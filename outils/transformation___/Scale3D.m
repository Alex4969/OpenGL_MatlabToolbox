classdef Scale3D<Transformation3D
    % geometrical transformation
    
    properties
        ScaleFactor;
    end
    
    methods
        function obj=Scale3D(ScaleFactor)
            disp('je suis scaling')
            obj.setScaleFactor(ScaleFactor);
        end

        % set Scale factor and Matrice
        function setScaleFactor(obj,sf)          
            
            if nargin==2
                if isnumeric(sf) && ((size(sf,1)==1 && size(sf,2)==3) || (size(sf,1)==3 && size(sf,2)==1))
                    %un vecteur numerique
                    obj.ScaleFactor=sf;
                else
                    error('Bad argument(s)')
                end
            else
                error('Bad argument number')
            end
            obj.setMatrice(obj.computeMatrice);
        end
        
    end
    
    methods (Access='protected')
        function M=computeMatrice(obj)
            M=[obj.ScaleFactor(1) 0 0 0;
               0 obj.ScaleFactor(2) 0 0;
               0 0 obj.ScaleFactor(3) 0;
               0 0 0 1];
        end
    end    
    
end