classdef Scene3D < handle
    %SCENE3D la scene 3D a afficher
    
    properties
        fenetre jOGLframe   % jOGLframe contient la fenetre, un panel, le canvas, la toolbar ...
        canvas              % GLCanvas dans lequel on peut utiliser les fonction openGL
        context             % GLContext
        pickingTexture Framebuffer % contient l'image 2D de la scène a afficher

        mapElements containers.Map  % map contenant les objets 3D de la scenes
        mapGroups   containers.Map  % map contenant les ensembles

        camera Camera           % instance de la camera
        lumiere Light           % instance de la lumiere
        idLastInternal int32 = 0; %id du dernier objet interne

        cbk_manager javacallbackmanager
        startX      double        % position x de la souris lorsque je clique
        startY      double        % position y de la souris lorsque je clique
        mouseButton int8 = -1    % numéro du bouton sur lequel j'appuie (1 = gauche, 2 = mil, 3 = droite)
        selectObject struct        % struct qui contient les données de l'objets selectionné
        couleurFond (1,4) double % couleur du fond de la scene

        camLightUBO UBO     % données de la caméra et de la lumière transmises aux shaders
    end %fin de propriete defaut
    
    events
        evt_redraw
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

            obj.camera = Camera(obj.canvas.getWidth() / obj.canvas.getHeight());
            addlistener(obj.camera, 'evt_updateUbo', @obj.cbk_updateUbo);
            obj.lumiere = Light();
            addlistener(obj.lumiere, 'evt_updateUbo', @obj.cbk_updateUbo);
            addlistener(obj.lumiere, 'evt_updateForme', @obj.cbk_giveGL);
            obj.camLightUBO = UBO(gl, 0, 80);
            obj.fillCamUbo();
            obj.fillLightUbo();
            obj.generateInternalObject(); % axes, gyroscope, grille & framebuffer

            %Listeners
            obj.cbk_manager = javacallbackmanager(obj.canvas);
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MousePressed');
            %obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseReleased');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseWheelMoved');

            obj.cbk_manager.setMethodCallbackWithSource(obj,'KeyPressed');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');

            addlistener(obj,'evt_redraw',@obj.cbk_redraw);
        end % fin du constructeur de Scene3D

        function elem = AddElement(obj, comp)
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
                    addlistener(elem,'evt_textureUpdate',@obj.cbk_giveGL);
                case 'ligne'
                    elem = ElementLigne(gl, comp);
                case 'point'
                    elem = ElementPoint(gl, comp);
                case 'texte'
                    elem = ElementTexte(gl, comp);
                    addlistener(elem,'evt_textureUpdate',@obj.cbk_giveGL);
            end
            obj.mapElements(elem.getId()) = elem;
            addlistener(elem,'evt_redraw',@obj.cbk_redraw);
            addlistener(elem.Geom, 'evt_updateModel', @obj.cbk_redraw);
            addlistener(elem,'evt_updateRendu',@obj.cbk_giveGL);
            addlistener(elem.GLGeom,'evt_updateLayout',@obj.cbk_giveGL);
        end % fin de AddElement

        function group = CreateGroup(obj, groupId)
            group = Ensemble(groupId);
            obj.mapGroups(groupId) = group;
        end % fin de createGroup

        function elem = RemoveElement(obj, elemId) % element et texte
            if isKey(obj.mapElements, elemId)
                elem = obj.mapElements(elemId);
                if (obj.selectObject.id == elemId)
                    obj.selectObject = elem.deselect(obj.selectObject);
                end
                if ~isempty(elem.parent)
                    elem.parent.removeElem(elemId);
                end
                remove(obj.mapElements, elemId);
            else
                disp('objet a supprimé n existe pas');
            end
        end % fin de RemoveElement

        function RemoveGroup(obj, groupId)
            if isKey(obj.mapGroups, groupId)
                group = obj.mapGroups(groupId);
                group.delete();
                obj.mapGroups.remove(groupId);
                notify(obj, 'evt_redraw');
            else
                disp('Le groupe a supprimé n existe pas');
            end
        end

        function setCouleurSelection(obj, newColor)
            if (numel(newColor) == 3)
                newColor(4) = 1;
            end
            if numel(newColor) == 4
                if obj.selectObject.id ~= 0
                    elem = obj.mapElements(obj.selectObject.id);
                    obj.selectObject = elem.deselect(obj.selectObject);
                    obj.selectObject.couleur = newColor;
                    obj.selectObject = elem.select(obj.selectObject);
                else
                    obj.selectObject.couleur = newColor;
                end
            end
        end % fin de setCouleurSelection

        function setCouleurFond(obj, newColor) % matrice 1x3 ou 1x4
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
            notify(obj,'evt_redraw');
        end % fin setCouleurFond

        function DrawScene(obj)
            %DRAW dessine la scene avec tous ses objets
            gl = obj.getGL();
            gl.glClear(bitor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT));
            
            %dessiner les objet interne a la scene
            if ~isempty(obj.lumiere.forme)
                obj.drawElem(gl, obj.lumiere.forme);
            end
            for i=obj.idLastInternal:-1
                obj.drawElem(gl, obj.mapElements(i));
            end
            %dessiner les objets de l'experience
            listeElem = obj.orderElem();
            for i=1:numel(listeElem)
                if (listeElem{i}.getId() > 0)
                    obj.drawElem(gl, listeElem{i});
                end
            end

            obj.context.release();
            obj.canvas.swapBuffers(); % rafraichi la fenetre
        end % fin de Draw
    
        function screenShot(obj)
            gl = obj.getGL();
            w = obj.canvas.getWidth();
            h = obj.canvas.getHeight();
            disp('capture en cours...')
            gl.glBindFramebuffer(gl.GL_FRAMEBUFFER,0);

            gl.glPixelStorei(gl.GL_PACK_ALIGNMENT, 1);
            buffer = java.nio.ByteBuffer.allocate(3 * w * h);
            gl.glReadPixels(0, 0, w, h, gl.GL_RGB, gl.GL_UNSIGNED_BYTE, buffer);
            img = typecast(buffer.array, 'uint8');
            img = reshape(img, [3 w h]);
            img = permute(img,[2 3 1]);
            img = rot90(img);
            imshow(img);
        end % fin de screenShot

        function delete(obj)
            %DELETE Supprime les objets de la scene
            disp('deleting Scene3D...')
            gl = obj.getGL();
            listeElem = values(obj.mapElements);
            for i=1:numel(listeElem)
                listeElem{i}.delete(gl);
            end
            Texture.DeleteAll(gl);
            obj.camLightUBO.delete(gl);
            obj.context.release();
        end % fin de delete
    end % fin des methodes defauts

    methods (Access = private)
        function gl = getGL(obj)
            if ~obj.context.isCurrent()
                obj.context.makeCurrent();
            end
            gl = obj.context.getCurrentGL();
        end % fin de getGL

        function drawElem(obj, gl, elem)
            elem.shader.Bind(gl);
            [cam, model] = obj.getOrientationMatrices(elem);
            elem.shader.SetUniformMat4(gl, 'uModelMatrix', model);
            elem.shader.SetUniformMat4(gl, 'uCamMatrix', cam);
            elem.Draw(gl);
        end % fin de drawElem

        function generateInternalObject(obj)
            tailleAxes = 50;
            obj.idLastInternal = obj.idLastInternal - 1;
            axesGeom = GeomAxes(obj.idLastInternal, -tailleAxes, tailleAxes);
            elem = obj.AddElement(axesGeom);
            elem.AddColor(axesGeom.color);

            obj.idLastInternal = obj.idLastInternal - 1;
            grilleGeom = GeomGrille(obj.idLastInternal, tailleAxes, 2);
            elem = obj.AddElement(grilleGeom);
            elem.setEpaisseur(1);
            elem.setCouleur([0.3 0.3 0.3]);

            obj.idLastInternal = obj.idLastInternal - 1;
            gysmoGeom = GeomAxes(obj.idLastInternal, 0, 1);
            elem = obj.AddElement(gysmoGeom);
            elem.AddColor(gysmoGeom.color);
            elem.setOrientation("REPERE");
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
                    distance(i) = norm(listeTrie{i}.getPosition() - obj.camera.position);
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
            shader3D.Bind(gl);

            %dessiner les objets
            gl.glEnable(gl.GL_SCISSOR_TEST); % limite la zone de dessin au pixel
            gl.glScissor(x, y, 1, 1);        % qui nous interesse (optimisation)
            if obj.couleurFond(1) > 0
                gl.glClearColor(0, 0, 0, 0);
            end
            gl.glClear(bitor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT));
            listeElem = obj.mapElements.values;
            for i=1:numel(listeElem)
                elem = listeElem{i};
                [cam, model] = obj.getOrientationMatrices(elem);
                shader3D.SetUniformMat4(gl, 'uModelMatrix', model);
                shader3D.SetUniformMat4(gl, 'uCamMatrix', cam);
                shader3D.SetUniform1i(gl, 'id', elem.getId());
                elem.DrawId(gl);
            end

            shader3D.delete(gl);

            %lire le pixel de couleurs -> obtenir l'id
            buffer = java.nio.IntBuffer.allocate(1);
            gl.glReadPixels(x, y, 1, 1, gl.GL_RED_INTEGER, gl.GL_INT, buffer);
            elemId = typecast(buffer.array(), 'int32');

            %lire la valeur de profondeur -> position du monde
            gl.glReadPixels(x, y, 1, 1, gl.GL_DEPTH_COMPONENT, gl.GL_FLOAT, buffer);
            profondeur = typecast(buffer.array(), 'single');

