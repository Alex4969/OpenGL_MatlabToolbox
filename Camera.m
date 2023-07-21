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
        type logical    % 1 pour perspective, 0 pour orthonormé
        projMatrix      % 4x4 matrice de transformation correspondant aux valeurs ci dessus
    end

    properties

        %%% Attributes pour le mouvement
        speed = 0.15;
        %sensibility
        posCentreMvt = 0;   % 1x3 si pour donner un centre de rotation sinon le centre = target
    end

    methods

        function obj = Camera(ratio)
        %CAMERA Construct an instance of this class
            obj.position = [0 0 10];
            obj.target = [0 0 0];
            obj.up = [0 1 0];
            obj.computeView();

            obj.near = 0.1;
            obj.far = 100;
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

        function setCentreMvt(obj, newPos)
            obj.posCentreMvt = newPos;
        end % fin de setCentreMvt

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

        function Mrot = getViewMatrix(obj)
            Mrot = obj.viewMatrix;
        end

        function [thetaX, thetaY, thetaZ] = getRotationAngles(obj)
            sx=norm(obj.viewMatrix(1:3,1));
            sy=norm(obj.viewMatrix(1:3,2));
            sz=norm(obj.viewMatrix(1:3,3));
            R=obj.viewMatrix(1:3,1:3);
            R(1:3,1)=R(1:3,1)/sx;
            R(1:3,2)=R(1:3,2)/sy;
            R(1:3,3)=R(1:3,3)/sz;
            R(4, 4) = 1;
            
            thetaY=asin(-R(3,1));
            thetaZ=atan(R(2,1)/R(1,1));
            thetaX=atan(R(3,2)/R(3,3));
            if (obj.position(1) > 0 && obj.position(3) > 0)
                thetaY = -thetaY;
            elseif (obj.position(1) > 0 && obj.position(3) < 0)
                thetaY = pi + thetaY;
            elseif obj.position(1) < 0 && obj.position(3) < 0
                thetaY = pi + thetaY;
            else
                thetaY = 2*pi - thetaY;
            end
        end

        function MProj = getProjMatrix(obj)
            MProj = obj.projMatrix;
        end

    end %fin des methodes defauts

    % special transformations / gestion de la souris
    methods
        function translatePlanAct(obj,dx,dy)
            translation = dy * obj.up;
            left = cross(obj.position - obj.target, obj.up);
            left = left/norm(left);
            translation = translation + dx * left;
            translation = translation * (1 + obj.speed);
            obj.position = obj.position + translation;
            obj.target   = obj.target   + translation;
            obj.computeView();
        end % fin de translatePlanAct

        function zoom(obj,signe)
            facteur = 1 + signe*obj.speed;
            vect = obj.position - obj.target;
            vect = vect * facteur;
            obj.position = obj.target + vect;
            obj.computeView();
            if obj.type == 0 % recompute la matrice orthonorme car depend de la distance
                obj.computeProj();
            end
        end % fin de zoom

        function rotate(obj, dx, dy)
            if numel(obj.posCentreMvt) == 3
                centre = obj.posCentreMvt;
            else
                centre = obj.target;
            end
            pos = obj.position;
            pos = pos - centre;
            % conversion en coordonné sphérique et application du changement
            % en coordonnée spherique les axes ne sont pas dans le meme ordre : https://fr.wikipedia.org/wiki/Coordonn%C3%A9es_sph%C3%A9riques)
            rayon = norm(pos);
            theta = acos(pos(2) / rayon)   - dy;
            phi   = atan2(pos(1), pos(3))  - dx;
            if (theta < 0)
                theta = 0.01;
            elseif (theta > pi)
                theta = pi - 0.01;
            end
            % reconversion en coordonnée cartesien
            pos = [ sin(theta)*sin(phi)   cos(theta)   sin(theta)*cos(phi) ] * rayon;
            obj.position = pos + centre;
            obj.computeView();
        end % fin de rotate

        function defaultView(obj)
            obj.position=[0 0 10];
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
            left = left / norm(left);
            newUp = cross(forward, left);

            Mrot = eye(4);
            Mrot(1,1:3) = left;
            Mrot(2,1:3) = newUp;
            Mrot(3,1:3) = forward;
        end

        function computeProj(obj)
            if obj.type == 0 % vue ortho
                distance = norm(obj.position - obj.target);
                obj.projMatrix = MProj3D('O', [distance * obj.ratio, distance, obj.near, obj.far]);
            else % vue en perspective
                obj.projMatrix = MProj3D('P', [obj.ratio, obj.fov, obj.near, obj.far]);
            end
        end % fin de computeProj

    end % fin des methodes privées

end %fin classe Camera