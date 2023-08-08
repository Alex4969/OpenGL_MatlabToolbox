classdef (Abstract) Vector3< matlab.mixin.Copyable
    %classe gerant un objet a 3 coordonnees dans l'espace
    
    properties (SetAccess='protected',GetAccess='public')
        coord % en colonne
        h %handle to graphic object
    end
    
    methods
        %constructeur
        function obj=Vector3()

        end
        
        function setCoord(obj,p)
            if isnumeric(p)
                if sum(size(p)==[1 3])==2
                    p=p';
                elseif sum(size(p)==[3 1])==2
                    %this is a good point
                else
                    error('bad argument size')
                end
                obj.coord=p;
            else
                error('the argument is not a numeric')
            end
        end
        
        function P=getCoord(obj)
            P=obj.coord;
        end        
        
        function x=x(obj)
            x=obj.coord(1);
        end
        
        function y=y(obj)
            y=obj.coord(2);
        end
        
        function z=z(obj)
            z=obj.coord(3);
        end       
               
        function transform(obj,t)
            if isa(t,'Transformation3D')
                P1=Vector3D([0 0 0]);
                Pt1=t*P1;

                P2=Vector3D(obj.coord);
                Pt2=t*P2;
                
                obj.coord=Pt2.coord-Pt1.coord;
            else
                error('argument is not a Transformation3D')
            end
        end
                
        function M=middle(obj,P)
            %retourne le milieu du segment
            if isa(P,'Point3D')
                M=Point3D((P.coord+obj.coord)/2);
            else
                error('argument is not a Point3D')
            end
        end
        
        % operator
        function t=uminus(obj)
            %operateur -
            if isa(obj,'Point3D')
                t=Point3D(-obj.coord);
            elseif isa(obj,'Vector3D')
                t=Vector3D(-obj.coord);
            elseif isa(obj,'Vector3Dl')
                t=Vector3Dl(-obj.coord);
            end
        end
    end
    
end

