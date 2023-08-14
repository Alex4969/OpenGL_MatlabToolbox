classdef UBO < handle
    %UBO place des données utilisés par les shaders dans le GPU
    
    properties
        UBOId uint32
        UBOBuffer
        taille uint16       % taille en octets des données contenues dans le buffer
        binding uint8       % n° du bind dans le shader
    end
    
    methods
        function obj = UBO(gl, binding, taille)
            obj.binding = binding;
            obj.taille = taille;
            obj.generateUbo(gl);
        end % fin du constructeur UBO

        function putVec3(obj, gl, vec, deb)
            % met un vecteur a 3 dimensions dans l'UBO a la position deb
            % dans les UBO les valeurs font 1, 2 ou 4 octets donc on occupe 16 bits pour un vec3
            obj.Bind(gl);
            vecUni = java.nio.FloatBuffer.allocate(4);
            vecUni.put(vec(:));
            vecUni.rewind();
            gl.glBufferSubData(gl.GL_UNIFORM_BUFFER, deb, 16, vecUni);
        end % fin de put vec3

        function Bind(obj, gl)
            gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, obj.UBOId);
        end % fin de bind

        function delete(obj, gl)
            gl.glDeleteBuffers(1, obj.UBOBuffer);
        end % fin de delete
    end

    methods (Access = private)
        function generateUbo(obj, gl)
            obj.UBOBuffer = java.nio.IntBuffer.allocate(1);
            gl.glGenBuffers(1, obj.UBOBuffer);
            obj.UBOId = typecast(obj.UBOBuffer.array(), 'uint32');
            gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, obj.UBOId);
            gl.glBufferData(gl.GL_UNIFORM_BUFFER, obj.taille, [], gl.GL_DYNAMIC_DRAW);
            gl.glBindBufferRange(gl.GL_UNIFORM_BUFFER, 0, obj.UBOId, 0, obj.taille);
            gl.glBindBuffer(gl.GL_UNIFORM_BUFFER, obj.binding);
        end % fin de generateUbo
    end % fin des methodes privées
end % fin classe UBO

