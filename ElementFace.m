classdef ElementFace < VisibleElement
    %ELEMENTFACE Décrit les objets a afficher qui sont pleins
    
    properties %(GetAccess = public, SetAccess = protected)
        textureId        = -1
        epaisseurArretes = 3                    % float
        epaisseurPoints  = 4                    % float
        couleurFaces     = [1 0 0 1]            % 1x4
        couleurArretes   = [0 1 0 1]            % 1x4
        couleurPoints    = [0 0 1 1]            % 1x4
        choixAffichage   = [true false false]   % 1x3 logical, vrai s'il faut afficher Face, Arrete, Points
    end
    
    methods
        function obj = ElementFace(aGeom)
            %FACEELEMENT 
            obj@VisibleElement(aGeom); % appel au constructeur parent
            obj.typeLumiere = 'D';
        end

        function Draw(obj, gl, camAttrib)
            %DRAW dessine cet objet
            if obj.visible == 0
                return
            end

            obj.CommonDraw(gl, camAttrib);

            if obj.typeRendu == 'T' && obj.textureId ~= -1
                gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
                obj.shader.SetUniform1i(gl, 'uTexture', obj.textureId);
                gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            elseif obj.typeRendu == 'C' && obj.GLGeom.nLayout(2) ~= 0
                gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
                gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            else
                if obj.choixAffichage(1) == true
                    gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
                    obj.shader.SetUniform4f(gl, 'uColor', obj.couleurFaces);
                    gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
                end
            end

            if obj.choixAffichage(2) == true
                gl.glLineWidth(obj.epaisseurArretes);
                gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_LINE);
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleurArretes);
                gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            end
                
            if obj.choixAffichage(3) == true
                gl.glPointSize(obj.epaisseurPoints);
                gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_POINT);
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleurPoints);
                gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            end

            CheckError(gl, 'apres le dessin');
            obj.GLGeom.Unbind(gl);
        end % fin de Draw

        function setEpaisseurArretes(obj, newEp)
            obj.epaisseurArretes = newEp;
        end

        function setEpaisseurPoints(obj, newEp)
            obj.epaisseurPoints = newEp;
        end

        function setCouleurFaces(obj, newCol)
            obj.couleurFaces = obj.testNewCol(newCol);
            obj.choixAffichage(1) = true; 
        end

        function setCouleurArretes(obj, newCol)
            obj.couleurArretes = obj.testNewCol(newCol);
            obj.choixAffichage(2) = true; 
        end

        function setCouleurPoints(obj, newCol)
            obj.couleurPoints = obj.testNewCol(newCol);
            obj.choixAffichage(3) = true; 
        end

        function setChoixAffichage(obj, newChoix)
            if numel(newChoix) == 1 || numel(newChoix) == 3
                obj.choixAffichage(1:3) = newChoix;
            else
                warning('mauvais format de newChoix');
            end
        end

        function sNew = reverseSelect(obj, s)
            sNew.id        = obj.getId();
            sNew.couleur   = obj.couleurArretes;
            sNew.epaisseur = obj.epaisseurArretes;
            obj.couleurArretes   = s.couleur;
            obj.epaisseurArretes = s.epaisseur;
        end % fin de reverseSelect
    end % fin de methodes defauts

    methods (Access = private)
        function col = testNewCol(~, newCol)
            if (numel(newCol) == 3)
                newCol(4) = 1;
            end
            if numel(newCol) == 4
                col = newCol;
            else
                warning('mauvais format pour la nouvelle couleur, couleur mise a 0');
            end
        end % fin de testNewCol
    end % fin des methodes privees
end % fin classe ElementFace

