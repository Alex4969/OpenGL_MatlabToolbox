function [sommetsValeurs, indices, sommetsCouleur] = generateAxis(deb, fin)
    sommetsValeurs = [  deb   0.0   0.0 ;   % 0
                        fin   0.0   0.0 ;   % 1
                        0.0   deb   0.0 ;   % 2 
                        0.0   fin   0.0 ;   % 3
                        0.0   0.0   deb ;   % 4
                        0.0   0.0   fin ];  % 5
    sommetsCouleur = [1.0 0.0 0.0 ; 1.0 0.0 0.0 ; 0.0 1.0 0.0 ; 0.0 1.0 0.0 ; 0.0 0.0 1.0 ; 0.0 0.0 1.0 ];
    indices = [0 1 2 3 4 5];
end %fin de generateAxes