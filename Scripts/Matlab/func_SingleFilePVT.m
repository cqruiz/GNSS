function func_SingleFilePVT(rootPath,day,hour)
% plot the position, velocity and time (PVT) solution of the receiver.xlim([0,3600])
% rootPath: data folder
% days: day for display, e.g. one day 12 
% hours: hour for display, e.g. one hour 1


pvt = loadjson([rootPath,'\',num2str(day),'\pvtSolution',num2str(hour),'.json']);
recordTime = pvt.recordTime;
xticks1=linspace(1,length(recordTime),3);
xticklabels1 = {};
for xti = 1:length(xticks1)
    xticklabels1{1,xti} = recordTime{1,floor(xticks1(xti))}(12:end-3);
end
%% plot the position, velocity and time (PVT) solution of the receiver.
subplotWid = 0.25;subplotht = 0.34;
figure(101);
set(gcf, 'Position', [100, 100, 1500, 550]);
% subplot(231)
subplot('position', [0.08 0.60 subplotWid subplotht])
plot(pvt.lon,LineWidth=2,Color='r');xlim([0,3600])
legend('Longitude (deg)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(a)');set(gca,'FontSize',15)

% subplot(232)
subplot('position', [0.41 0.60 subplotWid subplotht])
plot(pvt.lat,LineWidth=2,Color='g');xlim([0,3600])
legend('Latitude (deg)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(b)');set(gca,'FontSize',15)

% subplot(233)
subplot('position', [0.73 0.60 subplotWid subplotht])
plot(pvt.height,LineWidth=2,Color='b');xlim([0,3600])
legend('Height (mm)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(c)');hold off;set(gca,'FontSize',15)

% subplot(234)
subplot('position', [0.08 0.13 subplotWid subplotht])
plot(pvt.ecefX,LineWidth=2,Color='r');xlim([0,3600])
legend('ECEFX (cm)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(d)');set(gca,'FontSize',15)

% subplot(235)
subplot('position', [0.41 0.13 subplotWid subplotht])
plot(pvt.ecefY,LineWidth=2,Color='g');xlim([0,3600])
legend('ECEFY (cm)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(e)');set(gca,'FontSize',15)

% subplot(236)
subplot('position', [0.73 0.13 subplotWid subplotht])
plot(pvt.ecefZ,LineWidth=2,Color='b');xlim([0,3600])
legend('ECEFZ (cm)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(f)');set(gca,'FontSize',15)
saveas(gcf,'PVT(P).png')
%%
subplotWid = 0.28;subplotht = 0.70;
fig = figure('Position', [100, 100, 1259, 300]);
subplot('position', [0.04 0.25 subplotWid subplotht])
plot(pvt.velE,LineWidth=2,Color='r');xlim([0,3600])
legend('East  velocity (mm/s)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(a)');set(gca,'FontSize',15)

subplot('position', [0.37 0.25 subplotWid subplotht])
plot(pvt.velD,LineWidth=2,Color='g');xlim([0,3600])
legend('Down velocity (mm/s)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(b)');set(gca,'FontSize',15)

subplot('position', [0.70 0.25 subplotWid subplotht])
plot(pvt.velN,LineWidth=2,Color='b');xlim([0,3600])
legend('North velocity (mm/s)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(c)');set(gca,'FontSize',15)
saveas(gcf,'PVT(V).png')
% 
% figure(103);
% subplot(131),plot(pvt.ecefX,LineWidth=2,Color='r');xlim([0,3600])
% legend('ECEFX (cm)');xticks(xticks1)
% xticklabels(xticklabels1);
% xlabel('(a)');
% subplot(132),plot(pvt.ecefY,LineWidth=2,Color='g');xlim([0,3600])
% legend('ECEFY (cm)');xticks(xticks1)
% xticklabels(xticklabels1);
% xlabel('(b)');
% subplot(133),plot(pvt.ecefZ,LineWidth=2,Color='b');xlim([0,3600])
% legend('ECEFZ (cm)');xticks(xticks1)
% xticklabels(xticklabels1);
% xlabel('(c)');


% figure(104);
subplotWid = 0.195;subplotht = 0.63;
fig = figure('Position', [100, 100, 1250, 300]);
subplot('position', [0.035 0.25 subplotWid subplotht])
plot(pvt.clkB,'r',LineWidth=2);xlim([0,3600])
legend('Clock bias (ns)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(a)');
set(gca,'FontSize',15)

subplot('position', [0.287 0.25 subplotWid subplotht])
plot(pvt.clkD,'g',LineWidth=2);xlim([0,3600])
legend('Clock drift (ns/s)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(b)');
set(gca,'FontSize',15)

subplot('position', [0.53 0.25 subplotWid subplotht])
plot(pvt.tAcc,'b',LineWidth=2);xlim([0,3600])
legend('tAcc (ns)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(c)');
set(gca,'FontSize',15)

subplot('position', [0.777 0.25 subplotWid subplotht])
plot(pvt.fAcc,'m',LineWidth=2);xlim([0,3600])
legend('fAcc (ps/s)');xticks(xticks1)
xticklabels(xticklabels1);
xlabel('(d)');
set(gca,'FontSize',15)
saveas(gcf,'PVT(T).png')


fig = figure('Position', [100, 100, 1000, 300]);
dops = [pvt.gDOP;pvt.pDOP;pvt.tDOP;pvt.vDOP;pvt.hDOP;pvt.nDOP;pvt.eDOP;]';
plot(dops,LineWidth=2);xlim([0,3600])
lgds = {'gDOP','pDOP','tDOP','vDOP','hDOP','nDOP','eDOP'};
legend(lgds,NumColumns=4)
xticks(xticks1)
xticklabels(xticklabels1);
set(gca,'FontSize',15)
saveas(gcf,'DOP.png')



