classdef jFrame < jComponent
    % basic JFrame display in matlab

    properties (Hidden,SetAccess=protected,GetAccess=public)
        InitialFrameLayout
    end

    properties (Constant)
        LOOKANDFEEL="System" % Metal, System or Motif
    end

    properties %(SetAccess=protected,GetAccess=protected)
        toolBar containers.Map %javax.swing.JToolBar
    end 
    
    methods
        
        function obj = jFrame(jF)

            if nargin==0
                obj.initialize;
            elseif nargin==1
                obj.initialize(jF);
            end

            obj.toolBar=containers.Map('KeyType','char','ValueType','any');
            % store frame layout
            contentPane=obj.getContentPane;
            obj.InitialFrameLayout=contentPane.getLayout;

            % Callback
            obj.setCallback('WindowClosing',@(~,~) obj.cbk_WindowClosing);%'WindowClosed'
            
        end
        
    
        function initialize(obj,jF)

            obj.initLookAndFeel(obj.LOOKANDFEEL); %Metal System Motif
            obj.javaObj.setDefaultLookAndFeelDecorated(true);
            %  an alternative way to set the Metal L&F is to replace the 
              % previous line with:
              % lookAndFeel = "javax.swing.plaf.metal.MetalLookAndFeel";

            if nargin==1 %default
                iconpath='C:\Users\pduvauchelle\Philippe\Matlab\Simulation\VXIforMatlab_dev(git)\icon\collection';
                iconFile=fullfile(iconpath,'icons8-atome-66.png');
                title='Default JFrame';
                obj.setContentPaneColor([0.5 0.5 0.5]);
            elseif nargin==2

                title=jF.javaObj.getTitle;
                iconFile=jF.javaObj.getIconImage();
            end
                obj.setTitle(title);
                obj.setIconImage(iconFile);

                obj.setBehaviorOnClose(obj.javaObj.DISPOSE_ON_CLOSE)
                % option DISPOSE_ON_CLOSE, DO_NOTHING_ON_CLOSE, HIDE_ON_CLOSE , EXIT_ON_CLOSE
                obj.javaObj.setLocationRelativeTo([]); % set position to center of screen   
        end
    
        function delete(obj)
            disp('deleting jFrame')
%             obj.rmCallback; % in jComponent
            obj.javaObj.dispose;
        end    

        function cbk_WindowClosing(obj)
            disp('What do i when you click here ?')
            state=obj.javaObj.getDefaultCloseOperation();
            
            switch state
                % option DISPOSE_ON_CLOSE, DO_NOTHING_ON_CLOSE, HIDE_ON_CLOSE , EXIT_ON_CLOSE

                case 0 % DO_NOTHING_ON_CLOSE
                case 1 % HIDE_ON_CLOSE
                case 2 %DISPOSE_ON_CLOSE
                    disp('Byeeee')                   
                    %obj.delete;
                case 3 %EXIT_ON_CLOSE
            end
        end

    end

    methods

        % Menu
        function setMenuVisible(obj,value)
            obj.getMenuBar.setVisible(value);
        end

        % Toolbar
        function addToolbar(obj,name)
            import java.awt.BorderLayout;  
            import java.awt.Container;  
            import javax.swing.JButton;  
            import javax.swing.JComboBox;  
            import javax.swing.JFrame;  
            import javax.swing.JScrollPane;  
            import javax.swing.JTextArea;  
            import javax.swing.JToolBar;  


            toolBar=JToolBar();
            toolBar.setRollover(true);

            button = JButton(strcat('File(', name, ')')); 
            toolBar.add(button);
            toolBar.addSeparator();
            toolBar.add(JButton("Edit")); 

            contentPane = obj.javaObj.getContentPane;  
            contentPane.add(toolBar, BorderLayout.NORTH);%%%%%%
            
%             textArea = JTextArea();  
%             mypane = JScrollPane(textArea);  
%             contentPane.add(mypane, BorderLayout.EAST); %%%%% 
%              obj.setSize([450, 250]);  
             %obj.setVisible(true);  

        end

        % Frame
        function setIconImage(obj,pathToFileOnDisk)
            img=javax.swing.ImageIcon(pathToFileOnDisk);
            obj.javaObj.setIconImage(img.getImage());
        end
        
        function setTitle(obj,title)
            obj.javaObj.setTitle(title);
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

        % ContentPane
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
        
        function setContentPaneColor(obj,color)
            if length(color)==3
                jCol=java.awt.Color(color(1),color(2),color(3));
            elseif length(color)==4
                jCol=java.awt.Color(color(1),color(2),color(3),color(4));
            end
            contentPane=obj.getContentPane;
            contentPane.setBackground(jCol); 
            obj.update;
        end
    end

    %tests and demo
    methods (Access=protected)
        % Other
        function demoLayout(obj)
            obj.setLayout(java.awt.BorderLayout(5,10));
            lo1=obj.getLayout;
            north=javax.swing.JLabel("north                                north");
            south=javax.swing.JLabel("south                                south");
            east=javax.swing.JLabel("<<<<< east >>>>>");
            west=javax.swing.JLabel("<<<<< west >>>>>");
            center=javax.swing.JLabel("***** center *****");
            obj.add(north,lo1.NORTH);
            obj.add(south,lo1.SOUTH);
            obj.add(east,lo1.EAST);
            obj.add(west,lo1.WEST);   
            obj.add(center,lo1.CENTER); 
        end

        function makeToolbar(obj)
            import java.awt.BorderLayout;  
            import java.awt.Container;  
            import javax.swing.JButton;  
            import javax.swing.JComboBox;  
            import javax.swing.JFrame;  
            import javax.swing.JScrollPane;  
            import javax.swing.JTextArea;  
            import javax.swing.JToolBar;  

        myframe = JFrame("JToolBar Example");  
        myframe.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);  

        toolbar = JToolBar();  
        toolbar.setRollover(true);  

        button = JButton("File");  
        toolbar.add(button);  
        toolbar.addSeparator();  
        toolbar.add(JButton("Edit"));  
%         toolbar.add(JComboBox(String[] { "Opt-1", "Opt-2", "Opt-3", "Opt-4" }));  
        contentPane = myframe.getContentPane();  
        contentPane.add(toolbar, BorderLayout.NORTH); 

        textArea = JTextArea();  
        mypane = JScrollPane(textArea);  
        contentPane.add(mypane, BorderLayout.EAST);  
        myframe.setSize(450, 250);  
        myframe.setVisible(true);

        end

    end

    % Callback
    methods(Access=public)

        function setBehaviorOnClose(obj,operation)
                % option DISPOSE_ON_CLOSE, DO_NOTHING_ON_CLOSE, HIDE_ON_CLOSE , EXIT_ON_CLOSE
                obj.javaObj.setDefaultCloseOperation(operation);%obj.javaObj.DISPOSE_ON_CLOSE);
        end


        % Callback
        function MousePressed(obj,src,evt)
            disp('MousePressed  ')
        end
        
        function KeyPressed(obj,src,evt)
            %disp(['KeyPressed : ' evt.getKeyChar])
        end

    end

    methods(Access=private)
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
