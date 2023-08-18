classdef ElementPoint < VisibleElement
    %ELEMENTPOINT
    
    properties (GetAccess = public, SetAccess = protected)
        epaisseur (1,1) double = 2       
        couleur   (1,4) double = [1 0 0 1]
    end
    
    methods
        function obj = ElementPoint(gl, aGeom)
            %ELEMENTLIGNE
            obj@VisibleElement(gl, aGeom);
            obj.Type = 'Point';
            obj.shader = ShaderProgram(gl, obj.GLGeom.nLayout, obj.Type, obj.typeRendu);
        end % fin du constructeur ElementLigne

        function Draw(obj, gl)
            %DRAW dessine cet objet
            if obj.isVisible() == false
                return
            end
            obj.GLGeom.Bind(gl);

            gl.glPointSize(obj.epaisseur);
            if bitand(obj.typeRendu, 1) == 1
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleur);
            end
            % gl.glDrawArrays(gl.GL_POINTS, 0, size(obj.Geom.listePoints, 1));
            gl.glDrawElements(gl.GL_POINTS, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
        end % fin de Draw

        function setEpaisseur(obj, newEp)
            obj.epaisseur = newEp;
            notify(obj,'evt_redraw');
        end

        function setCouleur(obj, newColor)
            if numel(newColor) == 3
                newColor(4) = 1;
            end
            if numel(newColor) == 4
                obj.couleur = newColor;
                notify(obj,'evt_redraw');
            else
                warning('mauvaise matrice de couleur, annulation');
            end
        end % fin de setCouleur
    end % fin des methodes defauts

    methods(Hidden = true)
        function DrawId(obj, gl)
            % DRAWID dessine uniquement l'id dans le frameBuffer (pour la selection)
            obj.GLGeom.Bind(gl);
            gl.glDrawElements(gl.GL_POINTS, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
        end % fin de drawID

        function sNew = select(obj, s)
            sNew.id = obj.getId();
            sNew.couleur = obj.couleur;
            sNew.epaisseur = obj.epaisseur;
            sNew.oldType = obj.typeRendu;
            obj.couleur = s.couleur;
            obj.epaisseur = s.epaisseur;
            if bitand(obj.typeRendu, 1) == 0
                obj.setModeRendu("UNIFORME");
            end
        end % fin de select

        function sNew = deselect(obj, s)
            sNew.id = 0;
            sNew.couleur = obj.couleur;
            sNew.epaisseur = obj.epaisseur;
            obj.couleur = s.couleur;
            obj.epaisseur = s.epaisseur;
            if obj.typeRendu ~= s.oldType
                obj.setModeRendu("PAR_SOMMET");
            end
        end % fin de deselect
    end % fin des methodes cachés
end  % fin classe ElementLigne