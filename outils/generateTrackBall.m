function [sommetsValeurs, indices, sommetsCouleur] = generateTrackBall(R)

indices=[];
XY=[];
k=0;
pas=10;
for i=0:pas:360
    XY=[XY;R*cosd(i) R*sind(i) 0];
    indices=[indices k k+1];
    k=k+1;
end
N=size(XY,1);
nb_cercle=3;
sommetsValeurs=zeros(nb_cercle*N,3);
sommetsValeurs(1:N,1)=XY(:,1);sommetsValeurs(1:N,2)=XY(:,2);
sommetsValeurs(N+1:2*N,1)=XY(:,1);sommetsValeurs(N+1:2*N,3)=XY(:,2);
sommetsValeurs(2*N+1:3*N,2)=XY(:,1);sommetsValeurs(2*N+1:3*N,3)=XY(:,2);

    % sommetsValeurs = [  fin   0.0   0.0 ;   % 0
    %                     fin-L   L/2   0.0 ;   % 0
    %                     fin-L   -L/2   0.0 ;   % 0
    %                     0.0   fin   0.0 ;   % 1 
    %                     L/2   fin-L   0.0 ;   % 1
    %                     -L/2   fin-L   0.0 ;   % 1
    %                     0.0   0.0   fin ;   % 2
    %                     0.0   -L/2   fin-L; % 2
    %                     0.0   +L/2   fin-L];  % 2
    Red = repmat([1.0 0.0 0.0] ,N,1);
    Green = repmat([0.0 1.0 0.0] ,N,1);
    Blue = repmat([0.0 0.0 1.0] ,N,1);
    sommetsCouleur=[Blue;Green;Red];
% sommetsCouleur=[Red;Green];
    % indices = [0 1 0 2 3 4 3 5 6 7 6 8];
    indices=[indices(1:end-2) indices(1:end-2)+N indices(1:end-2)+2*N];
end %fin de generateAxes