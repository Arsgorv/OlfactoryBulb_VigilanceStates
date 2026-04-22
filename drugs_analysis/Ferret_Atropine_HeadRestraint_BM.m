

clear all

Dir{1} = PathForExperimentsOB({'Shropshire'}, 'head-fixed', 'saline');
Dir{2} = PathForExperimentsOB({'Shropshire'}, 'head-fixed', 'atropine');

for drug=1:2
    for sess=1:length(Dir{drug}.path)
        
        load([Dir{drug}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SmoothGamma', 'inj_time')
        load([Dir{drug}.path{sess} filesep 'behavResources.mat'], 'MovAcctsd')
        load([Dir{drug}.path{sess} filesep 'HeartBeatInfo.mat'])
        
        Smooth_Acc = tsd(Range(MovAcctsd) , runmean(log10(Data(MovAcctsd)),30));
        Smooth_HR = tsd(Range(EKG.HBRate) , runmean(Data(EKG.HBRate),5));
        
        Before_Injection = intervalSet(inj_time-1.5*3600e4 , inj_time);
        After_Injection = intervalSet(inj_time , inj_time+1.5*3600e4);
        Bef_inj_time{drug}(sess) = max(Range(Restrict(Smooth_Acc , Before_Injection)))./3600e4;
        Aft_inj_time{drug}(sess) = (max(Range(Restrict(Smooth_Acc , After_Injection)))-max(Range(Restrict(Smooth_Acc , Before_Injection))))./3600e4;
        
        Smooth_Gamma_mean{drug}(1,sess) = nanmean(Data(Restrict(SmoothGamma , Before_Injection)));
        Smooth_Gamma_mean{drug}(2,sess) = nanmean(Data(Restrict(SmoothGamma , After_Injection)));
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
        
        Smooth_HR_mean{drug}(1,sess) = nanmean(Data(Restrict(Smooth_HR , Before_Injection)));
        Smooth_HR_mean{drug}(2,sess) = nanmean(Data(Restrict(Smooth_HR , After_Injection)));
        clear D, D = Data(Restrict(Smooth_HR , Before_Injection));
        Smooth_HR_interp{drug}(1,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
        clear D, D = Data(Restrict(Smooth_HR , After_Injection));
        Smooth_HR_interp{drug}(2,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
        
        load([Dir{drug}.path{sess} filesep 'B_Middle_Spectrum.mat'])
        B_Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
        OB_Sp_Bef = Restrict(B_Sptsd,Before_Injection);
        OB_Sp_Aft = Restrict(B_Sptsd,After_Injection);
        
        OB_SpData_Bef{drug}{sess} = Data(OB_Sp_Bef);
        OB_SpData_Aft{drug}{sess} = Data(OB_Sp_Aft);
                clear D, D = runmean(runmean(log10(Spectro{3}.*OB_SpData_Bef{drug}{sess}),1e2)',3)';
        for i=1:size(OB_SpData_Bef{drug}{sess},2)
            Smooth_OB_Bef_interp{drug}(sess,i,:) = interp1(linspace(0,1,length(D(:,i))) , D(:,i) , linspace(0,1,100));
        end
        clear D, D = runmean(runmean(log10(Spectro{3}.*OB_SpData_Aft{drug}{sess}),1e2)',3)';
        for i=1:size(OB_SpData_Aft{drug}{sess},2)
            Smooth_OB_Aft_interp{drug}(sess,i,:) = interp1(linspace(0,1,length(D(:,i))) , D(:,i) , linspace(0,1,100));
        end
        
        OB_Wake_Bef_Inj{drug}(sess,:) = nanmean(Data(OB_Sp_Bef ));
        OB_Wake_Aft_Inj{drug}(sess,:) = nanmean(Data(OB_Sp_Aft ));
        
        disp([num2str(drug) ' ' num2str(sess)])
    end
    Smooth_HR_interp{drug}(Smooth_HR_interp{drug}>5.5) = NaN;
end
Smooth_HR_interp{2}(2,1,:) = NaN;
OB_Wake_Aft_Inj{1}(5,:) = NaN;
OB_Wake_Aft_Inj{2}(6,:) = NaN;


%%
Cols = {[.3 .3 .3],[.3 1 .3]};
X = 1:2;
Legends = {'Saline','Atropine'};
NoLegends = {'',''};


figure
subplot(2,3,1:2)
Data_to_use = squeeze(Smooth_Gamma_interp{1}(2,:,:))./nanmean(squeeze(Smooth_Gamma_interp{1}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1.5,100), Mean_All_Sp , Conf_Inter ,'-k',1); hold on
Data_to_use = squeeze(Smooth_Gamma_interp{2}(2,:,:))./nanmean(squeeze(Smooth_Gamma_interp{2}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1.5,100), Mean_All_Sp , Conf_Inter ,'-g',1);
title('Head restraint after injection'), ylim([0 2]), hline(1,'--r'), ylabel('OB Gamma power (norm)')
makepretty

subplot(2,3,4:5)
Data_to_use = squeeze(Smooth_HR_interp{1}(2,:,:))./nanmean(squeeze(Smooth_HR_interp{1}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10,'omitnan')';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1.5,100), Mean_All_Sp , Conf_Inter ,'-k',1); hold on
Data_to_use = squeeze(Smooth_HR_interp{2}(2,:,:))./nanmean(squeeze(Smooth_HR_interp{2}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10,'omitnan')';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1.5,100), Mean_All_Sp , Conf_Inter ,'-g',1);
makepretty
xlabel('time (h)'), ylim([.6 1.4]), hline(1,'--r'), ylabel('Heart rate (Hz)')


subplot(233)
MakeSpreadAndBoxPlot3_SB({Smooth_Gamma_mean{1}(2,:)./Smooth_Gamma_mean{1}(1,:)...
    Smooth_Gamma_mean{2}(2,:)./Smooth_Gamma_mean{2}(1,:)},Cols,X,NoLegends,'showpoints',1,'paired',0);
ylabel('OB Gamma power (norm)')
makepretty_BM2


subplot(236)
MakeSpreadAndBoxPlot3_SB({nanmean(squeeze(Smooth_HR_interp{1}(2,:,:))')./nanmean(squeeze(Smooth_HR_interp{1}(1,:,:))')...
    nanmean(squeeze(Smooth_HR_interp{2}(2,:,:))')./nanmean(squeeze(Smooth_HR_interp{2}(1,:,:))')},Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('Heart rate (Hz)')
makepretty_BM2




figure
subplot(1,4,1:2)
[~,MaxPowerValues1,f1] = Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_Wake_Bef_Inj{1} , 'color' , 'k');
[~,MaxPowerValues2,f2] = Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_Wake_Bef_Inj{2} , 'color' , 'k');
[~,MaxPowerValues3,Freq_Max1] = Plot_MeanSpectrumForMice_BM((Spectro{3}.*OB_Wake_Aft_Inj{1})./MaxPowerValues1');
[~,MaxPowerValues4,Freq_Max2] = Plot_MeanSpectrumForMice_BM((Spectro{3}.*OB_Wake_Aft_Inj{2})./MaxPowerValues2');
clf
subplot(1,4,1:2)
Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_Wake_Aft_Inj{1} , 'color' , 'k' , 'power_norm_value' , MaxPowerValues1);
Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_Wake_Aft_Inj{2} , 'color' , 'g' , 'power_norm_value' , MaxPowerValues2);
xlim([20 100]), ylim([0 1.1])
makepretty, axis square
f=get(gca,'Children'); legend([f(5),f(1)],'Saline','Atropine');

subplot(143)
MakeSpreadAndBoxPlot3_SB({MaxPowerValues3 MaxPowerValues4},Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('OB gamma power (norm)')
makepretty_BM2

subplot(144)
MakeSpreadAndBoxPlot3_SB({Freq_Max1 Freq_Max2},Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('OB gamma freq (Hz)')
makepretty_BM2




figure
subplot(211)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Aft_interp{1}))',5)'), axis xy
caxis([4 4.8]), hline([40 60],'-r'), ylabel('Frequency (Hz)')
makepretty
title('Saline')
subplot(212)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Aft_interp{2}))',5)'), axis xy
caxis([4 5]), hline([40 60],'-r'), xlabel('time (h)'), ylabel('Frequency (Hz)')
makepretty
title('Atropine')



%% tools
figure
subplot(221)
plot(Spectro{3} , (Spectro{3}.*OB_Wake_Bef_Inj{1})'), xlim([20 100]), ylim([0 2.5e5])
subplot(222)
plot(Spectro{3} , (Spectro{3}.*OB_Wake_Aft_Inj{1})'), xlim([20 100]), ylim([0 2.5e5])
subplot(223)
plot(Spectro{3} , (Spectro{3}.*OB_Wake_Bef_Inj{2})'), xlim([20 100]), ylim([0 2.5e5])
subplot(224)
plot(Spectro{3} , (Spectro{3}.*OB_Wake_Aft_Inj{2})'), xlim([20 100]), ylim([0 2.5e5])



figure
Data_to_use = log10(Accelero_interp{1});
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,1000), Mean_All_Sp , Conf_Inter ,'-k',1); hold on
Data_to_use = log10(Accelero_interp{2});
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,1000), Mean_All_Sp , Conf_Inter ,'-r',1);


figure
Data_to_use = HR_interp{1};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,1000), Mean_All_Sp , Conf_Inter ,'-k',1); hold on
Data_to_use = HR_interp{2};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,1000), Mean_All_Sp , Conf_Inter ,'-r',1);




