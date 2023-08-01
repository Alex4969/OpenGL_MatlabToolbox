classdef ElementPoint < VisibleElement
    %ELEMENTLIGNE
    
    properties
        epaisseurLignes     % float
        couleurLignes       % 1x4
    end
    
    methods

        function obj = ElementPoint(aGeom, epaisseur, couleur)
            %ELEMENTLIGNE
            obj@VisibleElement(aGeom);

            if nargin < 2, epaisseur = 2; end
            if nargin < 3, couleur = [1 1 1 1]; end
            obj.epaisseurLignes = epaisseur;
            obj.couleurLignes   = couleur;
        end % fin du constructeur ElementLigne

        function Draw(obj, gl)
            %DRAW dessine cet objet
            if obj.visible == 0
                return
            end
            obj.GLGeom.Bind(gl);
            obj.verifNewProg(gl);
            obj.shader.SetUniformMat4(gl, 'uModelMatrix', obj.Geom.modelMatrix);

            gl.glPointSize(obj.epaisseurLignes);
            gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_POINT);
            if (obj.GLGeom.nLayout(2) == 0)
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleurLignes);
            end
            gl.glDrawElements(gl.GL_POINTS, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

            CheckError(gl, 'apres le dessin');
            obj.GLGeom.Unbind(gl);
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