function M = MRot3DbyAxe(theta, axe)
% input : [angleSurX angleSurY angleSurZ]
% en degre
    theta = deg2rad(theta);
    ux=axe(1);
    uy=axe(2);
    uz=axe(3);

    M = eye(4);


        M = [ cos(theta)+ux^2*(1-cos(theta))        ux*uy*(1-cos(theta))-uz*sin(theta)      ux*uz*(1-cos(theta))+uy*sin(theta)      0 ;
              ux*uy*(1-cos(theta))+uz*sin(theta)    cos(theta)+uy^2*(1-cos(theta))          uy*uz*(1-cos(theta))-ux*sin(theta)      0;
              ux*uz*(1-cos(theta))-uy*sin(theta)    uy*uz*(1-cos(theta))+ux*sin(theta)      cos(theta)+uz^2*(1-cos(theta))          0;
              0        0        0        1 ];


