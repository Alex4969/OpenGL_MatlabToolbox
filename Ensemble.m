classdef Ensemble < handle
    %ENSEMBLE permet de regrouper plusieurs element pour les déplacer ensemble

    properties (GetAccess = public, SetAccess = protected)
        id int32
        sousElements containers.Map
        groupMatrix = eye(4);
    end

    properties (Access = public)
        visible logical
    end    

    methods
        function obj = Ensemble(id)
        %ENSEMBLE Construct an instance of this class
            obj.id = id;
            obj.visible = true;
            obj.sousElements = containers.Map('KeyType', 'int32', 'ValueType', 'any');
        end % fin du constructeur Ensemble

        function AddElem(obj, elem)
            obj.sousElements(elem.getId()) = elem;
            elem.setParent(obj);
        end % fin de AddElem

        function mod = getModelMatrix(obj)
            mod = obj.groupMatrix;
        end % fin de getModelMatrix

        function b = isVisible(obj)
            b = obj.visible;
        end % fin de isVisible

        function elem = removeElem(obj, elemId)
            if obj.sousElements.isKey(elemId)
                elem = obj.sousElements(elemId);
                elem.setParent([]);
                obj.sousElements.remove(elemId);
            else
                disp('l objet a supprimer n est pas dans la liste')
            end
        end % fin de removeElem

        function modifyModelMatrix(obj, model, after)
            %ADDTOMODELMATRIX multiplie la nouvelle matrice modele par
            %celle deja existante (avant ou apres selon after)
            if (nargin == 3 && after == 1)
                obj.groupMatrix = obj.groupMatrix * model;
            else
                obj.groupMatrix = model * obj.groupMatrix;
            end
        end % fin de addToModelMatrix

        function setModelMatrix(obj, model)
            obj.groupMatrix = model;
        end % fin de setModelMatrix

        function delete(obj)
            listeElem = obj.sousElements.values;
            for i=1:numel(listeElem)
                listeElem{i}.setParent([]);
            end
        end
    end % fin methodes defauts
end % fin classe Ensemble