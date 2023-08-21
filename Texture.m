classdef Texture < handle
    %TEXTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = private)
        filePath  char      % nom du fichier avec extension
        textureId uint32    % id de la texture
        slot      uint32    % le slot OpenGL dans lequel se situe la texture (nombre limité par le GPU, minimum 16)
    end
    properties (Access = private)
        texBuffer           % java.nio.IntBuffer : necessaire pour supprimer l'objet
    end
    properties (Constant = true)
        mapTextures = containers.Map('KeyType','char', 'ValueType', 'any');
        % map qui contient les textures deja créé pour pouvoir les redonner 
        % cela permet de gérer les numéro de slot et d'optimiser
        % Cette map ne se supprime pas avec un clear all
    end
    
    methods
        function obj = Texture(gl, fileName, width, height)
            %TEXTURE
            if isempty(fileName) % sans fileName on créé une texture avec une taille donnée pour le frameBuffer
                obj.slot = 0;
                obj.generateTextureFBO(gl, width, height);
            else
                if isKey(obj.mapTextures, fileName)
                    obj.slot = obj.mapTextures(fileName).slot;
                else
                    obj.slot = length(obj.mapTextures) + 1;
                end
                obj.filePath = fileName;
                obj.generateTexture(gl);
                obj.mapTextures(fileName) = obj;
            end
        end % fin du constructeur Texture

        function Bind(obj, gl)
            gl.glActiveTexture(gl.GL_TEXTURE0 + obj.slot);
            gl.glBindTexture(gl.GL_TEXTURE_2D, obj.textureId);
        end % fin de Bind

        function Unbind(~, gl)
            gl.glBindTexture(gl.GL_TEXTURE_2D, 0);
        end

        function delete(obj, gl)
            gl.glDeleteTextures(1, obj.texBuffer);
        end
    end % fin des methodes defauts

    methods (Access = private)
        function generateTexture(obj, gl)
            obj.texBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenTextures(1, obj.texBuffer);
            obj.textureId = typecast(obj.texBuffer.array(), 'uint32');
            gl.glActiveTexture(gl.GL_TEXTURE0 + obj.slot);
            gl.glBindTexture(gl.GL_TEXTURE_2D, obj.textureId);
        	gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR);	
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR);	
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP_TO_EDGE);
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP_TO_EDGE);
            [im, ~, alpha] = imread(obj.filePath);
            if isempty(alpha)
                type = gl.GL_RGB;
            else
                type = gl.GL_RGBA;
                im(:,:,4) = alpha;
            end
            im = rot90(im, -1);
            im = permute(im, [3 1:2]);
            imBuffer = java.nio.ByteBuffer.allocate(numel(im));
            imBuffer.put(im(:));
            imBuffer.rewind();
            gl.glPixelStorei(gl.GL_UNPACK_ALIGNMENT, 1);
            gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, type, size(im, 2), size(im, 3), 0, type, gl.GL_UNSIGNED_BYTE, imBuffer);
            gl.glGenerateMipmap(gl.GL_TEXTURE_2D);
        end % fin de generateTexture

        function generateTextureFBO(obj, gl, w, h)
            % La texture du frameBuffer sert uniquement pour reperer un objet en cliquant dessus.
            % la texture contient pour chaque pixel l'id de l'élément dessiné ici
            % Au lieu dêtre une texture RGBA, c'est une texture uniquement Red
            obj.texBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenTextures(1, obj.texBuffer);
            obj.textureId = typecast(obj.texBuffer.array(), 'uint32');
            gl.glActiveTexture(gl.GL_TEXTURE0);
            gl.glBindTexture(gl.GL_TEXTURE_2D, obj.textureId);
            gl.glPixelStorei(gl.GL_UNPACK_ALIGNMENT, 1);
            gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_R32I, w, h, 0, gl.GL_RED_INTEGER, gl.GL_INT, []);

        	gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR);	
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR);	
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP_TO_EDGE);
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP_TO_EDGE);
        end % fin de generateTextureFBO

    end % fin des methodes privées

    methods (Static)
        function DeleteAll(gl)
            k = keys(Texture.mapTextures);
            for i=1:numel(k)
                cle = k{i};
                tex = Texture.mapTextures(cle);
                tex.delete(gl);
                remove(Texture.mapTextures, cle);
            end
        end
    end
end % fin classe Texture