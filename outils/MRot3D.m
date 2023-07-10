function M = MRot3D(angleParAxe)
% input : [angleSurX angleSurY angleSurZ]
% en degre
    angleParAxe = angleParAxe * pi/180;
    ax = angleParAxe(1);
    ay = angleParAxe(2);
    az = angleParAxe(3);

    M = eye(4);

    if (ax ~= 0)
        matX = [ 1        0        0        0 ;
                 0        cos(ax) -sin(ax)  0 ;
                 0        sin(ax)  cos(ax)  0 ;
                 0        0        0        1 ];
        M = M * matX;
    end

    if (az ~= 0) 
        matZ = [ cos(az)  -sin(az) 0        0 ;
                 sin(az)  cos(az)  0        0 ;
                 0        0        1        0 ;
                 0        0        0        1 ];
        M = M * matZ;
    end

    if (ay ~= 0)
        matY = [ cos(ay)  0        -sin(ay) 0 ;
                 0        1        0        0 ;
                 sin(ay)  0        cos(ay)  0 ;
                 0        0        0        1 ];
        M = M * matY;
    end
end

