classdef ElementTexte < VisibleElement
    %TEXTE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        textureId = -1
    end
    
    methods
        function obj = ElementTexte(geom)
            %TEXTE
            obj@VisibleElement(geom);
        end

        function Draw(obj, gl)
            %DRAW dessine cet objet
            if obj.visible == 0
                return
            end
            obj.GLGeom.Bind(gl);
            obj.shader.SetUniformMat4(gl, 'uModelMatrix', obj.Geom.modelMatrix);

            gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
            obj.shader.SetUniform1i(gl, 'uTexture', obj.textureId);
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
        end

        function Init(obj, gl)
            sommets = [ obj.Geom.listePoints obj.Geom.composanteSupp ];
            obj.GLGeom = GLGeometry(gl, sommets, obj.Geom.listeConnection);
        end
    end

    methods(Static = true)
        function [pos, ind, mapping] = constructText(str, dico)
            pos = zeros(strlength(str) * 4, 3);
            mapping = zeros(strlength(str) * 4, 2);
            % curseur = struct('x', 0, 'y', 0);
            cursor = 0;
            ind = [];
            for i = 1:strlength(str)
                base = (i-1)*4;
                infos = dico(str(i));
                pos(base + 1, 1:3) = [cursor+infos.xoffset-infos.width cursor+infos.yoffset             0];
                pos(base + 2, 1:3) = [cursor+infos.xoffset              cursor+infos.yoffset             0];
                pos(base + 3, 1:3) = [cursor+infos.xoffset              cursor+infos.yoffset+infos.height 0];
                pos(base + 4, 1:3) = [cursor+infos.xoffset-infos.width cursor+infos.yoffset+infos.height 0];
                mapping(base + 1, 1:2) = [ (infos.x+infos.width)    infos.y ];
                mapping(base + 2, 1:2) = [  infos.x                  infos.y ];
                mapping(base + 3, 1:2) = [  infos.x                 (infos.y+infos.height) ];
                mapping(base + 4, 1:2) = [ (infos.x+infos.width)   (infos.y+infos.height) ];
                cursor = cursor + infos.xadvance;
                ind = [ind base base+1 base+2 base+2 base+3 base];
            end
            pos = pos / double(cursor);
            mapping = mapping/512;
        end % fin de constructText

    end % fin des methodes statiques

end % fin classe Texte

