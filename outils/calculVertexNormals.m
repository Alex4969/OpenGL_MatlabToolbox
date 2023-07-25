% function Normales = calculVertexNormals(pos, ind)
% %CALCULVERTEXNORMALS Summary of this function goes here
% %   Detailed explanation goes here
%     Normales = zeros(size(pos));
%     cote = cell(size(pos,1), 1);
%     for i = 1:size(ind,2)
%         triangle = ind(1:3, i);
%         for j = 1:size(triangle,1)
%             liste = cote{triangle(j)};
%             liste = [liste triangle(mod(j, 3) + 1) triangle(mod(j+1, 3) + 1)];
%             cote{triangle(j)} = liste;
%         end
%     end
% 
%     for i = 1:size(cote, 1)
%         liste = cote{i};
%         liste = unique(liste);
% 
%         moy = pos(liste, 1:3);
%         moy = mean(moy);
%         Normales(i, :) = pos(i, :) - moy;
%     end
% end
function normales = calculVertexNormals(pos, ind)
    if(min(ind) == 0)
        ind = ind+1;
    end
    nombreTriangles = numel(ind)/3;
    nombreSommets   = size(pos,1);
    listeNormalesVoisins = cell(nombreSommets, 1);
    for i=1:nombreTriangles
        base = (i-1)*3;
        a = pos(ind(base+1), 1:3);
        b = pos(ind(base+2), 1:3);
        c = pos(ind(base+3), 1:3);
        NormaleTriangle = cross(b-a, c-a);
        tailleNormaleTriangle = norm(NormaleTriangle);
        angle(1) = atan2(tailleNormaleTriangle,dot(b-a,c-a));
        angle(2) = atan2(tailleNormaleTriangle,dot(a-b,c-b));
        angle(3) = atan2(tailleNormaleTriangle,dot(a-c,b-c));
        NormaleTriangle = NormaleTriangle / tailleNormaleTriangle;
        for j=1:3
            liste = listeNormalesVoisins{ind(base+j)};
            liste = [liste ; NormaleTriangle * angle(j)];
            listeNormalesVoisins{ind(base+j)} = liste;
        end
    end
    normales = zeros(nombreSommets, 3);
    for i=1:nombreSommets
        normalesVoisins = listeNormalesVoisins{i};
        normale = mean(normalesVoisins);
        normales(i, 1:3) = normale/vecnorm(normale);
    end
end