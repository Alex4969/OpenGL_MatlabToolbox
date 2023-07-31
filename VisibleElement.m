classdef (Abstract) VisibleElement < handle
    %VISIBLEELEMENT 
    
    properties
        Geom Geometry
        GLGeom GLGeometry
        shader ShaderProgram
        typeLumiere = 'S'
        typeRendu = 'D'
        newRendu logical
        typeOrientation = 'P' % 'P' Perspective, 'N' Normale a l'ecran, 'F' Fixe, 'O' orthonormé

        visible logical
    end
    
    methods

        function obj = VisibleElement(aGeom)
            %VISIBLEELEMENT
            obj.Geom = aGeom;
            obj.GLGeom = GLGeometry(obj.Geom.listePoints);
            obj.visible = true;
            obj.newRendu = true;
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
            obj.GLGeom.addDataToBuffer(matColor, 2);
            obj.typeRendu = 'C';
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

        function GenerateNormals(obj)
            normales = calculVertexNormals(obj.Geom.listePoints, obj.Geom.listeConnection);
            obj.GLGeom.addDataToBuffer(normales, 4);
            obj.typeLumiere = 'L';
            obj.newRendu = true;
        end

        function id = getId(obj)
            id = obj.Geom.id;
        end

        function setId(obj, newId)
            obj.Geom.id = newId;
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

        function Init(obj, gl)
            obj.GLGeom.CreateGLObject(gl, obj.Geom.listeConnection);
            obj.verifNewProg(gl);
        end % fin de Init

        function setModeRendu(obj, newTypeRendu, newTypeLumiere)
            if nargin == 3
                obj.typeLumiere = newTypeLumiere;
            end
            obj.typeRendu = newTypeRendu;
            obj.newRendu = true;
        end % fin de setModeRendu

        function verifNewProg(obj, gl)
            if obj.newRendu
                obj.newRendu = false;
                obj.changerProg(gl);
            end
        end % fin de verifNewProg

        function changerProg(obj, gl)
            nLayout = obj.GLGeom.nLayout;
            typeL = obj.typeLumiere;
            if typeL == 'L' && nLayout(4) == 0
                warning('L objet ne contient pas de normales aux sommets')
                typeL = 'D';
            end
            if nLayout(3) > 0 && obj.textureId == -1
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
            obj.shader.Bind(gl);
        end % fin de changerProg
    end % fin des methodes defauts

    methods (Abstract = true)
        Draw(obj, gl)
        sNew = reverseSelect(obj, s)
    end % fin des methodes abstraites
end % fin de la classe VisibleElement

