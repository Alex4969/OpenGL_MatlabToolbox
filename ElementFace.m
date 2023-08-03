classdef ElementFace < VisibleElement
    %ELEMENTFACE Décrit les objets a afficher qui sont pleins
    
    properties %(GetAccess = public, SetAccess = protected)
        texture
        textureUpdate = false
        epaisseurArretes = 1                    % float
        epaisseurPoints  = 4                    % float
        couleurFaces     = [1 0 0 1]            % 1x4
        couleurArretes   = [0 1 0 1]            % 1x4
        couleurPoints    = [0 0 1 1]            % 1x4
    end

    properties (GetAccess = public, SetAccess = protected)
        quoiAfficher int32   % 1x3 logical, vrai s'il faut afficher Face, Arrete, Points
    end  
   
    
    methods
        function obj = ElementFace(gl, aGeom)
            %FACEELEMENT 
            obj@VisibleElement(gl, aGeom); % appel au constructeur parent
            obj.Type = 'Face';
            obj.typeLumiere = 'D';
            obj.quoiAfficher = 1;
        end

        function Draw(obj, gl, camAttrib)
            %DRAW dessine cet objet
            if obj.visible == 0
                return
            end

            obj.CommonDraw(gl, camAttrib);
            if obj.typeOrientation ~= 'R'
                obj.shader.SetUniform1i(gl, 'uQuoiAfficher', obj.quoiAfficher);
                if bitand(obj.quoiAfficher, 1) > 0
                    if obj.typeRendu == 'T' && ~isempty(obj.texture)
                        if obj.textureUpdate == true
                            obj.texture = Texture(gl, obj.texture);
                            obj.textureUpdate = false;
                        end
                        obj.shader.SetUniform1i(gl, 'uTexture', obj.texture.slot);
                        gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);
                    elseif obj.typeRendu == 'D' && bitand(obj.quoiAfficher, 1) > 0
                        obj.shader.SetUniform4f(gl, 'uFaceColor', obj.couleurFaces);
                    end
                end
                if bitand(obj.quoiAfficher, 2) > 0
                    obj.shader.SetUniform4f(gl, 'uLineColor', obj.couleurArretes);
                    obj.shader.SetUniform1f(gl, 'uLineSize', obj.epaisseurArretes);
                end
                if bitand(obj.quoiAfficher, 4) > 0
                    obj.shader.SetUniform4f(gl, 'uPointColor', obj.couleurPoints);
                end
            end
            gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
            gl.glDrawElements(gl.GL_TRIANGLES, numel(obj.Geom.listeConnection) , gl.GL_UNSIGNED_INT, 0);

            CheckError(gl, 'apres le dessin');
        end % fin de Draw

        function useTexture(obj, fileName)
            if obj.GLGeom.nLayout(3) == 0
                warning('l objet ne contient pas le mapping pour appliquer la texture. Annulation')
                return 
            end
            obj.setModeRendu('T');
            obj.textureUpdate = true;
            obj.texture = fileName;
        end

        function setEpaisseurArretes(obj, newEp)
            obj.epaisseurArretes = newEp;
        end

        function setEpaisseurPoints(obj, newEp)
            obj.epaisseurPoints = newEp;
        end

        function setCouleurFaces(obj, newCol)
            obj.couleurFaces = obj.testNewCol(newCol);
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
            elseif newChoix < 0
                disp('valeur incorrect');
            else
                obj.quoiAfficher = newChoix;
            end
        end % fin de setQuoiAfficher

        function sNew = reverseSelect(obj, s)
            sNew.id        = obj.getId();
            sNew.couleur   = obj.couleurArretes;
            sNew.epaisseur = obj.epaisseurArretes;
            obj.couleurArretes   = s.couleur;
            obj.epaisseurArretes = s.epaisseur;
        end % fin de reverseSelect
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

