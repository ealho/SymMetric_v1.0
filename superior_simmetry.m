
%Author:Eduardo Alho
%Date:21/4/2017
%This function analyses head simmetry from superior view photographs
%N is the number of images to be compared


function superior_simmetry(N)

for i=1:N
%loads image
nf = uigetfile('*.jpg','Choose an image.');
Af = imread(nf);
%manual skull segmentation
figure(1)
imshow(Af)
set(1,'Name','Perform cranial segmentation','Numbertitle','off');
Bw=roipoly(Af);

%Define midline points
set(1,'Name','Define 2 midline points','Numbertitle','off');
h1=impoint;
wait(h1);
pos1 = h1.getPosition();
h2=impoint;
wait(h2);
pos2=h2.getPosition();
close
%finds image center
sizeBw=size(Bw);
mat=sizeBw./2;
centerpixel=fliplr(mat);

%Calculates centroid coordinates of the segmentation

stats1 = regionprops(Bw,'Centroid');
centroids = cat(1, stats1.Centroid);

%Bring segmentation to the center of the image
C=centerpixel-centroids;
New = imtranslate(Bw,[C(:,1) C(:,2)]);

%Calculations with centered image

stats = regionprops('table',New,'Centroid',...
    'MajorAxisLength','MinorAxisLength','Orientation','Eccentricity')
centroids2 = cat(1, stats.Centroid);



%Calculates extreme pixels from Major and Minor Lengths
BoundaryPixel1=stats.Centroid+[-stats.MajorAxisLength/2,0];
BoundaryPixel2=stats.Centroid+[stats.MajorAxisLength/2,0];
BoundaryPixel3=stats.Centroid+[0,-stats.MinorAxisLength/2];
BoundaryPixel4=stats.Centroid+[0,stats.MinorAxisLength/2];

% Finds skull ouside countour
[B,L] = bwboundaries(New,'noholes');
imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
boundary = B{1};
plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
z=zeros(size(New));
z=im2bw(z);
close

%Shows extreme pixels, centroid, and skull boundary
figure1=figure;
imshow(z)
hold on
plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
plot(centroids2(:,1),centroids2(:,2), 'b*');
plot(BoundaryPixel1(:,1),BoundaryPixel1(:,2), 'b*');
plot(BoundaryPixel2(:,1),BoundaryPixel2(:,2), 'b*');
plot(BoundaryPixel3(:,1),BoundaryPixel3(:,2), 'b*');
plot(BoundaryPixel4(:,1),BoundaryPixel4(:,2), 'b*');

%calculates Cephalic index based on major and minor head axis
RealCephalicIndex=[stats.MinorAxisLength]/[stats.MajorAxisLength]*100
RCI(i,:)=[RealCephalicIndex];
%xlswrite('RCI.xls',RCI);  %Adicionei essas duas linhas ainda nao sei se funcionam
fileID = fopen('cepahlic_index.txt','w');
fprintf(fileID,'%6s %12s\n');
fprintf(fileID,'%6.2f %12.8f\n',RCI);
fclose(fileID);

%calculates midline and tranverse axis
hold on
Mid= imline(gca,[pos2(1) pos1(1)],[pos2(2),pos1(2)]);
Midline=createMask(Mid);
PointsAP=[pos1(1) pos1(2);pos2(1) pos2(2)];
AP_distance=pdist(PointsAP);
px=(pos1(1)+pos2(1))/2;
py=(pos1(2)+pos2(2))/2;
Center=[px,py];
hold on
plot(Center(1),Center(2),'b*')

%Calculates clock
clocklenght=[(sizeBw(1)/2)-1];
%clocklenght=[stats.MajorAxisLength]/2+0.005*[stats.MajorAxisLength];
ClockOutPixel=stats.Centroid+[-clocklenght,0];
imshow(z)
hold on
plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
plot(ClockOutPixel(:,1),ClockOutPixel(:,2), 'b*');
hold off
imshow(z)
hold on
clock=imline(gca,[ClockOutPixel(:,1),centroids2(:,1)],[ClockOutPixel(:,2),centroids2(:,2)]);
clockmask=createMask(clock);
imshow(clockmask)
plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
close

%Rotates clock

%calculates euclidean distance between center and intersection of the
%curves
a=centroids2(1);
b=centroids2(2);
r=clocklenght;

%Calculates distances from Left Hemisphere and eliminates zero
%values (for angles between 181 and 359)
for angle=181:359
    
    th = angle*pi/180;
    x=a+r*cos(th);
    y=b+r*sin(th);
    Pnew=[x y];
    x1=boundary(:,2);
    y1=boundary(:,1);
    x2=linspace(a,Pnew(1),r);
    x2=x2.';
    y2=linspace(b,Pnew(2),r);
    y2=y2.';
    [X,Y]=curveintersect(x1,y1,x2,y2);
    Matrix=[a b;X Y];
    LeftHemisphere(angle,:) = pdist(Matrix);
    LH=LeftHemisphere(LeftHemisphere~=0);
