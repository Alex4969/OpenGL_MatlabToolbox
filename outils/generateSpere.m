function [posBoule, indBoule, mapping] = generateSpere(nPointsHauteur, nPointsCercle)
%GENERATESPERE genere une sphere avec nPointsHauteur sur le demi-cercle
%nPointsCercle pour chaque cercle
    nPointsCercle = nPointsCercle + 1; % on fait superposer un point a chaque fois pour les textures
    indBoule = [];
    posBoule = zeros(nPointsCercle * nPointsHauteur, 3);
    mapping = zeros(nPointsCercle * nPointsHauteur, 2);
    for i=0:(nPointsHauteur-1)
        alpha = pi/(nPointsHauteur-1) * i;
        z = cos(alpha);
        r = sqrt(1 - (z*z));
        for j = 0:(nPointsCercle-1)
            base = i*nPointsCercle;
            beta = 2 * pi/(nPointsCercle-1) * j;
            posBoule(base + j + 1, 1:3) = [r * cos(beta), z, r * sin(beta)];
            mapping(base + j + 1, 1:2) = [ 1-(j/(nPointsCercle-1))  i/(nPointsHauteur-1)];
            if (j + 1 == nPointsCercle)
                jp = 0;
            else
                jp = j + 1;
            end
            if i == 0
                indBoule = [indBoule j nPointsCercle+jp nPointsCercle+j];
            elseif i == (nPointsHauteur-2)
                indBoule = [indBoule base+j base+jp base+nPointsCercle+j];
            elseif i ~= (nPointsHauteur-1)
                indBoule = [indBoule base+j base+jp base+nPointsCercle+j];
                indBoule = [indBoule base+jp base+nPointsCercle+jp base+nPointsCercle+j];
            end
        end
    end
end

