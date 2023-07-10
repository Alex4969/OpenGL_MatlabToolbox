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
            %%%TODO TRAITER LE SHADER


        end % fin du constructeur de VisibleElement

        function SetAttributeSize(obj, nPos, nColor, nTextureMapping, nNormals)
            obj.GLGeom.SetVertexAttribSize(nPos, nColor, nTextureMapping, nNormals);
            %%%TODO TRAITER LE SHADER
        end

        function res = GetAttrib(obj)
            res = [obj.GLGeom.nColor obj.GLGeom.nTextureMapping obj.GLGeom.nNormals];
            res = logical(res);
        end

    end % fin des methodes defauts

    methods (Abstract = true)
        
        Init(obj, gl)
        Draw(obj, gl)
        Delete(obj, gl)

    end % fin des methodes abstraites

end % fin de la classe VisibleElement
