

clear all

%% initialization
Dir{1} = PathForExperimentsOB({'Shropshire'}, 'head-fixed', 'saline');

drug=1; sess=2; 
load([Dir{drug}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SmoothGamma', 'inj_time')
load([Dir{drug}.path{sess} filesep 'behavResources.mat'], 'MovAcctsd')
load([Dir{drug}.path{sess} filesep 'HeartBeatInfo.mat'])

smooth_time = 5;
smooth_time2 = 40;


%% collect data
R = Range(EKG.HBRate); D = Data(EKG.HBRate); R(D>5.5) = []; D(D>5.5) = []; 
Smooth_HR = tsd(R , movmean(D , ceil(smooth_time2/median(diff(Range(EKG.HBRate,'s')))) , 'omitnan'));
bin_size = median(diff(Range(EKG.HBRate)))/1e4;

Epoch = or(intervalSet(10*60e4,80*60e4),intervalSet(115*60e4,180*60e4));
Smooth_HR = Restrict(Smooth_HR , Epoch);

SmoothGamma_bis = Restrict(SmoothGamma , Smooth_HR);
Smooth_Gamma = tsd(Range(SmoothGamma_bis) , movmean(log10(Data(SmoothGamma_bis)) , ceil(smooth_time/median(diff(Range(SmoothGamma_bis,'s')))) , 'omitnan'));

[c,lags] = xcorr(zscore(log10(Data(Smooth_Gamma))) , zscore(Data(Smooth_HR)));

figure
subplot(211)
plot(linspace(0,length(Smooth_Gamma)*bin_size,length(Smooth_Gamma))/60 , zscore(log10(Data(Smooth_Gamma))) , '-k')
makepretty
ylabel('OB gamma power (log scale)'); 
yyaxis right
plot(linspace(0,length(Smooth_Gamma)*bin_size,length(Smooth_Gamma))/60 , zscore(Data(Smooth_HR)) , '-r')
makepretty
xlabel('time (min)'), ylabel('HR (zscore)'), xlim([0 122])

subplot(246)
% X = runmean(zscore(log10(Data(Smooth_Gamma))),100);
X = zscore(log10(Data(Smooth_Gamma)));
% Y = runmean(zscore(Data(Smooth_HR)),100);
Y = zscore(Data(Smooth_HR));
PlotCorrelations_BM(X(1:1e2:end), Y(1:1e2:end))
xlabel('OB gamma power (log scale)'), ylabel('HR (Hz)'), 
axis square
makepretty_BM2

subplot(247)
plot(lags*bin_size/60,c,'k')
xlim([-10 10]), ylim([-.6e4 1.2e4]), xlabel('time (min)'), ylabel('corr values')
makepretty
vline(0,'--r')


