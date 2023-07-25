classdef ElementTexte < VisibleElement
    %TEXTE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        str                 % le texte a afficher
        police Police
        taille              % coefficient multiplicateur (autour de 1)
        type                % 'P' : perspective, 'N' : normal, de face, 'F' : Fixe
        textureId = -1
        ancre               % définit le point d'accroche du texte 
                            % 0:centre, 1:haut gauche, 2:haut droite, 3:bas gauche, 4:bas droite

        couleurTexte        % 1x4 double entre 0 et 1
    end
    
    methods
        function obj = ElementTexte(str, police, taille, type, color, posAncre, ancre)
            %TEXTE
            [pos, ind, mapping] = ElementTexte.constructText(str, police, taille, ancre);
            geom = Geometry(pos, ind, mapping);
            obj@VisibleElement(geom);
            obj.str = str;
            obj.police = police;
            obj.taille = taille;
            obj.type = type;
            obj.couleurTexte = color;
            obj.setModelMatrix(MTrans3D(posAncre));
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

        function Init(obj, gl, id)
            obj.id = id;
            sommets = [ obj.Geom.listePoints obj.Geom.composanteSupp ];
            obj.GLGeom = GLGeometry(gl, sommets, obj.Geom.listeConnection);
            obj.setAttributeSize(3, 0, 2, 0);
        end

        function AddText(obj, gl, str)
            obj.str = [obj.str  str];
            [pos, ind, mapping] = ElementTexte.constructText(obj.str, obj.police, obj.taille);
            obj.ChangeGeom(gl, pos, ind, mapping);
            obj.setAttributeSize(3, 0, 2, 0);
        end

        function ChangeText(obj, gl, str)
            obj.str = str;
            [pos, ind, mapping] = ElementTexte.constructText(obj.str, obj.police, obj.taille);
            obj.ChangeGeom(gl, pos, ind, mapping);
            obj.setAttributeSize(3, 0, 2, 0);
        end
    end

    methods(Static = true)
        function [pos, ind, mapping] = constructText(str, police, taille, ancre)
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
            minX = min(pos(:,1));
            maxX = max(pos(:,1));
            minY = min(pos(:,2));
            maxY = max(pos(:,2));
            switch ancre
                case 0 % centre
                    xDep = (maxX - minX) / 2;
                    yDep = (maxY - minY) / 2;
                case 1 % haut gauche
                    xDep = minX;
                    yDep = maxY;
                case 2 % haut droite
                    xDep = maxX;
                    yDep = maxY;
                case 3 % bas gauche
                    xDep = -minX;
                    yDep = -minY;
                case 4 % bas droite
                    xDep = maxX;
                    yDep = -minY;
            end
            pos(:, 1) = pos(:, 1) - xDep;
            pos(:, 2) = pos(:, 2) + yDep;
            mapping = mapping/512;
        end % fin de constructText

    end % fin des methodes statiques

end % fin classe Texte

