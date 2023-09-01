classdef jOGLframe < jFrame
    % Frame containing openGL panel and other options

    properties(Constant,GetAccess=protected)
        icon_multiviews="cube_plein.png" %multi views
        icon_standard="cube_center.png"
        icon_face="cube_front.png"
        icon_back="cube_back.png"
        icon_rear="cube_rear.png"
        icon_left="cube_left.png"
        icon_right="cube_right.png"
        icon_top="cube_top.png"
        icon_bottom="cube_bottom.png"

        icon_perspective="cube_perspective.png"
        icon_windows="3d_objects.png"
        icon_camera="camera.png"
        icon_info="info3_1.png"
        icon_gear="gear.png"
        icon_light="projector3.png"
        icon_color="color.png"
        icon_grid="grid3.png"
        icon_flash="flash1.png"
        icon_axis="axis1.png"
    end

    properties
        mainPanel jPanel
        statusBar jPanel
        toolBarPanel jPanel
        %scene myScene %glEventListener  
        canvas glCanvas
        textStatusbarLeft jLabel
        textStatusbarMiddle jTextField
        textStatusbarRight jLabel
        textMainPanelNorth jLabel
        textMainPanelSouth jLabel        
    end

    properties
        tTextStatusbarL textTimer
        tTextStatusbarM textTimer
        tTextStatusbarR textTimer
        tTextMainNorth textTimer
        tTextMainSouth textTimer
    end

    properties(GetAccess=public)
        iconpath='C:\Users\pduvauchelle\Philippe\Matlab\openGL\Stage Alexandre Biaud (opengl4-2023)\OpenGL_MatlabToolbox\icons';
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

            %Border
            grayborder1=obj.getJlineBorder([0.6 0.6 0.6],1,true);
            whiteborder2=obj.getJlineBorder([1 1 1],2,true);

            % Set Frame
            obj.setTitle("Open GL windows")                            
            obj.setIconImage(obj.getIconPathOnDisk(obj.icon_windows));

            % Set MainPanel
            obj.mainPanel=jPanel('Main Panel');
            obj.mainPanel.setBorderLayout;            
            obj.mainPanel.add(obj.canvas.javaObj,obj.BORDERLAYOUT.CENTER);
            obj.mainPanel.setBorder(whiteborder2);

            obj.textMainPanelNorth=jLabel;
            obj.textMainPanelNorth.setFont("Arial",2,40);
            obj.textMainPanelNorth.setForegroundColor([0.12 0.42 0.42])
            obj.textMainPanelNorth.setAlignment(pos="CENTER");
            obj.textMainPanelNorth.setBorder(grayborder1);
            obj.textMainPanelNorth.setVisible(true);

            obj.textMainPanelSouth=jLabel;
            obj.textMainPanelSouth.setFont("Arial",0,30);
            obj.textMainPanelSouth.setAlignment(pos="LEFT");
            obj.textMainPanelSouth.setBorder(grayborder1);
            obj.textMainPanelSouth.setVisible(true);

            obj.mainPanel.add(obj.textMainPanelNorth,obj.BORDERLAYOUT.NORTH);
            obj.mainPanel.add(obj.textMainPanelSouth,obj.BORDERLAYOUT.SOUTH);

            % Set toolbar Panel
            obj.toolBarPanel = jPanel('ToolBar Panel');
            % obj.toolBarPanel.setBorderLayout;
            % obj.toolBarPanel.setFlowLayout(FlowLayout.LEFT,[100 100]);
            obj.toolBarPanel.setGridLayout([1 3], [15 15]);
            obj.toolBarPanel.setVisible(true);

            % Set StatusBar
            obj.statusBar = jPanel('Statusbar Panel');
            % obj.statusBar.setBorderLayout;
            %obj.statusBar.setFlowLayout(FlowLayout.LEFT,[20 20]);
            obj.statusBar.setGridLayout([1 5], [15 15]);
            obj.statusBar.setVisible(true);

            % Set Label/Text
            obj.textStatusbarRight=jLabel;
            obj.textStatusbarRight.setFont("Arial",0,30);
            obj.textStatusbarRight.setText("Hello");
            obj.textStatusbarRight.setBorder(grayborder1);
            obj.textStatusbarRight.setIcon(obj.getIconPathOnDisk(obj.icon_info));
            obj.textStatusbarRight.setVisible(true);

            obj.textStatusbarLeft=jLabel;        	    
    	    obj.textStatusbarLeft.setFont("Arial",0,30);             
            obj.textStatusbarLeft.setText("Welcome");
            obj.textStatusbarLeft.setBorder(grayborder1);
            obj.textStatusbarLeft.setIcon(obj.getIconPathOnDisk(obj.icon_gear));
            obj.textStatusbarLeft.setVisible(true);
            
            obj.textStatusbarMiddle=jTextField;        	    
    	    obj.textStatusbarMiddle.setFont("Arial",0,30);             
            obj.textStatusbarMiddle.setText("Middle");
            obj.textStatusbarMiddle.setBorder(grayborder1);
            obj.textStatusbarMiddle.setAlignment(pos="CENTER");
            obj.textStatusbarMiddle.setVisible(true);

            obj.statusBar.add(obj.textStatusbarLeft);
            obj.statusBar.add(obj.textStatusbarMiddle);            
            obj.statusBar.add(obj.textStatusbarRight);

            % Set text timer
            obj.tTextStatusbarL=textTimer(obj.textStatusbarLeft);
            obj.tTextStatusbarM=textTimer(obj.textStatusbarMiddle);
            obj.tTextStatusbarR=textTimer(obj.textStatusbarRight);
            obj.tTextMainNorth=textTimer(obj.textMainPanelNorth);
            obj.tTextMainSouth=textTimer(obj.textMainPanelSouth);
            
            % ToolBars
            tb=obj.addToolbar('Views'); 
            tb.setBorder(grayborder1);
            obj.addToolbarComponent('Views','JButton','multiviews',obj.getIconPathOnDisk(obj.icon_multiviews),'Multiviews (8 predefined views)');
            tb.addSeparator();
            obj.addToolbarComponent('Views','JButton','standard',obj.getIconPathOnDisk(obj.icon_standard),'Standard view');
            obj.addToolbarComponent('Views','JButton','face',obj.getIconPathOnDisk(obj.icon_face),'Front view');
            obj.addToolbarComponent('Views','JButton','back',obj.getIconPathOnDisk(obj.icon_back),'Back view');
            obj.addToolbarComponent('Views','JButton','rear',obj.getIconPathOnDisk(obj.icon_rear),'Rear view');
            obj.addToolbarComponent('Views','JButton','left',obj.getIconPathOnDisk(obj.icon_left),'Left view');
            obj.addToolbarComponent('Views','JButton','right',obj.getIconPathOnDisk(obj.icon_right),'Right view');
            obj.addToolbarComponent('Views','JButton','top',obj.getIconPathOnDisk(obj.icon_top),'Top view');
            obj.addToolbarComponent('Views','JButton','bottom',obj.getIconPathOnDisk(obj.icon_bottom),'Bottom view');  
            tb.addSeparator();
            obj.addToolbarComponent('Views','JToggleButton','perspective',obj.getIconPathOnDisk(obj.icon_perspective),'Perspective/Orthographic');

            tb=obj.addToolbar('Camera');
            tb.setBorder(grayborder1);
            obj.addToolbarComponent('Camera','JButton','axis',obj.getIconPathOnDisk(obj.icon_axis),'Axis');
            obj.addToolbarComponent('Camera','JButton','grid',obj.getIconPathOnDisk(obj.icon_grid),'Change grid');
            obj.addToolbarComponent('Camera','JButton','light',obj.getIconPathOnDisk(obj.icon_light),'Light');
            obj.addToolbarComponent('Camera','JToggleButton','flash',obj.getIconPathOnDisk(obj.icon_flash),'Flash mode : set light on camera');            
            obj.addToolbarComponent('Camera','JButton','color',obj.getIconPathOnDisk(obj.icon_color),'Background Color');
            obj.addToolbarComponent('Camera','JButton','screenshot',obj.getIconPathOnDisk(obj.icon_camera),'Screenshot');          

            % Link Panels
            obj.add(obj.mainPanel,obj.BORDERLAYOUT.CENTER);
            obj.add(obj.toolBarPanel, obj.BORDERLAYOUT.NORTH);
            obj.add(obj.statusBar, obj.BORDERLAYOUT.SOUTH);          

        end

        % Destructor
        function delete(obj)
            obj.canvas.delete;
            delete@jFrame(obj);
            disp('jOGLframe deleted')
        end
    end

    %ToolBar
    methods

        function toolbar=addToolbar(obj,name)

            toolbar=jToolbar(name);
            obj.toolBarMap(name)=toolbar;
            obj.toolBarPanel.add(toolbar);

        end

        function toolbar=addToolbarComponent(obj,tb_name,comp_type,comp_name,comp_icon,comp_toolTip)

            toolbar=obj.toolBarMap(tb_name);
            % comp_icon=obj.getAvailableIcon(icon=comp_icon);
            toolbar.addComponent(comp_type,comp_name,comp_icon,comp_toolTip);
        end

        function iconFile=getIconPathOnDisk(obj,name)
            % arguments
            %     obj
            %     name.icon {mustBeMember(name.icon,{'icon_origin','icon_face','icon_back',...
            %         'icon_left','icon_right','icon_top','icon_bottom',...
            %         'icon_windows'})}
            %     name.icon1 {mustBeMember(name.icon1,{obj.icon_origin})}
            % end
            
            iconFile=fullfile(obj.iconpath,name);
            % disp(iconFile)
        end


    end

    % Windows methods
    methods

        function setTextLeft(obj,newText,duration)
            if nargin==2 %duration infinity
                obj.tTextStatusbarL.setText(newText);
            elseif nargin==3
                obj.tTextStatusbarL.setText(newText,duration);
            end 
        end

        function setTextMiddle(obj,newText,duration)
            if nargin==2 %duration infinity
                obj.tTextStatusbarM.setText(newText);
            elseif nargin==3
                obj.tTextStatusbarM.setText(newText,duration);
            end 
        end

        function setTextRight(obj,newText,duration)
            if nargin==2 %duration infinity
                obj.tTextStatusbarR.setText(newText);
            elseif nargin==3
                obj.tTextStatusbarR.setText(newText,duration);
            end 
        end

         function setTextNorth(obj,newText,duration)
            if nargin==2 %duration infinity
                obj.tTextMainNorth.setText(newText);
            elseif nargin==3
                obj.tTextMainNorth.setText(newText,duration);
            end 
         end      

         function setTextSouth(obj,newText,duration)
            if nargin==2 %duration infinity
                obj.tTextMainSouth.setText(newText);
            elseif nargin==3
                obj.tTextMainSouth.setText(newText,duration);
            end 
        end           

    end
end