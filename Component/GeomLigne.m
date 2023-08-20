classdef GeomLigne < MyGeom % < GeomComponent
    %GEOMFACE : Ma géometrie de type face
    properties
    end

    methods
        function obj = GeomLigne(id, points, connectivite)
            if nargin == 2, connectivite = 0; end
            obj@MyGeom(id, "ligne", points, connectivite);
        end % fin constructeur de GeomLigne

        % Methodes pour calculer l'aire, le perimetre,...
    end % fin des methodes défauts
end % fin de classe GeomFace