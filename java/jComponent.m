classdef jComponent < jObject
    % basic JFrame display in matlab

    properties (Constant)
            javaComponentAvailable={'jFrame' 'jPanel' 'jLabel'}
    end
    
    properties
        % javaObj % javax.swing.JFrame
    end
    
    methods
        
        function obj = jComponent(jC)
                if isa(obj,'jPanel')
                    obj.javaObj = javax.swing.JPanel;
                    obj.setSize([800 600]);
                elseif isa(obj,'jLabel')
                    obj.javaObj = javax.swing.JLabel;  
                    obj.setSize([150 40]);
                end
            

            % Default values
            
            obj.setVisible(false);

            % Callback
            obj.populateCallbacks(obj.javaObj);

            %obj.setCallback('MousePressed',@(~,~) obj.Phil);
%             obj.setMethodCallback('MousePressed');
%             obj.setMethodCallback('KeyPressed');
        end
    end

    methods
        function setBorder(obj,jborder)
            % jborder : javax.swing.border object create by javax.swing.BorderFactory
            %blackline = javax.swing.BorderFactory.createLineBorder(java.awt.Color.black);
            %raisedetched = javax.swing.BorderFactory.createEtchedBorder(javax.swing.border.EtchedBorder.RAISED); 
            obj.javaObj.setBorder(jborder);
        end        
    end
       
end
