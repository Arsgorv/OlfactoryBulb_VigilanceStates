

%% Gamma OB/PFC lag
cd('/media/nas7/React_Passive_AG/OBG/Brynza/freely-moving/20240202_saline')
load('SleepScoring_OBGamma.mat', 'Wake')

load('LFPData/LFP11.mat')
FilGamma = FilterLFP(LFP,[40 60],1024);
tEnveloppeGamma = tsd(Range(LFP), abs(hilbert(Data(FilGamma))) ); 
smootime=.06;
SmoothGamma_OB = tsd(Range(tEnveloppeGamma), runmean(Data(tEnveloppeGamma), ...
    ceil(smootime/median(diff(Range(tEnveloppeGamma,'s'))))));

load('LFPData/LFP13.mat')
FilGamma = FilterLFP(LFP,[40 60],1024);
tEnveloppeGamma = tsd(Range(LFP), abs(hilbert(Data(FilGamma))) ); 
SmoothGamma_PFC = tsd(Range(tEnveloppeGamma), runmean(Data(tEnveloppeGamma), ...
    ceil(smootime/median(diff(Range(tEnveloppeGamma,'s'))))));

SmoothGamma_OB_Wake = Restrict(SmoothGamma_OB , Wake);
[c,lags] = xcorr(zscore(Data(SmoothGamma_OB_Wake)) , zscore(Data(Restrict(SmoothGamma_PFC,SmoothGamma_OB_Wake))) , 1250 , 'biased');

figure
plot(linspace(-1,1,2501) , c , 'b' , 'LineWidth' , 2)
xlabel('lag (s)'), ylabel('Corr values (a.u.)'), xlim([-1 1])
box off
vline(0,'--r')









