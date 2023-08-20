classdef GeomAxes < ClosedGeom
    %GEOMAXES defini la géometrie d'un axe
    properties(GetAccess = public, SetAccess = private)
        deb     (1,1) double
        fin     (1,1) double
        color   (:,3) double
    end
    methods
        function obj = GeomAxes(id, deb, fin)
            obj@ClosedGeom(id, "ligne");
            if nargin ~= 3 || deb == fin
                deb = 0; fin = 1;
            end
            obj.deb = deb;
            obj.fin = fin;
            obj.attributes = "color";
            obj.generateAxis();
        end % fin du constructeur de GeomAxes

        function setDimension(obj, deb, fin)
            if nargin ~= 3 || deb == fin
                deb = 0; fin = 1;
            end
            obj.deb = deb;
            obj.fin = fin;
            obj.generateAxis();
            if event.hasListener(obj, 'evt_updateGeom')
                notify(obj, 'evt_updateGeom')
            end
        end
    end % fin des methodes defauts

    methods(Access = private)
        function generateAxis(obj)
            obj.listePoints = [ obj.deb   0.0      0.0     ;   % 0
                                obj.fin   0.0      0.0     ;   % 1
                                0.0       obj.deb  0.0     ;   % 2 
                                0.0       obj.fin  0.0     ;   % 3
                                0.0       0.0      obj.deb ;   % 4
                                0.0       0.0      obj.fin ];  % 5
            obj.color = [1.0 0.0 0.0 ; 1.0 0.0 0.0 ;
                         0.0 1.0 0.0 ; 0.0 1.0 0.0 ;
                         0.0 0.0 1.0 ; 0.0 0.0 1.0 ];
            obj.listeConnection = [0 1 2 3 4 5];
        end % fin de generateAxis

    end % fin des methodes privées
end % fin classe GeomAxes