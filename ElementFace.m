classdef ElementFace < VisibleElement
    %ELEMENTFACE Décrit les objets a afficher qui sont pleins
    
    properties (GetAccess = public, SetAccess = protected)
        texture
        epaisseurArretes = 1                % float
        epaisseurPoints  = 2                % float
        couleur          = [1 0 0 1]        % 1x4
        couleurArretes   = [0 1 0 1]        % 1x4
        couleurPoints    = [0 0 1 1]        % 1x4
        
        quoiAfficher int8 = 1               % 001 : face, 010 : ligne, 100, points
                                            % toutes combinaisons acceptés
    end

    events
        evt_textureUpdate           % la texture doit être créé
    end
   
    methods
        function obj = ElementFace(gl, aGeom)
            %FACEELEMENT 
            obj@VisibleElement(gl, aGeom); % appel au constructeur parent
            obj.Type = 'Face';
            obj.typeRendu = 32 + 1; % shading sur + uniform
            obj.shader = ShaderProgram(gl, obj.GLGeom.nLayout, obj.Type, obj.typeRendu);
        end % fin constructeur ElementFace

        function Draw(obj, gl)
            %DRAW dessine cet objet
            if ~obj.isVisible()
                return
            end
            obj.GLGeom.Bind(gl);
            obj.shader.SetUniform1i(gl, 'uQuoiAfficher', obj.quoiAfficher);
            %On affiche les faces
            if bitand(obj.quoiAfficher, 1) > 0
                if bitand(obj.typeRendu, 4) == 4 && ~isempty(obj.texture)
                    obj.shader.SetUniform1i(gl, 'uTexture', obj.texture.slot);
                    gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
                elseif bitand(obj.typeRendu, 1) == 1
                    obj.shader.SetUniform4f(gl, 'uFaceColor', obj.couleur);
                end
            end
            % On affiche les lignes
            if bitand(obj.quoiAfficher, 2) > 0
                obj.shader.SetUniform4f(gl, 'uLineColor', obj.couleurArretes);
                obj.shader.SetUniform1f(gl, 'uLineSize', obj.epaisseurArretes);
            end
            % On affiche les points
            if bitand(obj.quoiAfficher, 4) > 0
                obj.shader.SetUniform4f(gl, 'uPointColor', obj.couleurPoints);
                obj.shader.SetUniform1f(gl, 'uPointSize', obj.epaisseurPoints);
            end
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

            %CheckError(gl, 'apres le dessin');
        end % fin de Draw

        function DrawId(obj, gl)
            % DRAWID dessine uniquement l'id dans le frameBuffer (pour la selection)
            obj.GLGeom.Bind(gl);
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
        end % fin de drawID

        function useTexture(obj, fileName)
            if obj.GLGeom.nLayout(3) == 0
                warning('l objet ne contient pas le mapping pour appliquer la texture. Annulation')
                return 
            end
            if bitand(obj.typeRendu, 4) == 0
                obj.setModeRendu("TEXTURE");
            end
            obj.texture = fileName;
            notify(obj, 'evt_textureUpdate');
        end % fin de useTexture

        function setEpaisseurArretes(obj, newEp)
            obj.epaisseurArretes = newEp;
            notify(obj,'evt_redraw');
        end

        function setEpaisseurPoints(obj, newEp)
            obj.epaisseurPoints = newEp;
            notify(obj,'evt_redraw');
        end

        function setCouleur(obj, newCol)
            obj.couleur = obj.testNewCol(newCol);
            obj.quoiAfficher = bitor(obj.quoiAfficher, 1);
            notify(obj,'evt_redraw');
        end

        function setCouleurArretes(obj, newCol)
            obj.couleurArretes = obj.testNewCol(newCol);
            obj.quoiAfficher = bitor(obj.quoiAfficher, 2);
            notify(obj,'evt_redraw');
        end

        function setCouleurPoints(obj, newCol)
            obj.couleurPoints = obj.testNewCol(newCol);
            obj.quoiAfficher = bitor(obj.quoiAfficher, 4);
            notify(obj,'evt_redraw');
        end

        function setQuoiAfficher(obj, newChoix)
            if newChoix == 0
                obj.visible = false;
                disp('rien a afficher, objet est rendu invisible');
            elseif newChoix < 0
                disp('valeur incorrect');
            else
                obj.quoiAfficher = newChoix;
                notify(obj,'evt_redraw');
            end
        end % fin de setQuoiAfficher

        function sNew = select(obj, s)
            sNew.id = obj.getId();
            sNew.couleur = obj.couleurArretes;
            sNew.epaisseur = obj.epaisseurArretes;
            if bitand(obj.quoiAfficher, 2) == 2
                sNew.arretesActives = true;
            else
                sNew.arretesActives = false;
            end
            obj.quoiAfficher = bitor(obj.quoiAfficher, 2);
            obj.couleurArretes = s.couleur;
            obj.epaisseurArretes = s.epaisseur;
        end % fin de select

        function sNew = deselect(obj, s)
            sNew.id = 0;
            sNew.couleur = obj.couleurArretes;
            sNew.epaisseur = obj.epaisseurArretes;
            obj.couleurArretes = s.couleur;
            obj.epaisseurArretes = s.epaisseur;
            if (s.arretesActives == false)
                obj.quoiAfficher = bitand(obj.quoiAfficher, 5);
            end
        end % fin de deselect

        function AddMapping(obj, matMapping)
            obj.GLGeom.addDataToBuffer(matMapping, 3);
            obj.typeRendu = bitand(obj.typeRendu, 0xF0) + 4;
            notify(obj, 'evt_updateRendu');
        end % fin de AddMapping

        function AddNormals(obj, matNormales)
            obj.GLGeom.addDataToBuffer(matNormales, 4);
            obj.typeRendu = bitand(obj.typeRendu, 0x0F) + 64;
            notify(obj, 'evt_updateRendu');
        end % fin de AddNormals

        function GenerateNormals(obj)
            normales = calculVertexNormals(obj.Geom.listePoints, obj.Geom.listeConnection);
            obj.GLGeom.addDataToBuffer(normales, 4);
            obj.typeRendu = bitand(obj.typeRendu, 0x0F) + 64;
            notify(obj, 'evt_updateRendu');
        end % fin de GenerateNormals

        function glUpdate(obj, gl, eventName)
            if eventName == "evt_textureUpdate"
                obj.texture = Texture(gl, obj.texture);
            else
                glUpdate@VisibleElement(obj, gl, eventName);
            end
        end % fin de glUpdate
    end % fin de methodes defauts

    methods (Access = private)
        function col = testNewCol(~, newCol)
            if (numel(newCol) == 3)
                newCol(4) = 1;
            end
            if numel(newCol) == 4
                col = newCol;
            else
                warning('mauvais format pour la nouvelle couleur, couleur mise a 0');
            end
        end % fin de testNewCol
    end % fin des methodes privees
end % fin classe ElementFace