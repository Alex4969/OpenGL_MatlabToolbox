classdef (Abstract) VisibleElement < handle
    %VISIBLEELEMENT 
    
    properties
        Geom Geometry
        GLGeom GLGeometry
        shader ShaderProgram

        visible logical
    end
    
    methods

        function obj = VisibleElement(aGeom)
            %VISIBLEELEMENT
            obj.Geom = aGeom;
            obj.GLGeom = GLGeometry(obj.Geom.listePoints);
            obj.visible = true;
        end % fin du constructeur de VisibleElement

        function res = getLayout(obj)
            res = obj.GLGeom.nLayout;
        end

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
        end

        function AddMapping(obj, matMapping)
            obj.GLGeom.addDataToBuffer(matMapping, 3);
        end

        function AddNormals(obj, matNormales)
            obj.GLGeom.addDataToBuffer(matNormales, 4);
        end

        function GenerateNormals(obj)
            normales = calculVertexNormals(obj.Geom.listePoints, obj.Geom.listeConnection);
            obj.GLGeom.addDataToBuffer(normales, 4);
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
        end % fin de delete

        function Init(obj, gl)
            obj.GLGeom.CreateGLObject(gl, obj.Geom.listeConnection);
        end
    end % fin des methodes defauts

    methods (Abstract = true)
        Draw(obj, gl)
        sNew = reverseSelect(obj, s)
    end % fin des methodes abstraites

end % fin de la classe VisibleElement

