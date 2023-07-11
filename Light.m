classdef Light < handle
    %LIGHT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        position
        couleurLumiere
    end
    
    methods
        function obj = Light(position, couleur)
            %LIGHT Construct an instance of this class
            if nargin < 1, position = [-5 -5 5];end
            if nargin < 2, couleur = [1 1 1]; end
            obj.position = position;
            obj.couleurLumiere = couleur;
        end % fin du constructeur de light

        function SetPosition(obj, newPos)
            obj.position = newPos;
        end % fin de SetPosition

        function lightData = GetLightInfo(obj)
            lightData = [obj.position ; obj.couleurLumiere];
        end % fin de GetlightInfo

    end % fin des methodes defauts

end % fin classe light