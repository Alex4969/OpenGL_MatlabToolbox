classdef IO_CADfile<handle
    %read and write different type of CAD files
    
    properties
        
    end
    
    %read ascii and binary STL file library
    methods (Static)        
        function r=isSTLfile(filename)
            b=IO_CADfile.isSTLbinary(filename);
            a=IO_CADfile.isSTLascii(filename);
%             if b
%                 disp('***** file is binary STL')
%             elseif a
%                 disp('***** file is ascii STL')
%             else
%                 disp('***** file is NOT an STL file')
%             end
            r=a || b;
        end
        
        function h=getSTLheader(filename)
            if ~exist(filename,'file')
                h=[];
                return;
%                 error(['File does not exist'], filename);
            end    
            
            [path,file,ext]=fileparts(filename);
            h.Filename=strcat(file, ext);
            h.Filepath=path;            
            if IO_CADfile.isSTLbinary(filename)
                %read file
                fid = fopen(filename,'r');    
                if ~isempty(ferror(fid))
                    h=[];
                    return;
%                     error(lasterror); %#ok
                end

                M = fread(fid,inf,'uint8=>uint8');
                fclose(fid); 
                % end read file 

                h.Filetype='binary';
                h.Comment = char(M(1:80))';
                h.NumFaces = typecast(M(81:84),'uint32'); 
                
            elseif IO_CADfile.isSTLascii(filename)
                %read file
                fid = fopen(filename,'r');    
                if ~isempty(ferror(fid))
                    h=[];
                    return;
%                     error(lasterror); %#ok
                end

                M = textscan(fid,'%s','delimiter','\n','MultipleDelimsAsOne',1);
                fclose(fid);   
                s=M{1}{1};% 1 ere ligne
                
                h.Filetype='ascii';
                h.Comment =s(7:end);
                h.NumFaces =(length(M{1})-2)/7;             
            end

        end
        
        function r=isSTLbinary(filename)
            % UINT8[80] – Header
            % UINT32 – Number of triangles
            if ~exist(filename,'file')
                r=[];
                return;
%                 error(['File does not exist'], filename);
            end 
            
            %read file
            fid = fopen(filename,'r');    
            if ~isempty(ferror(fid))
                r=[];
                return;
%                 error(lasterror); %#ok
            end

            M = fread(fid,inf,'uint8=>uint8');
            fclose(fid); 
            % end read file 

            if length(M) < 84
                r=false;
%                 warning('This is not a valid binary STL file.');
                return;
            end

            % Bytes 81-84 are an unsigned 32-bit integer specifying the number of faces
            % that follow.
            numFaces = typecast(M(81:84),'uint32');
            expectedSize=80+4+50*(numFaces);
            if numFaces == 0 || ~isnumeric(numFaces) || expectedSize~=length(M)
                r=false;
%                 warning('This is not a valid binary STL file.');
                return;
            end
            r=true;
        end   
        
        function r=isSTLascii(filename)
            %read file
            fid = fopen(filename,'r');    
            if ~isempty(ferror(fid))
                r=[];
                return;
%                 error(lasterror); %#ok
            end

            M = textscan(fid,'%s','delimiter','\n','MultipleDelimsAsOne',1);
            nb_ligne=(length(M{1})-2);
            fclose(fid); 
            % end read file 
            
            s=M{1}{1};% 1 ere ligne
            if strcmpi('solid',s(1:5)) && mod(nb_ligne,7)==0
                r = true; % ASCII
            else
                r=false;
%                 warning('This is not a valid ASCII STL file.');
            end
            
        end
        
        function varargout=readSTL(filename,simplify)
            % simplify : reduce points number, true or false
            % OUTPUT :
            %        1 argument  : structure contenant header + V, F, et N            
            %        2 arguments : header + structure contenant V, F, et N
            %        3 arguments : V, F, et N
            %        4 arguments : header + V, F, et N
      
            
            if nargin==1
                simplify=true;%default simplification is on
            end

            if ~exist(filename,'file')
%                 r=[];
                return;
%                 error(['File does not exist'], filename);
            end 
            
            %read file
            fid = fopen(filename,'r');    
            if ~isempty(ferror(fid))
%                 r=[];
                return;
%                 error(lasterror); %#ok
            end            
            
            if IO_CADfile.isSTLfile(filename)
                if( IO_CADfile.isSTLbinary(filename) ) % This may not be a reliable test
                    M = fread(fid,inf,'uint8=>uint8');
                    fclose(fid);                    
                   [v,f,n] = stlbinary(M);
                elseif IO_CADfile.isSTLascii(filename)
                    M = textscan(fid,'%s','delimiter','\n','MultipleDelimsAsOne',1);
