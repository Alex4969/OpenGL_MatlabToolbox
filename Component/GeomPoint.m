classdef GeomPoint < MyGeom % < GeomComponent
    %GEOMFACE : Ma géometrie de type face
    properties
    end

    methods
        function obj = GeomPoint(id, points)
            obj@MyGeom(id, "point", points);
        end % fin constructeur de GeomPoint

        % Methodes pour calculer des choses
    end % fin des methodes défauts
end % fin de classe GeomFace