classdef animator < handle 
    % camera animator

    properties%(SetAccess=protected,GetAccess=protected)
        t timer
        camera Camera
        Enable logical

        beginPoint (1,2) double 
        currentPoint (1,2) double
        endPoint (1,2) double 

        currentVector
        nbAppel

        impulse

        beginTime
        acceleration
        rotAxis
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

        end


        function setBegin(obj,P)
            if obj.Enable==false
                return;
            end
            disp('BEGIN')
            
            obj.t.stop;
            
            obj.beginPoint=P; 
            obj.currentPoint=P;
            obj.beginTime=tic;
            % obj
        end

        function setCurrent(obj,P)
            if obj.Enable==false
                return;
            end

            dt=toc;

            obj.currentVector=P-obj.currentPoint;
            obj.acceleration=norm(obj.currentVector)/(dt^2);
            % scatter(toc(uint64(obj.beginTime)),obj.acceleration)
            % a=obj.acceleration;
            obj.currentPoint=P;
            tic;
            
            % obj
        end        

        function setEnd(obj,P)
            if obj.Enable==false
                return;
            end
            disp('END')
            

            

            % % % obj.impulse=P-obj.currentPoint;
            % % % 
            % % % % obj.anim(d_uv);
            % % % 
            % % % if obj.acceleration>2000
            % % %     obj.t.start;
            % % % end
            % v=v/norm(v)



            % dt=toc(uint64(obj.elapsedTime)); 
            % 
            % obj.endPoint=P;            
            % obj.acceleration=norm(obj.endPoint-obj.startPoint)/(dt^2);
            % 
            % % aaa=obj.acceleration
            % if obj.acceleration>1000
            % 
            %     obj.t.start;
            % else
            %     obj.t.stop;
            % end
            % % obj
        end

        function vector=getMovingVector(obj)
            vector=obj.endPoint-obj.startPoint;
        end

        function delete(obj)
            obj.t.delete();
        end

    end

    % interpolations
    methods
        function anim(obj,d_uv)
            [u_xyz,v_xyz]=obj.getRotationAxis();


            transl=d_uv(1)*[1 0]+d_uv(2)*[0 1];
            transl=transl/norm(transl);

            axis=[-transl(2) transl(1)];
            axis=axis/norm(axis);

            rotAxis=axis(1)*u_xyz+axis(2)*v_xyz;
            norm(rotAxis);

            Mtrans = eye(4);
            Mtrans(1:3,4) = -obj.camera.position';

            for i=1:10
                disp('anim')
                % T1 = MRot3DbyAxe(i*6,rotAxis) * Mtrans;
                % position=-T1(1:3,1:3)'*obj.camera.position'
                % obj.camera.setviewMatrix(T1);
                % notify(obj.camera, 'evt_updateUbo');
                % obj.camera.setPosition(position)

                d_uv=[100 0];
                obj.camera.rotate( d_uv(1)/obj.camera.Width , d_uv(2)/obj.camera.Height ,obj.camera.target)
                d_uv(1)/obj.camera.Width
                d_uv(2)/obj.camera.Height
                % notify(obj.camera, 'evt_updateUbo');

            end
        end

    end

    % Callback
    methods(Access=protected)
        function cbk_startTimer(obj,source,event)


            [u_xyz,v_xyz]=obj.getRotationAxis();

            transl=obj.currentVector;
            % transl=d_uv(1)*[1 0]+d_uv(2)*[0 1];
            transl=transl/norm(transl);

            axis=[-transl(2) transl(1)];
            % axis=axis/norm(axis);

            obj.rotAxis=axis(1)*u_xyz+axis(2)*v_xyz;
            % norm(rotAxis);

            obj.nbAppel=0;

                % T1 = MRot3DbyAxe(i*6,rotAxis) * Mtrans;
                % position=-T1(1:3,1:3)'*obj.camera.position'
                % obj.camera.setviewMatrix(T1);
                % notify(obj.camera, 'evt_updateUbo');
                % obj.camera.setPosition(position)
                figure(1)
                clf;
                hold on

        end

        function cbk_animate(obj,source,event)
            % disp('animate')
                % d_uv=[150 -10];

                % fonction a peu pres
                % % % d_uv(1)=obj.impulse(1);
                % % % d_uv(2)=obj.impulse(2);
                % % % d_uv=d_uv*obj.acceleration/1000;
                % % % obj.camera.rotate( d_uv(1)/obj.camera.Width , d_uv(2)/obj.camera.Height ,obj.camera.target)

                % % % obj.impulse=P-obj.currentPoint;

            % obj.anim(d_uv);
            
            % if obj.acceleration>2000
            %     obj.t.start;
            % end

            Mtrans = eye(4);
            Mtrans(1:3,4) = -obj.camera.position';
            if obj.nbAppel==0
                Mtrans(1:3,4)=-[0 0 500]';
            end
            %******************
            obj.nbAppel=obj.nbAppel+1;
            step=1*obj.acceleration/1000;
            r=obj.rotAxis
            T1 = MRot3DbyAxe(step,obj.rotAxis) * Mtrans;
                position=T1(1:3,1:3)'*obj.camera.position'
                % obj.camera.setviewMatrix(T1);
                % notify(obj.camera, 'evt_updateUbo');
                scatter3(position(1),position(2),position(3))
                obj.camera.setPosition(position);

        end

        function cbk_stopTimer(obj,source,event)

        end

        function [u_axis,v_axis]=getRotationAxis(obj)
                u_right = cross(obj.camera.getDirection, obj.camera.up);
                u_right = u_right/norm(u_right);
                v_up=cross(u_right,obj.camera.getDirection);
                v_up=v_up/norm(v_up);
                u_axis=u_right;
                v_axis=v_up;
                % vectN=+v_up-u_right; %perpendicular to vect
                % axis=vectN/norm(vectN)
                % % axis = +v_up-u_right;
        end


    end
end
