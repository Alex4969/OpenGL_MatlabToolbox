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

        UBOId               % uniform block
        UBOBuffer           % uniform block buffer
        updateNeeded logical

        modelListener
    end
    
    methods
        function obj = Light(gl, pos, col, dir, param)
            %LIGHT Construct an instance of this class
            if nargin < 2, pos   = [ 5  5  5]; end
            if nargin < 3, col   = [ 1  1  1]; end
            if nargin < 4, dir   = [ 0 -1  0]; end
            if nargin < 5, param = [ 0  0  0]; end
            obj.position = pos;
            obj.couleurLumiere = col;
            obj.directionLumiere = dir;
            obj.paramsLumiere = param;
            obj.generateUbo(gl);
            obj.remplirUbo(gl);
            obj.updateNeeded = false;
        end % fin du constructeur de light

        function setForme(obj, elem)
            if ~isempty(obj.forme)
                obj.forme.setParent([]);
                delete(obj.modelListener);
            end
            obj.forme = elem;
            obj.forme.setModelMatrix(MTrans3D(obj.position));
            obj.forme.setCouleur(obj.couleurLumiere);
            obj.forme.setParent(obj);
            obj.forme.setModeRendu('U', 'S');
            obj.modelListener = addlistener(obj.forme.Geom,'modelUpdate',@obj.cbk_modelUpdate);
        end % fin de setForme

        function removeForme(obj)
            if ~isempty(obj.forme)
                obj.forme.setParent([]);
            end
        end % fin de removeForme

        function setPosition(obj, newPos)
            obj.position = newPos;
            if ~isempty(obj.forme)
                obj.forme.setModelMatrix(MTrans3D(obj.position));
            end
            obj.updateNeeded = true;
        end % fin de SetPosition

        function setColor(obj, newCol)
            obj.couleurLumiere = newCol(1:3);
            if ~isempty(obj.forme) && any(obj.forme.couleur(1:3) ~= obj.couleurLumiere)
                obj.forme.setCouleur(obj.couleurLumiere);
            end
            obj.updateNeeded = true;
        end % fin de setCouleur

        function setDirection(obj, newDir)
            obj.directionLumiere = newDir;
            obj.updateNeeded = true;
        end % fin de setDirection

        function setParam(obj, newParam)
            obj.paramsLumiere = newParam;
            obj.updateNeeded = true;
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
            obj.updateNeeded = true;
        end % fin de desactivate

        function activate(obj)
            if obj.oldType > 0
                obj.paramsLumiere(1) = obj.oldType;
            end
            obj.updateNeeded = true;
        end % fin de activate

        function dotLight(obj, a, b)
            if nargin == 1
                a = 0.01; b = 0;
            end
            obj.paramsLumiere = [1 a b];
            obj.updateNeeded = true;
        end % fin de dot light

        function directionalLight(obj, direction)
            if nargin == 1
                direction = [0 -1 0];
            end
            obj.paramsLumiere = [2 0 0];
            obj.directionLumiere = direction;
            obj.updateNeeded = true;
        end % fin de directionalLight

        function spotLight(obj, angle, direction)
            if nargin == 1
                angle = 20; direction = [0 -1 0];
            end
            angles = [angle angle*1.3];
            angles = cos(deg2rad(angles));
            obj.paramsLumiere = [3 angles];
            obj.directionLumiere = direction;
            obj.updateNeeded = true;
        end % fin de spotLight

        function generateUbo(obj, gl)
            obj.UBOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenBuffers(1, obj.UBOBuffer);
            obj.UBOId = typecast(obj.UBOBuffer.array(), 'uint32');
            gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, obj.UBOId);
            gl.glBufferData(gl.GL_UNIFORM_BUFFER, 64, [], gl.GL_DYNAMIC_DRAW);
            gl.glBindBufferRange(gl.GL_UNIFORM_BUFFER, 0, obj.UBOId, 0, 64);
            gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, 0);
        end

        function remplirUbo(obj, gl)
            if obj.updateNeeded
                gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, obj.UBOId);
                obj.putVec(gl, obj.position, 0);
                obj.putVec(gl, obj.couleurLumiere, 16);
                obj.putVec(gl, obj.directionLumiere, 32);
                obj.putVec(gl, obj.paramsLumiere, 48);
                gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, 0);
            end
            obj.updateNeeded = false;
        end

        function cbk_modelUpdate(obj, source, ~)
            % disp('je suis ici');
            newPos = source.modelMatrix(1:3, 4)';
            if any(newPos == obj.position)
                obj.setPosition(newPos);
            end
        end
    end % fin des methodes defauts

    methods (Access = private)
        function putVec(~, gl, vec, deb)
            vecUni = java.nio.FloatBuffer.allocate(4);
            vecUni.put(vec(:));
            vecUni.rewind();
            gl.glBufferSubData(gl.GL_UNIFORM_BUFFER, deb, 16, vecUni);
        end
    end % fin des methodes privees
end % fin classe light