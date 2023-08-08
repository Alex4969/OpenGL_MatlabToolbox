classdef Rotation3D_Y<Rotation3D %& matlab.mixin.Copyable
    % geometrical transformation
    
    properties

    end
    
    methods
        function obj=Rotation3D_Y(theta)

%             disp('Constructeur : Rotation3D_Y')
            obj@Rotation3D(theta,[0 0 0],[0 1 0]);
        end
    end
    
    methods (Access='protected')
        function M=computeMatrice(obj)
            cos_theta=cosd(obj.theta);
            sin_theta=sind(obj.theta);
            M= [cos_theta 0 sin_theta 0;
                0 1 0 0;
                -sin_theta 0 cos_theta 0;
                0 0 0 1]; 
        end
    end
    
       
             
    end
