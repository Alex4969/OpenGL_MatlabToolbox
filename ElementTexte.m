classdef ElementTexte < VisibleElement
    %TEXTE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = public, SetAccess = protected)
        color (1,4) double = [1 1 1 1]    % entre 0 et 1
        texture
    end

    events
        evt_textureUpdate       % la texture doit être généré
    end
    
    methods
        function obj = ElementTexte(gl, geomComp) % voir option pour ancre ligne 100
            %ELEMENTTEXTE
            obj@VisibleElement(gl, geomComp);
            obj.Type = 'Texte';
            obj.AddMapping(obj.geom.mapping);
            obj.GLGeom.glUpdate(gl)
            obj.typeOrientation = 2; % normal a l'ecran
            obj.typeRendu = 16 + 4; % sans shading + texture
            obj.texture = Texture(gl, obj.geom.police.name + ".png");
            obj.shader = ShaderProgram(gl, obj.GLGeom.nLayout, obj.Type, obj.typeRendu);
        end % fin du constructeur Texte

        function setColor(obj, newColor)
            %SETCOULEURFOND change la couleur du texte
            %Peut prendre en entrée une matrice 1x3 (rgb) ou 1x4 (rgba)
            if (numel(newColor) == 3)
                newColor(4) = 1;
            end
            if numel(newColor) == 4
                obj.color = newColor;
                notify(obj,'evt_redraw');
            else
                warning('Le format de la nouvelle couleur n est pas bon, annulation');
            end
        end % fin setCouleurFond

        function setPolice(obj, newPolice)
            obj.geom.setPolice(newPolice)
        end % fin de setPolice
    
        function setText(obj, newPolice)
            obj.geom.setText(newPolice)
        end  

        function setAnchor(obj, newAnchor)
            obj.geom.setAnchor(newAnchor)
        end
    
        function setSize(obj,value) % value is relative
            M=obj.getModelMatrix;
            if length(value)==1
                M([1 6])=[value value];
            elseif length(value)==2
                M([1 6])=[value(1) value(2)];
            else
                warning('wrong parameter')
                return;
            end
            obj.setModelMatrix(M);
        end

        function s=getSize(obj) % value is relative
            M=obj.getModelMatrix;
            s=M([1 6]);
        end        

        function setPosition(obj,pos) % value is relative
            % a modifier pour tenir compte de l'orientation
            M=obj.getModelMatrix;
            M(13:15)=pos;
            obj.setModelMatrix(M);
        end        

        function pos=getPosition(obj)
            M=obj.getModelMatrix;
            pos=M(13:15);
        end

    end % fin des methodes defauts

    methods (Hidden = true)
        function Draw(obj, gl)
            %DRAW dessine cet objet
            if obj.isVisible() == false
                return
            end
            obj.GLGeom.Bind(gl);
            obj.shader.SetUniform1i(gl, 'uTexture', obj.texture.slot);
            obj.shader.SetUniform4f(gl, 'uColor', obj.color);
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
            %CheckError(gl, 'apres le dessin d un texte');
        end % fin de Draw

        function DrawId(obj, gl)
            % DRAWID dessine uniquement l'id dans le frameBuffer (pour la selection)
            obj.GLGeom.Bind(gl);
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
        end % fin de drawID
        function AddMapping(obj, matMapping)
            obj.GLGeom.addDataToBuffer(matMapping, 3);
        end % fin de AddMapping

        function glUpdate(obj, gl, eventName)
            if eventName == "evt_textureUpdate"
                obj.texture = Texture(gl, obj.texture);
            else
                glUpdate@VisibleElement(obj, gl, eventName);
            end
        end % fin de glUpdate

        function changePolice(obj)
            obj.texture = obj.geom.police.name + ".png";
            notify(obj, 'evt_textureUpdate');
        end % fin de changerPolice

        function sNew = select(obj, s)
            sNew.id = obj.getId();
            sNew.couleur = obj.color;
            sNew.epaisseur = s.epaisseur;
            obj.color = s.couleur;
        end % fin de select

        function sNew = deselect(obj, s)
            sNew.id = 0;
            sNew.couleur = obj.color;
            sNew.epaisseur = s.epaisseur;
            obj.color = s.couleur;
        end % fin de deselect
    end % fin des methodes cachés
end % fin classe Texte