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

            obj.epaisseurArretes = 2;
            obj.epaisseurPoints = 4;
            obj.couleurArretes = 0;
            obj.couleurPoints = 0;
            obj.couleurFaces = [0.2 0.5 0.0 1.0];
            obj.textureId = -1;
        end

        function Init(obj, gl)
            sommets = [ obj.Geom.listePoints obj.Geom.composanteSupp ];
            obj.GLGeom = GLGeometry(gl, sommets, obj.Geom.listeConnection);
        end

        function Draw(obj, gl)
            %DRAW dessine cet objet
            if obj.Geom.enable == 0
                return
            end
            obj.GLGeom.Bind(gl);
            obj.shader.SetUniformMat4(gl, 'uModelMatrix', obj.Geom.modelMatrix);

            if obj.textureId ~= -1
                gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
                obj.shader.SetUniform1i(gl, 'uTexture', obj.textureId);
                gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            elseif obj.GLGeom.nColor ~= 0
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

        function SetEpaisseurArretes(obj, newEp)
            obj.epaisseurArretes = newEp;
        end

        function SetEpaisseurPoints(obj, newEp)
            obj.epaisseurPoints = newEp;
        end

        function SetCouleurFaces(obj, newCol)
            if (newCol == 0)
                obj.couleurFaces = newCol;
            elseif (numel(newCol) == 3)
                newCol(4) = 1;
            end
            if (numel(newCol) == 4)
                obj.couleurFaces = newCol;
            end
        end

        function SetCouleurArrete(obj, newCol)
            if (newCol == 0)
                obj.couleurArretes = newCol;
            elseif (numel(newCol) == 3)
                newCol(4) = 1;
            end
            if (numel(newCol) == 4)
                obj.couleurArretes = newCol;
            end
        end

        function SetCouleurPoints(obj, newCol)
            obj.couleurPoints = newCol;
        end

        function Delete(obj, gl)
            obj.GLGeom.Delete(gl);
        end % fin de Delete

    end % fin de methodes defauts

end % fin classe ElementFace

