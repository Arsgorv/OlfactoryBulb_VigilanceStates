

clear all

Dir{1} = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir{2} = PathForExperimentsOB({'Shropshire'}, 'freely-moving', 'atropine');


for drug=1:2
    for sess=1:length(Dir{drug}.path)
        
        clear inj_time
        load([Dir{drug}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SmoothGamma')
        load([Dir{drug}.path{sess} filesep 'SleepScoring_Accelero.mat'], 'Wake','Sleep','REMEpoch','TotalNoiseEpoch','Epoch')
        load([Dir{drug}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'inj_time')
        load([Dir{drug}.path{sess} filesep 'B_Middle_Spectrum.mat'])
        load([Dir{drug}.path{sess} filesep 'behavResources.mat'], 'MovAcctsd')
        Smooth_Acc = tsd(Range(MovAcctsd) , movmean(log10(Data(MovAcctsd)),30,'omitnan'));
        
        try
            inj_time;
        catch
            inj_time = max(Range(SmoothGamma))/2;
        end
        
        % spectro
        B_Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
        OB_Sp_Wake = Restrict(B_Sptsd,Wake);
        
        % epochs
        Before_Injection = intervalSet(inj_time-2.2*3600e4 , -600e4+inj_time);
        After_Injection = intervalSet(inj_time+600e4 , inj_time+2.2*3600e4);
        
        Moving = thresholdIntervals(Smooth_Acc , 6.7 , 'Direction' , 'Above');
        Moving = mergeCloseIntervals(Moving , 1e4);
        Moving = dropShortIntervals(Moving , 2e4);
        NonMoving = or(Epoch,TotalNoiseEpoch)-Moving;
        
        % cleaning
        OB_Sp_Bef = Restrict(B_Sptsd,and(Before_Injection , Moving));
        OB_Sp_Aft = Restrict(B_Sptsd,and(After_Injection , Moving));
        [OB_Sp_Wake_clean_bef{drug}{sess},~,Ep] = CleanSpectro_BM(OB_Sp_Bef , Spectro{3} , 9 , 5);
        [OB_Sp_Wake_clean_aft{drug}{sess},~,Ep] = CleanSpectro_BM(OB_Sp_Aft , Spectro{3} , 9 , 5);
        
        % interp
        clear D, D = runmean(runmean(log10(Spectro{3}.*Data(OB_Sp_Wake_clean_bef{drug}{sess})),1e2)',3)';
        for i=1:size(Data(OB_Sp_Wake_clean_bef{drug}{sess}),2)
            Smooth_OB_Bef_interp{drug}(sess,i,:) = interp1(linspace(0,1,length(D(:,i))) , D(:,i) , linspace(0,1,100));
        end
        clear D, D = runmean(runmean(log10(Spectro{3}.*Data(OB_Sp_Wake_clean_aft{drug}{sess})),1e2)',3)';
        for i=1:size(Data(OB_Sp_Wake_clean_aft{drug}{sess}),2)
            Smooth_OB_Aft_interp{drug}(sess,i,:) = interp1(linspace(0,1,length(D(:,i))) , D(:,i) , linspace(0,1,100));
        end
        
        % mean sp
        OB_MeanSp_Bef{drug}(sess,:) = nanmean(Data(OB_Sp_Wake_clean_bef{drug}{sess}));
        OB_MeanSp_Aft{drug}(sess,:) = nanmean(Data(OB_Sp_Wake_clean_aft{drug}{sess}));
        
        % mean values
        Smooth_Gamma_mean{drug}(1,sess) = nanmean(Data(Restrict(SmoothGamma , Before_Injection-TotalNoiseEpoch)));
        Smooth_Gamma_mean{drug}(2,sess) = nanmean(Data(Restrict(SmoothGamma , After_Injection-TotalNoiseEpoch)));
        clear D, D = Data(Restrict(SmoothGamma , Before_Injection));
        Smooth_Gamma_interp{drug}(1,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
        clear D, D = Data(Restrict(SmoothGamma , After_Injection));
        Smooth_Gamma_interp{drug}(2,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
        
        Smooth_Acc_mean{drug}(1,sess) = nanmean(Data(Restrict(Smooth_Acc , Before_Injection)));
        Smooth_Acc_mean{drug}(2,sess) = nanmean(Data(Restrict(Smooth_Acc , After_Injection)));
        clear D, D = Data(Restrict(Smooth_Acc , Before_Injection));
        Smooth_Acc_interp{drug}(1,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
        clear D, D = Data(Restrict(Smooth_Acc , After_Injection));
        Smooth_Acc_interp{drug}(2,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
        
        % states prop
        Wake = or(Wake , TotalNoiseEpoch);
        Wake_prop_Bef_Inj{drug}(sess) = sum(DurationEpoch(and(Moving , Before_Injection)))./sum(DurationEpoch(Before_Injection));
        Wake_prop_Aft_Inj{drug}(sess) = sum(DurationEpoch(and(Moving , After_Injection)))./sum(DurationEpoch(After_Injection));
        
        MeanAcc_Sleep_Bef_Inj{drug}(sess) = nanmean(Data(Restrict(MovAcctsd , and(NonMoving , Before_Injection))));
        MeanAcc_Sleep_Aft_Inj{drug}(sess) = nanmean(Data(Restrict(MovAcctsd , and(NonMoving , After_Injection))));
        
        MeanAcc_Wake_Bef_Inj{drug}(sess) = nanmean(Data(Restrict(MovAcctsd , and(Moving , Before_Injection))));
        MeanAcc_Wake_Aft_Inj{drug}(sess) = nanmean(Data(Restrict(MovAcctsd , and(Moving , After_Injection))));
        
        disp([num2str(drug) ' ' num2str(sess)])
    end
    Smooth_Gamma_interp{drug}(Smooth_Gamma_interp{drug}==0) = NaN;
    OB_MeanSp_Bef{drug}(OB_MeanSp_Bef{drug}==0) = NaN;
    OB_MeanSp_Aft{drug}(OB_MeanSp_Aft{drug}==0) = NaN;
end
% OB_Wake_Aft_Inj{2}([3],:) = NaN;
% OB_Wake_Bef_Inj{1}([3],:) = NaN;

Cols = {[.3 .3 .3],[.3 1 .3]};
X = 1:2;
Legends = {'Saline','Atropine'};

figure
[~,MaxPowerValues1,f] = Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_MeanSp_Bef{1} , 'color' , 'k');
[~,MaxPowerValues2,f] = Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_MeanSp_Bef{2} , 'color' , 'k');
[~,MaxPowerValues3,Freq_Max1] = Plot_MeanSpectrumForMice_BM((Spectro{3}.*OB_MeanSp_Aft{1})./MaxPowerValues1');
[~,MaxPowerValues4,Freq_Max2] = Plot_MeanSpectrumForMice_BM((Spectro{3}.*OB_MeanSp_Aft{2})./MaxPowerValues2');
clf
subplot(1,4,1:2)
Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_MeanSp_Aft{1} , 'color' , 'k' , 'power_norm_value' , MaxPowerValues1);
Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_MeanSp_Aft{2} , 'color' , 'g' , 'power_norm_value' , MaxPowerValues2);
xlim([20 100]), ylim([0 2])
makepretty, axis square
f=get(gca,'Children'); legend([f(5),f(1)],'Saline','Atropine');

% MaxPowerValues3(3) = NaN;
subplot(143)
MakeSpreadAndBoxPlot3_SB({MaxPowerValues3 MaxPowerValues4},Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('OB gamma power (norm)')
makepretty_BM2

subplot(144)
MakeSpreadAndBoxPlot3_SB({Freq_Max1 Freq_Max2},Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('OB gamma freq (Hz)')
makepretty_BM2



figure
subplot(121)
MakeSpreadAndBoxPlot3_SB(Wake_prop_Aft_Inj,Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('Wake proportion')
makepretty_BM2

subplot(122)
MakeSpreadAndBoxPlot3_SB(MeanAcc_Sleep_Aft_Inj,Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('Motion during sleep')
makepretty_BM2




figure
subplot(211)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Aft_interp{1}))',5)'), axis xy
caxis([4 6]), hline([40 60],'-r'), ylim([20 100]), ylabel('Frequency (Hz)')
makepretty
title('Saline')
subplot(212)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Aft_interp{2}))',5)'), axis xy
caxis([4 6]), hline([40 60],'-r'), ylim([20 100]), xlabel('time (h)'), ylabel('Frequency (Hz)')
makepretty
title('Atropine')




%% other ferret

Dir{1} = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = PathForExperimentsOB({'Brynza'}, 'freely-moving', 'atropine');


%% tools
figure
subplot(121)
plot(Spectro{3} , ((Spectro{3}.*OB_Wake_Aft_Inj{1})./MaxPowerValues1')'), xlim([5 100])
subplot(122)
plot(Spectro{3} , ((Spectro{3}.*OB_Wake_Aft_Inj{2})./MaxPowerValues2')'), xlim([5 100])



plot(OB_Wake_Bef_Inj{1}')

plot(OB_Wake_Aft_Inj{2}')




figure
subplot(221)
plot(Spectro{3} , Spectro{3}.*OB_MeanSp_Bef{1}), xlim([20 100])
subplot(222)
plot(Spectro{3} , Spectro{3}.*OB_MeanSp_Aft{1}), xlim([20 100])
subplot(223)
plot(Spectro{3} , Spectro{3}.*OB_MeanSp_Bef{2}), xlim([20 100])
subplot(224)
plot(Spectro{3} , Spectro{3}.*OB_MeanSp_Aft{2}), xlim([20 100])


figure
subplot(121)
Data_to_use = Spectro{3}.*OB_Wake_Bef_Inj{1};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(Spectro{3} , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
Data_to_use = Spectro{3}.*OB_Wake_Bef_Inj{2};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(Spectro{3} , nanmean(Data_to_use) , Conf_Inter ,'-g',1); hold on;
makepretty

subplot(122)
Data_to_use = Spectro{3}.*OB_Wake_Aft_Inj{1};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(Spectro{3} , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
Data_to_use = Spectro{3}.*OB_Wake_Aft_Inj{2};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(Spectro{3} , nanmean(Data_to_use) , Conf_Inter ,'-g',1); hold on;
makepretty




figure
subplot(221)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Bef_interp{1}))',5)'), axis xy
caxis([4 5.5]), hline([40 60],'-r'), ylabel('Frequency (Hz)')
title('Pre')
makepretty
subplot(222)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Aft_interp{1}))',5)'), axis xy
caxis([4 5.5]), hline([40 60],'-r')
makepretty
title('Post')
subplot(223)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Bef_interp{2}))',5)'), axis xy
caxis([4 5.5]), hline([40 60],'-r'), xlabel('time (h)'), ylabel('Frequency (Hz)')
makepretty
subplot(224)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Aft_interp{2}))',5)'), axis xy
caxis([4 5.5]), hline([40 60],'-r'), xlabel('time (h)')
makepretty



