classdef ElementTexte < VisibleElement
    %TEXTE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = protected)
        str                         % le texte a afficher
        police Police
        couleurTexte = [1 1 1 1]    % 1x4 double entre 0 et 1
        texture
    end
    
    methods
        function obj = ElementTexte(gl, id, str, police, ancre)
            %TEXTE
            [pos, ind, mapping] = ElementTexte.constructText(str, police, ancre);
            geom = Geometry(id, pos, ind);
            obj@VisibleElement(gl, geom);
            obj.Type='Texte';
            obj.AddMapping(mapping);
            obj.str = str;
            obj.police = police;
            obj.typeOrientation = 2; % normal a l'ecran
            obj.typeRendu = 'T';
            obj.texture = Texture(gl, police.name + ".png");
            obj.changerProg(gl);
        end % fin du constructeur Texte

        function Draw(obj, gl, camAttrib, model)
            %DRAW dessine cet objet
            if obj.visible == 0
                return
            end
            if nargin == 3
                model = obj.getModelMatrix();
            end
            obj.CommonDraw(gl, camAttrib, model);

            gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
            obj.shader.SetUniform1i(gl, 'uTexture', obj.texture.slot);
            obj.shader.SetUniform4f(gl, 'uColor', obj.couleurTexte);
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            CheckError(gl, 'apres le dessin d un texte');
        end % fin de Draw

        function setCouleurTexte(obj, newColor)
            %SETCOULEURFOND change la couleur du texte
            %Peut prendre en entrée une matrice 1x3 (rgb) ou 1x4 (rgba)
            if (numel(newColor) == 3)
                newColor(4) = 1;
            end
            if numel(newColor) == 4
                obj.couleurTexte = newColor;
            else
                warning('Le format de la nouvelle couleur n est pas bon, annulation');
            end
            notify(obj,'evt_update');
        end % fin setCouleurFond

        function setMainColor(obj, matColor)
            obj.setCouleurTexte(matColor);
        end % fin de setMainColor

        function sNew = reverseSelect(obj, s)
            sNew.id          = obj.getId();
            sNew.couleur     = obj.couleurTexte;
            sNew.epaisseur   = s.epaisseur;
            obj.couleurTexte = s.couleur;
        end % fin de reverseSlect
    end % fin des methodes defauts

    methods(Static = true)
        function [pos, ind, mapping] = constructText(str, police, ancre)
            pos = zeros(strlength(str) * 4, 2);
            mapping = zeros(strlength(str) * 4, 2);
            cursor = struct('x', 0, 'y', 0);
            ind = [];
            for i = 1:strlength(str)
                base = (i-1)*4;
                infos = police.letterProperties(str(i));
                cursor.x = cursor.x + infos.xoffset;
                cursor.y = cursor.y - infos.yoffset;
                pos(base + 1, 1:2) = [cursor.x              cursor.y             ];
                pos(base + 2, 1:2) = [cursor.x+infos.width  cursor.y             ];
                pos(base + 3, 1:2) = [cursor.x+infos.width  cursor.y-infos.height];
                pos(base + 4, 1:2) = [cursor.x              cursor.y-infos.height];
                maxY = 512 - infos.y;
                mapping(base + 1, 1:2) = [  infos.x                 maxY              ];
                mapping(base + 2, 1:2) = [  infos.x+infos.width     maxY              ];
                mapping(base + 3, 1:2) = [  infos.x+infos.width     maxY-infos.height ];
                mapping(base + 4, 1:2) = [  infos.x                 maxY-infos.height ];
                cursor.x = cursor.x - infos.xoffset + infos.xadvance;
                cursor.y = cursor.y + infos.yoffset;
                ind = [ind base base+1 base+2 base+2 base+3 base];
            end
            pos = pos / double(police.taille);
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