%<<<<<<< HEAD
            if profondeur == 1
                worldCoord = 0;
                disp('le lancer n a pas touché de cible');

                %tentative pour recuperer un point hors cible : fonctionne
                % mais dans erreur cas particulier
                % Zt=0;
                % P=obj.camera.position;
                % T=worldCoord;T(3)=-obj.camera.far;
                % k=(Zt-P(3))/(T(3)-P(3));
                % worldCoord=(T-P)*k+P;
                % worldCoord(3) = Zt;
                % disp('le lancer n a pas touché de cible');
            else
                NDC = [ x/w ; y/h ; profondeur ; 1 ].*2 - 1; % coordonnées dans l'écran -1 -> 1
%=======
            
%            NDC = [ x/w ; y/h ; profondeur ; 1 ].*2 - 1; % coordonnées dans l'écran -1 -> 1
%>>>>>>> 0a4e26a8d22708fedc7e774cbe8eea7584e9ebe9

            worldCoord = obj.camera.projMatrix * obj.camera.viewMatrix \ NDC;
            worldCoord = worldCoord(1:3)./worldCoord(4);
            worldCoord = worldCoord';
            if profondeur == 1
                %si on touche le fond alors on trouve l'intersection entre le
                %vecteur camera->worldCoord & le plan de normale z
                vect =  double(worldCoord) - obj.camera.position;
                t = obj.camera.position(3) / vect(3);
                worldCoord = obj.camera.position - t * vect;
            end

            %unbind le frameBuffer, remise des parametre de la scene
            obj.pickingTexture.UnBind(gl);
            gl.glDisable(gl.GL_SCISSOR_TEST);
            if obj.couleurFond(1) > 0
                obj.setCouleurFond(obj.couleurFond);
            end
        end % fin de pickingObject

        function colorSelection(obj, elemId)
            newElem = obj.mapElements(elemId);
            if obj.selectObject.id == elemId
                obj.selectObject = newElem.deselect(obj.selectObject);
            else
                if obj.selectObject.id ~= 0
                    oldElem = obj.mapElements(obj.selectObject.id);
                    obj.selectObject = oldElem.deselect(obj.selectObject);
                end
                obj.selectObject = newElem.select(obj.selectObject);
            end
        end % fin de colorSelection

        function [cam, model] = getOrientationMatrices(obj, elem)
            %typeOrientation '1000' fixe, '0100' Normale a l'ecran, '0010' orthonorme, '0001' perspective, '0' rien
            model = elem.getModelMatrix();
            cam = eye(4);
            camAttrib = obj.camera.getAttributes();
            if elem.typeOrientation == 1 %'0001' PERSPECTIVE
                cam = camAttrib.proj * camAttrib.view;
            elseif elem.typeOrientation == 8 %'1000' fixe (pour texte)
                % on utilise la matrice modele pour positionner le texte
                % dans le repere ecran (-1;+1)
                % pour changer la taille, on change le scaling de la
                % matrice model
                model(1, 4) = model(1, 4) * camAttrib.maxX;
                model(2, 4) = model(2, 4) * camAttrib.maxY;
                model(3, 4) = -camAttrib.near - 5e-4;
                model = model * MScale3D(camAttrib.coef);%coef pour dimension identique en ortho ou perspective
                cam =  camAttrib.proj;
            else
                if bitand(elem.typeOrientation, 2) > 0 % 0010 'face a l'ecran
                    model(1:3, 1:3) = camAttrib.view(1:3, 1:3) \ model(1:3, 1:3);
                    cam =  camAttrib.proj * camAttrib.view;
                    % cam*model = proj*view*inv(view)*model
                end
                if bitand(elem.typeOrientation, 4) > 0 %'0100' coin inferieur gauche 
                    % rotation seulement activée sur un point de l'ecran
                    cam = MProj3D('O', [camAttrib.ratio*16 16 1 20]) * camAttrib.view;
                    cam(1,4) = -0.97 + 0.1/camAttrib.ratio;
                    cam(2,4) = -0.87;
                    cam(3,4) =  0;
                end
            end
        end % fin de getOrientationMatrices

        function fillCamUbo(obj)
            obj.camLightUBO.putVec3(obj.getGL(), obj.camera.position, 64);
        end % fin de fillCamUbo

        function fillLightUbo(obj)
            gl = obj.getGL();
            obj.camLightUBO.putVec3(gl, obj.lumiere.position, 0);
            obj.camLightUBO.putVec3(gl, obj.lumiere.couleurLumiere, 16);
            obj.camLightUBO.putVec3(gl, obj.lumiere.directionLumiere, 32);
            obj.camLightUBO.putVec3(gl, obj.lumiere.paramsLumiere, 48);
        end % fin de fillLightUbo
    end % fin des methodes privees

    methods % callback
        function cbk_MousePressed(obj, ~, event)
            obj.cbk_manager.rmCallback('MouseDragged');
            disp('MousePressed')
            obj.startX = event.getX();
            obj.startY = event.getY();
            obj.mouseButton = event.getButton();

            if obj.mouseButton == 1
                [elemId, worldCoord] = obj.pickObject();
                obj.fenetre.setTextRight(['ID = ' num2str(elemId) '  ']);
                disp(['ID = ' num2str(elemId) ' Coord = ' num2str(worldCoord)]);
            
                mod = event.getModifiers();
