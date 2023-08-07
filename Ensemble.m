classdef Ensemble < handle
    %ENSEMBLE Summary of this class goes here
    %   Detailed explanation goes here

    properties (GetAccess = public, SetAccess = protected)
        id int32
        sousElements containers.Map
        groupMatrix = eye(4);
        typeOrientation uint16
    end

    properties (Access = public)
        visible logical
    end    

    methods
        function obj = Ensemble(id, centre)
        %ENSEMBLE Construct an instance of this class
            if nargin == 2
                obj.groupMatrix(1:3, 4) = centre;
            end
            obj.id = id;
            obj.visible = true;
            obj.sousElements = containers.Map('KeyType', 'int32', 'ValueType', 'any');
            obj.typeOrientation = 1;
        end

        function AddElem(obj, elem)
            obj.sousElements(elem.getId()) = elem;
            elem.ModifyModelMatrix(MTrans3D(-obj.groupMatrix(1:3, 4)));
            elem.typeOrientation = obj.typeOrientation;
        end % fin de AddElem

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

        function pos = getPosition(obj)
            pos = obj.groupMatrix(1:3, 4);
            pos = pos';
        end % fin de getPosition

        function setTypeOrientation(obj, newType)
            obj.typeOrientation = newType;
            listeElem = values(obj.sousElements);
            for i=1:numel(listeElem)
                elem = listeElem{i};
                elem.typeOrientation = newType;
            end
        end

        function Draw(obj, gl, camAttrib)
            listeElem = values(obj.sousElements); % trié ?
            for i=1:numel(listeElem)
                elem = listeElem{i};
                elem.Draw(gl, camAttrib, obj.groupMatrix * elem.getModelMatrix);
            end
        end
    end
end