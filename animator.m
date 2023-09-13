classdef animator < handle 
    % camera animator

    properties%(SetAccess=protected,GetAccess=protected)
        t timer
    end

    properties(SetAccess=protected,GetAccess=public)
        acceleration
        Enable logical
    end

    properties(SetAccess=protected,GetAccess=protected)
        camera Camera
        
        currentPoint (1,2) double   % in screen space
        currentVector (1,2) double  % in screen space

        currentRotationMatrix (4,4) double
    end

    methods
        % Constructor
        function obj = animator(camera_)
            % if nargin==1
            %     duration=2;
            % end

            obj.t=timer();
            obj.t.ExecutionMode="fixedSpacing"; %'fixedDelay', 'fixedRate', and 'fixedSpacing'
            obj.t.StartDelay=0;
            obj.t.Period=0.02;
            obj.t.TimerFcn=@(src,evt)obj.cbk_animate(src,evt);
            obj.t.StartFcn=@(src,evt)obj.cbk_startTimer(src,evt);
            obj.t.StopFcn=@(src,evt)obj.cbk_stopTimer(src,evt);

            obj.camera=camera_;
            obj.Enable=false;

        end

        function state=isRunning(obj)
            if strcmpi(obj.t.Running,'off')
                state=false;
            else
                state=true;
            end
        end

        function setEnable(obj,state)
            if state
                obj.Enable=true;
            else
                obj.Enable=false;
                obj.t.stop;
            end
        end        

        function setBegin(obj,P)
            % Begin dynamic animation
            disp('BEGIN')
            
            if obj.Enable==false
                return;
            end
                      
            obj.t.stop;
            obj.acceleration=0;
            obj.currentPoint=P;
            tic; %beginning the drag
        end

        function setCurrent(obj,P)
            if obj.Enable==false
                return;
            end

            dt=toc;
            obj.currentVector=(P-obj.currentPoint).*[1 -1];
            obj.acceleration=norm(obj.currentVector)/(dt^2);

            obj.currentPoint=P;
            tic;
            
            % obj
        end        

        function setEnd(obj,P)
            disp('END')
            if obj.Enable==false
                return;
            end            
            
            dt=toc;
            obj.currentVector=(P-obj.currentPoint).*[1 -1];
            obj.acceleration=norm(obj.currentVector)/(dt^2);
            
        end

        function delete(obj)
            obj.t.delete();
        end

    end

    % interpolations
    methods
        function animate(obj,posList)
            %animat the camera from a list of generated position
            %postList : Nx3 list camera position

            figure(1)
            clf(1)
            hold on

            N=numel(posList)/3;
            dir=obj.camera.getDirection();
            for i=1:N
                disp('anim')
                position=posList(i,:);
                    %debug
                    scatter3(position(1),position(2),position(3))
                cam.position=position;
                % obj.camera.setDirection(dir,"target");
                cam.target=position.*[0 1 0];
                cam.up=obj.camera.up;
                cam.viewMatrix=obj.camera.viewMatrix;
                % obj.camera.setCamParameters(cam);
                obj.camera.move(cam.position,cam.up,cam.target,1);
            end

        end

        function posList=genTranslationMove(obj,origin,vecTrans,N)
            posList=zeros(N,3);
            T=MTrans3D(vecTrans);
            posList(1,:)=origin;
            for i=2:N
                newPos=T*[posList(i-1,:) 1]';
                posList(i,:)=newPos(1:3)';
            end
        end

        function posList=genHelicoidalMove(obj,origin,vecTrans,angle,N)
            posList=zeros(N,3);
            Tr=MTrans3D(vecTrans);
            R=MRot3D(angle);
            T=Tr*R;
            posList(1,:)=origin;
            for i=2:N
                newPos=T*[posList(i-1,:) 1]';
                posList(i,:)=newPos(1:3)';
            end
        end        


    end

    % Callback
    methods(Access=protected)
        function cbk_startTimer(obj,source,event)
            accelCoef=25000;

            disp('start timer')

            [u_xyz,v_xyz]=obj.get3DRotationAxis();

            % Mouse translation vector
            transl=obj.currentVector;
            transl=transl/norm(transl);

            axis=[-transl(2) transl(1)]; %normal to transl

            % 3D rotation axis
            rotAxis=(axis(1)*u_xyz+axis(2)*v_xyz);
            rotSign=sign(dot(obj.camera.up,rotAxis));
            rotAxis=rotSign*rotAxis;

            obj.camera.setUp(rotAxis);

            rotationStep=rotSign*obj.acceleration/accelCoef;

            obj.currentRotationMatrix = MRot3DbyAxe(rotationStep,-rotAxis); % minus come from the camera is moving, not the object (need to invert)

            %debug
            % figure(1)
            % clf;
            % hold on

        end

        function cbk_animate(obj,source,event)
            % disp('animate timer')

            position=obj.currentRotationMatrix*[obj.camera.position 1]';
            position=position(1:3)';

            obj.camera.setPosition(position);

            %debug
            % scatter3(position(1),position(2),position(3))

        end

        function cbk_stopTimer(obj,source,event)
            disp('stop timer')
        end

        function [u_axis,v_axis]=get3DRotationAxis(obj)
            % u_axis,v_axis : u,v vector define camera's plane in absolute coordinate system

            u_right = cross(obj.camera.getDirection, obj.camera.up);
            u_right = u_right/norm(u_right);
            v_up=cross(u_right,obj.camera.getDirection);
            v_up=v_up/norm(v_up);
            u_axis=u_right;
            v_axis=v_up;
        end


    end
end