%<<<<<<< HEAD
                if elemId ~= 0 && mod==18 %CTRL LEFT CLICK              
                    obj.colorSelection(elemId);
                end
                if mod==24 %ALT LEFT CLICK
%=======
%                if elemId ~= 0 && mod == 18 %CTRL LEFT CLICK
%                        obj.colorSelection(elemId);
%                elseif mod==24 %ALT LEFT CLICK
%>>>>>>> 0a4e26a8d22708fedc7e774cbe8eea7584e9ebe9
                    obj.camera.setTarget(worldCoord);
                end
            end
%<<<<<<< HEAD
            obj.DrawScene();
%=======
%            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
%>>>>>>> 0a4e26a8d22708fedc7e774cbe8eea7584e9ebe9
        end
        

        function cbk_MouseReleased(~,~,~)
            disp('MouseReleased')
        end

        function cbk_MouseDragged(obj, ~, event)
            obj.cbk_manager.rmCallback('MouseDragged');
            redraw = false;
            posX = event.getX();
            dx = posX - obj.startX;
            obj.startX = posX;
            posY = event.getY();
            dy = posY - obj.startY;
            obj.startY = posY;

            mod = event.getModifiers();
            ctrlPressed = bitand(mod,event.CTRL_MASK);
            if (obj.mouseButton == 3)
                redraw = true;
                if ctrlPressed
                    obj.camera.translatePlanAct(dx/obj.canvas.getWidth(),dy/obj.canvas.getHeight());
                else
                    obj.camera.rotate(dx/obj.canvas.getWidth(),dy/obj.canvas.getHeight());
                end
            end
            if (obj.lumiere.onCamera == true)
                obj.lumiere.setPositionCamera(obj.camera.position, obj.camera.targetDir);
                redraw = true;
            end
            if (redraw == true)
                obj.DrawScene();
            end
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
                        elem = obj.mapElements(obj.selectObject.id);
                        obj.selectObject = elem.deselect(obj.selectObject);
                    end
                case char(127) % SUPPR
                    if obj.selectObject.id ~= 0
                        obj.RemoveElement(obj.selectObject.id);
                        obj.selectObject = struct('id', 0, 'couleur', [1 0.6 0 1], 'epaisseur', 6);
                    end
               case 'i'
                     obj.screenShot();
                     redraw = false;
                otherwise
                    redraw = false;
            end
            if redraw
                obj.DrawScene();
            end
        end

        function cbk_MouseWheelMoved(obj, ~,event)
            obj.cbk_manager.rmCallback('MouseWheelMoved');
            obj.camera.zoom(-event.getWheelRotation());
            if obj.lumiere.onCamera == true
                obj.lumiere.setPositionCamera(obj.camera.position, obj.camera.targetDir);
            end
            obj.DrawScene();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseWheelMoved');
        end
    
        function cbk_ComponentResized(obj, ~, ~)
            obj.cbk_manager.rmCallback('ComponentResized');
            w = obj.canvas.getWidth();
            h = obj.canvas.getHeight();
            %disp(['ComponentResized (' num2str(w) ' ; ' num2str(h) ')'])
            gl = obj.getGL();
            gl.glViewport(0, 0, w, h);
            obj.camera.setRatio(w/h);
            obj.DrawScene();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');
        end

        function cbk_updateUbo(obj, source, ~)
            if isa(source, 'Light')
                obj.fillLightUbo()
            elseif isa(source, 'Camera')
                obj.fillCamUbo();
            end
        end % fin de cbk_updateUbo

        function cbk_redraw(obj, ~, ~)
            disp('cbk_redraw');
            obj.DrawScene;
        end

        function cbk_giveGL(obj, source, event)
            disp('cbk_giveGL');
            source.glUpdate(obj.getGL(), event.EventName);
            obj.DrawScene();
        end
    end % fin des methodes callback

end % fin de la classe Scene3D