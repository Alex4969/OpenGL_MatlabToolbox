classdef Light < handle
    %LIGHT
    
    properties (GetAccess = public, SetAccess = private)
        position       (1,3) double     %position de la lumiere dans la scene
        color (1,3) double     %couleur de la lumière

        forme           ElementFace     %donne une forme a la lumiere
        comp            MyGeom          %component avant de devenir un elementFace

        direction (1,3) double   %direction souhaité de la lumière (pour la lumière directionel ou spot)
        Type   (1,4) double    %[t a b method] t = type (0 : desactivé, 1 : pointLight, 2 : directionel, 3 : spotLight)
                                            %a et b sont les parametre d'intensité pour le pointLight.
                                            %a et b sont les cos des angles pour la spotLight
                                            % method : intensity calculation method

        Intensity       (1,4) double    % [global ambient specular diffuse]
        storedIntensity (1,4) double    %sauvegarde le type de lumière avant de désactiver

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
            if nargin < 4, param = [ 0  0  0 1]; end
            obj.position = pos;
            obj.color = col;
            obj.direction = dir;
            obj.Type = param;
            obj.Intensity=[1 0.3 0.5 1]; %global |ambient | specular | diffuse
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
            if nargin == 1 ; b = true ; end
            
            obj.onCamera = b;
            if (~isempty(obj.forme)) % a light shape exist
                if (b == true)
                    obj.forme.setVisible(false);
                else 
                    obj.forme.setVisible(true);
                    obj.cbk_updateModel(obj.forme.geom);
                end
                % obj.cbk_updateModel(obj.forme.geom);
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
            obj.color = newCol(1:3);
            if ~isempty(obj.forme)
                obj.forme.setColor(obj.color);
            end
            notify(obj, 'evt_updateUbo');
        end % fin de setCouleur

        function setIntensity(obj,newI)
            obj.Intensity=newI;
            notify(obj, 'evt_updateUbo');
        end

        function setDirection(obj, newDir)
            obj.direction = newDir;
            notify(obj, 'evt_updateUbo');
        end % fin de setDirection

        function activate(obj,state)
            if state %activated
                obj.Intensity=obj.storedIntensity;
            else %desactivated
                obj.storedIntensity=obj.Intensity;
                obj.Intensity = [0 0 0 0];
            end
            notify(obj, 'evt_updateUbo');
        end % fin de activate

        function setType(obj,type,param)
            arguments
                obj
                type enum.LightType
                param
            end

            switch type
                case enum.LightType.point %&& length(param)==3
                    if nargin == 2
                        param(1) = 0.01; param(2) = 0; % light parameters function
                        param(3)=1; % calculation method
                    end
                    obj.Type = [1 param(1) param(2) param(3)];

                case enum.LightType.directionnal %&& length(param)==3)
                    if nargin == 2
                        param = [0 -1 0];
                    end
                    obj.Type = [2 0 0 0];
                    obj.direction=param;
                    
                case enum.LightType.spot
                    if nargin == 2
                        param = [5 10]; % inner and outer angle in degrees
                    end
                    param=cosd(param);
                    obj.Type = [3 param(1) param(2) 0];
            end

            notify(obj, 'evt_updateUbo');

        end

        function dotLight(obj, a, b, method)
            % intensite calculation depends on method
            % 1 : I=exp(-a*dist)
            % 2 : I=1/a*dist² + b*dist + 1
            % voir allfrag.glsl
            if nargin == 1
                a = 0.01; b = 0; % valeurs de a et b par defaut
            end
            obj.Type = [1 a b method];
            notify(obj, 'evt_updateUbo');
        end % fin de dot light

        function directionalLight(obj, direction)
            if nargin == 1
                direction = [0 -1 0];
            end
            obj.Type = [2 0 0 0];
            obj.direction = direction;
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
            obj.Type = [3 angles 0];
            notify(obj, 'evt_updateUbo');
        end % fin de spotLight
    
    end
    % fin des methodes defauts

    methods (Hidden = true)
        function setPositionWithCamera(obj, newPos, direction)
            % positionne la lumiere & la direction comme la camera
            obj.position = newPos;
            obj.direction = direction;
            % % % notify(obj, 'evt_updateUbo');
        end
        % fin de setPositionWithCamera

        function cbk_updateModel(obj, source, ~)
            newPos = source.modelMatrix(1:3, 4)';
            obj.position = newPos;
            notify(obj, 'evt_updateUbo');
        end
        % fin de cbk_updateModel

        function glUpdate(obj, gl, ~)
            obj.forme = ElementFace(gl, obj.comp);
            obj.forme.setModelMatrix(MTrans3D(obj.position));

            obj.forme.setColor(obj.color);
            obj.forme.setModeRendu("UNIFORME", "SANS");
            obj.forme.glUpdate(gl, "evt_updateModel")
            obj.modelListener = addlistener(obj.forme.geom,'evt_updateModel',@obj.cbk_updateModel);
        end

    end % fin des methodes cachées
end % fin classe light
