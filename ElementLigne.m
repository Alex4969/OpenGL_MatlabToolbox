classdef ElementLigne < VisibleElement
    %ELEMENTLIGNE
    
    properties
        epaisseur = 2             % float
        couleur   = [1 0 0 1]     % 1x4
    end
    
    methods

        function obj = ElementLigne(gl, aGeom)
            %ELEMENTLIGNE
            obj@VisibleElement(gl, aGeom);
            obj.Type = 'Line';
            obj.changerProg(gl);
        end % fin du constructeur ElementLigne

        function Draw(obj, gl)
            %DRAW dessine cet objet
            if obj.isVisible() == false
                return
            end

            obj.shader.Bind(gl);
            obj.GLGeom.Bind(gl);
            obj.CommonDraw(gl);

            gl.glLineWidth(obj.epaisseur);
            if (obj.GLGeom.nLayout(2) == 0)
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleur);
            end
            gl.glDrawElements(gl.GL_LINES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

            CheckError(gl, 'apres le dessin');
        end % fin de Draw

        function setEpaisseur(obj, newEp)
            obj.epaisseur = newEp;
        end

        function setCouleur(obj, newColor)
            if numel(newColor) == 3
                newColor(4) = 1;
            end
            if numel(newColor) == 4
                obj.couleur = newColor;
            else
                warning('mauvaise matrice de couleur, annulation');
            end
        end % fin de setCouleur

        function sNew = reverseSelect(obj, s)
            sNew.id        = obj.getId();
            sNew.couleur   = obj.couleur;
            sNew.epaisseur = obj.epaisseur;
            obj.couleur   = s.couleur;
            obj.epaisseur = s.epaisseur;
        end % fin de reverseSelect
    end % fin des methodes defauts
end  % fin classe ElementLigne