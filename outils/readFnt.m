function [dico] = readFnt(fileName)
%READFNT Summary of this function goes here
    dico = dictionary;
    fId = fopen(fileName);
    for i=1:4
        tline = fgetl(fId);
    end
    
    nbLigne = tline(13:14);
    nbLigne = str2double(nbLigne);

    for i=1:nbLigne
        tline = fgetl(fId);
        [letter, infos] = readLigne(tline);
        dico(letter) = infos;
    end
end

function [letter, infos] = readLigne(ligne)
    tmp = ligne(9:11);
    letter = int16(str2double(tmp));
    
    tmp = ligne(19:21);
    infos.x = int16(str2double(tmp));
    tmp = ligne(26:28);
    infos.y = int16(str2double(tmp));
    tmp = ligne(37:39);
    infos.width = int16(str2double(tmp));
    tmp = ligne(49:51);
    infos.height = int16(str2double(tmp));
    tmp = ligne(62:64);
    infos.xoffset = int16(str2double(tmp));
    tmp = ligne(75:77);
    infos.yoffset = int16(str2double(tmp));
    tmp = ligne(89:91);
    infos.xadvance = int16(str2double(tmp));
end 