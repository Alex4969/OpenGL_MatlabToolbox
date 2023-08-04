classdef (Abstract) VisibleElement < handle
    %VISIBLEELEMENT 
    
    properties (GetAccess = public, SetAccess = protected)
        Type string
        Geom Geometry
        GLGeom GLGeometry
        shader ShaderProgram
        typeLumiere = 'S'
        typeRendu = 'D'
        newRendu logical
    end

    properties (Access = public)
        typeOrientation uint16 % '1000' Perspective, '0100' Normale a l'ecran, '0010' Fixe, '0001' orthonormé, 'R' rien
        visible = true
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
            obj.typeOrientation = 1;

            addlistener(obj.Geom,'geomUpdate',@obj.cbk_geomUpdate);
        end % fin du constructeur de VisibleElement

        function model = getModelMatrix(obj)
            model = obj.Geom.modelMatrix;
        end

        function setModelMatrix(obj, newModel)
            obj.Geom.setModelMatrix(newModel);
        end

        function ModifyModelMatrix(obj, matrix, after)
            if nargin < 3, after = 0; end
            obj.Geom.AddToModelMatrix(matrix, after);
        end

        function pos = getPosition(obj)
            pos = obj.Geom.modelMatrix(1:3, 4);
            pos = pos';
        end % fin de getPosition

        function AddColor(obj, matColor)
            if size(matColor, 1) == 1
                obj.setMainColor(matColor);
                obj.typeRendu = 'D';
            else
                obj.GLGeom.addDataToBuffer(matColor, 2);
                obj.typeRendu = 'C';
            end
            obj.newRendu = true;
        end

        function AddMapping(obj, matMapping)
            obj.GLGeom.addDataToBuffer(matMapping, 3);
            obj.typeRendu = 'T';
            obj.newRendu = true;
        end

        function AddNormals(obj, matNormales)
            obj.GLGeom.addDataToBuffer(matNormales, 4);
            obj.typeLumiere = 'L';
            obj.newRendu = true;
        end

        function cbk_geomUpdate(obj, ~, ~)
            obj.GLGeom.nouvelleGeom(obj.Geom.listePoints, obj.Geom.listeConnection, true);
            if size(obj.Geom.listePoints, 2) == 2
                obj.typeLumiere = 'S';
            else
                obj.typeLumiere = 'D';
            end
            obj.typeRendu = 'D';
            obj.newRendu = true;
        end

        function AddPoints(obj, plusDePoints, plusDeConnectivite)
            newDim = size(plusDePoints, 2);
            if newDim ~= size(obj.GLGeom.vertexData, 2)
                if newDim ~= obj.GLGeom.nLayout(1)
                    warning('passage de 2D a 3D impossible, Annulation')
                    return;
                end
                warning('Les sommets ne sont pas composés de la même facon, suppression des couleurs')
                if newDim == 2
                    obj.typeLumiere = 'S';
                else
                    obj.typeLumiere = 'D';
                end
                obj.typeRendu = 'D';
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

        function GenerateNormals(obj)
            normales = calculVertexNormals(obj.Geom.listePoints, obj.Geom.listeConnection);
            obj.GLGeom.addDataToBuffer(normales, 4);
            obj.typeLumiere = 'L';
            obj.newRendu = true;
        end % fin de GenerateNormals

        function id = getId(obj)
            id = obj.Geom.id;
        end

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

        function setModeRendu(obj, newTypeRendu, newTypeLumiere)
            if nargin == 3
                obj.typeLumiere = newTypeLumiere;
            end
            obj.typeRendu = newTypeRendu;
            obj.newRendu = true;
        end % fin de setModeRendu

        function changerProg(obj, gl)
            nLayout = obj.GLGeom.nLayout;
            typeL = obj.typeLumiere;
            if typeL == 'L' && nLayout(4) == 0
                warning('L objet ne contient pas de normales aux sommets')
                typeL = 'D';
            end
            if nLayout(3) > 0 && isempty(obj.texture)
                nLayout(3) = 0;
            end
            switch obj.typeRendu
                case 'T' % texture
                    if nLayout(3) > 0
                        nLayout(2) = 0;
                    end
                case 'C' % color
                    if nLayout(2) > 0
                        nLayout(3) = 0;
                    end
                case 'D'
                    nLayout([2, 3]) = 0;
            end
            obj.shader = ShaderProgram(gl, nLayout, typeL);
        end % fin de changerProg

        function CommonDraw(obj, gl, camAttrib, model)
            %COMMONDRAW, fonction appele au debut de tous les draw des
            %objets. Definie le programme et le mode d'orientation
            if obj.newRendu == true
                obj.newRendu = false;
                obj.changerProg(gl);
            end
            obj.shader.Bind(gl);
            obj.GLGeom.Bind(gl);
            if obj.typeOrientation == 0
                cam = eye(4);
            elseif obj.typeOrientation == 1
                cam = camAttrib.proj * camAttrib.view;
            elseif obj.typeOrientation == 8
                model(1, 4) = model(1, 4) * camAttrib.maxX;
                model(2, 4) = model(2, 4) * camAttrib.maxY;
                model(3, 4) = -camAttrib.near;
                model = model * MScale3D(camAttrib.coef);
                cam =  camAttrib.proj;
            else
                if bitand(obj.typeOrientation, 2) > 0
                    model(1:3, 1:3) = camAttrib.view(1:3, 1:3) \ model(1:3, 1:3);
                    cam =  camAttrib.proj * camAttrib.view;
                end
                if bitand(obj.typeOrientation, 4) > 0
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
        Draw(obj, gl, camAttrib, model)
        sNew = reverseSelect(obj, s)
        setMainColor(obj, matColor)
    end % fin des methodes abstraites
end % fin de la classe VisibleElement