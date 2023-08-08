classdef TextGeom < GeomComponent
    %TEXTGEOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        str char
        police Police
        ancre int8
        mapping
    end
    
    methods
        function obj = TextGeom(id, str, police, ancre)
            %TEXTGEOM
            obj@GeomComponent(id);
            obj.str = str;
            obj.police = police;
            obj.ancre = ancre;
            obj.constructText();
            obj.type = 'texte';
        end % fin du constructeur TextGeom

        function mapping = getMapping(obj)
            mapping = obj.mapping;
        end

    end % fin des methodes defauts

    methods (Access = private)

        function constructText(obj)
            pos = zeros(strlength(obj.str) * 4, 2);
            map = zeros(strlength(obj.str) * 4, 2);
            cursor = struct('x', 0, 'y', 0);
            ind = [];
            for i = 1:strlength(obj.str)
                base = (i-1)*4;
                infos = obj.police.letterProperties(obj.str(i));
                cursor.x = cursor.x + infos.xoffset;
                cursor.y = cursor.y - infos.yoffset;
                pos(base + 1, 1:2) = [cursor.x              cursor.y             ];
                pos(base + 2, 1:2) = [cursor.x+infos.width  cursor.y             ];
                pos(base + 3, 1:2) = [cursor.x+infos.width  cursor.y-infos.height];
                pos(base + 4, 1:2) = [cursor.x              cursor.y-infos.height];
                maxY = 512 - infos.y;
                map(base + 1, 1:2) = [ infos.x                 maxY              ];
                map(base + 2, 1:2) = [ infos.x+infos.width     maxY              ];
                map(base + 3, 1:2) = [ infos.x+infos.width     maxY-infos.height ];
                map(base + 4, 1:2) = [ infos.x                 maxY-infos.height ];
                cursor.x = cursor.x - infos.xoffset + infos.xadvance;
                cursor.y = cursor.y + infos.yoffset;
                ind = [ind base base+1 base+2 base+2 base+3 base];
            end
            pos = pos / double(obj.police.taille);
            minX = min(pos(:,1));
            maxX = max(pos(:,1));
            minY = min(pos(:,2));
            maxY = max(pos(:,2));
            switch (obj.ancre)
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
            map = map/512;
            obj.mapping = map;
            obj.listeConnection = ind;
            obj.listePoints = pos;
        end % fin de constructText
    end % fin des methodes privées
end % fin classe TextGeom