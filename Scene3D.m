classdef Scene3D < handle
    %SCENE3D la scene 3D a afficher
    
    properties
        fenetre jOGLframe   % jOGLframe contient la fenetre, un panel, le canvas, la toolbar ...
        canvas              % GLCanvas dans lequel on peut utiliser les fonction openGL
        context             % GLContext
        framebuffer Framebuffer % contient une image de la scène a afficher

        mapElements containers.Map  % map contenant les objets 3D de la scenes

        camera Camera       % instance de la camera
        lumiere Light       % instance de la lumiere
        axes ElementLigne           % instance des axes lié au repere
        gyroscope ElementLigne      % indication d'angle dans le repere
        grille Grid         % instance de la grille lié au repere

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
            obj.generateInternalObject(gl); % axes, gyroscope, grille & framebuffer

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

        function elem = AjouterTexte(obj, id, texte, police, typeAncre)
            if nargin == 4, typeAncre = 0; end
            elem = ElementTexte(obj.getGL(), id, texte, police, typeAncre);
            obj.mapElements(id) = elem;
            obj.context.release();
        end % fin de ajouterTexte

        function elem = AjouterGeom(obj, aGeom, type)
            if nargin == 2, type = 'face'; end
            gl = obj.getGL();
            if isKey(obj.mapElements, aGeom.id)
                warning('Id deja existante remplace l ancient element');
            end
            switch type
                case 'face'
                    elem = ElementFace(gl, aGeom);
                case 'ligne'
                    elem = ElementLigne(gl, aGeom);
                case 'point'
                    elem = ElementPoint(gl, aGeom);
            end
            obj.mapElements(elem.getId()) = elem;
            addlistener(elem,'evt_update',@obj.cbk_update);
            obj.context.release();
        end % fin de ajouterGeom

        function RetirerObjet(obj, elemId) % element et texte
            if isKey(obj.mapElements, elemId)
                remove(obj.mapElements, elemId);
            else
                disp('objet a supprimé n existe pas');
            end
        end % fin de retirerObjet

        function Draw(obj)
            %DRAW dessine la scene avec tous ses objets
            gl = obj.getGL();
            obj.lumiere.remplirUbo(gl);
            obj.camera.remplirUbo(gl);
            obj.framebuffer.Bind(gl);
            gl.glClear(bitor(gl.GL_COLOR_BUFFER_BIT, gl.GL_DEPTH_BUFFER_BIT));
            gl.glEnable(gl.GL_DEPTH_TEST);

            camAttrib = obj.camera.getAttributes();

            %dessin des objets internes
            obj.gyroscope.Draw(gl, camAttrib)
            obj.axes.Draw(gl, camAttrib)
            obj.grille.Draw(gl, camAttrib)
            if ~isempty(obj.lumiere.forme)
                obj.lumiere.forme.Draw(gl, camAttrib)
            end

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
            notify(obj,'evt_update');
        end % fin setCouleurFond

        function AddGeomToLight(obj, geom)
            disp('ne fonctionne pas')
            gl = obj.getGL();
            elem = ElementFace(geom);
            elem.Init(gl);
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

        function generateInternalObject(obj, gl)
            tailleAxe = 50;
            [pos, idx, color] = Axes.generateAxes(-tailleAxe, tailleAxe);
            axesGeom = Geometry(-1, pos, idx);
            obj.axes = ElementLigne(gl, axesGeom);
            obj.axes.AddColor(color);

            [pos, idx] = Grid.generateGrid(tailleAxe, 2);
            grilleGeom = Geometry(-2, pos, idx);
            obj.grille = Grid(gl, grilleGeom, tailleAxe, 2);

            tailleGysmo = 0.06;
            [pos, idx, color] = Axes.generateAxes(0, tailleGysmo);
            gysmoGeom = Geometry(-3, pos, idx);
            obj.gyroscope = ElementLigne(gl, gysmoGeom);
            obj.gyroscope.setEpaisseur(4);
            obj.gyroscope.AddColor(color);
            obj.gyroscope.setModelMatrix(MTrans3D([-0.97, -0.87, 0]));
            obj.gyroscope.typeOrientation = 'O';

            obj.framebuffer = Framebuffer(gl, obj.canvas.getWidth(), obj.canvas.getHeight());
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
                    obj.fenetre.setTextRight(['ID = ' num2str(elem.getId()) '  '])
                elseif mod==24 %ALT LEFT CLICK
                    obj.camera.setTarget(worldCoord);
                end
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
                        obj.RetirerObjet(obj.selectObject.id);
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
            obj.Draw;
        end
    end % fin des methodes callback
end % fin de la classe Scene3D