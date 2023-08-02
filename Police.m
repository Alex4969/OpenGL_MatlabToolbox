classdef Police < handle
    %POLICE enregiste le style de police
    
    properties
        letterProperties    % dictionary caractère (int) -> struct
        name                % le nom de la police
        taille              % la taille de la police dans le fichier donné
        textureSlot = -1;   % le slot de texture dans lequelle la police est rendu
    end
    
    methods
        function obj = Police(fileName)
            obj.name = fileName;
            filePath = fileName + ".fnt";
            obj.letterProperties = obj.readFnt(filePath);
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
                [letter, infos] = obj.readLigne(tline);
                dico(letter) = infos;
            end
            fclose(fId);
        end % fin de readFnt
        
        function [letter, infos] = readLigne(~, ligne)
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
        end % fin de readLigne
    end % fin des methodes privées
end % fin classe Police

