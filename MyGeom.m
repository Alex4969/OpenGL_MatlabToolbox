classdef MyGeom < GeomComponent
    %MYGEOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        enable logical
    end
    
    methods
        function obj = MyGeom(id, points, connectivite, type)
            %MYGEOM
            obj@GeomComponent(id);
            obj.listePoints = points;
            obj.listeConnection = connectivite;
            obj.type = type;
            obj.enable = true;
        end % fin constructeur MyGeom
    end % fin des methodes defauts
end % Fin classe GeomComponent