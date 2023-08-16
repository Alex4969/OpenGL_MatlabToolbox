classdef Police < handle
    %POLICE enregiste le style de police
    
    properties
        letterProperties    % dictionary caractère (int) -> struct
        name                % le nom de la police
        taille              % la taille de la police dans le fichier donné
    end
    
    methods
        function obj = Police(fileName)
            obj.name = fileName;
            filePath = fileName + ".fnt";
            obj.letterProperties = obj.readFnt(filePath);
            obj.verification();
        end
    end

    methods (Access = private)
        function dico = readFnt(obj, fileName)
            %READFNT lit le fichier et construit un dictionnaire
            % caractère -> propriété de ce caractère
            dico = dictionary;
            fId = fopen(fileName);
            tline = fgetl(fId);
            tmp = extractBetween(tline, 'size=', ' ');
            obj.taille = str2double(tmp{1});
            for i=1:3
                tline = fgetl(fId);
            end
            
            nbLigne = extractAfter(tline, 'count=');
            nbLigne = str2double(nbLigne);
        
            for i=1:nbLigne
                tline = fgetl(fId);
                [letter, infos] = obj.decodeLine(tline);
                dico(letter) = infos;
            end
            fclose(fId);
        end % fin de readFnt
        
        function [letter, infos] = decodeLine(~, ligne)
            tmp = extractBetween(ligne, 'id=', ' ');
            letter = int16(str2double(tmp{1}));
            
            tmp = extractBetween(ligne, 'x=', ' ');
            infos.x = int16(str2double(tmp{1}));
            tmp = extractBetween(ligne, 'y=', ' ');
            infos.y = int16(str2double(tmp{1}));
            tmp = extractBetween(ligne, 'width=', ' ');
            infos.width = int16(str2double(tmp{1}));
            tmp = extractBetween(ligne, 'height=', ' ');
            infos.height = int16(str2double(tmp{1}));
            tmp = extractBetween(ligne, 'xoffset=', ' ');
            infos.xoffset = int16(str2double(tmp{1}));
            tmp = extractBetween(ligne, 'yoffset=', ' ');
            infos.yoffset = int16(str2double(tmp{1}));
            tmp = extractBetween(ligne, 'xadvance=', ' ');
            infos.xadvance = int16(str2double(tmp{1}));
        end % fin de decodeLine

        function verification(obj)
            majLetter = true;
            minLetter = true;
            for i=65:90 % parcours parmis les majuscules
                if ~isKey(obj.letterProperties, i)
                    majLetter = false;
                end
            end
            for i=97:122 % parcours parmis les minuscules
                if ~isKey(obj.letterProperties, i)
                    minLetter = false;
                end
            end
            if minLetter == false && majLetter == false
                disp('La police ne contient pas tous les caractères et ne vas pas fonctionner correctement. Changer de Police');
            end
            if minLetter == false && majLetter == true
                disp('Les caractères minuscules sont indéfinis et remplacer par les majuscules')
                for i=65:90
                    obj.letterProperties(i + 32) = obj.letterProperties(i);
                end
            elseif majLetter == false && minLetter == true
                disp('Les caractères majuscules sont indéfinis et remplacer par les minuscules')
                for i=65:90
                    obj.letterProperties(i) = obj.letterProperties(i + 32);
                end
            end
        end % fin de set verification
    end % fin des methodes privées
end % fin classe Police