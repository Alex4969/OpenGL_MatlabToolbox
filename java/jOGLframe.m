classdef jOGLframe < jFrame
    %config scene and array

    properties
        mainPanel jPanel
        %scene myScene %glEventListener  
        canvas glCanvas
        textDownL jLabel
        textDownR jLabel
    end

    methods
        function obj = jOGLframe(glprofile,aaSample)
            %
            if nargin<1
                glprofile='GL4';
                aaSample=0;
            elseif nargin<2
            end

            disp('Hello, i am a OpenGL scene3D')
            obj.canvas=glCanvas(glprofile,aaSample);
            obj.configure;% add canvas to Frame
            
            % obj.canvas.initOGL;
        end

        function configure(obj)
            % import
            import java.awt.KeyboardFocusManager;
            import java.util.*;
            import java.awt.*;
            import javax.swing.*;


            % Set Frame
            obj.setTitle("*** hellooooo ")

            % Set MainPanel
            obj.mainPanel=jPanel;
            obj.mainPanel.setBorderLayout;            
            obj.mainPanel.add(obj.canvas.javaObj,BorderLayout.CENTER);

            obj.textDownR=jLabel;
            obj.textDownL=jLabel;    
    	    obj.textDownR.setFont("Arial",0,30);
    	    obj.textDownL.setFont("Arial",0,30);   
            obj.textDownR.setText("Hello");
            obj.textDownL.setText("Welcome");
            
            down = jPanel;
            down.setBorderLayout;
            down.add(obj.textDownR, BorderLayout.EAST);
            down.add(obj.textDownL, BorderLayout.WEST);
            obj.mainPanel.add(down, BorderLayout.SOUTH);             

            %Link mainPanel to Frame
            obj.add(obj.mainPanel.javaObj,java.awt.BorderLayout.CENTER);            
        end

        function delete(obj)

            obj.canvas.delete;
            delete@jFrame(obj);
            disp('glScene3D deleted')
        end
        
        function setTextLeft(obj,newText)
            obj.textDownL.setText(newText);
        end

        function setTextRight(obj,newText)
            obj.textDownR.setText(newText);
        end

    end
end