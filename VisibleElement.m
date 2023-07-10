classdef VisibleElement < handle
    %VISIBLEELEMENT 
    
    properties
        Geom Geometry
        GLGeom GLGeometry
        shaderId
    end
    
    methods

        function obj = VisibleElement(gl, aGeom)
            %VISIBLEELEMENT
            obj.Geom = aGeom;
            sommets = [ obj.Geom.listePoints obj.Geom.composanteSupp ];
            obj.GLGeom = GLGeometry(gl, sommets, obj.Geom.listeConnection);
            %%%TODO TRAITER LE SHADER


        end % fin du constructeur de VisibleElement

        function SetAttributeSize(obj, nPos, nColor, nTextureMapping, nNormals)
            obj.GLGeom.SetVertexAttribSize(nPos, nColor, nTextureMapping, nNormals);
            %%%TODO TRAITER LE SHADER
        end

    end % fin des methodes defauts

    methods (Abstract = true)
        
        Init(obj, gl)
        Draw(obj, gl)
        Delete(obj, gl)

    end % fin des methodes abstraites

end % fin de la classe VisibleElement

