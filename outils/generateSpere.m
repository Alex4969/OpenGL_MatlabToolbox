function [posBoule, indBoule] = generateSpere(nPointsHauteur, nPointsCercle)
%GENERATESPERE genere une sphere avec nPointsHauteur sur le demi-cercle
%nPointsCercle pour chaque cercle
    indBoule = [];
    posBoule = zeros(nPointsCercle * nPointsHauteur, 3);
    for i=0:(nPointsHauteur-1)
        alpha = pi/(nPointsHauteur-1) * i;
        z = cos(alpha);
        r = sqrt(1 - (z*z));
        for j = 0:(nPointsCercle-1)
            base = i*nPointsCercle;
            beta = 2 * pi/nPointsCercle * j;
            posBoule(base + j + 1, 1:3) = [r * cos(beta), r * sin(beta), z];
            if (j + 1 == nPointsCercle)
                jp = 0;
            else
                jp = j + 1;
            end
            if i == 0
                indBoule = [indBoule j nPointsCercle+j nPointsCercle+jp];
            elseif i == (nPointsHauteur-2)
                indBoule = [indBoule base+j base+nPointsCercle+j base+jp];
            elseif i~= (nPointsHauteur-1)
                indBoule = [indBoule base+j base+nPointsCercle+j base+jp];
                indBoule = [indBoule base+jp base+nPointsCercle+j base+nPointsCercle+jp];
            end
        end
    end
end

