classdef Scene3D < handle
    %SCENE3D la scene 3D a afficher
    
    properties
        fenetre jOGLframe   % jOGLframe contient la fenetre, un panel, le canvas, la toolbar ...
        canvas              % GLCanvas dans lequel on peut utiliser les fonction openGL
        context             % GLContext

        listeElements       % cell Array contenant les objets 3D de la scenes
        listeShaders        % dictionnaire qui lie le nom du fichier glsl a son programme
        listeTextures       % dictionnaire qui lie le nom de l'image a sa texture
        listeTextes         % cellArray contenant les textes a afficher

        camera Camera       % instance de la camera
        lumiere Light       % instance de la lumiere
        axes Axes           % instance des axes lié au repere
        gyroscope Axes      % indication d'angle dans le repere
        grille Grid         % instance de la grille lié au repere

        cbk_manager javacallbackmanager
        startX              % position x de la souris lorsque je clique
        startY              % position y de la souris lorsque je clique
        mouseButton = -1    % numéro du bouton sur lequel j'appuie (1 = gauche, 2 = mil, 3 = droite)
    end %fin de propriete defaut
    

    methods
        function obj = Scene3D(windowsSize)
            obj.fenetre=jOGLframe('GL4',0);
            if nargin == 0
                obj.fenetre.setSize([1280 1280*9/16]);
            elseif nargin == 1
                obj.fenetre.setSize(windowsSize);
            else
                error('Bad argument number')
            end
            
            obj.canvas=obj.fenetre.canvas.javaObj;
            obj.canvas.setAutoSwapBufferMode(false);
            obj.canvas.display();
            obj.context = obj.fenetre.canvas.javaObj.getContext();

            obj.camera = Camera(obj.canvas.getWidth() / obj.canvas.getHeight());
            obj.lumiere = Light([0, 3, 3], [1 1 1]);
            obj.axes = Axes(-100, 100);
            obj.gyroscope = Axes(0, 0.6);
            obj.gyroscope.setEpaisseur(4);
            obj.grille = Grid(obj.axes.getFin(), 2);

            obj.listeShaders = dictionary;
            obj.listeTextures = dictionary;

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

    % callback
    methods

        function cbk_MousePressed(obj,source,event)
            %disp('MousePressed')
            obj.startX=event.getPoint.getX;
            obj.startY=event.getPoint.getY;
            obj.mouseButton = event.getButton();
        end

        function cbk_MouseReleased(obj,source,event)
            disp('MouseReleased')
        end

        function cbk_MouseDragged(obj,source,event)
            obj.cbk_manager.rmCallback('MouseDragged');
            disp(event.getButton());
            disp('MouseDragged')
            posX = event.getX();
            dx = posX - obj.startX;
            obj.startX = posX;
            posY = event.getY();
            dy = posY - obj.startY;
            obj.startY = posY;
            mod = event.getModifiers();
            ctrlPressed = bitand(mod,event.CTRL_MASK);
            if ctrlPressed
                obj.camera.translatePlanAct(3 * dx/obj.canvas.getWidth(), 3 * dy/obj.canvas.getHeight());
            else
                if (obj.mouseButton == 3)
                    obj.camera.rotate(dx/obj.canvas.getWidth(), dy/obj.canvas.getHeight());
                end
            end
            obj.Draw();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
        end

        function cbk_KeyPressed(obj,source,event)
            disp(['KeyPressed : ' event.getKeyChar  '   ascii : ' num2str(event.getKeyCode)])
            redraw = true;
            switch event.getKeyChar()
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
                otherwise
                    redraw = false;
            end
            if redraw
                obj.Draw();
            end
        end

        function cbk_MouseWheelMoved(obj,source,event)
            obj.cbk_manager.rmCallback('MouseWheelMoved');
            disp ('MouseWheelMoved')
            obj.camera.zoom(event.getWheelRotation());
            obj.Draw();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseWheelMoved');
        end
    
        function cbk_ComponentResized(obj,source,event)
            obj.cbk_manager.rmCallback('ComponentResized');
            w=source.getSize.getWidth;
            h=source.getSize.getHeight;
            disp(['ComponentResized (' num2str(w) ' ; ' num2str(h) ')'])
            obj.camera.setRatio(w/h);
            obj.Draw();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');
        end
    end

    methods

        function AjouterObjet(obj, elem, nPos, nColor, nTextureMapping, nNormals)
            %AJOUTEROBJET Initialise l'objet avec les fonction gl
            %puis l'ajoute a la liste d'objet a dessiner
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
            for i= 1:numel(obj.listeTextes)
                if i == 1
                    progAct = obj.listeTextes{i}.shader;
                    progAct.Bind(gl);
                end
                if (obj.listeTextes{i}.ortho)
                    viewMatrix = obj.camera.getviewMatrix;
                    viewMatrix(1:3, 1:3) = eye(3);
                    progAct.SetUniformMat4(gl, 'uCamMatrix',  obj.camera.getProjMatrix * viewMatrix);
                else
                    progAct.SetUniformMat4(gl, 'uCamMatrix',  obj.camera.getCameraMatrix());
                end
                obj.listeTextes{i}.Draw(gl);
            end

            obj.drawInternalObject(gl, obj.axes);
            obj.drawInternalObject(gl, obj.grille);
            if ~isempty(obj.lumiere.forme)
                obj.drawInternalObject(gl, obj.lumiere.forme);
            end

            %%afficher le gysmo
            gl.glViewport(0, 0, obj.canvas.getHeight()/10, obj.canvas.getHeight()/10);
            progAct = obj.gyroscope.shader;
            progAct.Bind(gl);
            gyroMatrix = MProj3D('O', [1 1 1 20]) * obj.camera.getviewMatrix();
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
                warning('Le format de la nouvelle couleur n est pas bon, annulation');
            end
        end % fin setCouleurFond

        function AjouterTexte(obj, elem)
            if isa(elem, "ElementTexte")
                slot = obj.getTextureId(elem.police.name + ".png", true);
                elem.textureId = slot;
                gl = obj.getGL();
                elem.Init(gl);
                obj.listeTextes{ 1 , numel(obj.listeTextes)+1 } = elem;
                obj.ajouterProg(elem, "texte");
            else
                warning('l objet donne n est pas un texte');
            end
        end

        function slot = getTextureId(obj, fileName, texte)
            %GETTEXTUREID Renvoie l'id de la texture correspondant au fichier.
            % si elle n'existe pas, elle est créée.
            if nargin < 3, texte = false; end
            if texte
                dossier = "textes\";
            else
                dossier = "textures\";
            end
            if numEntries(obj.listeTextures) ~= 0 && isKey(obj.listeTextures, fileName)
                %la texture a deja été ajouté :
                tex = obj.listeTextures(fileName);
                slot = tex{1}.slot;
            else
                if isfile(dossier + fileName)
                    gl = obj.getGL();
                    slot = numEntries(obj.listeTextures);
                    tex = {Texture(gl, dossier + fileName, slot)};
                    obj.listeTextures(fileName) = tex;
                    obj.context.release();
                else
                    slot = -1;
                end
            end
        end

        function ApplyTexture(obj, fileName, elem)
            if (isa(elem, 'ElementFace') && elem.GLGeom.nTextureMapping ~= 0)
                if fileName == ""
                    elem.textureId = -1;
                    obj.ajouterProg(elem, "defaut");
                else
                    slot = obj.getTextureId(fileName, false);
                    elem.textureId = slot;
                    obj.ajouterProg(elem, "textured");
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

        function ModifyGrid(obj, newBorne, newEcart)
            obj.grille.setGrid(obj.getGL(), newBorne, newEcart);
            obj.context.release();
        end

        function ModifyAxes(obj, newDeb, nexFin)
            obj.axes.setAxes(obj.getGL(), newDeb, nexFin);
            obj.context.release();
        end

        function AddText(obj, elem, str)
            elem.AddText(obj.getGL(), str);
        end


        function ChangeText(obj, elem, str)
            elem.ChangeText(obj.getGL(), str);
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