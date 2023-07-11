clear all

addpath('outils\');

import javax.swing.JFrame

frame = JFrame("Ma Scene OpenGL");
frame.setDefaultCloseOperation(frame.DISPOSE_ON_CLOSE);
frame.setSize(1280, 720);
frame.setLocationRelativeTo([]);
frame.setVisible(true);

viewer = Scene3D('GL4', frame);

%%%%  definition des objets  %%%%

% Une boule

[posBoule, indBoule] = generateSpere(8, 10);
bouleGeom = Geometry(posBoule, indBoule);

% Une pyramide
posPyramide = [  -0.5 0.0 -0.5   ;
                  0.5 0.0 -0.5   ;
                  0.5 0.0  0.5   ;
                 -0.5 0.0  0.5   ;
                  0.0 1.0  0.0   ];

mappingPyramide = [ 0 0 ; 1 0 ; 0 0 ; 1 0 ; 0.5 1 ];
couleurPyramide = [ 1 0 0 ; 1 1 0 ; 0 1 0 ; 0 0.6 1 ; 1 1 1];

indicesPyramide = [0 1 2   2 3 0   4 1 0   4 2 1   4 3 2   4 0 3];

pyraGeom = Geometry(posPyramide, indicesPyramide);

pyraTexGeom = Geometry(posPyramide, indicesPyramide, mappingPyramide);
pyraTexGeom.setModelMatrix(MTrans3D([1 0 0]));

pyraColorGeom = Geometry(posPyramide, indicesPyramide, couleurPyramide);
pyraColorGeom.setModelMatrix(MTrans3D([-1 0 0]));

% un cube importé depuis un fichier
cube = Geometry();
cube.CreateFromFile('objets3D/cube.stl');
cube.setModelMatrix(MTrans3D([0 0 -1]));

% Creation des elements Visible
pyramide1 = ElementFace(pyraGeom);
pyramide1.couleurArretes = [1 0 0 1];
pyramide1.couleurFaces = [1 1 0 1];
boule = ElementFace(bouleGeom);
boule.couleurPoints = [0 1 1 1];
boule.epaisseurPoints = 4;
boule.couleurArretes = [1 0 1 1];

%viewer.ajouterObjet(pyramide1);
viewer.ajouterObjet(boule);

%%%%  affichage  %%%%
for i=1:1:360
    viewer.Draw();
    rot = MRot3D([0 0 i]);
    boule.Geom.setModelMatrix(rot);

end

%%%%  suppression  %%%%
viewer.Delete();