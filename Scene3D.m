classdef Scene3D < handle
    %SCENE3D la scene 3D a afficher
    
    properties
        fenetre             % JFrame dans lequel il y a ce canvas
        canvas              % GLCanvas dans lequel on peut utiliser les fonction openGL
        context             % GLContext
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

            gl = obj.getGL();
            gl.glClearColor(0.0, 0.0, 0.4, 1.0);
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

        function setCouleurFond(obj, newColor)
            %SETCOULEURFOND change la couleur du fond de l'écran.
            %Peut prendre en entrée une matrice 1x3 (rgb) ou 1x4 (rgba)
            if (numel(newColor) == 3)
                newColor(4) = 1;
            end
            if numel(newColor) == 4
                gl = obj.getGL();
                gl.glClearColor(newColor(1), newColor(2), newColor(3), newColor(4));
                obj.context.release();
            else
                warning('Le format de la nouvelle couleur n est pas bon');
            end
        end % fin setCouleurFond
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