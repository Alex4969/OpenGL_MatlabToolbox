classdef Translation3D<Transformation3D
    % geometrical transformation
    
    properties (SetAccess='protected',GetAccess='public')
        vectorT;
    end
    
    methods
        function obj=Translation3D(varargin)
            % un vecteur [1 2 3]
            % un Vecteur3D
            % 2 points [1 2 3] , [4 5 6]
            % 2 Point3D
            % si on precise un repere, il doit etre en derniere position
            disp('je suis translation')
            obj.setVector(varargin{1:end});
        end

        % set Vector and Matrice
        function setVector(obj,varargin)
            v=varargin;
            n=length(v);
            
            if n==1
                p=v{1};
                if isnumeric(p) && ((size(p,1)==1 && size(p,2)==3) || (size(p,1)==3 && size(p,2)==1))
                    %un vecteur numerique
                    obj.vectorT=Vector3D(p);
                elseif isa(p,'Vector3D')
                    % 1 Vector3D
                    obj.vectorT=p;
                else
                    error('Bad argument(s)')
                end
            elseif n==2
                p1=v{1};
                p2=v{2};
                if (isnumeric(p1) && ((size(p1,1)==1 && size(p1,2)==3) || (size(p1,1)==3 && size(p1,2)==1))) &&...
                        (isnumeric(p2) && ((size(p2,1)==1 && size(p2,2)==3) || (size(p2,1)==3 && size(p2,2)==1)))
                    %deux points numeriques
                    P1=Point3D(p1);
                    P2=Point3D(p2);
                    obj.vectorT=P2-P1;
                elseif isa(p1,'Point3D') && isa(p2,'Point3D')
                    %deux Point3D
                    obj.vectorT=p2-p1;
                else
                    error('Bad argument(s)')
                end
            else
                error('Bad argument(s) number')
            end
            
            obj.setMatrice(obj.computeMatrice);
            
        end
          
        
        % overloading operator
        function t=uminus(obj)
            p=-obj.vectorT;
            t=Translation3D(p);
        end
    end
    
    methods (Access='protected')
        function M=computeMatrice(obj)
            M=[1 0 0 0; ...
               0 1 0 0; ...
               0 0 1 0; ...
               0 0 0 1];
            M(1:3,4)=obj.vectorT.coord;
        end
    end
    
end