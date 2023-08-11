classdef Scene3D < handle
    %SCENE3D la scene 3D a afficher
    
    properties
        fenetre jOGLframe   % jOGLframe contient la fenetre, un panel, le canvas, la toolbar ...
        canvas              % GLCanvas dans lequel on peut utiliser les fonction openGL
        context             % GLContext
        pickingTexture Framebuffer % contient l'image 2D de la scène a afficher

        mapElements containers.Map  % map contenant les objets 3D de la scenes
        mapGroups   containers.Map  % map contenant les ensembles

        camera Camera       % instance de la camera
        lumiere Light       % instance de la lumiere
        axesId int32        % instance des axes lié au repere
        gyroscopeId int32   % indication d'angle dans le repere
        grilleId int32      % instance de la grille lié au repere

        cbk_manager javacallbackmanager
        startX              % position x de la souris lorsque je clique
        startY              % position y de la souris lorsque je clique
        mouseButton = -1    % numéro du bouton sur lequel j'appuie (1 = gauche, 2 = mil, 3 = droite)
        selectObject        % struct qui contient les données de l'objets selectionné
        couleurFond
    end %fin de propriete defaut
    
    events
        evt_update
    end

    methods
        function obj = Scene3D(windowSize)
            obj.fenetre = jOGLframe('GL4',0);
            if nargin == 0
                obj.fenetre.setSize([1280 1280*9/16]);
            elseif nargin == 1
                obj.fenetre.setSize(windowSize);
            else
                error('Bad argument number')
            end
            
            obj.canvas = obj.fenetre.canvas.javaObj;
            obj.canvas.setAutoSwapBufferMode(false);
            obj.canvas.display();
            obj.context = obj.fenetre.canvas.javaObj.getContext();

            obj.mapElements = containers.Map('KeyType','int32','ValueType','any');
            obj.mapGroups   = containers.Map('KeyType','int32','ValueType','any');
            obj.selectObject = struct('id', 0, 'couleur', [1 0.6 0 1], 'epaisseur', 6);

            gl = obj.getGL();
            gl.glViewport(0, 0, obj.canvas.getWidth(), obj.canvas.getHeight());
            obj.couleurFond = [0, 0, 0.4, 1.0];
            obj.setCouleurFond(obj.couleurFond);
            gl.glDepthFunc(gl.GL_LESS);
            gl.glEnable(gl.GL_LINE_SMOOTH);
            gl.glEnable(gl.GL_BLEND);
            gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA);
            gl.glEnable(gl.GL_DEPTH_TEST);
            % gl.glEnable(gl.GL_CULL_FACE); % optimisation : supprime l'affichage des faces arrieres

            obj.camera = Camera(gl, obj.canvas.getWidth() / obj.canvas.getHeight());
            obj.lumiere = Light(gl);
            obj.generateInternalObject(); % axes, gyroscope, grille & framebuffer

            %Listeners
            obj.cbk_manager = javacallbackmanager(obj.canvas);
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MousePressed');
            %obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseReleased');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseWheelMoved');

            obj.cbk_manager.setMethodCallbackWithSource(obj,'KeyPressed');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');

            addlistener(obj,'evt_update',@obj.cbk_update);
        end % fin du constructeur de Scene3D

        function elem = AddComponent(obj, comp)
            if ~isa(comp, 'GeomComponent')
                warning('pas possible d ajouter un objet de ce type');
                return
            end
            gl = obj.getGL();
            if isKey(obj.mapElements, comp.id)
                warning('Id deja existante remplace l ancient element');
            end
            switch (comp.type)
                case 'face'
                    elem = ElementFace(gl, comp);
                case 'ligne'
                    elem = ElementLigne(gl, comp);
                case 'point'
                    elem = ElementPoint(gl, comp);
                case 'texte'
                    elem = ElementTexte(gl, comp);
            end
            obj.mapElements(elem.getId()) = elem;
            addlistener(elem,'evt_update',@obj.cbk_update);
            obj.removeGL();
        end % fin de ajouterGeom

        function group = CreateGroup(obj, groupId)
            group = Ensemble(groupId);
            obj.mapGroups(groupId) = group;
        end % fin de createGroup

        function elem = RemoveComponent(obj, elemId) % element et texte
            if isKey(obj.mapElements, elemId)
                elem = obj.mapElements(elemId);
                remove(obj.mapElements, elemId);
            else
                disp('objet a supprimé n existe pas');
            end
        end % fin de RemoveComponent

        function DrawScene(obj)
            %DRAW dessine la scene avec tous ses objets
            gl = obj.getGL();
            obj.lumiere.remplirUbo(gl);
            obj.camera.remplirUbo(gl);
            gl.glClear(bitor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT));

            camAttrib = obj.camera.getAttributes();
            %dessin des objets ajouter a la scene
            listeElem = obj.orderElem();
            for i=1:numel(listeElem)
                elem = listeElem{i};
                elem.Draw(gl, camAttrib);
            end

            obj.removeGL();
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
            Texture.DeleteAll(gl);
            obj.removeGL();
        end % fin de delete

        function setCouleurFond(obj, newColor)
            %SETCOULEURFOND change la couleur du fond de l'écran.
            %Peut prendre en entrée une matrice 1x3 (rgb) ou 1x4 (rgba)
            if (numel(newColor) == 3)
                newColor(4) = 1;
            end
            if numel(newColor) == 4
                gl = obj.getGL();
                obj.couleurFond = newColor;
                gl.glClearColor(newColor(1), newColor(2), newColor(3), newColor(4));
            else
                warning('Le format de la nouvelle couleur n est pas bon, annulation');
            end
            notify(obj,'evt_update');
        end % fin setCouleurFond
    end % fin des methodes defauts

    methods (Access = private)
        function gl = getGL(obj)
            if ~obj.context.isCurrent()
                obj.context.makeCurrent();
            end
            gl = obj.context.getCurrentGL();
        end % fin de getGL

        function removeGL(obj)
            if obj.context.isCurrent()
                obj.context.release();
            end
        end

        function generateInternalObject(obj)
            obj.axesId = -1;
            tailleAxe = 50;
            [pos, idx, color] = generateAxis(-tailleAxe, tailleAxe);
            axesGeom = MyGeom(obj.axesId, pos, idx, 'ligne');
            elem = obj.AddComponent(axesGeom);
            elem.AddColor(color);

            obj.grilleId = -2;
            [pos, idx] = generateGrid(tailleAxe, 2);
            grilleGeom = MyGeom(obj.grilleId, pos, idx, 'ligne');
            elem = obj.AddComponent(grilleGeom);
            elem.setEpaisseur(1);
            elem.setCouleur([0.3 0.3 0.3]);

            obj.gyroscopeId = -3;
            tailleGysmo = 1;
            [pos, idx, color] = generateAxis(0, tailleGysmo);
            gysmoGeom = MyGeom(obj.gyroscopeId, pos, idx, 'ligne');
            elem = obj.AddComponent(gysmoGeom);
            elem.AddColor(color);
            elem.typeOrientation = 4;
            elem.setEpaisseur(4);

            obj.pickingTexture = Framebuffer(obj.getGL(), obj.canvas.getWidth(), obj.canvas.getHeight());
        end % fin de generateInternalObject

        function listeTrie = orderElem(obj)
            %ORDERELEM : trie les objet du plus loin au plus pres, indispensable pour la transparence
            listeTrie = values(obj.mapElements);
            distance  = zeros(1, numel(listeTrie));
            for i=1:numel(listeTrie)
                if listeTrie{i}.typeOrientation >= 4 %ortho ou fixe
                    distance(i) = 0;
                else
                    distance(i) = norm(listeTrie{i}.getPosition() - obj.camera.getPosition());
                end
            end
            [~, newOrder] = sort(distance, 'descend');
            listeTrie = listeTrie(newOrder);
        end % fin de orderElem

        function [elemId, worldCoord] = pickObject(obj)
            gl = obj.getGL();

            % resize & bind frameBuffer
            w = obj.canvas.getWidth();
            h = obj.canvas.getHeight();
            x = obj.startX;
            y = h - obj.startY;
            obj.pickingTexture.Resize(gl, w, h);

            %create programme d'id
            shader3D = ShaderProgram(gl, [3 0 0 0], "id");
            shader2D = ShaderProgram(gl, [2 0 0 0], "id");

            %trier les objets
            listeElem = obj.orderElem();

            %dessiner les objets uniquement sur le pixel qui nous interresse
            camAttrib = obj.camera.getAttributes();
            gl.glEnable(gl.GL_SCISSOR_TEST);
            gl.glScissor(x, y, 1, 1);
            if obj.couleurFond(1) > 0
                gl.glClearColor(0, 0, 0, 0);
            end
            gl.glClear(bitor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT));
            for i=1:numel(listeElem)
                elem = listeElem{i};
                if elem.GLGeom.is2D
                    oldShader = elem.setShader(gl, shader2D);
                else
                    oldShader = elem.setShader(gl, shader3D);
                end
                elem.DrawId(gl, camAttrib);
                elem.setShader(gl, oldShader);
            end
            shader2D.delete(gl);
            shader3D.delete(gl);

            %lire le pixel de couleurs -> obtenir l'id
            buffer = java.nio.IntBuffer.allocate(1);
            gl.glReadPixels(x, y, 1, 1, gl.GL_RED_INTEGER, gl.GL_INT, buffer);
            elemId = typecast(buffer.array(), 'int32');

            %lire la valeur de profondeur -> position du monde
            gl.glReadPixels(x, y, 1, 1, gl.GL_DEPTH_COMPONENT, gl.GL_FLOAT, buffer);
            profondeur = typecast(buffer.array(), 'single');

            if profondeur == 1
                worldCoord = 0;
                disp('le lancer n a pas touché de cible');
            else
                NDC = [ x/w ; y/h ; profondeur ; 1 ].*2 - 1; % coordonnées dans l'écran -1 -> 1

                worldCoord = obj.camera.getProjMatrix * obj.camera.getViewMatrix \ NDC;
                worldCoord = worldCoord(1:3)./worldCoord(4);
                worldCoord = worldCoord';
            end
            %unbind le frameBuffer, remise des parametre de la scene
            obj.pickingTexture.UnBind(gl);
            gl.glDisable(gl.GL_SCISSOR_TEST);
            if obj.couleurFond(1) > 0
                obj.setCouleurFond(obj.couleurFond);
            end
            obj.removeGL();
        end

        function screenShot(~, gl, w, h)
            disp('capture en cours...')
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER,0);
            buffer = java.nio.ByteBuffer.allocate(3 * w * h);
            gl.glReadPixels(0, 0, w, h, gl.GL_RGB, gl.GL_UNSIGNED_BYTE, buffer);
            img = typecast(buffer.array, 'uint8');
            img = reshape(img, [3 w h]);
            img = permute(img,[2 3 1]);
            img = rot90(img);
            imshow(img);
        end % fin de screenShot
    end % fin des methodes privees

    methods % callback
        function cbk_MousePressed(obj, ~, event)
            %disp('MousePressed')
            obj.startX=event.getPoint.getX();
            obj.startY=event.getPoint.getY();
            obj.mouseButton = event.getButton();

            if obj.mouseButton == 1
                [elemId, worldCoord] = obj.pickObject();
                obj.fenetre.setTextRight(['ID = ' num2str(elemId) '  ']);
                disp(worldCoord)
            
                % if numel(worldCoord) == 3
                %     mod = event.getModifiers();
                %     if mod==18 %CTRL LEFT CLICK
                %         %obj.colorSelection(elem);
                %     elseif mod==24 %ALT LEFT CLICK
                %         obj.camera.setTarget(worldCoord);
                %     end
                %     obj.DrawScene;
                % end
            end
        end

        function cbk_MouseReleased(~,~,~)
            disp('MouseReleased')
        end

        function cbk_MouseDragged(obj, ~, event)
            obj.cbk_manager.rmCallback('MouseDragged');
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
                obj.camera.translatePlanAct(dx/obj.canvas.getWidth(),dy/obj.canvas.getHeight());
            else
                if (obj.mouseButton == 3)
                    obj.camera.rotate(dx/obj.canvas.getWidth(),dy/obj.canvas.getHeight());
                end
            end
            if (obj.lumiere.onCamera == true)
                obj.lumiere.setPositionCamera(obj.camera.position, obj.camera.target);
            end
            obj.DrawScene();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
        end

        function cbk_KeyPressed(obj, ~, event)
            % disp(['KeyPressed : ' event.getKeyChar  '   ascii : ' num2str(event.getKeyCode)])
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
                case 'f' %up
                    obj.camera.faceView;    
                case 'p' %perspective/ortho
                    obj.camera.switchProjType;
                case '+' %increase cam speed
                    obj.camera.speed=min(100,obj.camera.speed+1);
                case '-' %decrease cam speed
                    obj.camera.speed=max(5,obj.camera.speed-1);                   
                case char(27) % ECHAP
                    if obj.selectObject.id ~= 0
                        obj.selectObject = obj.mapElements(obj.selectObject.id).reverseSelect(obj.selectObject);
                        obj.selectObject.id = 0;
                    end
                case char(127) % SUPPR
                    if obj.selectObject.id ~= 0
                        obj.RemoveComponent(obj.selectObject.id);
                        obj.selectObject = struct('id', 0, 'couleur', [1 0.6 0 1], 'epaisseur', 6);
                    end
               case 'i'
                     obj.pickingTexture.screenShot(obj.getGL, obj.canvas.getWidth(), obj.canvas.getHeight());
                otherwise
                    redraw = false;
            end
            if redraw
                obj.DrawScene();
            end
        end

        function cbk_MouseWheelMoved(obj, ~,event)
            obj.cbk_manager.rmCallback('MouseWheelMoved');
            obj.camera.zoom(event.getWheelRotation());
            if obj.lumiere.onCamera == true
                obj.lumiere.setPositionCamera(obj.camera.position, obj.camera.target);
            end
            obj.DrawScene();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseWheelMoved');
        end
    
        function cbk_ComponentResized(obj, source, ~)
            obj.cbk_manager.rmCallback('ComponentResized');
            w=source.getSize.getWidth;
            h=source.getSize.getHeight;
            %disp(['ComponentResized (' num2str(w) ' ; ' num2str(h) ')'])
            gl = obj.getGL();
            gl.glViewport(0, 0, w, h);
            obj.camera.setRatio(w/h);
            obj.DrawScene();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');
        end

        function cbk_update(obj, ~, ~)
            disp('cbk_Update');
            obj.DrawScene;
        end
    end % fin des methodes callback
end % fin de la classe Scene3D