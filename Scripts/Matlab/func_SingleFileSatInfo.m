function func_SingleFileSatInfo(rootPath,day,hour)
% plot the position, velocity and time (PVT) solution of the receiver.xlim([0,3600])
% rootPath: data folder
% days: day for display, e.g. one day [12] 
% hours: hour for display, e.g. some hours [1] 

satInfo = loadjson([rootPath,'\',num2str(day),'\satelliteInfomation',num2str(hour),'.json']);
recordTime = satInfo.recordTime;
dims = [32,36,63,10,33];
gnsss = ["G","E","B","Q","R"];
%%  G
dim = dims(1);gnss=gnsss(1);
elev = [];%
azim = [];%
elev=[elev zeros(length(satInfo.elev_G),1)];
azim=[azim zeros(length(satInfo.azim_G),1)];
satID = ['']; 
for i=1:dim
    xs=strcat(gnss,num2str(i));
    satID = [satID, xs];
    elev = [elev satInfo.elev_G(:,i)];
    azim = [azim satInfo.azim_G(:,i)];
end
elev(elev <= 0) = missing;
figure(11)
set(gcf, 'Position', [100, 100, 500, 500]);
sp = skyplot(azim(1,:),elev(1,:),satID,MaskElevation=20);
for idx = size(elev, 1)
    set(sp,AzimuthData=azim(1:idx,:),ElevationData=elev(1:idx,:),...
    LabelFontSize=15,MarkerFaceColor='r',MarkerEdgeColor ='r',MarkerEdgeAlpha=0.9);
    drawnow limitrate
end
title('(a) Visible GPS navigation satellites',FontSize=16)
saveas(gcf,'skyplot_GPS.png')

%% E=
dim = dims(2);gnss=gnsss(2);
elev = [];%
azim = [];%
elev=[elev zeros(length(satInfo.elev_E),1)];
azim=[azim zeros(length(satInfo.azim_E),1)];
satID = ['']; 
for i=1:dim
    xs=strcat(gnss,num2str(i));
    satID = [satID, xs];
    elev = [elev satInfo.elev_E(:,i)];
    azim = [azim satInfo.azim_E(:,i)];
end
elev(elev <= 0) = missing;
figure(12)
set(gcf, 'Position', [100, 100, 500, 500]);
sp = skyplot(azim(1,:),elev(1,:),satID,MaskElevation=20);
for idx = size(elev, 1)
    set(sp,AzimuthData=azim(1:idx,:),ElevationData=elev(1:idx,:),...
    LabelFontSize=15,MarkerFaceColor='g',MarkerEdgeColor ='g',MarkerEdgeAlpha=0.9);
    drawnow limitrate
end
title('(b) Visible Galileo navigation satellites',FontSize=16)
saveas(gcf,'skyplot_Galileo.png')
%% B
dim = dims(3);gnss=gnsss(3);
elev = [];%
azim = [];%
elev=[elev zeros(length(satInfo.elev_B),1)];
azim=[azim zeros(length(satInfo.azim_B),1)];
satID = ['']; 
for i=1:dim
    xs=strcat(gnss,num2str(i));
    satID = [satID, xs];
    elev = [elev satInfo.elev_B(:,i)];
    azim = [azim satInfo.azim_B(:,i)];
end
elev(elev <= 0) = missing;
figure(13)
set(gcf, 'Position', [100, 100, 500, 500]);
sp = skyplot(azim(1,:),elev(1,:),satID,MaskElevation=20);
for idx = size(elev, 1)
    set(sp,AzimuthData=azim(1:idx,:),ElevationData=elev(1:idx,:),...
    LabelFontSize=15,MarkerFaceColor='b',MarkerEdgeColor ='b',MarkerEdgeAlpha=0.9);
    drawnow limitrate
end
title('(c) Visible BDS navigation satellites',FontSize=16)
saveas(gcf,'skyplot_BDS.png')
%% Q
dim = dims(4);gnss=gnsss(4);
elev = [];%
azim = [];%
elev=[elev zeros(length(satInfo.elev_Q),1)];
azim=[azim zeros(length(satInfo.azim_Q),1)];
satID = ['']; 
for i=1:dim
    xs=strcat(gnss,num2str(i));
    satID = [satID, xs];
    elev = [elev satInfo.elev_Q(:,i)];
    azim = [azim satInfo.azim_Q(:,i)];
end
elev(elev <= 0) = missing;
figure(14)
set(gcf, 'Position', [100, 100, 500, 500]);
sp = skyplot(azim(1,:),elev(1,:),satID,MaskElevation=20);
for idx = size(elev, 1)
    set(sp,AzimuthData=azim(1:idx,:),ElevationData=elev(1:idx,:),...
    LabelFontSize=15,MarkerFaceColor='m',MarkerEdgeColor ='m',MarkerEdgeAlpha=0.9);
    drawnow limitrate
end
title('(d) Visible QZSS navigation satellites',FontSize=16)
saveas(gcf,'skyplot_QZSS.png')
%% R
dim = dims(5);gnss=gnsss(5);
elev = [];%
azim = [];%
elev=[elev zeros(length(satInfo.elev_R),1)];
azim=[azim zeros(length(satInfo.azim_R),1)];
satID = ['']; 
for i=1:dim
    xs=strcat(gnss,num2str(i));
    satID = [satID, xs];
    elev = [elev satInfo.elev_R(:,i)];
    azim = [azim satInfo.azim_R(:,i)];
end
elev(elev <= 0) = missing;
figure(15)
set(gcf, 'Position', [100, 100, 500, 500]);
sp = skyplot(azim(1,:),elev(1,:),satID,MaskElevation=20);
for idx = size(elev, 1)
    set(sp,AzimuthData=azim(1:idx,:),ElevationData=elev(1:idx,:),...
    LabelFontSize=15,MarkerFaceColor='#D94319',MarkerEdgeColor ='#D94319',MarkerEdgeAlpha=0.9);
    drawnow limitrate
end
title('(e) Visible GLONASS navigation satellites',FontSize=16)
saveas(gcf,'skyplot_GLONASS.png')
