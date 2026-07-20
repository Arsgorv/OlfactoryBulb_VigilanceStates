

%% Furet analysis
% Generate spectrograms
for channel=24:29
    LowSpectrumSB([cd filesep],channel,'B')
    movefile('B_Low_Spectrum.mat',['B_Low_Spectrum_' num2str(channel) '.mat'])
    MiddleSpectrum_BM([cd filesep],channel,'B')
    movefile('B_Middle_Spectrum.mat',['B_Middle_Spectrum_' num2str(channel) '.mat'])
    HighSpectrum([cd filesep],channel,'B');
    movefile('B_High_Spectrum.mat',['B_High_Spectrum_' num2str(channel) '.mat'])
end

% Transform spectrograms into tsd
Channel={'Numb25','Numb26','Numb27','Numb28'}; i=1;
for channel=25:28
    
    load(['B_Low_Spectrum_' num2str(channel) '.mat'])
    OB_Low_Sp_tsd.(Channel{i}) = tsd(Spectro{2}*1e4 , Spectro{1});
    load(['B_Middle_Spectrum_' num2str(channel) '.mat'])
    OB_Middle_Sp_tsd.(Channel{i}) = tsd(Spectro{2}*1e4 , Spectro{1});
    load(['B_High_Spectrum_' num2str(channel) '.mat'])
    OB_High_Sp_tsd.(Channel{i}) = tsd(Spectro{2}*1e4 , Spectro{1});
    
    i=i+1;
end

% Restrict these tsd to epoch without noise
Epoch = Epoch - TotalNoiseEpoch; i=1;
for channel=25:28
    
    load(['B_Low_Spectrum_' num2str(channel) '.mat'])
    OB_Low_Sp_tsd_WithoutNoise.(Channel{i}) = Restrict(OB_Low_Sp_tsd.(Channel{i}) , Epoch);
    range_Low = Spectro{3};
    load(['B_Middle_Spectrum_' num2str(channel) '.mat'])
    OB_Middle_Sp_tsd_WithoutNoise.(Channel{i}) = Restrict(OB_Middle_Sp_tsd.(Channel{i}) , Epoch);
    range_Middle = Spectro{3};
    load(['B_High_Spectrum_' num2str(channel) '.mat'])
    OB_High_Sp_tsd_WithoutNoise.(Channel{i}) = Restrict(OB_High_Sp_tsd.(Channel{i}) , Epoch);
    range_High = Spectro{3};
    
    i=i+1;
end


%% OB Low
% Mean spectrums
figure
subplot(131)
for channel=1:4
    plot(range_Low , nanmean(Data(OB_Low_Sp_tsd.(Channel{channel})))); hold on
end
makepretty; xlim([0 10])
title('Mean spectrum, regular scale'); xlabel('Frequency (Hz)'); ylabel('Power (a.u.)')
legend('channel 25','channel 26','channel 27','channel 28')

subplot(132)
for channel=1:4
    plot(range_Low , nanmean(Data(OB_Low_Sp_tsd.(Channel{channel})))); hold on
end
makepretty; xlim([0 10]); set(gca, 'YScale', 'log');
title('Mean spectrum, log scale'); xlabel('Frequency (Hz)');

subplot(133)
for channel=1:4
    plot(range_Low , range_Low.*nanmean(Data(OB_Low_Sp_tsd.(Channel{channel})))); hold on
end
makepretty; xlim([0 10]); %set(gca, 'YScale', 'log');
vline(1,'--r'); vline(3.8,'--r')
title('Mean spectrum*f'); xlabel('Frequency (Hz)');


