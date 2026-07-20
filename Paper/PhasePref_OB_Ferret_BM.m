
function PhasePref_OB_Ferret_BM

load('SleepScoring_OBGamma.mat', 'Wake', 'SWSEpoch', 'REMEpoch', 'Epoch')

load('B_Middle_Spectrum.mat')
OB_High_Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
OB_High_Sptsd = Restrict(OB_High_Sptsd , Epoch);
OB_High_Sptsd_Wake = Restrict(OB_High_Sptsd , Wake);
OB_High_Sptsd_NREM = Restrict(OB_High_Sptsd , SWSEpoch);
OB_High_Sptsd_REM = Restrict(OB_High_Sptsd , REMEpoch);


load('LFPData/LFP8.mat')
LFP = Restrict(LFP , Epoch);
LFP_Wake = Restrict(LFP , Wake);
LFP_NREM = Restrict(LFP , SWSEpoch);
LFP_REM = Restrict(LFP , REMEpoch);

D=Data(OB_High_Sptsd); D=D(:,13:end);
[P,f,VBinnedPhase]=PrefPhaseSpectrum(LFP , D , Range(OB_High_Sptsd,'s') , Spectro{3}(13:end) , [2 6] , 30); close


figure
imagesc([VBinnedPhase VBinnedPhase+360] , f , log10([P' P'])); axis xy
xlabel('Phase (degrees)'), ylabel('Frequency(Hz)')
makepretty
caxis([2.5 3])
title('Wake')


%% OB High on 2-6Hz

figure
clear D P f VBinnedPhase
D=Data(OB_High_Sptsd_Wake); D=D(:,13:end);
[P,f,VBinnedPhase,L]=PrefPhaseSpectrum_BM(LFP_Wake , D , Range(OB_High_Sptsd_Wake,'s') , Spectro{3}(13:end) , [2 6] , 30); close

subplot(131)
imagesc([VBinnedPhase VBinnedPhase+360] , f , log10([P' P'])); axis xy, hold on
xlabel('Phase (degrees)'), ylabel('Frequency(Hz)')
makepretty
plot([VBinnedPhase VBinnedPhase+360] , [((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2)) ((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2))] , 'k', 'LineWidth' , 2)
% caxis([2.5 3.7])
title('Wake')


clear D P f VBinnedPhase
D=Data(OB_High_Sptsd_NREM); D=D(:,13:end);
[P,f,VBinnedPhase,L]=PrefPhaseSpectrum_BM(LFP_NREM , D , Range(OB_High_Sptsd_NREM,'s') , Spectro{3}(13:end) , [2 6] , 30); close

subplot(132)
imagesc([VBinnedPhase VBinnedPhase+360] , f , log10([P' P'])); axis xy, hold on
xlabel('Phase (degrees)'), ylabel('Frequency(Hz)')
makepretty
plot([VBinnedPhase VBinnedPhase+360] , [((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2)) ((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2))] , 'k', 'LineWidth' , 2)
% caxis([2.3 2.7])
title('NREM')


clear D P f VBinnedPhase
D=Data(OB_High_Sptsd_REM); D=D(:,13:end);
[P,f,VBinnedPhase,L]=PrefPhaseSpectrum_BM(LFP_REM , D , Range(OB_High_Sptsd_REM,'s') , Spectro{3}(13:end) , [2 6] , 30); close

subplot(133)
imagesc([VBinnedPhase VBinnedPhase+360] , f , log10([P' P'])); axis xy, hold on
xlabel('Phase (degrees)'), ylabel('Frequency(Hz)')
makepretty
plot([VBinnedPhase VBinnedPhase+360] , [((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2)) ((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2))] , 'k', 'LineWidth' , 2)
% caxis([2.2 2.8])
title('REM')




%% OB High on .1-.5Hz
figure
clear D P f VBinnedPhase
D=Data(OB_High_Sptsd_Wake); D=D(:,13:end);
[P,f,VBinnedPhase,L]=PrefPhaseSpectrum_BM(LFP_Wake , D , Range(OB_High_Sptsd_Wake,'s') , Spectro{3}(13:end) , [.1 .5] , 30); close


subplot(131)
imagesc([VBinnedPhase VBinnedPhase+360] , f , log10([P' P'])); axis xy, hold on
xlabel('Phase (degrees)'), ylabel('Frequency(Hz)')
makepretty
plot([VBinnedPhase VBinnedPhase+360] , [((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2)) ((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2))] , 'k', 'LineWidth' , 2)
% caxis([2.5 3.7])
title('Wake')


