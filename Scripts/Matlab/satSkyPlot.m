function satSkyPlot(gnssId,elev,azim, sats)
% gnssId: ID of GNSS (see Table 2), GPS:0, Galileo:2, BDS:3, QZSS:5, GLONASS: 6
% elev: Elevation 
% azim:  Azimuth 
% sats: satellites number for display, e.g. some satellites [1,2,3] or all GPS satellites: sats = linspace(1,32,32);

if gnssId ==0
    dim=32; gnss="G";
elseif gnssId == 2
    dim=36; gnss="E";
elseif gnssId == 3
    dim=63; gnss="B";
elseif gnssId == 5
    dim=10; gnss="Q";
elseif gnssId == 6
    dim=33; gnss="R";
else
    print('Wrong input for gnssId, please check!')
    print('GPS:0, Galileo:2, BDS:3, QZSS:5, GLONASS: 6')
end

sat_elev = [];
sat_azim = [];
sat_elev=[sat_elev zeros(length(elev),1)];
sat_azim=[sat_azim zeros(length(azim),1)];
sat_satID = [''];
for i=sats
    xs=strcat(gnss,num2str(i));
    sat_satID = [sat_satID, xs];
    sat_elev = [sat_elev elev(:,i)];
    sat_azim = [sat_azim azim(:,i)];
end
sat_elev(sat_elev <= 0) = missing;
figure(301)
set(gcf, 'Position', [100, 100, 500, 500]);
sp = skyplot(sat_azim(1,:),sat_elev(1,:),sat_satID,MaskElevation=20);
for idx = size(sat_elev, 1)
    set(sp,AzimuthData=sat_azim(1:idx,:),ElevationData=sat_elev(1:idx,:),...
    LabelFontSize=10,MarkerFaceColor='#D94319',MarkerEdgeColor ='#D94319',MarkerEdgeAlpha=0.9);
    drawnow limitrate
end
end
