classdef (Abstract) ClosedGeom < GeomComponent
    %CLOSEDSHAPE parent des formes non modifiables manuellement de la scene
    %3D (axes, gyroscopes, textes...)
    methods
        function obj = ClosedGeom(id, type)
            obj@GeomComponent(id, type);
        end % fin du constructeur de ClosedGeom
    end % fin des methodes defaut
end % fin classe ClosedShape