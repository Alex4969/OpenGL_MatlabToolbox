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

        function Draw(obj, gl)
            %DRAW dessine cet objet
            if obj.isVisible() == false
                return
            end
            obj.CommonDraw(gl);
            obj.shader.Bind(gl);
            obj.GLGeom.Bind(gl);

            gl.glPointSize(obj.epaisseur);
            if obj.typeColoration == 'U'
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleur);
            end
            % gl.glDrawArrays(gl.GL_POINTS, 0, size(obj.Geom.listePoints, 1));
            gl.glDrawElements(gl.GL_POINTS, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

            CheckError(gl, 'apres le dessin');
        end % fin de Draw

        function DrawId(obj, gl)
            % DRAWID dessine uniquement l'id dans le frameBuffer (pour la selection)
            obj.CommonDraw(gl);
            obj.shader.Bind(gl);
            obj.GLGeom.Bind(gl);
            obj.shader.SetUniform1i(gl, 'id', obj.getId());
            gl.glDrawElements(gl.GL_POINTS, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
        end % fin de drawID

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

        function sNew = select(obj, s)
            sNew.id = obj.getId();
            sNew.couleur = obj.couleur;
            sNew.epaisseur = obj.epaisseur;
            sNew.oldType = obj.typeColoration;
            obj.couleur = s.couleur;
            obj.epaisseur = s.epaisseur;
            obj.setModeRendu('U');
        end % fin de select

        function sNew = deselect(obj, s)
            sNew.id = 0;
            sNew.couleur = obj.couleur;
            sNew.epaisseur = obj.epaisseur;
            obj.couleur = s.couleur;
            obj.epaisseur = s.epaisseur;
            if obj.typeColoration ~= s.oldType
                obj.setModeRendu(s.oldType);
            end
        end % fin de deselect
        
    end % fin des methodes defauts
end  % fin classe ElementLigne