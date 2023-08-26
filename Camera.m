classdef Camera < matlab.mixin.Copyable
    %CAMERA Gestion d'une caméra pour la scène 3D
    % Author : Alexandre Biaud
    % Modif : Philippe Duvauchelle
    % Date : august 2023

    properties (Constant)
        SPEED_MIN=1   %min camera speed
        SPEED_MAX=100 %max camera speed
        SENSIBILITY_MIN=0.01   %min camera sensibility
        SENSIBILITY_MAX=1   %min camera sensibility
    end

    properties (GetAccess = public, SetAccess = protected)
        %%% Attributs de la caméra
        position    (1,3) double   % position de la caméra
        target      (1,3) double   % Centre de la rotation
        % targetDir   (1,3) double   % position de la cible/objet regardé par la caméra
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
        sensibility (1,1) double = 1;
        
        constraint  (1,3) logical  % pour chaque axe
    end

    properties (SetAccess=public)
        smooth      (1,1) uint32 = 25; % For interpolated moving : step number
    end

    events
        evt_updateUbo       % mise a jour du Ubo de scene 3D necessaire
    end

    methods
        %CAMERA Constructor
        function obj = Camera(ratio)
        
            obj.position = [0 0 10];
            obj.target = [0 0 0];
            % obj.targetDir = obj.target - obj.position;
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
    end

    % set and get
    methods
        % Camera position
        function setPosition(obj, newPosition)
            obj.position = newPosition;
            obj.computeView();
        end % fin de setPosition

        % Direction position -> target
        function dir=getDirection(obj)
            dir=obj.target - obj.position;
        end

        % Target : point looked at
        function setTarget(obj, newTarget)
            obj.target = newTarget;
            obj.computeView();
        end % fin de setTarget

        % Vertical direction
        function setUp(obj, newUp)
            obj.up = newUp;
            obj.computeView();
        end % fin de setUp

        %Perspective or orthographic
        function switchProjType(obj)
            obj.type = bitxor(obj.type, 1);
            obj.computeProj();
        end % fin de switchProjType

        % Camera near and far planes
        function setNearFar(obj, newNear, newFar)
            obj.near = newNear;
            obj.far  = newFar;
            obj.computeProj();
        end % fin de setNearFar

        % Ration Width/Height
        function setRatio(obj, newRatio)
            obj.ratio = newRatio;
            obj.computeProj();
        end % fin de setRation

        % FOV : Field Of View (perspective mode)
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
                maxY = norm(obj.getDirection)/2;
                att.coef = 0.173 * maxY; % 1.73 trouvé par essaies
            end
            maxX = maxY * obj.ratio;
            att.maxX  = maxX;
            att.maxY = maxY;
            att.view = obj.viewMatrix;
            att.proj = obj.projMatrix;
            att.ratio = obj.ratio;
        end % fin de getAttribute
    
        % Speed of camera
        function changeSpeed(obj,increment)
            if increment>0
                obj.speed=min(obj.SPEED_MAX,obj.speed+increment);
            else
                obj.speed=max(obj.SPEED_MIN,obj.speed+increment);
            end
            obj.speed
        end
    
        % Camera sensibility
        function changeSensibility(obj,increment)
            if increment>0
                obj.sensibility=min(obj.SENSIBILITY_MAX,obj.sensibility+increment);
            else
                obj.sensibility=max(obj.SENSIBILITY_MIN,obj.sensibility+increment);
            end
            obj.sensibility
        end

    end %fin des methodes defauts

    methods % Mouse moving methods
        
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
                left = cross(obj.getDirection, obj.up);
                left = left/norm(left);
                translation = translation - dx * left;
            end
            obj.position = obj.position + translation * obj.speed;
            obj.target = obj.target + translation * obj.speed;
            obj.computeView();
        end % fin de translatePlanAct

        % Zoom : sign = +/-1
        % modifiers : extented modifiers (SHIFT: slower , CTRL : faster)
        function zoom(obj,signe,modifiers)
            %ZOOM se deplace dans la direction de la target
            % % % dist = vecnorm(obj.position);
            % % % dist = sqrt(dist); % plus on est pres, plus on est precis,
            % % % dist = ceil(dist); % fonctionne par palier grace au ceil
            % % % facteur = signe * dist *0.3; % obj.speed; 

            if nargin==2
                modifiers=0;
            end

            dist=norm(obj.position-obj.target);
            facteur = signe * dist *0.1*obj.sensibility; % obj.speed; % pourcentage de la distance restante
            
            if modifiers==128 %CTRL : faster
                facteur=facteur*3;
            elseif modifiers==64 %SHIFT : slower
                facteur=facteur/3;
            end
            vect = obj.getDirection/norm(obj.getDirection);

            if norm(obj.position + vect * facteur-obj.target)>obj.near %dist>obj.near
                obj.position = obj.position + vect * facteur;
            end

            obj.computeView();
            if obj.type == 0 % recompute la matrice orthonorme car depend de la distance
                obj.computeProj();
            end
        end % fin de zoom

        % Rotation around camera axis, theta in degree
        function rotationAroundAxis(obj,theta)
            forward = -obj.getDirection();            
            forward = forward / norm(forward);

            %up=[sind(theta) cosd(theta) 0];
            left = cross(forward,obj.up);
            left = left / norm(left);

            up = cross(left,forward);
            up = up / norm(up);        

            obj.up=sind(theta)*left+cosd(theta)*up;

            obj.computeView();
            
            % newUp=sind(theta)*left+cosd(theta)*up;
            % left = cross(forward,newUp);
            % left = left / norm(left);
            % 
            % 
            % Mrot = eye(4);
            % Mrot(1,1:3) = left;
            % Mrot(2,1:3) = newUp;
            % Mrot(3,1:3) = forward;
            % 
            % Mtrans = eye(4);
            % Mtrans(1:3,4) = -obj.position';
            % 
            % obj.up=newUp;
            % obj.viewMatrix = Mrot * Mtrans;
            % notify(obj, 'evt_updateUbo');
        end

        % Rotation around camera axis depending on mouse move
        % rotation is more sensible when clicked point is far from the
        % figure's center
        function selfRotate(obj,posX,posY,dx,dy)
            P=[posX posY 0];
            R=norm(P);
            u=[dx dy 0];
            sens=sign(cross(P,u));
            theta=sens(3)*R*obj.speed;
            obj.rotationAroundAxis(theta);
        end

        % Rotatin due to (dx,dy) mouse move
        function rotate(obj, dx, dy,centre)

            target=obj.target;
            obj.setTarget(centre);

            pos = obj.position;
            pos = pos - centre;
            % conversion en coordonné sphérique et application du changement
            % en coordonnée spherique les axes ne sont pas dans le meme ordre : https://fr.wikipedia.org/wiki/Coordonn%C3%A9es_sph%C3%A9riques)
            rayon = norm(pos);
            theta = acos(pos(2) / rayon)   - dy * obj.sensibility;
            phi   = atan2(pos(1), pos(3))  - dx * obj.sensibility;
            % [phi1,theta1,rayon1]=cart2sph(pos(3),pos(1),pos(2)); %idem que les 3 lignes precedentes
            % theta1 = (pi/2-theta1)   - dy * obj.sensibility;
            % phi1   = phi1  - dx * obj.sensibility;

            if (theta < 0)
                theta = 0.01;
            elseif (theta > pi)
                theta = pi - 0.01;
            end
            % reconversion en coordonnée cartesien
            pos = [ sin(theta)*sin(phi)   cos(theta)   sin(theta)*cos(phi) ] * rayon;
            obj.position = pos + centre;
            % obj.targetDir = obj.target - obj.position;
            % obj.setTarget(target);
            obj.computeView();
        end % fin de rotate

        function obsolete_rotate(obj, dx, dy)
            centre = obj.target;
            pos = obj.position;
            pos = pos - centre;
            % conversion en coordonné sphérique et application du changement
            % en coordonnée spherique les axes ne sont pas dans le meme ordre : https://fr.wikipedia.org/wiki/Coordonn%C3%A9es_sph%C3%A9riques)
            rayon = norm(pos);
            theta = acos(pos(2) / rayon)   - dy * obj.sensibility;
            phi   = atan2(pos(1), pos(3))  - dx * obj.sensibility;
            % [phi1,theta1,rayon1]=cart2sph(pos(3),pos(1),pos(2)); %idem que les 3 lignes precedentes
            % theta1 = (pi/2-theta1)   - dy * obj.sensibility;
            % phi1   = phi1  - dx * obj.sensibility;

            if (theta < 0)
                theta = 0.01;
            elseif (theta > pi)
                theta = pi - 0.01;
            end
            % reconversion en coordonnée cartesien
            pos = [ sin(theta)*sin(phi)   cos(theta)   sin(theta)*cos(phi) ] * rayon;
            obj.position = pos + centre;
            % obj.targetDir = centre - obj.position;
            obj.computeView();
        end % fin de rotate

    end %% end methods for mouse moving

    methods %specific view
        
        function defaultView(obj,cadran,dist)
            if nargin==1
                cadran=2;
                dist=10;
            elseif nargin==2
                dist=10;
            elseif nargin==3
                dist=abs(dist);
            end
            
            switch cadran
                case 1
                    obj.position = [-dist dist dist];
                case 2
                    obj.position = [dist dist dist];
                case 3
                    obj.position = [dist dist -dist];
                case 4
                    obj.position = [-dist dist -dist];
                case 5
                    obj.position = [-dist -dist dist];
                case 6
                    obj.position = [dist -dist dist];
                case 7
                    obj.position = [dist -dist -dist];
                case 8
                    obj.position = [-dist -dist -dist];                    
            end

            obj.up = [0 1 0];
            obj.target = [0 0 0];
            obj.computeView(obj.smooth);
        end  

        function faceView(obj,dist)
            if nargin==1
                dist=10;
            elseif nargin==2
                dist=abs(dist);
            end
            obj.position = [0 0 dist];
            obj.up = [0 1 0];
            obj.target = [0 0 0];

            obj.computeView(obj.smooth);
        end   

        function rearView(obj,dist)
            if nargin==1
                dist=10;
            elseif nargin==2
                dist=abs(dist);
            end
            obj.position = [0 0 -dist];
            obj.up = [0 -1 0];
            obj.target = [0 0 0];
            obj.computeView(obj.smooth);
        end     

        function backView(obj,dist)
            if nargin==1
                dist=10;
            elseif nargin==2
                dist=abs(dist);
            end
            obj.position = [0 0 -dist];
            obj.up = [0 1 0];
            obj.target = [0 0 0];
            obj.computeView(obj.smooth);
        end           

        function upView(obj,dist)
            if nargin==1
                dist=10;
            elseif nargin==2
                dist=abs(dist);
            end
            obj.position = [0 dist 0];
            obj.up = [0 0 -1];
            obj.target = [0 0 0];
            obj.computeView(obj.smooth);
        end

        function downView(obj,dist)
            if nargin==1
                dist=10;
            elseif nargin==2
                dist=abs(dist);
            end
            obj.position = [0 -dist 0];
            obj.up = [0 0 1];
            obj.target = [0 0 0];
            obj.computeView(obj.smooth);
        end

        function leftView(obj,dist)
            if nargin==1
                dist=10;
            elseif nargin==2
                dist=abs(dist);
            end
            obj.position = [-dist 0 0];
            obj.up = [0 1 0];
            obj.target = [0 0 0];
            obj.computeView(obj.smooth);
        end

        function rightView(obj,dist)
            if nargin==1
                dist=10;
            elseif nargin==2
                dist=abs(dist);
            end
            obj.position = [dist 0 0];
            obj.up = [0 1 0];
            obj.target = [0 0 0];
            obj.computeView(obj.smooth);
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
    end 

    methods (Access = private)

        % Compute viewMatrix with/without interpolation
        function computeView(obj,N)
            % N : number of interpolated views between current and new one

            if nargin==1
                N=1;
            elseif nargin==2
            else
                return;
            end

            forward = -obj.getDirection;            
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

            T1 = Mrot * Mtrans;
            T0=obj.viewMatrix;
            M=obj.transformInterp(N,T0,T1);
                for i=1:size(M,3)
                    obj.viewMatrix=M(:,:,i);
                    notify(obj, 'evt_updateUbo');
                end

            % obj.viewMatrix=T1;
            % notify(obj, 'evt_updateUbo');

        end % fin de computeView

        %Compute projection matrix : orthographic (0) or perspective (1)
        function computeProj(obj)
            if obj.type == 0 % vue ortho
                distance = norm(obj.getDirection);
                obj.projMatrix = MProj3D('O', [distance * obj.ratio, distance, -obj.far, obj.far]);
            else % vue en perspective
                obj.projMatrix = MProj3D('P', [obj.ratio, obj.fov, obj.near, obj.far]);
            end
        end % fin de computeProj

        % Matrix interpolation for smooth moving
        function mat = transformInterp(obj,N,T0,T1)
            % compute interpolated matrix between T0 and T1, N steps
            % Only rotation and translation
            % mat : 4x4xN matrices
            
            q0=tform2quat(T0);
            q1=tform2quat(T1);      
            theta=acos(dot(q0,q1));
            if theta==0 || N==1
                mat=T1;
                return;
            end

            s=[0:1/(double(N)-1):1];
            t0=T0([13:15]);
            t1=T1([13:15]);

            mat=zeros(4,4,N);            
            for i=1:N
                new_t=(1-s(i))*t0+s(i)*t1;
                new_q=(sin((1-s(i))*theta)*q0+sin(s(i)*theta)*q1)/sin(theta);
                R=quat2rotm(new_q);
                mat(:,:,i)=eye(4);
                mat(1:3,1:3,i)=R;
                mat([13:15]+16*(double(i)-1))=new_t;
            end

        end

    end % fin des methodes privées

end %fin classe Camera