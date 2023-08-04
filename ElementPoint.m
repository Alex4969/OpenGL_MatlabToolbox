classdef ElementPoint < VisibleElement
    %ELEMENTPOINT
    
    properties
        epaisseurPoints = 2             % float
        couleurPoints   = [1 0 0 1]     % 1x4
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

            gl.glPointSize(obj.epaisseurPoints);
            gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_POINT);
            if (obj.GLGeom.nLayout(2) == 0)
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleurPoints);
            end
            gl.glDrawElements(gl.GL_POINTS, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

            CheckError(gl, 'apres le dessin');
        end % fin de Draw

        function setEpaisseur(obj, newEp)
            obj.epaisseurPoints = newEp;
        end

        function setCouleur(obj, newColor)
            if numel(newColor) == 3
                newColor(4) = 1;
            end
            if numel(newColor) == 4
                obj.couleurPoints = newColor;
            else
                warning('mauvaise matrice de couleur, annulation');
            end
        end % fin de setCouleur

        function setMainColor(obj, matColor)
            obj.setCouleur(matColor);
        end % fin de setMainColor

        function sNew = reverseSelect(obj, s)
            sNew.id        = obj.getId();
            sNew.couleur   = obj.couleurPoints;
            sNew.epaisseur = obj.epaisseurPoints;
            obj.couleurPoints   = s.couleur;
            obj.epaisseurPoints = s.epaisseur;
        end
        
    end % fin des methodes defauts
end  % fin classe ElementLigne