classdef Scene3D < handle
    %SCENE3D la scene 3D a afficher
    
    properties
        fenetre             % JFrame dans lequel il y a ce canvas
        canvas              % GLCanvas dans lequel on peut utiliser les fonction openGL
        context             % GLContext

        couleurFond         % Couleur du fond (matrice 1x4)
    end %fin de propriete defaut
    
    methods
        function obj = Scene3D(glVersion, jframe)
            %SCENE3D Construct an instance of this class
            %   Création du GLCanvas
            obj.fenetre = jframe;
            gp = com.jogamp.opengl.GLProfile.get(glVersion);
            cap = com.jogamp.opengl.GLCapabilities(gp);
            obj.canvas = com.jogamp.opengl.awt.GLCanvas(cap);
            obj.fenetre.add(obj.canvas);
            obj.fenetre.show();
            obj.canvas.setAutoSwapBufferMode(false);
            obj.canvas.display();

            obj.context = obj.canvas.getContext();

            obj.couleurFond = [0.0 1 0.2 1];

            gl = obj.getGL();
            gl.glClearColor(obj.couleurFond(1), obj.couleurFond(2), obj.couleurFond(3), obj.couleurFond(4));
            gl.glEnable(gl.GL_DEPTH_TEST);
            gl.glDepthFunc(gl.GL_LESS);
            gl.glEnable(gl.GL_BLEND);
            gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA);
            gl.glEnable(gl.GL_LINE_SMOOTH);
        end % fin du constructeur de Scene3D

        function Draw(obj)
            %DRAW dessine la scene avec tous ses objets
            gl = obj.getGL();
            gl.glClear(bitor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT));

            %dessiner les objets

            obj.context.release();
            obj.canvas.swapBuffers(); % rafraichi la fenetre
        end % fin de Draw
    end % fin des methodes defauts

    methods (Access = private)
        function gl = getGL(obj)
            if ~obj.context.isCurrent()
                obj.context.makeCurrent();
            end
            gl = obj.context.getCurrentGL();
        end
    end % fin des methodes privees
end % fin de la classe Scene3D