classdef jToolbar < javacallbackmanager
    % basic JFrame display in matlab
    properties
        javaObj javax.swing.JToolBar
    end
    
    methods
        
        function obj = jToolbar(name)
            % if nargin < 1
            %     name = 'javax.swing.JFrame';
            % end
            % if nargin < 2, sz = [800 600]; end
            
            obj.javaObj = javax.swing.JToolBar(name);
            % obj.java.setDefaultCloseOperation(obj.java.DISPOSE_ON_CLOSE);
            % obj.setSize(sz);
            % obj.java.setLocationRelativeTo([]); % set position to center of screen
            obj.setVisible(true);

            % obj.mainPanel = javax.swing.JPanel(java.awt.BorderLayout());
            % panel=obj.java.getRootPane;
            % panel.setContentPane(obj.mainPanel);

            obj.populateCallbacks(obj.java);
            obj.setCallback('WindowClosed',@(~,~) obj.delete);
        end

        function add(obj,children)
            obj.java.add(children);
            obj.java.show;
        end

        function setVisible(obj,value)
            obj.javaObj.setVisible(value);
        end

        function setSize(obj,sz)
%             sz = double(sz);
            obj.javaObj.setSize(sz(1),sz(2));
        end

        function setIconImage(obj,pathToFileOnDisk)
            img=javax.swing.ImageIcon(pathToFileOnDisk);
            obj.java.setIconImage(img.getImage());
        end
        
        function setTitle(obj,title)
            obj.javaObj.setTitle(title);
        end

        function jPanel=getRootPane(obj)
            jPanel=obj.java.getRootPane();
        end        

        function addToolBar(obj,pos)
            obj.toolBar=javax.swing.JToolBar("mytoolBar");
            obj.toolBar.setRollover(true);  
            button = javax.swing.JButton("File");  
            icon=javax.swing.ImageIcon('C:\Users\pduvauchelle\Philippe\Matlab\Simulation\VXIforMatlab_dev(git)\icon\collection\icons8-atome-66.png');
            button.setIcon(icon);

            obj.toolBar.add(button); 
            obj.mainPanel.add(obj.toolBar,java.awt.BorderLayout.NORTH);


        textDownR=javax.swing.JLabel("Hello")
        textDownL=javax.swing.JLabel("Welcome")
    	textDownR.setFont(java.awt.Font("Arial",0,40));
    	textDownL.setFont(java.awt.Font("Arial",0,40));

        down = javax.swing.JPanel(java.awt.BorderLayout())    
        down.add(textDownR, java.awt.BorderLayout.EAST);
        down.add(textDownL, java.awt.BorderLayout.WEST);

%         blackline= javax.swing.border.Border();
%         raisedetched= javax.swing.border.Border();
%         EtchedBorder= javax.swing.border.Border();
paneEdge = javax.swing.BorderFactory.createEmptyBorder(0,100,100,100);
 
        blackline = javax.swing.BorderFactory.createLineBorder(java.awt.Color.black);
        raisedetched = javax.swing.BorderFactory.createEtchedBorder(javax.swing.border.EtchedBorder.RAISED);

        obj.mainPanel.add(down, java.awt.BorderLayout.SOUTH); 
        obj.mainPanel.setBorder(blackline);
        down.setBorder(raisedetched);
        end

        function delete(obj)
            obj.rmCallback;
            obj.java.dispose;
        end
        
    end
end
