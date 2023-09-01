classdef jComponent < jObject
    % basic JFrame display in matlab

  
    properties

    end
    
    methods
        % Constructor
        function obj = jComponent()

        end

        function delete(obj)
            disp('deleting jComponent')
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
