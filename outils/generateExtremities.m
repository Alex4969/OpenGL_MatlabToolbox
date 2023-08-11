function [sommetsValeurs, indices, sommetsCouleur] = generateExtremities(deb,fin,pSize)

L=(fin-deb)*pSize;
    sommetsValeurs = [  fin   0.0   0.0 ;   % 0
                        fin-L   L/2   0.0 ;   % 0
                        fin-L   -L/2   0.0 ;   % 0
                        0.0   fin   0.0 ;   % 1 
                        L/2   fin-L   0.0 ;   % 1
                        -L/2   fin-L   0.0 ;   % 1
                        0.0   0.0   fin ;   % 2
                        0.0   -L/2   fin-L; % 2
                        0.0   +L/2   fin-L];  % 2
    sommetsCouleur = [1.0 0.0 0.0 ; 1.0 0.0 0.0; 1.0 0.0 0.0 ; 0.0 1.0 0.0 ; 0.0 1.0 0.0; 0.0 1.0 0.0 ; 0.0 0.0 1.0 ; 0.0 0.0 1.0; 0.0 0.0 1.0 ];
    indices = [0 1 0 2 3 4 3 5 6 7 6 8];
end %fin de generateAxes