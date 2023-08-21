classdef Camera < handle
    %CAMERA Gestion d'une caméra pour la scène 3D
    properties (GetAccess = public, SetAccess = private)
        %%% Attributs de la caméra
        position    (1,3) double   % position de la caméra
        targetDir   (1,3) double   % position de la cible/objet regardé par la caméra
        up          (1,3) double   % position du vecteur pointant vers le haut (NORMALISE!)
        viewMatrix  (4,4) double   % matrice de vue correspondant aux valeurs ci dessus

        %%% Attributs de la projection
        near        (1,1) double   % distance du plan rapproché
        far         (1,1) double   % distance du plan éloigné
        ratio       (1,1) double   % ration d'observation (width/height)
        fov         (1,1) double   % angle de vue d'observation (en degré) mieux entre 50 & 80
        type        (1,1) logical  % 1 pour perspective, 0 pour orthonormé
        projMatrix  (4,4) double   % matrice de projection correspondant aux valeurs ci dessus

        %%% Attributs pour le mouvement
        speed       (1,1) double = 5;
        sensibility (1,1) double = 2;
        centreMvt   (1,3) double   % Centre de la rotation
        constraint  (1,3) logical  % pour chaque axe
    end

    events
        evt_updateUbo       % mise a jour du Ubo de scene 3D necessaire
    end

    methods
        function obj = Camera(ratio)
        %CAMERA Construct an instance of this class
            obj.position = [0 0 10];
            obj.centreMvt = [0 0 0];
            obj.targetDir = obj.centreMvt - obj.position;
            obj.up = [0 1 0];
            obj.computeView();

            obj.near = 0.1;
            obj.far = 100;
            obj.ratio = ratio;
            obj.fov = 60;
            obj.type = 1;
            obj.computeProj();
            obj.constraint = [false, false, false];
        end % fin du constructeur camera

        function setPosition(obj, newPosition)
            obj.position = newPosition;
            obj.computeView();
        end % fin de setPosition

        function setTarget(obj, newTarget, changeDirection)
            %SETTARGET : modifie le centre du mouvement, si changeDirection
            %== true, on oriente la camera vers ce point
            obj.centreMvt = newTarget;
            if nargin == 3 && changeDirection == true
                obj.targetDir = newTarget - obj.position;
            end
            obj.computeView();
        end % fin de setTarget

        function setUp(obj, newUp)
            obj.up = newUp;
            obj.computeView();
        end % fin de setUp

        function switchProjType(obj)
            obj.type = bitxor(obj.type, 1);
            obj.computeProj();
        end % fin de switchProjType

        function setNearFar(obj, newNear, newFar)
            obj.near = newNear;
            obj.far  = newFar;
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

        function att = getAttributes(obj) % contient near, maxY, maxX, coef, view, proj, ratio
            att.near = obj.near;
            if obj.type % perspective
                maxY = obj.near * tan(deg2rad(obj.fov/2));
                att.coef = 0.1 * obj.near; % ne s'adapte pas aux variations de fov...
            else
                maxY = norm(obj.targetDir)/2;
                att.coef = 0.173 * maxY; % 1.73 trouvé par essaies
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
            if any(obj.constraint) % si une contrainte axial est présente : 
                dz = 0;
                if obj.constraint(3)
                    if obj.constraint(2)
                        dz = dx;
                    else
                        dz = -dy;
                    end
                end
                translation =  [dx, dy, dz] .* obj.constraint;
            else % si aucune constrainte on se met dans le plan de la caméra parallele au plan Oxy
                translation = dy * obj.up;
                left = cross(obj.targetDir, obj.up);
                left = left/norm(left);
                translation = translation - dx * left;
            end
            obj.position = obj.position + translation * obj.speed;
            obj.centreMvt = obj.centreMvt + translation * obj.speed;
            obj.computeView();
        end % fin de translatePlanAct

        function zoom(obj,signe)
            %ZOOM se deplace dans la direction de la target
            dist = vecnorm(obj.position);
            dist = sqrt(dist); % plus on est pres, plus on est precis,
            dist = ceil(dist); % fonctionne par palier grace au ceil
            facteur = signe * dist * 0.3;
            vect = obj.targetDir/norm(obj.targetDir);
            if norm(obj.position) - facteur *  norm(vect) > obj.near
                obj.position = obj.position + vect * facteur;
            end
            obj.computeView();
            if obj.type == 0 % recompute la matrice orthonorme car depend de la distance
                obj.computeProj();
            end
        end % fin de zoom

        function rotate(obj, dx, dy)
            centre = obj.centreMvt;
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
            obj.targetDir = centre - obj.position;
            obj.computeView();
        end % fin de rotate

        function defaultView(obj)
            obj.position = [10 10 10];
            obj.up = [0 1 0];
            obj.targetDir = obj.centreMvt - obj.position;
            obj.centreMvt = [0 0 0];
            obj.computeView();
        end  

        function upView(obj)
            obj.position = [0 10 0];
            obj.up = [1 0 0];
            obj.targetDir = obj.centreMvt - obj.position;
            obj.centreMvt = [0 0 0];
            obj.computeView();
        end

        function faceView(obj)
            obj.position = [0 0 10];
            obj.up = [0 1 0];
            obj.targetDir = obj.centreMvt - obj.position;
            obj.centreMvt = [0 0 0];
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
    end % fin des methodes liés au mouvements de souris

    methods (Access = private)
        function computeView(obj)
            forward = -obj.targetDir;            
            forward = forward / norm(forward);

            left = cross(obj.up, forward);
            left = left / norm(left);
            newUp = cross(forward, left);

            Mrot = eye(4);
            Mrot(1,1:3) = left;
            Mrot(2,1:3) = newUp;
            Mrot(3,1:3) = forward;

            Mtrans = eye(4);
            Mtrans(1:3,4) = -obj.position';

            obj.viewMatrix = Mrot * Mtrans;
            notify(obj, 'evt_updateUbo');
        end % fin de computeView

        function computeProj(obj)
            if obj.type == 0 % vue ortho
                distance = norm(obj.targetDir);
                obj.projMatrix = MProj3D('O', [distance * obj.ratio, distance, -obj.far, obj.far]);
            else % vue en perspective
                obj.projMatrix = MProj3D('P', [obj.ratio, obj.fov, obj.near, obj.far]);
            end
        end % fin de computeProj
    end % fin des methodes privées
end %fin classe Camera