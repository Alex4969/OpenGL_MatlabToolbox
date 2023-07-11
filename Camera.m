classdef Camera < handle
    %CAMERA Summary of this class goes here

    properties (Access = private)
        %%% Attributs de la caméra
        position        % 1x3 position de la caméra
        target          % 1x3 position de la cible/objet regardé par la caméra
        up              % 1x3 position du vecteur pointant vers le haut (NORMALISE!)
        viewMatrix      % 4x4 matrice de transformation correspondant aux valeurs ci dessus

        %%% Attributs de la projection
        near            % double distance du plan rapproché
        far             % double distance du plan éloigné
        ratio           % double ration d'observation (width/height)
        fov             % double angle de vue d'observation (en degré)
        type            % 'P' pour perspective, 'O' pour orthonormé
        projMatrix      % 4x4 matrice de transformation correspondant aux valeurs ci dessus
    end

    methods

        function obj = Camera(ratio)
        %CAMERA Construct an instance of this class
            obj.position = [5 5 5];
            obj.target = [0 0 0];
            obj.up = [0 1 0];
            obj.lookAt();

            obj.near = 0.1;
            obj.far = 100;
            obj.ratio = ratio;
            obj.fov = 60;
            obj.type = 'P';
            obj.computeProj();
        end % fin du constructeur camera

        function setPosition(obj, newPosition)
            obj.position = newPosition;
            obj.lookAt();
        end % fin de setPosition

        function setTarget(obj, newTarget)
            obj.target = newTarget;
            obj.lookAt();
        end % fin de setTarget

        function setUp(obj, newUp)
            obj.up = newUp;
            obj.lookAt();
        end % fin de setView

        function setView(obj, newPos, newTarget, newUp)
            obj.position = newPos;
            obj.position = newTarget;
            if nargin == 4
                obj.up = newUp;
            end
            obj.lookAt();
        end % fin de setView

        function setProj(obj, newType, newRatio, newFov, newNear, newFar)
            obj.type  = newType;
            obj.ratio = newRatio;
            obj.fov   = newFov;
            obj.near  = newNear;
            obj.far   = newFar;
            obj.computeProj();
        end % fin de setProj

        function switchProjType(obj)
        %%%TODO Faire la conversion proprement !!
            if obj.type == 'P'
                obj.type = 'O';
            else 
                obj.type = 'P';
            end
            obj.computeProj();
        end % fin de switchProjType

        function setNearFar(obj, newNear, newFar)
            obj.near = newNear;
            obj.far = newFar;
            obj.computeProj();
        end % fin de setNearFar

        function setRatio(obj, newRatio)
            obj.ratio = newRatio;
            obj.computeProj();
        end % fin de setRation

        function setFov(obj, newFov)
            obj.fov = newFov;
            obj.computeProj();
        end % fin de setFov
        
        function pos = getPosition(obj)
            pos = obj.position;
        end % fin de getPosition

        function camMat = getCameraMatrix(obj)
            camMat = obj.projMatrix * obj.viewMatrix;
        end % fin de getCameraMatrix

    end %fin des methodes defauts

    methods (Access = private)
        
        function lookAt(obj)
            forward = obj.position - obj.target;            
            forward = forward / norm(forward);

            left = cross(obj.up, forward);
            newUp = cross(forward, left);

            Mrot = eye(4);
            Mrot(1,1:3) = left;
            Mrot(2,1:3) = newUp;
            Mrot(3,1:3) = forward;

            Mtrans = eye(4);
            Mtrans(1:3,4) = -obj.position';

            obj.viewMatrix = Mrot * Mtrans;
        end % fin de lookAt

        function computeProj(obj)
            obj.projMatrix = MProj3D(obj.type, [obj.ratio, obj.fov, obj.near, obj.far]);
        end % fin de computeProj

    end % fin des methodes privées

end %fin classe Camera