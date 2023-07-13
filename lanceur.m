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
[posBoule, indBoule, mappingBoule] = generateSpere(15, 20);
bouleNormalesGeom = Geometry(posBoule, indBoule, posBoule);
bouleNormalesGeom.setModelMatrix(MTrans3D([0 3 0]));
bouleTexGeom = Geometry(posBoule, indBoule, mappingBoule);

% Un cube
[posCube, indCube, mappCub] = generateCube();
cubeGeom = Geometry(posCube, indCube, mappCub);
cubeGeom.setModelMatrix(MScale3D(2));

% Une pyramide
posPyramide = [  -0.5 0.0 -0.5   ;
                  0.5 0.0 -0.5   ;
                  0.5 0.0  0.5   ;
                 -0.5 0.0  0.5   ;
                  0.0 1.0  0.0   ];

mappingPyramide = [ 0 0 ; 1 0 ; 0 0 ; 1 0 ; 0.5 1 ];
couleurPyramide = [ 1 0 0 ; 1 1 0 ; 0 1 0 ; 0 0.6 1 ; 1 1 1];

indicesPyramide = [0 1 2   2 3 0   4 1 0   4 2 1   4 3 2   4 0 3];

[posPyramide, indicesPyramide] = generatePyramide(4, 0.8);

pyraGeom = Geometry(posPyramide, indicesPyramide);

pyraTexGeom = Geometry(posPyramide, indicesPyramide, mappingPyramide);
pyraTexGeom.setModelMatrix(MTrans3D([1 0 0]));

pyraColorGeom = Geometry(posPyramide, indicesPyramide, couleurPyramide);
pyraColorGeom.setModelMatrix(MTrans3D([-1 0 0]));

% un cube importé depuis un fichier
% cube = Geometry();
% cube.CreateFromFile('objets3D/cube.stl');
% cube.setModelMatrix(MTrans3D([0 0 -1]));

% Creation des elements Visible
pyramide1 = ElementFace(pyraGeom);
pyramide1.ModifyModelMatrix(MScale3D(4));
pyramide1.couleurArretes = [1 0 0 1];
pyramide1.couleurFaces = [1 1 1 1];

pyramide2 = ElementFace(pyraColorGeom);
pyramide2.ModifyModelMatrix(MScale3D(4));

pyramide3 = ElementFace(pyraTexGeom);
pyramide3.ModifyModelMatrix(MScale3D(4));

boule = ElementFace(bouleNormalesGeom);
boule.couleurPoints = [0 1 1 1];
boule.epaisseurPoints = 4;
boule.couleurArretes = [1 0 1 1];

boule2 = ElementFace(bouleTexGeom);
boule2.SetModelMatrix(MTrans3D([0 0 3]));
boule2.ModifyModelMatrix(MRot3D([90 0 0]), 1);
boule2.ModifyModelMatrix(MScale3D(2), 1);

cube1 = ElementFace(cubeGeom);

viewer.AddTexture("briques.jpg");
viewer.AddTexture("couleurs.jpg");
viewer.AddTexture("monde.jpg");
viewer.AjouterObjet(pyramide1);
viewer.AjouterObjet(pyramide2, 3, 3, 0, 0);
viewer.AjouterObjet(pyramide3, 3, 0, 2, 0);
viewer.ApplyTexture("briques.jpg", pyramide3)
viewer.AjouterObjet(boule, 3, 0, 0, 3);
viewer.AjouterObjet(boule2, 3, 0, 2, 0);
viewer.ApplyTexture("monde.jpg", boule2);

viewer.lumiere.SetParam([1 0.01 0.005]);
viewer.lumiere.SetPosition([5 5 3]);

%%%%  affichage  %%%%
for i=-45:45
    viewer.Draw();
    rot = MRot3D([0 0 1]);
    boule.ModifyModelMatrix(rot, 1);
    viewer.camera.setPosition([7*sin(i * pi/180) 5 7*cos(i * pi/180)]);
end

%%%%  suppression  %%%%
%viewer.Delete();