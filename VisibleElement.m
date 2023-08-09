classdef (Abstract) VisibleElement < handle
    %VISIBLEELEMENT 
    
    properties (GetAccess = public, SetAccess = protected)
        Type char
        Geom GeomComponent
        GLGeom GLGeometry
        shader ShaderProgram
        typeShading    = 'S'    % 'S' : Sans    , 'L' : Lisse, 'D' : Dur
        typeColoration = 'U'    % 'U' : Uniforme, 'C' : Color, 'T' : Texture
        newRendu logical

        parent
    end

    properties (Access = public)
        typeOrientation uint8 % '0001' Perspective, '0010' Normale a l'ecran, '0100' orthonorme, '1000' fixe, '0000' rien (pour framebuffer)
        visible logical
    end

    events
        evt_update
    end     
    
    methods
        function obj = VisibleElement(gl, aGeom)
            %VISIBLEELEMENT
            obj.Geom = aGeom;
            obj.GLGeom = GLGeometry(gl, obj.Geom.listePoints, obj.Geom.listeConnection);
            obj.newRendu = false;
            obj.visible = true;
            obj.typeOrientation = 1;

            addlistener(obj.Geom,'geomUpdate',@obj.cbk_geomUpdate);
        end % fin du constructeur de VisibleElement

        function model = getModelMatrix(obj)
            if isa(obj.parent, 'Ensemble')
                model = obj.parent.getModelMatrix() * obj.Geom.modelMatrix;
            else
                model = obj.Geom.modelMatrix;
            end
        end % fin de getModelMatrix

        function setModelMatrix(obj, newModel)
            obj.Geom.setModelMatrix(newModel);
        end % fin de setModelMatrix

        function ModifyModelMatrix(obj, matrix, after)
            if nargin < 3, after = 0; end
            obj.Geom.modifyModelMatrix(matrix, after);
        end % fin de ModifymodelMatrix

        function pos = getPosition(obj)
            mod = obj.getModelMatrix();
            pos = mod(1:3, 4)';
        end % fin de getPosition

        function b = isVisible(obj)
            if isa(obj.parent, 'Ensemble')
                b = (obj.visible && obj.parent.isVisible());
            else
                b = obj.visible;
            end
        end % fin de isVisible

        function id = getId(obj)
            id = obj.Geom.id;
        end % fin de getId

        function setParent(obj, newParent)
            obj.parent = newParent;
        end % fin de setParent

        function setModeRendu(obj, newTypeRendu, newTypeLumiere)
            if nargin == 3
                obj.typeShading = newTypeLumiere;
            end
            obj.typeColoration = newTypeRendu;
            obj.newRendu = true;
        end % fin de setModeRendu

        function AddColor(obj, matColor)
            if size(matColor, 1) == 1
                obj.setCouleur(matColor);
                obj.typeColoration = 'U';
            else
                obj.GLGeom.addDataToBuffer(matColor, 2);
                obj.typeColoration = 'C';
            end
            obj.newRendu = true;
        end % fin de AddColor

        function AddMapping(obj, matMapping)
            obj.GLGeom.addDataToBuffer(matMapping, 3);
            obj.typeColoration = 'T';
            obj.newRendu = true;
        end % fin de AddMapping

        function AddNormals(obj, matNormales)
            obj.GLGeom.addDataToBuffer(matNormales, 4);
            obj.typeShading = 'L';
            obj.newRendu = true;
        end % fin de AddNormals

        function AddPoints(obj, plusDePoints, plusDeConnectivite)
            newDim = size(plusDePoints, 2);
            if newDim ~= size(obj.GLGeom.vertexData, 2)
                if newDim ~= obj.GLGeom.nLayout(1)
                    warning('passage de 2D a 3D impossible, Annulation')
                    return;
                end
                warning('Les sommets ne sont pas composés de la même facon, suppression des couleurs')
                if newDim == 2
                    obj.typeShading = 'S';
                else
                    obj.typeShading = 'D';
                end
                obj.typeColoration = 'U';
                obj.newRendu = true;
                nbSommets = size(obj.Geom.listePoints, 1);
                newPoints = [obj.Geom.listePoints(:, 1:newDim) ; plusDePoints];
                newConnectivite = plusDeConnectivite + nbSommets;
                newConnectivite = [obj.Geom.listeConnection, newConnectivite];
                obj.Geom.nouvelleGeom(newPoints, newConnectivite);
                obj.GLGeom.nouvelleGeom(newPoints, newConnectivite, true);
            else
                nPos = obj.GLGeom.nLayout(1);
                newPoints = [obj.Geom.listePoints ; plusDePoints(:, 1:nPos)];
                newVertexData = [obj.GLGeom.vertexData ; plusDePoints];
                nbSommets = size(obj.Geom.listePoints, 1);
                newConnectivite = plusDeConnectivite + nbSommets;
                newConnectivite = [obj.Geom.listeConnection, newConnectivite];
                obj.Geom.nouvelleGeom(newPoints, newConnectivite);
                obj.GLGeom.nouvelleGeom(newVertexData, newConnectivite, false);
            end
        end % fin de AddPoints

        function cbk_geomUpdate(obj, ~, ~)
            obj.GLGeom.nouvelleGeom(obj.Geom.listePoints, obj.Geom.listeConnection, true);
            if size(obj.Geom.listePoints, 2) == 2
                obj.typeShading = 'S';
            else
                obj.typeShading = 'D';
            end
            obj.typeColoration = 'U';
            obj.newRendu = true;
        end % fin de cbk_geomUpdate

        function GenerateNormals(obj)
            normales = calculVertexNormals(obj.Geom.listePoints, obj.Geom.listeConnection);
            obj.GLGeom.addDataToBuffer(normales, 4);
            obj.typeShading = 'L';
            obj.newRendu = true;
        end % fin de GenerateNormals

        function toString(obj)
            nbPoint = size(obj.Geom.listePoints, 1);
            nbTriangle = numel(obj.Geom.listeConnection)/3;
            disp(['L objet contient ' num2str(nbPoint) ' points et ' num2str(nbTriangle) ' triangles']);
            disp(['Le vertex Buffer contient : ' num2str(obj.GLGeom.nLayout(1)) ' valeurs pour la position, ' ...
                num2str(obj.GLGeom.nLayout(2)) ' valeurs pour la couleur, ' num2str(obj.GLGeom.nLayout(3)) ...
                ' valeurs pour le texture mapping, ' num2str(obj.GLGeom.nLayout(4)) ' valeurs pour les normales'])
        end % fin de toString

        function delete(obj, gl)
            obj.GLGeom.delete(gl);
            obj.shader.delete(gl);
        end % fin de delete

        function changerProg(obj, gl)
            obj.shader = ShaderProgram(gl, obj.GLGeom.nLayout, obj.Type, obj.typeColoration, obj.typeShading);
        end % fin de changerProg

        function CommonDraw(obj, gl, camAttrib)
            %COMMONDRAW, fonction appele au debut de tous les draw des
            %objets. Definie le programme et le mode d'orientation
            if obj.newRendu == true
                obj.newRendu = false;
                obj.changerProg(gl);
            end
            obj.shader.Bind(gl);
            obj.GLGeom.Bind(gl);
            %typeOrientation '1000' fixe, '0100' Normale a l'ecran, '0010' orthonorme, '0001' perspective, '0' rien
            model = obj.getModelMatrix();
            if obj.typeOrientation == 0 % seule modelMatrix (dans le repere ecran normalise) active
                cam = eye(4);
            elseif obj.typeOrientation == 1 %'0001' PERSPECTIVE
                cam = camAttrib.proj * camAttrib.view;
            elseif obj.typeOrientation == 8 %'1000' fixe (pour texte)
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
                if bitand(obj.typeOrientation, 2) > 0 % 0010 'face a l'ecran
                    model(1:3, 1:3) = camAttrib.view(1:3, 1:3) \ model(1:3, 1:3);
                    cam =  camAttrib.proj * camAttrib.view;
                    % cam*model = proj*view*inv(view)*model
                end
                if bitand(obj.typeOrientation, 4) > 0 %'0100' coin inferieur gauche 
                    % rotation seulement activée sur un point de l'ecran
                    cam = MProj3D('O', [camAttrib.ratio*16 16 1 20]) * camAttrib.view;
                    cam(1,4) = -0.97 + 0.1/camAttrib.ratio;
                    cam(2,4) = -0.87;
                    cam(3,4) =  0;
                end
            end
            obj.shader.SetUniformMat4(gl, 'uCamMatrix', cam);
            obj.shader.SetUniformMat4(gl, 'uModelMatrix', model);
        end % fin de commonDraw
    end % fin des methodes defauts

    methods (Abstract = true)
        Draw(obj, gl, camAttrib)
        sNew = reverseSelect(obj, s)
        setCouleur(obj, matColor)
    end % fin des methodes abstraites
end % fin de la classe VisibleElement