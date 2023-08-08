classdef Point3D<Vector3
    %classe gerant un point dans l'espace
    
    properties (SetAccess='protected',GetAccess='public')

    end
    
    methods
        %constructeur
        function obj=Point3D(p)
            if nargin ~=1
                error('one argument is attempted')
            end
            obj.setCoord(p);
        end   
               
        function transform(obj,t)
            P=t*obj;
            obj.coord=P.coord;
        end
               
        function show(obj,color)
            if ishandle(obj.h)
                delete(obj.h)
            end
            if nargin==1
                color='r';
            elseif nargin==2
            else
                error('bad number of arguments')
            end
            
            hold on
            obj.h=scatter3(obj.coord(1),obj.coord(2),obj.coord(3),...
                'o','MarkerEdgeColor','k','MarkerFaceColor',color)
            hold off
        end
        
        % operator
        function v=minus(obj,a)
            %difference 2 points = vecteur
            if isa(obj,'Point3D')
                v=Vector3D(obj.coord-a.coord);
            else
                error('argument is not a Point3D')
            end
        end
        
        function delete(obj)
            if ishandle(obj.h)
                delete(obj.h)
            end
        end
        
    end
    
end

