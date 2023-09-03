classdef Scene3D < handle
    %OpenGL 3D scene


    % mask code for extended modifiers
    properties (Hidden, Constant) 
        SHIFT=64        
        CTRL=128
        ALT=512

        BUTTON1=1024
        BUTTON2=2048
        BUTTON3=4096
    end

    % constants for mouse action
    properties (Access=public)
        MOUSE_ROTATE 
        MOUSE_TRANSLATE
        MOUSE_SELECT
        MOUSE_TARGET
    end
    
    properties (GetAccess = public, SetAccess = private)
        fenetre jOGLframe   % jOGLframe contient la fenetre, un panel, le canvas, la toolbar ...
        canvas              % GLCanvas dans lequel on peut utiliser les fonction openGL getacces = public sinon impossible de fermer la fenetre
        context             % GLContext

        mapElements containers.Map  % map contenant les objets 3D de la scenes
        mapGroups   containers.Map  % map contenant les ensembles

        camera Camera             % instance de la camera
        lumiere Light             % instance de la lumiere

        selectObject struct       % struct qui contient les données de l'objets selectionné
        backgroundColor (1,4) double  % couleur du fond de la scene
        currentCamTarget
    end %fin de propriete defaut

    properties(Access = private)
        pickingTexture Framebuffer % contient l'image 2D de la scène a afficher

        idLastInternal int32 = 0; % id du dernier objet interne
        camLightUBO UBO     % données de la caméra et de la lumière transmises aux shaders

        cbk_manager javacallbackmanager
        startX      double        % position x de la souris lorsque je clique
        startY      double        % position y de la souris lorsque je clique
        mouseButton int8 = -1     % numéro du bouton sur lequel j'appuie (1 = gauche, 2 = mil, 3 = droite)
        currentWorldCoord
        
    end
    
    events
        evt_redraw
    end

    methods
        %Constructor
        function obj = Scene3D(windowSize)
            obj.fenetre = jOGLframe('GL4',0);
            if nargin == 0
                obj.fenetre.setSize([1280 1280*9/16]);
            elseif nargin == 1
                obj.fenetre.setSize(windowSize);
            else
                error('Bad argument number')
            end

            % To remove in final app
            addpath('outils\');
            addpath('icons\');
            addpath('Component\');

            % define mouse actions
            obj.MOUSE_ROTATE=obj.BUTTON1;
            obj.MOUSE_TRANSLATE=obj.BUTTON3;
            obj.MOUSE_SELECT=obj.BUTTON1+obj.CTRL;
            obj.MOUSE_TARGET=obj.BUTTON1+obj.ALT;

            obj.canvas = obj.fenetre.canvas.javaObj;
            obj.canvas.setAutoSwapBufferMode(false);
            obj.canvas.display();
            obj.context = obj.fenetre.canvas.javaObj.getContext();

            obj.mapElements = containers.Map('KeyType','int32','ValueType','any');
            obj.mapGroups   = containers.Map('KeyType','int32','ValueType','any');
            obj.selectObject = struct('id', 0, 'couleur', [1 0.6 0 1], 'epaisseur', 6);

            gl = obj.getGL();
            gl.glViewport(0, 0, obj.canvas.getWidth(), obj.canvas.getHeight());
            obj.setBackgroundColor([0, 0, 0.4, 1.0]);
            gl.glDepthFunc(gl.GL_LESS);
            gl.glEnable(gl.GL_LINE_SMOOTH);
            gl.glEnable(gl.GL_BLEND);
            gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA);
            gl.glEnable(gl.GL_DEPTH_TEST);
            % gl.glEnable(gl.GL_CULL_FACE); % optimisation : supprime l'affichage des faces arrieres

            % Camera and Light
            obj.camera = Camera(obj.canvas.getWidth() / obj.canvas.getHeight());
            addlistener(obj.camera, 'evt_updateUbo', @obj.cbk_updateUbo);
            obj.lumiere = Light();
            addlistener(obj.lumiere, 'evt_updateUbo', @obj.cbk_updateUbo);
            addlistener(obj.lumiere, 'evt_updateForme', @obj.cbk_giveGL);
            obj.camLightUBO = UBO(gl, 0, 96);
            obj.fillCamUbo();
            obj.fillLightUbo();
            obj.generateInternalObject(); % axes, gyroscope, grille & framebuffer
            addlistener(obj,'evt_redraw',@obj.cbk_redraw);

            %Listeners clavier/souris
            obj.cbk_manager = javacallbackmanager(obj.canvas);
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MousePressed');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseReleased');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseWheelMoved');

            obj.cbk_manager.setMethodCallbackWithSource(obj,'KeyPressed');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'KeyTyped');
            obj.cbk_manager.setMethodCallbackWithSource(obj,'ComponentResized');

            % Toolbar listeners
            addlistener(obj.fenetre.toolBarMap('Views'),'evt_mouseClickedButton',@obj.cbk_toolbarButtonClicked);           
            addlistener(obj.fenetre.toolBarMap('Camera'),'evt_mouseClickedButton',@obj.cbk_toolbarButtonClicked);

            
        end

        %Destructor
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
            obj.fenetre.delete();
        end
    
    end

    methods
        % Add Element to scene (map)
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
            addlistener(elem.geom, 'evt_updateModel', @obj.cbk_redraw);
            addlistener(elem,'evt_updateRendu',@obj.cbk_giveGL);
            addlistener(elem.GLGeom,'evt_updateLayout',@obj.cbk_giveGL);
        end

        %Add empty group of elements
        function group = CreateGroup(obj, groupId)
            group = Ensemble(groupId);
            obj.mapGroups(groupId) = group;
        end

        %Remove element from 3D Scene
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
                disp('Element ID does not exist');
            end
        end

        %Remove element's group 
        function RemoveGroup(obj, groupId)
            if isKey(obj.mapGroups, groupId)
                group = obj.mapGroups(groupId);
                group.delete();
                obj.mapGroups.remove(groupId);
                notify(obj, 'evt_redraw');
            else
                disp('This group ID does not exist');
            end
        end % fin de removeGroup

        %Set the color to highlight the selected object
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
        end

        %Set background color: 1x3 or 1x4
        function setBackgroundColor(obj, newColor) 
            if (numel(newColor) == 3)
                newColor(4) = 1;
            end
            if numel(newColor) == 4
                gl = obj.getGL();
                obj.backgroundColor = newColor;
                gl.glClearColor(newColor(1), newColor(2), newColor(3), newColor(4));
            else
                warning('Le format de la nouvelle couleur n est pas bon, annulation');
            end
            notify(obj,'evt_redraw');
        end

        %Get backGroundColor
        function col=getBackGroundColor(obj)
            col=obj.backgroundColor;
        end

        %Draw the whole scene
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
            obj.canvas.swapBuffers(); % refresh the scene
        end
    
        %Screenshot
        function img=screenShot(obj)
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
        end

    end

    % callback
    methods 
        function cbk_MousePressed(obj, ~, event)
            obj.cbk_manager.rmCallback('MouseDragged');
            disp('MousePressed')
            obj.startX = event.getX();
            obj.startY = event.getY();
            obj.mouseButton = event.getButton();

            event.getButton;
            mod = event.getModifiersEx()

            % if obj.mouseButton == 1
            %     elemId = obj.pickObject();
            %     worldCoord = obj.getWorldCoord();
            %     obj.fenetre.setTextRight(['ID = ' num2str(elemId) '  ']);
            %     disp(['ID = ' num2str(elemId) ' Coord = ' num2str(worldCoord)]);
            % 
            %     mod = event.getModifiers();
            %     if elemId ~= 0 && mod==18 %CTRL LEFT CLICK              
            %         obj.colorSelection(elemId);
            %         obj.DrawScene();
            %     end
            %     if mod==24 %ALT LEFT CLICK
            %         disp('ALT')
            %         obj.camera.setTarget(worldCoord,false);
            %     end
            % end

            obj.currentWorldCoord = obj.getWorldCoord();
            obj.currentCamTarget=obj.camera.target;

            disp([' Coord = ' num2str(obj.currentWorldCoord)]);
            if mod == obj.MOUSE_SELECT
                elemId = obj.pickObject();                
                obj.fenetre.setTextRight(['Selected (ID = ' num2str(elemId) ')']);
                disp(['Selected (ID = ' num2str(elemId)]);% ' Coord = ' num2str(worldCoord)]);
                if elemId ~= 0              
                    obj.colorSelection(elemId);
                    obj.DrawScene();
                end
            end
            if mod == obj.MOUSE_TARGET
                    disp('Set Target')
                    elemId = obj.pickObject()
                    obj.camera.setTarget(obj.currentWorldCoord);
                    
                    obj.fenetre.setTextRight(['Camera target setted (ID = ' num2str(elemId) ')'],5);
            end
            
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
                    
        end
        

        function cbk_MouseReleased(obj,~,event)
            disp('MouseReleased')

            % Why this ????
            % % % mod = event.getModifiersEx();
            % % % if mod ~= obj.ALT
            % % %     obj.camera.setTarget(obj.currentCamTarget);
            % % % end


            % obj.DrawScene;
        end

          
        function cbk_MouseDragged(obj, ~, event)
            obj.cbk_manager.rmCallback('MouseDragged');
            posX = event.getX();
            dx = posX - obj.startX;
            obj.startX = posX;
            posY = event.getY();
            dy = posY - obj.startY;
            obj.startY = posY;

            % worldcoord=obj.getWorldCoord()

            mod = event.getModifiersEx();
            % ctrlPressed = bitand(mod,event.CTRL_MASK);
            % if (obj.mouseButton == 3)
            %     if ctrlPressed
            if mod==obj.MOUSE_TRANSLATE
                    obj.camera.translatePlanAct(dx/obj.canvas.getWidth(),dy/obj.canvas.getHeight());
            elseif mod==obj.MOUSE_ROTATE
                    obj.camera.rotate(dx/obj.canvas.getWidth(),dy/obj.canvas.getHeight(),obj.camera.target);
            elseif mod==obj.MOUSE_ROTATE+obj.SHIFT
                    obj.camera.rotate(dx/obj.canvas.getWidth(),dy/obj.canvas.getHeight(),obj.currentWorldCoord);
            elseif mod==obj.BUTTON1+obj.SHIFT+obj.CTRL
                obj.camera.selfRotate((posX-obj.canvas.getWidth()/2)/obj.canvas.getWidth(),(posY-obj.canvas.getHeight()/2)/obj.canvas.getHeight(),dx/obj.canvas.getWidth(),dy/obj.canvas.getHeight());
            end
            if (obj.lumiere.onCamera == true)
                obj.lumiere.setPositionWithCamera(obj.camera.position, obj.camera.getDirection());
            end
            obj.cbk_manager.setMethodCallbackWithSource(obj,'MouseDragged');
        end

        function cbk_KeyPressed(obj, ~, event)
            % for CTRL + character
            % for special keys : F1 ... F12 , esc ...
            % ATTENTION : event.getKeyCode() retourne toujours le code ascii de la majuscule
            disp(['KeyPressed : ' event.getKeyChar  '   modifiersEx : ' num2str(event.getModifiersEx) '   ascii : ' num2str(event.getKeyCode)])

            % code=event.getModifiersEx+uint32(event.getKeyCode);
            % disp(['CODE : ' num2str(code)])

            
            code=uint32(event.getKeyChar);
            isPrintable=code>=33 & code<=126;

            % NO MODIFIERS
            if event.getModifiersEx==0                
                if isPrintable % printable ASCII character
                    switch code
                        case 'x'
                            obj.camera.setAuthorizedAxis([1 0 0])
                        case 'y'
                            obj.camera.setAuthorizedAxis([0 1 0])
                        case 'z'
                            obj.camera.setAuthorizedAxis([0 0 1])                 
                        case 'p' %perspective/ortho
                            obj.camera.switchProjType;
                        case '+' %increase cam speed
                            %obj.camera.speed=min(100,obj.camera.speed+1)
                            obj.camera.changeSpeed(+1);
                            disp('JUSTE +')
                        case uint32('-') %decrease cam speed
                            %obj.camera.speed=max(5,obj.camera.speed-1)   
                            obj.camera.changeSpeed(-1);           
                    end
                else                
                    switch event.getKeyCode() % NON PRINTABLE ASCII Character
                        case event.VK_ESCAPE  % ECHAP
                            if obj.selectObject.id ~= 0
                                elem = obj.mapElements(obj.selectObject.id);
                                obj.selectObject = elem.deselect(obj.selectObject);
                                obj.DrawScene();
                            end
                        case event.VK_DELETE % SUPPR
                            if obj.selectObject.id ~= 0
                                obj.RemoveElement(obj.selectObject.id);
                                obj.selectObject = struct('id', 0, 'couleur', [1 0.6 0 1], 'epaisseur', 6);
                                obj.DrawScene();
                            end
                        case event.VK_F10   %'i'
                             obj.screenShot();
                    end
                end

            % SHIFT MODIFIER
            elseif event.getModifiersEx==obj.SHIFT
                if isPrintable % printable ASCII character
                    switch code
                        
                        case '+' %increase cam speed
                        %obj.camera.speed=min(100,obj.camera.speed+1)
                        % obj.camera.changeSpeed(+1);
                        disp('SHIFT +')
                    end
                else % NON PRINTABLE ASCII Character
                    switch event.getKeyCode()
                    end
                end

            % CTRL MODIFIER
            elseif event.getModifiersEx==obj.CTRL
                code_ctrl=event.getKeyCode();
                isPrintable=code_ctrl>=33 & code_ctrl<=126;
                if isPrintable % printable ASCII character
                    
                    switch code_ctrl
                        case 'O' %origin
                            obj.camera.defaultView;
                        case uint32('F') %up
                            obj.camera.faceView;    
                        case uint32('B') %up
                            obj.camera.backView;    
                        case uint32('U') %up
                            obj.camera.upView;
                        case uint32('D') %up
                            obj.camera.downView;    
                        case uint32('L') %up
                            obj.camera.leftView;
                        case uint32('R') %up
                            obj.camera.rightView;  
                        case '+' %increase cam speed
                            disp('CTRL +')                            
                    end
                else % NON PRINTABLE ASCII Character
                    switch event.getKeyCode()
                    end
                end

            % ALT MODIFIER
            elseif event.getModifiersEx==obj.ALT
                if isPrintable % printable ASCII character
                    switch code
                        case 'x' % YZ plane, X constant
                            obj.camera.setAuthorizedAxis([0 1 1])
                        case 'y' % XZ plane, Y constant
                            obj.camera.setAuthorizedAxis([1 0 1])
                        case 'z' % XY plane, Z constant
                            obj.camera.setAuthorizedAxis([1 1 0])                         
                        case '+' %increase cam speed
                        disp('ALT +')
                    end
                else % NON PRINTABLE ASCII Character
                    switch event.getKeyCode()
                    end
                end

            % CTRL+SHIFT MODIFIER    
            elseif event.getModifiersEx==(obj.CTRL+obj.SHIFT)
                code_ctrl=event.getKeyCode();
                isPrintable=code_ctrl>=33 & code_ctrl<=126;
                if isPrintable % printable ASCII character
                    switch code_ctrl
                        case uint32('B') %up
                            obj.camera.rearView;                         
                        case '+' %increase cam speed
                        disp('CTRL+ALT +')                        
                    end
                else % NON PRINTABLE ASCII Character
                    switch event.getKeyCode()
                    end
                end
            end

        end

        function cbk_KeyTyped(obj, ~, event)
            disp(['KeyTyped : ' event.getKeyChar  '   modifiersEx : ' num2str(event.getModifiersEx) '   ascii : ' num2str(event.getKeyCode)])
            

        end

        function cbk_MouseWheelMoved(obj, ~,event)
            obj.cbk_manager.rmCallback('MouseWheelMoved');
            obj.camera.zoom(-event.getWheelRotation(),event.getModifiersEx());
            if obj.lumiere.onCamera == true
                obj.lumiere.setPositionWithCamera(obj.camera.position, obj.camera.getDirection());
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
    
        %toolbar
        function cbk_toolbarButtonClicked(obj,source,event)
            tb=char(source.javaObj.getName());
            event_name=char(event.handle.getName());

            switch tb
                case 'Views'
                    switch event_name
                        case 'standard'
                            obj.camera.defaultView();
                            obj.fenetre.setTextLeft('Standard view');
                        case 'multiviews'
                            num=obj.camera.nextDefaultView();
                            obj.fenetre.setTextLeft(['Multiviews (' num2str(num) ')']);
                        case 'face'
                            obj.fenetre.setTextLeft('Front view');
                            obj.camera.faceView();                            
                        case 'back'
                            obj.fenetre.setTextLeft('Back view');
                            obj.camera.backView();                            
                        case 'rear'
                            obj.fenetre.setTextLeft('Rear view');
                            obj.camera.rearView();                           
                        case 'left'                           
                            obj.fenetre.setTextLeft('Left view');
                            obj.camera.leftView();
                        case 'right'
                            obj.fenetre.setTextLeft('Right view');
                            obj.camera.rightView();                           
                        case 'top'
                            obj.fenetre.setTextLeft('Top view');
                            obj.camera.upView();                             
                        case 'bottom'
                            obj.fenetre.setTextLeft('Bottom view');
                            obj.camera.downView();                          
                        case 'perspective'
                            if event.handle.isSelected
                                obj.fenetre.setTextLeft('Orthographic mode');
                            else
                                obj.fenetre.setTextLeft('Perspective mode');
                            end
                            obj.camera.switchProjType();
                            

                    end

                case 'Camera'
                    switch event_name
                        case 'color'
                            col=obj.getBackGroundColor();
                            col=col(1:3);
                            newCol=uisetcolor(col,'Select a background color');
                            if ~isequal(col,newCol)
                                obj.setBackgroundColor(newCol);
                                obj.fenetre.setTextLeft('Background Color changed');
                            end
                        case 'flash'
                            if event.handle.isSelected
                                obj.fenetre.setTextLeft('Flash mode On (light is on camera)');
                                obj.lumiere.putOnCamera(true);
                                obj.lumiere.setPositionWithCamera(obj.camera.position, obj.camera.getDirection());
                            else
                                obj.fenetre.setTextLeft('Flash mode Off');
                                obj.lumiere.putOnCamera(false);
                            end
                        case 'screenshot'
                            obj.screenShot();
                            obj.fenetre.setTextLeft('Screenshot done');
                    end
            end

        end    
    
    end

    methods
        function cbk_updateUbo(obj, source, ~)
        % Appeler par la caméra et la light quand il faut mettre leurs données a jour
            % class(source)
            if isa(source, 'Light')
                obj.fillLightUbo();
                % if (obj.lumiere.onCamera == false)
                    obj.DrawScene();
                % end
            elseif isa(source, 'Camera')
                obj.fillCamUbo();
                obj.DrawScene();
            end
            
            % % % obj.fillLightUbo();
            % % % obj.fillCamUbo();
            % % % obj.DrawScene();
        end % fin de cbk_updateUbo

        function cbk_redraw(obj, ~, ~)
        % Appeler par la scene, un élément ou un component quand une valeur a été modifié
        % et qu'elle nécessite un nouvel affichage pour visualiser la modification
            disp('cbk_redraw');
            obj.DrawScene;
        end % fin de cbk_redraw

        function cbk_giveGL(obj, source, event)
        % appeler par element ou GLGeometrie evt_update*
        % modification des données qui nécessite le comntexte pour être prise en compte
        % Ces objets implémentent glUpdate()
            disp('cbk_giveGL');
            source.glUpdate(obj.getGL(), event.EventName);
            obj.DrawScene();
        end % fin de cbk_giveGL
    end % fin des methodes callback

    % Private methods
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
            elem.setColor([0.3 0.3 0.3]);

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

        function elemId = pickObject(obj)
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
            if obj.backgroundColor(1) > 0
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

            %unbind le frameBuffer, remise des parametre de la scene
            obj.pickingTexture.UnBind(gl);
            gl.glDisable(gl.GL_SCISSOR_TEST);
            if obj.backgroundColor(1) > 0
                obj.setBackgroundColor(obj.backgroundColor);
            end
        end % fin de pickingObject

        function worldCoord = getWorldCoord(obj)
            w = obj.canvas.getWidth();
            h = obj.canvas.getHeight();
            x = obj.startX;
            y = h - obj.startY;
            gl = obj.getGL();
            %lire la valeur de profondeur -> position du monde
            buffer = java.nio.FloatBuffer.allocate(1);
            gl.glReadPixels(x, y, 1, 1, gl.GL_DEPTH_COMPONENT, gl.GL_FLOAT, buffer);
            profondeur = typecast(buffer.array(), 'single');

