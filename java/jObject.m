classdef (Abstract) jObject <javacallbackmanager
    % General java class
    % general common function : size, background, 
    % useful function as color, icon, police ...

    properties (Constant)%,Hidden)
        BORDERLAYOUT=struct('CENTER',"Center",'SOUTH',"South",'NORTH',"North",'EAST',"East",'WEST',"West")
    end
    
    properties (SetAccess=public)%,Hidden)
        javaObj
    end

    methods
        %Constructor
        function obj = jObject()
            disp('jObject constructor...')

            if isa(obj,'jFrame')
                obj.javaObj = javax.swing.JFrame;
            elseif isa(obj,'jPanel')
                obj.javaObj = javax.swing.JPanel();
                % obj.setSize([800 600]);
            elseif isa(obj,'jLabel')
                obj.javaObj = javax.swing.JLabel();  
                % obj.setSize([150 40]);
            elseif isa(obj,'jToolbar')
                obj.javaObj = javax.swing.JToolBar();
            elseif isa(obj,'jButton')
                obj.javaObj = javax.swing.JButton();  
            elseif isa(obj,'jTextField')
                obj.javaObj = javax.swing.JTextField();                  
            else
               warning('No java object known')
               return;
            end

            % Default values
            % obj.setVisible(false);

            % Callback
            obj.populateCallbacks(obj.javaObj);
            

        end

        % Destructor
        function delete(obj)
            disp('jObject destructor ...')
            obj.rmCallback;
        end

    end

    % API methods
    methods

        function add(obj,children,idx)
            % idx (optionnal) : position in Layout (depending on layout) 
            % for java.awt.BorderLayout : string(North,East,West,South)
            if nargin==2
                if isjava(children)
                    obj.javaObj.add(children);
                elseif isa(children,'jComponent')
                    obj.javaObj.add(children.javaObj);
                end                
            elseif nargin==3
                if isjava(children)
                    obj.javaObj.add(children,idx);
                elseif isa(children,'jComponent')
                    obj.javaObj.add(children.javaObj,idx);
                end
            end
            obj.setVisible(true);
            obj.refresh;
        end 

        % Window visible
        function setVisible(obj,value)
            obj.javaObj.setVisible(value);
        end

        % Windows size 1x2
        function setSize(obj,sz)
