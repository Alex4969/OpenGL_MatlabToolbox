classdef (Abstract) VisibleElement < handle
    %VISIBLEELEMENT 
    
    properties (GetAccess = public, SetAccess = protected)
        Type string
        Geom GeomComponent
        GLGeom GLGeometry
        shader ShaderProgram
        typeShading    = 'S'    % 'S' : Sans    , 'L' : Lisse, 'D' : Dur
        typeColoration = 'U'    % 'U' : Uniforme, 'C' : Color, 'T' : Texture

        parent
    end

    properties (Access = public)
        typeOrientation uint8 = 1 % '0001' Perspective, '0010' Normale a l'ecran, '0100' orthonorme, '1000' fixe, '0000' rien (pour framebuffer)
        visible logical = true
    end

    events
        evt_redraw          % l'element doit être redessiner
        evt_updateRendu     % le mode de rendu a été modifié et nécessite un changement de programme
    end     
    
    methods
        function obj = VisibleElement(gl, aGeom)
            %VISIBLEELEMENT
            obj.Geom = aGeom;
            obj.GLGeom = GLGeometry(gl, obj.Geom.listePoints, obj.Geom.listeConnection);

            addlistener(obj.Geom,'evt_updateGeom',@obj.cbk_evt_updateGeom);
        end % fin du constructeur de VisibleElement

        function model = getModelMatrix(obj)
            if isa(obj.parent, 'Ensemble')
                model = obj.parent.getModelMatrix() * obj.Geom.modelMatrix;
            else
                model = obj.Geom.modelMatrix;
            end
        end % fin de getModelMatrix

        function setModelMatrix(obj, newModel)
            obj.Geom.setModelMatrix(newModel);
        end % fin de setModelMatrix

        function ModifyModelMatrix(obj, matrix, after)
            if nargin < 3, after = 0; end
            obj.Geom.modifyModelMatrix(matrix, after);
        end % fin de ModifymodelMatrix

        function pos = getPosition(obj)
            mod = obj.getModelMatrix();
            pos = mod(1:3, 4)';
        end % fin de getPosition

        function b = isVisible(obj)
            if isa(obj.parent, 'Ensemble')
                b = (obj.visible && obj.parent.isVisible());
            else
                b = obj.visible;
            end
        end % fin de isVisible

        function id = getId(obj)
            id = obj.Geom.id;
        end % fin de getId

        function setParent(obj, newParent)
            obj.parent = newParent;
        end % fin de setParent

        function setModeRendu(obj, newTypeRendu, newTypeLumiere)
            if nargin == 3
                obj.typeShading = newTypeLumiere;
            end
            obj.typeColoration = newTypeRendu;
            notify(obj, 'evt_updateRendu');
        end % fin de setModeRendu

        function AddColor(obj, matColor)
            if size(matColor, 1) == 1
                obj.setCouleur(matColor);
                obj.typeColoration = 'U';
            else
                obj.GLGeom.addDataToBuffer(matColor, 2);
                obj.typeColoration = 'C';
            end
            notify(obj, 'evt_updateRendu');
        end % fin de AddColor

        function cbk_evt_updateGeom(obj, source, ~)
            obj.GLGeom.nouvelleGeom(obj.Geom.listePoints, obj.Geom.listeConnection);
            if obj.Type == "Texte"
                obj.AddMapping(source.mapping);
                obj.changePolice();
            else
                obj.typeColoration = 'U';
                notify(obj, 'evt_updateRendu');
            end
        end % fin de cbk_evt_updateGeom

        function toString(obj)
            nbPoint = size(obj.Geom.listePoints, 1);
            nbTriangle = numel(obj.Geom.listeConnection)/3;
            disp(['L objet contient ' num2str(nbPoint) ' points et ' num2str(nbTriangle) ' triangles']);
            disp(['Le vertex Buffer contient : ' num2str(obj.GLGeom.nLayout(1)) ' valeurs pour la position, ' ...
                num2str(obj.GLGeom.nLayout(2)) ' valeurs pour la couleur, ' num2str(obj.GLGeom.nLayout(3)) ...
                ' valeurs pour le texture mapping, ' num2str(obj.GLGeom.nLayout(4)) ' valeurs pour les normales'])
        end % fin de toString

        function delete(obj, gl)
            obj.GLGeom.delete(gl);
            obj.shader.delete(gl);
        end % fin de delete

        function oldShader = setShader(obj, newShader)
            oldShader = obj.shader;
            obj.shader = newShader;
        end % fin de setShader

        function glUpdate(obj, gl, ~)
            obj.shader = ShaderProgram(gl, obj.GLGeom.nLayout, obj.Type, obj.typeColoration, obj.typeShading);
        end % fin de glUpdate
    end % fin des methodes defauts

    methods (Abstract = true)
        Draw(obj, gl)
        setCouleur(obj, matColor)
        sNew = select(obj, s)
        sNew = deselect(obj, s)
    end % fin des methodes abstraites
end % fin de la classe VisibleElement