classdef Light < handle
    %LIGHT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        position            % 1x3 position de la lumiere dans la scene
        couleurLumiere      % 1x3 couleur de la lumière

        forme ElementFace   % donne une forme a la lumiere
        comp  GeomComponent % component avant de devenir un elementFace

        directionLumiere    % 1x3 direction souhaité de la lumière (pour la lumière directionel ou spot)
        paramsLumiere       % [t a b] t = type (0 : desactivé, 1 : pointLight, 2 : directionel, 3 : spotLight)
                            % a et b sont les parametre d'intensité pour le pointLight.
                            % a et b sont les cos des angles pour la spotLight
        oldType             % sauvegarde le type de lumière avant de désactiver

        modelListener
        onCamera logical = false
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
                    obj.forme.visible = false;
                else 
                    obj.forme.visible = true;
                    obj.cbk_evt_updateModel(obj.forme.Geom)
                end
            end
        end

        function removeForme(obj)
            if ~isempty(obj.forme)
                delete(obj.modelListener);
                obj.forme = ElementFace.empty;
            end
        end % fin de removeForme

        function setPosition(obj, newPos)
            obj.position = newPos;
            if ~isempty(obj.forme)
                model = obj.forme.Geom.modelMatrix;
                model(1:3, 4) = newPos';
                obj.forme.setModelMatrix(model);
            end
            notify(obj, 'evt_updateUbo');
            obj.onCamera = false;
        end % fin de SetPosition

        function setPositionCamera(obj, newPos, target)
            obj.position = newPos;
            obj.directionLumiere = target - newPos;
            notify(obj, 'evt_updateUbo');
        end

        function setColor(obj, newCol)
            obj.couleurLumiere = newCol(1:3);
            if ~isempty(obj.forme) && any(obj.forme.couleur(1:3) ~= obj.couleurLumiere)
                obj.forme.setCouleur(obj.couleurLumiere);
            end
            notify(obj, 'evt_updateUbo');
        end % fin de setCouleur

        function setDirection(obj, newDir)
            obj.directionLumiere = newDir;
            notify(obj, 'evt_updateUbo');
        end % fin de setDirection

        function setParam(obj, newParam)
            obj.paramsLumiere = newParam;
            notify(obj, 'evt_updateUbo');
        end % fin de setParam

        function pos = getPosition(obj)
            pos = obj.position;
        end % fin de GetPosition

        function col = getColor(obj)
            col = obj.couleurLumiere;
        end % fin de GetPosition

        function dir = getDirection(obj)
            dir = obj.directionLumiere;
        end

        function param = getParam(obj)
            param = obj.paramsLumiere;
        end

        function desactivate(obj)
            if obj.paramsLumiere(1) > 0
                obj.oldType = obj.paramsLumiere(1);
            end
            obj.paramsLumiere(1) = 0;
            notify(obj, 'evt_updateUbo');
        end % fin de desactivate

        function activate(obj)
            if obj.oldType > 0
                obj.paramsLumiere(1) = obj.oldType;
            end
            notify(obj, 'evt_updateUbo');
        end % fin de activate

        function dotLight(obj, a, b)
            if nargin == 1
                a = 0.01; b = 0;
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

        function spotLight(obj, angle)
            if nargin == 1
                angle = 20;
            end
            angles = [angle angle*1.3];
            angles = cos(deg2rad(angles));
            obj.paramsLumiere = [3 angles];
            notify(obj, 'evt_updateUbo');
        end % fin de spotLight

        function cbk_evt_updateModel(obj, source, ~)
            newPos = source.modelMatrix(1:3, 4)';
            obj.position = newPos;
            notify(obj, 'evt_updateUbo');
        end

        function glUpdate(obj, gl, ~)
            if ~isempty(obj.comp)
                obj.forme = ElementFace(gl, obj.comp);
                obj.forme.setModelMatrix(MTrans3D(obj.position));
                obj.forme.setCouleur(obj.couleurLumiere);
                obj.forme.setModeRendu('U', 'S');
                obj.forme.glUpdate(gl, "evt_updateModel")
                obj.modelListener = addlistener(obj.forme.Geom,'evt_updateModel',@obj.cbk_evt_updateModel);
                obj.comp = GeomComponent.empty;
            end
        end % fin de glUpdate
    end % fin des methodes defauts
end % fin classe light