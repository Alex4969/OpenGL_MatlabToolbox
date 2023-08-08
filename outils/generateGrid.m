function [pos, ind] = generateGrid(borne, ecart)
    if nargin < 2, ecart = borne/10; end
    if mod(borne, ecart) ~= 0 || ecart > borne
        ecart = borne/10;
        warning("mauvaise valeurs pour setGrid. Valeurs choisis : borne = " + borne + " et ecart = " + ecart);
    end
    e = ecart;
    b = borne;
    deb = [-b b b -b ; 0 0 0 0 ; -b -b b b]; % contour du carré
    i = e:e:b-e;
    taille = 2*b/e -2;
    matBorne = ones(1, taille)*b;
    matZeros = zeros(1, taille * 4);
    pos = [-matBorne matBorne -i i -i i ; matZeros ; -i i -i i -matBorne matBorne];
    pos = [deb pos];
    pos = pos';
    t = taille/2;
    ind = [0 1 1 2 2 3 3 0];
    for i=0:1:t-1
        ajout = [4+i 4+taille+i   4+t+i 4+t+taille+i   4+2*taille+i 4+2*taille+taille+i   4+2*taille+t+i 4+2*taille+taille+t+i];
        ind = [ind ajout];
    end
end % fin de generateGrid