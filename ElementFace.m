classdef ElementFace < VisibleElement
    %ELEMENTFACE Décrit les objets a afficher qui sont pleins
    
    properties %(GetAccess = public, SetAccess = protected)
        texture
        textureUpdate = false
        epaisseurArretes = 1                % float
        epaisseurPoints  = 2                % float
        couleur          = [1 0 0 1]        % 1x4
        couleurArretes   = [0 1 0 1]        % 1x4
        couleurPoints    = [0 0 1 1]        % 1x4
    end

    properties (GetAccess = public, SetAccess = protected)
        quoiAfficher int8 = 1               % 001 : face, 010 : ligne, 100, points
                                            % toutes combinaisons acceptés
    end  
   
    methods
        function obj = ElementFace(gl, aGeom)
            %FACEELEMENT 
            obj@VisibleElement(gl, aGeom); % appel au constructeur parent
            obj.Type = 'Face';
            obj.typeShading = 'D';
            obj.changerProg(gl);
        end % fin constructeur ElementFace

        function Draw(obj, gl, camAttrib)
            %DRAW dessine cet objet
            if ~obj.isVisible()
                return
            end
            obj.CommonDraw(gl, camAttrib);
            obj.shader.SetUniform1i(gl, 'uQuoiAfficher', obj.quoiAfficher);
            if bitand(obj.quoiAfficher, 1) > 0
                if obj.typeColoration == 'T' && ~isempty(obj.texture)
                    if obj.textureUpdate == true
                        obj.texture = Texture(gl, obj.texture);
                        obj.textureUpdate = false;
                    end
                    obj.shader.SetUniform1i(gl, 'uTexture', obj.texture.slot);
                    gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
                elseif obj.typeColoration == 'U' && bitand(obj.quoiAfficher, 1) > 0
                    obj.shader.SetUniform4f(gl, 'uFaceColor', obj.couleur);
                end
            end
            if bitand(obj.quoiAfficher, 2) > 0
                obj.shader.SetUniform4f(gl, 'uLineColor', obj.couleurArretes);
                obj.shader.SetUniform1f(gl, 'uLineSize', obj.epaisseurArretes);
            end
            if bitand(obj.quoiAfficher, 4) > 0
                obj.shader.SetUniform4f(gl, 'uPointColor', obj.couleurPoints);
                obj.shader.SetUniform1f(gl, 'uPointSize', obj.epaisseurPoints);
            end
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

            CheckError(gl, 'apres le dessin');
        end % fin de Draw

        function DrawId(obj, gl, camAttrib)
            % DRAWID dessine uniquement l'id dans le frameBuffer (pour la selection)
            obj.CommonDraw(gl, camAttrib);
            obj.shader.SetUniform1i(gl, 'id', obj.getId());
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
        end % fin de drawID

        function useTexture(obj, fileName)
            if obj.GLGeom.nLayout(3) == 0
                warning('l objet ne contient pas le mapping pour appliquer la texture. Annulation')
                return 
            end
            obj.setModeRendu('T');
            obj.textureUpdate = true;
            obj.texture = fileName;
        end % fin de useTexture

        function setEpaisseurArretes(obj, newEp)
            obj.epaisseurArretes = newEp;
        end

        function setEpaisseurPoints(obj, newEp)
            obj.epaisseurPoints = newEp;
        end

        function setCouleur(obj, newCol)
            obj.couleur = obj.testNewCol(newCol);
            obj.quoiAfficher = bitor(obj.quoiAfficher, 1);
            notify(obj,'evt_update');
        end

        function setCouleurArretes(obj, newCol)
            obj.couleurArretes = obj.testNewCol(newCol);
            obj.quoiAfficher = bitor(obj.quoiAfficher, 2);
        end

        function setCouleurPoints(obj, newCol)
            obj.couleurPoints = obj.testNewCol(newCol);
            obj.quoiAfficher = bitor(obj.quoiAfficher, 4);
        end

        function setQuoiAfficher(obj, newChoix)
            if newChoix == 0
                obj.visible = false;
                disp('rien a afficher, objet est rendu invisible');
            elseif newChoix < 0
                disp('valeur incorrect');
            else
                obj.quoiAfficher = newChoix;
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