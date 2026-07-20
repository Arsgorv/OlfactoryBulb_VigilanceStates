
clear all

%% arousal markers at end of sleep cycles

cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs')
load('SleepScoring_OBGamma.mat', 'CleanStates', 'Info')
Accel = load('SleepScoring_Accelero.mat', 'Info');
EMG = load('StateEpochEMGSB.mat', 'EMG_thresh');

REMEpoch = mergeCloseIntervals(CleanStates.REM , 3*60e4);
REMEpoch = dropShortIntervals(REMEpoch , 60e4);
Dur_REM = DurationEpoch(REMEpoch)/60e4;
Sto = Stop(REMEpoch); % start of sleep cycle
SleepCycle = intervalSet(Sto(1:end-1) , Sto(2:end));
Dur_SleepCyc = DurationEpoch(SleepCycle)/60e4;

load('behavResources.mat', 'MovAcctsd')
load('SleepScoring_OBGamma.mat', 'SmoothGamma','SmoothTheta')

load('ChannelsToAnalyse/EMG.mat', 'channel')
load(['LFPData/LFP' num2str(channel) '.mat'])
smootime = .5;
Epoch = intervalSet([0 14e7]',[4e7 18e7]');
FilLFP=FilterLFP(LFP,[50 300],1024);
EMG = tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));

win = 100;

[M_acc,T_acc] = PlotRipRaw(MovAcctsd, Stop(SleepCycle)/1e4, win*1e3 , 0, 0, 0);
[M_gamma,T_gamma] = PlotRipRaw(SmoothGamma, Stop(SleepCycle)/1e4, win*1e3 , 0, 0, 0);
[M_emg,T_emg] = PlotRipRaw(EMG, Stop(SleepCycle)/1e4, win*1e3 , 0, 0, 0);
[M_theta,T_theta] = PlotRipRaw(SmoothTheta, Stop(SleepCycle)/1e4, win*1e3 , 0, 0, 0);

[M_acc,T_acc2] = PlotRipRaw(MovAcctsd, Stop(CleanStates.N1)/1e4, win*1e3 , 0, 0, 0);
[M_gamma,T_gamma2] = PlotRipRaw(SmoothGamma, Stop(CleanStates.N1)/1e4, win*1e3 , 0, 0, 0);
[M_emg,T_emg2] = PlotRipRaw(EMG, Stop(CleanStates.N1)/1e4, win*1e3 , 0, 0, 0);
[M_theta,T_theta2] = PlotRipRaw(SmoothTheta, Stop(CleanStates.N1)/1e4, win*1e3 , 0, 0, 0);



%% figures
figure
subplot(421)
Data_to_use = T_theta(:,1:500:end); 
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
ylabel('Theta'), l=hline(Info.theta_thresh , '--r'); l.LineWidth = 1; v=vline(0 , '--k');
xlim([-10 10]), ylim([1 7])
title('end REM')

subplot(423)
Data_to_use = T_acc(:,1:20:end); 
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
ylabel('Acc'), l=hline(Accel.Info.mov_threshold , '--r'); l.LineWidth = 1; v=vline(0 , '--k');
xlim([-10 10]), ylim([0 1e7])

subplot(425)
Data_to_use = T_gamma(:,1:500:end); 
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
ylabel('Gamma'), l=hline(Info.gamma_thresh , '--r'); l.LineWidth = 1; v=vline(0 , '--k');
xlim([-10 10]), ylim([100 250])

subplot(427)
Data_to_use = T_emg(:,1:500:end); 
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
ylabel('EMG'), l=hline(EMG.EMG_thresh , '--r'); l.LineWidth = 1;
xlim([-10 10]), ylim([-5e4 2e5])
v=vline(0 , '--k');


subplot(422)
Data_to_use = T_theta2(:,1:500:end); 
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
l=hline(Info.theta_thresh , '--r'); l.LineWidth = 1; v=vline(0 , '--k');
xlim([-10 10]), ylim([1 7])
title('end N1')

subplot(424)
Data_to_use = T_acc2(:,1:20:end); 
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
l=hline(Accel.Info.mov_threshold , '--r'); l.LineWidth = 1; v=vline(0 , '--k');
xlim([-10 10]), ylim([0 1e7])

subplot(426)
Data_to_use = T_gamma2(:,1:500:end); 
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
l=hline(Info.gamma_thresh , '--r'); l.LineWidth = 1; v=vline(0 , '--k');
xlim([-10 10]), ylim([100 250])

subplot(428)
Data_to_use = T_emg2(:,1:500:end); 
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
l=hline(EMG.EMG_thresh , '--r'); l.LineWidth = 1; 
xlim([-10 10]), ylim([-5e4 2e5])
v=vline(0 , '--k');


%% tools
% plot(linspace(-10,10,length(T_acc)) , movmean(nanmean(zscore(T_acc')'),round(length(T_acc)/20)))


figure
subplot(131)
plot(T_acc')
subplot(132)
plot(T_gamma')
subplot(133)
plot(T_emg')


