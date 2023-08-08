classdef Camera < handle
    %CAMERA Summary of this class goes here

    properties (GetAccess = public, SetAccess = protected)
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

        UBOId               % uniform block
        UBOBuffer           % uniform block buffer
        updateNeeded logical
    end

    properties
        %%% Attributes pour le mouvement
        speed = 5;
        sensibility =1;

        posCentreMvt = 0;   % 1x3 si pour donner un centre de rotation sinon le centre = target

        constraint logical  % 1x3 pour chaque axe
    end

    methods

        function obj = Camera(gl, ratio)
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
            obj.constraint = [false, false, false];

            obj.generateUbo(gl);
            obj.updateNeeded = true;
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
        
        function ratio = getRatio(obj)
            ratio = obj.ratio;
        end

        function pos = getPosition(obj)
            pos = obj.position;
        end % fin de getPosition

        function Mrot = getViewMatrix(obj)
            Mrot = obj.viewMatrix;
        end

        function MProj = getProjMatrix(obj)
            MProj = obj.projMatrix;
        end

        function att = getAttributes(obj) % contient near, maxY, maxX, coef, view, proj, ratio
            att.near = obj.near;
            if obj.type % perpective
                maxY = obj.near * tan(deg2rad(obj.fov/2));
                att.coef = 0.01;
            else
                maxY = norm(obj.position - obj.target)/2;
                att.coef = 0.173 * maxY; % 0.173 trouvé par essaies
            end
            maxX = maxY * obj.ratio;
            att.maxX  = maxX;
            att.maxY = maxY;
            att.view = obj.viewMatrix;
            att.proj = obj.projMatrix;
            att.ratio = obj.ratio;
        end % fin de getAttribute

    end %fin des methodes defauts

    methods % special transformations / gestion de la souris
        function translatePlanAct(obj,dx,dy)
            if any(obj.constraint)
                dz = 0;
                if obj.constraint(3)
                    if obj.constraint(2)
                        dz = dx;
                    else
                        dz = -dy;
                    end
                end
                translation =  [-dx, dy, dz] .* obj.constraint;
            else
                translation = dy * obj.up;
                left = cross(obj.position - obj.target, obj.up);
                left = left/norm(left);
                translation = translation + dx * left;
                translation = translation * (1 + obj.speed);
            end
            obj.position = obj.position + translation * obj.speed;
            obj.target   = obj.target   + translation * obj.speed;
            obj.computeView();
        end % fin de translatePlanAct

        function zoom(obj,signe)
            facteur = 1 + signe * 0.05 * obj.sensibility;
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
            theta = acos(pos(2) / rayon)   - dy * obj.sensibility;
            phi   = atan2(pos(1), pos(3))  - dx * obj.sensibility;
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

        function faceView(obj)
            obj.position=[0 0 10];
            obj.up=[0 1 0];
            obj.target=[0 0 0];
            obj.computeView();
        end        

        function xorConstraint(obj, l)
            obj.constraint = bitxor(obj.constraint, l);
            if all(obj.constraint)
                obj.constraint = l;
            end
        end

        function resetConstraint(obj)
            obj.constraint = [false false false];
        end

        function generateUbo(obj, gl)
            obj.UBOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenBuffers(1, obj.UBOBuffer);
            obj.UBOId = typecast(obj.UBOBuffer.array(), 'uint32');
            gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, obj.UBOId);
            gl.glBufferData(gl.GL_UNIFORM_BUFFER, 16, [], gl.GL_DYNAMIC_DRAW);
            gl.glBindBufferRange(gl.GL_UNIFORM_BUFFER, 1, obj.UBOId, 0, 16);
            gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, 0);
        end

        function remplirUbo(obj, gl)
            if obj.updateNeeded
                gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, obj.UBOId);
                vecUni = java.nio.FloatBuffer.allocate(4);
                vecUni.put(obj.position(:));
                vecUni.rewind();
                gl.glBufferSubData(gl.GL_UNIFORM_BUFFER, 0, 16, vecUni);
                gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, 0);
            end
            obj.updateNeeded = false;
        end
    end % fin des methodes liés au mouvements de souris

    methods (Access = private)
        function computeView(obj)
            Mrot = obj.computeRotationCamera();

            Mtrans = eye(4);
            Mtrans(1:3,4) = -obj.position';

            obj.viewMatrix = Mrot * Mtrans;
            obj.updateNeeded = true;
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
                obj.projMatrix = MProj3D('O', [distance * obj.ratio, distance, -obj.far, obj.far]);
            else % vue en perspective
                obj.projMatrix = MProj3D('P', [obj.ratio, obj.fov, obj.near, obj.far]);
            end
        end % fin de computeProj
    end % fin des methodes privées
end %fin classe Camera