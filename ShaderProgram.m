classdef ShaderProgram < handle
    %SHADERPROGRAM Compile un programme
    
    properties
        filePath            % string : le nom du fichier sans extension
        shaderProgId        % uint32 : id de la texture

        mapUniformLocation  % char -> int32 : associe un nom d'uniform (variable GLSL) a sa location
    end
    
    methods

        function obj = ShaderProgram(gl, fileName, layout)
            obj.mapUniformLocation = containers.Map('KeyType','char','ValueType','int32');
            obj.shaderProgId = gl.glCreateProgram();
            obj.filePath = "shaders/" + fileName;
            if (fileName == "all")
                obj.createProg(gl, layout, true);
            else
                obj.compileFile(gl, gl.GL_VERTEX_SHADER, fileread(obj.filePath + ".vert.glsl"));
                obj.compileFile(gl, gl.GL_FRAGMENT_SHADER, fileread(obj.filePath + ".frag.glsl"));
            end

            gl.glLinkProgram(obj.shaderProgId);
            gl.glValidateProgram(obj.shaderProgId);
            CheckError(gl, 'erreur de compilation des shaders');
        end % fin du constructeur ShaderProgram

        function compileFile(obj, gl, type, src)
            shaderId = gl.glCreateShader(type);
%            if contains(src, 'intensiteLumineuse')
 %               src2 = fileread("shaders/light.frag.glsl");
  %              src = [src  src2];
   %         end
            gl.glShaderSource(shaderId, 1, src, []);
            gl.glCompileShader(shaderId);
            gl.glAttachShader(obj.shaderProgId, shaderId);
            gl.glDeleteShader(shaderId);
        end %fin de compileFile

        function Bind(obj, gl)
            gl.glUseProgram(obj.shaderProgId);
        end

        function delete(obj, gl)
            %DELETE Supprime l'objet de la mémoire
            gl.glDeleteProgram(obj.shaderProgId);
        end % fin de delete

        function SetUniform4f(obj, gl, nom, attrib)
            location = obj.findLocation(gl, nom);
            gl.glUniform4f(location, attrib(1), attrib(2), attrib(3), attrib(4));
        end % fin de setUniform4f

        function SetUniform3f(obj, gl, nom, attrib)
            location = obj.findLocation(gl, nom);
            gl.glUniform3f(location, attrib(1), attrib(2), attrib(3));
        end % fin de setUniform3f

        function SetUniform1i(obj, gl, nom, attrib)
            location = obj.findLocation(gl, nom);
            gl.glUniform1i(location, attrib);
        end % fin de setUniform3f

        function SetUniformMat4(obj, gl, nom, matrix)
            matUni = java.nio.FloatBuffer.allocate(16);
            matUni.put(matrix(:));
            matUni.rewind();
            location = obj.findLocation(gl, nom);
            gl.glUniformMatrix4fv(location, 1, gl.GL_FALSE, matUni);
        end % fin de SetUniformMat4

    end % fin des méthodes defauts

    methods (Access = private)
        function location = findLocation(obj, gl, nom)
            if (isKey(obj.mapUniformLocation, nom))
                location = obj.mapUniformLocation(nom);
            else 
                location = gl.glGetUniformLocation(obj.shaderProgId, nom);
                if (location == -1)
                    warning(['uniform ' nom ' na pas ete trouve dans le programme']);
                else
                    obj.mapUniformLocation(nom) = location;
                end
            end
        end % fin findLocation

        function createProg(obj, gl, nLayout, bSmooth)
            motCle(1) = "POS" + nLayout(1);
            if nLayout(2) > 0
                motCle(2) = "COL" + nLayout(2);
            elseif nLayout(3) > 0
                motCle(2) = "TEX";
            else
                motCle(2) = "DEF";
            end
            if bSmooth %on veut un affichage smooth (normal au vertex)
                if nLayout(4) > 0
                    motCle(3) = "NORM";
                else
                    disp('Affichage smooth impossible pour un objet sans normales aux sommets');
                    bSmooth = false;
                end
            end
            src = "";
            fId = fopen("shaders/all.vert.glsl");
            while ~feof(fId)
                tline = fgets(fId);
                if contains(tline, "//")
                    if contains(tline, motCle)
                        src = src + tline;
                    end 
                else
                    src = src + tline;
                end
            end
            fclose(fId);
            if bSmooth
                fId = fopen("shaders/allSmooth.vert.glsl");
            else
                fId = fopen("shaders/allSharp.vert.glsl");
            end
            while ~feof(fId)
                tline = fgets(fId);
                if contains(tline, "//")
                    if contains(tline, motCle)
                        src = src + tline;
                    end 
                else
                    src = src + tline;
                end
            end
            fclose(fId);
            obj.compileFile(gl, gl.GL_VERTEX_SHADER, char(src));

            if bSmooth == 0 % shader pour calcul les normales aux faces
                src = "";
                fId = fopen("shaders/all.geom.glsl");
                while ~feof(fId)
                    tline = fgets(fId);
                    if contains(tline, "//")
                        if contains(tline, motCle)
                            src = src + tline;
                        end 
                    else
                        src = src + tline;
                    end
                end
                fclose(fId);
                obj.compileFile(gl, gl.GL_GEOMETRY_SHADER, char(src));
            end

            src = "";
            fId = fopen("shaders/all.frag.glsl");
            while ~feof(fId)
                tline = fgets(fId);
                if contains(tline, "//")
                    if contains(tline, motCle)
                        src = src + tline;
                    end 
                else
                    src = src + tline;
                end
            end
            fclose(fId);
            fId = fopen("shaders/light.frag.glsl");
            while ~feof(fId)
                tline = fgets(fId);
                src = src + tline;
            end
            fclose(fId);
            obj.compileFile(gl, gl.GL_FRAGMENT_SHADER, char(src));
        end

    end % fin des methodes privées

end % fin classe ShaderProgram