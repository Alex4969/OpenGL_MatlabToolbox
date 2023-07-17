classdef jComponent < javacallbackmanager
    % basic JFrame display in matlab

    properties (Constant)
            javaComponentAvailable={'jFrame' 'jPanel' 'jLabel'}
    end
    
    properties
        javaObj % javax.swing.JFrame
    end
    
    methods
        
        function obj = jComponent(jC)
                if isa(obj,'jFrame')
                    obj.javaObj = javax.swing.JFrame;
                    obj.setSize([800 600]);
                elseif isa(obj,'jPanel')
                    obj.javaObj = javax.swing.JPanel;
                    obj.setSize([800 600]);
                elseif isa(obj,'jLabel')
                    obj.javaObj = javax.swing.JLabel;  
                    obj.setSize([150 40]);
                end
            

            % Default values
            
            obj.setVisible(true);

            % Callback
            obj.populateCallbacks(obj.javaObj);

            %obj.setCallback('MousePressed',@(~,~) obj.Phil);
%             obj.setMethodCallback('MousePressed');
%             obj.setMethodCallback('KeyPressed');
        end
       
        function add(obj,children,idx)
            % idx : position in Layout (depending on layout) 
            % for java.awt.BorderLayout : string(North,East,West,South)
            if nargin==2
                if isjava(children)
                    obj.javaObj.add(children);
                elseif imember(class(children),obj.javaComponentAvailable)
                    obj.javaObj.add(children.javaObj);
                end                
            elseif nargin==3
                if isjava(children)
                    obj.javaObj.add(children,idx);
                elseif ismember(class(children),obj.javaComponentAvailable)
                    obj.javaObj.add(children.javaObj,idx);
                end
            end
            obj.setVisible(true);
            obj.update;
        end 

        %Window visible
        function setVisible(obj,value)
            obj.javaObj.setVisible(value);
        end

        %Windows size
        function setSize(obj,sz)
%             sz = double(sz);
            obj.javaObj.setSize(sz(1),sz(2));
        end

        % Layout
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
            obj.update;
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
        % End Layout

        function setBackground(obj,color)
            if length(color)==3
                jCol=java.awt.Color(color(1),color(2),color(3));
            elseif length(color)==4
                jCol=java.awt.Color(color(1),color(2),color(3),color(4));
            end
            obj.javaObj.setBackground(jCol);
        end

        function update(obj)
            obj.javaObj.repaint()
            obj.javaObj.revalidate();
        end

        function delete(obj)
            obj.rmCallback;
%             obj.javaObj.dispose;
        end

    end
end
