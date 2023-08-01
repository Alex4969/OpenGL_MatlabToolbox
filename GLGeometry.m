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
        vertexData              % doit etre de la meme hauteur que Geom.listePoints
                                % contient les composantes de couleurs / mapping / normales
        nLayout                 % [nPos, nColor, NTextureMapping, nNormales] : compte le nombre de valeurs pour chaque attribut
        updateNeeded = false
    end
    
    methods
        function obj = GLGeometry(gl, sommets, indices)
            obj.vertexData = sommets;
            nPos = size(sommets, 2);
            obj.nLayout = [nPos, 0, 0, 0];

            obj.CreateGLObject(gl, indices);
        end % fin du constructeur GLGeometry

        function addDataToBuffer(obj, mat, pos)
            % ADDDATATOBUFFER : modifie vertexData pour qu'il continnent les informations ajouter dans l'ordre :
            % pos, couleur, mapping, normales. Si on ajoute une composant qui existe deja, elle est remplacé par la nouvelle
            if size(obj.vertexData, 1) ~= size(mat, 1)
                warning('dimension incompatible')
                return
            end
            nAvant = 0;
            for i=1:(pos-1)
                nAvant = nAvant + obj.nLayout(i);
            end
            if obj.nLayout(pos) ~= 0
                obj.vertexData = [obj.vertexData(:,1:nAvant) obj.vertexData(:,(nAvant+obj.nLayout(pos)+1):size(obj.vertexData, 2))];
            end
            obj.vertexData = [obj.vertexData(:,1:nAvant) mat obj.vertexData(:,(nAvant+1):size(obj.vertexData, 2))];
            obj.nLayout(pos) = size(mat, 2);
            if ~isempty(obj.VBOId) % les modifications seront visibles au prochain draw de scene3D
                obj.updateNeeded = true;
            end
        end % fin de addDataToBuffer
        
        function CreateGLObject(obj, gl, indices)
            %CREATEGLOBJECT
            obj.generateVAO(gl);
            CheckError(gl, 'Erreur pour la creation du vao');
            obj.generateVBO(gl);
            CheckError(gl, 'Erreur pour la creation du arrayBuffer');
            obj.fillVBO(gl);
            CheckError(gl, 'Erreur pour le remplissage du arrayBuffer');
            obj.generateEBO(gl, indices);
            CheckError(gl, 'Erreur pour la creation de l indexBuffer');
            obj.declareVertexAttrib(gl);
            CheckError(gl, 'Erreur pour la declaration des vertex attributes');

            obj.Unbind(gl);
        end % fin de createGLObject

        function Bind(obj, gl)
            %BIND Met en contexte le vertexBuffer. S'il a été modifié, applique la modification
            gl.glBindVertexArray(obj.VAOId);
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER, obj.VBOId);
            CheckError(gl, 'Erreur du Bind');
            if obj.updateNeeded
                obj.declareVertexAttrib(gl);
                obj.fillVBO(gl);
                obj.updateNeeded = false;
                CheckError(gl, 'Erreur de la mise a jour');
            end
        end % fin de bind

        function Unbind(~, gl)
            %UNBIND retire les objets du contexte OpenGL
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER, 0);
            gl.glBindVertexArray(0);
            gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, 0);
        end % fin de unbind

        function delete(obj, gl)
            %DELETE Supprime l'objet de la mémoire
            gl.glDeleteBuffers(1, obj.VAOBuffer);
            gl.glDeleteBuffers(1, obj.VBOBuffer);
            gl.glDeleteBuffers(1, obj.EBOBuffer);
        end % fin de delete
    end % fin des methodes defauts

    methods (Access = private)
        function generateVAO(obj, gl)
            %GENERATEVERTEXARRAY : Creer le VAO
            obj.VAOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenVertexArrays(1, obj.VAOBuffer);
            obj.VAOId = typecast(obj.VAOBuffer.array, 'uint32');
            gl.glBindVertexArray(obj.VAOId);
        end % fin de generateVertexArray

        function generateVBO(obj, gl)
            %GENERATESOMMETS : Creer le VBO
            obj.VBOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenBuffers(1, obj.VBOBuffer);
            obj.VBOId = typecast(obj.VBOBuffer.array(), 'uint32');
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER, obj.VBOId);
        end % fin de generateSommets

        function fillVBO(obj, gl)
            %FILLVBO rempli le VBO avec les données du vertexData
            vertex = obj.vertexData;
            sommetsData = java.nio.FloatBuffer.allocate(numel(vertex));
            vertex = vertex';
            sommetsData.put(vertex(:));
            sommetsData.rewind();
            gl.glBufferData(gl.GL_ARRAY_BUFFER, numel(vertex) * 4, sommetsData, gl.GL_STATIC_DRAW);
        end

        function generateEBO(obj, gl, indices)
            %GENERATEINDICIES : Creer le EBO et le rempli avec les indices
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
            %DECLAREVERTEXATTRIB : definit les vertex attribute pour OpenGL.
            nbOctet = sum(obj.nLayout) * 4;
            offset = 0;
            for i=1:4
                if (obj.nLayout(i) > 0)
                    gl.glVertexAttribPointer(i, obj.nLayout(i), gl.GL_FLOAT, gl.GL_FALSE, nbOctet, offset);
                    gl.glEnableVertexAttribArray(i);
                    offset = offset + obj.nLayout(i)*4;
                end
            end
        end % fin de declareVertexAttrib

    end % fin des methodes privées
end % fin de la classe GLGeometry

