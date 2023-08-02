classdef ElementPoint < VisibleElement
    %ELEMENTPOINT
    
    properties
        epaisseurLignes = 2             % float
        couleurLignes   = [1 0 0 1]     % 1x4
    end
    
    methods

        function obj = ElementPoint(gl, aGeom)
            %ELEMENTLIGNE
            obj@VisibleElement(gl, aGeom);
            obj.Type='Point';
        end % fin du constructeur ElementLigne

        function Draw(obj, gl, camAttrib)
            %DRAW dessine cet objet
            if obj.visible == 0
                return
            end
            
            obj.CommonDraw(gl, camAttrib);

            gl.glPointSize(obj.epaisseurLignes);
            gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_POINT);
            if (obj.GLGeom.nLayout(2) == 0)
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleurLignes);
            end
            gl.glDrawElements(gl.GL_POINTS, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

            CheckError(gl, 'apres le dessin');
        end % fin de Draw

        function setEpaisseur(obj, newEp)
            obj.epaisseurLignes = newEp;
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

        function sNew = reverseSelect(obj, s)
            sNew.id        = obj.getId();
            sNew.couleur   = obj.couleurLignes;
            sNew.epaisseur = obj.epaisseurLignes;
            obj.couleurLignes   = s.couleur;
            obj.epaisseurLignes = s.epaisseur;
        end
    end % fin des methodes defauts

end  % fin classe ElementLigne