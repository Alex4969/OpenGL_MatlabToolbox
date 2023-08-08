classdef Rotation3D_Z<Rotation3D %& matlab.mixin.Copyable
    % geometrical transformation
    
    properties
%         %R;
%         axe;
%         theta;
    end
    
    methods
        function obj=Rotation3D_Z(theta)
            
%             disp('Constructeur : Rotation3D_Z')
            obj@Rotation3D(theta,[0 0 0],[0 0 1]);
        end
          
    end
    
    methods (Access='protected')
        function M=computeMatrice(obj)
            cos_theta=cosd(obj.theta);
            sin_theta=sind(obj.theta);
            M=[cos_theta -sin_theta 0 0;
               sin_theta cos_theta 0 0;
               0 0 1 0;
               0 0 0 1];
        end
    end    
    
end