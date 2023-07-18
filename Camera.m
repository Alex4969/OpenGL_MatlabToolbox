classdef Camera < handle
    %CAMERA Summary of this class goes here

    properties
        speed=0.1
        sensibility=100
    end

    properties (Access = private)
        %%% Attributs de la caméra
        position        % 1x3 position de la caméra
        target          % 1x3 position de la cible/objet regardé par la caméra
        up              % 1x3 position du vecteur pointant vers le haut (NORMALISE!)
        viewMatrix      % 4x4 matrice de transformation correspondant aux valeurs ci dessus

        orientation


        height
        width


        %%% Attributs de la projection
        near            % double distance du plan rapproché
        far             % double distance du plan éloigné
        ratio           % double ration d'observation (width/height)
        fov             % double angle de vue d'observation (en degré)
        type logical    % 1 pour perspective, 0 pour orthonormé
        projMatrix      % 4x4 matrice de transformation correspondant aux valeurs ci dessus
    end

    methods

        function obj = Camera(ratio)
        %CAMERA Construct an instance of this class
            obj.position = [5 5 5];
            obj.target = [0 0 0];
            obj.up = [0 1 0];
            obj.computeView();

            obj.near = 1;
            obj.far = 20;
            obj.ratio = ratio;
            obj.fov = 60;
            obj.type = 1;
            obj.computeProj();
        end % fin du constructeur camera

        function setPosition(obj, newPosition)
            obj.position = newPosition;
            obj.computeView();
        end % fin de setPosition

        function setTarget(obj, newTarget)
            obj.target = newTarget;
            obj.computeView();
        end % fin de setTarget

        function setUp(obj, newUp)
            obj.up = newUp;
            obj.computeView();
        end % fin de setView

        function setView(obj, newPos, newTarget, newUp)
            obj.position = newPos;
            obj.position = newTarget;
            if nargin == 4
                obj.up = newUp;
            end
            obj.computeView();
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
            if obj.type == 1
                obj.type = 0;
            else 
                obj.type = 1;
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

        function Mrot = getviewMatrix(obj)
            Mrot = obj.viewMatrix;
        end

    end %fin des methodes defauts

    % special transformations
    methods
        function translateXY(obj,dx,dy)
            obj.position=obj.position+[dx dy 0];
            % obj.target=obj.target+[dx dy 0];
            obj.computeView();
        end

        function zoom(obj,signe)
            facteur = 1 + signe*obj.speed;
            vect = obj.position - obj.target;
            vect = vect * facteur;
            obj.position = obj.target + vect;
            obj.computeView();
        end

        function rotate(obj, dx, dy)
            pos = obj.position;
            centre = obj.target;
            pos = pos - centre;
            matRot4 = MRot3D([dy -dx 0] * obj.sensibility);
            matRot3(1:3, 1:3) = matRot4(1:3, 1:3);
            newPos = pos * matRot3 + centre;
            obj.position = newPos;
            obj.computeView();
        end

        function defaultView(obj)
            obj.position=[2 2 10];
            obj.up=[0 1 0];
            obj.target=[0 0 0];
            obj.computeView();
        end  

        function upView(obj)
            obj.position=[0 10 0];
            obj.up=[1 0 0];
            obj.target=[0 0 0];
            obj.computeView();
        end  

    end

    methods (Access = private)
        
        function computeView(obj)
            Mrot = obj.computeRotationCamera();

            Mtrans = eye(4);
            Mtrans(1:3,4) = -obj.position';

            obj.viewMatrix = Mrot * Mtrans;
        end % fin de computeView

        function Mrot = computeRotationCamera(obj)
            forward = obj.position - obj.target;            
            forward = forward / norm(forward);

            left = cross(obj.up, forward);
            newUp = cross(forward, left);

            Mrot = eye(4);
            Mrot(1,1:3) = left;
            Mrot(2,1:3) = newUp;
            Mrot(3,1:3) = forward;
        end

        function computeProj(obj)
            if obj.type == 0 % vue ortho
                angle = obj.fov*pi/180; 
                xPlanFar = tan(angle/2) * obj.far;
                %xPlanFar = 9;
                obj.projMatrix = MProj3D('O', [xPlanFar, xPlanFar/obj.ratio, obj.near, obj.far]);
            else % vue en perspective
                obj.projMatrix = MProj3D('P', [obj.ratio, obj.fov, obj.near, obj.far]);
            end
        end % fin de computeProj

    end % fin des methodes privées

end %fin classe Camera