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
            obj.visible = true;
        end % fin du constructeur de VisibleElement

        function setAttributeSize(obj, nPos, nColor, nTextureMapping, nNormals)
            obj.GLGeom.SetVertexAttribSize(nPos, nColor, nTextureMapping, nNormals);
        end

        function res = getAttrib(obj)
            res = [obj.GLGeom.nColor obj.GLGeom.nTextureMapping obj.GLGeom.nNormals];
            res = logical(res);
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

        function Delete(obj, gl)
            obj.GLGeom.Delete(gl);
        end % fin de Delete

        function ChangeGeom(obj, gl, pos, ind, supp)
            obj.GLGeom.Delete(gl);
            delete(obj.GLGeom);
            delete(obj.Geom);
            if nargin < 5
                obj.Geom = Geometry(pos, ind);
                obj.GLGeom = GLGeometry(gl, pos, ind);
            else
                obj.Geom = Geometry(pos, ind, supp);
                obj.GLGeom = GLGeometry(gl, [pos supp], ind);
            end
        end % fin de changeGeom

    end % fin des methodes defauts

    methods (Abstract = true)
        
        Init(obj, gl)
        Draw(obj, gl)

    end % fin des methodes abstraites

end % fin de la classe VisibleElement

