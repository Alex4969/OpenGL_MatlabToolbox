classdef MyGeom < GeomComponent
    %MYGEOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        enable logical = true
    end
    
    methods
        function obj = MyGeom(id, points, connectivite, type)
            %MYGEOM
            obj@GeomComponent(id);
            if size(points, 2) == 2
                disp('liste en 2D, transformation vers de la 3D');
                points(size(points, 1), 3) = 0;
            end
            obj.listePoints = points;
            obj.listeConnection = connectivite;
            obj.type = type;
        end % fin constructeur MyGeom

        function ajouterPoints(obj, plusDePoints, plusDeConnectivite)
            if size(plusDePoints, 2) == 2
                disp('Ajouts en 2D, passage en 3D');
                plusDePoints(size(plusDePoints, 1), 3) = 0;
            end

            nbSommet = size(obj.listePoints, 1);
            obj.listePoints = [obj.listePoints ; plusDePoints];
            obj.listeConnection = [obj.listeConnection, (plusDeConnectivite + nbSommet)];
            if event.hasListener(obj, 'evt_updateGeom')
                notify(obj, 'evt_updateGeom');
            end
        end % fin de ajouterPoints

        function nouvelleGeom(obj, newPoints, newIndices)
            if size(newPoints, 2) == 2
                disp('Nouvelle geom en 2D, passage en 3D');
                newPoints(size(newPoints, 1), 3) = 0;
            end

            obj.listePoints = newPoints;
            obj.listeConnection = newIndices;
            if event.hasListener(obj, 'evt_updateGeom')
                notify(obj, 'evt_updateGeom');
            end
        end
    end % fin des methodes defauts
end % Fin classe GeomComponent