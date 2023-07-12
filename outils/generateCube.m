function [pos, ind, mapping] = generateCube()
%GENERATECUBE Summary of this function goes here
    pos = [ -1 -1 -1 ;
             1 -1 -1 ;
             1 -1  1 ;
            -1 -1  1 ;
            -1  1 -1 ;
             1  1 -1 ;
             1  1  1 ;
            -1  1  1 ];
    ind = [0 3 2  0 2 1  0 3 7  0 7 4  0 1 5  0 5 4  6 7 3  6 3 2  6 2 1  6 1 5  6 4 7  6 5 4];
    mapping = [0 0 ; 1 0 ; 1 1 ; 0 1 ; 0 1 ; 0 0 ; 1 0 ; 1 1];
end

