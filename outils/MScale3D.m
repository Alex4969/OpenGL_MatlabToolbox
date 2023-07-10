function M = MScale3D(facteurs)
% [tailleX tailleY tailleZ]
% la taille est multiplié par la taille actuelle (relatif pas absolue)
%
% S'il n'y a qu'une composante : l'objet est agrandi dans toutes les
% dimensions
    M = eye(4);
    if(numel(facteurs) == 1)
        M = M * facteurs;
        M(4,4) = 1;
    elseif (numel(facteurs) == 3)
        M(1,1) = M(1,1) * facteurs(1, 1);
        M(2,2) = M(2,2) * facteurs(1, 2);
        M(3,3) = M(3,3) * facteurs(1, 3);
    else
        disp('pas le bon nombre d element dans la matrice d homothetie');
    end
end

