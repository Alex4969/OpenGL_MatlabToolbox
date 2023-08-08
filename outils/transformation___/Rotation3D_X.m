classdef Rotation3D_X<Rotation3D %& matlab.mixin.Copyable
    % geometrical transformation
    
    properties

    end
    
    methods
        function obj=Rotation3D_X(theta)
            
            %disp('Constructeur : Rotation3D_X')
            obj@Rotation3D(theta,[0 0 0],[1 0 0]);
%             obj.theta=theta;
%             obj.P=Point3D([0;0;0]);
%             obj.V=Vector3D([1;0;0]);
%             obj.setMatrice(obj.computeMatrice);
        end    
        

    end
    
    methods (Access='protected')
        function M=computeMatrice(obj)
            cos_theta=cosd(obj.theta);
            sin_theta=sind(obj.theta);
            M=[1 0 0 0;
               0 cos_theta -sin_theta 0;
               0 sin_theta  cos_theta 0;
               0 0 0 1];
        end
    end    
    
end