classdef GLGeometry < handle
    %GLGEOMETRIE Definition de la geometrie selon OpenGL
    
    properties (GetAccess = public, SetAccess = private)
        VAOId       uint32      % Vertex Array Id
        VBOId       uint32      % Vertex Buffer ~ liste des sommets Id
        EBOId       uint32      % Element Buffer ~ liste connectivité Id

        %%% Definition des Vertex Attribute
        vertexData              % copie du VBO (=Geom.listePoints + couleurs et/ou mapping et/ou normales)
        indexData               % copie du EBO (=Geom.listeConnection)
        nLayout (1,4) double    % [nPos, nColor, NTextureMapping, nNormales] : compte le nombre de valeurs pour chaque attribut
    end
    properties (Access = private)
        VAOBuffer               % Vertex Array buffer (java.nio.IntBuffer)
        VBOBuffer               % Vertex Buffer buffer (java.nio.IntBuffer)
        EBOBuffer               % Element Buffer buffer (java.nio.IntBuffer)
    end

    events
        evt_updateLayout        % les données du vertex Buffer doivent être modifié
    end

    methods
        function obj = GLGeometry(gl, sommets, indices)
            obj.vertexData = sommets;
            obj.indexData = uint32(indices);
            obj.nLayout = [3, 0, 0, 0];

            obj.CreateGLObject(gl);
        end % fin du constructeur GLGeometry
    end
    
    methods (Hidden = true)
        function addDataToBuffer(obj, mat, pos)
            % ADDDATATOBUFFER : modifie vertexData pour qu'il continnent les informations ajouter dans l'ordre :
            % pos, couleur, mapping, normales. Si on ajoute une composant qui existe deja, elle est remplacé par la nouvelle
            if size(obj.vertexData, 1) ~= size(mat, 1) % verification compatibilité hauteur
                warning('dimension incompatible')
                return
            end
            nAvant = 0;
            for i=1:(pos-1)
                nAvant = nAvant + obj.nLayout(i);
            end
            if obj.nLayout(pos) ~= 0 % si cette composant existe deja on la supprime et on recole le tableau
                obj.vertexData = [obj.vertexData(:,1:nAvant) obj.vertexData(:,(nAvant+obj.nLayout(pos)+1):size(obj.vertexData, 2))];
            end
            obj.vertexData = [obj.vertexData(:,1:nAvant) mat obj.vertexData(:,(nAvant+1):size(obj.vertexData, 2))];
            obj.nLayout(pos) = size(mat, 2);
            notify(obj, 'evt_updateLayout');
        end % fin de addDataToBuffer

        function nouvelleGeom(obj, newVertexData, newIndices)
            obj.vertexData = newVertexData;
            obj.indexData = uint32(newIndices);
            nPos = size(newVertexData, 2);
            obj.nLayout = [nPos, 0, 0, 0];
            notify(obj, 'evt_updateLayout');
        end % fin de nouvelleGeom

        function Bind(obj, gl)
            gl.glBindVertexArray(obj.VAOId);
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER, obj.VBOId);
        end % fin de bind

        function Unbind(~, gl)
            %UNBIND retire les objets du contexte OpenGL
            gl.glBindBuffer(gl.GL_ARRAY_BUFFER, 0);
            gl.glBindVertexArray(0);
        end % fin de unbind

        function glUpdate(obj, gl, ~)
            obj.Bind(gl);
            obj.fillVBO(gl);
            obj.fillEBO(gl);
            obj.declareVertexAttrib(gl);
            %CheckError(gl, 'Erreur de la mise a jour');
            obj.Unbind(gl);
        end % fin de glUpdate

        function delete(obj, gl)
            %DELETE Supprime l'objet de la mémoire
            gl.glDeleteBuffers(1, obj.VAOBuffer);
            gl.glDeleteBuffers(1, obj.VBOBuffer);
            gl.glDeleteBuffers(1, obj.EBOBuffer);
        end % fin de delete
    end % fin des methodes defauts

    methods (Access = private)
        function CreateGLObject(obj, gl)
            %CREATEGLOBJECT
            obj.generateVAO(gl);
            obj.generateVBO(gl);
            obj.fillVBO(gl);
            obj.generateEBO(gl);
            fillEBO(obj, gl)
            obj.declareVertexAttrib(gl);

            CheckError(gl, 'OPENGL::Erreur lors de la creation de la GLGeometrie');

            obj.Unbind(gl);
        end % fin de createGLObject

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
            gl.glBufferData(gl.GL_ARRAY_BUFFER, numel(vertex) * 4, sommetsData, gl.GL_DYNAMIC_DRAW);
        end % fin de fillVBO

        function generateEBO(obj, gl)
            %GENERATEINDICIES : Creer le EBO et le rempli avec les indices
            obj.EBOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenBuffers(1, obj.EBOBuffer);
            obj.EBOId = typecast(obj.EBOBuffer.array(), 'uint32');
            gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, obj.EBOId);
        end % fin de generateIndices

        function fillEBO(obj, gl)
            gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, obj.EBOId);
            idxBuffer = java.nio.IntBuffer.allocate(numel(obj.indexData));
            idxBuffer.put(obj.indexData(:));
            idxBuffer.rewind();
            gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, numel(obj.indexData) * 4, idxBuffer, gl.GL_DYNAMIC_DRAW);
        end % fin de fillEBO

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

