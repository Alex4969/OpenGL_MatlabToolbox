classdef jLabel < jComponent
    % basic JLabel display in matlab

%     properties
%         javaObj % javax.swing.JPanel
%     end

   
    
    methods
        
        function obj = jLabel(text)
            if nargin==0
                % return;
            elseif nargin==1
                obj.setText(text);
            end      

            % Initialize default
            obj.setFont("Arial",0,30);
            obj.javaObj.setOpaque(true);%to view backgroundcolor

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

        function setIcon(obj,pathToFileOnDisk)
            newIcon=obj.getJimageIcon(pathToFileOnDisk);
            obj.javaObj.setIcon(newIcon);
        end   

        % change text color
        function setForegroundColor(obj,color)
            jCol=obj.getJcolor(color);
            obj.javaObj.setForeground(jCol);
        end        
    end


end
