
%%
clear all

cd('/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230227/')
load('DLC/DLC_data.mat', 'areas_pupil_tsd', 'pupil_mvt_tsd')
load('SleepScoring_OBGamma.mat', 'CleanStates')
CleanStates.REMEpoch = mergeCloseIntervals(CleanStates.REM,60e4);
CleanStates.REMEpoch = dropShortIntervals(CleanStates.REM,35e4);

smooth_PupilMvt = tsd(Range(pupil_mvt_tsd) , runmean(Data(pupil_mvt_tsd),1e2));
PupilMvt_Wake = Restrict(smooth_PupilMvt , CleanStates.Wake);
PupilMvt_N1 = Restrict(smooth_PupilMvt , CleanStates.N1);
PupilMvt_N2 = Restrict(smooth_PupilMvt , CleanStates.N2);
PupilMvt_REM = Restrict(smooth_PupilMvt , CleanStates.REMEpoch);


figure
plot(Range(PupilMvt_Wake,'s')/3.6e3 , Data(PupilMvt_Wake) , '.b')
hold on
plot(Range(PupilMvt_N1,'s')/3.6e3 , Data(PupilMvt_N1) , '.' , 'Color' , [1 .5 0])
plot(Range(PupilMvt_N2,'s')/3.6e3 , Data(PupilMvt_N2) , '.r')
plot(Range(PupilMvt_REM,'s')/3.6e3 , Data(PupilMvt_REM) , '.g')
xlabel('time (hours)'), ylabel('pupil movement (a.u.)')
legend('Wake','N1','N2','REM')
makepretty_BM2

bin_s = 50;

h=histogram(Data(PupilMvt_N1),'BinLimits',[0 .5],'NumBins',bin_s);
% HistData(1,:) = runmean(h.Values,3)/sum(h.Values);
HistData(1,:) = h.Values/sum(h.Values);
h=histogram(Data(PupilMvt_N2),'BinLimits',[0 .5],'NumBins',bin_s);
HistData(2,:) = h.Values/sum(h.Values);
% HistData(2,:) = runmean(h.Values,3)/sum(h.Values);
h=histogram(Data(PupilMvt_REM),'BinLimits',[0 .5],'NumBins',bin_s);
HistData(3,:) = h.Values/sum(h.Values);
% HistData(3,:) = runmean(h.Values,3)/sum(h.Values);
clf
                

figure
b=bar(linspace(0,1,bin_s) , HistData(1,:) , 'FaceColor' , [1 .5 0]); b.FaceAlpha = .5;
hold on
b=bar(linspace(0,1,bin_s) , HistData(2,:) , 'FaceColor' , 'r'); b.FaceAlpha = .5;
b=bar(linspace(0,1,bin_s) , HistData(3,:) , 'FaceColor' , 'g'); b.FaceAlpha = .5;
xlabel('pupil movement (a.u.)'), ylabel('PDF'), xlim([0 .8])
legend('N1','N2','REM')
makepretty





