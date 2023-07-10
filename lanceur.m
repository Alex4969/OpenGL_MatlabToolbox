clear all

import javax.swing.JFrame

frame = JFrame("une Fenetre");
frame.setDefaultCloseOperation(frame.DISPOSE_ON_CLOSE);
frame.setSize(1280, 720);
frame.setLocationRelativeTo([]);
frame.setVisible(true);

viewer = Scene3D('GL4', frame);

%%%%  definition des objets  %%%%

% Une pyramide
posPyramide = [  -0.5 0.0 -0.5   ;
                  0.5 0.0 -0.5   ;
                  0.5 0.0  0.5   ;
                 -0.5 0.0  0.5   ;
                  0.0 1.0  0.0   ];

mappingPyramide = [ 0 0 ; 1 0 ; 0 0 ; 1 0 ; 0.5 1 ];
couleurPyramide = [ 1 0 0 ; 1 1 0 ; 0 1 0 ; 0 0.6 1 ; 1 1 1];

indicesPyramide = [0 1 2   2 3 0   4 1 0   4 2 1   4 3 2   4 0 3];

pyraGeom = Geometrie(posPyramide, indicesPyramide);

pyraTexGeom = Geometrie(posPyramide, indicesPyramide, mappingPyramide);
pyraTexGeom.setModelMatrix(MTrans3D([1 0 0]));

pyraColorGeom = Geometrie(posPyramide, indicesPyramide, couleurPyramide);
pyraColorGeom.setModelMatrix(MTrans3D([-1 0 0]));

cube = Geometrie();
cube.CreateFromFile('objets3D/cube.stl');
cube.setModelMatrix(MTrans3D([0 0 -1]));

%%%%  affichage  %%%%
viewer.Draw();

%%%%  suppression  %%%%