c = [4 6];

figure
for i=1:7
    try
        subplot(7,4,(i-1)*4+1)
        imagesc(linspace(0,1.5,100) , Spectro{3} , squeeze(Smooth_OB_Bef_interp{1}(i,:,:))), axis xy, %caxis(c), ylim([20 70])
        hline([40 60],'-r'), ylim([20 100]), caxis([4 5.5])
    end
    try
        subplot(7,4,(i-1)*4+2)
        imagesc(linspace(0,1.5,100) , Spectro{3} , squeeze(Smooth_OB_Aft_interp{1}(i,:,:))), axis xy, %caxis(c), ylim([20 70])
        hline([40 60],'-r'), ylim([20 100]), caxis([4 5.5])
    end
    try
        subplot(7,4,(i-1)*4+3)
        imagesc(linspace(0,1.5,100) , Spectro{3} , squeeze(Smooth_OB_Bef_interp{2}(i,:,:))), axis xy, %caxis(c), ylim([20 70])
        hline([40 60],'-r'), ylim([20 100]), caxis([4 5.5])
    end
    try
        subplot(7,4,(i-1)*4+4)
        imagesc(linspace(0,1.5,100) , Spectro{3} , squeeze(Smooth_OB_Aft_interp{2}(i,:,:))), axis xy, %caxis(c), ylim([20 70])
        hline([40 60],'-r'), ylim([20 100]), caxis([4 5.5])
    end
