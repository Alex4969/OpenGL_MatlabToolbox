classdef Texture < handle
    %TEXTURE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        filePath        % string : nom du fichier avec l'extension
        textureId       % uint32 : id de la texture
        texBuffer
        slot
    end
    
    methods
        function obj = Texture(gl, fileName, slot)
            %TEXTURE 
            obj.filePath = fileName;
            obj.slot = slot;
            obj.generateTexture(gl);
        end % fin du constructeur Texture

        function Bind(obj, gl)
            gl.glActiveTexture(gl.GL_TEXTURE0 + obj.slot);
            gl.glBindTexture(gl.GL_TEXTURE_2D, obj.textureId);
        end % fin de Bind

        function Unbind(~, gl)
            gl.glBindTexture(gl.GL_TEXTURE_2D, 0);
        end

        function Delete(obj, gl)
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
                format = 3;
            else
                format = 4;
                im(:,:,4) = alpha;
            end
            im = rot90(im, -1);
            im = permute(im, [3 1:2]);
            imBuffer = java.nio.ByteBuffer.allocate(numel(im));
            imBuffer.put(im(:));
            imBuffer.rewind();
            if (format == 3)
                type = gl.GL_RGB;
                %disp('rgb')
            else
                type = gl.GL_RGBA;
                %disp('rgba')
            end
            %gl.glPixelStorei(gl.GL_UNPACK_ALIGNMENT, 1); %dans la toolbox mais visiblement pas necessaire
            gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, type, size(im, 2), size(im, 3), 0, type, gl.GL_UNSIGNED_BYTE, imBuffer);
            gl.glGenerateMipmap(gl.GL_TEXTURE_2D);
        end

    end % fin des methodes privées

end % fin classe Texture

