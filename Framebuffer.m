classdef Framebuffer < handle
    %FRAMEBUFFER Un frame buffer permet de généré une image dans une texture avant d'afficher la-dite texture
    %Cette methode permet de récupéré la projection de la souris dans la scène 3D

    properties
        FBOBuffer           %Frame Buffer Object
        FBOId               %Frame Buffer Id
        RBOBuffer           %Render Buffer Object
        RBOId               %Render Buffer Id
        TexBuffer           %Texture Buffer
        TexId               %Texture Id
        forme ElementFace   %Le carré sur lequel on affiche la texture=la scène
    end

    methods
        function obj = Framebuffer(forme)
            obj.forme = forme;
            obj.forme.textureId = 0;
        end

        function Init(obj, gl, width, height)
            obj.generateFramebuffer(gl);
            CheckError(gl, 'Erreur lors de la création du frameBuffer');
            obj.addTextureBuffer(gl, width, height);
            CheckError(gl, 'Erreur de la texture frameBuffer');
            obj.addRenderBuffer(gl, width, height);
            CheckError(gl, 'Erreur du renderbuffer du frameBuffer');
            obj.checkFrameBuffer(gl);

            obj.forme.Init(gl);

            obj.UnBind(gl);
        end

        function Resize(obj, gl, width, height)
            obj.Bind(gl);
            gl.glBindRenderbuffer(gl.GL_RENDERBUFFER, obj.FBOId);
            gl.glActiveTexture(gl.GL_TEXTURE0);
            gl.glBindTexture(gl.GL_TEXTURE_2D, obj.TexId);

            gl.glRenderbufferStorage(gl.GL_RENDERBUFFER, gl.GL_DEPTH24_STENCIL8, width, height);
            gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_RGB, width, height, 0, gl.GL_RGB, gl.GL_UNSIGNED_INT, []);
        end

        function Bind(obj, gl)
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, obj.FBOId);
        end

        function UnBind(~, gl)
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0);
        end
    end % fin des methodes defauts

    methods (Access = private)
        function generateFramebuffer(obj, gl)
            obj.FBOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenFramebuffers(1, obj.FBOBuffer);
            obj.FBOId = typecast(obj.FBOBuffer.array, 'uint32');
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, obj.FBOId);
        end % fin de generateFramebuffer

        function addTextureBuffer(obj, gl, w, h)
            obj.TexBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenTextures(1, obj.TexBuffer);
            obj.TexId = typecast(obj.TexBuffer.array(), 'uint32');
            gl.glActiveTexture(gl.GL_TEXTURE0);
            gl.glBindTexture(gl.GL_TEXTURE_2D, obj.TexId);
            gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_RGB, w, h, 0, gl.GL_RGB, gl.GL_UNSIGNED_INT, []);

        	gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR);	
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR);	
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP_TO_EDGE);
            gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP_TO_EDGE);

            gl.glFramebufferTexture2D(gl.GL_FRAMEBUFFER, gl.GL_COLOR_ATTACHMENT0, gl.GL_TEXTURE_2D, obj.TexId, 0);
        end % fin de addTextureBuffer

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
            end
        end % fin de checkRenderBuffer

    end % fin des methodes privées

end % fin classe Framebuffer