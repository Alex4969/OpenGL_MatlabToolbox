classdef ShaderProgram < handle
    %SHADERPROGRAM Compile un programme
    
    properties
        fileName
        shaderProgId
    end
    
    methods

        function obj = ShaderProgram(gl, fileName)
            obj.fileName = fileName;
            obj.shaderProgId = gl.glCreateProgram();

            obj.compileFile(gl, gl.GL_VERTEX_SHADER, "shaders/" +  fileName + ".vert.glsl");
            obj.compileFile(gl, gl.GL_FRAGMENT_SHADER, "shaders/" +  fileName + '.frag.glsl');
            obj.compileFile(gl, gl.GL_GEOMETRY_SHADER, "shaders/" +  fileName + '.geom.glsl');

            gl.glLinkProgram(obj.shaderProgId);
            gl.glValidateProgram(obj.shaderProgId);
        end % fin du constructeur ShaderProgram

        function compileFile(obj, gl, type, nomFichier)
            shaderId = gl.glCreateShader(type);
            src = fileread(nomFichier);
            gl.glShaderSource(shaderId, 1, src, []);
            gl.glCompileShader(shaderId);
            gl.glAttachShader(obj.shaderProgId, shaderId);
            gl.glDeleteShader(shaderId);
        end %fin de compileFile

        function Bind(obj, gl)
            gl.glUseProgram(obj.shaderProgId);
        end

        function Delete(obj, gl)
            %DELETE Supprime l'objet de la mémoire
            gl.glDeleteProgram(obj.shaderProgId);
        end % fin de Delete

    end % fin des méthodes defauts

end % fin classe ShaderProgram