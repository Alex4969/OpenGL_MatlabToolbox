classdef Grid < ElementLigne
    %GRID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        borne
        ecart

        normaleX logical
        normaleY logical
        normaleZ logical
    end
    
    methods

        function obj = Grid(aBorne, aEcart)
            %GRID construit la géometrie et en fait un ElementVisible
            [mat, ind] = Grid.generateGrid(aBorne, aEcart);
            grilleGeom = Geometry(mat, ind);
            obj@ElementLigne(grilleGeom)
            obj.borne = aBorne;
            obj.ecart = aEcart;
            obj.normaleX = 0;
            obj.normaleY = 1;
            obj.normaleZ = 0;
            obj.epaisseurLignes = 1;
            obj.couleurLignes = [0.3 0.3 0.3 1];
        end % fin du constructeur Grid

        function Draw(obj, gl)
            if obj.visible == 0
                return
            end
            obj.GLGeom.Bind(gl);

            gl.glLineWidth(obj.epaisseurLignes);
            gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_LINE);
            obj.shader.SetUniform4f(gl, 'uColor', obj.couleurLignes);

            if obj.normaleY == 1
                obj.shader.SetUniformMat4(gl, 'uModelMatrix', eye(4));
                gl.glDrawElements(gl.GL_LINES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            end
            if obj.normaleX == 1
                obj.shader.SetUniformMat4(gl, 'uModelMatrix', MRot3D([90 0 0]));
                gl.glDrawElements(gl.GL_LINES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            end
            if obj.normaleZ == 1
                obj.shader.SetUniformMat4(gl, 'uModelMatrix', MRot3D([0 0 90]));
                gl.glDrawElements(gl.GL_LINES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            end

            CheckError(gl, 'apres le dessin');
            obj.GLGeom.Unbind(gl);
        end % fin du Draw

        function setVisibleNormales(obj, normales)
            obj.normaleX = normales(1);
            obj.normaleY = normales(2);
            obj.normaleZ = normales(3);
        end % fin de setAxes

        function setGrid(obj, gl, newBorne, newEcart)
            [mat, ind] = Grid.generateGrid(newBorne, newEcart);
            obj.ChangeGeom(gl, mat, ind);
        end % fin de setGrid

    end % fin des methodes defauts

    methods (Static)
        function [pos, ind] = generateGrid(borne, ecart)
            if nargin < 2, ecart = borne/10; end
            if mod(borne, ecart) ~= 0 || ecart > borne
                ecart = borne/10;
                warning("mauvaise valeurs pour setGrid. Valeurs choisis : borne = " + borne + " et ecart = " + ecart);
            end
            e = ecart;
            b = borne;
            deb = [-b b b -b ; 0 0 0 0 ; -b -b b b]; % contour du carré
            i = e:e:b-e;
            taille = 2*b/e -2;
            matBorne = ones(1, taille)*b;
            matZeros = zeros(1, taille * 4);
            pos = [-matBorne matBorne -i i -i i ; matZeros ; -i i -i i -matBorne matBorne];
            pos = [deb pos];
            pos = pos';
            t = taille/2;
            ind = [0 1 1 2 2 3 3 0];
            for i=0:1:t-1
                ajout = [4+i 4+taille+i   4+t+i 4+t+taille+i   4+2*taille+i 4+2*taille+taille+i   4+2*taille+t+i 4+2*taille+taille+t+i];
                ind = [ind ajout];
            end
        end
    end

end % fin classe Grid

