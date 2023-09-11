classdef Camera < matlab.mixin.Copyable
    %CAMERA Gestion d'une caméra pour la scène 3D
    % Author : Alexandre Biaud
    % Modif : Philippe Duvauchelle
    % Date : august 2023

    properties (Constant)
        SPEED_MIN=1   %min camera speed
        SPEED_MAX=10000 %max camera speed
        SENSIBILITY_MIN=0.01   %min camera sensibility
        SENSIBILITY_MAX=1   %min camera sensibility
        DEFAULT_DISTANCE=500
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
        % ratio       (1,1) double   % ration d'observation (width/height)
        fov         (1,1) double   % angle de vue d'observation (en degré) mieux entre 50 & 80
        type        (1,1) logical  % 1 pour perspective, 0 pour orthonormé
        projMatrix  (4,4) double   % matrice de projection correspondant aux valeurs ci dessus

        %%% Attributs pour le mouvement
        speed       (1,1) double = 5;
        sensibility (1,1) double = 1;
        
        constraint  (1,3) logical  % pour chaque axe
        counter_view=1 % value of pre-defined view

        Width (1,1) double
        Height (1,1) double

    end

    properties (SetAccess=public)
        smooth      (1,1) uint32 = 12; % For interpolated moving : step number
    end

    events
        evt_updateUbo       % mise a jour du Ubo de scene 3D necessaire
    end

    methods
        %CAMERA Constructor
        function obj = Camera(width_,height_)
        
            obj.position = [0 0 obj.DEFAULT_DISTANCE];
            obj.target = [0 0 0];
            % obj.targetDir = obj.target - obj.position;
            obj.up = [0 1 0];
            obj.computeView();

            obj.near = 0.01;
            obj.far = 10000;
            obj.Width = width_;
            obj.Height = height_;
            obj.fov = 60;
            obj.type = 1;
            obj.computeProj();
            obj.constraint = [true true true]; %XYZ : authorized axis

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

        %Perspective (1) or orthographic (0)
        function switchProjType(obj,state)
            if nargin==1
                obj.type = bitxor(obj.type, 1);
            else
                obj.type=state;
            end
            obj.computeProj();
        end % fin de switchProjType

        % Camera near and far planes
        function setNearFar(obj, newNear, newFar)
            obj.near = newNear;
            obj.far  = newFar;
            obj.computeProj();
        end % fin de setNearFar

        % Ratio Width/Height
        function newRatio=getRatio(obj)
            newRatio=obj.Width/obj.Height;
        end % fin de getRatio

        % Size Width , Height
        function setSize(obj, w,h)
            obj.Width = w;
            obj.Height = h;

            obj.computeProj();
        end % fin de setSize    

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
            maxX = maxY * obj.getRatio;
            att.maxX  = maxX;
            att.maxY = maxY;
            att.view = obj.viewMatrix;
            att.proj = obj.projMatrix;
            att.ratio = obj.getRatio;
            att.pos = obj.position;
            att.direction=obj.getDirection();
        end
        % fin de getAttribute
    
        % Speed of camera
        function changeSpeed(obj,increment)
            if increment>0
                obj.speed=min(obj.SPEED_MAX,obj.speed+increment);
            else
                obj.speed=max(obj.SPEED_MIN,obj.speed+increment);
            end
            obj.speed
        end

        function setSpeed(obj,newSpeed)
            obj.speed=newSpeed;
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

    end
    %fin des methodes defauts

    methods % Mouse moving methods
        
        function translate(obj,dx,dy)
            % if any(obj.constraint) % si une contrainte axial est présente : 
            %     dz = 0;
            %     if obj.constraint(3)
            %         if obj.constraint(2)
            %             dz = dx;
            %         else
            %             dz = -dy;
            %         end
            %     end
            %     translation =  [dx, dy, dz] .* obj.constraint;
            % else % si aucune constrainte on se met dans le plan de la caméra parallele au plan Oxy
                % translation = dy * obj.up;
                
                u_right = cross(obj.getDirection, obj.up);
                u_right = u_right/norm(u_right);
                v_up=cross(u_right,obj.getDirection);
                v_up=v_up/norm(v_up);
                translation = (-dx * u_right+dy*v_up).*obj.constraint;
            % end
            obj.position = obj.position + translation * obj.speed;
            obj.target = obj.target + translation * obj.speed;
            obj.computeView();
        end % fin de translate

        function obsolete_translatePlanAct(obj,dx,dy)
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
        function zoom(obj,signe)
            %ZOOM se deplace dans la direction de la target
            % % % dist = vecnorm(obj.position);
            % % % dist = sqrt(dist); % plus on est pres, plus on est precis,
            % % % dist = ceil(dist); % fonctionne par palier grace au ceil
            % % % facteur = signe * dist *0.3; % obj.speed; 

            % disp('ZOOM')

            dist=norm(obj.position-obj.target);
            % Linear function : percentage of the remaining distance
            facteur = signe * 0.1*dist; 

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

            newUp = cross(left,forward);
            newUp = newUp / norm(newUp);        

            obj.up=sind(theta)*left+cosd(theta)*newUp;

            obj.computeView();
            
        end

        % Rotation around camera axis depending on mouse move
        % rotation is more sensible when clicked point is far from the
        % figure's center
        function selfRotate(obj,posX,posY,dx,dy)
            P=[posX posY 0];
            R=norm(P);
            u=[dx dy 0];
            sens=sign(cross(P,u));
            theta=sens(3)*R*5;%*obj.speed;
            obj.rotationAroundAxis(theta);
        end

        % Rotatin due to (dx,dy) mouse move
        function rotate(obj, dx, dy,centre)

            % target=obj.target;
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

        function setviewMatrix(obj,M)
            obj.viewMatrix=M;
        end
    end %% end methods for mouse moving

    %specific view
    methods
        
        %user/storage view
        function userView(obj,camParam)
            %camParam : can be obtained with getParametersView function
            % obj.position = camParam.position;
            % obj.up = camParam.up;
            % obj.target = camParam.target;
            % obj.computeView(obj.smooth);

            obj.anim(camParam.position,camParam.up,camParam.target,obj.smooth);
        end 

        function camParam=getCurrentView(obj)
            camParam.position=obj.position;
            camParam.up=obj.up;
            camParam.target=obj.target;
            camParam.viewMatrix=obj.viewMatrix;
        end       

        function setCamParameters(obj,camParam)
            obj.position=camParam.position;
            obj.up=camParam.up;
            obj.target=camParam.target;
            obj.viewMatrix=camParam.viewMatrix;
        end

        %Default views
        function numView=nextDefaultView(obj,dist)
            if nargin==1
                dist=obj.DEFAULT_DISTANCE;
            end
                
            obj.counter_view=obj.counter_view+1;
            if obj.counter_view>8
                obj.counter_view=1;
            end
            obj.defaultView(obj.counter_view,dist);
            numView=obj.counter_view;
        end

        function defaultView(obj,cadran,dist)
            if nargin==1
                cadran=2;
                dist=obj.DEFAULT_DISTANCE;
            elseif nargin==2
                dist=obj.DEFAULT_DISTANCE;
            elseif nargin==3
                dist=abs(dist);
            end
            
            switch cadran
                case 1
                    position = [-dist dist dist];
                case 2
                    position = [dist dist dist];
                case 3
                    position = [dist dist -dist];
                case 4
                    position = [-dist dist -dist];
                case 5
                    position = [-dist -dist dist];
                case 6
                    position = [dist -dist dist];
                case 7
                    position = [dist -dist -dist];
                case 8
                    position = [-dist -dist -dist];                    
            end

            % obj.up = [0 1 0];
            % obj.target = [0 0 0];
            % obj.computeView(obj.smooth);
            obj.anim(position,[0 1 0],[0 0 0],obj.smooth);
        end  

        %others view
        function faceView(obj,dist)
            if nargin==1
                dist=obj.DEFAULT_DISTANCE;
            elseif nargin==2
                dist=abs(dist);
            end

            obj.anim([0 0 dist],[0 1 0],[0 0 0],obj.smooth);

        end   

        function rearView(obj,dist)
            if nargin==1
                dist=obj.DEFAULT_DISTANCE;
            elseif nargin==2
                dist=abs(dist);
            end

            obj.anim([0 0 -dist],[0 -1 0],[0 0 0],obj.smooth);
        end     

        function backView(obj,dist)
            if nargin==1
                dist=obj.DEFAULT_DISTANCE;
            elseif nargin==2
                dist=abs(dist);
            end
            % obj.position = [0 0 -dist];
            % obj.up = [0 1 0];
            % obj.target = [0 0 0];
            % obj.computeView(obj.smooth);
            obj.anim([0 0 -dist],[0 1 0],[0 0 0],obj.smooth);
        end           

        function upView(obj,dist)
            if nargin==1
                dist=obj.DEFAULT_DISTANCE;
            elseif nargin==2
                dist=abs(dist);
            end
            % obj.position = [0 dist 0];
            % obj.up = [0 0 -1];
            % obj.target = [0 0 0];
            % obj.computeView(obj.smooth);
            obj.anim([0 dist 0],[0 0 -1],[0 0 0],obj.smooth);
        end

        function downView(obj,dist)
            if nargin==1
                dist=obj.DEFAULT_DISTANCE;
            elseif nargin==2
                dist=abs(dist);
            end
            % obj.position = [0 -dist 0];
            % obj.up = [0 0 1];
            % obj.target = [0 0 0];
            % obj.computeView(obj.smooth);
            obj.anim([0 -dist 0],[0 0 1],[0 0 0],obj.smooth);
        end

        function leftView(obj,dist)
            if nargin==1
                dist=obj.DEFAULT_DISTANCE;
            elseif nargin==2
                dist=abs(dist);
            end
            % obj.position = [-dist 0 0];
            % obj.up = [0 1 0];
            % obj.target = [0 0 0];
            % obj.computeView(obj.smooth);
            obj.anim([-dist 0 0],[0 1 0],[0 0 0],obj.smooth);
        end

        function rightView(obj,dist)
            if nargin==1
                dist=obj.DEFAULT_DISTANCE;
            elseif nargin==2
                dist=abs(dist);
            end
            % obj.position = [dist 0 0];
            % obj.up = [0 1 0];
            % obj.target = [0 0 0];
            % obj.computeView(obj.smooth);
            obj.anim([dist 0 0],[0 1 0],[0 0 0],obj.smooth);
        end        

        % A supprimer si inutile
        function xorConstraint(obj, l)
            obj.constraint = bitxor(obj.constraint, l);
            if all(obj.constraint)
                obj.constraint = l;
            end
        end

        function setAuthorizedAxis(obj, xyz)
            obj.constraint=xyz;
        end

        % A modifier
        function resetConstraint(obj)
            obj.constraint = [false false false];
        end
    

    end 

    methods (Access = protected)

        function computeView(obj)

            % target = reference
            forward = -obj.getDirection; %target -> position      
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
            obj.viewMatrix=T1;
            notify(obj, 'evt_updateUbo');

            % % % % T1(15)=-T1(15);
            % % % % T1
            % % % T0 = obj.viewMatrix;
            % % % sameMatrix=sum(abs(T1(:)-T0(:)))<1e-6;
            % % % if ~sameMatrix && N==1
            % % %     obj.viewMatrix=T1;
            % % %     notify(obj, 'evt_updateUbo');
            % % % elseif ~sameMatrix && N>1
            % % %     M=obj.transformInterp(N,T0,T1);
            % % %     for i=1:size(M,3)
            % % %         obj.position=-M(1:3,4,i); %position
            % % %         position=M(1:3,4,i)
            % % %         % left=M(1,1:3,i);
            % % %         % up=M(2,1:3,i)
            % % %         % forward=M(3,1:3,i) % !!! normalized
            % % %         % target=obj.position-forward
            % % %         obj.up=M(2,1:3,i);
            % % %         obj.viewMatrix=M(:,:,i);
            % % %         notify(obj, 'evt_updateUbo');
            % % %     end
            % % % % else
            % % % %     disp('Same Matrix')
            % end

            % obj.viewMatrix=T1;
            % notify(obj, 'evt_updateUbo');

        end % fin de computeView

        % Compute viewMatrix with/without interpolation
        function computeView_OK(obj,N)
            % N : number of interpolated views between current and new one

            if nargin==1
                N=1;
            elseif nargin==2
            else
                return;
            end

            forward = -obj.getDirection; %target -> position      
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
            % T1(15)=-T1(15);
            % T1
            T0 = obj.viewMatrix;
            sameMatrix=sum(abs(T1(:)-T0(:)))<1e-6;
            if ~sameMatrix && N==1
                obj.viewMatrix=T1;
                notify(obj, 'evt_updateUbo');
            elseif ~sameMatrix && N>1
                M=obj.transformInterp(N,T0,T1);
                for i=1:size(M,3)
                    obj.position=-M(1:3,4,i); %position
                    position=M(1:3,4,i)
                    % left=M(1,1:3,i);
                    % up=M(2,1:3,i)
                    % forward=M(3,1:3,i) % !!! normalized
                    % target=obj.position-forward
                    obj.up=M(2,1:3,i);
                    obj.viewMatrix=M(:,:,i);
                    notify(obj, 'evt_updateUbo');
                end
            % else
            %     disp('Same Matrix')
            end

            % obj.viewMatrix=T1;
            % notify(obj, 'evt_updateUbo');

        end % fin de computeView

        %Compute projection matrix : orthographic (0) or perspective (1)
        function computeProj(obj)
            if obj.type == 0 % vue ortho
                distance = norm(obj.getDirection);
                obj.projMatrix = MProj3D('O', [distance * obj.getRatio, distance, -obj.far, obj.far]);
            else % vue en perspective
                obj.projMatrix = MProj3D('P', [obj.getRatio, obj.fov, obj.near, obj.far]);
            end
            notify(obj, 'evt_updateUbo');
        end % fin de computeProj

    end

    methods (Access=public)
        % Matrix interpolation for smooth moving
        function [mat,pos,target] = transformInterp(obj,N,T0,T1)
            % compute interpolated matrix between T0 and T1, N steps
            % Only rotation and translation
            % mat : 4x4xN matrices
            % https://robotacademy.net.au/lesson/interpolating-pose-in-3d/
            % https://en.wikipedia.org/wiki/Slerp
            
            % s=0:1/(double(N)-1):1;
            s=1/double(N):1/double(N):1;
            
            q0=tform2quat(T0);
            q1=tform2quat(T1);      
            theta=acos(dot(q0,q1));
            % if theta==0 || N==1
            %     mat=T1;
            %     return;
            % end

            % s=[0:1/(double(N)-1):1];
            t0=T0(13:15);
            t1=T1(13:15);

            mat=zeros(4,4,N);
            pos=zeros(N,3);
            target=zeros(N,3);
            if theta==0
                R=zeros(3,3);
                R=T1(1:3,1:3);
                for i=1:N        
                    new_t=(1-s(i))*t0+s(i)*t1;
                    mat(:,:,i)=eye(4);
                    mat(1:3,1:3,i)=R;
                    mat((13:15)+16*(double(i)-1))=new_t;
                    pos(i,:)=-mat(1:3,1:3,i)'*mat(1:3,4,i);
                end                
            else
                for i=1:N
                    new_t=(1-s(i))*t0+s(i)*t1;
                    new_q=(sin((1-s(i))*theta)*q0+sin(s(i)*theta)*q1)/sin(theta);
                    R=quat2rotm(new_q);
                    mat(:,:,i)=eye(4);
                    mat(1:3,1:3,i)=R;
                    mat((13:15)+16*(double(i)-1))=new_t;
                    pos(i,:)=-mat(1:3,1:3,i)'*mat(1:3,4,i);
                    target(i,:)=pos(i,:)-norm(pos(i,:))*mat(3,1:3,i);
                end                
            end

            % mat=zeros(4,4,N);            
            % for i=1:N
            %     new_t=(1-s(i))*t0+s(i)*t1;
            %     new_q=(sin((1-s(i))*theta)*q0+sin(s(i)*theta)*q1)/sin(theta);
            %     R=quat2rotm(new_q);
            %     mat(:,:,i)=eye(4);
            %     mat(1:3,1:3,i)=R;
            %     mat([13:15]+16*(double(i)-1))=new_t;
            % end

        end
    
        function allPos=anim(obj,finalPos,finalUp,finalTarget,N)

            if nargin<=2
                finalUp=obj.up;
                finalTarget=obj.target;
                N=obj.smooth;
            elseif nargin<=3
                finalTarget=obj.target;
                N=obj.smooth;                
            elseif nargin<=4
                N=obj.smooth;
            end

            %compute final pos
            forward = (finalPos-finalTarget); %target -> position      
            forward = forward / norm(forward);

            left = cross(finalUp, forward);
            if isequal(left,[0 0 0])
                warning('Animation impossible: verify parameters')
                return;
            end
            left = left / norm(left);
            newUp = cross(forward, left);

            Mrot = eye(4);
            Mrot(1,1:3) = left;
            Mrot(2,1:3) = newUp;
            Mrot(3,1:3) = forward;

            Mtrans = eye(4);
            Mtrans(1:3,4) = -finalPos';

            T1 = Mrot * Mtrans;
            T0 = obj.viewMatrix;

            sameMatrix=sum(abs(T1(:)-T0(:)))<1e-6;
            if ~sameMatrix            
                [M,allPos,allTarget]=obj.transformInterp(N,T0,T1);
                % allPos=zeros(size(M,3),3);
                for i=1:size(M,3)
                    % disp('animation')
                    obj.position=allPos(i,:);
                    % left=M(1,1:3,i);
                    % up=M(2,1:3,i)
                    % forward=M(3,1:3,i) % !!! normalized
                    obj.up=M(2,1:3,i);
                    obj.target=allTarget(i,:);
                    obj.viewMatrix=M(:,:,i);
                    notify(obj, 'evt_updateUbo');
                end        
            end

        end

        function mat = obsolete_transformInterp(obj,N,T0,T1)
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

    end 

end %fin classe Camera