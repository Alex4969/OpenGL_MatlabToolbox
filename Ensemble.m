classdef Ensemble < handle
    %ENSEMBLE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        id int32
        sousElements containers.Map
        visible logical
        groupMatrix = eye(4);
    end

    methods
        function obj = Ensemble()
        %ENSEMBLE Construct an instance of this class
            obj.visible = true;
            obj.sousElements = containers.Map('KeyType', int32, 'ValueType', 'any');
        end

        function AddElem(obj, elem)
            obj.sousElements(elem.getId()) = elem;
        end % fin de AddElem

        function mod = getModelMatrix(obj)
            mod = obj.groupMatrix;
        end % fin de getModelMatrix

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

        function Draw(obj, gl, camAttrib)
            listeElem = values(obj.sousElements); % trié ?
            for i=1:numel(listeElem)
                elem = listeElem{i};
                elem.Draw(gl, camAttrib, obj.groupMatrix * elem.getModelMatrix);
            end
        end
    end
end