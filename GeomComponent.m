classdef GeomComponent < handle
    %GEOMETRIE contient les propriété d'une géometrie
    %Cette classe ne permet que de faire des test et sera remplacer par la
    %vrai classe Geometrie en fin de projet
    
    properties (GetAccess = public, SetAccess = protected)
        id int32            % id unique pour chaque géometrie, defini par le programmeur
        type string
        listePoints         % matrice nx3 ou nx2 contenant les points dans l'espace
        listeConnection     % matrice ligne donne la connectivité en triangle des points de la liste de points
        modelMatrix=eye(4)  % transformation du modèle dans la scène 3D (translation, rotation, homothétie)
    end

    events
        geomUpdate
        modelUpdate
    end
    
    methods
        function obj = GeomComponent(id)
            %GEOMCOMPONENT
            obj.id = id;
        end % fin du constructeur

        function modifyModelMatrix(obj, model, after)
            %ADDTOMODELMATRIX multiplie la nouvelle matrice modele par
            %celle deja existante (avant ou apres selon after)
            if (nargin == 3 && after == 1)
                obj.setModelMatrix(obj.modelMatrix * model);
            else
                obj.setModelMatrix(model * obj.modelMatrix);
            end
        end % fin de modifyModelMatrix

        function setModelMatrix(obj, model)
            obj.modelMatrix = model;
            if event.hasListener(obj, 'modelUpdate')
                notify(obj, 'modelUpdate')
            end
        end % fin de setModelMatrix

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
    end % fin des methodes defaut
end % fin de la classe geometrie