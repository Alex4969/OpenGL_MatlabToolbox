classdef jToolbar < jComponent
    % basic JFrame display in matlab
    properties
        % javaObj javax.swing.JToolBar
    end

    events
        evt_mouseClickedButton
    end
    
    methods
        
        function obj = jToolbar(name)
            if nargin == 0
                name='';
            elseif nargin==1
                obj.javaObj.setName(name);
            end          

            % Initialize default           
            obj.javaObj.setRollover(true);
            obj.javaObj.setFloatable(true);

            % obj.addComponent(name);

            % callback : if necessary
            %obj.setMethodCallback('***EVENT***');            

        end


        function addSeparator(obj)
            obj.javaObj.addSeparator();
            obj.refresh();
        end

        function addComponent(obj,compType,name,iconFile,toolTipText)
            arguments
                obj
                compType {mustBeMember(compType,{'JButton','JToggleButton'})}
                name char {mustBeTextScalar}
                iconFile char
                toolTipText char
            end

            if isequal(compType,'JButton')
                button = javax.swing.JButton();  
            elseif isequal(compType,'JToggleButton')    
                button = javax.swing.JToggleButton();
            end

            button.setName(name);
            icon=obj.getJimageIcon(iconFile);
            button.setIcon(icon);
            button.setToolTipText(toolTipText);

            obj.javaObj.add(button);
            obj.addAction();

        end
        
        function setComponent(obj,idx,prop)
            arguments
                obj
                idx (1,1) double {mustBeNonnegative,mustBeInteger}
                prop.iconFile char {mustBeTextScalar}
                prop.toolTipText char
            end
                    
            comp=obj.getComponentAtIndex(idx);
            if isfield(prop,'iconFile')
                icon=obj.getJimageIcon(comp_icon);
                comp.setIcon(icon);
            elseif isfield(prop,'toolTipText')
                comp.setToolTipText(prop.toolTipText);
            end
        end



        function N=getComponentCount(obj)
            N=obj.javaObj.getComponentCount();
        end

        %idxList : 1xN
        function buttonComp=getComponentAtIndex(obj,idxList)
            for i=1:length(idxList)
                buttonComp{i}=obj.javaObj.getComponentAtIndex(idxList(i));
            end
            buttonComp=cell2mat(buttonComp);
        end        

        function delete(obj)
            disp('jToolbar deleting')
            % obj.rmCallback;
        end
        
    end
    
    % Callback
    methods
        function cbk_MouseClicked(obj,source,event)
            disp(['JTOOLBAR ' char(obj.javaObj.getName()) '      >>> Button : ' char(source.getName())]);
            data=ClassEventData(source,event);
            notify(obj,'evt_mouseClickedButton',data);
        end
    end

    methods (Access=protected)
        function addAction(obj)
            N=obj.getComponentCount();
            c=obj.getComponentAtIndex(N-1);
            cbk_manager=javacallbackmanager(c);
            cbk_manager.setMethodCallbackWithSource(obj,'MouseClicked');
        end
    end


end
