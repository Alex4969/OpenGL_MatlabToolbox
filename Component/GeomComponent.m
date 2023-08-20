classdef (Abstract) GeomComponent < handle
    % GEOMETRIE contient les propriétés d'une géometrie
    % 
    
    properties (GetAccess = public, SetAccess = protected)
        id              int32                 % id unique pour chaque géometrie, defini par le programmeur
        type            string {mustBeMember(type, ["face", "ligne", "point", "texte"])}
        listePoints     (:,3) double          % matrice nx3 ou nx2 contenant les points dans l'espace
        listeConnection (1,:) uint32          % matrice ligne donne la connectivité en triangle des points de la liste de points
        modelMatrix     (4,4) double = eye(4) % transformation du modèle dans la scène 3D (translation, rotation, homothétie)
    end

    events
        evt_updateGeom          % modification de la geometrie
        evt_updateModel         % modification de la matrice model ( pour redessiner ou modfifier la lumiere)
    end
    
    methods
        function obj = GeomComponent(id, type)
            %GEOMCOMPONENT
            obj.id = id;
            obj.type = type;
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
            if event.hasListener(obj, 'evt_updateModel')
                notify(obj, 'evt_updateModel')
            end
        end % fin de setModelMatrix
    end % fin des methodes defaut
end % fin de la classe geometrie