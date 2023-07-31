classdef ElementFace < VisibleElement
    %ELEMENTFACE Décrit les objets a afficher qui sont pleins
    
    properties
        textureId           %
        epaisseurArretes    % float
        epaisseurPoints     % float
        couleurFaces        % 1x4
        couleurArretes      % 1x4
        couleurPoints       % 1x4
    end
    
    methods
        function obj = ElementFace(aGeom)
            %FACEELEMENT 
            obj@VisibleElement(aGeom); % appel au constructeur parent
            obj.typeLumiere = 'D';

            obj.epaisseurArretes = 2;
            obj.epaisseurPoints = 4;
            obj.couleurArretes = 0;
            obj.couleurPoints = 0;
            obj.couleurFaces = [0.2 0.5 0.0 1.0];
            obj.textureId = -1;
        end

        function Draw(obj, gl)
            %DRAW dessine cet objet
            if obj.visible == 0
                return
            end
            obj.verifNewProg(gl);
            obj.GLGeom.Bind(gl);
            obj.shader.SetUniformMat4(gl, 'uModelMatrix', obj.Geom.modelMatrix);

            if obj.typeRendu == 'T' && obj.textureId ~= -1
                gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
                obj.shader.SetUniform1i(gl, 'uTexture', obj.textureId);
                gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            elseif obj.typeRendu == 'C' && obj.GLGeom.nLayout(2) ~= 0
                gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
                gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            else
                if (numel(obj.couleurFaces) == 4)
                    gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
                    obj.shader.SetUniform4f(gl, 'uColor', obj.couleurFaces);
                    gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
                end

                if (numel(obj.couleurArretes) == 4)
                    gl.glLineWidth(obj.epaisseurArretes);
                    gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_LINE);
                    obj.shader.SetUniform4f(gl, 'uColor', obj.couleurArretes);
                    gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
                end
                    
                if (numel(obj.couleurPoints) == 4)
                    gl.glPointSize(obj.epaisseurPoints);
                    gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_POINT);
                    obj.shader.SetUniform4f(gl, 'uColor', obj.couleurPoints);
                    gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
                end
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
        end

        function setCouleurArrete(obj, newCol)
            obj.couleurArretes = obj.testNewCol(newCol);
        end

        function setCouleurPoints(obj, newCol)
            obj.couleurPoints = obj.testNewCol(newCol);
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
                col = 0;
                if (newCol ~= 0)
                    warning('mauvais format pour la nouvelle couleur, couleur mise a 0');
                end
            end
        end % fin de testNewCol
    end % fin des methodes privees
end % fin classe ElementFace

