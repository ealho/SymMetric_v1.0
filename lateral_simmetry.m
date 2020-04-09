%Author:Eduardo Alho
%Date:24/09/2018
%This function analyses cranial simmetry from lateral view photographs
%N is the number of images to be compared


function lateral_simmetry(N)

for i=1:N
%loads image
nf = uigetfile('*.jpg','Choose an image.');
Af = imread(nf);

figure(1)
set(1,'Name','Define rotation in prompt','Numbertitle','off');
imshow(Af)
prompt = 'To rotate image clockwise press -90, counter clockwise 90 or 0 to continue: ' ;
x = input(prompt);
Af=imrotate(Af,x);
imshow(Af)

figure(1)
set(1,'Name','Define forehead','Numbertitle','off');
%imshow(Af)
%Defines forehead (F)
h1=impoint;
wait(h1);
pos1 = h1.getPosition();


%Defines inion (I)
set(1,'Name','Define Inion','Numbertitle','off');
h2=impoint;
wait(h2);
pos2=h2.getPosition();


%Defines acustic meatus (M)
set(1,'Name','Define acustic meatus','Numbertitle','off');
h3=impoint;
wait(h3);
pos3=h3.getPosition();

%Defines nasion (N)
set(1,'Name','Define nasion','Numbertitle','off');
h4=impoint;
wait(h4);
pos4=h4.getPosition();

%Defines bregma (B)
set(1,'Name','Define bregma','Numbertitle','off');
h5=impoint;
wait(h5);
pos5=h5.getPosition();


%Distances

%Defines and calculates AP distance (AP)
AP= imline(gca,[pos2(1) pos1(1)],[pos2(2),pos1(2)]);
APline=createMask(AP);
PointsAPline=[pos1(1) pos1(2);pos2(1) pos2(2)];
AP_distance=pdist(PointsAPline);

%Defines and calculates Nasium-acustic meatus distance (NM)
NM= imline(gca,[pos3(1) pos4(1)],[pos3(2),pos4(2)]);
NMline=createMask(NM);
PointsNMline=[pos3(1) pos3(2);pos4(1) pos4(2)];
NM_distance=pdist(PointsNMline);

%Defines and calculates acustic meatus-inion distance (MI)
MI= imline(gca,[pos3(1) pos2(1)],[pos3(2),pos2(2)]);
MIline=createMask(MI);
PointsMIline=[pos3(1) pos3(2);pos2(1) pos2(2)];
MI_distance=pdist(PointsMIline);

%Defines and calculates acustic meatus-forehead distance (MF)
MF= imline(gca,[pos3(1) pos1(1)],[pos3(2),pos1(2)]);
MFline=createMask(MF);
PointsMFline=[pos3(1) pos3(2);pos1(1) pos1(2)];
MF_distance=pdist(PointsMFline);

%Defines and calculates acustic meatus-bregma distance (MB)
MB= imline(gca,[pos3(1) pos5(1)],[pos3(2),pos5(2)]);
MBline=createMask(MB);
PointsMBline=[pos3(1) pos3(2);pos5(1) pos5(2)];
MB_distance=pdist(PointsMBline);

%Defines and calculates nasium-inium distance (NI)
NI= imline(gca,[pos4(1) pos2(1)],[pos4(2),pos2(2)]);
NIline=createMask(NI);
PointsNIline=[pos4(1) pos4(2);pos2(1) pos2(2)];
NI_distance=pdist(PointsNIline);

%Defines and calculates nasium-bregma distance (NB)
NB= imline(gca,[pos4(1) pos5(1)],[pos4(2),pos5(2)]);
NBline=createMask(NB);
PointsNBline=[pos4(1) pos4(2);pos5(1) pos5(2)];
NB_distance=pdist(PointsNBline);

%Proportions

GHG=[AP_distance]+[NM_distance]+[MI_distance]+[MF_distance]+[MB_distance]+[NI_distance];%represents global head growth adding all distances

AP_prop=[AP_distance]/[GHG]*100; %AP proportion 
NM_prop=[NM_distance]/[GHG]*100; %NM proportion 
MI_prop=[MI_distance]/[GHG]*100; %MI proportion 
MF_prop=[MF_distance]/[GHG]*100; %MF proportion 
MB_prop=[MB_distance]/[GHG]*100; %MB proportion 
NI_prop=[NI_distance]/[GHG]*100; %NI proportion 
NB_prop=[NB_distance]/[GHG]*100; %NB proportion 

 
 %Stores data in a matrix M
 M(i,:)=[AP_prop NM_prop MI_prop MF_prop MB_prop NI_prop NB_prop];  
 
 close
end


 %Plots Global Facial Ratio over time (N pictures until 10)
 for i=1:N
figure (1)
plot([i],[M(i,1)],'kh','DisplayName','Anteroposterior Proportion')
hold on
plot([i],[M(i,2)],'g*','DisplayName','Nasiomeatal Proportion')
hold on
plot([i],[M(i,3)],'b*','DisplayName','Meato-inion Proportion')
hold on
plot([i],[M(i,4)],'y*','DisplayName','Meato-forhead Proportion')
hold on
plot([i],[M(i,5)],'m*','DisplayName','Meato-bregma Proportion')
hold on
plot([i],[M(i,6)],'c*','DisplayName','Nasioinion Proportion')
hold on
plot([i],[M(i,7)],'k*','DisplayName','Nasiobregma Proportion')
xlim([0 10])
ylim ([0 27])
title('Lateral Head Proportions')
xlabel({'Evolution in time','(number of pictures)'})
ylabel('Proportion of head growth')
legend ('Anteroposterior Proportion','Nasiomeatal Proportion','Meato-inion Proportion','Meato-forhead Proportion','Meato-bregma Proportion','Nasioinion Proportion','Nasiobregma Proportion')
saveas(figure (1),'Lateral_head_proportions.tif')

 end
 

end







