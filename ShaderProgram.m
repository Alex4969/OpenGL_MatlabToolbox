classdef ShaderProgram < handle
    %SHADERPROGRAM Compile un programme
    
    properties
        fileName
        shaderProgId

        mapUniformLocation
    end
    
    methods

        function obj = ShaderProgram(gl, fileName)
            obj.fileName = fileName;
            obj.mapUniformLocation = containers.Map('KeyType','char','ValueType','int32');
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

        function SetUniform4f(obj, gl, nom, attrib)
            location = obj.findLocation(gl, nom);
            gl.glUniform4f(location, attrib(1), attrib(2), attrib(3), attrib(4));
        end % fin de setUniform4f

        function SetUniform3f(obj, gl, nom, attrib)
            location = obj.findLocation(gl, nom);
            gl.glUniform3f(location, attrib(1), attrib(2), attrib(3));
        end % fin de setUniform4f

        function SetUniformMat4(obj, gl, nom, matrix)
            matUni = java.nio.FloatBuffer.allocate(16);
            matUni.put(matrix(:));
            matUni.rewind();
            location = obj.findLocation(gl, nom);
            gl.glUniformMatrix4fv(location, 1, gl.GL_FALSE, matUni);
        end

    end % fin des méthodes defauts

    methods (Access = private)

        function location = findLocation(obj, gl, nom)
            if (isKey(obj.mapUniformLocation, nom))
                location = obj.mapUniformLocation(nom);
            else 
                location = gl.glGetUniformLocation(obj.shaderProgId, nom);
                if (location == -1)
                    warning(['uniform ' nom 'na pas ete trouve dans le shader']);
                end
                obj.mapUniformLocation(nom) = location;
            end
        end % fin findLocation

    end % fin des methodes privées

end % fin classe ShaderProgram