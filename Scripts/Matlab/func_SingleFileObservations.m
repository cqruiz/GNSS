function func_SingleFileObservations(rootPath,day,hour)
% Place "jsonlab" in the toolbox folder in the matlab installation directory

obs = loadjson([rootPath,'\',num2str(day),'\observation',num2str(hour),'.json']);
recordTime = obs.recordTime;
dims = [32,36,63,10,33];
gnssIds = [0,2,3,5,6];
sigId2s = [3,6,2,5,2];

%% G *****************************************************************************
tNum = 3;
subplotWid = 0.19;subplotht = 0.63;  
xticks1=linspace(1,length(recordTime),tNum);%[1 1800 length(recordTime)];
xticklabels1 = {};
for xti = 1:length(xticks1)
    xticklabels1{1,xti} = recordTime{1,floor(xticks1(xti))}(12:end-3);
end
%  
figure(1)
set(gcf, 'Position', [50, 100, 1800, 460]); %  % set Figure window position and size
m=1; n=4;cno_TH = 10;
dim=32; gnss='G';
lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.05 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_G1(:,i))>cno_TH
        clgd =clgd +1;
        cn0_G1=obs.cn0_G1(:,i);
        cn0_G1(cn0_G1 == 0) = NaN;
        plot(cn0_G1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1C/A');
    end
end
for i=1:dim
    if mean(obs.cn0_G2(:,i))>cno_TH
        clgd =clgd +1;
        cn0_G2=obs.cn0_G2(:,i);
        cn0_G2(cn0_G2 == 0) = NaN;
        plot(cn0_G2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L2C');
    end
end
lgd = legend;
legend(lgds,NumColumns=8)
set(lgd,...
    'Position',[0.3499074121426652 0.856073484898151 0.305555547790394 0.104999997019768],...
    'NumColumns',8);
xlim([0,3600]),ylim([10,55])
xticks(xticks1)
xticklabels(xticklabels1);ylabel('C/N_0 [dB-Hz]')
xlabel('(a)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.305 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_G1(:,i))>cno_TH
        clgd =clgd +1;
        doMes_G1=obs.doMes_G1(:,i);
        doMes_G1(doMes_G1 == 0) = NaN;
        plot(doMes_G1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1C/A');
    end
end
for i=1:dim
    if mean(obs.cn0_G2(:,i))>cno_TH
        clgd =clgd +1;
        doMes_G2=obs.doMes_G2(:,i);
        doMes_G2(doMes_G2 == 0) = NaN;
        plot(doMes_G2,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L2C');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);
ylabel('Doppler [Hz]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(b)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.545 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_G1(:,i))>cno_TH
        clgd =clgd +1;
        prMes_G1=obs.prMes_G1(:,i);
        prMes_G1(prMes_G1 == 0) = NaN;
        plot(prMes_G1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1C/A');
    end
end
for i=1:dim
    if mean(obs.cn0_G2(:,i))>cno_TH
        clgd =clgd +1;
        prMes_G2=obs.prMes_G2(:,i);
        prMes_G2(prMes_G2 == 0) = NaN;
        plot(prMes_G2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L2C');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);
ylabel('Pseudorange [m]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(c)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.79 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_G1(:,i))>cno_TH
        clgd =clgd +1;
        cpMes_G1=obs.cpMes_G1(:,i);
        cpMes_G1(cpMes_G1 == 0) = NaN;
        plot(cpMes_G1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1C/A');
    end
end
for i=1:dim
    if mean(obs.cn0_G2(:,i))>cno_TH
        clgd =clgd +1;
        cpMes_G2=obs.cpMes_G2(:,i);
        cpMes_G2(cpMes_G2 == 0) = NaN;
        plot(cpMes_G2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L2C');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Carrier Phase [Cycles]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(d)');hold off;
saveas(gcf,'obs_GPS.png')
%%  E
figure(2)
set(gcf, 'Position', [50, 100, 1800, 460]); % set Figure window position and size
m=1; n=4;
dim=36; gnss='E';
lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.05 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_E1(:,i))>cno_TH
        clgd =clgd +1;
        cn0_E1=obs.cn0_E1(:,i);
        cn0_E1(cn0_E1 == 0) = NaN;
        plot(cn0_E1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' E1');
    end
end
for i=1:dim
    if mean(obs.cn0_E2(:,i))>cno_TH
        clgd =clgd +1;
        cn0_E2=obs.cn0_E2(:,i);
        cn0_E2(cn0_E2 == 0) = NaN;
        plot(cn0_E2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' E5b');
    end
end
lgd = legend;
legend(lgds,NumColumns=8)
set(lgd,...
    'Position',[0.3499074121426652 0.856073484898151 0.305555547790394 0.104999997019768],...
    'NumColumns',8);
xlim([0,3600]),ylim([10,50])
xticks(xticks1)
xticklabels(xticklabels1);ylabel('C/N_0 [dB-Hz]')
xlabel('(e)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.305 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_E1(:,i))>cno_TH
        clgd =clgd +1;
        doMes_E1=obs.doMes_E1(:,i);
        doMes_E1(doMes_E1 == 0) = NaN;
        plot(doMes_E1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' E1');
    end
end
for i=1:dim
    if mean(obs.cn0_E2(:,i))>cno_TH
        clgd =clgd +1;
        doMes_E2=obs.doMes_E2(:,i);
        doMes_E2(doMes_E2 == 0) = NaN;
        plot(doMes_E2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' E5b');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Doppler [Hz]');
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(f)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.545 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_E1(:,i))>cno_TH
        clgd =clgd +1;
        prMes_E1=obs.prMes_E1(:,i);
        prMes_E1(prMes_E1 == 0) = NaN;
        plot(prMes_E1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' E1');
    end
end
for i=1:dim
    if mean(obs.cn0_E2(:,i))>cno_TH
        clgd =clgd +1;
        prMes_E2=obs.prMes_E2(:,i);
        prMes_E2(prMes_E2 == 0) = [];
        plot(prMes_E2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = [gnss, num2str(i), ' E5b'];
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Pseudorange [m]');
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(g)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.79 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_E1(:,i))>cno_TH
        clgd =clgd +1;
        cpMes_E1=obs.cpMes_E1(:,i);
        cpMes_E1(cpMes_E1 == 0) = NaN;
        plot(cpMes_E1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' E1');
    end
end
for i=1:dim
    if mean(obs.cn0_E2(:,i))>cno_TH
        clgd =clgd +1;
        cpMes_E2=obs.cpMes_E2(:,i);
        cpMes_E2(cpMes_E2 == 0) = NaN;
        plot(cpMes_E2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' E5b');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Carrier Phase [Cycles]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(h)');hold off;
saveas(gcf,'obs_Galileo.png')

%%  B  *****************************************************************************

figure(3)
set(gcf, 'Position', [50, 100, 1800, 460]); %  % set Figure window position and size
m=1; n=4;
dim=63; gnss='B';
lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.05 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_B1(:,i))>cno_TH
        clgd =clgd +1;
        cn0_B1=obs.cn0_B1(:,i);
        cn0_B1(cn0_B1 == 0) = NaN;
        plot(cn0_B1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' B1');
    end
end
for i=1:dim
    if mean(obs.cn0_B2(:,i))>cno_TH
        clgd =clgd +1;
        cn0_B2=obs.cn0_B2(:,i);
        cn0_B2(cn0_B2 == 0) = NaN;
        plot(cn0_B2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' B2');
    end
end
lgd = legend;
legend(lgds,NumColumns=12)
set(lgd,...
    'Position',[0.3499074121426652 0.856073484898151 0.305555547790394 0.104999997019768],...
    'NumColumns',12);
xlim([0,3600]),ylim([15,53])
xticks(xticks1)
xticklabels(xticklabels1);ylabel('C/N_0 [dB-Hz]')
xlabel('(i)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.305 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_B1(:,i))>cno_TH
        clgd =clgd +1;
        doMes_B1=obs.doMes_B1(:,i);
        doMes_B1(doMes_B1 == 0) = NaN;
        plot(doMes_B1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' B1');
    end
end
for i=1:dim
    if mean(obs.cn0_B2(:,i))>cno_TH
        clgd =clgd +1;
        doMes_B2=obs.doMes_B2(:,i);
        doMes_B2(doMes_B2 == 0) = NaN;
        plot(doMes_B2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' B2');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Doppler [Hz]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(j)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.545 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_B1(:,i))>cno_TH
        clgd =clgd +1;
        prMes_B1=obs.prMes_B1(:,i);
        prMes_B1(prMes_B1 == 0) = NaN;
        plot(prMes_B1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' B1');
    end
end
for i=1:dim
    if mean(obs.cn0_B2(:,i))>cno_TH
        clgd =clgd +1;
        prMes_B2=obs.prMes_B2(:,i);
        prMes_B2(prMes_B2 == 0) = NaN;
        plot(prMes_B2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' B2');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Pseudorange [m]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(k)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.79 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_B1(:,i))>cno_TH
        clgd =clgd +1;
        cpMes_B1=obs.cpMes_B1(:,i);
        cpMes_B1(cpMes_B1 == 0) = NaN;
        plot(cpMes_B1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' B1');
    end
end
for i=1:dim
    if mean(obs.cn0_B2(:,i))>cno_TH
        clgd =clgd +1;
        cpMes_B2=obs.cpMes_B2(:,i);
        cpMes_B2(cpMes_B2 == 0) = NaN;
        plot(cpMes_B2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' B2');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Carrier Phase [Cycles]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(l)');hold off;
saveas(gcf,'obs_BDS.png')
%%  Q   ***********************************************************************************
  
figure(4)
set(gcf, 'Position', [50, 100, 1800, 460]); %  % set Figure window position and size
m=1; n=4;
dim=10; gnss='Q';
lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.05 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_Q1(:,i))>cno_TH
        clgd =clgd +1;
        cn0_Q1=obs.cn0_Q1(:,i);
        cn0_Q1(cn0_Q1 == 0) = NaN;
        plot(cn0_Q1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1C/A');
    end
end
for i=1:dim
    if mean(obs.cn0_Q2(:,i))>cno_TH
        clgd =clgd +1;
        cn0_Q2=obs.cn0_Q2(:,i);
        cn0_Q2(cn0_Q2 == 0) = NaN;
        plot(cn0_Q2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L2C');
    end
end
lgd = legend;
legend(lgds,NumColumns=8)
set(lgd,...
    'Position',[0.3499074121426652 0.856073484898151 0.305555547790394 0.104999997019768],...
    'NumColumns',8);
xlim([0,3600]),ylim([0,50])
xticks(xticks1)
xticklabels(xticklabels1);ylabel('C/N_0 [dB-Hz]')
xlabel('(e)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.305 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_Q1(:,i))>cno_TH
        clgd =clgd +1;
        doMes_Q1=obs.doMes_Q1(:,i);
        doMes_Q1(doMes_Q1 == 0) = NaN;
        plot(doMes_Q1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1 C/A');
    end
end
for i=1:dim
    if mean(obs.cn0_Q2(:,i))>cno_TH
        clgd =clgd +1;
        doMes_Q2=obs.doMes_Q2(:,i);
        doMes_Q2(doMes_Q2 == 0) = NaN;
        plot(doMes_Q2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), '  L2');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Doppler [Hz]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(f)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.545 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_Q1(:,i))>cno_TH
        clgd =clgd +1;
        prMes_Q1=obs.prMes_Q1(:,i);
        prMes_Q1(prMes_Q1 == 0) = NaN;
        plot(prMes_Q1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1 C/A');
    end
end
for i=1:dim
    if mean(obs.cn0_Q2(:,i))>cno_TH
        clgd =clgd +1;
        prMes_Q2=obs.prMes_Q2(:,i);
        prMes_Q2(prMes_Q2 == 0) = NaN;
        plot(prMes_Q2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L2C');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Pseudorange [m]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(g)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.79 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_Q1(:,i))>cno_TH
        clgd =clgd +1;
        cpMes_Q1=obs.cpMes_Q1(:,i);
        cpMes_Q1(cpMes_Q1 == 0) = NaN;
        plot(cpMes_Q1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1 C/A');
    end
end
for i=1:dim
    if mean(obs.cn0_Q2(:,i))>cno_TH
        clgd =clgd +1;
        cpMes_Q2=obs.cpMes_Q2(:,i);
        cpMes_Q2(cpMes_Q2 == 0) = NaN;
        plot(cpMes_Q2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L2C');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Carrier Phase [Cycles]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(h)');hold off;
saveas(gcf,'obs_QZSS.png')
%% R *****************************************************************************

figure(5)
set(gcf, 'Position', [50, 100, 1800, 460]); %  % set Figure window position and size
m=1; n=4;
dim=32; gnss='R';
lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.05 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_R1(:,i))>cno_TH
        clgd =clgd +1;
        cn0_R1=obs.cn0_R1(:,i);
        cn0_R1(cn0_R1 == 0) = NaN;
        plot(cn0_R1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1');
    end
end
for i=1:dim
    if mean(obs.cn0_R2(:,i))>cno_TH
        clgd =clgd +1;
        cn0_R2=obs.cn0_R2(:,i);
        cn0_R2(cn0_R2 == 0) = NaN;
        plot(cn0_R2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L2');
    end
end
lgd = legend;
legend(lgds,NumColumns=8)
set(lgd,...
    'Position',[0.3499074121426652 0.856073484898151 0.305555547790394 0.104999997019768],...
    'NumColumns',8);
xlim([0,3600]),ylim([10,55])
xticks(xticks1)
xticklabels(xticklabels1);ylabel('C/N_0 [dB-Hz]')
xlabel('(q)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.305 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_R1(:,i))>cno_TH
        clgd =clgd +1;
        doMes_R1=obs.doMes_R1(:,i);
        doMes_R1(doMes_R1 == 0) = NaN;
        plot(doMes_R1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1');
    end
end
for i=1:dim
    if mean(obs.cn0_R2(:,i))>cno_TH
        clgd =clgd +1;
        doMes_R2=obs.doMes_R2(:,i);
        doMes_R2(doMes_R2 == 0) = NaN;
        plot(doMes_R2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L2');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Doppler [Hz]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(r)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.545 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_R1(:,i))>cno_TH
        clgd =clgd +1;
        prMes_R1=obs.prMes_R1(:,i);
        prMes_R1(prMes_R1 == 0) = NaN;
        plot(prMes_R1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1');
    end
end
for i=1:dim
    if mean(obs.cn0_R2(:,i))>cno_TH
        clgd =clgd +1;
        prMes_R2=obs.prMes_R2(:,i);
        prMes_R2(prMes_R2 == 0) = NaN;
        plot(prMes_R2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L2');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Pseudorange [m]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(s)');hold off;

lgds = {};clgd = 0;LineWidth1=1.8;
subplot('position', [0.79 0.15 subplotWid subplotht])
for i=1:dim
    if mean(obs.cn0_R1(:,i))>cno_TH
        clgd =clgd +1;
        cpMes_R1=obs.cpMes_R1(:,i);
        cpMes_R1(cpMes_R1 == 0) = NaN;
        plot(cpMes_R1,'-',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L1');
    end
end
for i=1:dim
    if mean(obs.cn0_R2(:,i))>cno_TH
        clgd =clgd +1;
        cpMes_R2=obs.cpMes_R2(:,i);
        cpMes_R2(cpMes_R2 == 0) = NaN;
        plot(cpMes_R2,'-.',LineWidth=LineWidth1);hold on;
        lgds{1,clgd} = strcat(gnss, num2str(i), ' L2');
    end
end
% legend(lgds,NumColumns=2)
xlim([0,3600]);ylabel('Carrier Phase [Cycles]')
xticks(xticks1)
xticklabels(xticklabels1)
xlabel('(t)');hold off;
saveas(gcf,'obs_GLONASS.png')

