

clear all
% cd('/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230227/')
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241211_TORCs')

load('SleepScoring_OBGamma.mat', 'Clean_pupil_size')

smootime = 10;
load([pwd filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
FilGamma = FilterLFP(LFP,[50 75],1024);
hilbert_gamma = abs(hilbert(Data(FilGamma)));
SmoothGamma_wide = tsd(Range(LFP),runmean(hilbert_gamma,ceil(smootime/median(diff(Range(LFP,'s'))))));

FilGamma = FilterLFP(LFP,[40 60],1024);
hilbert_gamma = abs(hilbert(Data(FilGamma)));
SmoothGamma = tsd(Range(LFP),runmean(hilbert_gamma,ceil(smootime/median(diff(Range(LFP,'s'))))));



figure
plot(Range(Clean_pupil_size , 's') , zscore_nan(Data(Clean_pupil_size)))
hold on
plot(Range(SmoothGamma_wide , 's') , zscore_nan(Data(SmoothGamma_wide)))
plot(Range(SmoothGamma , 's') , zscore_nan(Data(SmoothGamma)))
xlabel('Time (s)'), ylabel('zscore')
legend('pupil size','Gamma 50-75Hz','Gamma 40-60')


load('B_Middle_Spectrum.mat')
load('SleepScoring_OBGamma.mat','Wake', 'ISEpoch', 'REMEpoch', 'SWSEpoch')
B_tsd = tsd(Spectro{2}*1e4 , log10(Spectro{1}));
B_Sp_Wake = Restrict(B_tsd , Wake);
B_Sp_NREM = Restrict(B_tsd , or(SWSEpoch , ISEpoch));
B_Sp_REM = Restrict(B_tsd , REMEpoch);


figure
plot(Spectro{3} , nanmean(Data(B_Sp_NREM)) , 'r')
hold on
plot(Spectro{3} , nanmean(Data(B_Sp_REM)) , 'g')
plot(Spectro{3} , nanmean(Data(B_Sp_Wake)) , 'b')
xlabel('Frequency (Hz)'), ylabel('Power (a.u.)')
legend('NREM','REM','Wake')



figure, imagesc(Spectro{2}/60 , Spectro{3} , log10(Spectro{1}')), axis xy




