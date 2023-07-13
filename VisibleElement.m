classdef (Abstract) VisibleElement < handle
    %VISIBLEELEMENT 
    
    properties
        Geom Geometry
        GLGeom GLGeometry
        shader ShaderProgram
    end
    
    methods

        function obj = VisibleElement(aGeom)
            %VISIBLEELEMENT
            obj.Geom = aGeom;
        end % fin du constructeur de VisibleElement

        function SetAttributeSize(obj, nPos, nColor, nTextureMapping, nNormals)
            obj.GLGeom.SetVertexAttribSize(nPos, nColor, nTextureMapping, nNormals);
        end

        function res = GetAttrib(obj)
            res = [obj.GLGeom.nColor obj.GLGeom.nTextureMapping obj.GLGeom.nNormals];
            res = logical(res);
        end

        function model = GetModelMatrix(obj)
            model = obj.Geom.modelMatrix;
        end

        function SetModelMatrix(obj, newModel)
            obj.Geom.SetModelMatrix(newModel);
        end

        function ModifyModelMatrix(obj, matrix, after)
            if nargin < 3, after = 0; end
            obj.Geom.AddToModelMatrix(matrix, after);
        end

        function Delete(obj, gl)
            obj.GLGeom.Delete(gl);
        end % fin de Delete

    end % fin des methodes defauts

    methods (Abstract = true)
        
        Init(obj, gl)
        Draw(obj, gl)

    end % fin des methodes abstraites

end % fin de la classe VisibleElement

