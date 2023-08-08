classdef Vector3Dl<Vector3
    %classe gerant un point dans l'espace
    
    properties (SetAccess='protected',GetAccess='public')
        attachedPoint
    end
    
    methods
        %constructeur
        function obj=Vector3Dl(P,u)
            if nargin==2
                %les arguments sont des Point3D
                if isa(P,'Point3D') && isa(u,'Vector3D')
                    obj.attachedPoint=P;
                    obj.coord=u.coord;
                elseif isnumeric(P) && isnumeric(u)
                    obj.attachedPoint=Point3D(P);
                    obj.setCoord(u);
                elseif isa(P,'Point3D') && isa(u,'Point3D')
                    obj.attachedPoint=P;
                    v=u-P;
                    obj.coord=v.coord;
                end
            else
                error('bad argument number')
            end
            
        end    
               
        function transform(obj,t)
            transform@Vector3(t);
            obj.attachedPoint=t*obj.attachedPoint;           
%             P1=obj.attachedPoint;
%             obj.attachedPoint=t*obj.attachedPoint;
%             
%             P2=Point3D(obj.coord);
%             Pt2=t*P2;           
%             obj.coord=obj.attachedPoint.coord+Pt2.coord;
        end
        
        function newVecteur3Dl=copy(obj)
            newVecteur3Dl=Vector3Dl(obj.attachedPoint.coord,obj.coord);
        end
        
        function show(obj,color,h)
            if nargin==2
                color='r';
                h=false;
            elseif nargin==3
                h=false;
            elseif nargin==4
            else
                error('bad number of arguments')
            end
                       
            obj.attachedPoint.show(color,1)
            if h
                hold on
            else
                hold off
            end

            quiver3(obj.attachedPoint.x,obj.attachedPoint.y,obj.attachedPoint.z,obj.coord(1),obj.coord(2),obj.coord(3),0,...
                'color',color,'LineWidth',2);
            if h
                hold off
            else
                hold on
            end            
        end
        
        function r=dot(obj,u)
            %produit scalaire
            if isa(u,'Vector3D') || isa(u,'Vector3Dl')
                r=u.coord(1)*obj.coord(1)+u.coord(2)*obj.coord(2)+u.coord(3)*obj.coord(3);
            else
                error('argument is not a Vector3D')
            end
        end
        
        function v=cross(obj,u)
            %produit vectoriel
            if isa(u,'Vector3D') || isa(u,'Vector3Dl')
                v=Vector3Dl(obj.attachedPoint.coord, cross(obj.coord,u.coord));
            else
                error('argument is not a Vector3D')
            end
        end
 
        function r=norm(obj)
            %norme
            r=norm(obj.coord);
        end        
        
        function v=getUnit(obj)
            %retourne un vecteur unitaire
            v=Vector3Dl(obj.attachedPoint,obj.coord/obj.norm);
        end
        
        function normalize(obj)
            %normalise le vecteur
                obj.coord=obj.coord/obj.norm;
        end
        
        
        % operator
        function v=minus(obj,u)
            %difference de 2 vecteurs
            if isa(u,'Vector3D') || isa(u,'Vector3Dl')
                v=Vector3Dl(obj.attachedPoint.coord,coord,u.coord-obj.coord);
            else
                error('argument is not a Vector3D')
            end
        end
        
        function v=plus(obj,u)
            %somme de 2 vecteurs
            if isa(u,'Vector3D') || isa(u,'Vector3Dl')
                v=Vector3Dl(obj.attachedPoint.coord,u.coord+obj.coord);
            else
                error('argument is not a Vector3D')
            end
        end     
               
        function v=times(obj,u)
            %produit terme a termede 2 vecteurs
            if isa(obj,'Vector3D') || isa(u,'Vector3Dl')
                v=Vector3Dl(obj.attachedPoint.coord,u.coord.*obj.coord);
            else
                error('argument is not a Vector3D')
            end
        end        
        
        function v=rdivide(obj,u)
            %division terme a terme de 2 vecteurs
            if isa(obj,'Vector3D') || isa(u,'Vector3Dl')
                v=Vector3Dl(obj.attachedPoint.coord,u.coord./obj.coord);
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

