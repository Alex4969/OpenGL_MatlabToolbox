function [posBoule, indBoule] = generateSpere(nPointsHauteur, nPointsCercle)
%GENERATESPERE Summary of this function goes here
%   Detailed explanation goes here
    indBoule = [];
    posBoule = zeros(nPointsCercle * nPointsHauteur, 3);
    for i=0:(nPointsHauteur-1)
        alpha = pi/nPointsHauteur * i;
        z = cos(alpha);
        r = sqrt(1 - (z*z));
        for j = 0:(nPointsCercle-1)
            base = i*nPointsCercle;
            beta = 2 * pi/nPointsCercle * j;
            posBoule(base + j + 1, 1:3) = [r * cos(beta), r * sin(beta), z];
            indBoule = [indBoule base+j base+nPointsCercle+j base+j+1];
            indBoule = [indBoule base+j+1 base+nPointsCercle+j base+nPointsCercle+j+1];
        end
    end
end

