

%% illustration of sleep scoring
% initialization
Colors.SWS = 'r';
Colors.REM = 'g';
Colors.Wake = 'b';
LineHeight = 9.5;
Colors.Noise = [0 0 0];
smootime = 10;

% load and generate data
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20250103_LSP_saline')
load('SleepScoring_OBGamma.mat', 'Wake', 'REMEpoch', 'SWSEpoch', 'SmoothTheta', 'SmoothGamma', 'Sleep', 'Info')
REMEpoch = mergeCloseIntervals(REMEpoch,25e4);
REMEpoch = dropShortIntervals(REMEpoch,25e4);


load('ChannelsToAnalyse/Bulb_deep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
LFP = tsd(Range(LFP) , Data(LFP));
Fil_Delta = FilterLFP(Restrict(LFP , Sleep),[.5 4],1024);
tEnveloppe = tsd(Range(Fil_Delta), abs(hilbert(Data(Fil_Delta))) );
SmoothDelta_OB  = tsd(Range(tEnveloppe), runmean(Data(tEnveloppe), ...
    ceil(smootime/median(diff(Range(tEnveloppe,'s'))))));


N2 = thresholdIntervals(SmoothDelta_OB , 10^2.62 , 'Direction' , 'Above');
N2 = mergeCloseIntervals(N2,5e4);
N2 = dropShortIntervals(N2,10e4);
N1 = SWSEpoch-N2;

Dur_NREM = sum(DurationEpoch(SWSEpoch))/3600e4;
Dur_REM = sum(DurationEpoch(REMEpoch))/3600e4;
Dur_N1 = sum(DurationEpoch(N1))/3600e4;
Dur_N2 = sum(DurationEpoch(N2))/3600e4;



H = load('H_Low_Spectrum.mat');
H_Sptsd = tsd(H.Spectro{2}*1e4 , H.Spectro{1});
[H_Sptsd_clean,~,~] = CleanSpectro(H_Sptsd , H.Spectro{3} , 5);
H_NREM = Restrict(H_Sptsd , SWSEpoch);
H_REM = Restrict(H_Sptsd , REMEpoch);
H_N1 = Restrict(H_Sptsd , N1);
H_N2 = Restrict(H_Sptsd , N2);

B = load('B_Low_Spectrum.mat');
B_Sptsd = tsd(B.Spectro{2}*1e4 , B.Spectro{1});
[B_Sptsd_clean,~,EpochClean] = CleanSpectro(B_Sptsd , H.Spectro{3} , 5);
B_NREM = Restrict(B_Sptsd , SWSEpoch);
B_REM = Restrict(B_Sptsd , REMEpoch);
B_N1 = Restrict(B_Sptsd , N1);
B_N2 = Restrict(B_Sptsd , N2);

% scoring based on distrib and thresholding
figure
subplot(131)
[Y,X]=hist(log10(Data(SmoothGamma)),1000);
Y=runmean(Y,5)/sum(Y);
plot(X,runmean(Y,5) , 'k')
xlabel('OB gamma power (log)'), ylabel('PDF'), xlim([1.9 3]), ylim([0 8.2e-3])
v=vline(log10(Info.gamma_thresh),'-r'); v.LineWidth=5;
makepretty

subplot(132)
[Y,X]=hist(log10(Data(Restrict(SmoothTheta, Sleep))),1000);
Y=runmean(Y,5)/sum(Y);
plot(X,runmean(Y,5) , 'k')
xlabel('HPC theta power (log)'), ylabel('PDF'), xlim([-.55 1.15]), ylim([0 3e-3])
v=vline(log10(Info.theta_thresh),'-r'); v.LineWidth=5;
makepretty

subplot(133)
[Y,X]=hist(log10(Data(Restrict(SmoothDelta_OB, SWSEpoch))),1000);
Y=runmean(Y,5)/sum(Y);
plot(X,runmean(Y,5) , 'k')
xlabel('OB delta power (log)'), ylabel('PDF'), xlim([2.38 3]), ylim([0 6e-3])
v=vline(2.62,'-r'); v.LineWidth=5;
makepretty




%% spectrograms
figure
subplot(421)
imagesc(Range(H_Sptsd)/3.6e7 , H.Spectro{3} , runmean(runmean(log10(Data(H_Sptsd)'),2)',100)'), axis xy
ylabel('Frequency_a_l_l (Hz)')
colormap jet, ylim([0 10]), hline([4 6],'--r'), caxis([3 5])
PlotPerAsLine(Wake,LineHeight,Colors.Wake,'timescaling',3.6e7);
PlotPerAsLine(SWSEpoch,LineHeight,Colors.SWS,'timescaling',3.6e7);
PlotPerAsLine(REMEpoch,LineHeight,Colors.REM,'timescaling',3.6e7);
title('HPC')
makepretty_BM2

subplot(423)
imagesc(linspace(0,Dur_REM,length(H_REM)) , H.Spectro{3} , runmean(runmean(log10(Data(H_REM)'),2)',100)'), axis xy
ylabel('Frequency_R_E_M (Hz)')
colormap jet, ylim([0 10]), hline([4 6],'--r'), caxis([3 5])
makepretty_BM2

subplot(425)
imagesc(linspace(0,Dur_N1,length(H_N1)) , H.Spectro{3} , runmean(runmean(log10(Data(H_N1)'),2)',100)'), axis xy
ylabel('Frequency_N_1 (Hz)')
colormap jet, ylim([0 10]), hline([4 6],'--r'), caxis([3 5])
makepretty_BM2

subplot(427)
imagesc(linspace(0,Dur_N2,length(H_N2)) , H.Spectro{3} , runmean(runmean(log10(Data(H_N2)'),2)',100)'), axis xy
ylabel('Frequency_N_2 (Hz)')
colormap jet, ylim([0 10]), hline([4 6],'--r'), caxis([3 5])
makepretty_BM2


subplot(422)
imagesc(Range(B_Sptsd)/3.6e7 , B.Spectro{3} , runmean(runmean(log10(Data(B_Sptsd)'),2)',100)'), axis xy
ylabel('Frequency_a_l_l (Hz)')
colormap jet, ylim([0 10]), hline([4 6],'--r'), caxis([3 5])
PlotPerAsLine(Wake,LineHeight,Colors.Wake,'timescaling',3.6e7);
PlotPerAsLine(SWSEpoch,LineHeight,Colors.SWS,'timescaling',3.6e7);
PlotPerAsLine(REMEpoch,LineHeight,Colors.REM,'timescaling',3.6e7);
title('OB')
makepretty_BM2

subplot(424)
imagesc(linspace(0,Dur_REM,length(B_REM)) , B.Spectro{3} , runmean(runmean(log10(Data(B_REM)'),2)',100)'), axis xy
ylabel('Frequency_R_E_M (Hz)')
colormap jet, ylim([0 10]), hline([4 6],'--r'), caxis([3 5])
makepretty_BM2

subplot(426)
imagesc(linspace(0,Dur_N1,length(B_N1)) , B.Spectro{3} , runmean(runmean(log10(Data(B_N1)'),2)',100)'), axis xy
ylabel('Frequency_N_1 (Hz)')
colormap jet, ylim([0 10]), hline([4 6],'--r'), caxis([3 5])
makepretty_BM2

subplot(428)
imagesc(linspace(0,Dur_N2,length(B_N2)) , B.Spectro{3} , runmean(runmean(log10(Data(B_N2)'),2)',100)'), axis xy
ylabel('Frequency_N_2 (Hz)')
colormap jet, ylim([0 10]), hline([4 6],'--r'), caxis([3 5])
makepretty_BM2


