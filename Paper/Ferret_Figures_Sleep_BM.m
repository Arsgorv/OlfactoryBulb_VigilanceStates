
%% Basic verifs compared Labneh : OB gamma & EMG high power


load('SleepScoring_OBGamma.mat', 'Epoch')
smootime=3;

load('ChannelsToAnalyse/EMG.mat', 'channel')
load(['LFPData/LFP' num2str(channel) '.mat'])

LFP = Restrict(LFP, Epoch);
FilLFP=FilterLFP(LFP,[50 300],1024);
EMGData=tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));

load('behavResources.mat', 'MovAcctsd')
MovAcctsd = Restrict(MovAcctsd, Epoch);
MovAcctsd=tsd(Range(MovAcctsd),runmean(Data((MovAcctsd)).^2,ceil(smootime/median(diff(Range(MovAcctsd,'s'))))));



load('SleepScoring_OBGamma.mat', 'SmoothGamma')
SmoothGamma=Restrict(SmoothGamma,Epoch);
SmoothGamma_int = Restrict(SmoothGamma,EMGData);
SmoothGamma_int2 = Restrict(SmoothGamma,MovAcctsd);


figure
% with EMG power
clear X Y
X = log10(Data(SmoothGamma_int)); Y = log10(Data(EMGData)); 

subplot(121)
plot(X(1:1000:end) , Y(1:1000:end) , '.k')
xlabel('OB gamma power (log scale)'); ylabel('EMG power (log scale)');
axis square
vline(2.2,'-r'), hline(3.6,'-r')
 
[gamma_thresh] = GetGammaThresh(Data(EMGData));
Sleep_EMG = thresholdIntervals(EMGData , exp(gamma_thresh) , 'Direction' , 'Below');
sum(DurationEpoch(and(Sleep_EMG , Epoch) , and(Sleep , Epoch)))/sum(DurationEpoch(and(Sleep_EMG , Epoch)))
sum(DurationEpoch(and(Sleep_EMG , Epoch) , and(Sleep , Epoch)))/sum(DurationEpoch(and(Sleep , Epoch)))

title('Overlap = 96%')


% with accelerometer
clear X Y
X = log10(Data(SmoothGamma_int2)); Y = log10(Data(MovAcctsd)); 

subplot(122)
plot(X(1:100:end) , Y(1:100:end) , '.k')
xlabel('OB gamma power (log scale)'); ylabel('Motion (log scale)');
axis square
vline(2.2,'-r'), hline(13.5,'-r')

[gamma_thresh] = GetGammaThresh(Data(MovAcctsd));
Sleep_Acc = thresholdIntervals(MovAcctsd , exp(gamma_thresh) , 'Direction' , 'Below');
sum(DurationEpoch(and(Sleep_Acc , Epoch) , and(Sleep , Epoch)))/sum(DurationEpoch(and(Sleep_Acc , Epoch)))
sum(DurationEpoch(and(Sleep_Acc , Epoch) , and(Sleep , Epoch)))/sum(DurationEpoch(and(Sleep , Epoch)))

title('Overlap = 95%')




%% show differents signals on OB channels
% Power 
Power_Distributions_Channels_BM([8:11])
Power_Distributions_Channels_BM([16:19])
Power_Distributions_Channels_BM([20:23])
Power_Distributions_Channels_BM([13:15 25:26])
Power_Distributions_Channels_BM([0:2])


load('SleepScoring_OBGamma.mat', 'Epoch', 'Wake', 'REMEpoch', 'SWSEpoch')
smootime=3;

load('LFPData/LFP10.mat')
LFP = Restrict(LFP , Epoch);
Fil = FilterLFP(LFP,[40 60],1024);
Enveloppe = tsd(Range(LFP), abs(hilbert(Data(Fil))) );
SmoothGamma = tsd(Range(Enveloppe), runmean(Data(Enveloppe), ...
    ceil(smootime/median(diff(Range(Enveloppe,'s'))))));
load('LFPData/LFP21.mat')
LFP = Restrict(LFP , Epoch);
Fil = FilterLFP(LFP,[2 6],1024);
Enveloppe = tsd(Range(LFP), abs(hilbert(Data(Fil))) );
SmoothTheta = tsd(Range(Enveloppe), runmean(Data(Enveloppe), ...
    ceil(smootime/median(diff(Range(Enveloppe,'s'))))));
load('LFPData/LFP10.mat')
LFP = Restrict(LFP , Epoch);
Fil = FilterLFP(LFP,[.15 1],1024);
Enveloppe = tsd(Range(LFP), abs(hilbert(Data(Fil))) );
SmoothUL = tsd(Range(Enveloppe), runmean(Data(Enveloppe), ...
    ceil(smootime/median(diff(Range(Enveloppe,'s'))))));