%<<<<<<< HEAD
            % % if profondeur == 1
            % %     worldCoord = 0;
            % %     disp('le lancer n a pas touché de cible');
            % % 
            % %     %tentative pour recuperer un point hors cible : fonctionne
            % %     % mais dans erreur cas particulier
            % %     % Zt=0;
            % %     % P=obj.camera.position;
            % %     % T=worldCoord;T(3)=-obj.camera.far;
            % %     % k=(Zt-P(3))/(T(3)-P(3));
            % %     % worldCoord=(T-P)*k+P;
            % %     % worldCoord(3) = Zt;
            % %     % disp('le lancer n a pas touché de cible');
            % % else
            % %     NDC = [ x/w ; y/h ; profondeur ; 1 ].*2 - 1; % coordonnées dans l'écran -1 -> 1
%=======
            
            NDC = [ x/w ; y/h ; profondeur ; 1 ].*2 - 1; % coordonnées dans l'écran -1 -> 1
%>>>>>>> 0a4e26a8d22708fedc7e774cbe8eea7584e9ebe9

            worldCoord = obj.camera.projMatrix * obj.camera.viewMatrix \ NDC;
            worldCoord = worldCoord(1:3)./worldCoord(4);
            worldCoord = worldCoord';
            if profondeur == 1
                %si on touche le fond alors on trouve l'intersection entre le
                %vecteur camera->worldCoord & le plan de normale z
                vect =  double(worldCoord) - obj.camera.position;
                t = obj.camera.position(3) / vect(3);
                if (t > 0) % le clic n'a pas touché le plan
                    t = obj.camera.position(1) / vect(1); % on prend l'intersection avec le plan 0yz
                    if (t > 0) % le clic n'a pas touché le plan
                        t = obj.camera.position(2) / vect(2); % on prend l'intersection avec le plan 0xz
                    end
                end
                if t == Inf % verification pas d'erreur
                    worldCoord = [0 0 0];
                    disp('le lancer de rayon n a pas pu aboutir');
                else
                    worldCoord = obj.camera.position - t * vect;
                end
            end
        end % fin de getWorldCoord

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
                model(3, 4) = -camAttrib.near;
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
            obj.camLightUBO.putVec3(obj.getGL(), obj.camera.position, 80);
        end % fin de fillCamUbo

        function fillLightUbo(obj)
            % disp('fill UBO')
            gl = obj.getGL();
            obj.camLightUBO.putVec3(gl, obj.lumiere.position, 0);
            obj.camLightUBO.putVec3(gl, obj.lumiere.couleurLumiere, 16);
            obj.camLightUBO.putVec3(gl, obj.lumiere.directionLumiere, 32);
            obj.camLightUBO.putVec3(gl, obj.lumiere.paramsLumiere, 48);
            obj.camLightUBO.putVec3(gl, [0.5 0 0], 64);
        end % fin de fillLightUbo
    end

    

