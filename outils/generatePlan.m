function [pos, ind, mapping] = generatePlan(largeur, hauteur)
    pos = [largeur/2  hauteur/2  0 ;
           largeur/2 -hauteur/2  0 ;
          -largeur/2 -hauteur/2  0 ;
          -largeur/2  hauteur/2  0 ];
    ind = [0 2 1  2 0 3];
    mapping = [1 1 ; 1 0 ; 0 0 ; 0 1];
end