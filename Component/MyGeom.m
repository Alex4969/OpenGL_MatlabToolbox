classdef MyGeom < GeomComponent
    %MYGEOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        enable logical = true
    end
    
    methods
        function obj = MyGeom(id, type, points, connectivite)
            %MYGEOM construit une geometrie (liste de points et connectivité) a partir des valeurs en paramètre
            % ou d'un fichier STL si points est de type string
            obj@GeomComponent(id, type);
            if (isa(points, "string") || isa(points, "char"))
                obj.createFromFile(points);
            else
                if size(points, 2) == 2
                    disp('liste en 2D, transformation vers de la 3D');
                    points(size(points, 1), 3) = 0;
                end
                if nargin == 3 && type == "point"
                    connectivite = 1:size(points, 1);
                end
                obj.listePoints = points;
                obj.listeConnection = connectivite;
            end
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

    methods (Access = private)
        function createFromFile(obj, fileName)
            %CREATEFROMFILE créé un objet 3D a partir d'un fichier stl
            stlObj = IO_CADfile.readSTL(fileName, 1);
            obj.listePoints = stlObj.vertices;
            temp = stlObj.faces';
            temp = temp - 1;
            obj.listeConnection = temp(:);
        end % fin de createFromFile
    end % fin des methodes privées
end % Fin classe GeomComponent