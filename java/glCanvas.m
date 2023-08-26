classdef glCanvas < javacallbackmanager
    % Abstract class for creating OpenGL component
    % Set this class as a superclass for your opengl render class
    % Define those methods in your class:
    % InitFcn(obj,d,gl,varargin)
    % UpdateFcn(obj,d,gl)
    % ResizeFcn(obj,d,gl)
    
    properties
        javaObj % com.jogamp.opengl.awt.GLCanvas
    end
    
    properties(Access=public)%protected)
        context
        % glInitialized=0 %true when OGL is initialized
    end
    
% events
%     evt_MousePressed
%     evt_MouseReleased
%     evt_MouseClicked
%     evt_MouseExited
%     evt_MouseEntered
%     evt_MouseMoved
%     evt_MouseDragged
%     evt_MouseWheelMoved
%     evt_KeyTyped
%     evt_KeyPressed
%     evt_KeyReleased
%     evt_ComponentResized
%     evt_ComponentMoved
%     evt_ComponentShown
%     evt_ComponentHidden
% end

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
        

    methods
        
        function delete(obj)
            obj.rmCallback;
            % obj.releaseContext;
        end
        
    end

end
