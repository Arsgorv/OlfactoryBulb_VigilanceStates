

clear all

datapath = '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs/';
smootime = 10;
LineHeight = 9.5;
Colors.IS = [1 .5 0];
Colors.SWS = [1 0 0];
Colors.REM = 'g';
Colors.Wake = 'b';
Colors.Noise = 'k';


%% spectro
B1 = load([datapath filesep 'B_Middle_Spectrum.mat']);
B_High_Sptsd = tsd(B1.Spectro{2}*1e4 , B1.Spectro{1});
Range_Mid = B1.Spectro{3};

H = load([datapath filesep 'H_Low_Spectrum.mat']);
H_Sptsd = tsd(H.Spectro{2}*1e4 , H.Spectro{1});

B2 = load([datapath filesep 'B_Low_Spectrum.mat']);
B_Low_Sptsd = tsd(B2.Spectro{2}*1e4 , B2.Spectro{1});

load([datapath filesep 'SleepScoring_OBGamma.mat'])


%% figures
figure
subplot(611) % OB High
clear D R, D = Data(B_High_Sptsd); D = D(1:100:end,:); R = Range(B_High_Sptsd); R = R(1:100:end);
imagesc(R/3.6e7 , B1.Spectro{3} , runmean(runmean(log10(D'),2)',10)'), axis xy
ylabel('OB frequency (Hz)')
colormap viridis, ylim([20 100]), caxis([2.1 3.6]), xticklabels({''}), box off

PlotPerAsLine(Wake,97,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,97,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(ISEpoch,97,Colors.IS,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(SWSEpoch,97,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(612)
clear D R, D = movmean(Data(SmoothGamma),1e4,'omitnan'); D(D>800) = NaN; D = D(1:100:end); R = Range(SmoothGamma); R = R(1:100:end);
plot(R/3.6e7 , D , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)]),  ylim([0 900]), xticklabels({''})
box off
ylabel('OB Gamma power')


subplot(613) % HPC 
imagesc(Range(H_Sptsd)/3.6e7 , H.Spectro{3} , runmean(runmean(log10(Data(H_Sptsd)'),5)',50)'), axis xy
ylabel('HPC Frequency (Hz)'), ylim([0 10]), caxis([3.5 5.4]), xticklabels({''}), box off

PlotPerAsLine(Wake,9.5,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,9.5,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(ISEpoch,9.5,Colors.IS,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(SWSEpoch,9.5,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(614)
clear R D, D = movmean(Data(SmoothTheta),1e4,'omitnan'); D(D>14.5) = NaN; D = D(1:100:end); R = Range(SmoothTheta); R = R(1:100:end);
plot(R/3.6e7 , D , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)]), ylim([0 8])
box off
ylabel('HPC Theta/Delta'), xticklabels({''})


subplot(615) % OB Low 
imagesc(Range(B_Low_Sptsd)/3.6e7 , B2.Spectro{3} , runmean(runmean(log10(Data(B_Low_Sptsd)'),5)',50)'), axis xy
ylabel('OB Frequency (Hz)'), ylim([0 10]), xticklabels({''}), box off
caxis([3.5 4.4])

PlotPerAsLine(Wake,LineHeight,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,LineHeight,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(ISEpoch,LineHeight,Colors.IS,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(SWSEpoch,LineHeight,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(616)
CleanSleep = Sleep-intervalSet([1.485 3.3 3.985]*3.6e7,[1.495 3.345 4.04]*3.6e7);
clear R D, D = movmean(Data(Restrict(SmoothDelta_OB , CleanSleep)),1e4,'omitnan'); D(D>700) = NaN; D = D(1:100:end); R = Range(Restrict(SmoothDelta_OB , CleanSleep)); R = R(1:100:end);
plot(R/3.6e7 , D , '.k' , 'MarkerSize',2)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)]), ylim([80 750])
box off
xlabel('Time (s)'), ylabel('OB Delta power')



%% zoom on a zone of interest
figure
subplot(611) % OB High
clear D R, D = Data(B_High_Sptsd); D = D(1:100:end,:); R = Range(B_High_Sptsd); R = R(1:100:end);
imagesc(R/3.6e7 , B1.Spectro{3} , runmean(runmean(log10(D'),2)',10)'), axis xy
ylabel('OB frequency (Hz)')
colormap viridis, ylim([20 100]), caxis([2.1 3.6]), xticklabels({''}), box off
xlim([2.55 2.9])

PlotPerAsLine(Wake,97,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,97,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(ISEpoch,97,Colors.IS,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(SWSEpoch,97,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(612)
clear D R, D = movmean(Data(SmoothGamma),1e4,'omitnan'); D(D>800) = NaN; D = D(1:100:end); R = Range(SmoothGamma); R = R(1:100:end);
plot(R/3.6e7 , D , 'k' , 'LineWidth',2)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)]),  ylim([0 900]), xticklabels({''})
box off
ylabel('OB Gamma power')
xlim([2.55 2.9])


subplot(613) % HPC 
imagesc(Range(H_Sptsd)/3.6e7 , H.Spectro{3} , runmean(runmean(log10(Data(H_Sptsd)'),5)',50)'), axis xy
ylabel('HPC Frequency (Hz)'), ylim([0 10]), caxis([3.5 5]), xticklabels({''}), box off
xlim([2.55 2.9])

PlotPerAsLine(Wake,9.5,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,9.5,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(ISEpoch,9.5,Colors.IS,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(SWSEpoch,9.5,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(614)
clear R D, D = movmean(Data(SmoothTheta),1e4,'omitnan'); D(D>14.5) = NaN; D = D(1:100:end); R = Range(SmoothTheta); R = R(1:100:end);
plot(R/3.6e7 , D , 'k' , 'LineWidth',2)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)]), ylim([0 15])
box off
ylabel('HPC Theta/Delta'), xticklabels({''})
xlim([2.55 2.9])


subplot(615) % OB Low 
imagesc(Range(B_Low_Sptsd)/3.6e7 , B2.Spectro{3} , runmean(runmean(log10(Data(B_Low_Sptsd)'),5)',50)'), axis xy
ylabel('OB Frequency (Hz)'), ylim([0 10]), xticklabels({''}), caxis([3.5 4.8]), xlim([2.55 2.9]), box off

PlotPerAsLine(Wake,LineHeight,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,LineHeight,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(ISEpoch,LineHeight,Colors.IS,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(SWSEpoch,LineHeight,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(616)
CleanSleep = Sleep-intervalSet([1.485 3.3 3.985]*3.6e7,[1.495 3.345 4.04]*3.6e7);
clear R D, D = movmean(Data(Restrict(SmoothDelta_OB , CleanSleep)),1e4,'omitnan'); D(D>700) = NaN; D = D(1:100:end); R = Range(Restrict(SmoothDelta_OB , CleanSleep)); R = R(1:100:end);
plot(R/3.6e7 , movmean(D , 250) , 'k' , 'MarkerSize',2 , 'LineWidth' , 2)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)]), ylim([150 750])
box off
xlabel('Time (s)'), ylabel('OB Delta power'), xticklabels({''})
xlim([2.55 2.9])