% Spectrograms
load(['B_Low_Spectrum_25.mat'])
figure
imagesc(Spectro{2}/60 , Spectro{3} , Data(OB_Low_Sp_tsd.(Channel{1}))'); axis xy
caxis([0 2e4]); xlabel('time (min)'); ylabel('Frequency (Hz)')
title('OB Low spectrogram')


%% OB Middle
load(['B_Middle_Spectrum_25.mat'])
figure
subplot(121)
for channel=1:4
    plot(Spectro{3} , nanmean(Data(OB_Middle_Sp_tsd.(Channel{channel})))); hold on
end
makepretty; xlim([10 100]); ylim([0 1000]); set(gca, 'YScale', 'log');
title('Mean spectrum'); xlabel('Frequency (Hz)'); ylabel('Power (log scale)')
legend('channel 25','channel 26','channel 27','channel 28')

subplot(122)
for channel=1:4
    plot(Spectro{3} , Spectro{3}.*nanmean(Data(OB_Middle_Sp_tsd.(Channel{channel})))); hold on
end
makepretty; xlim([10 100]); ylim([0 1.5e4]); set(gca, 'YScale', 'log');
title('Mean spectrum*f'); xlabel('Frequency (Hz)'); 
u=text(-72,3.2e3,'---------------------------------------------------------------'); 
set(u,'Rotation',90,'FontSize',20,'Color','r')
u=text(47,3.2e3,'----------------------------------------------------------------'); 
set(u,'Rotation',90,'FontSize',20,'Color','r')

a=suptitle('OB High mean spectrum'); a.FontSize=20;

% Spectrograms
load(['B_Middle_Spectrum_25.mat'])
figure
subplot(211)
imagesc(Spectro{2}/60 , Spectro{3} , Data(OB_Middle_Sp_tsd.(Channel{1}))'); axis xy
caxis([0 4e2]); ylim([20 100]); colormap jet
xlabel('time (min)'); ylabel('Frequency (Hz)')
title('OB High spectrogram')
subplot(223)
imagesc(Spectro{2}/60 , Spectro{3} , Data(OB_Middle_Sp_tsd.(Channel{1}))'); axis xy
caxis([0 3e2]); ylim([20 100]); xlim([6.1 6.15]); colormap jet
xlabel('time (min)'); ylabel('Frequency (Hz)')
subplot(224)
imagesc(Spectro{2}/60 , Spectro{3} , Data(OB_Middle_Sp_tsd.(Channel{1}))'); axis xy
caxis([0 3e2]); ylim([20 100]); xlim([6.1 6.15]); colormap jet
xlabel('time (min)'); ylabel('Frequency (Hz)')
title('OB High spectrogram')

%% Phase pref
load('LFPData/LFP28.mat'); load('B_Middle_Spectrum_25.mat')
[P,f,VBinnedPhase] = PrefPhaseSpectrum(LFP , Data(OB_Middle_Sp_tsd.(Channel{1})) , Range(OB_Middle_Sp_tsd.(Channel{1}),'s') , Spectro{3} , [2 6] , 30); close
figure
imagesc([VBinnedPhase VBinnedPhase+354] , f , [P ; P]'); axis xy; caxis([0 3.7e2]); ylim([20 100])
colormap jet
ylabel('Frequency (Hz)'); xlabel('Phase (degrees)')
title('OB High phase pref')

%%
load('LFPData/LFP24.mat'); load('B_Middle_Spectrum_24.mat')
[P,f,VBinnedPhase] = PrefPhaseSpectrum(LFP , Data(OB_Middle_Sp_tsd.(Channel{1})) , Range(OB_Middle_Sp_tsd.(Channel{1}),'s') , Spectro{3} , [2 6] , 30); close
figure
imagesc([VBinnedPhase VBinnedPhase+354] , f , [P ; P]'); axis xy; caxis([0 3.7e2]); ylim([20 100])
colormap jet
ylabel('Frequency (Hz)'); xlabel('Phase (degrees)')
title('OB High phase pref')

%% Without noise
figure
subplot(121)
for channel=1:4
    plot(range_Low , range_Low.*nanmean(Data(OB_Low_Sp_tsd_WithoutNoise.(Channel{channel})))); hold on
end
makepretty; xlim([0 20])
title('OB Low'); xlabel('Frequency (Hz)'); ylabel('Power (a.u.)')
legend('channel 25','channel 26','channel 27','channel 28')

subplot(122)
for channel=1:4
    plot(range_Middle , range_Middle.*nanmean(Data(OB_Middle_Sp_tsd_WithoutNoise.(Channel{channel})))); hold on
end
makepretty; xlim([15 100])
title('OB High'); xlabel('Frequency (Hz)');

load('LFPData/LFP28.mat'); load('B_Middle_Spectrum_25.mat')
[P,f,VBinnedPhase] = PrefPhaseSpectrum(LFP , range_Middle.*Data(OB_Middle_Sp_tsd_WithoutNoise.(Channel{1})) , Range(OB_Middle_Sp_tsd_WithoutNoise.(Channel{1}),'s') , range_Middle , [2 6] , 50); close
figure
imagesc([VBinnedPhase VBinnedPhase+354] , f , [P ; P]'); axis xy; caxis([6e3 9e3]); ylim([20 100])
colormap jet
ylabel('Frequency (Hz)'); xlabel('Phase (degrees)')
title('OB High phase pref')


%% Others

channel_bulb=28;
FindNoiseEpoch_BM([cd filesep],channel_bulb,0);


[SleepOB,SmoothGamma,Info_temp,microWakeEpochOB,microSleepEpochOB]= ...
    FindGammaEpoch_SleepScoring(Epoch, channel_bulb, minduration, 'foldername', foldername,...
    'smoothwindow', smootime,'controlepoch',ControlEpoch);




load('behavResources.mat', 'MovAcctsd')

%define immobile epoch
smoofact_Acc = 30;
NewMovAcctsd=tsd(Range(MovAcctsd),runmean(Data(MovAcctsd),smoofact_Acc));
thresh = GetGaussianThresh_BM(Data(NewMovAcctsd)); close
th_immob=0.005;
thtps_immob=3;
th_immob_Acc = 10^(thresh);
TotEpoch=intervalSet(0,max(Range(NewMovAcctsd)))-TotalNoiseEpoch;
FreezeAccEpoch=thresholdIntervals(NewMovAcctsd,th_immob_Acc,'Direction','Below');
FreezeAccEpoch=mergeCloseIntervals(FreezeAccEpoch,0.5*1e4);
FreezeAccEpoch=dropShortIntervals(FreezeAccEpoch,thtps_immob*1e4);
FreezeAccEpoch=and(FreezeAccEpoch , TotEpoch);
MovingEpoch=TotEpoch-FreezeAccEpoch;

figure
plot(Range(Restrict(NewMovAcctsd , MovingEpoch),'s')/60 , Data(Restrict(NewMovAcctsd , MovingEpoch))); hold on
plot(Range(Restrict(NewMovAcctsd , FreezeAccEpoch),'s')/60 , Data(Restrict(NewMovAcctsd , FreezeAccEpoch))); hold on
xlim([0 max(Range(NewMovAcctsd,'s'))/60]); ylim([0 1.2e7])
xlabel('time (min)')
hline(th_immob_Acc,'--r')
legend('Moving','Immobile')
ylabel('Movement quantity (a.u.)')
title('Accelerometer values')   
            


% correlations gamma & movement
figure
plot(Range(Restrict(SmoothGamma, MovingEpoch),'s')/60 , Data(Restrict(SmoothGamma, MovingEpoch)))
hold on
plot(Range(Restrict(SmoothGamma, FreezeAccEpoch),'s')/60 , Data(Restrict(SmoothGamma, FreezeAccEpoch)))
legend('Moving','Immobile')
ylabel('Gamma power (a.u.)')
xlabel('time (min)')
title('Gamma power values across session')   
    
            
MovAcctsd_NewRange = interp1(Range(NewMovAcctsd) , Data(NewMovAcctsd) , Range(SmoothGamma)); 
MovAcctsd_NewRange_tsd = tsd(Range(SmoothGamma) , MovAcctsd_NewRange);

D1 = Data(MovAcctsd_NewRange_tsd);
D2 = Data(SmoothGamma);
D1_bis = D1(D1<1.3e7);
D2_bis = D2(D1<1.3e7);

clf; bin=500;
subplot(121)
PlotCorrelations_BM(D1_bis(1:bin:end) , D2_bis(1:bin:end) , 5 , 1)
ylim([50 150])
xlabel('Accelerometer values (regular values)'); ylabel('Gamma values (regular values)')
title('regular values')
subplot(122)
PlotCorrelations_BM(log10(D1_bis(1:bin:end)) , log10(D2_bis(1:bin:end)) , 5 , 1)
xlabel('Accelerometer values (log values)'); ylabel('Gamma values (log values)')
title('log values')

a=suptitle('OB gamma power = f(accelero)'); a.FontSize=20;



