classdef GeomFace < MyGeom % < GeomComponent
    %GEOMFACE : Ma géometrie de type face
    properties
    end

    methods
        function obj = GeomFace(id, points, connectivite)
            if nargin == 2, connectivite = 0; end
            obj@MyGeom(id, "face", points, connectivite);
        end % fin constructeur de GeomFace

        % Methodes pour calculer l'aire, le perimetre,...
    end % fin des methodes défauts
end % fin de classe GeomFace