figure
for i=1:7
    try
        subplot(7,4,(i-1)*4+1)
        imagesc(linspace(0,1.5,100) , Spectro{3} , squeeze(Smooth_OB_Bef_interp{1}(i,:,:))), axis xy, caxis(c), ylim([20 70])
        hline([40 60],'-r')
    end
    try
        subplot(7,4,(i-1)*4+2)
        imagesc(linspace(0,1.5,100) , Spectro{3} , squeeze(Smooth_OB_Aft_interp{1}(i,:,:))), axis xy, caxis(c), ylim([20 70])
        hline([40 60],'-r')
    end
    try
        subplot(7,4,(i-1)*4+3)
        imagesc(linspace(0,1.5,100) , Spectro{3} , squeeze(Smooth_OB_Bef_interp{2}(i,:,:))), axis xy, caxis(c), ylim([20 70])
        hline([40 60],'-r')
    end
    try
        subplot(7,4,(i-1)*4+4)
        imagesc(linspace(0,1.5,100) , Spectro{3} , squeeze(Smooth_OB_Aft_interp{2}(i,:,:))), axis xy, caxis(c), ylim([20 70])
        hline([40 60],'-r')
    end
end



figure
subplot(221)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Bef_interp{1}))',5)'), axis xy
caxis([4 4.8]), hline([40 60],'-r'), ylabel('Frequency (Hz)')
title('Pre')
makepretty
subplot(222)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Aft_interp{1}))',5)'), axis xy
caxis([4 4.8]), hline([40 60],'-r')
makepretty
title('Post')
subplot(223)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Bef_interp{2}))',5)'), axis xy
caxis([4 5]), hline([40 60],'-r'), xlabel('time (h)'), ylabel('Frequency (Hz)')
makepretty
subplot(224)
imagesc(linspace(0,1.5,100) , Spectro{3} , runmean(squeeze(nanmean(Smooth_OB_Aft_interp{2}))',5)'), axis xy
caxis([4 5]), hline([40 60],'-r'), xlabel('time (h)')
makepretty




figure
subplot(2,5,1:2)
Data_to_use = squeeze(Smooth_Gamma_interp{1}(1,:,:))./nanmean(squeeze(Smooth_Gamma_interp{1}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,100), Mean_All_Sp , Conf_Inter ,'-k',1); hold on
Data_to_use = squeeze(Smooth_Gamma_interp{2}(1,:,:))./nanmean(squeeze(Smooth_Gamma_interp{2}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,100), Mean_All_Sp , Conf_Inter ,'-g',1);
makepretty
ylabel('OB Gamma power (norm)'), ylim([0 2])
title('Before injection')
f=get(gca,'Children'); legend([f(5),f(1)],'Saline','Atropine');

subplot(2,5,3:4)
Data_to_use = squeeze(Smooth_Gamma_interp{1}(2,:,:))./nanmean(squeeze(Smooth_Gamma_interp{1}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,100), Mean_All_Sp , Conf_Inter ,'-k',1); hold on
Data_to_use = squeeze(Smooth_Gamma_interp{2}(2,:,:))./nanmean(squeeze(Smooth_Gamma_interp{2}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,100), Mean_All_Sp , Conf_Inter ,'-g',1);
title('After injection'), ylim([0 2])
makepretty


subplot(2,5,6:7)
Data_to_use = squeeze(Smooth_HR_interp{1}(1,:,:))./nanmean(squeeze(Smooth_HR_interp{1}(1,:,:))')';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,100), Mean_All_Sp , Conf_Inter ,'-k',1); hold on
Data_to_use = squeeze(Smooth_HR_interp{2}(1,:,:))./nanmean(squeeze(Smooth_HR_interp{2}(1,:,:))')';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,100), Mean_All_Sp , Conf_Inter ,'-g',1);
makepretty
xlabel('time (norm)'), ylabel('Hear rate (Hz)'), ylim([.6 1.4])

