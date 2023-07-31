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
pyramide1 = ElementFace(pyraGeom);
pyramide1.setModelMatrix(MTrans3D([-10 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
pyramide1.couleurArretes = [1 0 0 1];
pyramide1.couleurFaces = [1 1 1 1];
pyramide1.setEpaisseurArretes(5);
viewer.AjouterObjet(pyramide1);

% pyramide avec une couleur par sommet
couleurPyramide = [ 1 0 0 1 ; 1 1 0 1 ; 0 1 0 1 ; 0 0.6 1 1 ; 1 1 1 0];
%couleurPyramide = [ 1 0 0 ; 1 1 0 ; 0 1 0 ; 0 0.6 1 ; 1 1 1];
pyraColorGeom = Geometry(2, posPyramide, indicesPyramide);
pyraColorGeom.setModelMatrix(MTrans3D([-7 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
pyramide2 = ElementFace(pyraColorGeom);
pyramide2.AddColor(couleurPyramide);
viewer.AjouterObjet(pyramide2);

% pyramide avec texture
pyraTexGeom = Geometry(3, posPyramide, indicesPyramide);
pyraTexGeom.setModelMatrix(MTrans3D([-4 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
pyramide3 = ElementFace(pyraTexGeom);
pyramide3.AddMapping(mappingPyramide);
viewer.AjouterObjet(pyramide3);
viewer.ApplyTexture(pyramide3, "briques.jpg");

% generation d'une sphere
[posBoule, indBoule, mappingBoule] = generateSphere(12, 16, pi * 2);

%sphere avec des normales par sommet
bouleNormalesGeom = Geometry(4, posBoule, indBoule);
boule1 = ElementFace(bouleNormalesGeom);
boule1.GenerateNormals();
boule1.setModelMatrix(MTrans3D([-0.5 1.8 0]));
boule1.couleurArretes = [1 0 1 1];
viewer.AjouterObjet(boule1);

% sphere classique
bouleGeom = Geometry(5, posBoule, indBoule);
boule2 = ElementFace(bouleGeom);
boule2.setModelMatrix(MTrans3D([-0.5 -0.2 0]));
boule2.couleurPoints = [1 1 0 1];
viewer.AjouterObjet(boule2);

% sphere avec texture map monde
bouleTexGeom = Geometry(6, posBoule, indBoule);
boule3 = ElementFace(bouleTexGeom);
boule3.GenerateNormals();
boule3.AddMapping(mappingBoule);
boule3.setModelMatrix(MTrans3D([3 0 0]));
boule3.ModifyModelMatrix(MRot3D([180 0 0]), 1);
boule3.ModifyModelMatrix(MScale3D(2), 1);
viewer.AjouterObjet(boule3);
viewer.ApplyTexture(boule3, "monde.jpg");



% generation du cylindre
[posCyl, indCyl, mappingCyl, normCyl] = generateCylinder(20, pi, 1, 2, 0);

cylTexGeom = Geometry(7, posCyl, indCyl);
cyl2 = ElementFace(cylTexGeom);
cyl2.AddMapping(mappingCyl);
cyl2.setModelMatrix(MTrans3D([3 3 0]));
viewer.AjouterObjet(cyl2);
viewer.ApplyTexture(cyl2, "couleurs.jpg");

%generation du plan
% [posPlan, indPlan, mappingPlan] = generatePlan(16, 9);
% planGeom = Geometry(8, posPlan, indPlan);
% plan1 = ElementFace(planGeom);
% plan1.AddMapping(mappingPlan);
% plan1.setModelMatrix(MTrans3D([0 0 -4]));
% viewer.AjouterObjet(plan1);
% viewer.ApplyTexture(plan1, "monde.jpg");

% piece d'echec depuis un fichier
chessGeom = Geometry(9);
chessGeom.CreateFromFile('objets3D/chess4_ascii.stl');
chess = ElementFace(chessGeom);
chess.GenerateNormals();
chess.setCouleurFaces(rand(1,3));
chess.setModelMatrix(MTrans3D([2 0 2]) * MScale3D(0.02));
% chess.setModelMatrix(MTrans3D([2 0 2]) * MRot3D([-90 0 0]) * MScale3D(2));
viewer.AjouterObjet(chess);

ravie = Police("ravie");
texteP = ElementTexte(11, 'Texte perspective', ravie, 'P', [1 0.5 0.7 1.0], 0);
texteP.setModelMatrix(MTrans3D([-2 -2 -2]));
viewer.AjouterObjet(texteP);

texteN = ElementTexte(13, 'Texte Ancre', ravie, 'N', [0.8 0.1 0.65 1.0], 0);
texteN.setModelMatrix(MTrans3D([2 2 2]));
viewer.AjouterObjet(texteN);

viewer.lumiere.dotLight(0.01, 0); % lumiere ponctuelle d'intensité 1 / (a * dist² + b * dist + 1)
viewer.lumiere.setColor([1 1 1]);
% [posBoule, indBoule] = generateSphere(8, 10, 2*pi, 0.2);
% bouleLightGeom = Geometry(100, posBoule, indBoule);
% viewer.AddGeomToLight(bouleLightGeom);

%%%%  affichage  %%%%
viewer.Draw();

%%%%  suppression  %%%%
% viewer.delete();