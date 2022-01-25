fid = fopen("Mew_lp_new.txt", 'r');
if fid == -1
  error('Cannot open file: %s', FileName);
end
data = textscan(fid,'%f %f %f %f %f %f %f %f %f',...
'Delimiter',' ');
% data = fread(fid, 5631*9,'float32');
fclose(fid);
% data = reshape(data, [5631, 9]);
model1 = [data{1}, data{2}, data{3}];
model2 = [data{4}, data{5}, data{6}];
model3 = [data{7}, data{8}, data{9}];

[numTri,col] = size(model1);
one = ones(numTri,1);
Worldmodel1 = [model1, one];
Worldmodel2 = [model2, one];
Worldmodel3 = [model3, one];
%%
%for scalingg matrixxx(tranllation)
sX = 2;
sY = 2;
sZ = 2;
% for positional matrix()
tX = 0;
tY = -15;
tZ = 0;
thetaX = 85;
thetaY = 75;
thetaZ = 0;
tranlation = [ 1 0 0 0; 0 1 0 0; 0 0 1 0; tX tY tZ 1];
scaling = [ sX 0 0 0; 0 sY 0 0; 0 0 sZ 0; 0 0 0 1];
rotateX = [1 0 0 0; 0 cosd(thetaX) sind(thetaX) 0; 0 -sind(thetaX) cosd(thetaX) 0; 0 0 0 1];
rotateY = [cosd(thetaY) 0 -sind(thetaY) 0; 0 1 0 0; sind(thetaY) 0 cosd(thetaY) 0; 0 0 0 1];
rotateZ = [cosd(thetaZ) sind(thetaZ) 0 0; -sind(thetaZ) cosd(thetaZ) 0 0; 0 0 1 0;0 0 0 1];

rotationMatrix = rotateX * rotateY * rotateZ; 
translationmatrix = scaling * tranlation; 
Worldmodel1 = Worldmodel1 * rotationMatrix * translationmatrix ;
Worldmodel2 = Worldmodel2 * rotationMatrix * translationmatrix ;
Worldmodel3 = Worldmodel3 * rotationMatrix * translationmatrix ;

%%
%liting calculation
light = [32 -25 25];
m_diff = 1;
lightColor = [0.1 0.6 1];
vector1= Worldmodel2(:, 1:3)-Worldmodel1(:, 1:3);
vector2= Worldmodel3(:, 1:3)-Worldmodel1(:, 1:3);
lightingNormals = cross(vector1, vector2, 2);

lightingNormals = normr(lightingNormals);
lightingNormals= -lightingNormals;
lightingAVG = (Worldmodel1 + Worldmodel2 + Worldmodel3)./3; 

liting = lightingAVG(:,1:3) - light;
liting = normr(liting);
lightingColor = dot(liting,lightingNormals,2);
% lightingColor = normr(lightingColor);
cdiff = lightColor .* (m_diff* max(0,lightingColor));


%%
%camera position view transformation
 point = [1 1 1];
cameraAt = [15 15 15];
cameraup = [0 1 0];

zaxis = point - cameraAt;
% zaxis = zaxis./vecnorm(zaxis);
zaxis = normr(zaxis);

xaxis =  cross(cameraup,zaxis);
% xaxis =  xaxis./vecnorm(xaxis);
xaxis = normr(xaxis);
yaxis = cross(zaxis, xaxis);

viewMatrix = [[xaxis(1); xaxis(2); xaxis(3); -dot(xaxis, cameraAt)] , [yaxis(1); yaxis(2); yaxis(3); -dot(yaxis, cameraAt)], [zaxis(1); zaxis(2); zaxis(3);-dot(zaxis, cameraAt)],[0;0;0;1]];


%% precepective projection
FOV = 70;
aspectRatio = 1;
far = 100;
near = 10;

prespetive = [(cotd(FOV/2)/aspectRatio) 0 0 0; 0 cotd(FOV/2) 0 0 ; 0 0 (far/(far-near)) 1; 0 0 ((-far*near)/(far - near)) 0];

%%
% finalmatrix calculation
filnalModel1 = Worldmodel1 * viewMatrix * prespetive;
filnalModel2 = Worldmodel2 * viewMatrix * prespetive;
filnalModel3 = Worldmodel3 * viewMatrix * prespetive;

filnalModel1 = filnalModel1./filnalModel1(:,4);
filnalModel2 = filnalModel2./filnalModel2(:,4);
filnalModel3 = filnalModel3./filnalModel3(:,4);
%%
%z-clipping
[Rows,Cols] = size(filnalModel1);
for i = 1:(Rows)
    if((filnalModel1(i,3)<0 || filnalModel1(i,3)>1)&&(filnalModel2(i,3)<0 || filnalModel2(i,3)>1) &&(filnalModel3(i,3)<0 || filnalModel3(i,3)>1))
        filnalModel1(i,:) = [0 0 0 0];
        filnalModel2(i,:) = [0 0 0 0];
        filnalModel3(i,:) = [0 0 0 0];      
    end
    [Rows,Cols] = size(filnalModel1);
end
%%
% z sorting
zAVG = filnalModel1(:,3)+filnalModel2(:,3)+filnalModel3(:,3);
zAVG = zAVG./3;
SortModel1 = [filnalModel1 zAVG];
SortModel2 = [filnalModel2 zAVG];
SortModel3 = [filnalModel3 zAVG];
sortCdiff = [cdiff zAVG];

SorteedModel1 = sortrows(SortModel1,5,'descend');
SorteedModel2 = sortrows(SortModel2,5,'descend');
SorteedModel3 = sortrows(SortModel3,5,'descend');
sortedCdiff = sortrows(sortCdiff,4,'descend');
set(0,'DefaultPatchEdgeColor','none');
for i = 1:Rows
    if(SorteedModel1(i,4)~=0)
        patch([SorteedModel1(i,1) SorteedModel2(i,1) SorteedModel3(i,1)],[SorteedModel1(i,2) SorteedModel2(i,2) SorteedModel3(i,2) ],[sortedCdiff(i,1) sortedCdiff(i,2) sortedCdiff(i,3)] );
    end
end
% patch(X, Y, Finalcolor);
axis([-1 1 -1 1]);




