classdef textTimer < handle 
    % SetText in java Component for a givent time

    properties%(SetAccess=protected,GetAccess=protected)
        t timer
        target_component
        text string
        % duration double
    end

    methods
        % Constructor
        function obj = textTimer(target_component)
            % if nargin==1
            %     duration=2;
            % end

            obj.t=timer();
            obj.t.ExecutionMode="singleShot";
            obj.t.StartDelay=2;
            obj.t.TimerFcn='nan;';
            obj.t.StartFcn=@(src,evt)obj.cbk_startTimer(src,evt);
            obj.t.StopFcn=@(src,evt)obj.cbk_stopTimer(src,evt);

            obj.target_component=target_component;
            obj.text="";
            % obj.duration=duration;

            % obj.t.start;
        end

        function setText(obj,newText,duration)
            obj.text=newText;
            if obj.t.Running
                    obj.t.stop;
            end
            if nargin==2 %duration infinity
                obj.cbk_startTimer();
            elseif nargin==3
                obj.t.StartDelay=duration;
                obj.t.start;             
            end        
            
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
            obj.target_component.setText(obj.text);
        end

        function cbk_stopTimer(obj,source,event)
            % disp('timer stopped')
            obj.target_component.setText('');
            % toc
        end


    end
end
