function M = MProj3D(type,in)
% create a projection matrix (perspective, ortho, or perspective with field of view.
% [width height near far] pour ortho & perspective
% [ratio FOV    near far] pour perspective avec angle de vue (angle en degré)
% http://www.songho.ca/opengl/gl_projectionmatrix.html

    M = eye(4);
    
    switch type
        case 'P'
            % perspective
            % in = [width height near far]
            r=in(1)/2; t=in(2)/2; n=in(3); f=in(4);
            M([1 6 11 12 15 16]) = [n/r n/t (f+n)/(n-f) -1 2*f*n/(n-f) 0];
        case 'O'
            % ortho
            % in = [width height near far]
            r=in(1)/2; t=in(2)/2; n=in(3); f=in(4);
            M([1 6 11 15]) = [1/r 1/t 2/(n-f) (f+n)/(n-f)];
        case 'F'
            % perspective with fov
            % in = [aspectRatio FOV near far]
            ar=in(1); fov=in(2); n=in(3); f=in(4);
            fov=fov/180*pi;
            M([1 6 11 12 15 16]) = [1/(ar*tan(fov/2)) 1/tan(fov/2) (f+n)/(n-f) -1 2*f*n/(n-f) 0];
        otherwise
            error('invalid projection type');
    end

end

