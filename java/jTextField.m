classdef jTextField < jComponent
    % basic JLabel display in matlab

%     properties
%         javaObj % javax.swing.JPanel
%     end

   
    
    methods
        
        function obj = jTextField(text)
            if nargin==0
                % return;
            elseif nargin==1
                obj.setText(text);
            end      

            % Initialize default
            obj.setFont("Arial",0,30);
            obj.setEditable(false);
            obj.setSelectable(false);
            

            % callback : if necessary
            %obj.setMethodCallback('***EVENT***');
        end

        function delete(obj)
            disp('deleting jLabel')

        end
    end

    methods
        function setFont(obj,police,style,siz)
            % style: 0 (normal) , 1 (bold) 2 (italic) 3 (bold+italic)
            import java.awt.*;
            obj.javaObj.setFont(Font(police,style,siz));
        end

        % change text color
        function setForegroundColor(obj,color)
            jCol=obj.getJcolor(color);
            obj.javaObj.setForeground(jCol);
        end   

        function setText(obj,newText)
            obj.javaObj.setText(newText);
        end  

        function setAlignment(obj,option)
            arguments
                obj
                option.pos {mustBeMember(option.pos,{'CENTER','LEFT','RIGHT'})}
            end
            obj.javaObj.setHorizontalAlignment(javax.swing.JTextField.(option.pos));
        end

        function setEditable(obj,value)
            obj.javaObj.setEditable(value);
        end

        function setSelectable(obj,value)
            if value
            else
                obj.javaObj.setHighlighter('');
            end
        end        
             
    end


end
