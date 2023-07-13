clear all

addpath('outils');

import javax.swing.JFrame

frame = JFrame("Ma Scene OpenGL");
frame.setDefaultCloseOperation(frame.DISPOSE_ON_CLOSE);
frame.setSize(1280, 720);
frame.setLocationRelativeTo([]);
frame.setVisible(true);

viewer = Scene3D('GL4', frame);

%%%%  definition des objets  %%%%

% generation des parametre de la pyramide
[posPyramide, indicesPyramide, mappingPyramide] = generatePyramide(4, 0.8);

% pyramide simple
pyraGeom = Geometry(posPyramide, indicesPyramide);
pyramide1 = ElementFace(pyraGeom);
pyramide1.SetModelMatrix(MTrans3D([-10 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
pyramide1.couleurArretes = [1 0 0 1];
pyramide1.couleurFaces = [1 1 1 1];
viewer.AjouterObjet(pyramide1);

% pyramide avec une couleur par sommet
couleurPyramide = [ 1 0 0 ; 1 1 0 ; 0 1 0 ; 0 0.6 1 ; 1 1 1];
pyraColorGeom = Geometry(posPyramide, indicesPyramide, couleurPyramide);
pyraColorGeom.SetModelMatrix(MTrans3D([-7 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
pyramide2 = ElementFace(pyraColorGeom);
viewer.AjouterObjet(pyramide2, 3, 3, 0, 0);

% pyramide avec texture
pyraTexGeom = Geometry(posPyramide, indicesPyramide, mappingPyramide);
pyraTexGeom.SetModelMatrix(MTrans3D([-4 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
pyramide3 = ElementFace(pyraTexGeom);
viewer.AjouterObjet(pyramide3, 3, 0, 2, 0);
viewer.AddTexture("briques.jpg");
viewer.ApplyTexture("briques.jpg", pyramide3)

% generation d'une sphere
[posBoule, indBoule, mappingBoule] = generateSpere(12, 16, 0.8);

% sphere avec des normales par sommet
bouleNormalesGeom = Geometry(posBoule, indBoule, posBoule);
boule1 = ElementFace(bouleNormalesGeom);
boule1.SetModelMatrix(MTrans3D([-0.5 1.8 0]));
boule1.couleurArretes = [1 0 1 1];
viewer.AjouterObjet(boule1, 3, 0, 0, 3);

% sphere classique
bouleGeom = Geometry(posBoule, indBoule);
boule2 = ElementFace(bouleGeom);
boule2.SetModelMatrix(MTrans3D([-0.5 -0.2 0]));
boule2.couleurPoints = [1 1 0 1];
viewer.AjouterObjet(boule2, 3, 0, 0, 0);

% sphere avec texture map monde
bouleTexGeom = Geometry(posBoule, indBoule, mappingBoule);
boule3 = ElementFace(bouleTexGeom);
boule3.SetModelMatrix(MTrans3D([3 0 0]));
boule3.ModifyModelMatrix(MRot3D([180 0 0]), 1);
boule3.ModifyModelMatrix(MScale3D(2), 1);
viewer.AjouterObjet(boule3, 3, 0, 2, 0);
viewer.AddTexture("monde.jpg");
viewer.ApplyTexture("monde.jpg", boule3);

% piece d'echec depuis un fichier
chessGeom = Geometry();
chessGeom.CreateFromFile('objets3D/chess4_ascii.stl');
chess = ElementFace(chessGeom);
chess.SetModelMatrix(MTrans3D([7 0 0]) * MScale3D(0.02));
viewer.AjouterObjet(chess);

viewer.lumiere.setParam([1 0.01 0.005]); % lumiere ponctuelle d'intensité 1 / (0.01 * dist² + 0.005 * dist + 1)
viewer.lumiere.setPosition([0 2 3]);
[posBoule, indBoule] = generateSpere(8, 10, 0.5);
bouleLightGeom = Geometry(posBoule, indBoule);
viewer.AddGeomToLight(bouleLightGeom);

%%%%  affichage  %%%%
for i=-10:0.06:10
    rot = MRot3D([0 0 1]);
    boule1.ModifyModelMatrix(rot, 1);
    boule2.ModifyModelMatrix(rot, 1);
    % viewer.camera.setPosition([7*sin(i * pi/180) 5 7*cos(i * pi/180)]);
    viewer.camera.setPosition([i 4 5]);
    viewer.camera.setTarget([i 0 0]);
    viewer.lumiere.setPosition([i 0 3]);
    viewer.lumiere.setColor([0.75+i/28 1 0.75-i/28]);
    viewer.Draw();
end

%%%%  suppression  %%%%
viewer.Delete();