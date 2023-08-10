classdef Framebuffer < handle
    %FRAMEBUFFER Un frame buffer permet de généré une image dans une texture avant d'afficher la-dite texture
    %Cette methode permet de récupéré la projection de la souris dans la scène 3D

    properties
        FBOBuffer           %Frame Buffer Object
        FBOId               %Frame Buffer Id
        RBOBuffer           %Render Buffer Object
        RBOId               %Render Buffer Id
        texture Texture
    end

    methods
        function obj = Framebuffer(gl, width, height)
            obj.generateFramebuffer(gl);
            CheckError(gl, 'Erreur lors de la création du frameBuffer');
            
            obj.texture = Texture(gl, '', width, height);
            gl.glFramebufferTexture2D(gl.GL_FRAMEBUFFER, gl.GL_COLOR_ATTACHMENT0, gl.GL_TEXTURE_2D, obj.texture.textureId, 0);

            CheckError(gl, 'Erreur de la texture frameBuffer');
            obj.addRenderBuffer(gl, width, height);
            CheckError(gl, 'Erreur du renderbuffer du frameBuffer');
            obj.checkFrameBuffer(gl);

            obj.UnBind(gl);
        end % fin du constructeur Framebuffer

        % function Resize(obj, gl, width, height)
        %     obj.Bind(gl);
        %     gl.glBindRenderbuffer(gl.GL_RENDERBUFFER, obj.FBOId);
        %     gl.glActiveTexture(gl.GL_TEXTURE0);
        %     gl.glBindTexture(gl.GL_TEXTURE_2D, obj.TexId);
        % 
        %     gl.glPixelStorei(gl.GL_UNPACK_ALIGNMENT, 1);
        %     gl.glRenderbufferStorage(gl.GL_RENDERBUFFER, gl.GL_DEPTH24_STENCIL8, width, height);
        %     gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_RGB, width, height, 0, gl.GL_RGB, gl.GL_UNSIGNED_INT, []);
        % end % fin de Resize

        function Bind(obj, gl)
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, obj.FBOId);
        end

        function UnBind(~, gl)
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0);
        end

        % function screenShot(obj, gl, w, h)
        %     gl.glBindFramebuffer(gl.GL_FRAMEBUFFER,obj.FBOId);
        %     buffer = java.nio.ByteBuffer.allocate(3 * w * h);
        %     gl.glReadPixels(0, 0, w, h, gl.GL_RGB, gl.GL_UNSIGNED_BYTE, buffer);
        %     img = typecast(buffer.array, 'uint8');
        %     img = reshape(img, [3 w h]);
        %     img = permute(img,[2 3 1]);
        %     img = rot90(img);
        %     imshow(img);
        % end % fin de screenShot
    end % fin des methodes defauts

    methods (Access = private)
        function generateFramebuffer(obj, gl)
            obj.FBOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenFramebuffers(1, obj.FBOBuffer);
            obj.FBOId = typecast(obj.FBOBuffer.array, 'uint32');
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, obj.FBOId);
        end % fin de generateFramebuffer

        function addRenderBuffer(obj, gl, w, h)
            obj.RBOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenRenderbuffers(1, obj.RBOBuffer);
            obj.RBOId = typecast(obj.RBOBuffer.array, 'uint32');
            gl.glBindRenderbuffer(gl.GL_RENDERBUFFER, obj.FBOId);

            gl.glRenderbufferStorage(gl.GL_RENDERBUFFER, gl.GL_DEPTH24_STENCIL8, w, h);
            gl.glFramebufferRenderbuffer(gl.GL_FRAMEBUFFER, gl.GL_DEPTH_STENCIL_ATTACHMENT, gl.GL_RENDERBUFFER, obj.RBOId);
        end % fin de addRenderBuffer

        function checkFrameBuffer(~, gl)
            fboStatus = gl.glCheckFramebufferStatus(gl.GL_FRAMEBUFFER);
            if (fboStatus ~= gl.GL_FRAMEBUFFER_COMPLETE)
                warning('frame buffer  mal construit');
            % else 
            %     disp('frameBuffer OK !');
            end
        end % fin de checkRenderBuffer

    end % fin des methodes privées
end % fin classe Framebuffer