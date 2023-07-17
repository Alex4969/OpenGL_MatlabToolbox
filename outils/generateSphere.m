function [posBoule, indBoule, mapping] = generateSphere(nPointsHauteur, nPointsCercle, angleMax, rayon)
%GENERATESPERE genere une sphere avec nPointsHauteur sur le demi-cercle
%nPointsCercle pour chaque cercle
    if nargin < 3
        angleMax = 2 * pi;
    end
    if nargin < 4
        rayon = 1;
    end
    nPointsCercle = nPointsCercle + 1; % on fait superposer un point a chaque fois pour les textures
    indBoule = [];
    posBoule = zeros(nPointsCercle * nPointsHauteur, 3);
    mapping = zeros(nPointsCercle * nPointsHauteur, 2);
    for i=0:(nPointsHauteur-1)
        alpha = pi/(nPointsHauteur-1) * i;
        z = cos(alpha) * rayon;
        r = sqrt(rayon*rayon - (z*z));
        for j = 0:(nPointsCercle-1)
            base = i*nPointsCercle;
            beta = angleMax/(nPointsCercle-1) * j;
            posBoule(base + j + 1, 1:3) = [r * cos(beta), z, r * sin(beta)];
            mapping(base + j + 1, 1:2) = [ 1-(j/(nPointsCercle-1))  i/(nPointsHauteur-1)];
            if (j + 1 ~= nPointsCercle) % par ce que le dernier point superpose le premier !
                if i == 0
                    indBoule = [indBoule j nPointsCercle+j+1 nPointsCercle+j];
                elseif i == (nPointsHauteur-2)
                    indBoule = [indBoule base+j base+j+1 base+nPointsCercle+j];
                elseif i ~= (nPointsHauteur-1)
                    indBoule = [indBoule base+j base+j+1 base+nPointsCercle+j];
                    indBoule = [indBoule base+j+1 base+nPointsCercle+j+1 base+nPointsCercle+j];
                end
            end
        end
    end
end

