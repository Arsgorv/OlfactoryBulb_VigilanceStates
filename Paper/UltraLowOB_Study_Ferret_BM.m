%%

load('SleepScoring_OBGamma.mat', 'Epoch', 'Wake', 'REMEpoch', 'SWSEpoch')
smootime=3;

load('LFPData/LFP8.mat')
LFP=Restrict(LFP , Epoch);
Fil = FilterLFP(LFP,[.15 .8],1024);
Enveloppe = tsd(Range(LFP), abs(hilbert(Data(Fil))) );
SmoothUL = tsd(Range(Enveloppe), runmean(Data(Enveloppe), ...
    ceil(smootime/median(diff(Range(Enveloppe,'s'))))));
SmoothUL_Wake = Restrict(SmoothUL , Wake);
SmoothUL_NREM = Restrict(SmoothUL , SWSEpoch);
SmoothUL_REM = Restrict(SmoothUL , REMEpoch);


load('LFPData/LFP11.mat')
LFP=Restrict(LFP , Epoch);
Fil = FilterLFP(LFP,[1 6],1024);
Enveloppe = tsd(Range(LFP), abs(hilbert(Data(Fil))) );
SmoothTheta = tsd(Range(Enveloppe), runmean(Data(Enveloppe), ...
    ceil(smootime/median(diff(Range(Enveloppe,'s'))))));
SmoothTheta_corr = Restrict(SmoothTheta , SmoothUL);
SmoothTheta_Wake = Restrict(SmoothTheta_corr , Wake);
SmoothTheta_NREM = Restrict(SmoothTheta_corr , SWSEpoch);
SmoothTheta_REM = Restrict(SmoothTheta_corr , REMEpoch);


load('LFPData/LFP10.mat')
LFP=Restrict(LFP , Epoch);
LFP = Restrict(LFP , Epoch);
Fil = FilterLFP(LFP,[40 60],1024);
Enveloppe = tsd(Range(LFP), abs(hilbert(Data(Fil))) );
SmoothGamma = tsd(Range(Enveloppe), runmean(Data(Enveloppe), ...
    ceil(smootime/median(diff(Range(Enveloppe,'s'))))));
SmoothGamma_corr = Restrict(SmoothGamma , SmoothUL);
SmoothGamma_Wake = Restrict(SmoothGamma_corr , Wake);
SmoothGamma_NREM = Restrict(SmoothGamma_corr , SWSEpoch);
SmoothGamma_REM = Restrict(SmoothGamma_corr , REMEpoch);



figure
subplot(121)
clear X Y
X = log10(Data(SmoothUL_Wake)); Y = log10(Data(SmoothTheta_Wake)); 
plot(X(1:100:end) , Y(1:100:end) , '.b'), hold on
clear X Y
X = log10(Data(SmoothUL_NREM)); Y = log10(Data(SmoothTheta_NREM)); 
plot(X(1:100:end) , Y(1:100:end) , '.r')
clear X Y
X = log10(Data(SmoothUL_REM)); Y = log10(Data(SmoothTheta_REM)); 
plot(X(1:100:end) , Y(1:100:end) , '.g')


subplot(122)
clear X Y
X = log10(Data(SmoothTheta_Wake)); Y = log10(Data(SmoothGamma_Wake)); 
plot(X(1:100:end) , Y(1:100:end) , '.b'), hold on
clear X Y
X = log10(Data(SmoothTheta_NREM)); Y = log10(Data(SmoothGamma_NREM)); 
plot(X(1:100:end) , Y(1:100:end) , '.r')
clear X Y
X = log10(Data(SmoothTheta_REM)); Y = log10(Data(SmoothGamma_REM)); 
plot(X(1:100:end) , Y(1:100:end) , '.g')



%%

cd('/media/nas7/React_Passive_AG/OBG/Labneh/freely-moving/20230302_saline')
cd('/media/nas7/React_Passive_AG/OBG/Labneh/freely-moving/20221221_long')
cd('/media/nas7/React_Passive_AG/OBG/Labneh/freely-moving/20230309_2/recording1')


load('StateEpochBM.mat')

min_dur = 30;
SWSEpoch = mergeCloseIntervals(SWSEpoch,min_dur*1E4);
SWSEpoch = dropShortIntervals(SWSEpoch,min_dur*1E4);

