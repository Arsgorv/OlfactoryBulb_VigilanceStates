pwd = '/media/nas7/React_Passive_AG/OBG/Brynza/freely-moving/20240202_saline/';

%% EMG / HPC / PFC
l=11; % OB
load([pwd 'LFPData/LFP' num2str(l) '.mat'])
LFP_ferret = LFP;

LFP_ferret_Fil1 = FilterLFP(LFP_ferret,[.1 100],1024);
LFP_ferret_Fil2 = FilterLFP(LFP_ferret,[40 60],1024);
LFP_ferret_Fil3 = FilterLFP(LFP_ferret,[50 75],1024);

figure
% Wake
subplot(221)
i=0;
plot(Range(LFP_ferret_Fil1,'s') , Data(LFP_ferret_Fil1)-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil2,'s') , Data(LFP_ferret_Fil2)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil3,'s') , Data(LFP_ferret_Fil3)*4-i*4.5e3 , 'k')
xlim([12588 12590]), ylim([-13e3 2e3]), axis off % xlim([12840 12844])
text(12585,0,'OB','FontSize',15)
text(12585,-4200,'[40-60]','FontSize',15)
text(12585,-9000,'[50-75] Hz','FontSize',15)

% NREM
subplot(222)
i=0;
plot(Range(LFP_ferret_Fil1,'s') , Data(LFP_ferret_Fil1)-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil2,'s') , Data(LFP_ferret_Fil2)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil3,'s') , Data(LFP_ferret_Fil3)-i*4.5e3 , 'k')
xlim([9623 9625]), ylim([-13e3 2e3]), axis off 

% REM
subplot(223)
i=0;
plot(Range(LFP_ferret_Fil1,'s') , Data(LFP_ferret_Fil1)-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil2,'s') , Data(LFP_ferret_Fil2)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil3,'s') , Data(LFP_ferret_Fil3)-i*4.5e3 , 'k')
xlim([9998 10000]), ylim([-13e3 2e3]), axis off


% IS
subplot(224)
i=0;
plot(Range(LFP_ferret_Fil2,'s') , Data(LFP_ferret_Fil2)-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil5,'s') , Data(LFP_ferret_Fil5)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil,'s') , Data(LFP_ferret_Fil)-i*4.5e3 , 'k')
xlim([8147 8151]), ylim([-16e3 4e3]), axis off



%% bimodal distributions
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs')
load('SleepScoring_OBGamma.mat', 'SmoothGamma', 'SmoothGamma_wide','Epoch')

Epoch = and(Epoch , intervalSet([0 14e7]',[1e7 15.3e7]'));


figure
subplot(121)
[Y,X] = hist(log10(Data(Restrict(SmoothGamma , Epoch))),300);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
v2=vline(2.25,'-r'); v2.LineWidth=3;
xlabel('[40-60 Hz] power (log)'), ylabel('PDF'), xlim([2 3]), ylim([0 4e4])
makepretty

subplot(122)
[Y,X] = hist(log10(Data(SmoothGamma_wide)),300);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
v2=vline(2.241,'-r'); v2.LineWidth=3;
xlabel('[50-75 Hz] power (log)'), ylabel('PDF'), xlim([2.12 2.32]), ylim([0 3.5e5])
makepretty
