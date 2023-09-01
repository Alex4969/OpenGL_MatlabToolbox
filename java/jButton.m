classdef jButton < jComponent
    % basic JLabel display in matlab

%     properties
%         javaObj % javax.swing.JPanel
%     end

   
    
    methods
        
        function obj = jButton(name)
            if nargin == 0              
                obj.setName('newButton');
                % obj.setText('newButton');
                % obj.setToolTipText('newButton');
            elseif nargin==1
                obj.setName(name);
                obj.setToolTipText(name);
            end          

            % Initialize default           
            % icon,action,toolTipText,altText)
            % 
            % % JButton button = new JButton();
            % % button.setActionCommand(actionCommand);
            % % button.setToolTipText(toolTipText);
            % % button.addActionListener(this);
            % % setIcon(new ImageIcon(imageURL, altText));
            % % button.setText(altText);
            % 
            % import javax.swing.JButton;  
            % 
            % iconpath='C:\Users\pduvauchelle\Philippe\Matlab\Simulation\VXIforMatlab_dev(git)\icon\collection';
            % iconFile=fullfile(iconpath,'if_3d_objects_102518.png');
            % icon=obj.makeJimageIcon(iconFile);

            % callback : if necessary
            % obj.setMethodCallback('MouseClicked'); 
        end

        function setText(obj,newText)
            obj.javaObj.setText(newText);
        end

        function setToolTipText(obj,toolTipText)
            obj.javaObj.setToolTipText(toolTipText);
        end

        function setIcon(obj,icon)
            obj.javaObj.setIcon(icon);
        end

        function MouseClicked(obj,source,event)
            disp(['JBUTTON CLASS ******** ' char(obj.javaObj.getName())]);
        end
    
        function delete(obj)
            disp('deleting jButton')
%             obj.rmCallback; % in jComponent
%             obj.javaObj.dispose;
        end         
    end

methods


       
    end
end