figure
subplot(131)
[Y,X]=hist(log(Data(Restrict(SmoothGamma , Wake))),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'b')
hold on
[Y,X]=hist(log(Data(Restrict(SmoothGamma , SWSEpoch))),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'r')
[Y,X]=hist(log(Data(Restrict(SmoothGamma , REMEpoch))),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'g')
makepretty
xlabel('Power (log scale)'), ylabel('#')
legend('Wake','NREM','REM')
title('OB Gamma')


subplot(132)
[Y,X]=hist(log(Data(Restrict(SmoothTheta , Wake))),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'b')
hold on
[Y,X]=hist(log(Data(Restrict(SmoothTheta , SWSEpoch))),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'r')
[Y,X]=hist(log(Data(Restrict(SmoothTheta , REMEpoch))),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'g')
makepretty
xlabel('Power (log scale)'), ylabel('#')
legend('Wake','NREM','REM')
title('HPC Theta')


subplot(133)
[Y,X]=hist(log(Data(Restrict(SmoothUL , Wake))),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'b')
hold on
[Y,X]=hist(log(Data(Restrict(SmoothUL , SWSEpoch))),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'r')
[Y,X]=hist(log(Data(Restrict(SmoothUL , REMEpoch))),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'g')
makepretty
xlabel('Power (log scale)'), ylabel('#')
legend('Wake','NREM','REM')
title('OB Ultra Low')

a=sgtitle('Power distribution, Brynza, freely moving session'); a.FontSize=20;

% Frequency
MeanSpectrums_Channels_Ferret_BM


%% Oscillations correlations
CorrelationMatrix_Ferret_BM


%% PhasePref
PhasePref_OB_Ferret_BM


% see UltraLowOB_Study_Ferret_BM.m for more
%% Correlations 
load('SleepScoring_OBGamma.mat', 'Epoch', 'REMEpoch', 'SWSEpoch', 'Wake', 'smooth_01_05', 'SmoothTheta')
load(['LFPData/LFP1.mat'])
LFP = Restrict(LFP , Epoch);
FilDelta = FilterLFP(LFP,[.5 2],1024); % filtering
H = abs(hilbert(Data(FilDelta))); H(H>200)=200;
tEnveloppeDelta = tsd(Range(LFP), H); %tsd: hilbert transform then enveloppe
smootime=10;
SmoothDelta = tsd(Range(tEnveloppeDelta), runmean(Data(tEnveloppeDelta),ceil(smootime/median(diff(Range(tEnveloppeDelta,'s'))))));


figure
subplot(121)
clear D1 D2
smooth_01_05_corr = Restrict(smooth_01_05,SmoothDelta);
D1 = log10(Data(Restrict(smooth_01_05_corr,SWSEpoch)));
D2 = log10(Data(Restrict(SmoothDelta,SWSEpoch)));
bin=20000;
PlotCorrelations_BM(D1(1:bin:end)' , D2(1:bin:end)')
xlabel('0.1-0.5 power, Bulb (a.u.)'), ylabel('delta power, cortex (a.u.)')
axis square

subplot(122)
imagesc(SmoothDec(hist2d(D1,D2,30,30)',.7)); axis xy, axis square
xlabel('0.1-0.5 power, Bulb (a.u.)'), ylabel('delta power, cortex (a.u.)')

a=suptitle('Delta power, Cortex  = f(ultra low power, Bulb), SWS'); a.FontSize=20;



%% Ultra low rhythm and deepness of sleep
load('SleepScoring_OBGamma.mat', 'Epoch', 'REMEpoch')
smootime=10;
NREM = load('SleepSubstages.mat');
load('LFPData/LFP8.mat')
LFP = Restrict(LFP , Epoch);
Fil = FilterLFP(LFP,[.15 1],1024);
Enveloppe = tsd(Range(LFP), abs(hilbert(Data(Fil))) );
SmoothUL = tsd(Range(Enveloppe), runmean(Data(Enveloppe), ...
    ceil(smootime/median(diff(Range(Enveloppe,'s'))))));


SmoothUL_N1 = Restrict(SmoothUL , NREM.Epoch{1});
SmoothUL_N2 = Restrict(SmoothUL , NREM.Epoch{2});
SmoothUL_N3 = Restrict(SmoothUL , NREM.Epoch{3});

SmoothUL_REM = Restrict(SmoothUL , REMEpoch);


figure
[Y,X]=hist(log10(Data(SmoothUL_N1)),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'Color' , [1 .5 .5])
hold on
[Y,X]=hist(log10(Data(SmoothUL_N2)),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'Color' , [1 0 0])
[Y,X]=hist(log10(Data(SmoothUL_N3)),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'Color' , [.7 0 0])
makepretty
legend('N1','N2','N3')
xlabel('Power (a.u.)'), ylabel('#')


figure
[Y,X]=hist(log10(Data(SmoothUL_REM)),100);
Y=Y/sum(Y);
plot(X,runmean(Y,3),'g')
hold on



