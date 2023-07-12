classdef ElementLigne < VisibleElement
    %ELEMENTLIGNE
    
    properties
        epaisseurLignes     % float
        couleurLignes       % 1x3
    end
    
    methods

        function obj = ElementLigne(aGeom, epaisseur, couleur)
            %ELEMENTLIGNE
            obj@VisibleElement(aGeom);

            if nargin < 2, epaisseur = 2; end
            if nargin < 3, couleur = [1 1 1]; end
            obj.epaisseurLignes = epaisseur;
            obj.couleurLignes   = couleur;
        end % fin du constructeur ElementLigne

        function Init(obj, gl)
            sommets = [ obj.Geom.listePoints obj.Geom.composanteSupp ];
            obj.GLGeom = GLGeometry(gl, sommets, obj.Geom.listeConnection);
        end % fin de Init

        function Draw(obj, gl)
            %DRAW dessine cet objet
            if obj.Geom.enable == 0
                disp('objet invisible');
                return
            end
            obj.GLGeom.Bind(gl);
            obj.shader.SetUniformMat4(gl, 'uModelMatrix', obj.Geom.modelMatrix);

            gl.glLineWidth(obj.epaisseurLignes);
            gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_LINE);
            if (obj.GLGeom.nColor == 0)
                obj.shader.SetUniform4f(gl, 'uColor', obj.couleurLignes);
            end
            gl.glDrawElements(gl.GL_LINES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

            CheckError(gl, 'apres le dessin');
            obj.GLGeom.Unbind(gl);
        end % fin de Draw

        function Delete(obj, gl)
            obj.GLGeom.Delete(gl);
        end % fin de Delete

    end % fin des methodes defauts

end  % fin classe ElementLigne