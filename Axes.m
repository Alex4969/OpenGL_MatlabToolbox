classdef Axes < ElementLigne
    %AXES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        debut
        fin
    end
    
    methods

        function obj = Axes(id, deb, fin)
            %AXES Construct an instance of this class
            [pos, ind, col] = Axes.generateAxes(deb, fin);
            axesGeom = Geometry(id, pos, ind);
            obj@ElementLigne(axesGeom);
            obj.AddColor(col);
            obj.debut = deb;
            obj.fin = fin;
        end % fin du constructeur Axes

        function deb = getDebut(obj)
            deb = obj.debut;
        end

        function fin = getFin(obj)
            fin = obj.fin;
        end

        function setAxes(obj, gl, newDeb, newFin)
            disp('Cette fonction doit etre refaite') %% A REFAIRE
            [pos, ind, col] = Axes.generateAxes(newDeb, newFin);
            obj.ChangeGeom(gl, pos, ind, col);
            obj.debut = newDeb;
            obj.fin = newFin;
        end % fin de setAxes
    
    end % fin des methdoes defauts

    methods (Static)
        function [sommetsValeurs, indices, sommetsCouleur] = generateAxes(deb, fin)
            sommetsValeurs = [  deb   0.0   0.0 ;   % 0
                                fin   0.0   0.0 ;   % 1
                                0.0   deb   0.0 ;   % 2 
                                0.0   fin   0.0 ;   % 3
                                0.0   0.0   deb ;   % 4
                                0.0   0.0   fin ];  % 5
            sommetsCouleur = [1.0 0.0 0.0 ; 1.0 0.0 0.0 ; 0.0 1.0 0.0 ; 0.0 1.0 0.0 ; 0.0 0.0 1.0 ; 0.0 0.0 1.0 ];
            indices = [0 1 2 3 4 5];
        end %fin de generateAxes
    end % fin des methodes static

end % fin classe Axes

