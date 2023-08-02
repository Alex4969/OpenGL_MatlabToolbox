clear all

addpath('outils\');
addpath('java\');

viewer = Scene3D;
viewer.setCouleurFond([0 0 0.4])

%%%%  definition des objets  %%%%

% generation des parametre de la pyramide
[posPyramide, indicesPyramide, mappingPyramide] = generatePyramide(4, 0.8);

% pyramide simple
pyraGeom = Geometry(1, posPyramide, indicesPyramide);
viewer.AjouterGeom(pyraGeom, 'face');
elem = viewer.mapElements(1);
elem.setCouleurArretes([1 0 0 1]);
elem.setCouleurFaces([1 1 1 1]);
elem.setEpaisseurArretes(5);
elem.setModelMatrix(MTrans3D([-10 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));

% pyramide avec une couleur par sommet
pyraColorGeom = Geometry(2, posPyramide, indicesPyramide);
viewer.AjouterGeom(pyraColorGeom, 'face');

couleurPyramide = [ 1 0 0 1 ; 1 1 0 1 ; 0 1 0 1 ; 0 0.6 1 1 ; 1 1 1 0];
elem = viewer.mapElements(2);
elem.setModelMatrix(MTrans3D([-7 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
elem.AddColor(couleurPyramide);

% % nuage de points avec une couleur par sommet
N=10000;
m=-1;M=1;
posPoints=rand(N,3)*(M-m)+m;
cloudGeom = Geometry(25, posPoints, [1:N]);
viewer.AjouterGeom(cloudGeom, 'point');
elem = viewer.mapElements(25);
elem.setModelMatrix(MTrans3D([-2 4 -4]) * MRot3D([0 0 45]) * MScale3D(1));

elem = viewer.mapElements(25);
couleurPoints = rand(N,3);
elem.AddColor(couleurPoints);

% % pyramide avec texture
pyraTexGeom = Geometry(3, posPyramide, indicesPyramide);
viewer.AjouterGeom(pyraTexGeom, 'face');

elem = viewer.mapElements(3);
elem.setModelMatrix(MTrans3D([-4 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
elem.AddMapping(mappingPyramide);
elem.useTexture('textures/briques.jpg');

% % generation des données d'une sphere
[posBoule, indBoule, mappingBoule] = generateSphere(12, 16, pi * 2);

% % sphere wireframe
bouleGeom = Geometry(4, posBoule, indBoule);
elem = viewer.AjouterGeom(bouleGeom, 'face');

elem.setCouleurArretes([1 1 0]);
elem.setChoixAffichage([0 1 0]);
elem.setModelMatrix(MTrans3D([0 1 0]));

% % sphere avec des normales pour rendu lisse
bouleNormalesGeom = Geometry(5, posBoule, indBoule);
elem = viewer.AjouterGeom(bouleNormalesGeom, 'face');

elem.setModelMatrix(MTrans3D([0 3 0]));
elem.GenerateNormals();
elem.setCouleurArretes([1 0 1 1]);

% % sphere avec texture map monde
bouleTexGeom = Geometry(6, posBoule, indBoule);
elem = viewer.AjouterGeom(bouleTexGeom, 'face');

elem.AddMapping(mappingBoule);
elem.useTexture('textures/monde.jpg');
elem.setModelMatrix(MTrans3D([3, 0, 0]));
elem.ModifyModelMatrix(MRot3D([180 0 0]) * MScale3D(2), 1);
elem.GenerateNormals();

% % piece d'echec depuis un fichier
chessGeom = Geometry(9);
chessGeom.CreateFromFile('objets3D/chess4_ascii.stl');
elem = viewer.AjouterGeom(chessGeom, 'face');

elem.setCouleurFaces(rand(1, 3));
elem.setModelMatrix(MTrans3D([2 0 2]) * MScale3D(0.02)); % pour la piece d'echec
% chess.setModelMatrix(MTrans3D([2 0 2]) * MRot3D([-90 0 0]) * MScale3D(2)); % pour le loup
elem.GenerateNormals();
elem.setModeRendu('D', 'D'); % uniform & dur

ravie = Police("textes/ravie");
elem = viewer.AjouterTexte(101, 'Hello World', ravie, 1);
elem.setModelMatrix(MTrans3D([2 2.2 2]) * MScale3D(0.4));

viewer.lumiere.dotLight(0.01, 0); % lumiere ponctuelle d'intensité 1 / (a * dist² + b * dist + 1)
viewer.lumiere.setColor([1 1 1]);
% [posBoule, indBoule] = generateSphere(8, 10, 2*pi, 0.2);
% bouleLightGeom = Geometry(100, posBoule, indBoule);
% viewer.AddGeomToLight(bouleLightGeom);

%%%%  affichage  %%%%
viewer.Draw();

%%%%  suppression  %%%%
% viewer.delete();