clear D P f VBinnedPhase
D=Data(OB_High_Sptsd_NREM); D=D(:,13:end);
[P,f,VBinnedPhase,L]=PrefPhaseSpectrum_BM(LFP_NREM , D , Range(OB_High_Sptsd_NREM,'s') , Spectro{3}(13:end) , [.1 .5] , 30); close

subplot(132)
imagesc([VBinnedPhase VBinnedPhase+360] , f , log10([P' P'])); axis xy, hold on
xlabel('Phase (degrees)'), ylabel('Frequency(Hz)')
makepretty
plot([VBinnedPhase VBinnedPhase+360] , [((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2)) ((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2))] , 'k', 'LineWidth' , 2)
% caxis([2.3 2.7])
title('NREM')


clear D P f VBinnedPhase
D=Data(OB_High_Sptsd_REM); D=D(:,13:end);
[P,f,VBinnedPhase,L]=PrefPhaseSpectrum_BM(LFP_REM , D , Range(OB_High_Sptsd_REM,'s') , Spectro{3}(13:end) , [.1 .5] , 30); close

subplot(133)
imagesc([VBinnedPhase VBinnedPhase+360] , f , log10([P' P'])); axis xy, hold on
xlabel('Phase (degrees)'), ylabel('Frequency(Hz)')
makepretty
plot([VBinnedPhase VBinnedPhase+360] , [((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2)) ((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2))] , 'k', 'LineWidth' , 2)
% caxis([2.2 2.8])
title('REM')




%% OB Low on .1-.5Hz
load('B_Low_Spectrum.mat')
OB_Low_Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
OB_Low_Sptsd = Restrict(OB_Low_Sptsd , Epoch);
OB_Low_Sptsd_Wake = Restrict(OB_Low_Sptsd , Wake);
OB_Low_Sptsd_NREM = Restrict(OB_Low_Sptsd , SWSEpoch);
OB_Low_Sptsd_REM = Restrict(OB_Low_Sptsd , REMEpoch);



figure
clear D P f VBinnedPhase
D=Data(OB_Low_Sptsd_Wake); D=D(:,13:end);
[P,f,VBinnedPhase,L]=PrefPhaseSpectrum_BM(LFP_Wake , D , Range(OB_Low_Sptsd_Wake,'s') , Spectro{3}(13:end) , [.1 .5] , 30); close


subplot(131)
imagesc([VBinnedPhase VBinnedPhase+360] , f , log10([P' P'])); axis xy, hold on
xlabel('Phase (degrees)'), ylabel('Frequency(Hz)')
makepretty
plot([VBinnedPhase VBinnedPhase+360] , [((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2)) ((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2))] , 'k', 'LineWidth' , 2)
% caxis([2.5 3.7])
title('Wake')


clear D P f VBinnedPhase
D=Data(OB_Low_Sptsd_NREM); D=D(:,13:end);
[P,f,VBinnedPhase,L]=PrefPhaseSpectrum_BM(LFP_NREM , D , Range(OB_Low_Sptsd_NREM,'s') , Spectro{3}(13:end) , [.1 .5] , 30); close

subplot(132)
imagesc([VBinnedPhase VBinnedPhase+360] , f , log10([P' P'])); axis xy, hold on
xlabel('Phase (degrees)'), ylabel('Frequency(Hz)')
makepretty
plot([VBinnedPhase VBinnedPhase+360] , [((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2)) ((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2))] , 'k', 'LineWidth' , 2)
% caxis([2.3 2.7])
title('NREM')


clear D P f VBinnedPhase
D=Data(OB_Low_Sptsd_REM); D=D(:,13:end);
[P,f,VBinnedPhase,L]=PrefPhaseSpectrum_BM(LFP_REM , D , Range(OB_Low_Sptsd_REM,'s') , Spectro{3}(13:end) , [.1 .5] , 30); close

subplot(133)
imagesc([VBinnedPhase VBinnedPhase+360] , f , log10([P' P'])); axis xy, hold on
xlabel('Phase (degrees)'), ylabel('Frequency(Hz)')
makepretty
plot([VBinnedPhase VBinnedPhase+360] , [((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2)) ((L'-min(L))/max(L))*(max(f)*.1)+f(round(length(f)/2))] , 'k', 'LineWidth' , 2)
% caxis([2.2 2.8])
title('REM')


