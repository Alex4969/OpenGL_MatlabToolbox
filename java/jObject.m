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
            end
            

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
                % elseif ismember(class(children),obj.javaComponentAvailable)
                elseif isa(children,'jComponent')
                    obj.javaObj.add(children.javaObj);
                end                
            elseif nargin==3
                if isjava(children)
                    obj.javaObj.add(children,idx);
                % elseif ismember(class(children),obj.javaComponentAvailable)
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

        function setBackground(obj,color)
            jCol=obj.makeJcolor(color);
            obj.javaObj.setBackground(jCol);
        end        
    
        function setBounds(obj,x,y,width,height)
            jRect=obj.makeJrectangle(x, y, width, height);
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
        function jCol=makeJcolor(obj,color_)
            if length(color_)==3
                jCol=java.awt.Color(color_(1),color_(2),color_(3));
            elseif length(color_)==4
                jCol=java.awt.Color(color_(1),color_(2),color_(3),color_(4));
            end
        end
    
        function jImg=makeJimageIcon(obj,pathToFileOnDisk)
            jImg=javax.swing.ImageIcon(pathToFileOnDisk);
        end    
   
        function jRect=makeJrectangle(obj,x, y, width, height)
            jRect=java.awt.Rectangle(x, y, width, height);
        end
    
        function jInset=makeInset(obj,top, left, bottom, right)
            jInset=java.awt.Insets(top, left, bottom, right);
        end
    end

    methods(Access=protected)
        function refresh(obj)
            obj.javaObj.repaint()
            obj.javaObj.revalidate();
        end
    end


end