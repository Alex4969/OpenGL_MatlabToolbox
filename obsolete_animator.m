classdef animator < handle 
    % camera animator

    properties%(SetAccess=protected,GetAccess=protected)
        t timer
        camera Camera    
        startPoint (1,2) double 
        endPoint (1,2) double 
        Enable logical
        speed
        acceleration
        elapsedTime (1,1) double 
        startAnimation (1,1) uint64
        duration (1,1) double
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
            obj.duration=2;

            % obj.t.start;
        end


        function setBegin(obj,P)
            if obj.Enable==false
                return;
            end
            disp('BEGIN')
            obj.t.stop;
            
            obj.startPoint=P; 
            obj.elapsedTime=tic;
            % obj
        end

        function setCurrent(obj,P)
            if obj.Enable==false
                return;
            end

            dt=toc(uint64(obj.elapsedTime));            
            obj.acceleration=norm(P-obj.startPoint)/(dt^2);
            a=obj.acceleration;
            obj.startPoint=P;
            obj.elapsedTime=tic;
            
            % obj
        end        

        function setEnd(obj,P)
            if obj.Enable==false
                return;
            end
            % disp('END')

            dt=toc(uint64(obj.elapsedTime)); 
            
            obj.endPoint=P;            
            obj.acceleration=norm(obj.endPoint-obj.startPoint)/(dt^2);
            
            % aaa=obj.acceleration
            if obj.acceleration>1000
                
                obj.t.start;
            else
                obj.t.stop;
            end
            % obj
        end

        function vector=getMovingVector(obj)
            vector=obj.endPoint-obj.startPoint;
        end

        function delete(obj)
            obj.t.delete();
        end

    end

    % Callback
    methods(Access=protected)
        function cbk_startTimer(obj,source,event)
            % disp('timer started')
            % tic
            % depl=obj.getMovingVector();
            % dx=depl(1);dy=depl(2);
            % obj.rotationSpeed=norm(depl)/
            % obj
            obj.startAnimation=tic;
        end

        function cbk_animate(obj,source,event)
            % disp('ANIMATE')
            depl=obj.getMovingVector();
            crtTime=toc(obj.startAnimation);
            
            a=min(10,obj.acceleration);
            depl=a*depl;
            if obj.duration~=Inf
                % f=(-1/obj.duration*crtTime+1); %linear
                % f=exp(-4/obj.duration*crtTime); %exp
                f=exp(log(0.01)/obj.duration*crtTime); %exp time controlled
                % a=min(10,obj.acceleration);
                depl=depl*max(f,0);%*a*depl;
            end
            

            % norm(depl)
            if norm(depl)>=0.1 && crtTime<=obj.duration %&& obj.acceleration>=500
            % if obj.acceleration>=10 && crtTime<=obj.duration
                dx=depl(1);dy=depl(2);
                obj.camera.rotate(dx/obj.camera.Width,dy/obj.camera.Height,obj.camera.target);
            else
                disp('STOPPPPP')
                obj.t.stop;

            end
        end

        function cbk_stopTimer(obj,source,event)
            disp('timer stopped')
            
            toc(obj.startAnimation)
        end


    end
end
