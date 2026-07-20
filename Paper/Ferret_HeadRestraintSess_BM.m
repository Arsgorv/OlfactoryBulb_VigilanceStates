

cd('/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/2023-01-21_16-52-21')
load('InstFreqAndPhase_B.mat', 'AllPeaks')
load('LFPData/LFP35.mat')
load('StateEpochSB.mat', 'Sleep', 'S1_epoch', 'S2_epoch', 'Wake')


%% OB spectrograms
figure

load('B_UltraLow_Spectrum.mat')

subplot(311)
imagesc(Spectro{2} , Spectro{3} , Spectro{1}'), axis xy, caxis([0 4e4])
xlabel(''), ylabel('Frequency (Hz)')
makepretty
title('OB Ultra Low')
Hypnogram_LineColor_BM(.95)


load('B_Low_Spectrum.mat')

subplot(312)
imagesc(Spectro{2} , Spectro{3} , Spectro{1}'), axis xy, caxis([0 4e4])
xlabel(''), ylabel('Frequency (Hz)')
makepretty
title('OB Low')
Hypnogram_LineColor_BM(19)


load('B_Middle_Spectrum.mat')

subplot(313)
imagesc(Spectro{2} , Spectro{3} , Spectro{1}'), axis xy, caxis([0 5e3])
xlabel('time (s)'), ylabel('Frequency (Hz)'), ylim([20 100])
makepretty
a=colorbar; a.Ticks=[0 1e4]; a.TickLabels={'0','1'}; a.Label.String='Power (a.u.)'; a.Label.FontSize=15;
title('OB High')
Hypnogram_LineColor_BM(95)

a=suptitle('OB spectrograms, head restraint session'); a.FontSize=20;



%% Mean waveform
Breathing_tsd = LFP;
Breathing_Sleep = Restrict(Breathing_tsd , Sleep);
Breathing_Wake = Restrict(Breathing_tsd , Wake);
Breathing_S1 = Restrict(Breathing_tsd , S1_epoch);
Breathing_S2 = Restrict(Breathing_tsd , S2_epoch);


figure
Conf_Inter=nanstd(T_sleep)/sqrt(size(T_sleep,1));
h=shadedErrorBar(M_sleep(:,1)' , nanmean(T_sleep) , Conf_Inter ,'-r',1); hold on;
Conf_Inter=nanstd(T_wake)/sqrt(size(T_wake,1));
h=shadedErrorBar(M_wake(:,1)' , nanmean(T_wake) , Conf_Inter ,'-b',1); hold on;
makepretty
xlabel('time (s)')
ylabel('amplitude (a.u.)')
f=get(gca,'Children'); legend([f(5),f(1)],'Sleep','Wake');
ylim([7e3 9e3])
title('Mean breathing waveform, head restraint session')


%% Physio basic stuff
load('HeartBeatInfo.mat')

EKG_smooth = tsd(Range(EKG.HBRate) , runmean(Data(EKG.HBRate),30));
EKG_smooth_Wake = Restrict(EKG_smooth , Wake);
EKG_smooth_Sleep = Restrict(EKG_smooth , Sleep);

EKG_Wake = Restrict(EKG.HBRate , Wake);
EKG_Sleep = Restrict(EKG.HBRate , Sleep);

HRVar = tsd(Range(EKG.HBRate) , movstd(Data(EKG.HBRate),3));
HRVar_Sleep = Restrict(HRVar , Sleep);
HRVar_Wake = Restrict(HRVar , Wake);

HRVar_smooth = tsd(Range(HRVar) , runmean(Data(HRVar),30));
HRVar_smooth_Wake = Restrict(HRVar_smooth , Wake);
HRVar_smooth_Sleep = Restrict(HRVar_smooth , Sleep);


figure
subplot(2,7,1:6)
plot(Range(EKG_smooth_Wake,'s') , runmean(Data(EKG_smooth_Wake),30) , '.b' , 'MarkerSize' , 2)
hold on
plot(Range(EKG_smooth_Sleep,'s') , runmean(Data(EKG_smooth_Sleep),30) , '.r' , 'MarkerSize' , 2)
ylabel('Frequency (Hz)')
legend('Wake','Sleep')
title('Heart rate evolution')

subplot(277)
u=bar([nanmean(Data(EKG_smooth_Wake)) nanmean(Data(EKG_smooth_Sleep))]); u.FaceColor = 'flat'; u.CData = [0 0 1 ; 1 0 0];
xticklabels({'Wake','Sleep'})
ylabel('Frequency (Hz)')
title('Heart rate mean value')


subplot(2,7,8:13)
plot(Range(HRVar_smooth_Wake,'s') , runmean(Data(HRVar_smooth_Wake),30) , '.b' , 'MarkerSize' , 2)
hold on
plot(Range(HRVar_smooth_Sleep,'s') , runmean(Data(HRVar_smooth_Sleep),30) , '.r' , 'MarkerSize' , 2)
ylabel('Frequency (Hz)'), xlabel('time (s)')
title('Heart rate variability evolution')

subplot(2,7,14)
u=bar([nanmean(Data(HRVar_smooth_Wake)) nanmean(Data(HRVar_smooth_Sleep))]); u.FaceColor = 'flat'; u.CData = [0 0 1 ; 1 0 0];
xticklabels({'Wake','Sleep'})
ylabel('Frequency (Hz)')
title('Heart rate variability mean value')

a=suptitle('Hear activity, head restraint session'); a.FontSize=20;



[M_all,T_all] = PlotRipRaw(EKG.HBRate , AllPeaks_corr, 2e3, 0 , 0);
[M_sleep,T_sleep] = PlotRipRaw(EKG_Sleep , Range(AllPeaks_Sleep)/1e4, 2e3, 0 , 0);
[M_wake,T_wake] = PlotRipRaw(EKG_Wake , Range(AllPeaks_Wake)/1e4, 2e3, 0 , 0);

figure
subplot(121)
Conf_Inter=nanstd(T_sleep)/sqrt(size(T_sleep,1));
h=shadedErrorBar(M_sleep(:,1)' , nanmean(T_sleep) , Conf_Inter ,'-r',1); hold on;
Conf_Inter=nanstd(T_wake)/sqrt(size(T_wake,1));
h=shadedErrorBar(M_wake(:,1)' , nanmean(T_wake) , Conf_Inter ,'-b',1); hold on;
makepretty
xlabel('time (s)')
ylabel('Frequency (Hz)')
f=get(gca,'Children'); legend([f(5),f(1)],'Sleep','Wake');
title('Heart rate')


[M_all,T_all] = PlotRipRaw(HRVar , AllPeaks_corr, 2e3, 0 , 0);
[M_sleep,T_sleep] = PlotRipRaw(HRVar_Sleep , Range(AllPeaks_Sleep)/1e4, 2e3, 0 , 0);
[M_wake,T_wake] = PlotRipRaw(HRVar_Wake , Range(AllPeaks_Wake)/1e4, 2e3, 0 , 0);

subplot(122)
Conf_Inter=nanstd(T_sleep)/sqrt(size(T_sleep,1));
h=shadedErrorBar(M_sleep(:,1)' , nanmean(T_sleep) , Conf_Inter ,'-r',1); hold on;
Conf_Inter=nanstd(T_wake)/sqrt(size(T_wake,1));
h=shadedErrorBar(M_wake(:,1)' , nanmean(T_wake) , Conf_Inter ,'-b',1); hold on;
makepretty
xlabel('time (s)'), ylabel('variability (a.u.)')
title('Heart rate variability')


a=suptitle('Heart activity around breathing, head restraint session'); a.FontSize=20;