%% old
% 
% %%
% clear all
% 
% cd('/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230227/')
% load('DLC/DLC_data.mat', 'areas_pupil_tsd', 'pupil_mvt_tsd')
% load('SleepScoring_OBGamma.mat', 'Wake', 'SWSEpoch', 'REMEpoch')
% REMEpoch = mergeCloseIntervals(REMEpoch,60e4);
% REMEpoch = dropShortIntervals(REMEpoch,35e4);
% 
% smooth_PupilSize = tsd(Range(areas_pupil_tsd) , runmean(Data(areas_pupil_tsd),1e2));
% PupilSize_Wake = Restrict(smooth_PupilSize , Wake);
% PupilSize_NREM = Restrict(smooth_PupilSize , SWSEpoch);
% PupilSize_REM = Restrict(smooth_PupilSize , REMEpoch);
% 
% smooth_PupilMvt = tsd(Range(pupil_mvt_tsd) , runmean(Data(pupil_mvt_tsd),1e2));
% PupilMvt_Wake = Restrict(smooth_PupilMvt , Wake);
% PupilMvt_NREM = Restrict(smooth_PupilMvt , SWSEpoch);
% PupilMvt_REM = Restrict(smooth_PupilMvt , REMEpoch);
% 
% 
% figure
% subplot(2,5,1:4)
% plot(Range(PupilSize_Wake,'s')/3.6e3 , Data(PupilSize_Wake) , '.b')
% hold on
% plot(Range(PupilSize_NREM,'s')/3.6e3 , Data(PupilSize_NREM) , '.r')
% plot(Range(PupilSize_REM,'s')/3.6e3 , Data(PupilSize_REM) , '.g')
% ylabel('pupil size (a.u.)')
% box off
% legend('Wake','NREM','REM')
% 
% subplot(2,5,6:9)
% plot(Range(PupilMvt_Wake,'s')/3.6e3 , Data(PupilMvt_Wake) , '.b')
% hold on
% plot(Range(PupilMvt_NREM,'s')/3.6e3 , Data(PupilMvt_NREM) , '.r')
% plot(Range(PupilMvt_REM,'s')/3.6e3 , Data(PupilMvt_REM) , '.g')
% xlabel('time (hours)'), ylabel('pupil movement (a.u.)')
% box off
% 
% 
% subplot(255)
% h=histogram(Data(PupilSize_Wake),'BinLimits',[1,1500],'NumBins',75);
% h.FaceColor = [0 0 1]; h.FaceAlpha = .4;
% hold on
% h=histogram(Data(PupilSize_NREM),'BinLimits',[1,1500],'NumBins',75);
% h.FaceColor = [1 0 0]; h.FaceAlpha = .4;
% h=histogram(Data(PupilSize_REM),'BinLimits',[1,1500],'NumBins',75);
% h.FaceColor = [0 1 0]; h.FaceAlpha = .4;
% xlabel('pupil size (a.u.)'), ylabel('PDF')
% xlim([0 1500]), makepretty
% 
% subplot(2,5,10)
% h=histogram(Data(PupilMvt_Wake),'BinLimits',[0 .5],'NumBins',75);
% h.FaceColor = [0 0 1]; h.FaceAlpha = .4;
% hold on
% h=histogram(Data(PupilMvt_NREM),'BinLimits',[0 .5],'NumBins',75);
% h.FaceColor = [1 0 0]; h.FaceAlpha = .4;
% h=histogram([Data(PupilMvt_REM) ;Data(PupilMvt_REM) ;Data(PupilMvt_REM);Data(PupilMvt_REM);Data(PupilMvt_REM);Data(PupilMvt_REM);Data(PupilMvt_REM)],...
%     'BinLimits',[0 .5],'NumBins',75);
% h.FaceColor = [0 1 0]; h.FaceAlpha = .4;
% xlabel('pupil size (a.u.)'), ylabel('PDF')
% xlim([0 .5]), makepretty
% 
% subplot(2,5,10)
% [Y,X]=hist(Data(PupilMvt_Wake),1000);
% Y=Y/sum(Y);
% plot(X,runmean(Y,90),'b','LineWidth',2)
% hold on
% [Y,X]=hist(Data(PupilMvt_NREM),1000);
% Y=Y/sum(Y);
% plot(X,runmean(Y,90),'r','LineWidth',2)
% [Y,X]=hist(Data(PupilMvt_REM),1000);
% Y=Y/sum(Y);
% plot(X,runmean(Y,90),'g','LineWidth',2)
% xlabel('pupil movement (a.u.)'), ylabel('PDF')
% box off, xlim([0 1])
% 
% 



%% EMG drop
% cd('/media/nas7/React_Passive_AG/OBG/Brynza/freely-moving/20240124')
% load('LFPData/LFP4.mat')
% FilLFP = FilterLFP(LFP,[50 300],1024);
% EMGDataf = tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));
% 
% load('SleepScoring_OBGamma.mat', 'Wake', 'SWSEpoch', 'REMEpoch')
% EMG_Wake = Restrict(EMGDataf , Wake);
% EMG_NREM = Restrict(EMGDataf , SWSEpoch);
% EMG_REM = Restrict(EMGDataf , REMEpoch);
% 
% figure
% plot(Range(EMG_Wake,'s')/3600 , log10(Data(EMG_Wake)) , '.b')
% hold on
% plot(Range(EMG_NREM,'s')/3600 , log10(Data(EMG_NREM)) , '.r')
% plot(Range(EMG_REM,'s')/3600 , log10(Data(EMG_REM)) , '.g')
% 
% 
% figure
% [Y,X]=hist(log10(Data(EMG_Wake)),1000);
% Y=Y/sum(Y);
% plot(X,runmean(Y,10),'b','LineWidth',1)
% hold on
% [Y,X]=hist(log10(Data(EMG_NREM)),1000);
% Y=Y/sum(Y);
% plot(X,runmean(Y,10),'r','LineWidth',1)
% [Y,X]=hist(log10(Data(EMG_REM)),1000);
% Y=Y/sum(Y);
% plot(X,runmean(Y,10),'g','LineWidth',1)
% xlabel('EMG power (log scale)'), ylabel('PDF')
% box off, xlim([1.5 6])
% legend('Wake','NREM','REM')









