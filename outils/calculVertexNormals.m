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