end

%Calculates distances from center to Right Hemisphere, eliminates zero
%values (for angles between 179 and 1)and inverts matrix to compare with
%left hemisphere
for angle=179:-1:1
      
    th = angle*pi/180;
    x=a+r*cos(th);
    y=b+r*sin(th);
    Pnew=[x y];
    x1=boundary(:,2);
    y1=boundary(:,1);
    x2=linspace(a,Pnew(1),r);
    x2=x2.';
    y2=linspace(b,Pnew(2),r);
    y2=y2.';
    [X,Y]=curveintersect(x1,y1,x2,y2);
    Matrix=[a b;X Y];
    RightHemisphere(angle,:) = pdist(Matrix);
    RH=RightHemisphere(RightHemisphere~=0);
    RH=flipud(RH);
end


LHmean=mean(LH);
LHsd=std(LH);
RHmean=mean(RH);
RHsd=std(RH);

Simmetry_index{i}=LH./RH;

end
%Calculates Cranial Vault Asymetry Index (Loveday 2001)


DiagA=LH(30,1)+ RH(150,1);
DiagB=RH(30,1)+LH(150,1);
CVAI=[DiagA]-[DiagB]/[DiagA]*100;
CVAI=abs(CVAI);
CranialVault(i,:)=[CVAI];


fileID = fopen('cvai.txt','w');
fprintf(fileID,'%6s %12s\n');
fprintf(fileID,'%6.2f %12.8f\n',CranialVault);
fclose(fileID);


%Asymetry Severity Index (ASI): Calculates percentage of asymetric skull,
%0-5% no asymetry, 6-25% mild 25-50% moderate and >50% severe


Count=[sum(Simmetry_index{1,i}>1.035)]+[sum(Simmetry_index{1,i}<0.965)];
Absolute_count(i,:)=[Count]; %Absolute number of lines that are considered asymetric (more than 3.5% of difference of left and right hemisphere)
ASI(i,:)=[Count/1.8]; %this is the percentage of degrees of the head that are considered asymetric


fileID = fopen('Absolute_count.txt','w');
fprintf(fileID,'%6s %12s\n');
fprintf(fileID,'%6.2f %12.8f\n',Absolute_count);
fclose(fileID);

fileID = fopen('ASI.txt','w');
fprintf(fileID,'%6s %12s\n');
fprintf(fileID,'%6.2f %12.8f\n',ASI);
fclose(fileID);

for i=1:N
figure(6)
hold on
plot([i],[ASI(i,1)],'*','DisplayName','ASI');
hold on
plot([0 10],[5 5],'g');
plot([0 10],[25 25],'y');
plot([0 10],[50 50],'r');
xlim([0 10])
ylim([0 100])
title('Asymetry Severity Index')
xlabel({'Evolution in time','(number of pictures)'})
ylabel('ASI')
%legend('before','after')%precisa ver se funciona isso
saveas(figure(6),'ASI.tif')
end

for i=1:N
figure(5)
hold on
plot([i],[CranialVault(i,1)],'*','DisplayName','CVAI');
hold on
plot([0 10],[3.5 3.5],'b','DisplayName','significantly asymetrical');
xlim([0 10])
%ylim([0 2000])
title('Cranial Vault Asymetry Index')
xlabel({'Evolution in time','(number of pictures)'})
ylabel('CVAI')
%legend('before','after')%precisa ver se funciona isso
saveas(figure(5),'Cranial_vault_index.tif')
end

for i=1:N
figure(4)
hold on
plot([i],[RCI(i,1)],'*','DisplayName','CI');
hold on
plot([0 10],[75 75],'b','DisplayName','lower limit');
plot([0 10],[85 85],'b','DisplayName','upper limit');
xlim([0 10])
ylim([30 100])
title('Cephalic index')
xlabel({'Evolution in time','(number of pictures)'})
ylabel('Cephalic index')
%legend('before','after')%precisa ver se funciona isso
saveas(figure(4),'Cephalic_index.tif')
end


for i=1:N
figure(3)
hold on
plot(Simmetry_index{1,i},'marker','*');
hold on
plot([0 180],[0.965 0.965],'b','DisplayName','lower limit');
plot([0 180],[1.035 1.035],'b','DisplayName','upper limit');
title('Superior simmetry index')
xlabel('Angles in degrees')
ylabel('Simmetry index')
saveas(figure(3),'Superior_simmetry_index.tif')
end
end