REMEpoch = mergeCloseIntervals(REMEpoch,min_dur*1E4);
REMEpoch = dropShortIntervals(REMEpoch,min_dur*1E4);

Wake = mergeCloseIntervals(Wake,min_dur*1E4);
Wake = dropShortIntervals(Wake,min_dur*1E4);

Sleep = mergeCloseIntervals(Sleep,min_dur*1E4);
Sleep = dropShortIntervals(Sleep,min_dur*1E4);

% save('StateEpochBM.mat','SWSEpoch','REMEpoch','Wake','Sleep','-append')

load('StateEpochSB.mat','Epoch_01_05')

Epoch_01_05 = mergeCloseIntervals(Epoch_01_05,min_dur*1E4);
Epoch_01_05 = dropShortIntervals(Epoch_01_05,min_dur*1E4);

% save('StateEpochSB.mat','Epoch_01_05','Wake','Sleep','-append')

OB_High = load('B_High_Spectrum.mat'); OB_High_tsd = tsd(OB_High.Spectro{2}*1e4 , OB_High.Spectro{1});
OB_ULow = load('B_UltraLow_Spectrum.mat'); OB_ULow_tsd = tsd(OB_ULow.Spectro{2}*1e4 , OB_ULow.Spectro{1});
Ref_Low = load('Ref_Low_Spectrum.mat'); Ref_Low_tsd = tsd(Ref_Low.Spectro{2}*1e4 , Ref_Low.Spectro{1});

