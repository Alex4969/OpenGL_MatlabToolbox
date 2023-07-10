function M = MTrans3D(vectTrans)
% [transX transY transZ]

    M = eye(4);
    M(1:3,4) = vectTrans;
end

