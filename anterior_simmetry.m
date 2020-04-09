%Author:Eduardo Alho
%Date:17/06/2017
%This function analyses facial simmetry from anterior view photographs
%N is the number of images to be compared

%anterior symmetry---------------------------------------
function anterior_simmetry(N)

for i=1:N
%loads image
nf = uigetfile('*.jpg','Choose an image.');
Af = imread(nf);

figure(1)
set(1,'Name','Define rotation in prompt','Numbertitle','off');
imshow(Af)
prompt = 'To rotate image clockwise press -90 or -180, counter clockwise 90 or 180 or 0 to continue: ' ;
x = input(prompt);
Af=imrotate(Af,x);
imshow(Af)

figure(1)
set(1,'Name','Define facial midline','Numbertitle','off');
%imshow(Af)
%Defines top of the head (H)
h1=impoint;
wait(h1);
pos1 = h1.getPosition();
%Defines chin (C)
h2=impoint;
wait(h2);
pos2=h2.getPosition();
%Defines midline and calculates HC distance
Mid= imline(gca,[pos2(1) pos1(1)],[pos2(2),pos1(2)]);
Midline=createMask(Mid);
PointsMidline=[pos1(1) pos1(2);pos2(1) pos2(2)];
HC_distance=pdist(PointsMidline);

%Defines forehead (F)
set(1,'Name','Define forehead','Numbertitle','off');
h3=impoint;
wait(h3);
pos3=h3.getPosition();

%Defines glabela (G)
set(1,'Name','Define glabela','Numbertitle','off');
h4=impoint;
wait(h4);
pos4=h4.getPosition();

%Defines subnasale (N)
set(1,'Name','Define subnasal point','Numbertitle','off');
h5=impoint;
wait(h5);
pos5=h5.getPosition();

%Defines biparietal points (BP) and biparietal line distance
set(1,'Name','Define 2 parietal points','Numbertitle','off');
%first parietal
h6=impoint;
wait(h6);
pos6=h6.getPosition();
%second parietal
h7=impoint;
wait(h7);
pos7=h7.getPosition();
%Defines midline and calculates BP distance
BP_line= imline(gca,[pos6(1) pos7(1)],[pos6(2),pos7(2)]);
Biparietal=createMask(BP_line);
PointsBP=[pos7(1) pos7(2);pos6(1) pos6(2)];
BP_distance=pdist(PointsBP);

%Defines lateral canthus points (e1 and e2) and ocular distance
set(1,'Name','Define lateral canthus of both eyes','Numbertitle','off');
%first eye
h8=impoint;
wait(h8);
pos8=h8.getPosition();
%second eye
h9=impoint;
wait(h9);
pos9=h9.getPosition();
%Defines eye line and calculates e1e2 distance
eye_line= imline(gca,[pos8(1) pos9(1)],[pos8(2),pos9(2)]);
Eyes=createMask(eye_line);
Points_eyes=[pos9(1) pos9(2);pos8(1) pos8(2)];
e1e2_distance=pdist(Points_eyes);

%Defines Tragus (T1 and T2) and facial width (T1T2 distance)
set(1,'Name','Define tragus bilaterally','Numbertitle','off');
%first tragus (T1)
h10=impoint;
wait(h10);
pos10=h10.getPosition();
%second tragus (T2)
h11=impoint;
wait(h11);
pos11=h11.getPosition();
%Defines tragus and calculates T1T2 distance
face_line= imline(gca,[pos10(1) pos11(1)],[pos10(2),pos11(2)]);
face=createMask(face_line);
Points_face=[pos10(1) pos10(2);pos11(1) pos11(2)];
T1T2_distance=pdist(Points_face);

%Ratios and proportions 

% 1)Golden ratio: (Fi) is equal 1,618
%Face_ratio is the proportion between hight and width of the face
%Eye_ratio is the proportion between eye distance and face width
%ideal number for both is Fi
Fi=1.618;
Face_ratio=HC_distance/T1T2_distance;
Eye_ratio=T1T2_distance/e1e2_distance;


% 2) Facial proportions (facial proportions should be divided in 3/3)

%Forehead to chin distance
Points_FC=[pos3(1) pos3(2);pos2(1) pos2(2)];
FC_dist=pdist(Points_FC);
Perfect_third=FC_dist/3;
%Forhead distance
Points_forhead=[pos3(1) pos3(2);pos4(1) pos4(2)];
Forhead_dist=pdist(Points_forhead);
Forhead_size=Forhead_dist/Perfect_third; %ideal is 1, <1 indicate forhead smaller that ideal, >1, bigger
%Middle third
Points_middle=[pos4(1) pos4(2);pos5(1) pos5(2)];
Middle_dist=pdist(Points_middle);
Middle_size=Middle_dist/Perfect_third; %ideal is 1, <1 indicate middle face smaller that ideal, >1, bigger
%Inferior third
Points_chin=[pos5(1) pos5(2);pos2(1) pos2(2)];
Inferior_dist=pdist(Points_chin);
Inferior_size=Inferior_dist/Perfect_third; %ideal is 1, <1 indicate inferior face smaller that ideal, >1, bigger

