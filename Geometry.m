classdef Geometry < handle
    %GEOMETRIE contient les propriété d'une géometrie
    %Cette classe ne permet que de faire des test et sera remplacer par la
    %vrai classe Geometrie en fin de projet
    
    properties
        enable logical      % affiche ou non l'objet
        listePoints         % matrice nx3 ou nx2 contenant les points dans l'espace
        listeConnection     % matrice ligne donne la connectivité en triangle des points de la liste de points
        modelMatrix         % transformation du modèle dans la scène 3D (translation, rotation, homothétie)
        composanteSupp      % matrice nxm contenant des indications supplémentaires sur les sommets (couleurs, normales...)
    end
    
    methods

        function obj = Geometry(points, index, supp)
            %GEOMETRIE sans argument, le modele est ensuite donné en stl
            %recupere la liste de pointe et sa connectivité
            if (nargin == 0)
                obj.enable = 0;
            else
                obj.enable = 1;
                obj.listePoints = points;
                obj.listeConnection = index;
                if nargin == 3
                    if size(points, 1) ~= size(supp, 1)
                        warning('le nombre de ligne de supp et points doit etre similaire !')
                    else
                        obj.composanteSupp = supp;
                    end
                end
            end
            obj.modelMatrix = eye(4);
        end % fin du constructeur
        
        function CreateFromFile(obj, fileName, optimized)
            %CREATEFROMFILE créé un objet 3D a partir d'un fichier stl
            if (nargin == 2)
                optimized = 1;
            end
            addpath('outils');
            stlObj = IO_CADfile.readSTL(fileName, optimized);
            obj.listePoints = stlObj.vertices;
            temp = stlObj.faces';
            temp = temp - 1;
            obj.listeConnection = temp(:);
            obj.enable = 1;
        end % fin de createFromFile

        function AddToModelMatrix(obj, model, after)
            %ADDTOMODELMATRIX multiplie la nouvelle matrice modele par
            %celle deja existante (avant ou apres selon after)
            if (nargin == 3 && after == 1)
                obj.modelMatrix = obj.modelMatrix * model;
            else
                obj.modelMatrix = model * obj.modelMatrix;
            end
        end % fin de addToModelMatrix

        function setModelMatrix(obj, model)
            obj.modelMatrix = model;
        end % fin de setModelMatrix

    end % fin des methodes defaut

end % fin de la classe geometrie