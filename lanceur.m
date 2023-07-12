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
bouleGeom = Geometry(posBoule, indBoule, posBoule);
bouleGeom.setModelMatrix(MTrans3D([0 3 0]));

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
pyramide1.ModifyModelMatrix(MScale3D(4));
pyramide1.couleurArretes = [1 0 0 1];
pyramide1.couleurFaces = [1 1 1 1];

pyramide2 = ElementFace(pyraColorGeom);
pyramide2.ModifyModelMatrix(MScale3D(4));

pyramide3 = ElementFace(pyraTexGeom);
pyramide3.ModifyModelMatrix(MScale3D(4));

boule = ElementFace(bouleGeom);
boule.couleurPoints = [0 1 1 1];
boule.epaisseurPoints = 4;
boule.couleurArretes = [1 0 1 1];

viewer.AjouterObjet(pyramide1);
viewer.AjouterObjet(pyramide2, 3, 3, 0, 0);
viewer.AjouterObjet(pyramide3, 3, 0, 2, 0);
viewer.AddTexture("briques.jpg");
viewer.AddTexture("sable.png");
viewer.AddTexture("couleurs.jpg");
viewer.ApplyTexture("briques.jpg", pyramide3)
viewer.AjouterObjet(boule, 3, 0, 0, 3);
viewer.lumiere.SetParam([2 0.01 0.005]);
viewer.lumiere.SetPosition([5 5 3]);

%%%%  affichage  %%%%
for i=-45:30
    viewer.Draw();
    rot = MRot3D([0 0 1]);
    boule.ModifyModelMatrix(rot, 1);
    viewer.camera.setPosition([7*sin(i * pi/180) 5 7*cos(i * pi/180)]);
end

%%%%  suppression  %%%%
viewer.Delete();