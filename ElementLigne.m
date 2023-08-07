classdef ElementLigne < VisibleElement
    %ELEMENTLIGNE
    
    properties
        epaisseurLignes = 2             % float
        couleurLignes   = [1 0 0 1]     % 1x4
    end
    
    methods

        function obj = ElementLigne(gl, aGeom)
            %ELEMENTLIGNE
            obj@VisibleElement(gl, aGeom);
            obj.Type = 'Line';
            obj.changerProg(gl);
        end % fin du constructeur ElementLigne

        function Draw(obj, gl, camAttrib, model)
            %DRAW dessine cet objet
            if obj.visible == 0
                return
            end
            if nargin == 3
                model = obj.getModelMatrix();
            end
            obj.CommonDraw(gl, camAttrib, model);

            gl.glLineWidth(obj.epaisseurLignes);
            if (obj.GLGeom.nLayout(2) == 0)
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleurLignes);
            end
            gl.glDrawElements(gl.GL_LINES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

            CheckError(gl, 'apres le dessin');
        end % fin de Draw

        function setEpaisseur(obj, newEp)
            obj.epaisseurLignes = newEp;
            notify(obj,'evt_update');
        end

        function setCouleur(obj, newColor)
            if numel(newColor) == 3
                newColor(4) = 1;
            end
            if numel(newColor) == 4
                obj.couleurLignes = newColor;
            else
                warning('mauvaise matrice de couleur, annulation');
            end
        end % fin de setCouleur

        function setMainColor(obj, matColor)
            obj.setCouleur(matColor);
        end % fin de setMainColor

        function sNew = reverseSelect(obj, s)
            sNew.id        = obj.getId();
            sNew.couleur   = obj.couleurLignes;
            sNew.epaisseur = obj.epaisseurLignes;
            obj.couleurLignes   = s.couleur;
            obj.epaisseurLignes = s.epaisseur;
        end % fin de reverseSelect
    end % fin des methodes defauts
end  % fin classe ElementLigne