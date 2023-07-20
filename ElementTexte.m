classdef ElementTexte < VisibleElement
    %TEXTE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        str
        police Police
        taille              % coefficient multiplicateur (autour de 1)
        nbLigne
        align
        ortho logical
        textureId = -1

        couleurTexte % a faire
    end
    
    methods
        function obj = ElementTexte(str, police, nbLigne, align, taille, ortho, color)
            %TEXTE
            [pos, ind, mapping] = ElementTexte.constructText(str, police, taille, nbLigne, align);
            geom = Geometry(pos, ind, mapping);
            obj@VisibleElement(geom);
            obj.str = str;
            obj.police = police;
            obj.taille = taille;
            obj.nbLigne = nbLigne;
            obj.align = align;
            obj.ortho = ortho;
            obj.couleurTexte = color;
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
            obj.shader.SetUniform4f(gl, 'uTextColor', obj.couleurTexte);
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            CheckError(gl, 'apres le dessin d un texte');
        end

        function Init(obj, gl)
            sommets = [ obj.Geom.listePoints obj.Geom.composanteSupp ];
            obj.GLGeom = GLGeometry(gl, sommets, obj.Geom.listeConnection);
            obj.setAttributeSize(3, 0, 2, 0);
        end
    end

    methods(Static = true)
        function [pos, ind, mapping] = constructText(str, police, taille, nbLigne, align)
            if (nbLigne > 1)
                posEsp = strfind(str, ' ');
                if (numel(posEsp) >= nbLigne)
                    warning('trop de ligne demandé');
                else
                    posCherche = strlength(str)/nbLigne;
                    %parcourir les position 
                    %chercher si ecart plus grand avec avant ou apres
                    %modifier posEsp
                    %remplacer l'espace par un retour a la ligne
                end
            end
            pos = zeros(strlength(str) * 4, 3);
            mapping = zeros(strlength(str) * 4, 2);
            cursor = struct('x', 0, 'y', 0);
            ind = [];
            for i = 1:strlength(str)
                base = (i-1)*4;
                infos = police.letterProperties(str(i));
                cursor.x = cursor.x + infos.xoffset;
                cursor.y = cursor.y - infos.yoffset;
                pos(base + 1, 1:3) = [cursor.x              cursor.y               0];
                pos(base + 2, 1:3) = [cursor.x+infos.width  cursor.y               0];
                pos(base + 3, 1:3) = [cursor.x+infos.width  cursor.y-infos.height  0];
                pos(base + 4, 1:3) = [cursor.x              cursor.y-infos.height  0];
                maxY = 512 - infos.y;
                mapping(base + 1, 1:2) = [  infos.x                 maxY              ];
                mapping(base + 2, 1:2) = [  infos.x+infos.width     maxY              ];
                mapping(base + 3, 1:2) = [  infos.x+infos.width     maxY-infos.height ];
                mapping(base + 4, 1:2) = [  infos.x                 maxY-infos.height ];
                cursor.x = cursor.x - infos.xoffset + infos.xadvance;
                cursor.y = cursor.y + infos.yoffset;
                ind = [ind base base+1 base+2 base+2 base+3 base];
            end
            pos = pos / double(police.taille) * taille;
            mapping = mapping/512;
        end % fin de constructText

    end % fin des methodes statiques

end % fin classe Texte