end




D_Bef_Sal = ((Spectro{3}.*OB_Wake_Bef_Inj{1})'./nanmean((Spectro{3}([13:16 54:end]).*OB_Wake_Bef_Inj{1}(:,[13:16 54:end]))'))';
D_Aft_Sal = ((Spectro{3}.*OB_Wake_Aft_Inj{1})'./nanmean((Spectro{3}([13:16 54:end]).*OB_Wake_Aft_Inj{1}(:,[13:16 54:end]))'))';
D_Bef_At = ((Spectro{3}.*OB_Wake_Bef_Inj{2})'./nanmean((Spectro{3}([13:16 54:end]).*OB_Wake_Bef_Inj{2}(:,[13:16 54:end]))'))';
D_Aft_At = ((Spectro{3}.*OB_Wake_Aft_Inj{2})'./nanmean((Spectro{3}([13:16 54:end]).*OB_Wake_Aft_Inj{2}(:,[13:16 54:end]))'))';




%% BRYNZA
clear all

Dir{1} = PathForExperimentsOB({'Brynza'}, 'freely-moving');
Dir{2} = PathForExperimentsOB({'Brynza'}, 'freely-moving', 'atropine');

inj_time(2:3) = [5e7 7e7];
drug = 2;

for sess=2:3
    cd(Dir{2}.path{sess})
    
    load([Dir{drug}.path{sess} filesep 'B_Middle_Spectrum.mat'])
    load([Dir{drug}.path{sess} filesep 'behavResources.mat'], 'MovAcctsd')
    load([Dir{drug}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SmoothGamma')
    B_Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
    
    Smooth_Acc = tsd(Range(MovAcctsd) , movmean(log10(Data(MovAcctsd)),30,'omitnan'));
    Moving = thresholdIntervals(Smooth_Acc , 6.4 , 'Direction' , 'Above');
    Moving = mergeCloseIntervals(Moving , 1e4);
    Moving = dropShortIntervals(Moving , 2e4);
    
    Before_Injection = intervalSet(inj_time(sess)-2.2*3600e4 , inj_time(sess));
    After_Injection = intervalSet(inj_time(sess) , inj_time(sess)+2.2*3600e4);
    
    OB_Sp_Bef{sess} = Restrict(B_Sptsd,and(Before_Injection , Moving));
    OB_Sp_Aft{sess} = Restrict(B_Sptsd,and(After_Injection , Moving));
    
    SmoothGamma_BefInj = Restrict(SmoothGamma , Before_Injection);
    SmoothGamma_AftInj = Restrict(SmoothGamma , After_Injection);
    
    OB_MeanSp_Bef(sess,:) = nanmean(Data(OB_Sp_Bef{sess}));
    OB_MeanSp_Aft(sess,:) = nanmean(Data(OB_Sp_Aft{sess}));
end
OB_MeanSp_Bef(OB_MeanSp_Bef==0)=NaN;
OB_MeanSp_Aft(OB_MeanSp_Aft==0)=NaN;



figure
subplot(221)
imagesc(Range(OB_Sp_Bef{2},'s')/60 , Spectro{3} , log10(Spectro{3}.*Data(OB_Sp_Bef{2}))'), axis xy, ylim([20 100])
caxis([3 6])
subplot(222)
imagesc(Range(OB_Sp_Aft{2},'s')/60 , Spectro{3} , log10(Spectro{3}.*Data(OB_Sp_Aft{2}))'), axis xy, ylim([20 100])
caxis([3 6])

subplot(223)
imagesc(Range(OB_Sp_Bef{3},'s')/60 , Spectro{3} , log10(Spectro{3}.*Data(OB_Sp_Bef{3}))'), axis xy, ylim([20 100])
caxis([3 6])
subplot(224)
imagesc(Range(OB_Sp_Aft{3},'s')/60 , Spectro{3} , log10(Spectro{3}.*Data(OB_Sp_Aft{3}))'), axis xy, ylim([20 100])
caxis([3 6])




figure
plot(Spectro{3} , nanmean(Data(OB_Sp_Bef{sess})))
hold on
plot(Spectro{3} , nanmean(Data(OB_Sp_Aft{sess})))




figure
[~,MaxPowerValues1,Freq_Max1] = Plot_MeanSpectrumForMice_BM((Spectro{3}.*OB_MeanSp_Bef));
[~,MaxPowerValues2,Freq_Max2] = Plot_MeanSpectrumForMice_BM((Spectro{3}.*OB_MeanSp_Aft) , 'power_norm_value' , MaxPowerValues1' , 'color' , 'g');
xlim([20 100]), ylim([0 1])
makepretty
f=get(gca,'Children'); legend([f(5),f(1)],'Saline','Atropine');
plot(Range(Smooth_Acc,'s')/60 , Data(Smooth_Acc))

figure
D = log10(Data(SmoothGamma_BefInj));
[Y,X]=hist(D,1000);
Y=Y/sum(Y);
plot(X,Y), hold on
D = log10(Data(SmoothGamma_AftInj));
[Y,X]=hist(D,1000);
Y=Y/sum(Y);
plot(X,Y)