figure
subplot(311)
imagesc(Range(OB_High_tsd)/60e4 , OB_High.Spectro{3} , log10(Data(OB_High_tsd))'), axis xy, caxis([3 4])
Hypnogram_LineColor_BM(95,'time','min')
Hypnogram_LineColor_BM(90,'time','min','scoring','bm')
ylabel('Frequency (Hz)')
title('OB High')

subplot(312)
imagesc(Range(OB_ULow_tsd)/60e4 , OB_ULow.Spectro{3} , log10(Data(OB_ULow_tsd))'), axis xy, caxis([2 6])
Hypnogram_LineColor_BM(.95,'time','min')
Hypnogram_LineColor_BM(.9,'time','min','scoring','bm')
ylabel('Frequency (Hz)')
title('OB Ultra low')

subplot(313)
imagesc(Range(Ref_Low_tsd)/60e4 , Ref_Low.Spectro{3} , log10(Data(Ref_Low_tsd))'), axis xy, caxis([2 4])
Hypnogram_LineColor_BM(19,'time','min')
Hypnogram_LineColor_BM(18,'time','min','scoring','bm')
ylabel('Frequency (Hz)'), xlabel('time (min)')
title('Cortex')

a=suptitle('Spectrograms, sleep session, freely moving'); a.FontSize=20;


%% 
load('SleepScoring_OBGamma.mat', 'Epoch', 'REMEpoch', 'SWSEpoch', 'Wake', 'smooth_01_05', 'SmoothTheta')


load(['LFPData/LFP1.mat'])
LFP = Restrict(LFP , Epoch);
FilDelta = FilterLFP(LFP,[.5 2],1024); % filtering
H = abs(hilbert(Data(FilDelta))); H(H>200)=200;
tEnveloppeDelta = tsd(Range(LFP), H); %tsd: hilbert transform then enveloppe
smootime=10;
SmoothDelta = tsd(Range(tEnveloppeDelta), runmean(Data(tEnveloppeDelta),ceil(smootime/median(diff(Range(tEnveloppeDelta,'s'))))));

smooth_Theta = tsd(Range(SmoothTheta), runmean(Data(SmoothTheta),ceil(smootime/median(diff(Range(SmoothTheta,'s'))))));
smooth_01_05 = tsd(Range(smooth_01_05), runmean(Data(smooth_01_05),ceil(smootime/median(diff(Range(smooth_01_05,'s'))))));


figure
subplot(311)
plot(Range(Restrict(smooth_Theta,Wake))/60e4 , Data(Restrict(smooth_Theta,Wake)) , '.b','MarkerSize',1)
hold on
plot(Range(Restrict(smooth_Theta,SWSEpoch))/60e4 , Data(Restrict(smooth_Theta,SWSEpoch)) , '.r','MarkerSize',1)
plot(Range(Restrict(smooth_Theta,REMEpoch))/60e4 , Data(Restrict(smooth_Theta,REMEpoch)) , '.g','MarkerSize',1)
ylabel('Power (a.u.)'), legend('Wake','SWS','REM'), xlim([0 max(Range(LFP))/60e4])
title('Theta cortex')

subplot(312)
plot(Range(Restrict(smooth_01_05,Wake))/60e4 , Data(Restrict(smooth_01_05,Wake)) , '.b','MarkerSize',1)
hold on
plot(Range(Restrict(smooth_01_05,SWSEpoch))/60e4 , Data(Restrict(smooth_01_05,SWSEpoch)) , '.r','MarkerSize',1)
plot(Range(Restrict(smooth_01_05,REMEpoch))/60e4 , Data(Restrict(smooth_01_05,REMEpoch)) , '.g','MarkerSize',1)
ylabel('Power (a.u.)'), ylim([0 800]), xlim([0 max(Range(LFP))/60e4])
title('Ultra low OB')

subplot(313)
plot(Range(Restrict(SmoothDelta,Wake))/60e4 , Data(Restrict(SmoothDelta,Wake)) , '.b','MarkerSize',1)
hold on
plot(Range(Restrict(SmoothDelta,SWSEpoch))/60e4 , Data(Restrict(SmoothDelta,SWSEpoch)) , '.r','MarkerSize',1)
plot(Range(Restrict(SmoothDelta,REMEpoch))/60e4 , Data(Restrict(SmoothDelta,REMEpoch)) , '.g','MarkerSize',1)
xlabel('time (min)'), ylabel('Power (a.u.)'), ylim([0 150]), xlim([0 max(Range(LFP))/60e4])
title('Delta cortex')

a=suptitle('Oscillations power evolution, sleep session, freely moving'); a.FontSize=20;




%%
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
axis off

a=suptitle('Delta power, Cortex  = f(ultra low power, Bulb), SWS'); a.FontSize=20;

%%
n=1;
for s=1:length(Start(SWSEpoch))
    smooth_01_05_SWS = Restrict(smooth_01_05 , subset(SWSEpoch,s));
    SmoothDelta_SWS = Restrict(SmoothDelta , subset(SWSEpoch,s));
    
    smooth_01_05_SWS_interp(n,:) = interp1(linspace(0,1,length(Data(smooth_01_05_SWS))) , Data(smooth_01_05_SWS) , linspace(0,1,100));
    SmoothDelta_SWS_interp(n,:) = interp1(linspace(0,1,length(Data(SmoothDelta_SWS))) , Data(SmoothDelta_SWS) , linspace(0,1,100));
    n=n+1;
end

figure
subplot(121)
Data_to_use = smooth_01_05_SWS_interp;
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
clear Mean_All_Sp; Mean_All_Sp=nanmean(Data_to_use);
shadedErrorBar([1:100] , runmean(Mean_All_Sp,3) , runmean(Conf_Inter,3) ,'-k',1); hold on;
xlabel('time (a.u.)'), ylabel('power (a.u.)')
makepretty
title('Ultra low OB')

subplot(122)
Data_to_use = SmoothDelta_SWS_interp;
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
clear Mean_All_Sp; Mean_All_Sp=nanmean(Data_to_use);
shadedErrorBar([1:100] , runmean(Mean_All_Sp,3) , runmean(Conf_Inter,3) ,'-k',1); hold on;
makepretty
xlabel('time (a.u.)')
title('Delta cortex')

a=suptitle('Oscillations power evolution, average for SWS episode'); a.FontSize=20;


%%
load('StateEpochBM.mat')
min_dur = 30;
SWSEpoch=mergeCloseIntervals(SWSEpoch,min_dur*1E4);
SWSEpoch=dropShortIntervals(SWSEpoch,min_dur*1E4);

[aft_cell1,bef_cell1]=transEpoch(SWSEpoch,Wake);
SWS_FollowedByWake = aft_cell1{1,2};
SWS_AfterWake = bef_cell1{1,2};

[aft_cell2,bef_cell2]=transEpoch(SWSEpoch,REMEpoch);
SWS_FollowedByREM = aft_cell2{1,2};
SWS_AfterREM = bef_cell2{1,2};


% Wake then SWS
n=1;
for s=1:length(Start(SWS_FollowedByWake))
    smooth_01_05_SWS_FollowedByWake = Restrict(smooth_01_05 , subset(SWS_FollowedByWake,s));
    SmoothDelta_SWS_FollowedByWake = Restrict(SmoothDelta , subset(SWS_FollowedByWake,s));
    
    smooth_01_05_SWS_FollowedByWake_interp(n,:) = interp1(linspace(0,1,length(Data(smooth_01_05_SWS_FollowedByWake))) , Data(smooth_01_05_SWS_FollowedByWake) , linspace(0,1,100));
    SmoothDelta_SWS_FollowedByWake_interp(n,:) = interp1(linspace(0,1,length(Data(SmoothDelta_SWS_FollowedByWake))) , Data(SmoothDelta_SWS_FollowedByWake) , linspace(0,1,100));
    n=n+1;
end

n=1;
for s=1:length(Start(SWS_AfterWake))
    smooth_01_05_SWS_AfterWake = Restrict(smooth_01_05 , subset(SWS_AfterWake,s));
    SmoothDelta_SWS_AfterWake = Restrict(SmoothDelta , subset(SWS_AfterWake,s));
    
    smooth_01_05_SWS_AfterWake_interp(n,:) = interp1(linspace(0,1,length(Data(smooth_01_05_SWS_AfterWake))) , Data(smooth_01_05_SWS_AfterWake) , linspace(0,1,100));
    SmoothDelta_SWS_AfterWake_interp(n,:) = interp1(linspace(0,1,length(Data(SmoothDelta_SWS_AfterWake))) , Data(SmoothDelta_SWS_AfterWake) , linspace(0,1,100));
    n=n+1;
end

n=1;
for s=1:length(Start(SWS_FollowedByREM))
    smooth_01_05_SWS_FollowedByREM = Restrict(smooth_01_05 , subset(SWS_FollowedByREM,s));
    SmoothDelta_SWS_FollowedByREM = Restrict(SmoothDelta , subset(SWS_FollowedByREM,s));
    
    smooth_01_05_SWS_FollowedByREM_interp(n,:) = interp1(linspace(0,1,length(Data(smooth_01_05_SWS_FollowedByREM))) , Data(smooth_01_05_SWS_FollowedByREM) , linspace(0,1,100));
    SmoothDelta_SWS_FollowedByREM_interp(n,:) = interp1(linspace(0,1,length(Data(SmoothDelta_SWS_FollowedByREM))) , Data(SmoothDelta_SWS_FollowedByREM) , linspace(0,1,100));
    n=n+1;
end

n=1;
for s=1:length(Start(SWS_AfterREM))
    smooth_01_05_SWS_AfterREM = Restrict(smooth_01_05 , subset(SWS_AfterREM,s));
    SmoothDelta_SWS_AfterREM = Restrict(SmoothDelta , subset(SWS_AfterREM,s));
    
    smooth_01_05_SWS_AfterREM_interp(n,:) = interp1(linspace(0,1,length(Data(smooth_01_05_SWS_AfterREM))) , Data(smooth_01_05_SWS_AfterREM) , linspace(0,1,100));
    SmoothDelta_SWS_AfterREM_interp(n,:) = interp1(linspace(0,1,length(Data(SmoothDelta_SWS_AfterREM))) , Data(SmoothDelta_SWS_AfterREM) , linspace(0,1,100));
    n=n+1;
end



figure
subplot(241)
plot(runmean(smooth_01_05_SWS_FollowedByWake_interp',5))
title('SWS before Wake')
subplot(245)
plot(runmean(SmoothDelta_SWS_FollowedByWake_interp',5))
xlabel('time (a.u.)')

subplot(242)
plot(runmean(smooth_01_05_SWS_AfterWake_interp',5))
title('SWS after Wake')
subplot(246)
plot(runmean(SmoothDelta_SWS_AfterWake_interp',5))
xlabel('time (a.u.)')

subplot(243)
plot(runmean(smooth_01_05_SWS_FollowedByREM_interp',5))
title('SWS before REM')
subplot(247)
plot(runmean(SmoothDelta_SWS_FollowedByREM_interp',5))
xlabel('time (a.u.)')

subplot(244)
plot(runmean(smooth_01_05_SWS_AfterREM_interp',5))
title('SWS after REM')
subplot(248)
plot(runmean(SmoothDelta_SWS_AfterREM_interp',5))
xlabel('time (a.u.)')

a=suptitle('Oscillations power evolution, SWS episodes'); a.FontSize=20;


%%





