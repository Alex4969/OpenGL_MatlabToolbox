classdef Scene3D < handle
    %SCENE3D la scene 3D a afficher
    
    properties
        fenetre jOGLframe   % jOGLframe contient la fenetre, un panel, le canvas, la toolbar ...
        canvas              % GLCanvas dans lequel on peut utiliser les fonction openGL
        context             % GLContext

        listeElements       % cell Array contenant les objets 3D de la scenes
        listeShaders        % dictionnaire qui lie le nom du fichier glsl a son programme
        listeTextures       % dictionnaire qui lie le nom de l'image a sa texture

        camera Camera       % instance de la camera
        lumiere Light       % instance de la lumiere
        axes Axes           % instance des axes lié au repere
        gyroscope Axes      % indication d'angle dans le repere
        grille Grid         % instance de la grille lié au repere

        cbk_manager javacallbackmanager
        startX
        startY
    end %fin de propriete defaut
    

    methods
        function obj = Scene3D(windowsSize)
            % windowsSize=[width length]
            %SCENE3D Construct an instance of this class
            %   Création du GLCanvas
            % % obj.fenetre = jframe;
            % % gp = com.jogamp.opengl.GLProfile.get(glVersion);
            % % cap = com.jogamp.opengl.GLCapabilities(gp);
            % % obj.canvas = com.jogamp.opengl.awt.GLCanvas(cap);
            % % obj.fenetre.add(obj.canvas);
            % % obj.fenetre.show();
            % % obj.canvas.setAutoSwapBufferMode(false);
            % % obj.canvas.display();

            obj.fenetre=jOGLframe('GL4',0);
            if nargin==0
                obj.fenetre.setSize([1280 1280*9/16]);
            elseif nargin==1
                obj.fenetre.setSize(windowsSize);
            else
                error('Bad argument number')
            end
            
            obj.canvas=obj.fenetre.canvas.javaObj;
            obj.context = obj.fenetre.canvas.javaObj.getContext();

            obj.camera = Camera(obj.canvas.getWidth() / obj.canvas.getHeight());
            obj.lumiere = Light([0, 3, 3], [1 1 1]);
            obj.axes = Axes(-100, 100);
            obj.gyroscope = Axes(0, 0.6);
            obj.gyroscope.setEpaisseur(4);
            obj.grille = Grid(obj.axes.getFin(), 2);

            obj.listeShaders = dictionary;
            obj.listeTextures = dictionary;

                
            % obj.context = obj.canvas.getContext();

            gl = obj.getGL();
            gl.glClearColor(0.0, 0.0, 0.4, 1.0);
            gl.glEnable(gl.GL_DEPTH_TEST);
            gl.glDepthFunc(gl.GL_LESS);
            gl.glEnable(gl.GL_BLEND);
            gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA);
            gl.glEnable(gl.GL_LINE_SMOOTH);

            obj.axes.Init(gl);
            obj.ajouterProg(obj.axes, "axis");
            obj.gyroscope.Init(gl);
            obj.ajouterProg(obj.gyroscope, "axis");
            obj.grille.Init(gl);
            obj.ajouterProg(obj.grille, "grille");

            obj.context.release();

            %Listeners
            obj.cbk_manager=javacallbackmanager(obj.canvas);
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MousePressed');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseReleased');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseWheelMoved');

            obj.cbk_manager.setMethodCallbackWithSource(obj,'KeyPressed');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');
            % addlistener(obj.fenetre.canvas,'evt_MousePressed',@obj.cbk_MousePressed);


        end % fin du constructeur de Scene3D
    end

    methods

        function cbk_MousePressed(obj,source,event)
            %disp('MousePressed')
            obj.startX=event.getPoint.getX;
            obj.startY=event.getPoint.getY;
        end

        function cbk_MouseReleased(obj,source,event)
            disp('MouseReleased')
            event.getPoint;
        end

        function cbk_MouseDragged(obj,source,event)
            %disp('MouseDragged')
            dX=(event.getPoint.getX-obj.startX);
            dY=(event.getPoint.getY-obj.startY);
            % obj.camera.setPosition(obj.camera.getPosition-[dX dY 0]);
            obj.camera.translateXY(obj.camera.speed*sign(dX),obj.camera.speed*sign(dY));
            obj.camera.getPosition
            obj.Draw();
        end

        function cbk_KeyPressed(obj,source,event)
            disp(['KeyPressed : ' event.getKeyChar  '   ascii : ' num2str(event.getKeyCode)])
            switch event.getKeyChar
                case 'l'
                    obj.camera.setPosition(obj.camera.getPosition-[obj.camera.speed 0 0]);
                case 'r'
                    obj.camera.setPosition(obj.camera.getPosition+[obj.camera.speed 0 0]);
                case 'u'
                    obj.camera.setPosition(obj.camera.getPosition+[0 obj.camera.speed 0]);
                case 'd'
                    obj.camera.setPosition(obj.camera.getPosition-[0 obj.camera.speed 0]);                    
                case 'o' %origin
                    obj.camera.defaultView;
                case 'f' %origin
                    obj.camera.upView;                    
                case 'p' %perspective/ortho
                    obj.camera.switchProjType;
            end
            obj.Draw();
        end

        function cbk_MouseWheelMoved(obj,source,event)
            disp ('MouseWheelMoved')
            obj.camera.zoom(sign(event.getWheelRotation)*obj.camera.speed*obj.camera.sensibility);
            z=obj.camera.getPosition;
            z(3)
            obj.Draw();     
        end        
    end

    methods

        function cbk_ComponentResized(obj,source,event)
            disp('ComponentResized')
            obj.cbk_manager.rmCallback('ComponentResized');
            w=source.getSize.getWidth;
            h=source.getSize.getHeight;
            disp(['ComponentResized (' num2str(w) ' ; ' num2str(h) ')'])     
            obj.Draw;
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');
        end

        function AjouterObjet(obj, elem, nPos, nColor, nTextureMapping, nNormals)
            %AJOUTEROBJET Initialise l'objet avec les fonction gl
            % puis l'ajoute a la liste d'objet a dessiner
            % 
            if (~isa(elem, 'VisibleElement'))
                disp('l objet a ajouter n est pas un VisibleElement');
                return
            end
            gl = obj.getGL();
            elem.Init(gl);
            if (nargin > 2)
                elem.setAttributeSize(nPos, nColor, nTextureMapping, nNormals);
            end
            obj.listeElements{ 1 , numel(obj.listeElements)+1 } = elem;
            obj.choixProg(elem);
            obj.context.release();
        end % fin de ajouterObjet

        function Draw(obj)
            %DRAW dessine la scene avec tous ses objets
            gl = obj.getGL();
            gl.glViewport(0, 0, obj.canvas.getWidth() , obj.canvas.getHeight());
            gl.glClear(bitor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT));

            %dessiner les objets
            for i= 1:numel(obj.listeElements)
                if (i == 1 || progAct ~= obj.listeElements{i}.shader)
                    progAct = obj.listeElements{i}.shader;
                    progAct.Bind(gl);
                    progAct.SetUniformMat4(gl, 'uCamMatrix',  obj.camera.getCameraMatrix());
                    progAct.SetUniform3f  (gl, 'uCamPos',     obj.camera.getPosition());
                    progAct.SetUniform3f  (gl, 'uLightPos',   obj.lumiere.getPosition());
                    progAct.SetUniform3f  (gl, 'uLightColor', obj.lumiere.getColor());
                    progAct.SetUniform3f  (gl, 'uLightDir',   obj.lumiere.getDirection());
                    progAct.SetUniform3f  (gl, 'uLightData',  obj.lumiere.getParam());
                end
                obj.listeElements{i}.Draw(gl);
            end

            obj.drawInternalObject(gl, obj.axes);
            obj.drawInternalObject(gl, obj.grille);
            if ~isempty(obj.lumiere.forme)
                obj.drawInternalObject(gl, obj.lumiere.forme);
            end

            %%afficher le gysmo
            gl.glViewport(0, 0, obj.canvas.getWidth()/10, obj.canvas.getHeight()/10);
            progAct = obj.gyroscope.shader;
            progAct.Bind(gl);
            gyroMatrix = MProj3D('O', [obj.canvas.getWidth()/10 obj.canvas.getHeight()/10 1 20]) * obj.camera.getviewMatrix();
            gyroMatrix(1:3, 4) = 0;
            progAct.SetUniformMat4(gl, 'uCamMatrix', gyroMatrix);
            obj.gyroscope.Draw(gl);

            obj.context.release();
            obj.canvas.swapBuffers(); % rafraichi la fenetre
        end % fin de Draw


        function drawInternalObject(obj, gl, elem)
            progAct = elem.shader;
            progAct.Bind(gl);
            progAct.SetUniformMat4(gl, 'uCamMatrix',  obj.camera.getCameraMatrix());
            elem.Draw(gl);
        end

        function delete(obj)

        function Delete(obj)
            %DELETE Supprime les objets de la scene
            disp('deleting Scene3D...')
            gl = obj.getGL();
            for i=1:numel(obj.listeElements)
                obj.listeElements{i}.Delete(gl);
            end
            if numEntries(obj.listeShaders) ~= 0
                progs = values(obj.listeShaders);
                for i=1:numel(progs)
                    progs{1}.Delete(gl);
                end
            end
            if numEntries(obj.listeTextures) ~= 0
                textures = values(obj.listeTextures);
                for i=1:numel(textures)
                    textures{1}.Delete(gl);
                end
            end
            obj.axes.Delete(gl);
            obj.grille.Delete(gl);
            obj.gyroscope.Delete(gl);
            if ~isempty(obj.lumiere.forme)
                obj.lumiere.forme.Delete(gl);
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

        function AddTexture(obj, fileName)
            if (isfile("textures\" + fileName))
                gl = obj.getGL();
                tex = {Texture(gl, fileName, numEntries(obj.listeTextures))};
                obj.listeTextures(fileName) = tex;
                obj.context.release();
            else
                warning("le fichier de texture nexiste pas");
            end
        end % fin de AddTexture

        function ApplyTexture(obj, fileName, elem)
            if (isa(elem, 'ElementFace') && elem.GLGeom.nTextureMapping ~= 0)
                if (numEntries(obj.listeTextures) ~= 0 && isKey(obj.listeTextures, fileName))
                    tex = obj.listeTextures(fileName);
                    texId = tex{1}.slot;
                    elem.textureId = texId;
                    obj.ajouterProg(elem, "textured");
                else
                    elem.textureId = -1;
                    obj.ajouterProg(elem, "defaut");
                    if fileName ~= ""
                        if (isfile("textures\" + fileName))
                            obj.AddTexture(fileName);
                            obj.ApplyTexture(fileName, elem);
                        else
                            warning('la texture n existe pas');
                        end
                    end
                end
            else 
                warning('L objet donne en parametre n est pas texturable');
            end
        end % fin de ApplyTexture

        function AddGeomToLight(obj, geom)
            gl = obj.getGL();
            elem = ElementFace(geom);
            elem.Init(gl);
            obj.ajouterProg(elem, "grille");
            obj.lumiere.setForme(elem);
            obj.context.release();
        end

    end % fin des methodes defauts

    methods (Access = private)

        function gl = getGL(obj)
            if ~obj.context.isCurrent()
                obj.context.makeCurrent();
            end
            gl = obj.context.getCurrentGL();
        end % fin de getGL

        function choixProg(obj, elem)
            attrib = elem.getAttrib(); % 1x3 logical : color, mapping, normal
            if (attrib(1) == 1)
                choix = "colored";
            elseif attrib(3) == 1
                choix = "normed";
            else
                choix = "defaut";
            end
            obj.ajouterProg(elem, choix);
        end % fin de choixProg

        function ajouterProg(obj, elem, fileName)
            if (numEntries(obj.listeShaders) == 0 || isKey(obj.listeShaders, fileName) == 0)
                prog = {ShaderProgram(obj.getGL(), fileName)};
                obj.listeShaders(fileName) = prog;
                elem.shader = prog{1};
            else
                shader = obj.listeShaders(fileName);
                elem.shader = shader{1};
            end
        end % fin de ajouterProg

        function drawIntenalObject(obj, gl, elem)
            progAct = elem.shader;
            progAct.Bind(gl);
            progAct.SetUniformMat4(gl, 'uCamMatrix',  obj.camera.getCameraMatrix());
            elem.Draw(gl);
        end % fin de drawInternalObject

    end % fin des methodes privees

end % fin de la classe Scene3D