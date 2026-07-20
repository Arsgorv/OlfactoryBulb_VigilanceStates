
pwd = '/media/nas7/React_Passive_AG/OBG/Brynza/freely-moving/20240202_saline/';

%% EMG / HPC / PFC
for l=[4 15 20] % EMG, PFC, HPC
    load([pwd 'LFPData/LFP' num2str(l) '.mat'])
    LFP_ferret{l} = LFP;
end
l = 4; LFP_ferret_Fil2{l} = FilterLFP(LFP_ferret{l},[50 300],1024);
l = 20; LFP_ferret_Fil5{l} = FilterLFP(LFP_ferret{l},[.1 100],1024);
l = 15; LFP_ferret_Fil{l} = FilterLFP(LFP_ferret{l},[.1 100],1024);

figure
% Wake
subplot(221)
i=0;
plot(Range(LFP_ferret_Fil2{4},'s') , Data(LFP_ferret_Fil2{4})-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil5{20},'s') , Data(LFP_ferret_Fil5{20})*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil{15},'s') , Data(LFP_ferret_Fil{15})-i*4.5e3 , 'k')
xlim([12586 12590]), ylim([-16e3 4e3]), axis off % xlim([12840 12844])
text(12585,0,'EMG','FontSize',15)
text(12585,-4200,'HPC','FontSize',15)
text(12585,-9000,'PFC','FontSize',15)

% NREM
subplot(222)
i=0;
plot(Range(LFP_ferret_Fil2{4},'s') , Data(LFP_ferret_Fil2{4})-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil5{20},'s') , Data(LFP_ferret_Fil5{20})*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil{15},'s') , Data(LFP_ferret_Fil{15})-i*4.5e3 , 'k')
xlim([9621 9625]), ylim([-16e3 4e3]), axis off 

% REM
subplot(223)
i=0;
plot(Range(LFP_ferret_Fil2{4},'s') , Data(LFP_ferret_Fil2{4})-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil5{20},'s') , Data(LFP_ferret_Fil5{20})*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil{15},'s') , Data(LFP_ferret_Fil{15})-i*4.5e3 , 'k')
xlim([10003 10007]), ylim([-16e3 4e3]), axis off

% IS
subplot(224)
i=0;
plot(Range(LFP_ferret_Fil2{4},'s') , Data(LFP_ferret_Fil2{4})-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil5{20},'s') , Data(LFP_ferret_Fil5{20})*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil{15},'s') , Data(LFP_ferret_Fil{15})-i*4.5e3 , 'k')
xlim([8147 8151]), ylim([-16e3 4e3]), axis off



%% bimodal distributions
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs')

smootime = 3;
load('ChannelsToAnalyse/EMG.mat', 'channel')
load(['LFPData/LFP' num2str(channel) '.mat'])
Epoch = intervalSet([0 14e7]',[4e7 18e7]');
LFP = Restrict(LFP , Epoch);
FilLFP=FilterLFP(LFP,[50 300],1024);
EMGData=tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));
EMGData=Restrict(EMGData,Epoch);

figure
subplot(121)
[Y,X] = hist(log10(Data(EMGData)),300);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
box off
v2=vline(3.5,'-r'); v2.LineWidth=3;
xlabel('EMG power (log)'), ylabel('PDF'), xlim([2.2 6.2]), %ylim([0 6e4])
makepretty


load('SleepScoring_OBGamma.mat', 'Sleep', 'SmoothTheta')

subplot(122)
[Y,X] = hist(log10(Data(SmoothTheta)),300);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
box off
v2=vline(.55,'-r'); v2.LineWidth=3;
xlabel('HPC theta power (log)'), ylabel('PDF'), xlim([-.5 1.2]),% ylim([0 6e4])
makepretty
