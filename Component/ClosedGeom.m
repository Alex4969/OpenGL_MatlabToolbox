classdef (Abstract) ClosedGeom < GeomComponent
    %CLOSEDGEOM parent des formes non modifiables manuellement de la scene
    %3D (axes, gyroscopes, textes...)
    properties (GetAccess = public, SetAccess = protected)
        attributes string %contient le nom des attributs (mapping, police, couleur) a changer
                          % permet de remettre a jour cela lors des modification de geometrie
    end

    methods
        function obj = ClosedGeom(id, type)
            obj@GeomComponent(id, type);
        end % fin du constructeur de ClosedGeom
    end % fin des methodes defaut
end % fin classe ClosedGeom