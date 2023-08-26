classdef trajectory<handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        T0
        T1
        N
    end

    methods
        function obj = trajectory(N,T0,T1)
            if nargin==1
                obj.init();
            else
                obj.T0=T0;
                obj.T1=T1;
            end
            obj.N=N;
        end
        function init(obj)
            obj.T0=eye(4);
            T1=eye(4);
            T1([13:15])=[1 2 3];
            obj.T1=T1;
        end

        function mat = interp(obj)
            s=[0:1/double(obj.N-1):1];
            t0=obj.T0([13:15]);
            t1=obj.T1([13:15]);
            q0=tform2quat(obj.T0);
            q1=tform2quat(obj.T1);
            mat=zeros(4,4,obj.N);
            theta=acos(dot(q0,q1));%problem if theta=0
            for i=1:obj.N
                new_t=(1-s(i))*t0+s(i)*t1;
                new_q=(sin((1-s(i))*theta)*q0+sin(s(i)*theta)*q1)/sin(theta);
                R=quat2rotm(new_q);
                mat(:,:,i)=eye(4);
                mat(1:3,1:3,i)=R;
                mat([13:15]+16*(double(i)-1))=new_t;
            end

        end
    end
end