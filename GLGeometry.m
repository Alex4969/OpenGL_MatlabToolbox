classdef GLGeometry < handle
    %GLGEOMETRIE Definition de la geometrie selon OpenGL
    
    properties
        VAOId                   % Vertex Array Id (uint32)
        VAOBuffer               % Vertex Array buffer (java.nio.IntBuffer)
        VBOId                   % Vertex Buffer ~ liste des sommets Id (uint32)
        VBOBuffer               % Vertex Buffer buffer (java.nio.IntBuffer)
        EBOId                   % Element Buffer ~ liste connectivité Id (uint32)
        EBOBuffer               % Element Buffer buffer (java.nio.IntBuffer)

        %%% Definition des Vertex Attribute
        %%% Contient le nombre de valeurs pour cet attribut ou 0 si il n'y est pas
        nPos                    % nombre de valeur utile pour définir la position (généralement 2 ou 3, défaut 3)
        nColor                  % nombre de valeur utile pour définir la couleur (généralement 3 ou 4, défaut 0)
        nTextureMapping         % nombre de valeur utile pour définir le mapping (généralement 2, défaut 0)
        nNormals                % nombre de valeur utile pour définir les normales (généralement 3, défaut 0)
        newLayout logical       % vrai s'il faut changer le layout OpenGL. le changement se fait dans le bind si besoin.
                                % definir un nouveau layout pour OpenGL necessite un contexte
    end
    
    methods

        function obj = GLGeometry(gl, sommets, indices)
            %GLGEOMETRIE

            obj.SetVertexAttribSize(3, 0, 0, 0); %taille des vertex attribute par defaut
            obj.newLayout = true;

            obj.generateVertexArray(gl);
            CheckError(gl, 'Erreur pour la creation du vao');
            obj.generateSommets(gl, sommets);
            CheckError(gl, 'Erreur pour la creation du arrayBuffer');
            obj.generateIndices(gl, indices);
            CheckError(gl, 'Erreur pour la creation de l indexBuffer');
            obj.declareVertexAttrib(gl);
            CheckError(gl, 'Erreur pour la declaration des vertex attributes');

            obj.Unbind(gl);
        end % fin du constructeur de GLgeometry

        function SetVertexAttribSize(obj, nPos, nColor, nTextureMapping, nNormals)
            if nargin < 2, nPos = 3; end
            if nargin < 3, nColor = 0; end
            if nargin < 4, nTextureMapping = 0; end
            if nargin < 5, nNormals = 0; end
            obj.nPos = nPos;
            obj.nColor = nColor;
            obj.nTextureMapping = nTextureMapping;
            obj.nNormals = nNormals;
            obj.newLayout = true;
        end % fin de setAttribSize

        function Bind(obj, gl)
            gl.glBindVertexArray(obj.VAOId);
            CheckError(gl, '1');
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER, obj.VBOId);
            CheckError(gl, '2');
            if (obj.newLayout == true)
                obj.declareVertexAttrib(gl);
            end
            CheckError(gl, '3');
            %gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, 0);
        end % fin de bing

        function Unbind(~, gl)
            %UNBIND retire les objets du contexte OpenGL
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER, 0);
            gl.glBindVertexArray(0);
            gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, 0);
        end % fin de unbind

        function Delete(obj, gl)
            %DELETE Supprime l'objet de la mémoire
            gl.glDeleteBuffers(1, obj.VAOBuffer);
            gl.glDeleteBuffers(1, obj.VBOBuffer);
            gl.glDeleteBuffers(1, obj.EBOBuffer);
        end % fin de Delete

    end % fin des methodes defauts

    methods (Access = private)
        
        function generateVertexArray(obj, gl)
            %GENERATEVERTEXARRAY : Creer le VAO
            obj.VAOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenVertexArrays(1, obj.VAOBuffer);
            obj.VAOId = typecast(obj.VAOBuffer.array, 'uint32');
            gl.glBindVertexArray(obj.VAOId);
        end % fin de generateVertexArray

        function generateSommets(obj, gl, sommets)
            %GENERATESOMMETS : Creer le VBO a partir de la liste de sommets de la géometrie
            sommetsData = java.nio.FloatBuffer.allocate(numel(sommets));
            sommets = sommets';
            sommetsData.put(sommets(:));
            sommetsData.rewind();
            obj.VBOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenBuffers(1, obj.VBOBuffer);
            obj.VBOId = typecast(obj.VBOBuffer.array(), 'uint32');
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER, obj.VBOId);
            gl.glBufferData(gl.GL_ARRAY_BUFFER, numel(sommets) * 4, sommetsData, gl.GL_STATIC_DRAW);
        end % fin de generateSommets

        function generateIndices(obj, gl, indices)
            %GENERATEINDICIES : Creer le EBO a partir de la liste de connectivité de la géometrie
            indices = uint32(indices);
            indexData = java.nio.IntBuffer.allocate(numel(indices));
            indexData.put(indices(:));
            indexData.rewind();
            obj.EBOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenBuffers(1, obj.EBOBuffer);
            obj.EBOId = typecast(obj.EBOBuffer.array(), 'uint32');
            gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, obj.EBOId);
            gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, numel(indices) * 4, indexData, gl.GL_STATIC_DRAW);
        end % fin de generateIndices

        function declareVertexAttrib(obj, gl)
            %DECLAREVERTEXATTRIB : definit les vertex attribute pour OpenGL. Fait plusieurs appel a setVertexAttrib
            taille = obj.nPos + obj.nColor + obj.nTextureMapping + obj.nNormals;
            taille = taille * 4;
            index = 0;
            offset = 0;
            [index, offset] = obj.setVertexAttrib(gl, obj.nPos, index, offset, taille);
            [index, offset] = obj.setVertexAttrib(gl, obj.nColor, index, offset, taille);
            [index, offset] = obj.setVertexAttrib(gl, obj.nTextureMapping, index, offset, taille);
            [~, ~] = obj.setVertexAttrib(gl, obj.nNormals, index, offset, taille);
            obj.newLayout = false;
        end % fin de declareVertexAttrib

        function [index, offset] = setVertexAttrib(~, gl, nAttrib, index, offset, taille)
            %SETVERTEXATTRIB : définit 1 vertex attribute pour OpenGL
            if (nAttrib ~= 0)
                gl.glVertexAttribPointer(index, nAttrib, gl.GL_FLOAT, gl.GL_FALSE, taille, offset);
                gl.glEnableVertexAttribArray(index);
                index = index + 1;
                offset = offset + 4 * nAttrib;
            end
        end % fin de setVertexAttrib
    
    end % fin des methodes privées

end % fin de la classe GLGeometry

