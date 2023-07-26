classdef Light < handle
    %LIGHT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        position            % 1x3 position de la lumiere dans la scene
        couleurLumiere      % 1x3 couleur de la lumière

        forme ElementFace   % donne une forme a la lumiere

        directionLumiere    % 1x3 direction souhaité de la lumière (pour la lumière directionel ou spot)
        paramsLumiere       % [t a b] t = type (0 : desactivé, 1 : pointLight, 2 : directionel, 3 : spotLight)
                            % a et b sont les parametre d'intensité pour le pointLight.
                            % a et b sont les cos des angles pour la spotLight
        oldType             % sauvegarde le type de lumière avant de désactiver
    end
    
    methods
        function obj = Light(pos, col, dir, param)
            %LIGHT Construct an instance of this class
            if nargin < 1, pos   = [-5 -5  5]; end
            if nargin < 2, col   = [ 1  1  1]; end
            if nargin < 3, dir   = [ 0 -1  0]; end
            if nargin < 4, param = [ 0  0  0]; end
            obj.position = pos;
            obj.couleurLumiere = col;
            obj.directionLumiere = dir;
            obj.paramsLumiere = param;
        end % fin du constructeur de light

        function setForme(obj, elem)
            obj.forme = elem;
            obj.forme.setModelMatrix(MTrans3D(obj.position));
            obj.forme.setCouleurFaces(obj.couleurLumiere);
        end % fin de SetForme

        function setPosition(obj, newPos)
            obj.position = newPos;
            if ~isempty(obj.forme)
                obj.forme.setModelMatrix(MTrans3D(obj.position));
            end
        end % fin de SetPosition

        function setColor(obj, newCol)
            obj.couleurLumiere = newCol;
            if ~isempty(obj.forme)
                obj.forme.setCouleurFaces(newCol);
            end
        end % fin de setCouleur

        function setDirection(obj, newDir)
            obj.directionLumiere = newDir;
        end

        function setParam(obj, newParam)
            obj.paramsLumiere = newParam;
        end

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
        end % fin de desactivate

        function activate(obj)
            if obj.oldType > 0
                obj.paramsLumiere(1) = obj.oldType;
            end
        end % fin de activate

        function dotLight(obj, a, b)
            if nargin == 1
                a = 0.01; b = 0;
            end
            obj.paramsLumiere = [1 a b];
        end % fin de dot light

        function directionalLight(obj, direction)
            if nargin == 1
                direction = [0 -1 0];
            end
            obj.paramsLumiere = [2 0 0];
            obj.directionLumiere = direction;
        end % fin de directionalLight

        function spotLight(obj, angle, direction)
            if nargin == 1
                angle = 20; direction = [0 -1 0];
            end
            angles = [angle angle*1.3];
            angles = cos(deg2rad(angles));
            obj.paramsLumiere = [3 angles];
            obj.directionLumiere = direction;
        end % fin de spotLight
    end % fin des methodes defauts
end % fin classe light