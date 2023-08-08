classdef FileGeom < GeomComponent
    %FILEGEOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fileName char
    end
    
    methods
        function obj = FileGeom(id, fileName, type)
            %FILEGEOM
            obj@GeomComponent(id);
            if nargin == 2
                obj.type = 'face';
            else
                obj.type = type;
            end
            obj.fileName = fileName;
            obj.CreateFromFile();
        end % fin du constructeur FileGeom
        
        function CreateFromFile(obj)
            %CREATEFROMFILE créé un objet 3D a partir d'un fichier stl
            stlObj = IO_CADfile.readSTL(obj.fileName, 1);
            obj.listePoints = stlObj.vertices;
            temp = stlObj.faces';
            temp = temp - 1;
            obj.listeConnection = temp(:);
        end % fin de createFromFile
    end % fin des methodes defauts
end % fin classe FileGeom