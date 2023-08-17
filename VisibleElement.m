classdef (Abstract) VisibleElement < handle
    %VISIBLEELEMENT 
    
    properties (GetAccess = public, SetAccess = protected)
        Type            string
        Geom            % GeomComponent
        GLGeom          GLGeometry
        shader          ShaderProgram
        typeShading     (1,1) char    = 'S'    % 'S' : Sans    , 'L' : Lisse, 'D' : Dur
        typeColoration  (1,1) char    = 'U'    % 'U' : Uniforme, 'C' : Color, 'T' : Texture
        visible         logical       = true

        parent
        typeOrientation uint8 = 1 % '0001' Perspective, '0010' Normale a l'ecran, '0100' orthonorme, '1000' fixe
    end

    properties (Constant = true)
        enumOrientation = dictionary("PERPECTIVE", 1, "NORMAL", 2, "REPERE", 4, "REPERE_NORMAL", 6, "FIXE", 8);
        enumColoration  = dictionary("UNIFORME", 1, "PAR_SOMMET", 2, "TEXTURE", 4);
        enumShading     = dictionary("SANS", 16, "DUR", 32, "LISSE", 64);
    end

    events
        evt_redraw          % une modification necessite un redraw
        evt_updateRendu     % une modification necessite le contexte et un redraw (changement de programme)
    end     
    
    methods
        function obj = VisibleElement(gl, aGeom)
            %VISIBLEELEMENT
            obj.Geom = aGeom;
            obj.GLGeom = GLGeometry(gl, obj.Geom.listePoints, obj.Geom.listeConnection);

            addlistener(obj.Geom,'evt_updateGeom',@obj.cbk_updateGeom);
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

        function setVisibilite(obj, b)
            obj.visible = b;
        end % fin de setVisibilite

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

        function setOrientation(obj, newOrientation)
            if obj.enumOrientation.isKey(newOrientation)
                obj.typeOrientation = obj.enumOrientation(newOrientation);
                notify(obj, 'evt_redraw');
            else
                disp('Nouvelle orientation incorrect');
                disp(['Valeurs possibles : ' VisibleElement.enumOrientation.keys']);
            end
        end

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

        function cbk_updateGeom(obj, source, ~) % source = geomComponent
            obj.GLGeom.nouvelleGeom(obj.Geom.listePoints, obj.Geom.listeConnection);
            if isa(source, 'ClosedGeom')
                if any(source.attributes == "police")
                    obj.changePolice();
                end
                if any(source.attributes == "mapping")
                    obj.AddMapping(source.mapping);
                end
                if any(source.attributes == "color")
                    obj.AddColor(source.color);
                end
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