%3)Craniofacial proportion :this index should be slightly higher than 1 (as
%biparietal distance is normally a little bit bigger than the face width.
%If this index is much higher than 1, indicates skull is big in relationship to the face,
%and smaller than 1, skull is small in proportion to the face

Craniofacial_proportion=BP_distance/T1T2_distance;

%4) Angles between eyes, ears and midline
x1=pos1(1); 
x2=pos2(1);
x3=pos9(1);
x4=pos8(1);
x5=pos10(1);
x6=pos11(1);
y1=pos1(2);
y2=pos2(2);
y3=pos9(2);
y4=pos8(2);
y5=pos10(2);
y6=pos11(2);

 ang_eyes_rad = mod( atan2( (x2-x1)*(y4-y3)-(y2-y1)*(x4-x3),...
     (x2-x1)*(x4-x3)+(y2-y1)*(y4-y3) ) , 2*pi ) ;
 
 ang_ears_rad = mod( atan2( (x2-x1)*(y5-y6)-(y2-y1)*(x5-x6),...
     (x2-x1)*(x5-x6)+(y2-y1)*(y5-y6) ) , 2*pi );
 
 %angle betwwee eye line and midline, ideally 90 degrees
 angleEyes = radtodeg(ang_eyes_rad);
 %angle betwwee ear line and midline, ideally 90 degrees
 angleEars = radtodeg(ang_ears_rad);
 
 %Stores data in a matrix M
 M(i,:)=[Face_ratio Eye_ratio Forhead_size Middle_size Inferior_size Craniofacial_proportion angleEyes angleEars];
 
 close
 
end
xlswrite('Values.xls',M);

 %Plots Global Facial Ratio over time (N pictures until 10)
 for i=1:N
figure (1)
plot([i],[M(i,1)],'kd','DisplayName','Facial Ratio')
hold on
plot([i],[M(i,2)],'r*','DisplayName','Eye Ratio')
hold on
plot([0 10],[1.618 1.618],'b','DisplayName','Golden Ratio(\phi)')
xlim([0 10])
ylim ([0 5])
title('Global Facial Ratios')
xlabel({'Evolution in time','(number of pictures)'})
ylabel('Facial and Eye ratios')
legend ('Facial Ratio','Eye Ratio','Golden Ratio (\phi)')
saveas(figure (1),'Global_Facial_ratio.tif')

 end
 
 %Plots craniofacial relationship to the ideal number (close to 1) over time(N pictures until 10)
 for i=1:N
figure (2)
plot([i],[M(i,6)],'kd','DisplayName','Craniofacial proportion')
hold on
plot([0 10],[1.1 1.1],'b','DisplayName','Ideal')
xlim([0 10])
ylim ([0 5])
title('Craniofacial proportion')
xlabel({'Evolution in time','(number of pictures)'})
ylabel('proportions')
legend ('Craniofacial proportion','Ideal')
saveas(figure (2),'Craniofacial_proportions.tif')
 end
 
 %Plots sizes of three thirds of the face in relationship to the ideal number (N pictures until 10)
 for i=1:N
figure (3)
plot([i],[M(i,3)],'kd','DisplayName','superior third')
hold on
plot([i],[M(i,4)],'r*','DisplayName','middle third')
hold on
plot([i],[M(i,5)],'mo','DisplayName','inferior third')
hold on
plot([0 10],[1 1],'b','DisplayName','Ideal')
xlim([0 10])
ylim ([0 5])
title('Facial proportions in thirds')
xlabel({'Evolution in time','(number of pictures)'})
ylabel('Facial proportions')
legend ('superior third','middle third','inferior third','Ideal')
saveas(figure (3),'Facial_proportions.tif')
 end
 
 %Plots Eye and Ear angles in relationship to midline over time (N pictures until 10)
 for i=1:N
figure (4)
plot([i],[M(i,7)],'kd','DisplayName','Eyes')
hold on
plot([i],[M(i,8)],'r*','DisplayName','Ears')
hold on
plot([0 120],[90 90],'b','DisplayName','Ideal angle')
xlim([0 10])
ylim ([30 120])
title('Eyes and Ears angles relative to midline')
xlabel({'Evolution in time','(number of pictures)'})
ylabel('Angles')
legend ('Eyes','Ears','Ideal')
saveas(figure (4),'Eye_Ear_angles.tif')
 end

end







