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

        function pos = getPosition(obj)
            pos = obj.position;
        end % fin de GetPosition

        function col = getColor(obj)
            col = obj.couleurLumiere;
        end % fin de GetPosition

    end % fin des methodes defauts

end % fin classe light