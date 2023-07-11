classdef ElementFace < VisibleElement
    %ELEMENTFACE Décrit les objets a afficher qui sont pleins
    
    properties
        textureId
        epaisseurArretes
        epaisseurPoints
        couleurFaces
        couleurArretes
        couleurPoints
    end
    
    methods
        function obj = ElementFace(aGeom)
            %FACEELEMENT 
            obj@VisibleElement(aGeom); % appel au constructeur parent

            obj.epaisseurArretes = 2;
            obj.epaisseurPoints = 2;
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
                disp('objet invisible');
                return
            end
            obj.GLGeom.Bind(gl);
            obj.shader.SetUniformMat4(gl, 'uModelMatrix', obj.Geom.modelMatrix);

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
            CheckError(gl, 'apres le dessin');
            obj.GLGeom.Unbind(gl);
        end % fin de Draw

        function Delete(obj, gl)
            obj.GLGeom.Delete(gl);
        end % fin de Delete

    end % fin de methodes defauts

end % fin classe ElementFace

