clear all

addpath('outils\');
addpath('java\');

viewer = Scene3D;

viewer.setCouleurFond([0 0 0.4])

%%%%  definition des objets  %%%%

% generation des parametre de la pyramide
[posPyramide, indicesPyramide, mappingPyramide] = generatePyramide(4, 0.8);

% pyramide simple
pyraGeom = Geometry(posPyramide, indicesPyramide);
pyramide1 = ElementFace(pyraGeom);
pyramide1.setModelMatrix(MTrans3D([-10 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
pyramide1.couleurArretes = [1 0 0 1];
pyramide1.couleurFaces = [1 1 1 1];
pyramide1.epaisseurArretes=5;
viewer.AjouterObjet(pyramide1);

% pyramide avec une couleur par sommet
couleurPyramide = [ 1 0 0 1 ; 1 1 0 1 ; 0 1 0 1 ; 0 0.6 1 1 ; 1 1 1 0];
pyraColorGeom = Geometry(posPyramide, indicesPyramide, couleurPyramide);
pyraColorGeom.setModelMatrix(MTrans3D([-7 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
pyramide2 = ElementFace(pyraColorGeom);
viewer.AjouterObjet(pyramide2, 3, 4, 0, 0);

% pyramide avec texture
pyraTexGeom = Geometry(posPyramide, indicesPyramide, mappingPyramide);
pyraTexGeom.setModelMatrix(MTrans3D([-4 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
pyramide3 = ElementFace(pyraTexGeom);
viewer.AjouterObjet(pyramide3, 3, 0, 2, 0);
viewer.ApplyTexture(pyramide3, "briques.jpg")

% generation d'une sphere
[posBoule, indBoule, mappingBoule] = generateSphere(12, 16, pi * 2);

% sphere avec des normales par sommet
%bouleNormalesGeom = Geometry(posBoule, indBoule, posBoule);
bouleNormalesGeom = Geometry(posBoule, indBoule);
bouleNormalesGeom.GenerateNormales();
boule1 = ElementFace(bouleNormalesGeom);
boule1.setModelMatrix(MTrans3D([-0.5 1.8 0]));
boule1.couleurArretes = [1 0 1 1];
viewer.AjouterObjet(boule1, 3, 0, 0, 3);

% sphere classique
bouleGeom = Geometry(posBoule, indBoule);
boule2 = ElementFace(bouleGeom);
boule2.setModelMatrix(MTrans3D([-0.5 -0.2 0]));
boule2.couleurPoints = [1 1 0 1];
%viewer.AjouterObjet(boule2, 3, 0, 0, 0);

% sphere avec texture map monde
bouleTexGeom = Geometry(posBoule, indBoule, mappingBoule);
boule3 = ElementFace(bouleTexGeom);
boule3.setModelMatrix(MTrans3D([3 0 0]));
boule3.ModifyModelMatrix(MRot3D([180 0 0]), 1);
boule3.ModifyModelMatrix(MScale3D(2), 1);
viewer.AjouterObjet(boule3, 3, 0, 2, 0);
viewer.ApplyTexture(boule3, "monde.jpg");

% generation du cylindre
[posCyl, indCyl, mappingCyl, normCyl] = generateCylinder(20, pi, 1, 2, 0);

cylTexGeom = Geometry(posCyl, indCyl, mappingCyl);
cyl2 = ElementFace(cylTexGeom);
cyl2.setModelMatrix(MTrans3D([3 3 0]));
viewer.AjouterObjet(cyl2, 3, 0, 2, 0);
viewer.ApplyTexture(cyl2, "couleurs.jpg");

%generation du plan
[posPlan, indPlan, mappingPlan] = generatePlan(16, 9);
planGeom = Geometry(posPlan, indPlan, mappingPlan);
plan1 = ElementFace(planGeom);
plan1.setModelMatrix(MTrans3D([0 0 -4]));
%viewer.AjouterObjet(plan1, 3, 0, 2, 0);
%viewer.ApplyTexture(plan1, "monde.jpg");

% piece d'echec depuis un fichier
chessGeom = Geometry();
chessGeom.CreateFromFile('objets3D/wolf.stl');
chessGeom.GenerateNormales();
chess = ElementFace(chessGeom);
%chess.setModelMatrix(MTrans3D([2 0 2]) * MScale3D(0.02));
chess.setModelMatrix(MTrans3D([2 0 2]) * MRot3D([-90 0 0]) * MScale3D(2));
viewer.AjouterObjet(chess, 3, 0, 0, 3);
chess.setCouleurFaces(rand(1,3));

ravie = Police("ravie");
% texte1 = ElementTexte('Hello World !', ravie, 0.5, 'N', [0.7 0.1 0.2 1.0]);
% viewer.AjouterTexte(texte1);
% 
% texte2 = ElementTexte('Bienvenue', ravie, 0.08, 'F', [0.2 0.8 0.2 1.0]);
% texte2.setModelMatrix(MTrans3D([-1 1 0]))
% viewer.AjouterTexte(texte2);

texte3 = ElementTexte('Je suis un texte', ravie, 0.4, 'P', [1 0.5 0.7 1.0], [0 0 0], 0);
%texte3.setModelMatrix(MTrans3D([2 2 2]))
viewer.AjouterTexte(texte3);

viewer.lumiere.setParam([1 0.01 0.005]); % lumiere ponctuelle d'intensité 1 / (0.01 * dist² + 0.005 * dist + 1)
viewer.lumiere.setPosition([0 2 3]);
viewer.lumiere.setColor([1 1 1]);
[posBoule, indBoule] = generateSphere(8, 10, 2*pi, 0.2);
bouleLightGeom = Geometry(posBoule, indBoule);
viewer.AddGeomToLight(bouleLightGeom);

texteX = ElementTexte('X', ravie, 1, 'P', [1 1 0 1], [5 0 0], 0);
%texteX.setModelMatrix(MTrans3D([5, 0, 0]))
viewer.AjouterTexte(texteX);

%%%%  affichage  %%%%
viewer.Draw();

%%%%  suppression  %%%%
% viewer.delete();