classdef Ensemble < handle
    %ENSEMBLE Summary of this class goes here
    %   Detailed explanation goes here

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
        end

        function AddToModelMatrix(obj, model, after)
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
    end % fin methodes defauts
end % fin classe Ensemble