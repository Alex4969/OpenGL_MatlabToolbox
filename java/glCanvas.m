classdef glCanvas < javacallbackmanager
    % Abstract class for creating OpenGL component
    % Set this class as a superclass for your opengl render class
    % Define those methods in your class:
    % InitFcn(obj,d,gl,varargin)
    % UpdateFcn(obj,d,gl)
    % ResizeFcn(obj,d,gl)
    
    properties
%         parent % jFrame
        javaObj % com.jogamp.opengl.awt.GLCanvas
%         glStop logical = 0;
        % % autoCheckError logical = 1;
        % % updateNeeded logical = 0;
        % % resizeNeeded logical = 1;
        % % updating logical = 0;

    end
    
    properties(Access=public)%protected)
        context
        % glInitialized=0 %true when OGL is initialized
    end
    
events
    evt_MousePressed
    evt_MouseReleased
    evt_MouseClicked
    evt_MouseExited
    evt_MouseEntered
    evt_MouseMoved
    evt_MouseDragged
    evt_MouseWheelMoved
    evt_KeyTyped
    evt_KeyPressed
    evt_KeyReleased
    evt_ComponentResized
    evt_ComponentMoved
    evt_ComponentShown
    evt_ComponentHidden
end

    methods%(Sealed=true)

        function obj=glCanvas(profile,aaSample)
            
            % profile: GL2, GL3, GL4, GL2GL3, GL2ES1, GL2ES2, GL3bc, GL4bc, GL4ES3
            if nargin==0
                profile='GL4';%ES2;
                aaSample=0;
            elseif nargin==1
                aaSample=0;
            end
            
            % initialize canvas
            obj.initialize(profile,aaSample);

            %canvas callback
            obj.populateCallbacks(obj.javaObj);
              
            %obj.javaObj.ComponentResizedCallback = @(src,evt) obj.ComponentResized(src,evt);

            % Mouse/Keyboard Callback
            % % obj.setMethodCallback('MousePressed');
            % % obj.setMethodCallback('MouseReleased');
            % % obj.setMethodCallback('MouseClicked');
            % % obj.setMethodCallback('MouseExited');
            % % obj.setMethodCallback('MouseEntered');
            % % obj.setMethodCallback('MouseMoved');
            % % obj.setMethodCallback('MouseDragged');
            % % obj.setMethodCallback('MouseWheelMoved');
            % % 
            % % obj.setMethodCallback('KeyTyped');    
            % % obj.setMethodCallback('KeyPressed');
            % % obj.setMethodCallback('KeyReleased');
            % % 
            % % obj.setMethodCallback('ComponentResized');
            % % obj.setMethodCallback('ComponentMoved');
            % % obj.setMethodCallback('ComponentShown');
            % % obj.setMethodCallback('ComponentHidden');

        end


        function initialize(obj, profile, aaSample)

            % import
            import com.jogamp.opengl.*;

            glProfile = GLProfile.get(profile);
            glCapabilities = GLCapabilities(glProfile);

            if aaSample
	            glCapabilities.setSampleBuffers(true);
                glCapabilities.setNumSamples(aaSample);% anti aliasing
            end

            % GLCanvas
            obj.javaObj=com.jogamp.opengl.awt.GLCanvas(glCapabilities);
            % obj.context = obj.javaObj.getContext;

        end
    end
        

    % Mouse Callback
    methods
% % 
% %         function MousePressed(obj,source,event)
% %             disp('MousePressed')
% %             notify(obj,'evt_MousePressed');
% %         end
% % 
% %         function MouseReleased(obj,source,event)
% %             disp('MouseReleased')
% %             notify(obj,'evt_MouseReleased');
% %         end
% % 
% %         function MouseClicked(obj,source,event)
% %             disp('MouseClicked')
% %             notify(obj,'evt_MouseClicked');
% %         end
% % 
% %         function MouseExited(obj,source,event)
% %             disp('MouseExited')
% %             notify(obj,'evt_MouseExited');
% %         end
% % 
% %         function MouseEntered(obj,source,event)
% %             disp('MouseEntered')
% %             notify(obj,'evt_MouseEntered');
% %         end
% % 
% %         function MouseMoved(obj,source,event)
% %             disp('MouseMoved')
% %             notify(obj,'evt_MouseMoved');
% %         end
% % 
% %         function MouseDragged(obj,source,event)
% %             disp('MouseDragged')
% %             notify(obj,'evt_MouseDragged');
% %         end
% % 
% %         function MouseWheelMoved(obj,source,event)
% %             disp ('MouseWheelMoved')
% %             notify(obj,'evt_MouseWheelMoved');
% % %             obj.resizeNeeded = 1;
% % %             obj.Update;
% %         end
% %     end
% % 
% %     % Keyboard callback
% %     methods
% % 
% %         function KeyTyped(obj,source,event)
% %             disp('KeyTyped')
% %             notify(obj,'evt_KeyTyped');
% %         end 
% % 
% %         function KeyPressed(obj,source,event)
% %             disp(['KeyPressed : ' event.getKeyChar  '   ascii : ' num2str(event.getKeyCode)])
% %             notify(obj,'evt_KeyPressed');
% %         end
% % 
% %         function KeyReleased(obj,source,event)
% %             disp('KeyReleased')
% %             notify(obj,'evt_KeyReleased');
% %         end
% %     end
% % 
% %     % Component callback
% %     methods
% % 
% %         function ComponentResized(obj,source,event)          
% %             w=source.getSize.getWidth;
% %             h=source.getSize.getHeight;
% %             disp(['ComponentResized (' num2str(w) ' ; ' num2str(h) ')'])
% %             notify(obj,'evt_ComponentResized');
% %         end
% % 
% %         function ComponentMoved(obj,source,event)          
% %             disp('ComponentMoved')
% %             notify(obj,'evt_ComponentMoved');
% %         end
% % 
% %         function ComponentShown(obj,source,event)          
% %             disp('ComponentShown')
% %             notify(obj,'evt_ComponentShown');
% %         end
% % 
% %         function ComponentHidden(obj,source,event)          
% %             disp('ComponentHidden')
% %             notify(obj,'evt_ComponentHidden');
% %         end                
    end


    methods
        
        function delete(obj)
%            obj.glStop = 1;
            obj.rmCallback;
%             delete(obj.parent);
%             try
%                 glmu.State(1);
%             catch
%             end
            obj.releaseContext;
        end
        
    end

    methods(Static)
    %     function CheckError(gl)
    %         err = gl.glGetError();
    %         while err > 0
    %             warning(['GL Error 0x' dec2hex(err,4)])
    %             err = gl.glGetError();
    %         end
    %     end
    end
    
    % methods(Abstract)
    %     % d is the GLDrawable
    %     % gl is the GL object
    %     glInit(obj,d,gl);%,d,gl,varargin)
    %     glDisplay(obj,d,gl);
    %     glResize(obj,d,gl);
    %     glDispose(obj,d,gl);
    % end
end
