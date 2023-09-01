classdef jPanel < jComponent
    % basic JFrame display in matlab with toolbar

    properties %(SetAccess=protected,GetAccess=protected)
        toolBarMap containers.Map %javax.swing.JToolBar
    end 
   
    
    methods
        
        function obj = jPanel(name)
   
            if nargin==0 %default
                name='NewjPanel';
            elseif nargin==1

            end
            
            % Initialize
            obj.toolBarMap=containers.Map('KeyType','char','ValueType','any');
            obj.setName(name);
            % obj.setBorderLayout();
            % obj.setBackground([0.5 0.5 0.5]);

            % callback : if necessary
            %obj.setMethodCallback('***EVENT***');
        end

    
        function delete(obj)
            disp('deleting jPanel')
            
            k=obj.toolBarMap.keys;
            for i=1:obj.toolBarMap.Count
                obj.toolBarMap.remove(k{i});
            end
        end         
    end

methods

        % Toolbar
        function toolbar=addToolbar(obj,name)

            toolbar=jToolbar(name);
            obj.toolBarMap(name)=toolbar;
            obj.add(toolbar,obj.BORDERLAYOUT.NORTH);

        end
   
      
    end
end
