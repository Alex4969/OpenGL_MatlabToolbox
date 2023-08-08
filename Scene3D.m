classdef Scene3D < handle
    %SCENE3D la scene 3D a afficher
    
    properties
        fenetre jOGLframe   % jOGLframe contient la fenetre, un panel, le canvas, la toolbar ...
        canvas              % GLCanvas dans lequel on peut utiliser les fonction openGL
        context             % GLContext
        framebuffer Framebuffer % contient l'image 2D de la scène a afficher

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
            gl.glClearColor(0.0, 0.0, 0.4, 1.0);
            gl.glDepthFunc(gl.GL_LESS);
            gl.glEnable(gl.GL_LINE_SMOOTH);
            gl.glEnable(gl.GL_BLEND);
            gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA);
            % gl.glEnable(gl.GL_CULL_FACE); % optimisation : supprime l'affichage des faces arrieres

            obj.camera = Camera(gl, obj.canvas.getWidth() / obj.canvas.getHeight());
            obj.lumiere = Light(gl, [obj.camera.getPosition], [1 1 1]);
            obj.generateInternalObject(); % axes, gyroscope, grille & framebuffer

            obj.context.release();

            %Listeners
            obj.cbk_manager = javacallbackmanager(obj.canvas);
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MousePressed');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseReleased');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseWheelMoved');

            obj.cbk_manager.setMethodCallbackWithSource(obj,'KeyPressed');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');

            addlistener(obj,'evt_update',@obj.cbk_update);
        end % fin du constructeur de Scene3D

        function elem = AddComponent(obj, comp)
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
            obj.context.release();
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

        function Draw(obj)
            tic
            %DRAW dessine la scene avec tous ses objets
            gl = obj.getGL();
            obj.lumiere.remplirUbo(gl);
            obj.camera.remplirUbo(gl);
            obj.framebuffer.Bind(gl);
            gl.glClear(bitor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT));
            gl.glEnable(gl.GL_DEPTH_TEST);

            camAttrib = obj.camera.getAttributes();
            %dessin des objets ajouter a la scene
            listeElem = obj.orderElem();
            for i=1:numel(listeElem)
                elem = listeElem{i};
                elem.Draw(gl, camAttrib);
            end

            obj.framebuffer.UnBind(gl);
            gl.glDisable(gl.GL_DEPTH_TEST);
            obj.framebuffer.forme.Draw(gl, camAttrib);

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
            Texture.DeleteAll(gl);
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

            obj.framebuffer = Framebuffer(obj.getGL(), obj.canvas.getWidth(), obj.canvas.getHeight());
        end % fin de generateInternalObject

        function worldCoord = getWorldCoord(obj, clickPos)
            gl = obj.getGL();
            obj.framebuffer.Bind(gl);

            r = 2;      % click radius (square box) px
            w = 2*r+1;  % square side length px

            buffer = java.nio.FloatBuffer.allocate(w*w);
            sz = [obj.canvas.getWidth() ; obj.canvas.getHeight()];
            clickPos(2) = sz(2) - clickPos(2);
            gl.glReadPixels(clickPos(1)-r, clickPos(2)-r, w, w, gl.GL_DEPTH_COMPONENT, gl.GL_FLOAT, buffer);
            profondeur = typecast(buffer.array(), 'single');
            n = (profondeur == 1);

            if all(n, "all")
                worldCoord = 0;
                % disp('le lancer n a pas touché de cible');
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
                if listeTrie{i}.typeOrientation >= 4 %ortho ou fixe
                    distance(i) = 0;
                else
                    distance(i) = norm(listeTrie{i}.getPosition() - obj.camera.getPosition());
                end
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
        end % fin de colorSelection  
    end % fin des methodes privees

    methods % callback
        function cbk_MousePressed(obj,source,event)
            %disp('MousePressed')
            obj.startX=event.getPoint.getX();
            obj.startY=event.getPoint.getY();
            obj.mouseButton = event.getButton();
            
            worldCoord = obj.getWorldCoord([obj.startX; obj.startY]);
            % disp(worldCoord)
            if numel(worldCoord) == 3
                mod = event.getModifiers();
                if mod==18 %CTRL LEFT CLICK
                    elem = obj.getPointedObject(worldCoord);
                    disp(['element touched : ' num2str(elem.getId())]);
                    obj.colorSelection(elem);
                    obj.fenetre.setTextRight(['ID = ' num2str(elem.getId()) '  ']);
                elseif mod==24 %ALT LEFT CLICK
                    obj.camera.setTarget(worldCoord);
                end
                obj.Draw;
            end
        end

        function cbk_MouseReleased(obj,source,event)
            disp('MouseReleased')
        end

        function cbk_MouseDragged(obj,source,event)
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
            obj.lumiere.setPosition([obj.camera.getPosition]);
            obj.Draw();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
        end

        function cbk_KeyPressed(obj,source,event)
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
                    obj.framebuffer.screenShot(obj.getGL, obj.canvas.getWidth(), obj.canvas.getHeight());
                otherwise
                    redraw = false;
            end
            if redraw
                obj.Draw();
            end
        end

        function cbk_MouseWheelMoved(obj,source,event)
            obj.cbk_manager.rmCallback('MouseWheelMoved');
            obj.camera.zoom(event.getWheelRotation());
            obj.lumiere.setPosition([obj.camera.getPosition]);
            obj.Draw();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseWheelMoved');
        end
    
        function cbk_ComponentResized(obj,source,event)
            obj.cbk_manager.rmCallback('ComponentResized');
            w=source.getSize.getWidth;
            h=source.getSize.getHeight;
            %disp(['ComponentResized (' num2str(w) ' ; ' num2str(h) ')'])
            gl = obj.getGL();
            gl.glViewport(0, 0, w, h);
            obj.camera.setRatio(w/h);
            obj.framebuffer.Resize(gl, w, h);
            obj.Draw();
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');
        end

        function cbk_update(obj,source,event)
            disp('cbk_Update');
            % obj.Draw;
        end
    end % fin des methodes callback
end % fin de la classe Scene3D