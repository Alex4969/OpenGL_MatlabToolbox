classdef GeomTexte < ClosedGeom
    %TEXTGEOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = protected)
        str      char          % doit rester un char pout etre lu correctement
        police   Police        % information sur la représentation des caracteres
        ancre    int8          % position de l'ancre par rapport au texte
                                 % 0:centre, 1:haut-gauche, 2:haut-droite,
                                 % 3:bas-gauche, 4:bas-droite
        mapping  (:,2) double  % mapping de la texture de police
    end

    properties (Constant = true)  % choix d'ancrage disponible
        enumAncrage = dictionary("CENTRE"     , 0, ...
                                 "HAUT_GAUCHE", 1, ...
                                 "HAUT_DROITE", 2, ...
                                 "BAS_GAUCHE" , 3, ...
                                 "BAS_DROITE" , 4);
    end
    
    methods
        function obj = GeomTexte(id, str, police, ancre)
            %TEXTGEOM
            obj@ClosedGeom(id, "texte");
            obj.str = str;
            obj.police = police;
            if obj.enumAncrage.isKey(ancre)
                obj.ancre = obj.enumAncrage(ancre);
            elseif ancre > 4 || ancre < 0
                obj.ancre = 0;
            else
                obj.ancre = ancre;
            end
            obj.attributes = ["police", "mapping"];
            obj.generateText();
        end % fin du constructeur TextGeom

        function setPolice(obj, newPolice)
            if isa(newPolice, "char") || isa(newPolice, "string")
                obj.police = Police(newPolice);
            else
                obj.police = newPolice;
            end
            obj.generateText();
            if event.hasListener(obj, 'evt_updateGeom')
                obj.attributes = ["police", "mapping"];
                notify(obj, 'evt_updateGeom')
            end
        end % fin de setPolice

        function setTexte(obj, newTexte)
            obj.str = newTexte;
            obj.generateText();
            if event.hasListener(obj, 'evt_updateGeom')
                obj.attributes = "mapping";
                notify(obj, 'evt_updateGeom')
            end
        end % fin de setTexte

        function setAncrage(obj, newAncre)
            if obj.enumAncrage.isKey(newAncre)
                obj.ancre = obj.enumAncrage(newAncre);
            elseif newAncre > 4 || newAncre < 0
                obj.ancre = 0;
            else
                obj.ancre = newAncre;
            end
            minX = min(obj.listePoints(:,1));
            maxX = max(obj.listePoints(:,1));
            minY = min(obj.listePoints(:,2));
            maxY = max(obj.listePoints(:,2));
            switch (obj.ancre)
                case 0 % centre
                    xDep = minX + ( (maxX - minX) / 2 );
                    yDep = maxY - ( (maxY - minY) / 2 );
                case 1 % haut gauche
                    xDep = minX;
                    yDep = maxY;
                case 2 % haut droite
                    xDep = maxX;
                    yDep = maxY;
                case 3 % bas gauche
                    xDep = minX;
                    yDep = minY;
                case 4 % bas droite
                    xDep = maxX;
                    yDep = minY;
            end
            obj.listePoints(:, 1) = obj.listePoints(:, 1) - xDep;
            obj.listePoints(:, 2) = obj.listePoints(:, 2) - yDep;
            
            if event.hasListener(obj, 'evt_updateGeom')
                obj.attributes = "mapping";
                notify(obj, 'evt_updateGeom')
            end
        end % fin de setAncrage
    end % fin des methodes defauts

    methods (Access = private)
        function generateText(obj)
            pos = zeros(strlength(obj.str) * 4, 3);
            map = zeros(strlength(obj.str) * 4, 2);
            cursor = struct('x', 0, 'y', 0);
            ind = [];
            zValue = 0;
            for i = 1:strlength(obj.str)
                base = (i-1)*4;
                infos = obj.police.letterProperties(obj.str(i));
                cursor.x = cursor.x + infos.xoffset;
                cursor.y = cursor.y - infos.yoffset;
                pos(base + 1, 1:2) = [cursor.x              cursor.y             ];
                pos(base + 2, 1:2) = [cursor.x+infos.width  cursor.y             ];
                pos(base + 3, 1:2) = [cursor.x+infos.width  cursor.y-infos.height];
                pos(base + 4, 1:2) = [cursor.x              cursor.y-infos.height];
                pos(base+1:base+4, 3) = zValue;
                maxY = obj.police.tailleImage - infos.y;
                map(base + 1, 1:2) = [ infos.x                 maxY              ];
                map(base + 2, 1:2) = [ infos.x+infos.width     maxY              ];
                map(base + 3, 1:2) = [ infos.x+infos.width     maxY-infos.height ];
                map(base + 4, 1:2) = [ infos.x                 maxY-infos.height ];
                cursor.x = cursor.x - infos.xoffset + infos.xadvance;
                cursor.y = cursor.y + infos.yoffset;
                ind = [ind base base+1 base+2 base+2 base+3 base];
                zValue = zValue + 5e-4; % on avance légérement la lettre suivante pour l'overlapping
            end
            pos(:, 1:2) = pos(:, 1:2) / double(obj.police.taille);
            minX = min(pos(:,1));
            maxX = max(pos(:,1));
            minY = min(pos(:,2));
            maxY = max(pos(:,2));
            switch (obj.ancre)
                case 0 % centre
                    xDep = (maxX - minX) / 2;
                    yDep = (minY - maxY) / 2;
                case 1 % haut gauche
                    xDep = minX;
                    yDep = maxY;
                case 2 % haut droite
                    xDep = maxX;
                    yDep = maxY;
                case 3 % bas gauche
                    xDep = -minX;
                    yDep = minY;
                case 4 % bas droite
                    xDep = maxX;
                    yDep = minY;
            end
            pos(:, 1) = pos(:, 1) - xDep;
            pos(:, 2) = pos(:, 2) - yDep;
            map = map/obj.police.tailleImage;
            obj.mapping = map;
            obj.listeConnection = ind;
            obj.listePoints = pos;
        end % fin de generateText
    end % fin des methodes privées
end % fin classe TextGeom