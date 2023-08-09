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

        function ajouterPoints(obj, plusDePoints, plusDeConnectivite)
            if size(plusDePoints, 2) == size(obj.listePoints, 2)
                nbSommet = size(obj.listePoints, 1);
                obj.listePoints = [obj.listePoints ; plusDePoints];
                obj.listeConnection = [obj.listeConnection, (plusDeConnectivite + nbSommet)];
                if event.hasListener(obj, 'geomUpdate')
                    notify(obj, 'geomUpdate');
                end
            else 
                warning('Impossible de passer de la 2D a la 3D')
            end
        end % fin de ajouterPoints

        function nouvelleGeom(obj, newPoints, newIndices)
            obj.listePoints = newPoints;
            obj.listeConnection = newIndices;
        end
    end % fin des methodes defauts
end % Fin classe GeomComponent