subplot(2,5,8:9)
Data_to_use = squeeze(Smooth_HR_interp{1}(2,:,:))./nanmean(squeeze(Smooth_HR_interp{1}(1,:,:))')';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,100), Mean_All_Sp , Conf_Inter ,'-k',1); hold on
Data_to_use = squeeze(Smooth_HR_interp{2}(2,:,:))./nanmean(squeeze(Smooth_HR_interp{2}(1,:,:))')';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1,100), Mean_All_Sp , Conf_Inter ,'-g',1);
makepretty
xlabel('time (norm)'), ylim([.6 1.4])



%% cross-corr gamma frequencies Saline
clear all

Dir{1} = PathForExperimentsOB({'Shropshire'}, 'head-fixed', 'saline');
Dir{2} = PathForExperimentsOB({'Shropshire'}, 'head-fixed', 'atropine');

drug=1; sess=7;

load([Dir{drug}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SmoothGamma', 'inj_time')
% load([Dir{drug}.path{sess} filesep 'B_Middle_Spectrum.mat'])
Before_Injection = intervalSet(inj_time-1.5*3600e4 , inj_time);
After_Injection = intervalSet(inj_time , inj_time+1.5*3600e4);
B_Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
OB_Sp_Bef = Restrict(B_Sptsd,Before_Injection);
OB_Sp_Aft = Restrict(B_Sptsd,After_Injection);



D = log10(Data(OB_Sp_Aft))';
imagesc(linspace(0,1.5*60*60,length(D)) , Spectro{3} , smooth2a(D,5)), axis xy
caxis([2 4]),% xlim([.712 .715])
colormap viridis
xlabel('time (min)'), ylabel('Frequency (Hz)')
makepretty

figure
plot(nanmean(D'))

figure
imagesc(Spectro{3} , Spectro{3} , smooth2a(corr(D'),2))
xlabel('Frequency (Hz)'), ylabel('Frequency (Hz)')
makepretty, axis square
colorbar, xticks([10:10:100]), yticks([10:10:100])
caxis([0 .5])
colormap viridis

