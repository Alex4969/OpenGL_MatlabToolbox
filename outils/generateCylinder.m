function [pos, ind, mapping, norm] = generateCylinder(nPointsCercle, angleMax, rayon, hauteur, ferme)
%GENERATECYLINDER genere un cylinder avec nPointsCercle par cercle
%angle pour avoir des d
    if nargin < 2
        angleMax = 2 * pi;
    elseif angleMax > 2*pi
        warning('angle trop grand !');
        angleMax = 2*pi;
    end
    if nargin < 3, rayon = 1;   end
    if nargin < 4, hauteur = 1; end
    if nargin < 5, ferme = 0;   end
    hauteur = hauteur / 2;
    nPointsCercle = nPointsCercle + 1; % on fait superposer un point a chaque fois pour les textures
    ind = [];
    pos = zeros(nPointsCercle * 2, 3);
    norm = zeros(nPointsCercle * 2, 3);
    mapping = zeros(nPointsCercle * 2, 2);
    for j = 0:(nPointsCercle-1)
        beta = angleMax/(nPointsCercle-1) * j;
        pos    (j + 1, 1:3)                 = [rayon * cos(beta), -hauteur, rayon * sin(beta)];
        pos    (nPointsCercle + j + 1, 1:3) = [rayon * cos(beta),  hauteur, rayon * sin(beta)];
        norm   (j + 1, 1:3)                 = [cos(beta), 0, sin(beta)];
        norm   (nPointsCercle + j + 1, 1:3) = [cos(beta), 0, sin(beta)];
        mapping(j + 1, 1:2)                 = [(j/(nPointsCercle-1))  0];
        mapping(nPointsCercle + j + 1, 1:2) = [(j/(nPointsCercle-1))  1];
        if j~=0
            ind = [ind j j-1 nPointsCercle+j-1    j nPointsCercle+j-1 nPointsCercle+j];
        end
    end
    if ferme == 1
        for i=2:(nPointsCercle-1)
            ind = [ind 0 i-1 i nPointsCercle nPointsCercle+i-1 nPointsCercle+i];
        end
    end

end