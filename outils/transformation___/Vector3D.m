classdef Vector3D<Vector3
    %classe gerant un point dans l'espace
    
    properties (SetAccess='protected',GetAccess='public')

    end
    
    methods
        %constructeur
        function obj=Vector3D(u,P1)
            if nargin==1
                %coordonnees du vecteur
                obj.setCoord(u);
            elseif nargin==2
                %les arguments sont des Point3D
                if isa(u,'Point3D') && isa(u,'Point3D')
                    v=P1-u;
                    obj.coord=v.coord;
                else
                    error('arguments are not Point3D')
                end
            else
                error('one argument is attempted')
            end
            
        end    
               
%         function transform(obj,t)
%             P=Point3D(obj.coord);
%             Pt=t*P;
%             obj.coord=Pt.coord;
%         end
        
%         function newVecteur3D=copy(obj)
%             newVecteur3D=Vector3D(obj.coord);
%         end
        
        function show(obj,P,color)
            if ishandle(obj.h)
                delete(obj.h)
            end
            
            if nargin==2
                color='r';
            elseif nargin==3
            else
                error('bad number of arguments')
            end
            
            hold on
            obj.h=quiver3(P.x,P.y,P.z,obj.coord(1),obj.coord(2),obj.coord(3),0,...
                'color',color,'LineWidth',2);
            hold off
            
        end
 
        function r=norm(obj)
            %norme
            r=norm(obj.coord);
        end        
        
        function v=getUnit(obj)
            %retourne un vecteur unitaire
            v=Vector3D(obj.coord/obj.norm);
        end
        
        function normalize(obj)
            %normalise le vecteur
                obj.coord=obj.coord/obj.norm;
        end
        
        function delete(obj)
            if ishandle(obj.h)
                delete(obj.h)
            end
        end        
        
        % operator
        function v=minus(obj,u)
            %difference de 2 vecteurs
            if isa(u,'Vector3D') || isa(u,'Vector3Dl')
                v=Vector3D(u.coord-obj.coord);
            else
                error('argument is not a Vector3D')
            end
        end
        
        function v=plus(obj,u)
            %somme de 2 vecteurs
            if isa(u,'Vector3D') || isa(u,'Vector3Dl')
                v=Vector3D(u.coord+obj.coord);
            else
                error('argument is not a Vector3D')
            end
        end     
               
        function v=times(obj,u)
            %produit terme a termede 2 vecteurs
            if isa(u,'Vector3D') || isa(u,'Vector3Dl')
                v=Vector3D(u.coord.*obj.coord);
            else
                error('argument is not a Vector3D')
            end
        end        
        
        function v=rdivide(obj,u)
            %division terme a terme de 2 vecteurs
            if isa(u,'Vector3D') || isa(u,'Vector3Dl')
                v=Vector3D(u.coord./obj.coord);
            else
                error('argument is not a Vector3D')
            end
        end    
        
        function v=transpose(obj)
            %difference 2 points = vecteur
            v=obj.coord';
        end            
        
    end
    
end

