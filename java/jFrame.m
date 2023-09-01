classdef jFrame < jObject
    % basic JFrame display in matlab

    properties (Constant,Hidden)
        FRAME_CLOSE_OPERATION struct=struct('DISPOSE_ON_CLOSE',2, 'DO_NOTHING_ON_CLOSE',0, 'HIDE_ON_CLOSE' ,1, 'EXIT_ON_CLOSE',3)
    end

    properties (Constant)
        LOOKANDFEEL="System" % Metal, System or Motif
    end

    properties %(SetAccess=protected,GetAccess=protected)
        toolBarMap containers.Map %javax.swing.JToolBar
    end 

    % Recordable properties
    properties (SetAccess=protected,GetAccess=public)
        title
    end
    
    methods
        % Constructor
        function obj = jFrame(title)
            obj = obj@jObject;
            
            if nargin==0
                % obj.initialize;
                obj.setTitle("New Frame");
            elseif nargin==1
                % obj.initialize(jF);
                obj.setTitle(title);
            end

            % Look and Feel
            obj.initLookAndFeel(obj.LOOKANDFEEL); %Metal System Motif
            obj.javaObj.setDefaultLookAndFeelDecorated(true);
            %  an alternative way to set the Metal L&F is to replace the previous line with: lookAndFeel = "javax.swing.plaf.metal.MetalLookAndFeel";

            % initialize Frame
            obj.setBounds(100,100,1000,1000);
            obj.setContentPaneColor([0.5 0.5 0.5]);
            
            % ToolBar
            obj.toolBarMap=containers.Map('KeyType','char','ValueType','any');
            

            % Callback
            obj.populateCallbacks(obj.javaObj);
            obj.setCallback('WindowClosing',@(~,~) obj.cbk_WindowClosing);%'WindowClosed'
            obj.setCallback('WindowClosed',@(~,~) obj.cbk_WindowClosed);
            
            % Frame behavior

            % option
            option=obj.FRAME_CLOSE_OPERATION;% option DISPOSE_ON_CLOSE, DO_NOTHING_ON_CLOSE, HIDE_ON_CLOSE , EXIT_ON_CLOSE
            obj.setBehaviorOnClose(option.HIDE_ON_CLOSE);
            % obj.javaObj.setLocationRelativeTo([]); % set position to center of screen 

        end
        
        % Destructor
        function delete(obj)
            disp('deleting jFrame')
            k=obj.toolBarMap.keys;
            for i=1:obj.toolBarMap.Count
                obj.toolBarMap.remove(k{i});
            end

            obj.javaObj.dispose;
        end    
        
    end


    methods

        % Windows Title
        function setTitle(obj,title)
            obj.javaObj.setTitle(title);
            obj.title=title;
        end      
        
        % Menu
        function setMenuVisible(obj,value)
            obj.getMenuBar.setVisible(value);
        end

        % Toolbar
        function toolbar=addToolbar(obj,name)

            toolbar=jToolbar(name);
            obj.toolBarMap(name)=toolbar;
            obj.add(toolbar,obj.BORDERLAYOUT.NORTH);

        end

        % Frame
        function setIconImage(obj,pathToFileOnDisk)
            img=obj.getJimageIcon(pathToFileOnDisk);
            obj.javaObj.setIconImage(img.getImage());
        end
        
        function jImage=getIconImage(obj)
            jImage=obj.javaObj.getIconImage();
        end

        function setBehaviorOnClose(obj,operation)
                % option DISPOSE_ON_CLOSE, DO_NOTHING_ON_CLOSE, HIDE_ON_CLOSE , EXIT_ON_CLOSE
                obj.javaObj.setDefaultCloseOperation(operation);%obj.javaObj.DISPOSE_ON_CLOSE);
        end    

        % ContentPane
        function setContentPaneColor(obj,color)
            jCol=obj.getJcolor(color);
            contentPane=obj.getContentPane;
            contentPane.setBackground(jCol); 
            obj.refresh;
        end
    
        function setContentPane(obj,panel)
%             mainPanel = obj.getRootPane;
%             javax.swing.JPanel(java.awt.BorderLayout());
            if isa(panel,'javax.swing.JPanel')
                obj.javaObj.setContentPane(panel);
            elseif isa(panel,'jPanel')
                obj.javaObj.setContentPane(panel.javaObj);
            end
        end

        function jPanel=getContentPane(obj)
            jPanel=obj.javaObj.getContentPane();
        end        
        
    end

    %java methods
    methods(Access = protected)

        %Menu and toolbar
        function setMenuBar(obj,jmenubar)
            if nargin==1 %default
                jmenubar=javax.swing.JMenuBar();
                jmenu=javax.swing.JMenu("Default Menu");
                jmenubar.add(jmenu);
            end
            obj.javaObj.setJMenuBar(jmenubar);
            obj.javaObj.revalidate;
        end      

        function jmenubar=getMenuBar(obj)
            jmenubar=obj.javaObj.getJMenuBar();
        end


    end

    % Callback
    methods(Access=protected)

        function cbk_WindowClosing(obj)
            disp('WindowClosing .... What do i when you click here ?')
            state=obj.javaObj.getDefaultCloseOperation();
            
            switch state
                % option DISPOSE_ON_CLOSE, DO_NOTHING_ON_CLOSE, HIDE_ON_CLOSE , EXIT_ON_CLOSE

                case 0 % DO_NOTHING_ON_CLOSE
                case 1 % HIDE_ON_CLOSE
                    disp('Windows is hidden')
                case 2 %DISPOSE_ON_CLOSE
                    disp('Windows is closed ... Byeeee')                   
                    obj.delete;
                case 3 %EXIT_ON_CLOSE
            end
        end

        function cbk_WindowClosed(obj)
            disp('WindowClosed .... ')
            state=obj.javaObj.getDefaultCloseOperation();
        end

    end

    % Other protected methods
    methods(Access=protected)
        function lookAndFeel = initLookAndFeel(obj,LOOKANDFEEL)
               import javax.swing.UIManager;
            switch LOOKANDFEEL
                case "Metal"
                    lookAndFeel = UIManager.getCrossPlatformLookAndFeelClassName();
%                     lookAndFeel = "javax.swing.plaf.metal.MetalLookAndFeel"; %alternative                
                case "System"
                    lookAndFeel = UIManager.getSystemLookAndFeelClassName();
                case "Motif"
                    lookAndFeel = "com.sun.java.swing.plaf.motif.MotifLookAndFeel";
                otherwise
                    lookAndFeel = UIManager.getCrossPlatformLookAndFeelClassName();
            end         	       	
                UIManager.setLookAndFeel(lookAndFeel);
                % obj.LOOKANDFEEL=LOOKANDFEEL;
        end
    end

end
