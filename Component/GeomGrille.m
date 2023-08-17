classdef GeomGrille < ClosedGeom % < GeomComponent
    % GEOMGRILLE Defini la geometrie d'une grille
    properties (GetAccess = public, SetAccess = protected)
        tailleTotale (1,1) double
        tailleEcart  (1,1) double
    end

    methods
        function obj = GeomGrille(id, tailleTotale, tailleEcart)
            obj@ClosedGeom(id, "ligne")
            if nargin == 3
                obj.checkValues(tailleTotale, tailleEcart);
            else
                obj.tailleEcart = 2;
                obj.tailleTotale = 50;
            end
            obj.attributes = string.empty;
            obj.generateGrid();
        end % fin du constructeur de GeomGrille

        function setDimension(obj, tailleTotale, tailleEcart)
            if nargin == 3
                obj.checkValues(tailleTotale, tailleEcart);
            else
                obj.tailleEcart = 2;
                obj.tailleTotale = 50;
            end
            obj.generateGrid();
            if event.hasListener(obj, 'evt_updateGeom')
                notify(obj, 'evt_updateGeom')
            end
        end % fin de setDimension
    end % fin des methodes defauts

    methods (Access = private)
        function generateGrid(obj)
            e = obj.tailleEcart;
            b = obj.tailleTotale;
            deb = [-b b b -b ; 0 0 0 0 ; -b -b b b]; % contour du carré
            i = e:e:b-e;
            taille = 2*b/e -2;
            matBorne = ones(1, taille)*b;
            matZeros = zeros(1, taille * 4);
            pos = [-matBorne matBorne -i i -i i ; matZeros ; -i i -i i -matBorne matBorne];
            pos = [deb pos];
            pos = pos';
            t = taille/2;
            ind = [0 1 1 2 2 3 3 0];
            for i=0:1:t-1
                ajout = [4+i 4+taille+i   4+t+i 4+t+taille+i   4+2*taille+i 4+2*taille+taille+i   4+2*taille+t+i 4+2*taille+taille+t+i];
                ind = [ind ajout];
            end
            obj.listePoints = pos;
            obj.listeConnection = ind;
        end % fin de generateAxis

        function checkValues(obj, borne, ecart)
            %verifie que les valeurs des argument soient plausibles
            if borne <= 0
                borne = 50;
            end
            if mod(borne, ecart) ~= 0 || borne < ecart || ecart < 0 
                ecart = borne/10;
            end
            obj.tailleEcart = ecart;
            obj.tailleTotale = borne;
        end % fin de checkValues
    end % fin des methodes privees
end % fin classe GeomGrille