%                     nb_ligne=(length(M{1})-2);
                    fclose(fid);                     
                   [v,f,n] = stlascii(M);
                end
            else %not an STL file
                v=[];
                f=[];
                n=[];
            end
            
            %simplification
            if simplify
                [v,~,ic]=unique(v,'row','stable');
                f=transpose(reshape(ic,[3 length(f)]));                
            end
            
            h=IO_CADfile.getSTLheader(filename);
            varargout = cell(1,nargout);
            switch nargout 
                case 2
                    varargout{1} = h;
                    varargout{2} = struct('vertices',v,'faces',f,'normal',n);
                case 3
                    varargout{1} = h;
                    varargout{2} = v;
                    varargout{3} = f;
                case 4
                    varargout{1} = h;
                    varargout{2} = v;
                    varargout{3} = f;
                    varargout{4} = n;
                otherwise
                    varargout{1} = struct('vertices',v,'faces',f,'normal',n,'header',h);
            end  
            
            function [V,F,N] = stlbinary(M)
            % foreach triangle
            % REAL32[3] – Normal vector
            % REAL32[3] – Vertex 1
            % REAL32[3] – Vertex 2
            % REAL32[3] – Vertex 3
            % UINT16 – Attribute byte count
                F = [];
                V = [];
                N = [];

                numFaces = typecast(M(81:84),'uint32');
                T = M(85:end);
                F = NaN(numFaces,3);
                V = NaN(3*numFaces,3);
                N = NaN(numFaces,3);

                numRead = 0;
                while numRead < numFaces
                    % Each facet is 50 bytes
                    %  - Three single precision values specifying the face normal vector
                    %  - Three single precision values specifying the first vertex (XYZ)
                    %  - Three single precision values specifying the second vertex (XYZ)
                    %  - Three single precision values specifying the third vertex (XYZ)
                    %  - Two unused bytes
                    i1    = 50 * numRead + 1;
                    i2    = i1 + 50 - 1;
                    facet = T(i1:i2)';

                    n  = typecast(facet(1:12),'single');
                    v1 = typecast(facet(13:24),'single');
                    v2 = typecast(facet(25:36),'single');
                    v3 = typecast(facet(37:48),'single');

                    n = double(n);
                    v = double([v1; v2; v3]);

                    % Figure out where to fit these new vertices, and the face, in the
                    % larger F and V collections.        
                    fInd  = numRead + 1;        
                    vInd1 = 3 * (fInd - 1) + 1;
                    vInd2 = vInd1 + 3 - 1;

                    V(vInd1:vInd2,:) = v;
                    F(fInd,:)        = vInd1:vInd2;
                    N(fInd,:)        = n;

                    numRead = numRead + 1;
                end

            end            
            
            function [V,F,N]=stlascii(M)

%                 k = cellfun(@length,M);
                M=M{1,1}(2:end-1,1);
                numFaces=length(M)/7;

                F = NaN(numFaces,3);
                V = NaN(3*numFaces,3);
                N = NaN(numFaces,3);                
                
                f = 1;
                 for f=1:numFaces
                     i=(f-1)*7+1;
                     j=3*(f-1)+1;
                     Fbloc=M(i:i+6,1);
                     r=textscan(Fbloc{1},'facet normal %f %f %f',1,'Delimiter',' ','MultipleDelimsAsOne',1);
                     N(f,:)=[r{1:3}];
                     r=textscan(Fbloc{3},'vertex %f %f %f',1,'Delimiter',' ','MultipleDelimsAsOne',1);
                     V(j,:)=[r{1:3}];
                     r=textscan(Fbloc{4},'vertex %f %f %f',1,'Delimiter',' ','MultipleDelimsAsOne',1);
                     V(j+1,:)=[r{1:3}];
                     r=textscan(Fbloc{5},'vertex %f %f %f',1,'Delimiter',' ','MultipleDelimsAsOne',1);
                     V(j+2,:)=[r{1:3}];
                     F(f,:)=[j j+1 j+2];
                 end                
            end
            
            function [V,F,N] = stlascii1(C)
