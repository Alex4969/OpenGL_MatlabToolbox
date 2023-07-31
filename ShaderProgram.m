classdef ShaderProgram < handle
    %SHADERPROGRAM Compile un programme
    
    properties
        filePath            % string : le nom du fichier sans extension
        shaderProgId        % uint32 : id de la texture

        mapUniformLocation  % char -> int32 : associe un nom d'uniform (variable GLSL) a sa location
    end
    
    methods

        function obj = ShaderProgram(gl, nLayout, ind) %ind = 'D' dur, 'L' lisse, 'S' sans lumiere
            obj.mapUniformLocation = containers.Map('KeyType','char','ValueType','int32');
            obj.shaderProgId = gl.glCreateProgram();
            motCle(1) = "POS" + nLayout(1);
            if nLayout(2) > 0
                motCle(2) = "COL" + nLayout(2);
            elseif nLayout(3) > 0
                motCle(2) = "TEX";
            else
                motCle(2) = "DEF";
            end
            if ind == 'S'
                obj.createProgNoLight(gl, motCle);
            else
                if ind == 'L' && nLayout(4) > 0 
                    bSmooth = true;
                    motCle(3) = "NORM";
                else
                    bSmooth = false;
                end
                obj.createProgWithLight(gl, motCle, bSmooth)
            end
            gl.glLinkProgram(obj.shaderProgId);
            gl.glValidateProgram(obj.shaderProgId);
            CheckError(gl, 'erreur de compilation des shaders');
        end % fin du constructeur ShaderProgram

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
        end % fin de findLocation

        function createProgWithLight(obj, gl, motCle, bSmooth)
            srcVert = obj.readIfContains("shaders/all.vert.glsl", motCle);
            if bSmooth == 1
                srcVert = srcVert + obj.readIfContains("shaders/allSmooth.vert.glsl", motCle);
                obj.compileFile(gl, gl.GL_VERTEX_SHADER, srcVert);
            else
                srcVert = srcVert + obj.readIfContains("shaders/allSharp.vert.glsl", motCle);
                obj.compileFile(gl, gl.GL_VERTEX_SHADER, srcVert);
                %affichage avec normal aux faces, il faut générer les normales dans un geometry shaders
                srcGeom = obj.readIfContains("shaders/all.geom.glsl", motCle);
                obj.compileFile(gl, gl.GL_GEOMETRY_SHADER, srcGeom);
            end

            srcFrag = obj.readIfContains("shaders/all.frag.glsl", motCle);
            srcFrag = srcFrag + fileread("shaders/light.frag.glsl");
            obj.compileFile(gl, gl.GL_FRAGMENT_SHADER, srcFrag);
        end % fin de create Program

        function createProgNoLight(obj, gl, motCle)
            srcVert = obj.readIfContains("shaders/noLight.vert.glsl", motCle);
            obj.compileFile(gl, gl.GL_VERTEX_SHADER, srcVert);

            srcFrag = obj.readIfContains("shaders/noLight.frag.glsl", motCle);
            obj.compileFile(gl, gl.GL_FRAGMENT_SHADER, srcFrag);
        end % fin de create Program

        function src = readIfContains(~, filePath, keyWords)
            src = "";
            fId = fopen(filePath);
            while ~feof(fId)
                tline = fgets(fId);
                if contains(tline, "//")
                    if contains(tline, keyWords)
                        src = src + tline;
                    end 
                else
                    src = src + tline;
                end
            end
            fclose(fId);
        end % fin de readIfContains

        function compileFile(obj, gl, type, src)
            shaderId = gl.glCreateShader(type);
            gl.glShaderSource(shaderId, 1, src, []);
            gl.glCompileShader(shaderId);
            gl.glAttachShader(obj.shaderProgId, shaderId);
            gl.glDeleteShader(shaderId);
        end %fin de compileFile
    end % fin des methodes privées
end % fin classe ShaderProgram