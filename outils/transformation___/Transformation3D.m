classdef Transformation3D < matlab.mixin.Copyable %& matlab.mixin.SetGet
    % geometrical transformation
    
    properties(SetAccess='protected',GetAccess='public')
        M; %transformation courante matrix (rad)
    end
    
    methods
        function obj=Transformation3D(M)
            %disp('Constructeur : Transformation3D')    

            if nargin==0
                obj.setIdentity;
            elseif nargin==1
                obj.setMatrix(M);
            else
                error([class(obj) ': Bad number of argument'])
            end         
        end
    end

    %
    methods
               
        % modification of homogeneous matrix
        function setMatrix(obj,M)
            if obj.isHomogeneousMatrix(M)
                obj.M=M;
            else
                error('Argument is not a 4x4 matrix')
            end            
        end        
               
        % set identity
        function setIdentity(obj)
            obj.M=eye(4);
        end
        
        % set identity
        function M=getMatrix(obj)
            M=obj.M;
        end

        % get RTS : decomposition in matrix : Rotation, Translation and Scaling
        function [R,T,S]=getRTS(obj)
            %https://math.stackexchange.com/questions/237369/given-this-transformation-matrix-how-do-i-decompose-it-into-translation-rotati/417813
            T=eye(4); T(1:3,4)=obj.M(1:3,4);
            sx=norm(obj.M(1:3,1));
            sy=norm(obj.M(1:3,2));
            sz=norm(obj.M(1:3,3));
            S=eye(4); S(1,1)=sx;S(2,2)=sy;S(3,3)=sz;
            R=obj.M(1:3,1:3);
            R(1:3,1)=R(1:3,1)/sx;
            R(1:3,2)=R(1:3,2)/sy;
            R(1:3,3)=R(1:3,3)/sz;
        end
        
        % get Angle from XYZ rotation R : R=Rz*Ry*Rx
        function [Angle]=getAngleFromXYZRotation(obj)
            R=obj.getRTS;
            
            if R(3,1)<1
                if R(3,1)>-1
                    thetaY=asin(-R(3,1));
                    thetaZ=atan2(R(2,1),R(1,1));
                    thetaX=atan2(R(3,2),R(3,3));
                else %M31=-1
                    thetaY=pi/2;
                    thetaZ=-atan2d(R(2,3),R(2,2));
                    thetaX=0;
                end
            else %M31=1
                thetaY=-pi/2;
                thetaZ=atan2d(-R(2,3),R(2,2));
                thetaX=0;
            end
            Angle=[thetaX thetaY thetaZ];
            disp(['(thetaX = ' num2str(thetaX) 'rad | thetaY = ' num2str(thetaY) 'rad | thetaZ = ' num2str(thetaZ) 'rad)'])
            disp(['(thetaX = ' num2str(rad2deg(thetaX)) '° | thetaY = ' num2str(rad2deg(thetaY)) '° | thetaZ = ' num2str(rad2deg(thetaZ)) '°)'])            
        end
        
        % get equivalent rotation angle and axis 
        function [Angle,Axis]=getAngleAndAxisRotation(obj)
            %https://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToAngle/index.htm
            EPSILON=0.01;
            EPSILON2=0.1;
            R=obj.getRTS;R=R(1:3,1:3);
            if (abs(R(1,2)-R(2,1))<EPSILON) && (abs(R(1,3)-R(3,1))<EPSILON) && (abs(R(2,3)-R(3,2))<EPSILON)
                if sum(sum((R-eye(3))<EPSILON2))==9 
                    Angle=0;
                    Axis=[];%indefinite
                    return;
                end
                Angle=pi/2;
                xx=(R(1,1)+1)/2;
                yy=(R(2,2)+1)/2;
                zz=(R(3,3)+1)/2;
                xy=(R(1,2)+R(2,1))/4;
                xz=(R(1,3)+R(3,1))/4;
                yz=(R(2,3)+R(2,3))/4;
                if ((xx>yy) && (xx>zz))
                    if xx<EPSILON
                        Axis(1)=0;Axis(2)=sqrt(2)/2;Axis(3)=sqrt(2)/2;
                    else
                        Axis(1)=sqrt(xx);Axis(2)=xy/Axis(1);Axis(3)=xz/Axis(1);
                    end
                elseif yy>zz
                    if yy<EPSILON
                        Axis(1)=sqrt(2)/2;Axis(2)=0;Axis(3)=sqrt(2)/2;
                    else
                        Axis(2)=sqrt(yy);Axis(1)=xy/Axis(2);Axis(3)=yz/Axis(2);
                    end    
                else
                    if zz<EPSILON
                        Axis(1)=sqrt(2)/2;Axis(2)=sqrt(2)/2;Axis(3)=0;
                    else
                        Axis(3)=sqrt(zz);Axis(1)=xz/Axis(3);Axis(3)=yz/Axis(3);
                    end 
                end
                return;
                
            end
            Angle=acos((R(1,1)+R(2,2)+R(3,3)-1)/2);
            s=sqrt((R(3,2)-R(2,3))^2+(R(1,3)-R(3,1))^2+(R(2,1)-R(1,2))^2);
            
            Axis(1)=(R(3,2)-R(2,3))/s;
            Axis(2)=(R(1,3)-R(3,1))/s;
            Axis(3)=(R(2,1)-R(1,2))/s;
        end
        
        % multiplying object
        function r=mtimes(obj,T)
            if ~obj.isIdentity
                if isa(T,'Transformation3D')
                    r=Transformation3D();
                    r.M=obj.M*T.M;
                    %A tester
    %             elseif isa(T,'Point3D')
    %                 r=obj.M*[T.coord;1];
    %                 r=r(1:3);
    %                 r=Point3D(r);
    %             elseif isa(T,'Vector3D')
    %                 r1=obj.M*[0;0;0;1];
    %                 r2=obj.M*[T.coord;1];
    %                 r=r2-r1;
    %                 r=r(1:3);
    %                 r=Vector3D(r);
    %             elseif isa(T,'Vector3Dl')
    %                 r=obj.M*[T.coord;1];
    %                 r=r(1:3);
    %                 r=Vector3Dl(T.attachedPoint.coord,r);                
    %             elseif isnumeric(T) && size(T,1)==3 && size(T,2)>=1 && size(T,2)~=3  
    %                 % points en ligne, coordonnees en colonnes
    %                 n=size(T,2);
    %                 r=zeros(3,n);
    %                 for i=1:n
    %                     r1=obj.M*[T(:,i);1];
    %                     r(:,i)=r1(1:3);
    %                 end
                elseif isnumeric(T) && size(T,1)>=1 && size(T,2)==3                
                        % matrix nx3 : n number of points
                        n=size(T,1);
                        r=zeros(n,3);
                        for i=1:n
                            r1=obj.M*[T(i,:)';1];
                            r(i,:)=r1(1:3)';
                        end
                else
                    r=-1;
                    warning('Wrong input parameter')
                end
            else
                r=T;
            end            
        end

        % set identity
        function r=isIdentity(obj)
            r=isequal(obj.M,eye(4));
        end
                
        %% OBSOLETE
         % modification of 
        function modifyTransformation(obj,M)
            if isa(obj,'Transformation3D')
                if obj.isHomogeneousMatrix(M)
                    obj.M=M;
                else
                    error('Argument is not a 4x4 matrix')
                end
            else
                error(['Modification is not allowed for ' class(obj) ' class'])
            end
        end

        function setMatrice(obj,M)
            if obj.isHomogeneousMatrix(M)
                obj.M=M;
            else
                error('Argument is not a 4x4 matrix')
            end            
        end  
         
    end

    %constructors
    methods
        % get inverse
        function I=inverseTransform(obj)
            I=Transformation3D(inv(obj.M));
        end         

    end
    
    methods (Access=protected) 
        
        function r=isHomogeneousMatrix(obj,M)
            if isnumeric(M) && isequal(size(M),size(eye(4)))
                r=true;
            else
                r=false;
            end
        end        
    end

    
end