%                 PREPARATION DES DONNEES (avant utilisation de cette fonction)
%                 E=textscan(fid, '%s %s \n');
%                 fmt = '%*s %*s %f32 %f32 %f32 \r\n %*s %*s \r\n %*s %f32 %f32 %f32 \r\n %*s %f32 %f32 %f32 \r\n %*s %f32 %f32 %f32 \r\n %*s \r\n %*s \r\n';
%                 C=textscan(fid, fmt);%, 'HeaderLines', 1);
%                 fclose(fid);
%                 data.h.comment=E{2}{1};
%                 [data.f,data.v,data.n] = stlascii(C);
                
                %extract normal vectors and vertices
                N = cell2mat(C(1:3));
                N = N(1:end-1,:); %strip off junk from last line
                N=double(N);
                
                v1 = cell2mat(C(4:6));
                v2 = cell2mat(C(7:9));
                v3 = cell2mat(C(10:12));
                
                if (isnan(C{4}(end)) ) % pas d'erreur
                    v1 = v1(1:end-1,:); %strip off junk from last line
                    v2 = v2(1:end-1,:); %strip off junk from last line
                    v3 = v3(1:end-1,:); %strip off junk from last line
                end
                
                v_temp = [v1 v2 v3]';
                V = zeros(3,numel(v_temp)/3);
                
                V(:) = v_temp(:);
                V = V';
                
                
                c=size(V,1);
                
                F=zeros(3,c/3);
                F(:)=[1:c];
                F=F';
                
                
            end
        end
        
        function writeSTL(filename,P,F,binary)
            % P : points list : Npx3
            % F : faces list : Nfx3
            % binary : output file type, true or false
            TR = triangulation(F,P);
            if binary
                stlwrite(TR,filename,'binary');
            else
                stlwrite(TR,filename,'text');
            end
        end
    end
    
    % Wavefront OBJ files    
    methods (Static) 
        function [data] = readOBJ(fname)
            %
            % obj = readObj(fname)
            %
            % This function parses wavefront object data
            % It reads the mesh vertices, texture coordinates, normal coordinates
            % and face definitions(grouped by number of vertices) in a .obj file
            %
            %
            % INPUT: fname - wavefront object file full path
            %
            % OUTPUT: obj.v - mesh vertices
            %       : obj.vt - texture coordinates
            %       : obj.vn - normal coordinates
            %       : obj.f - face definition assuming faces are made of of 3 vertices
            %
            % Bernard Abayowa, Tec^Edge
            % 11/8/07
            
            % set up field types
            v = []; vt = []; vn = []; f.v = []; f.vt = []; f.vn = [];
            
            fid = fopen(fname);
            
            % parse .obj file
            while 1
                tline = fgetl(fid);
                if ~ischar(tline),   break,   end  % exit at end of file
                ln = sscanf(tline,'%s',1); % line type
                %disp(ln)
                switch ln
                    case 'v'   % mesh vertexs
                        v = [v; sscanf(tline(2:end),'%f')'];
                    case 'vt'  % texture coordinate
                        vt = [vt; sscanf(tline(3:end),'%f')'];
                    case 'vn'  % normal coordinate
                        vn = [vn; sscanf(tline(3:end),'%f')'];
                    case 'f'   % face definition
                        fv = []; fvt = []; fvn = [];
                        str = textscan(tline(2:end),'%s'); str = str{1};
                        
                        nf = length(findstr(str{1},'/')); % number of fields with this face vertices
                        
                        
                        [tok str] = strtok(str,'//');     % vertex only
                        for k = 1:length(tok) fv = [fv str2num(tok{k})]; end
                        
                        if (nf > 0)
                            [tok str] = strtok(str,'//');   % add texture coordinates
                            for k = 1:length(tok) fvt = [fvt str2num(tok{k})]; end
                        end
                        if (nf > 1)
                            [tok str] = strtok(str,'//');   % add normal coordinates
                            for k = 1:length(tok) fvn = [fvn str2num(tok{k})]; end
                        end
                        f.v = [f.v; fv]; f.vt = [f.vt; fvt]; f.vn = [f.vn; fvn];
                end
            end
            fclose(fid);
            
            % set up matlab object
            data.v = v;
            %data.vt = vt;
            data.n = vn;
            data.f = f.v;
            data.vn=f.vn;
        end
    end
    
    %visualisation
    methods (Static)
        function h=plotVFN(V,F,N)
            % V : vertices
            % F : faces
            % N : normals (optionnal)
            if nargin==2
                N=[];
            end
            shade=true;
          
            h.Vertices = V;
            h.Faces = F;
            h.FaceNormals=N;

            h.FaceColor = [0.8 0.2 0.2];%'red';
            h.EdgeColor = [0.8 0.8 0.8];%'black';%'none'
            if ~shade
                h.FaceLighting='gouraud';
                h.LineWidth = 0.1;
                h.AmbientStrength=0.15;
                patch(h)
                material('dull');%shiny   metal
                camlight('headlight');    
            else
                h.FaceLighting='gouraud';
                h.LineWidth = 0.1;
                h.AmbientStrength=0.15;
                h.FaceAlpha=0.3;
                patch(h)
                material('dull');%shiny   metal
                camlight('headlight');
            end
        end        
    end

end

