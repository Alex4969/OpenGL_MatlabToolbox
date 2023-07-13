function [pos, ind, mapping] = generatePyramide(nBase, rBase)
    %GENERATEPYRAMIDE Summary of this function goes here
    pos = zeros(nBase + 1, 3);
    ind = [];
    for i = 0:(nBase-1)
        beta = 2 * pi/(nBase) * i;
        pos(i + 1, 1:3) = [rBase * sin(beta), -1/4, rBase * cos(beta)];
        if (i+1 == nBase)
            ind = [ind i 0 nBase];
        else
            ind = [ind i i+1 nBase];
        end
        if (i > 1)
            ind = [ind 0 i-1 i];
        end
    end
    pos(nBase+1, 1:3) = [0 3/4 0];
    if (nBase == 4)
        mapping = [ 0 0 ; 1 0 ; 0 0 ; 1 0 ; 0.5 1 ];
    end
end

