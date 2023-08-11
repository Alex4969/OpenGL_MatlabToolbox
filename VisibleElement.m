classdef (Abstract) VisibleElement < handle
    %VISIBLEELEMENT 
    
    properties (GetAccess = public, SetAccess = protected)
        Type string
        Geom GeomComponent
        GLGeom GLGeometry
        shader ShaderProgram
        typeShading    = 'S'    % 'S' : Sans    , 'L' : Lisse, 'D' : Dur
        typeColoration = 'U'    % 'U' : Uniforme, 'C' : Color, 'T' : Texture
        newRendu logical = false

        parent
        geomListener
    end

    properties (Access = public)
        typeOrientation uint8 = 1 % '0001' Perspective, '0010' Normale a l'ecran, '0100' orthonorme, '1000' fixe, '0000' rien (pour framebuffer)
        visible logical = true
    end

    events
        evt_update
    end     
    
    methods
        function obj = VisibleElement(gl, aGeom)
            %VISIBLEELEMENT
            obj.Geom = aGeom;
            obj.GLGeom = GLGeometry(gl, obj.Geom.listePoints, obj.Geom.listeConnection);

            obj.geomListener = addlistener(obj.Geom,'geomUpdate',@obj.cbk_geomUpdate);
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

        function GenerateNormals(obj)
            normales = calculVertexNormals(obj.Geom.listePoints, obj.Geom.listeConnection);
            obj.GLGeom.addDataToBuffer(normales, 4);
            obj.typeShading = 'L';
            obj.newRendu = true;
        end % fin de GenerateNormals

        function cbk_geomUpdate(obj, source, ~)
            obj.GLGeom.nouvelleGeom(obj.Geom.listePoints, obj.Geom.listeConnection);
            if source.type == "texte"
                obj.AddMapping(source.mapping);
                obj.changePolice(source.police.name);
            else
                obj.typeColoration = 'U';
                obj.newRendu = true;
            end
        end % fin de cbk_geomUpdate

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
            obj.newRendu = false;
        end % fin de changerProg

        function oldShader = setShader(obj, gl, newShader)
            if obj.newRendu == true
                obj.changerProg(gl);
            end
            oldShader = obj.shader;
            obj.shader = newShader;
        end % fin de setShader

        function CommonDraw(obj, gl, camAttrib)
            %COMMONDRAW, fonction appele au debut de tous les draw des
            %objets. Definie le programme et le mode d'orientation
            if obj.newRendu == true
                obj.changerProg(gl);
            end
            obj.shader.Bind(gl);
            obj.GLGeom.Bind(gl);
            %typeOrientation '1000' fixe, '0100' Normale a l'ecran, '0010' orthonorme, '0001' perspective, '0' rien
            model = obj.getModelMatrix();
            if obj.typeColoration == 0 % seule modelMatrix (dans le repere ecran normalise) active
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
        setCouleur(obj, matColor)
        sNew = select(obj, s)
        sNew = deselect(obj, s)
    end % fin des methodes abstraites
end % fin de la classe VisibleElement