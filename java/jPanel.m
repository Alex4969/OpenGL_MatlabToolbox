classdef jPanel < jComponent
    % basic JFrame display in matlab

%     properties
%         javaObj % javax.swing.JPanel
%     end

    properties %(SetAccess=protected,GetAccess=protected)
        toolBar containers.Map %javax.swing.JToolBar
    end 
   
    
    methods
        
        function obj = jPanel(jP)

            if nargin==0
                obj.initialize;
            elseif nargin==1
                obj.initialize(jP);
            end            
            
            obj.toolBar=containers.Map('KeyType','char','ValueType','any');

            obj.populateCallbacks(obj.javaObj);
            %obj.setCallback('WindowClosed',@(~,~) obj.delete);
        end

        function initialize(obj,jP)
%             arguments
%                 obj
%                 jP jPanel
%             end
           
            if nargin==1 %default
%                 obj.setLayout(java.awt.GridLayout());
                %obj.setBackground([1 0 0]);
            elseif nargin==2
                obj.setLayout(jP.getLayout);
            end
               
        end
    
        function delete(obj)
            disp('deleting jPanel')
%             obj.rmCallback; % in jComponent
%             obj.javaObj.dispose;
        end         
    end

methods

        function setBorder(obj,jborder)
            % jborder : javax.swing.border object create by javax.swing.BorderFactory
            %blackline = javax.swing.BorderFactory.createLineBorder(java.awt.Color.black);
            %raisedetched = javax.swing.BorderFactory.createEtchedBorder(javax.swing.border.EtchedBorder.RAISED); 
            obj.javaObj.setBorder(jborder);
        end



%         function setSize(obj,sz)
% %             sz = double(sz);
%             obj.javaObj.setSize(sz(1),sz(2));
%         end
% 
%         function setIconImage(obj,pathToFileOnDisk)
%             img=javax.swing.ImageIcon(pathToFileOnDisk);
%             obj.javaObj.setIconImage(img.getImage());
%         end
%         
%         function setTitle(obj,title)
%             obj.javaObj.setTitle(title);
%         end
% 
%         function jPanel=getRootPane(obj)
%             jPanel=obj.javaObj.getRootPane();
%         end        

        function addToolBar(obj,name)
            import javax.swing.*
            obj.toolBar(name)=javax.swing.JToolBar(name);
            tb=obj.toolBar(name);

            tb.setRollover(true);
            button = JButton(strcat('File(', name, ')')); 
            tb.add(button);
            tb.addSeparator();
            tb.add(JButton("Edit"));

%             tb.setBorder(javax.swing.BorderFactory.createLineBorder(java.awt.Color.black));
%             tb.show();
%             toolbarPanel=jPanel;
%             obj.add(toolbarPanel.javaObj,java.awt.BorderLayout.NORTH);
% %             %toolbarPanel.setLayout(java.awt.BorderLayout())
%             toolbarPanel.add(tb,java.awt.BorderLayout.NORTH);%java.awt.FlowLayout);
%             toolbarPanel.setBorder(javax.swing.BorderFactory.createLineBorder(java.awt.Color.black))
% %             obj.add(toolbarPanel.javaObj,java.awt.BorderLayout.NORTH);

%               obj.add(tb,idx);
              obj.javaObj.add(tb,"North");
            obj.javaObj.revalidate;
        end

        function DemoToolBar(obj,name)
            button1 = javax.swing.JButton(strcat('File(', name, ')')); 
            button2 = javax.swing.JButton("Edit"); 
            button3 = javax.swing.JButton("Help"); 
            icon=javax.swing.ImageIcon('C:\Users\pduvauchelle\Philippe\Matlab\Simulation\VXIforMatlab_dev(git)\icon\collection\icons8-atome-66.png');
            button1.setIcon(icon);obj.toolBar(name).add(button1);
            tb=obj.toolBar(name);
            tb.addSeparator;
            button2.setIcon(icon);tb.add(button2);
            button3.setIcon(icon);tb.add(button3);

            obj.javaObj.revalidate;
        end

       
    end
end
