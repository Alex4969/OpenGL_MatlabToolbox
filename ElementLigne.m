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
            obj.shader = ShaderProgram(gl, obj.GLGeom.nLayout, obj.Type, obj.typeColoration, obj.typeShading);
        end % fin du constructeur ElementLigne

        function Draw(obj, gl)
            %DRAW dessine cet objet
            if obj.isVisible() == false
                return
            end
            obj.GLGeom.Bind(gl);

            gl.glLineWidth(obj.epaisseur);
            if obj.typeColoration == 'U'
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleur);
            end
            gl.glDrawElements(gl.GL_LINES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

            CheckError(gl, 'apres le dessin');
        end % fin de Draw

        function DrawId(obj, gl)
            % DRAWID dessine uniquement l'id dans le frameBuffer (pour la selection)
            obj.GLGeom.Bind(gl);
            obj.shader.SetUniform1i(gl, 'id', obj.getId());
            gl.glDrawElements(gl.GL_LINES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
        end % fin de drawID

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