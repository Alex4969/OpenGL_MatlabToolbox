classdef ElementPoint < VisibleElement
    %ELEMENTPOINT
    
    properties
        epaisseur = 2             % float
        couleur   = [1 0 0 1]     % 1x4
    end
    
    methods

        function obj = ElementPoint(gl, aGeom)
            %ELEMENTLIGNE
            obj@VisibleElement(gl, aGeom);
            obj.Type = 'Point';
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

            gl.glPointSize(obj.epaisseur);
            if (obj.GLGeom.nLayout(2) == 0)
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleur);
            end
            % gl.glDrawArrays(gl.GL_POINTS, 0, size(obj.Geom.listePoints, 1));
            gl.glDrawElements(gl.GL_POINTS, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

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
        end
        
    end % fin des methodes defauts
end  % fin classe ElementLigne