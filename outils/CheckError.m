function CheckError(gl, message) % revele tous les drapeau d'erreur qui ont été levé jusqu'ici
    err = gl.glGetError();
    if (err > 0)
        warning(message)
    end
    while err > 0
        softwarn(['GL Error 0x' dec2hex(err,4)])
        err = gl.glGetError();
    end
end

function softwarn(str)
    % https://undocumentedmatlab.com/articles/another-command-window-text-color-hack
    disp(['[' 8 str ']' 8]);
end