classdef jLabel < jComponent
    % basic JLabel display in matlab

%     properties
%         javaObj % javax.swing.JPanel
%     end

   
    
    methods
        
        function obj = jLabel(jL)

            if nargin==0
                obj.initialize;
            elseif nargin==1
                obj.initialize(jP);
            end            
            
            obj.populateCallbacks(obj.javaObj);
            %obj.setCallback('WindowClosed',@(~,~) obj.delete);
        end

        function initialize(obj,jL)
            %import java.awt.*;
            if nargin==1 %default
                obj.setFont("Arial",0,30);
                obj.setText("new text");
            elseif nargin==2
                obj.setFont(jL.getFont);
                obj.setText(jL.getText);
            end
               
        end

        function setFont(obj,police,style,siz)
            % style: 0 (normal) , 1 (bold) 2 (italic) 3 (bold+italic)
            import java.awt.*;
            obj.javaObj.setFont(Font(police,style,siz));
        end

        function setText(obj,newText)
            obj.javaObj.setText(newText);
        end
    
        function delete(obj)
            disp('deleting jLabel')
%             obj.rmCallback; % in jComponent
%             obj.javaObj.dispose;
        end         
    end

methods


       
    end
end
