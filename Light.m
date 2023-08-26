classdef Light < handle
    %LIGHT
    
    properties (GetAccess = public, SetAccess = private)
        position       (1,3) double     %position de la lumiere dans la scene
        couleurLumiere (1,3) double     %couleur de la lumière

        forme           ElementFace     %donne une forme a la lumiere
        comp            MyGeom          %component avant de devenir un elementFace

        directionLumiere (1,3) double   %direction souhaité de la lumière (pour la lumière directionel ou spot)
        paramsLumiere   (1,3) double    %[t a b] t = type (0 : desactivé, 1 : pointLight, 2 : directionel, 3 : spotLight)
                                            %a et b sont les parametre d'intensité pour le pointLight.
                                            %a et b sont les cos des angles pour la spotLight
        oldType         (1,1) double    %sauvegarde le type de lumière avant de désactiver

        modelListener                   % listener de GeomComponent, permet de le supprimer quand si on retire la forme
        onCamera        logical = false % vrai pour fixer la lumiere a la camera
    end

    events
        evt_updateForme     % une forme pour la lumière a été ajouté et doit être générée
        evt_updateUbo       % mise a jour de l'ubo de scene3D nécéssaire
    end
    
    methods
        function obj = Light(pos, col, dir, param)
            %LIGHT Construct an instance of this class
            if nargin < 1, pos   = [ 5  5  5]; end
            if nargin < 2, col   = [ 1  1  1]; end
            if nargin < 3, dir   = [ 0 -1  0]; end
            if nargin < 4, param = [ 0  0  0]; end
            obj.position = pos;
            obj.couleurLumiere = col;
            obj.directionLumiere = dir;
            obj.paramsLumiere = param;
        end % fin du constructeur de light

        function elem = setForme(obj, comp)
            if ~isempty(obj.forme)
                delete(obj.modelListener);
                obj.forme = ElementFace.empty;
            end
            obj.comp = comp;
            notify(obj, 'evt_updateForme');
            elem = obj.forme;
        end % fin de setForme

        function putOnCamera(obj, b)
            if nargin == 1, b = true; end
            obj.onCamera = b;
            if (~isempty(obj.forme))
                if (b == true)
                    obj.forme.setVisibilite(false);
                else 
                    obj.forme.setVisibilite(true);
                    obj.cbk_updateModel(obj.forme.geom)
                end
            end
        end % fin de putOnCamera

        function removeForme(obj)
            if ~isempty(obj.forme)
                delete(obj.modelListener);
                obj.forme = ElementFace.empty;
            end
        end % fin de removeForme

        function setPosition(obj, newPos)
            obj.position = newPos;
            if ~isempty(obj.forme)
                model = obj.forme.geom.modelMatrix;
                model(1:3, 4) = newPos';
                obj.forme.setModelMatrix(model);
            end
            notify(obj, 'evt_updateUbo');
            obj.onCamera = false;
        end % fin de SetPosition

        function setColor(obj, newCol)
            obj.couleurLumiere = newCol(1:3);
            if ~isempty(obj.forme)
                obj.forme.setColor(obj.couleurLumiere);
            end
            notify(obj, 'evt_updateUbo');
        end % fin de setCouleur

        function setDirection(obj, newDir)
            obj.directionLumiere = newDir;
            notify(obj, 'evt_updateUbo');
        end % fin de setDirection

        function activate(obj)
            if obj.oldType > 0
                obj.paramsLumiere(1) = obj.oldType;
            end
            notify(obj, 'evt_updateUbo');
        end % fin de activate

        function desactivate(obj)
            if obj.paramsLumiere(1) > 0
                obj.oldType = obj.paramsLumiere(1);
            end
            obj.paramsLumiere(1) = 0;
            notify(obj, 'evt_updateUbo');
        end % fin de desactivate

        function dotLight(obj, a, b)
            % lumiere avec une atténuation de 1/a*dist² + b*dist + 1
            if nargin == 1
                a = 0.01; b = 0; % valeurs de a et b par defaut
            end
            obj.paramsLumiere = [1 a b];
            notify(obj, 'evt_updateUbo');
        end % fin de dot light

        function directionalLight(obj, direction)
            if nargin == 1
                direction = [0 -1 0];
            end
            obj.paramsLumiere = [2 0 0];
            obj.directionLumiere = direction;
            notify(obj, 'evt_updateUbo');
        end % fin de directionalLight

        function spotLight(obj, angleInt, angleExt)
            % lumiere de projecteur qui forme un cone
            % on a besoin d'un deuxieme angle pour avoir un effet d'attenuation de la lumiere doux
            if nargin == 3
                angles = [angleInt, angleExt];
            else
                if nargin == 1
                    angleInt = 20;
                end
                angles = [angleInt angleInt*1.3];
            end
            angles = cos(deg2rad(angles));
            obj.paramsLumiere = [3 angles];
            notify(obj, 'evt_updateUbo');
        end % fin de spotLight
    end % fin des methodes defauts

    methods (Hidden = true)
        function setPositionWithCamera(obj, newPos, direction)
            % positionne la lumiere & la direction comme la camera
            obj.position = newPos;
            obj.directionLumiere = direction;
            notify(obj, 'evt_updateUbo');
        end % fin de setPositionWithCamera

        function cbk_updateModel(obj, source, ~)
            newPos = source.modelMatrix(1:3, 4)';
            obj.position = newPos;
            notify(obj, 'evt_updateUbo');
        end % fin de cbk_updateModel

        function glUpdate(obj, gl, ~)
            obj.forme = ElementFace(gl, obj.comp);
            obj.forme.setModelMatrix(MTrans3D(obj.position));
            obj.forme.setColor(obj.couleurLumiere);
            obj.forme.setModeRendu("UNIFORME", "SANS");
            obj.forme.glUpdate(gl, "evt_updateModel")
            obj.modelListener = addlistener(obj.forme.geom,'evt_updateModel',@obj.cbk_updateModel);
        end % fin de glUpdate
    end % fin des methodes cachées
end % fin classe light