%             sz = double(sz);
            obj.javaObj.setSize(sz(1),sz(2));
        end     

        function setName(obj,name)
            obj.javaObj.setName(name);
        end

        function setBackground(obj,color)
            jCol=obj.getJcolor(color);
            obj.javaObj.setBackground(jCol);
            obj.refresh;
        end        
    
        function setBounds(obj,x,y,width,height)
            jRect=obj.getJrectangle(x, y, width, height);
            obj.javaObj.setBounds(jRect);
        end

        function [jRect,bounds]=getBounds(obj)
            jRect=obj.javaObj.getBounds();
            bounds.x=jRect.x;
            bounds.y=jRect.y;
            bounds.width=jRect.width;
            bounds.height=jRect.height;
        end

    end

    % Layout methods
    methods
        
        function jlayout=getLayout(obj)
            % jlayout : java object
            jlayout=obj.javaObj.getLayout();
        end

        function setLayout(obj,jlayout)
            % jlayout : java object
            if isa(obj,'jFrame')
                contentPane=obj.getContentPane;
                contentPane.setLayout(jlayout);
            else
                obj.javaObj.setLayout(jlayout);
            end
            obj.refresh;
        end

        function setBorderLayout(obj,gap)
            %https://docs.oracle.com/javase/8/docs/api/java/awt/BorderLayout.html
            
            if nargin==1
                if isa(obj,'jFrame')
                    obj.InitialFrameLayout.setHgap(0);
                    obj.InitialFrameLayout.setVgap(0);
                    obj.setLayout(obj.InitialFrameLayout);
                else
                    obj.setLayout(java.awt.BorderLayout());
                end
            else
                if isa(obj,'jFrame')
                    obj.InitialFrameLayout.setHgap(gap(1));
                    obj.InitialFrameLayout.setVgap(gap(2));
                    obj.setLayout(obj.InitialFrameLayout);
                else
                hgap=gap(1); vgap=gap(2);
                obj.setLayout(java.awt.BorderLayout(hgap, vgap));
                end

            end            
        end

        function setBoxLayout(obj,axis)
            %https://docs.oracle.com/javase/8/docs/api/javax/swing/BoxLayout.html
            %Axis : 0 to 3
            import javax.swing.*;
            if nargin==1
                axis=BoxLayout.LINE_AXIS; %(axis=2)
            end  
            if isa(obj,'jFrame')
                contentPane=obj.getContentPane;
                javax.swing.BoxLayout(contentPane,axis);
            else
                javax.swing.BoxLayout(obj.javaObj,axis);
            end
            obj.update;
        end

        function setCardLayout(obj,gap)
            %https://docs.oracle.com/javase/8/docs/api/java/awt/CardLayout.html
            hgap=gap(1); vgap=gap(2);
            if nargin==1
                obj.javaObj.setLayout(java.awt.CardLayout());
            else
                obj.javaObj.setLayout(java.awt.CardLayout(hgap, vgap));
            end            
        end

        % gap 1x2
        function setFlowLayout(obj,align, gap)
            %https://docs.oracle.com/javase/8/docs/api/java/awt/FlowLayout.html
            
            if nargin==1
                obj.setLayout(java.awt.FlowLayout());
            elseif nargin==2
                obj.setLayout(java.awt.FlowLayout(align));
            elseif nargin==3
                hgap=gap(1); vgap=gap(2);
                obj.setLayout(java.awt.FlowLayout(align,hgap,vgap));
            end            
        end   

        function setGridLayout(obj,RowCol, gap)
            %https://docs.oracle.com/javase/8/docs/api/java/awt/GridLayout.html
            
            if nargin==1
                obj.setLayout(java.awt.GridLayout());
            elseif nargin==2
                obj.setLayout(java.awt.GridLayout(RowCol(1),RowCol(2)));
            elseif nargin==3
                hgap=gap(1); vgap=gap(2);
                obj.setLayout(java.awt.GridLayout(RowCol(1),RowCol(2),hgap,vgap));
            end            
        end   
                
    end

    %Native java methods
    methods (Access=public)%protected)
        % get java color 1x3 or 1x4
        function jCol=getJcolor(obj,color_)
            if length(color_)==3
                jCol=java.awt.Color(color_(1),color_(2),color_(3));
            elseif length(color_)==4
                jCol=java.awt.Color(color_(1),color_(2),color_(3),color_(4));
            end
        end
    
        function jImg=getJimageIcon(obj,pathToFileOnDisk)
            jImg=javax.swing.ImageIcon(pathToFileOnDisk);
        end    
   
        function jRect=getJrectangle(obj,x, y, width, height)
            jRect=java.awt.Rectangle(x, y, width, height);
        end
    
        function jInset=getJinset(obj,top, left, bottom, right)
            jInset=java.awt.Insets(top, left, bottom, right);
        end

        % Border
        % https://docs.oracle.com/javase/tutorial/uiswing/components/border.html
        function jBorder=getJemptyBorder(obj)
             	jBorder = javax.swing.BorderFactory.createEmptyBorder();
        end

        function jBorder=getJlineBorder(obj,color,thickness,rounded)
            jBorder = javax.swing.BorderFactory.createLineBorder(obj.getJcolor(color),thickness,rounded);
        end

        function jBorder=getJdashedBorder(obj,color,thickness,length,spacing,rounded)
            jBorder = javax.swing.BorderFactory.createDashedBorder(obj.getJcolor(color),  thickness,  length,  spacing,  rounded);            
        end     

        % type : RAISED (0) , LOWERED (1)
        function jBorder=getJbevelBorder(obj,type)
            % jBorder = javax.swing.BorderFactory.createBevelBorder(type, obj.getJcolor(ColorhighlightOuter), obj.getJcolor(ColorhighlightInner), obj.getJcolor(ColorshadowOuter), obj.getJcolor(ColorshadowInner))           
            jBorder = javax.swing.BorderFactory.createBevelBorder(type);           
        end 

        % type : RAISED (0) , LOWERED (1)
        function jBorder=getJetchedBorder(obj,type,ColorHighlight, ColorShadow)
            jBorder = javax.swing.BorderFactory.createEtchedBorder(type, obj.getJcolor(ColorHighlight), obj.getJcolor(ColorShadow));    
        end 



        function jTitleborder=getJtitledBorder(obj,jborder, title)
            jTitleborder=javax.swing.BorderFactory.createTitledBorder(jborder, title)
        end  

   % paneEdge = javax.swing.BorderFactory.createEmptyBorder(0,100,100,100);
   % 
   %      blackline = javax.swing.BorderFactory.createLineBorder(java.awt.Color.black);
   %      raisedetched = javax.swing.BorderFactory.createEtchedBorder(javax.swing.border.EtchedBorder.RAISED);
   % 
   %      obj.mainPanel.add(down, java.awt.BorderLayout.SOUTH); 
   %      obj.mainPanel.setBorder(blackline);
   %      down.setBorder(raisedetched);

    end

    methods(Access=public)
        function refresh(obj)
            obj.javaObj.repaint()
            obj.javaObj.revalidate();
        end
    end


end