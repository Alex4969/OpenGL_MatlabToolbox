
if M(3,1)<1
    if M(3,1)>-1
        thetaY=asin(-M(3,1));
        thetaZ=atan2(M(2,1),M(1,1));
        thetaX=atan2(M(3,2),M(3,3));
    else %M31=-1
        thetaY=pi/2;
        thetaZ=-atan2d(M(2,3),M(2,2));
        thetaX=0;
    end
else %M31=1
    thetaY=-pi/2;
    thetaZ=atan2d(-M(2,3),M(2,2));
    thetaX=0;
end
disp(['(thetaX = ' num2str(thetaX) 'rad | thetaY = ' num2str(thetaY) 'rad | thetaZ = ' num2str(thetaZ) 'rad)'])
disp(['(thetaX = ' num2str(rad2deg(thetaX)) '° | thetaY = ' num2str(rad2deg(thetaY)) '° | thetaZ = ' num2str(rad2deg(thetaZ)) '°)'])