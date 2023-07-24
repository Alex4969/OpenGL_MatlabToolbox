classdef Axes < ElementLigne
    %AXES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        debut
        fin
    end
    
    methods

        function obj = Axes(deb, fin)
            %AXES Construct an instance of this class
            [pos, ind, col] = Axes.generateAxes(deb, fin);
            
            axesGeom = Geometry(pos, ind, col);
            obj@ElementLigne(axesGeom);
            obj.debut = deb;
            obj.fin = fin;
        end % fin du constructeur Axes

        function Init(obj, gl, id)
            obj.id = id;
            sommets = [ obj.Geom.listePoints obj.Geom.composanteSupp ];
            obj.GLGeom = GLGeometry(gl, sommets, obj.Geom.listeConnection);
            obj.setAttributeSize(3, 3, 0, 0);
        end % fin de Init

        function deb = getDebut(obj)
            deb = obj.debut;
        end

        function fin = getFin(obj)
            fin = obj.fin;
        end

        function setAxes(obj, gl, newDeb, newFin)
            [pos, ind, col] = Axes.generateAxes(newDeb, newFin);
            obj.ChangeGeom(gl, pos, ind, col);
            obj.setAttributeSize(3, 3, 0, 0);
            obj.debut = newDeb;
            obj.fin = newFin;
        end
    
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
        end
    end

end % fin classe Axes

