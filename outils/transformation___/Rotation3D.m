classdef Rotation3D<Transformation3D %& matlab.mixin.Copyable
    % geometrical transformation
    
    properties (SetAccess=protected, GetAccess=public)
        theta %angle en degres
        P %point3D
        V %vecteur3D
    end

    
    methods
        function obj=Rotation3D(theta,P,V)
            % theta : angle en degré
            % P un point3D ou un point numerique
            % V un vecteur3D ou un vecteur numerique
            

            %disp('Constructeur : Rotation3D')

            obj.setAngle(theta);
            if nargin==3
                obj.setPoint(P);
                obj.setVector(V);                                       
            else
                error([class(obj) ': Wrong parameter number'])
            end
           
        end
                      
        % set Angle and update Matrice
        function setAngle(obj,value)
            if nargin==2
                if isnumeric(value) && size(value,1)==1 && size(value,2)==1 
                    obj.theta=value;
                else
                    error('Bad argument')
                end
            else
                error('Bad number of arguments')
            end
            if isa(obj.P,'Point3D') && isa(obj.V,'Vector3D')
                obj.setMatrice(obj.computeMatrice);
            end
        end
               
        % set Point and update Matrice
        function setPoint(obj,p)
            if nargin==2
                if isnumeric(p) && ((size(p,1)==1 && size(p,2)==3) || (size(p,1)==3 && size(p,2)==1))
                    %un point numerique
                    obj.P=Point3D(p);
                elseif isa(p,'Point3D')
                    % 1 Point3D
                    obj.P=p;
                else
                    error('Bad argument')
                end
            else
                error('Bad number of arguments')
            end
            if ~isempty(obj.theta) && isa(obj.V,'Vector3D')
                obj.setMatrice(obj.computeMatrice);
            end
        end        
        
        % set Vector and update Matrice
        function setVector(obj,v)
            if nargin==2
                if isnumeric(v) && ((size(v,1)==1 && size(v,2)==3) || (size(v,1)==3 && size(v,2)==1))
                    %un vecteur numerique
                    obj.V=Vector3D(v);
                elseif isa(v,'Vector3D')
                    % 1 Vector3D
                    obj.V=v;
                else
                    error('Bad argument')
                end
            else
                error('Bad number of arguments')
            end
            if ~isempty(obj.theta) && isa(obj.P,'Point3D')
                obj.setMatrice(obj.computeMatrice);
            end
        end        
        
        
        
        %operators
        function r=uminus(obj)
            % -Rotation
            r=obj.copy;            
            r.setAngle(-obj.theta);
        end
    end
    
    methods (Access='protected')
        function M=computeMatrice(obj)
            cos_theta=cosd(obj.theta);
            sin_theta=sind(obj.theta);
            %v=obj.V/norm(obj.V);%normalize
            v=obj.V.getUnit;
            
            %See "Geometry Formulas and Facts", by Silvio Levy, chapter 10.1
            txx=cos_theta + (1-cos_theta)*v.x*v.x;
            txy=(1-cos_theta)*v.x*v.y - sin_theta*v.z;
            txz=(1-cos_theta)*v.x*v.z + sin_theta*v.y;
            
            tyx=(1-cos_theta)*v.y*v.x + sin_theta*v.z;
            tyy=cos_theta + (1-cos_theta)*v.y*v.y;
            tyz=(1-cos_theta)*v.y*v.z - sin_theta*v.x;
            
            tzx=(1-cos_theta)*v.z*v.x - sin_theta*v.y;
            tzy=(1-cos_theta)*v.z*v.y + sin_theta*v.x;
            tzz=cos_theta + (1-cos_theta)*v.z*v.z;
            
            M=[txx txy txz obj.P.x-txx*obj.P.x-txy*obj.P.y-txz*obj.P.z;
                tyx tyy tyz obj.P.y-tyx*obj.P.x-tyy*obj.P.y-tyz*obj.P.z;
                tzx tzy tzz obj.P.z-tzx*obj.P.x-tzy*obj.P.y-tzz*obj.P.z;
                0 0 0 1];
        end   
    end
    
end