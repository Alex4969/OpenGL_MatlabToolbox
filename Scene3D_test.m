classdef Scene3D_test < Scene3D
    % Test of Scene3D

    properties
        
    end

    methods
        function obj = Scene3D_test()

        end
    end

% ******************** TESTS AND DEBUG ********************


    %test and debug with member functions
    methods
        function test1(obj)
            
            addpath('outils\');
            addpath('java\');
            addpath('Component\');
            
            viewer = obj;
            viewer.setBackgroundColor([0 0 0.4])
            viewer.lumiere.dotLight(0.01, 0); % lumiere ponctuelle d'intensité 1 / (a * dist² + b * dist + 1)
            viewer.lumiere.setColor([1 1 1]);
            viewer.DrawScene();
            %%%%  definition des objets  %%%%
            
            % generation des parametre de la pyramide
            [posPyramide, indicesPyramide, mappingPyramide] = generatePyramide(4, 0.8);
            
            % pyramide avec une couleur par sommet
            pyraColorGeom = GeomFace(1, posPyramide, indicesPyramide);
            viewer.AddElement(pyraColorGeom);
            
            couleurPyramide = [ 1 0 0 1 ; 1 1 0 1 ; 0 1 0 1 ; 0 0.6 1 1 ; 1 1 1 0];
            elem = viewer.mapElements(1);
            elem.setModelMatrix(MTrans3D([-7 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
            elem.AddColor(couleurPyramide);
            
            % % nuage de points avec une couleur par sommet
            N = 10000;
            m = -1; M = 1;
            posPoints=rand(N,3)*(M-m)+m;
            cloudGeom = GeomPoint(25, posPoints);
            elem = viewer.AddElement(cloudGeom);
            elem.setModelMatrix(MTrans3D([-2 4 -4]) * MRot3D([0 0 45]) * MScale3D(1));
            
            couleurPoints = rand(N,3);
            elem.AddColor(couleurPoints);
            
            % % generation des données d'une sphere
            [posBoule, indBoule, mappingBoule] = generateSphere(12, 16, pi * 2);
            
            % % sphere wireframe
            bouleGeom = MyGeom(2, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleGeom);
            
            elem.setCouleurArretes([1 1 0]);
            elem.setEpaisseurArretes(3);
            elem.setQuoiAfficher(2);
            elem.setModelMatrix(MTrans3D([-4 1 0]));
            
            % % sphere avec texture map monde
            bouleTexGeom = MyGeom(3, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleTexGeom);
            
            elem.AddMapping(mappingBoule);
            elem.useTexture('textures/monde.jpg');
            elem.setModelMatrix(MTrans3D([3, 0, 0]));
            elem.ModifyModelMatrix(MRot3D([180 0 0]) * MScale3D(2), 1);
            elem.AddNormals(posBoule);
            
            % % piece d'echec depuis un fichier
            chessGeom = MyGeom(5, "face", "objets3D/chess4_ascii.stl");
            elem = viewer.AddElement(chessGeom);
            
            elem.setColor(rand(1, 3));
            elem.setModelMatrix(MTrans3D([2 0 2]) * MScale3D(0.02)); % pour la piece d'echec
            % chess.setModelMatrix(MTrans3D([2 0 2]) * MRot3D([-90 0 0]) * MScale3D(2)); % pour le loup
            elem.GenerateNormals();
            elem.setQuoiAfficher(3);
            elem.setModeColoration("UNIFORME");
            elem.setModeShading("DUR");
            
            ravie = Police("textes/ravie");
            geomTexte = GeomTexte(101, 'Hello World !', ravie, "CENTRE");
            elemtexte = viewer.AddElement(geomTexte);
            elemtexte.setModelMatrix(MTrans3D([2 2.2 2]) * MScale3D(0.4));
            
            geomTexteFixe = GeomTexte(102, 'Bienvenue', ravie, "HAUT_GAUCHE");
            elemtexte = viewer.AddElement(geomTexteFixe);
            elemtexte.setModelMatrix(MTrans3D([-1 1 0]));
            elemtexte.setOrientation("FIXE");
            
            geomTexteX = GeomTexte(111, 'X', ravie, "CENTRE");
            elementTexte = viewer.AddElement(geomTexteX);
            elementTexte.setModelMatrix(MTrans3D([1 0 0]));
            elementTexte.setOrientation("REPERE_NORMAL");
            
            %% Creation d'un group
                % sphere avec des normales pour rendu lisse
                bouleNormalesGeom = MyGeom(31, "face", posBoule, indBoule);
                bouleNormalesGeom.setModelMatrix(MTrans3D([0 0.8 0]) * MScale3D(0.8));
                elem = viewer.AddElement(bouleNormalesGeom);
                elem.AddNormals(posBoule);
                elem.setCouleurArretes([1 0 1 1]);
                
                % autre sphere
                bouleNormalesGeom2 = MyGeom(32, "face", posBoule, indBoule);
                bouleNormalesGeom2.setModelMatrix(MTrans3D([0 3.9 0]) * MScale3D(1.2));
                elem = viewer.AddElement(bouleNormalesGeom2);
                elem.setColor([0 1 0.8 1]);
                
                % pyramide avec texture
                pyraTexGeom = MyGeom(33, "face", posPyramide, indicesPyramide);
                pyraTexGeom.setModelMatrix(MTrans3D([0 1.8 0]) * MRot3D([0 -45 0]) * MScale3D(1.3));
                elem = viewer.AddElement(pyraTexGeom);
                
                elem.AddMapping(mappingPyramide);
                elem.useTexture('textures/briques.jpg');
                
                % plan
                [pos, ind, map] = generatePlan(3, 3);
                planGeom = MyGeom(34, "face", pos, ind);
                planGeom.setModelMatrix(MRot3D([90 0 0]));
                viewer.AddElement(planGeom);
                
                % creation du groupe
                group = viewer.CreateGroup(1);
                group.AddElem(viewer.mapElements(31));
                group.AddElem(viewer.mapElements(32));
                group.AddElem(viewer.mapElements(33));
                group.AddElem(viewer.mapElements(34));
                group.setModelMatrix(MTrans3D([3 3 -3]) * MRot3D([0 45 0]));
            
            [posLight, indLight] = generatePyramide(50, 1);
            bouleLightGeom = MyGeom(1000, "face", posLight, indLight);
            elem = viewer.lumiere.setForme(bouleLightGeom);
            
            %%%%  affichage  %%%%
            viewer.DrawScene();
            
            %%%%  suppression  %%%%
            % viewer.delete();            
        end

        function test2(obj)
            
            addpath('outils\');
            addpath('java\');
            addpath('Component\');
            
            viewer = obj;
            viewer.setBackgroundColor([0.05 0.05 0.1]);
            % % % viewer.lumiere.dotLight(0.01, 0 , 1); % lumiere ponctuelle d'intensité 1 / (a * dist² + b * dist + 1)

            viewer.lumiere.spotLight(3,6);
            viewer.lumiere.setColor([1 1 1]);
            viewer.DrawScene();

            %welcome message
            viewer.fenetre.setTextNorth('Welcome in virtual X-ray Imaging',10);

            %%%%  definition des objets  %%%%
            
            % generation des parametre de la pyramide
            [posPyramide, indicesPyramide, mappingPyramide] = generatePyramide(4, 0.8);
            
            % pyramide avec une couleur par sommet
            pyraColorGeom = GeomFace(1, posPyramide, indicesPyramide);
            viewer.AddElement(pyraColorGeom);
            
            couleurPyramide = [ 1 0 0 1 ; 1 1 0 1 ; 0 1 0 1 ; 0 0.6 1 1 ; 1 1 1 0];
            elem = viewer.mapElements(1);
            elem.setModelMatrix(MTrans3D([-7 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
            elem.AddColor(couleurPyramide);
            
            % % nuage de points avec une couleur par sommet
            N = 10000;
            m = -1; M = 1;
            posPoints=rand(N,3)*(M-m)+m;
            cloudGeom = GeomPoint(25, posPoints);
            elem = viewer.AddElement(cloudGeom);
            elem.setModelMatrix(MTrans3D([-2 4 -4]) * MRot3D([0 0 45]) * MScale3D(1));
            
            couleurPoints = rand(N,3);
            elem.AddColor(couleurPoints);
            
            % % generation des données d'une sphere
            [posBoule, indBoule, mappingBoule] = generateSphere(12, 16, pi * 2);
            
            % % sphere wireframe
            bouleGeom = MyGeom(2, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleGeom);
            
            elem.setCouleurArretes([1 1 0]);
            elem.setEpaisseurArretes(3);
            elem.setQuoiAfficher(2);
            elem.setModelMatrix(MTrans3D([-4 1 0]));
            
            % % sphere avec texture map monde
            bouleTexGeom = MyGeom(3, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleTexGeom);
            
            elem.AddMapping(mappingBoule);
            elem.useTexture('textures/monde.jpg');
            elem.setModelMatrix(MTrans3D([3, 0, 0]));
            elem.ModifyModelMatrix(MRot3D([180 0 0]) * MScale3D(2), 1);
            elem.AddNormals(posBoule);
            
            % % piece d'echec depuis un fichier
            chessGeom = MyGeom(5, "face", "objets3D/chess4_ascii.stl");
            elem = viewer.AddElement(chessGeom);
            
            elem.setColor(rand(1, 3));
            elem.setModelMatrix(MTrans3D([2 0 2]) * MScale3D(0.02)); % pour la piece d'echec
            % chess.setModelMatrix(MTrans3D([2 0 2]) * MRot3D([-90 0 0]) * MScale3D(2)); % pour le loup
            elem.GenerateNormals();
            elem.setQuoiAfficher(3);
            elem.setModeColoration("UNIFORME");
            elem.setModeShading("DUR");
            
            ravie = Police("textes/ravie");
            geomTexte = GeomTexte(101, 'Hello World !', ravie, "CENTRE");
            elemtexte = viewer.AddElement(geomTexte);
            elemtexte.setModelMatrix(MTrans3D([2 2.2 2]) * MScale3D(0.4));
            
            geomTexteFixe = GeomTexte(102, 'Bienvenue', ravie, "HAUT_GAUCHE");
            elemtexte = viewer.AddElement(geomTexteFixe);
            elemtexte.setModelMatrix(MTrans3D([-1 1 0]));
            elemtexte.setOrientation("FIXE");
            
            timesnewroman = Police("textes/timesnewroman");
            geomTexteX = GeomTexte(111, 'X', timesnewroman, "CENTRE");
            elementTexte = viewer.AddElement(geomTexteX);
            elementTexte.setModelMatrix(MTrans3D([1.3 0 0]));
            elementTexte.setColor([1 0 0]);
            elementTexte.setSize(0.3);
            elementTexte.setOrientation("REPERE_NORMAL");
            
            %% Creation d'un group
                % sphere avec des normales pour rendu lisse
                bouleNormalesGeom = MyGeom(31, "face", posBoule, indBoule);
                bouleNormalesGeom.setModelMatrix(MTrans3D([0 0.8 0]) * MScale3D(0.8));
                elem = viewer.AddElement(bouleNormalesGeom);
                elem.AddNormals(posBoule);
                elem.setCouleurArretes([1 0 1 1]);
                
                % autre sphere
                bouleNormalesGeom2 = MyGeom(32, "face", posBoule, indBoule);
                bouleNormalesGeom2.setModelMatrix(MTrans3D([0 3.9 0]) * MScale3D(1.2));
                elem = viewer.AddElement(bouleNormalesGeom2);
                elem.setColor([0 1 0.8 1]);
                
                % pyramide avec texture
                pyraTexGeom = MyGeom(33, "face", posPyramide, indicesPyramide);
                pyraTexGeom.setModelMatrix(MTrans3D([0 1.8 0]) * MRot3D([0 -45 0]) * MScale3D(1.3));
                elem = viewer.AddElement(pyraTexGeom);
                
                elem.AddMapping(mappingPyramide);
                elem.useTexture('textures/briques.jpg');
                
                % plan
                [pos, ind, map] = generatePlan(3, 3);
                planGeom = MyGeom(34, "face", pos, ind);
                planGeom.setModelMatrix(MRot3D([90 0 0]));
                viewer.AddElement(planGeom);
                
                % creation du groupe
                group = viewer.CreateGroup(1);
                group.AddElem(viewer.mapElements(31));
                group.AddElem(viewer.mapElements(32));
                group.AddElem(viewer.mapElements(33));
                group.AddElem(viewer.mapElements(34));
                group.setModelMatrix(MTrans3D([3 3 -3]) * MRot3D([0 45 0]));
            
            [posLight, indLight] = generatePyramide(50, 1);
            bouleLightGeom = MyGeom(1000, "face", posLight, indLight);
            elem = viewer.lumiere.setForme(bouleLightGeom);
            
            %%%%  affichage  %%%%
            viewer.DrawScene();
            
            %%%%  suppression  %%%%
            % viewer.delete();            
        end
        
        function test3(obj)
            
            addpath('outils\');
            addpath('java\');
            addpath('Component\');
            
            viewer = obj;
            viewer.setBackgroundColor([0.05 0.05 0.1]);
            viewer.lumiere.dotLight(0.001, 0, 1); % lumiere ponctuelle d'intensité 1 / (a * dist² + b * dist + 1)
            viewer.lumiere.setColor([1 1 1]);
            viewer.DrawScene();

            %welcome message
            viewer.fenetre.setTextNorth('Welcome in virtual X-ray Imaging',10);

            engine = MyGeom(64, "face", "objets3D/engine.stl");
            elem1 = viewer.AddElement(engine);
            elem1.setColor([0.85 0.85 0.95 1]);

            % carbu = MyGeom(66, "face", "C:\Users\pduvauchelle\Philippe\Recherche\DATA\Modeles CAO\download\compressor.stl");
            % elem2 = viewer.AddElement(carbu);
            % elem2.setColor([0.05 0.85 0.05 1]);
            % elem2.setModelMatrix(MTrans3D([200 0 -50])*MScale3D(0.5));

            % Cube
            [pos, ind, mapping] = generateCube();
            cubeGeom = GeomFace(1, pos, ind);
            viewer.AddElement(cubeGeom);
            
            elem = viewer.mapElements(1);
            elem.setColor([0 1 1 1]);
            elem.setCouleurArretes([1 0 0]);
            elem.setModelMatrix(MScale3D(230));
        end

    end    

    %test and debug with static functions
    methods (Static)
        function testStatic1(~)
            % clear all
            
            addpath('outils\');
            addpath('java\');
            addpath('Component\');
            
            viewer = Scene3D();
            viewer.setBackgroundColor([0 0 0.4])
            viewer.lumiere.dotLight(0.01, 0); % lumiere ponctuelle d'intensité 1 / (a * dist² + b * dist + 1)
            viewer.lumiere.setColor([1 1 1]);
            viewer.DrawScene();
            %%%%  definition des objets  %%%%
            
            % generation des parametre de la pyramide
            [posPyramide, indicesPyramide, mappingPyramide] = generatePyramide(4, 0.8);
            
            % pyramide avec une couleur par sommet
            pyraColorGeom = GeomFace(1, posPyramide, indicesPyramide);
            viewer.AddElement(pyraColorGeom);
            
            couleurPyramide = [ 1 0 0 1 ; 1 1 0 1 ; 0 1 0 1 ; 0 0.6 1 1 ; 1 1 1 0];
            elem = viewer.mapElements(1);
            elem.setModelMatrix(MTrans3D([-7 0 0]) * MRot3D([0 45 0]) * MScale3D(2.5));
            elem.AddColor(couleurPyramide);
            
            % % nuage de points avec une couleur par sommet
            N = 10000;
            m = -1; M = 1;
            posPoints=rand(N,3)*(M-m)+m;
            cloudGeom = GeomPoint(25, posPoints);
            elem = viewer.AddElement(cloudGeom);
            elem.setModelMatrix(MTrans3D([-2 4 -4]) * MRot3D([0 0 45]) * MScale3D(1));
            
            couleurPoints = rand(N,3);
            elem.AddColor(couleurPoints);
            
            % % generation des données d'une sphere
            [posBoule, indBoule, mappingBoule] = generateSphere(12, 16, pi * 2);
            
            % % sphere wireframe
            bouleGeom = MyGeom(2, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleGeom);
            
            elem.setCouleurArretes([1 1 0]);
            elem.setEpaisseurArretes(3);
            elem.setQuoiAfficher(2);
            elem.setModelMatrix(MTrans3D([-4 1 0]));
            
            % % sphere avec texture map monde
            bouleTexGeom = MyGeom(3, "face", posBoule, indBoule);
            elem = viewer.AddElement(bouleTexGeom);
            
            elem.AddMapping(mappingBoule);
            elem.useTexture('textures/monde.jpg');
            elem.setModelMatrix(MTrans3D([3, 0, 0]));
            elem.ModifyModelMatrix(MRot3D([180 0 0]) * MScale3D(2), 1);
            elem.AddNormals(posBoule);
            
            % % piece d'echec depuis un fichier
            chessGeom = MyGeom(5, "face", "objets3D/chess4_ascii.stl");
            elem = viewer.AddElement(chessGeom);
            
            elem.setColor(rand(1, 3));
            elem.setModelMatrix(MTrans3D([2 0 2]) * MScale3D(0.02)); % pour la piece d'echec
            % chess.setModelMatrix(MTrans3D([2 0 2]) * MRot3D([-90 0 0]) * MScale3D(2)); % pour le loup
            elem.GenerateNormals();
            elem.setQuoiAfficher(3);
            elem.setModeColoration("UNIFORME");
            elem.setModeShading("DUR");
            
            ravie = Police("textes/ravie");
            geomTexte = GeomTexte(101, 'Hello World !', ravie, "CENTRE");
            elemtexte = viewer.AddElement(geomTexte);
            elemtexte.setModelMatrix(MTrans3D([2 2.2 2]) * MScale3D(0.4));
            
            geomTexteFixe = GeomTexte(102, 'Bienvenue', ravie, "HAUT_GAUCHE");
            elemtexte = viewer.AddElement(geomTexteFixe);
            elemtexte.setModelMatrix(MTrans3D([-1 1 0]));
            elemtexte.setOrientation("FIXE");
            
            geomTexteX = GeomTexte(111, 'X', ravie, "CENTRE");
            elementTexte = viewer.AddElement(geomTexteX);
            elementTexte.setModelMatrix(MTrans3D([1 0 0]));
            elementTexte.setColor([1 0 0]);
            elementTexte.setOrientation("REPERE_NORMAL");
            
            %% Creation d'un group
                % sphere avec des normales pour rendu lisse
                bouleNormalesGeom = MyGeom(31, "face", posBoule, indBoule);
                bouleNormalesGeom.setModelMatrix(MTrans3D([0 0.8 0]) * MScale3D(0.8));
                elem = viewer.AddElement(bouleNormalesGeom);
                elem.AddNormals(posBoule);
                elem.setCouleurArretes([1 0 1 1]);
                
                % autre sphere
                bouleNormalesGeom2 = MyGeom(32, "face", posBoule, indBoule);
                bouleNormalesGeom2.setModelMatrix(MTrans3D([0 3.9 0]) * MScale3D(1.2));
                elem = viewer.AddElement(bouleNormalesGeom2);
                elem.setColor([0 1 0.8 1]);
                
                % pyramide avec texture
                pyraTexGeom = MyGeom(33, "face", posPyramide, indicesPyramide);
                pyraTexGeom.setModelMatrix(MTrans3D([0 1.8 0]) * MRot3D([0 -45 0]) * MScale3D(1.3));
                elem = viewer.AddElement(pyraTexGeom);
                
                elem.AddMapping(mappingPyramide);
                elem.useTexture('textures/briques.jpg');
                
                % plan
                [pos, ind, map] = generatePlan(3, 3);
                planGeom = MyGeom(34, "face", pos, ind);
                planGeom.setModelMatrix(MRot3D([90 0 0]));
                viewer.AddElement(planGeom);
                
                % creation du groupe
                group = viewer.CreateGroup(1);
                group.AddElem(viewer.mapElements(31));
                group.AddElem(viewer.mapElements(32));
                group.AddElem(viewer.mapElements(33));
                group.AddElem(viewer.mapElements(34));
                group.setModelMatrix(MTrans3D([3 3 -3]) * MRot3D([0 45 0]));
            
            [posLight, indLight] = generatePyramide(50, 1);
            bouleLightGeom = MyGeom(1000, "face", posLight, indLight);
            elem = viewer.lumiere.setForme(bouleLightGeom);
            
            %%%%  affichage  %%%%
            viewer.DrawScene();
            
            %%%%  suppression  %%%%
            % viewer.delete();            
        end
    end    


end