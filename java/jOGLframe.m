classdef jOGLframe < jFrame
    % Frame containing openGL panel and other options

    properties
        mainPanel jPanel
        statusBar jPanel
        toolBarPanel jPanel
        %scene myScene %glEventListener  
        canvas glCanvas
        textDownL jLabel
        textDownR jLabel
        textMiddle jLabel
    end

    properties(GetAccess=public)
        iconpath='C:\Users\pduvauchelle\Philippe\Matlab\Simulation\VXIforMatlab_dev(git)\icon\collection';
    end

    methods
        % Constructor
        function obj = jOGLframe(glprofile,aaSample)
            obj = obj@jFrame;
            if nargin<1
                glprofile='GL4';
                aaSample=0;
            elseif nargin<2
            end

            disp('Hello, i am a OpenGL 3D scene')
            obj.canvas=glCanvas(glprofile,aaSample);
            obj.configure;% add canvas to Frame
            
            % obj.canvas.initOGL;
        end

        % OpenGL windows configuration
        function configure(obj)
            % import
            import java.awt.KeyboardFocusManager;
            import java.util.*;
            import java.awt.*;
            import javax.swing.*;


            % Set Frame
            obj.setTitle("Open GL windows")                            
            iconFile=fullfile(obj.iconpath,'if_3d_objects_102518.png');
            obj.makeJimageIcon(iconFile)
            obj.setIconImage(iconFile);

            % Set MainPanel
            obj.mainPanel=jPanel;
            obj.mainPanel.setBorderLayout;            
            obj.mainPanel.add(obj.canvas.javaObj,obj.BORDERLAYOUT.CENTER);

            % Set StatusBar
            obj.toolBarPanel = jPanel;
            % obj.statusBar.setBorderLayout;
            %obj.statusBar.setFlowLayout(FlowLayout.LEFT,[20 20]);
            obj.toolBarPanel.setGridLayout([1 3], [50 50]);
            obj.toolBarPanel.setVisible(true);

            % Set StatusBar
            obj.statusBar = jPanel;
            % obj.statusBar.setBorderLayout;
            %obj.statusBar.setFlowLayout(FlowLayout.LEFT,[20 20]);
            obj.statusBar.setGridLayout([1 3], [50 50]);
            obj.statusBar.setVisible(true);

            % Set Label/Text
            obj.textDownR=jLabel;
            obj.textDownR.setFont("Arial",0,30);
            obj.textDownR.setText("Hello");
            obj.textDownR.setVisible(true);

            obj.textDownL=jLabel;        	    
    	    obj.textDownL.setFont("Arial",0,30);             
            obj.textDownL.setText("Welcome");
            obj.textDownL.setVisible(true);
            
            obj.textMiddle=jLabel;        	    
    	    obj.textMiddle.setFont("Arial",0,30);             
            obj.textMiddle.setText("Middle");
            obj.textMiddle.setVisible(true);

            % obj.statusBar.add(obj.textDownL, BorderLayout.WEST);
            % obj.statusBar.add(obj.textMiddle, BorderLayout.CENTER);
            % obj.statusBar.add(obj.textDownR, BorderLayout.EAST);
            obj.statusBar.add(obj.textDownL);
            obj.statusBar.add(obj.textMiddle);
            obj.statusBar.add(obj.textDownR);
            


            % xxx1=javax.swing.JTextField("JTEXTField01234567890123456789");
            % xxx2=javax.swing.JTextField("JTEXTField01234567890123456789");
            % xxx1.setHorizontalAlignment(javax.swing.JTextField.CENTER)
            % statusBar.add(xxx1);
            % statusBar.add(xxx2);
            % xxx1.setEditable(false);
            % xxx1.setHighlighter('');
            % xxx1.setBounds(50,150, 500,30);


                         

            %Link mainPanel to Frame
            % obj.add(obj.mainPanel.javaObj,java.awt.BorderLayout.CENTER); 
            % obj.add(obj.mainPanel,java.awt.BorderLayout.CENTER); %NE FONCTIONNE PAS

            % Link Panels
            obj.add(obj.statusBar, obj.BORDERLAYOUT.SOUTH);
            obj.add(obj.toolBarPanel, obj.BORDERLAYOUT.NORTH);
            obj.add(obj.mainPanel,obj.BORDERLAYOUT.CENTER);

        end

        % Destructor
        function delete(obj)
            obj.canvas.delete;
            delete@jFrame(obj);
            disp('jOGLframe deleted')
        end
    end

    % Windows methods
    methods
        function setTextLeft(obj,newText)
            obj.textDownL.setText(newText);
        end

        function setTextMiddle(obj,newText)
            obj.textMiddle.setText(newText);
        end

        function setTextRight(obj,newText)
            obj.textDownR.setText(newText);
        end

        function setStatusBarVisible(obj,state)

        end
    end
end