% ******************** TESTS AND DEBUG ********************

    %test and debug with static functions
    methods (Static)
        function testStatic1(~)
            % clear all
            
            addpath('outils\');
            addpath('java\');
            addpath('Component\');
            
            viewer = Scene3D();
            viewer.setBackgroundColor([0 0 0.4])
            viewer.lumiere.dotLight(0.01, 0); % lumiere ponctuelle d'intensité 1 / (a * dist² + b * dist + 1)
            viewer.lumiere.setColor([1 1 1]);
            viewer.DrawScene();
            %%%%  definition des objets  %%%%
            
            % generation des parametre de la pyramide
            [posPyramide, indicesPyramide, mappingPyramide] = generatePyramide(4, 0.8);
            
            % pyramide avec une couleur par sommet
            pyraColorGeom = GeomFace(1, posPyramide, indicesPyramide);
            viewer.AddElement(pyraColorGeom);
            
            couleurPyramide = [ 1 0 0 1 ; 1 1 0 1 ; 0 1 0 1 ; 0 0.6 1 1 ; 1 1 1 0];
            elem = viewer.mapElements(1);
            elem.setModelMatrix(MTrans3D([-7 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
            elem.AddColor(couleurPyramide);
            
            % % nuage de points avec une couleur par sommet
            N = 10000;
            m = -1; M = 1;
            posPoints=rand(N,3)*(M-m)+m;
            cloudGeom = GeomPoint(25, posPoints);
            elem = viewer.AddElement(cloudGeom);
            elem.setModelMatrix(MTrans3D([-2 4 -4]) * MRot3D([0 0 45]) * MScale3D(1));
            
            couleurPoints = rand(N,3);
            elem.AddColor(couleurPoints);
            
            % % generation des données d'une sphere
            [posBoule, indBoule, mappingBoule] = generateSphere(12, 16, pi * 2);
            
            % % sphere wireframe
            bouleGeom = MyGeom(2, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleGeom);
            
            elem.setCouleurArretes([1 1 0]);
            elem.setEpaisseurArretes(3);
            elem.setQuoiAfficher(2);
            elem.setModelMatrix(MTrans3D([-4 1 0]));
            
            % % sphere avec texture map monde
            bouleTexGeom = MyGeom(3, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleTexGeom);
            
            elem.AddMapping(mappingBoule);
            elem.useTexture('textures/monde.jpg');
            elem.setModelMatrix(MTrans3D([3, 0, 0]));
            elem.ModifyModelMatrix(MRot3D([180 0 0]) * MScale3D(2), 1);
            elem.AddNormals(posBoule);
            
            % % piece d'echec depuis un fichier
            chessGeom = MyGeom(5, "face", "objets3D/chess4_ascii.stl");
            elem = viewer.AddElement(chessGeom);
            
            elem.setColor(rand(1, 3));
            elem.setModelMatrix(MTrans3D([2 0 2]) * MScale3D(0.02)); % pour la piece d'echec
            % chess.setModelMatrix(MTrans3D([2 0 2]) * MRot3D([-90 0 0]) * MScale3D(2)); % pour le loup
            elem.GenerateNormals();
            elem.setQuoiAfficher(3);
            elem.setModeRendu("UNIFORME", "DUR"); % uniform & dur
            
            ravie = Police("textes/ravie");
            geomTexte = GeomTexte(101, 'Hello World !', ravie, "CENTRE");
            elemtexte = viewer.AddElement(geomTexte);
            elemtexte.setModelMatrix(MTrans3D([2 2.2 2]) * MScale3D(0.4));
            
            geomTexteFixe = GeomTexte(102, 'Bienvenue', ravie, "HAUT_GAUCHE");
            elemtexte = viewer.AddElement(geomTexteFixe);
            elemtexte.setModelMatrix(MTrans3D([-1 1 0]));
            elemtexte.setOrientation("FIXE");
            
            geomTexteX = GeomTexte(111, 'X', ravie, "CENTRE");
            elementTexte = viewer.AddElement(geomTexteX);
            elementTexte.setModelMatrix(MTrans3D([1 0 0]));
            elementTexte.setColor([1 0 0]);
            elementTexte.setOrientation("REPERE_NORMAL");
            
            %% Creation d'un group
                % sphere avec des normales pour rendu lisse
                bouleNormalesGeom = MyGeom(31, "face", posBoule, indBoule);
                bouleNormalesGeom.setModelMatrix(MTrans3D([0 0.8 0]) * MScale3D(0.8));
                elem = viewer.AddElement(bouleNormalesGeom);
                elem.AddNormals(posBoule);
                elem.setCouleurArretes([1 0 1 1]);
                
                % autre sphere
                bouleNormalesGeom2 = MyGeom(32, "face", posBoule, indBoule);
                bouleNormalesGeom2.setModelMatrix(MTrans3D([0 3.9 0]) * MScale3D(1.2));
                elem = viewer.AddElement(bouleNormalesGeom2);
                elem.setColor([0 1 0.8 1]);
                
                % pyramide avec texture
                pyraTexGeom = MyGeom(33, "face", posPyramide, indicesPyramide);
                pyraTexGeom.setModelMatrix(MTrans3D([0 1.8 0]) * MRot3D([0 -45 0]) * MScale3D(1.3));
                elem = viewer.AddElement(pyraTexGeom);
                
                elem.AddMapping(mappingPyramide);
                elem.useTexture('textures/briques.jpg');
                
                % plan
                [pos, ind, map] = generatePlan(3, 3);
                planGeom = MyGeom(34, "face", pos, ind);
                planGeom.setModelMatrix(MRot3D([90 0 0]));
                viewer.AddElement(planGeom);
                
                % creation du groupe
                group = viewer.CreateGroup(1);
                group.AddElem(viewer.mapElements(31));
                group.AddElem(viewer.mapElements(32));
                group.AddElem(viewer.mapElements(33));
                group.AddElem(viewer.mapElements(34));
                group.setModelMatrix(MTrans3D([3 3 -3]) * MRot3D([0 45 0]));
            
            [posLight, indLight] = generatePyramide(50, 1);
            bouleLightGeom = MyGeom(1000, "face", posLight, indLight);
            elem = viewer.lumiere.setForme(bouleLightGeom);
            
            %%%%  affichage  %%%%
            viewer.DrawScene();
            
            %%%%  suppression  %%%%
            % viewer.delete();            
        end
    end

    %test and debug with member functions
    methods
        function test1(obj)
            
            addpath('outils\');
            addpath('java\');
            addpath('Component\');
            
            viewer = obj;
            viewer.setBackgroundColor([0 0 0.4])
            viewer.lumiere.dotLight(0.01, 0); % lumiere ponctuelle d'intensité 1 / (a * dist² + b * dist + 1)
            viewer.lumiere.setColor([1 1 1]);
            viewer.DrawScene();
            %%%%  definition des objets  %%%%
            
            % generation des parametre de la pyramide
            [posPyramide, indicesPyramide, mappingPyramide] = generatePyramide(4, 0.8);
            
            % pyramide avec une couleur par sommet
            pyraColorGeom = GeomFace(1, posPyramide, indicesPyramide);
            viewer.AddElement(pyraColorGeom);
            
            couleurPyramide = [ 1 0 0 1 ; 1 1 0 1 ; 0 1 0 1 ; 0 0.6 1 1 ; 1 1 1 0];
            elem = viewer.mapElements(1);
            elem.setModelMatrix(MTrans3D([-7 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
            elem.AddColor(couleurPyramide);
            
            % % nuage de points avec une couleur par sommet
            N = 10000;
            m = -1; M = 1;
            posPoints=rand(N,3)*(M-m)+m;
            cloudGeom = GeomPoint(25, posPoints);
            elem = viewer.AddElement(cloudGeom);
            elem.setModelMatrix(MTrans3D([-2 4 -4]) * MRot3D([0 0 45]) * MScale3D(1));
            
            couleurPoints = rand(N,3);
            elem.AddColor(couleurPoints);
            
            % % generation des données d'une sphere
            [posBoule, indBoule, mappingBoule] = generateSphere(12, 16, pi * 2);
            
            % % sphere wireframe
            bouleGeom = MyGeom(2, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleGeom);
            
            elem.setCouleurArretes([1 1 0]);
            elem.setEpaisseurArretes(3);
            elem.setQuoiAfficher(2);
            elem.setModelMatrix(MTrans3D([-4 1 0]));
            
            % % sphere avec texture map monde
            bouleTexGeom = MyGeom(3, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleTexGeom);
            
            elem.AddMapping(mappingBoule);
            elem.useTexture('textures/monde.jpg');
            elem.setModelMatrix(MTrans3D([3, 0, 0]));
            elem.ModifyModelMatrix(MRot3D([180 0 0]) * MScale3D(2), 1);
            elem.AddNormals(posBoule);
            
            % % piece d'echec depuis un fichier
            chessGeom = MyGeom(5, "face", "objets3D/chess4_ascii.stl");
            elem = viewer.AddElement(chessGeom);
            
            elem.setColor(rand(1, 3));
            elem.setModelMatrix(MTrans3D([2 0 2]) * MScale3D(0.02)); % pour la piece d'echec
            % chess.setModelMatrix(MTrans3D([2 0 2]) * MRot3D([-90 0 0]) * MScale3D(2)); % pour le loup
            elem.GenerateNormals();
            elem.setQuoiAfficher(3);
            elem.setModeRendu("UNIFORME", "DUR"); % uniform & dur
            
            ravie = Police("textes/ravie");
            geomTexte = GeomTexte(101, 'Hello World !', ravie, "CENTRE");
            elemtexte = viewer.AddElement(geomTexte);
            elemtexte.setModelMatrix(MTrans3D([2 2.2 2]) * MScale3D(0.4));
            
            geomTexteFixe = GeomTexte(102, 'Bienvenue', ravie, "HAUT_GAUCHE");
            elemtexte = viewer.AddElement(geomTexteFixe);
            elemtexte.setModelMatrix(MTrans3D([-1 1 0]));
            elemtexte.setOrientation("FIXE");
            
            geomTexteX = GeomTexte(111, 'X', ravie, "CENTRE");
            elementTexte = viewer.AddElement(geomTexteX);
            elementTexte.setModelMatrix(MTrans3D([1 0 0]));
            elementTexte.setOrientation("REPERE_NORMAL");
            
            %% Creation d'un group
                % sphere avec des normales pour rendu lisse
                bouleNormalesGeom = MyGeom(31, "face", posBoule, indBoule);
                bouleNormalesGeom.setModelMatrix(MTrans3D([0 0.8 0]) * MScale3D(0.8));
                elem = viewer.AddElement(bouleNormalesGeom);
                elem.AddNormals(posBoule);
                elem.setCouleurArretes([1 0 1 1]);
                
                % autre sphere
                bouleNormalesGeom2 = MyGeom(32, "face", posBoule, indBoule);
                bouleNormalesGeom2.setModelMatrix(MTrans3D([0 3.9 0]) * MScale3D(1.2));
                elem = viewer.AddElement(bouleNormalesGeom2);
                elem.setColor([0 1 0.8 1]);
                
                % pyramide avec texture
                pyraTexGeom = MyGeom(33, "face", posPyramide, indicesPyramide);
                pyraTexGeom.setModelMatrix(MTrans3D([0 1.8 0]) * MRot3D([0 -45 0]) * MScale3D(1.3));
                elem = viewer.AddElement(pyraTexGeom);
                
                elem.AddMapping(mappingPyramide);
                elem.useTexture('textures/briques.jpg');
                
                % plan
                [pos, ind, map] = generatePlan(3, 3);
                planGeom = MyGeom(34, "face", pos, ind);
                planGeom.setModelMatrix(MRot3D([90 0 0]));
                viewer.AddElement(planGeom);
                
                % creation du groupe
                group = viewer.CreateGroup(1);
                group.AddElem(viewer.mapElements(31));
                group.AddElem(viewer.mapElements(32));
                group.AddElem(viewer.mapElements(33));
                group.AddElem(viewer.mapElements(34));
                group.setModelMatrix(MTrans3D([3 3 -3]) * MRot3D([0 45 0]));
            
            [posLight, indLight] = generatePyramide(50, 1);
            bouleLightGeom = MyGeom(1000, "face", posLight, indLight);
            elem = viewer.lumiere.setForme(bouleLightGeom);
            
            %%%%  affichage  %%%%
            viewer.DrawScene();
            
            %%%%  suppression  %%%%
            % viewer.delete();            
        end

        function test2(obj)
            
            addpath('outils\');
            addpath('java\');
            addpath('Component\');
            
            viewer = obj;
            viewer.setBackgroundColor([0.05 0.05 0.1]);
            viewer.lumiere.dotLight(0.01, 0); % lumiere ponctuelle d'intensité 1 / (a * dist² + b * dist + 1)
            viewer.lumiere.setColor([1 1 1]);
            viewer.DrawScene();

            %welcome message
            viewer.fenetre.setTextNorth('Welcome in virtual X-ray Imaging',10);

            %%%%  definition des objets  %%%%
            
            % generation des parametre de la pyramide
            [posPyramide, indicesPyramide, mappingPyramide] = generatePyramide(4, 0.8);
            
            % pyramide avec une couleur par sommet
            pyraColorGeom = GeomFace(1, posPyramide, indicesPyramide);
            viewer.AddElement(pyraColorGeom);
            
            couleurPyramide = [ 1 0 0 1 ; 1 1 0 1 ; 0 1 0 1 ; 0 0.6 1 1 ; 1 1 1 0];
            elem = viewer.mapElements(1);
            elem.setModelMatrix(MTrans3D([-7 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
            elem.AddColor(couleurPyramide);
            
            % % nuage de points avec une couleur par sommet
            N = 10000;
            m = -1; M = 1;
            posPoints=rand(N,3)*(M-m)+m;
            cloudGeom = GeomPoint(25, posPoints);
            elem = viewer.AddElement(cloudGeom);
            elem.setModelMatrix(MTrans3D([-2 4 -4]) * MRot3D([0 0 45]) * MScale3D(1));
            
            couleurPoints = rand(N,3);
            elem.AddColor(couleurPoints);
            
            % % generation des données d'une sphere
            [posBoule, indBoule, mappingBoule] = generateSphere(12, 16, pi * 2);
            
            % % sphere wireframe
            bouleGeom = MyGeom(2, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleGeom);
            
            elem.setCouleurArretes([1 1 0]);
            elem.setEpaisseurArretes(3);
            elem.setQuoiAfficher(2);
            elem.setModelMatrix(MTrans3D([-4 1 0]));
            
            % % sphere avec texture map monde
            bouleTexGeom = MyGeom(3, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleTexGeom);
            
            elem.AddMapping(mappingBoule);
            elem.useTexture('textures/monde.jpg');
            elem.setModelMatrix(MTrans3D([3, 0, 0]));
            elem.ModifyModelMatrix(MRot3D([180 0 0]) * MScale3D(2), 1);
            elem.AddNormals(posBoule);
            
            % % piece d'echec depuis un fichier
            chessGeom = MyGeom(5, "face", "objets3D/chess4_ascii.stl");
            elem = viewer.AddElement(chessGeom);
            
            elem.setColor(rand(1, 3));
            elem.setModelMatrix(MTrans3D([2 0 2]) * MScale3D(0.02)); % pour la piece d'echec
            % chess.setModelMatrix(MTrans3D([2 0 2]) * MRot3D([-90 0 0]) * MScale3D(2)); % pour le loup
            elem.GenerateNormals();
            elem.setQuoiAfficher(3);
            elem.setModeRendu("UNIFORME", "DUR"); % uniform & dur
            
            ravie = Police("textes/ravie");
            geomTexte = GeomTexte(101, 'Hello World !', ravie, "CENTRE");
            elemtexte = viewer.AddElement(geomTexte);
            elemtexte.setModelMatrix(MTrans3D([2 2.2 2]) * MScale3D(0.4));
            
            geomTexteFixe = GeomTexte(102, 'Bienvenue', ravie, "HAUT_GAUCHE");
            elemtexte = viewer.AddElement(geomTexteFixe);
            elemtexte.setModelMatrix(MTrans3D([-1 1 0]));
            elemtexte.setOrientation("FIXE");
            
            timesnewroman = Police("textes/timesnewroman");
            geomTexteX = GeomTexte(111, 'X', timesnewroman, "CENTRE");
            elementTexte = viewer.AddElement(geomTexteX);
            elementTexte.setModelMatrix(MTrans3D([1.3 0 0]));
            elementTexte.setColor([1 0 0]);
            elementTexte.setSize(0.3);
            elementTexte.setOrientation("REPERE_NORMAL");
            
            %% Creation d'un group
                % sphere avec des normales pour rendu lisse
                bouleNormalesGeom = MyGeom(31, "face", posBoule, indBoule);
                bouleNormalesGeom.setModelMatrix(MTrans3D([0 0.8 0]) * MScale3D(0.8));
                elem = viewer.AddElement(bouleNormalesGeom);
                elem.AddNormals(posBoule);
                elem.setCouleurArretes([1 0 1 1]);
                
                % autre sphere
                bouleNormalesGeom2 = MyGeom(32, "face", posBoule, indBoule);
                bouleNormalesGeom2.setModelMatrix(MTrans3D([0 3.9 0]) * MScale3D(1.2));
                elem = viewer.AddElement(bouleNormalesGeom2);
                elem.setColor([0 1 0.8 1]);
                
                % pyramide avec texture
                pyraTexGeom = MyGeom(33, "face", posPyramide, indicesPyramide);
                pyraTexGeom.setModelMatrix(MTrans3D([0 1.8 0]) * MRot3D([0 -45 0]) * MScale3D(1.3));
                elem = viewer.AddElement(pyraTexGeom);
                
                elem.AddMapping(mappingPyramide);
                elem.useTexture('textures/briques.jpg');
                
                % plan
                [pos, ind, map] = generatePlan(3, 3);
                planGeom = MyGeom(34, "face", pos, ind);
                planGeom.setModelMatrix(MRot3D([90 0 0]));
                viewer.AddElement(planGeom);
                
                % creation du groupe
                group = viewer.CreateGroup(1);
                group.AddElem(viewer.mapElements(31));
                group.AddElem(viewer.mapElements(32));
                group.AddElem(viewer.mapElements(33));
                group.AddElem(viewer.mapElements(34));
                group.setModelMatrix(MTrans3D([3 3 -3]) * MRot3D([0 45 0]));
            
            [posLight, indLight] = generatePyramide(50, 1);
            bouleLightGeom = MyGeom(1000, "face", posLight, indLight);
            elem = viewer.lumiere.setForme(bouleLightGeom);
            
            %%%%  affichage  %%%%
            viewer.DrawScene();
            
            %%%%  suppression  %%%%
            % viewer.delete();            
        end
        
    end

end % fin de la classe Scene3D