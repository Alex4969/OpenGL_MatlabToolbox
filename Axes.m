classdef Axes < ElementLigne
    %AXES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods

        function obj = Axes(deb, fin)
            %AXES Construct an instance of this class
            sommetsValeurs = [  deb   0.0   0.0 ;   % 0
                                fin   0.0   0.0 ;   % 1
                                0.0   deb   0.0 ;   % 2 
                                0.0   fin   0.0 ;   % 3
                                0.0   0.0   deb ;   % 4
                                0.0   0.0   fin ];  % 5
            sommetsCouleur = [1.0 0.0 0.0 ; 1.0 0.0 0.0 ; 0.0 1.0 0.0 ; 0.0 1.0 0.0 ; 0.0 0.0 1.0 ; 0.0 0.0 1.0 ];
            indices = [0 1 2 3 4 5];
            
            axesGeom = Geometry(sommetsValeurs, indices, sommetsCouleur);
            obj@ElementLigne(axesGeom);
        end % fin du constructeur Axes

        function Init(obj, gl)
            sommets = [ obj.Geom.listePoints obj.Geom.composanteSupp ];
            obj.GLGeom = GLGeometry(gl, sommets, obj.Geom.listeConnection);
            obj.SetAttributeSize(3, 3, 0, 0);
        end % fin de Init

    end % fin des methdoes defauts

end % fin classe Axes

