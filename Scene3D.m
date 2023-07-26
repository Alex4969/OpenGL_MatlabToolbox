classdef Scene3D < handle
    %SCENE3D la scene 3D a afficher
    
    properties
        fenetre jOGLframe   % jOGLframe contient la fenetre, un panel, le canvas, la toolbar ...
        canvas              % GLCanvas dans lequel on peut utiliser les fonction openGL
        context             % GLContext
        framebuffer Framebuffer

        mapElements         % map contenant les objets 3D de la scenes
        listeShaders        % dictionnaire qui lie le nom du fichier glsl a son programme
        mapTextures         % dictionnaire qui lie le nom de l'image a sa texture
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
        selectObject
    end %fin de propriete defaut
    

    methods
        function obj = Scene3D(windowSize)
            obj.fenetre=jOGLframe('GL4',0);
            if nargin == 0
                obj.fenetre.setSize([1280 1280*9/16]);
            elseif nargin == 1
                obj.fenetre.setSize(windowSize);
            else
                error('Bad argument number')
            end
            
            obj.canvas=obj.fenetre.canvas.javaObj;
            obj.canvas.setAutoSwapBufferMode(false);
            obj.canvas.display();
            obj.context = obj.fenetre.canvas.javaObj.getContext();

            obj.camera = Camera(obj.canvas.getWidth() / obj.canvas.getHeight());
            obj.lumiere = Light([0, 3, 3], [1 1 1]);
            
            obj.generateInternalObject(); % axes, gyroscope, grille & framebuffer

            obj.mapElements = containers.Map('KeyType','int32','ValueType','any');
            obj.mapTextures = containers.Map('KeyType','char', 'ValueType', 'any');
            obj.selectObject = struct('id', 0, 'couleur', [1 0.6 0 1], 'epaisseur', 6);
            obj.listeShaders = dictionary;

            gl = obj.getGL();
            gl.glClearColor(0.0, 0.0, 0.4, 1.0);
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
            obj.framebuffer.Init(gl, obj.canvas.getWidth(), obj.canvas.getHeight());
            obj.ajouterProg(obj.framebuffer.forme, "framebuffer");

            obj.context.release();

            %Listeners
            obj.cbk_manager=javacallbackmanager(obj.canvas);
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MousePressed');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseReleased');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseWheelMoved');

            obj.cbk_manager.setMethodCallbackWithSource(obj,'KeyPressed');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');

        end % fin du constructeur de Scene3D

        function AjouterObjet(obj, elem)
            %AJOUTEROBJET Initialise l'objet avec les fonction gl
            %puis l'ajoute a la liste d'objet a dessiner
            if (~isa(elem, 'VisibleElement'))
                disp('l objet a ajouter n est pas un VisibleElement');
                return
            end
            gl = obj.getGL();
            elem.Init(gl);
            obj.mapElements(elem.getId()) = elem;
            %obj.listeElements{ 1 , numel(obj.listeElements)+1 } = elem;
            obj.choixProg(elem);
            obj.context.release();
        end % fin de ajouterObjet

        function AjouterTexte(obj, elem)
            disp('depracated') % a refaire
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

        function Draw(obj)
            %DRAW dessine la scene avec tous ses objets
            gl = obj.getGL();
            obj.framebuffer.Bind(gl);

            gl.glClear(bitor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT));
            gl.glEnable(gl.GL_DEPTH_TEST);

            %%afficher le gysmo
            gl.glViewport(0, 0, obj.canvas.getHeight()/10, obj.canvas.getHeight()/10);
            progAct = obj.gyroscope.shader;
            progAct.Bind(gl);
            gyroMatrix = MProj3D('O', [1 1 1 20]) * obj.camera.getViewMatrix();
            gyroMatrix(1:3, 4) = 0;
            progAct.SetUniformMat4(gl, 'uCamMatrix', gyroMatrix);
            obj.gyroscope.Draw(gl);

            gl.glViewport(0, 0, obj.canvas.getWidth(), obj.canvas.getHeight());

            %dessiner les objets interne puis utilisateurs
            obj.drawInternalObject(gl, obj.axes);
            obj.drawInternalObject(gl, obj.grille);
            if ~isempty(obj.lumiere.forme)
                obj.drawInternalObject(gl, obj.lumiere.forme);
            end
            
            listeElem = obj.orderElem();
            for i= 1:numel(listeElem)
                elem = listeElem{i};
                if (i == 1 || progAct ~= elem.shader)
                    progAct = elem.shader;
                    progAct.Bind(gl);
                    progAct.SetUniformMat4(gl, 'uCamMatrix',  obj.camera.getCameraMatrix());
                    progAct.SetUniform3f  (gl, 'uCamPos',     obj.camera.getPosition());
                    progAct.SetUniform3f  (gl, 'uLightPos',   obj.lumiere.getPosition());
                    progAct.SetUniform3f  (gl, 'uLightColor', obj.lumiere.getColor());
                    progAct.SetUniform3f  (gl, 'uLightDir',   obj.lumiere.getDirection());
                    progAct.SetUniform3f  (gl, 'uLightData',  obj.lumiere.getParam());
                end
                elem.Draw(gl);
            end
            for i=1:numel(obj.listeTextes)
                elem = obj.listeTextes{i};
                if i == 1
                    progAct = elem.shader;
                    progAct.Bind(gl);
                end
                if elem.type == 'F'
                    %progAct.SetUniformMat4(gl, 'uCamMatrix',  eye(4)); %%%TODO a refaire
                    progAct.SetUniformMat4(gl, 'uCamMatrix', obj.camera.getProjMatrix);
                else
                    progAct.SetUniformMat4(gl, 'uCamMatrix',  obj.camera.getCameraMatrix());
                end
                if elem.type == 'N'
                %     [theta, phi] = obj.camera.getRotationAngles();
                %     disp("theta" + theta)
                %     newRot = MRot3D([(theta*180/pi - 90), (-phi*180/pi) , 0]); % 
                %     elem.setModelMatrix(newRot);

                    [thetaX, thetaY, thetaZ] = obj.camera.getRotationAngles();

                    Angle=[thetaX thetaY thetaZ] * 180 / pi;
                    disp(['(thetaX = ' num2str(rad2deg(thetaX)) '° | thetaY = ' num2str(rad2deg(thetaY)) '° | thetaZ = ' num2str(rad2deg(thetaZ)) '°)'])
                    newModel = MRot3D([-Angle(1),-Angle(2), 0]);
                    elem.setModelMatrix(newModel);

                end
                elem.Draw(gl);
            end

            obj.framebuffer.UnBind(gl);
            gl.glDisable(gl.GL_DEPTH_TEST);
            progAct = obj.framebuffer.forme.shader;
            progAct.Bind(gl);
            obj.framebuffer.forme.Draw(gl);


            obj.context.release();
            obj.canvas.swapBuffers(); % rafraichi la fenetre
        end % fin de Draw

        function delete(obj)
            %DELETE Supprime les objets de la scene
            disp('deleting Scene3D...')
            gl = obj.getGL();
            listeElem = values(obj.mapElements);
            for i=1:numel(listeElem)
                listeElem{i}.delete(gl);
            end
            if numEntries(obj.listeShaders) ~= 0
                progs = values(obj.listeShaders);
                for i=1:numel(progs)
                    progs{1}.delete(gl);
                end
            end
            if numEntries(obj.mapTextures) ~= 0
                textures = values(obj.mapTextures);
                for i=1:numel(textures)
                    textures{1}.delete(gl);
                end
            end
            obj.axes.delete(gl);
            obj.grille.delete(gl);
            obj.gyroscope.delete(gl);
            if ~isempty(obj.lumiere.forme)
                obj.lumiere.forme.delete(gl);
            end
            obj.context.release();
        end % fin de delete

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

        function ApplyTexture(obj, elem, fileName)
            %APPLYTEXTURE ajoute la texture avec le nom de fichier donné a
            %l'element. si le fichier n'existe pas, la texture est retiré.
            if (isa(elem, 'ElementFace') && elem.GLGeom.nLayout(3) ~= 0)
                slot = obj.getTextureId(fileName, false);
                elem.textureId = slot;
                if slot == -1
                    obj.ajouterProg(elem, "defaut");
                else
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
            if (attrib(2) == 1)
                choix = "colored";
            elseif attrib(4) == 1
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

        function drawInternalObject(obj, gl, elem)
            progAct = elem.shader;
            progAct.Bind(gl);
            progAct.SetUniformMat4(gl, 'uCamMatrix',  obj.camera.getCameraMatrix());
            elem.Draw(gl);
        end % fin de drawInternalObject

        function slot = getTextureId(obj, fileName, texte)
            %GETTEXTUREID Renvoie l'id de la texture correspondant au fichier.
            % si elle n'existe pas, elle est créée.
            if nargin < 3, texte = false; end
            if texte
                dossier = "textes\";
            else
                dossier = "textures\";
            end
            if isKey(obj.mapTextures, fileName)
                %la texture a deja été ajouté :
                slot = obj.mapTextures(fileName).slot;
            else
                if isfile(dossier + fileName)
                    slot = length(obj.mapTextures) + 1;
                    tex = Texture(obj.getGL(), dossier + fileName, slot);
                    obj.mapTextures(fileName) = tex;
                    obj.context.release();
                else
                    slot = -1;
                end
            end
        end

        function generateInternalObject(obj)
            tailleAxe = 50;
            [pos, idx, color] = Axes.generateAxes(-tailleAxe, tailleAxe);
            axesGeom = Geometry(-1, pos, idx);
            obj.axes = Axes(axesGeom, -tailleAxe, tailleAxe);
            obj.axes.AddColor(color);

            tailleGysmo = 0.5;
            [pos, idx, color] = Axes.generateAxes(0, tailleGysmo);
            gysmoGeom = Geometry(-2, pos, idx);
            obj.gyroscope = Axes(gysmoGeom, 0, tailleGysmo);
            obj.gyroscope.setEpaisseur(4);
            obj.gyroscope.AddColor(color);

            [pos, idx] = Grid.generateGrid(obj.axes.getFin(), 2);
            grilleGeom = Geometry(-3, pos, idx);
            obj.grille = Grid(grilleGeom, obj.axes.getFin(), 2);

            [pos, idx, mapping] = generatePlan(2, 2);
            planGeom = Geometry(0, pos, idx);
            frameBufferPlan = ElementFace(planGeom);
            frameBufferPlan.AddMapping(mapping);
            obj.framebuffer = Framebuffer(frameBufferPlan);
        end % fin de generateInternalObject

        function worldCoord = getWorldCoord(obj, clickPos)
            gl = obj.getGL();
            obj.framebuffer.Bind(gl);

            r = 1; % click radius (square box) px
            w = 2*r+1; % square side length px

            buffer = java.nio.FloatBuffer.allocate(w*w);

            sz = [obj.canvas.getWidth() ; obj.canvas.getHeight()];
            clickPos(2) = sz(2) - clickPos(2);
            gl.glReadPixels(clickPos(1)-r, clickPos(2)-r, w, w, gl.GL_DEPTH_COMPONENT, gl.GL_FLOAT, buffer);
            profondeur = typecast(buffer.array(), 'single');

            n = (profondeur == 1);

            if all(n, "all")
                worldCoord = 0;
                disp('le lancer n a pas touché de cible');
            else
                profondeur(n) = nan; % pourquoi ?
                profondeur = rot90(profondeur);

                [m, k] = min(profondeur(:));
                [y, x] = ind2sub([w, w], k);
                NDC = [ (clickPos + [x-r-0.5 ; r-y+1.5])./sz ; m ; 1 ].*2 - 1; % coordonnées dans un cube -1 -> 1

                worldCoord = obj.camera.getProjMatrix * obj.camera.getViewMatrix \ NDC;
                worldCoord = worldCoord(1:3)./worldCoord(4);
                worldCoord = worldCoord';
            end
            obj.context.release();
        end % fin de getWorldCoord

        function listeTrie = orderElem(obj)
            %ORDERELEM : trie les objet du plus loin au plus pres, indispensable pour la transparence
            listeTrie = values(obj.mapElements);
            distance  = zeros(1, numel(listeTrie));
            for i=1:numel(listeTrie)
                distance(i) = norm(listeTrie{i}.getPosition() - obj.camera.getPosition());
            end
            [~, newOrder] = sort(distance, 'descend');
            listeTrie = listeTrie(newOrder);
        end % fin de orderElem

        function elem = getPointedObject(obj, mouseCoord)
            listeElem = values(obj.mapElements);
            distance = zeros(1, numel(listeElem));
            for i=1:numel(listeElem)
                distance(i) = norm(listeElem{i}.getPosition() - mouseCoord);
            end
            [~, idx] = min(distance);
            elem = listeElem{idx};
        end % fin de getPointedObject

        function colorSelection(obj, elem)
            if obj.selectObject.id ~= 0
                obj.selectObject = obj.mapElements(obj.selectObject.id).reverseSelect(obj.selectObject);
            end
            if elem.getId() == obj.selectObject.id
                obj.selectObject.id = 0;
            else
                obj.selectObject = elem.reverseSelect(obj.selectObject);
            end
        end
                
    end % fin des methodes privees

    % callback
    methods
        function cbk_MousePressed(obj,source,event)
            %disp('MousePressed')
            obj.startX=event.getPoint.getX();
            obj.startY=event.getPoint.getY();
            obj.mouseButton = event.getButton();
            
            if obj.mouseButton == 1
                worldCoord = obj.getWorldCoord([obj.startX; obj.startY]);
                disp(worldCoord)
                if numel(worldCoord) == 3
                    elem = obj.getPointedObject(worldCoord);
                    obj.colorSelection(elem);
                    obj.Draw();
                end
            end
        end

        function cbk_MouseReleased(obj,source,event)
            disp('MouseReleased')
        end

        function cbk_MouseDragged(obj,source,event)
            obj.cbk_manager.rmCallback('MouseDragged');
            %disp(event.getButton());
            %disp('MouseDragged')
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
            %disp(['KeyPressed : ' event.getKeyChar  '   ascii : ' num2str(event.getKeyCode)])
            redraw = true;
            switch event.getKeyChar()
                case 'x'
                    obj.camera.xorConstraint([true false false])
                case 'y'
                    obj.camera.xorConstraint([false true false])
                case 'z'
                    obj.camera.xorConstraint([false false true])
                case 'o' %origin
                    obj.camera.defaultView;
                case 'u' %up
                    obj.camera.upView;                    
                case 'p' %perspective/ortho
                    obj.camera.switchProjType;
                case char(27)
                    if obj.selectObject.id ~= 0
                        obj.selectObject = obj.mapElements(obj.selectObject.id).reverseSelect(obj.selectObject);
                        obj.selectObject.id = 0;
                    end
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
            obj.framebuffer.Resize(obj.getGL(), w, h);
            obj.Draw();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');
        end
    end % fin des methodes callback

end % fin de la classe Scene3D