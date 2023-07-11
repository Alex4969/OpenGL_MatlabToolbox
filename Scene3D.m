classdef Scene3D < handle
    %SCENE3D la scene 3D a afficher
    
    properties
        fenetre             % JFrame dans lequel il y a ce canvas
        canvas              % GLCanvas dans lequel on peut utiliser les fonction openGL
        context             % GLContext

        listeElements       % cell Array contenant les objets 3D de la scenes
        listeShaders

        camera Camera       % instance de la camera
        lumiere Light       % instance de la lumiere
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

            obj.camera = Camera(obj.canvas.getWidth() / obj.canvas.getHeight());
            obj.lumiere = Light([-5, 3, -5], [1 1 1]);
                
            obj.context = obj.canvas.getContext();

            gl = obj.getGL();
            gl.glClearColor(0.0, 0.0, 0.4, 1.0);
            gl.glEnable(gl.GL_DEPTH_TEST);
            gl.glDepthFunc(gl.GL_LESS);
            gl.glEnable(gl.GL_BLEND);
            gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA);
            gl.glEnable(gl.GL_LINE_SMOOTH);

            obj.listeShaders = dictionary;
            prog = {ShaderProgram(gl, "defaut")};
            obj.listeShaders("defaut") = prog;

            obj.context.release();
        end % fin du constructeur de Scene3D

        function ajouterObjet(obj, elem)
            %AJOUTEROBJET Ajouter un objet a la liste d'objet a dessiner
            if (~isa(elem, 'VisibleElement'))
                disp('l objet a ajouter n est pas un VisibleElement');
                return
            end
            gl = obj.getGL();
            elem.Init(gl);
            obj.listeElements{ 1 , numel(obj.listeElements)+1 } = elem;
            obj.choixProg(elem);
            obj.context.release();
        end % fin de ajouterObjet

        function Draw(obj)
            %DRAW dessine la scene avec tous ses objets
            gl = obj.getGL();
            gl.glClear(bitor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT));

            %dessiner les objets
            i = 1;
            while i <= numel(obj.listeElements)
                if (i == 1 || progAct ~= obj.listeElements{i}.shader)
                    progAct = obj.listeElements{i}.shader;
                    progAct.Bind(gl);
                    lightData = obj.lumiere.GetLightInfo();
                    progAct.SetUniformMat4(gl, 'uCamMatrix', obj.camera.getCameraMatrix());
                    progAct.SetUniform3f(gl, 'uLightPos', lightData(1, 1:3));
                    progAct.SetUniform3f(gl, 'uLightColor', lightData(2, 1:3));
                end
                obj.listeElements{i}.Draw(gl);
                i = i + 1;
            end

            obj.context.release();
            obj.canvas.swapBuffers(); % rafraichi la fenetre
        end % fin de Draw

        function Delete(obj)
            %DELETE Supprime les objets de la scene
            gl = obj.getGL();
            i = 1;
            while (i <= size(obj.listeElements, 2))
                obj.listeElements{i}.Delete(gl);
                i = i+1;
            end
            obj.context.release();
        end % fin de Delete

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

        function choixProg(obj, elem)
            attrib = elem.GetAttrib();
            if (attrib(1) == 0 && attrib(2) == 0 && attrib(3) == 0)
                choix = "defaut";
            end
            obj.ajouterProg(elem, choix);
        end % fin de choixProg

        function ajouterProg(obj, elem, fileName)
            if isKey(obj.listeShaders, fileName)
                shader = obj.listeShaders(fileName);
                elem.shader = shader{1};
            else
                prog = {ShaderProgram(obj.getGL(), fileName)};
                obj.listeShaders(fileName) = prog;
            end
        end
    end % fin des methodes privees

end % fin de la classe Scene3D