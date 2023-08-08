clear all

addpath('outils\');
addpath('java\');

viewer = Scene3D;
viewer.setCouleurFond([0 0 0.4])
viewer.lumiere.dotLight(0.01, 0); % lumiere ponctuelle d'intensité 1 / (a * dist² + b * dist + 1)
viewer.lumiere.setColor([1 1 1]);

%%%%  definition des objets  %%%%

% generation des parametre de la pyramide
[posPyramide, indicesPyramide, mappingPyramide] = generatePyramide(4, 0.8);

% pyramide avec une couleur par sommet
pyraColorGeom = MyGeom(1, posPyramide, indicesPyramide, 'face');
viewer.AddComponent(pyraColorGeom);

couleurPyramide = [ 1 0 0 1 ; 1 1 0 1 ; 0 1 0 1 ; 0 0.6 1 1 ; 1 1 1 0];
elem = viewer.mapElements(1);
elem.setModelMatrix(MTrans3D([-7 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
elem.AddColor(couleurPyramide);
elem.setCouleurArretes([1 0 1]);

% % nuage de points avec une couleur par sommet
N=10000;
m=-1;M=1;
posPoints=rand(N,3)*(M-m)+m;
cloudGeom = MyGeom(25, posPoints, [1:N], 'point');
elem = viewer.AddComponent(cloudGeom);
elem.setModelMatrix(MTrans3D([-2 4 -4]) * MRot3D([0 0 45]) * MScale3D(1));

couleurPoints = rand(N,3);
elem.AddColor(couleurPoints);

% % generation des données d'une sphere
[posBoule, indBoule, mappingBoule] = generateSphere(12, 16, pi * 2);

% % sphere wireframe
bouleGeom = MyGeom(2, posBoule, indBoule, 'face');
elem = viewer.AddComponent(bouleGeom);

elem.setCouleurArretes([1 1 0]);
elem.setEpaisseurArretes(3);
elem.setQuoiAfficher(2);
elem.setModelMatrix(MTrans3D([-4 1 0]));

% % sphere avec texture map monde
bouleTexGeom = MyGeom(3, posBoule, indBoule, 'face');
elem = viewer.AddComponent(bouleTexGeom);

elem.AddMapping(mappingBoule);
elem.useTexture('textures/monde.jpg');
elem.setModelMatrix(MTrans3D([3, 0, 0]));
elem.ModifyModelMatrix(MRot3D([180 0 0]) * MScale3D(2), 1);
elem.GenerateNormals();

% % piece d'echec depuis un fichier
chessGeom = FileGeom(5, 'objets3D/chess4_ascii.stl', 'face');
elem = viewer.AddComponent(chessGeom);

elem.setCouleur(rand(1, 3));
elem.setModelMatrix(MTrans3D([2 0 2]) * MScale3D(0.02)); % pour la piece d'echec
% chess.setModelMatrix(MTrans3D([2 0 2]) * MRot3D([-90 0 0]) * MScale3D(2)); % pour le loup
elem.GenerateNormals();
elem.setQuoiAfficher(3);
elem.setModeRendu('U', 'D'); % uniform & dur

ravie = Police("textes/ravie");
geomTexte = TextGeom(101, 'Hello World !', ravie, 1);
elemtexte = viewer.AddComponent(geomTexte);
elemtexte.setModelMatrix(MTrans3D([2 2.2 2]) * MScale3D(0.4));

viewer.lumiere.dotLight(0.01, 0); % lumiere ponctuelle d'intensité 1 / (a * dist² + b * dist + 1)
viewer.lumiere.setColor([1 1 1]);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % sphere avec des normales pour rendu lisse
    bouleNormalesGeom = Geometry(31, posBoule, indBoule);
    bouleNormalesGeom.setModelMatrix(MTrans3D([0 0.8 0]) * MScale3D(0.8));
    elem = viewer.AjouterGeom(bouleNormalesGeom, 'face');
    
    elem.GenerateNormals();
    elem.setCouleurArretes([1 0 1 1]);

    % autre sphere
    bouleNormalesGeom2 = Geometry(32, posBoule, indBoule);
    bouleNormalesGeom2.setModelMatrix(MTrans3D([0 3.9 0]) * MScale3D(1.2));
    elem = viewer.AjouterGeom(bouleNormalesGeom2, 'face');
    elem.setCouleurFaces([0 1 0.8 1]);

    % pyramide avec texture
    pyraTexGeom = Geometry(33, posPyramide, indicesPyramide);
    pyraTexGeom.setModelMatrix(MTrans3D([0 1.8 0]) * MRot3D([0 -45 0]) * MScale3D(1.3));
    elem = viewer.AjouterGeom(pyraTexGeom, 'face');

    elem.AddMapping(mappingPyramide);
    elem.useTexture('textures/briques.jpg');

    [pos, ind] = generatePlan(3, 3);
    planGeom = Geometry(34, pos, ind);
    planGeom.setModelMatrix(MRot3D([90 0 0]));
    viewer.AjouterGeom(planGeom, 'face');

listeId = 31:34;
ens = viewer.makeGroup(30, listeId, [0 2 0]);
ens.setModelMatrix(MTrans3D([3 3 -3]) * MRot3D([0 45 0]));

% Ajout texte
geomTexte = TextGeom(102, 'X', ravie, 0);
elementTexte = viewer.AddComponent(geomTexte);
elementTexte.setModelMatrix(MTrans3D([1 0 0]));
elementTexte.setCouleur([1 0 0]);
elementTexte.typeOrientation = 2 + 4;

% % % sphere avec des normales pour rendu lisse
bouleNormalesGeom = MyGeom(31, posBoule, indBoule, 'face');
bouleNormalesGeom.setModelMatrix(MTrans3D([0 0.8 0]) * MScale3D(0.8));
elem = viewer.AddComponent(bouleNormalesGeom);
elem.GenerateNormals();
elem.setCouleurArretes([1 0 1 1]);

bouleNormalesGeom2 = MyGeom(32, posBoule, indBoule, 'face');
bouleNormalesGeom2.setModelMatrix(MTrans3D([0 3.9 0]) * MScale3D(1.2));
elem = viewer.AddComponent(bouleNormalesGeom2);
elem.setCouleur([0 1 0.8 1]);

% % pyramide avec texture
pyraTexGeom = MyGeom(33, posPyramide, indicesPyramide, 'face');
pyraTexGeom.setModelMatrix(MTrans3D([0 1.8 0]) * MRot3D([0 -45 0]) * MScale3D(1.3));
elem = viewer.AddComponent(pyraTexGeom);

elem.AddMapping(mappingPyramide);
elem.useTexture('textures/briques.jpg');

[pos, ind] = generatePlan(3, 3);
planGeom = MyGeom(34, pos, ind, 'face');
planGeom.setModelMatrix(MRot3D([90 0 0]));
viewer.AddComponent(planGeom);

group = viewer.CreateGroup(1);
group.AddElem(viewer.mapElements(31));
group.AddElem(viewer.mapElements(32));
group.AddElem(viewer.mapElements(33));
group.AddElem(viewer.mapElements(34));
group.setModelMatrix(MTrans3D([3 3 -3]) * MRot3D([0 45 0]));

%listeId = 31:34;
%ens = viewer.makeGroup(30, listeId, [0 2 0]);
%ens.setModelMatrix(MTrans3D([3 3 -3]) * MRot3D([0 45 0]));

% [posBoule, indBoule] = generateSphere(8, 10, 2*pi, 0.2);
% bouleLightGeom = Geometry(100, posBoule, indBoule);
% viewer.AddGeomToLight(bouleLightGeom);

%%%%  affichage  %%%%
viewer.Draw();

%%%%  suppression  %%%%
% viewer.delete();