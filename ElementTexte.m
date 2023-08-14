classdef ElementTexte < VisibleElement
    %TEXTE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = protected)
        couleur = [1 1 1 1]    % 1x4 double entre 0 et 1
        texture
    end

    events
        evt_textureUpdate
    end
    
    methods
        function obj = ElementTexte(gl, geomComp) % voir option pour ancre ligne 100
            %ELEMENTTEXTE
            obj@VisibleElement(gl, geomComp);
            obj.Type = 'Texte';
            obj.AddMapping(obj.Geom.mapping);
            obj.GLGeom.glUpdate(gl)
            obj.typeOrientation = 2; % normal a l'ecran
            obj.typeColoration = 'T';
            obj.texture = Texture(gl, obj.Geom.police.name + ".png");
            obj.shader = ShaderProgram(gl, obj.GLGeom.nLayout, obj.Type, obj.typeColoration, obj.typeShading);
        end % fin du constructeur Texte

        function Draw(obj, gl)
            %DRAW dessine cet objet
            if obj.isVisible() == false
                return
            end
            obj.GLGeom.Bind(gl);
            obj.shader.SetUniform1i(gl, 'uTexture', obj.texture.slot);
            obj.shader.SetUniform4f(gl, 'uColor', obj.couleur);
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            CheckError(gl, 'apres le dessin d un texte');
        end % fin de Draw

        function DrawId(obj, gl)
            % DRAWID dessine uniquement l'id dans le frameBuffer (pour la selection)
            obj.GLGeom.Bind(gl);
            obj.shader.SetUniform1i(gl, 'id', obj.getId());
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
        end % fin de drawID

        function setCouleur(obj, newColor)
            %SETCOULEURFOND change la couleur du texte
            %Peut prendre en entrée une matrice 1x3 (rgb) ou 1x4 (rgba)
            if (numel(newColor) == 3)
                newColor(4) = 1;
            end
            if numel(newColor) == 4
                obj.couleur = newColor;
                notify(obj,'evt_update');
            else
                warning('Le format de la nouvelle couleur n est pas bon, annulation');
            end
        end % fin setCouleurFond

        function glUpdate(obj, gl, eventName)
            if eventName == "evt_textureUpdate"
                obj.texture = Texture(gl, obj.texture);
            else
                glUpdate@VisibleElement(obj, gl, eventName);
            end
        end % fin de glUpdate

        function changePolice(obj)
            obj.texture = obj.Geom.police.name + ".png";
            notify(obj, 'evt_textureUpdate');
        end

        function AddMapping(obj, matMapping)
            obj.GLGeom.addDataToBuffer(matMapping, 3);
            obj.typeColoration = 'T';
            notify(obj, 'evt_newRendu');
        end % fin de AddMapping

        function sNew = select(obj, s)
            sNew.id = obj.getId();
            sNew.couleur = obj.couleur;
            sNew.epaisseur = s.epaisseur;
            obj.couleur = s.couleur;
        end % fin de select

        function sNew = deselect(obj, s)
            sNew.id = 0;
            sNew.couleur = obj.couleur;
            sNew.epaisseur = s.epaisseur;
            obj.couleur = s.couleur;
        end % fin de deselect
    end % fin des methodes defauts
end % fin classe Texte