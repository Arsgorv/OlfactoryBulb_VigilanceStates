

%% preliminary parameters and variables
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs/') % not sure about session here
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241211_TORCs/') % not sure about session here

load([pwd filesep 'SleepScoring_OBGamma.mat'], 'Wake','Epoch','Sleep', 'REMEpoch','ISEpoch','SWSEpoch','SmoothDelta_OB','SmoothTheta')
smootime = 10;

load([pwd filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
FilGamma = FilterLFP(LFP,[50 75],1024);
hilbert_gamma = abs(hilbert(Data(FilGamma)));
SmoothGamma_wide = tsd(Range(LFP),runmean(hilbert_gamma,ceil(smootime/median(diff(Range(LFP,'s'))))));


% spectro
% B1 = load([pwd filesep 'B_Middle_Spectrum.mat']);
% B_High_Sptsd = tsd(B1.Spectro{2}*1e4 , B1.Spectro{1});
% Range_Mid = B1.Spectro{3};
% 
% H = load([pwd filesep 'H_Low_Spectrum.mat']);
% H_Sptsd = tsd(H.Spectro{2}*1e4 , H.Spectro{1});
% 
% B2 = load([pwd filesep 'B_Low_Spectrum.mat']);
% B_Low_Sptsd = tsd(B2.Spectro{2}*1e4 , B2.Spectro{1});


%% defining sleep cycles with REM ends
REMEpoch = mergeCloseIntervals(REMEpoch , 3*60e4);
REMEpoch = dropShortIntervals(REMEpoch , 60e4);
Dur_REM = DurationEpoch(REMEpoch)/60e4;
Sto = Stop(REMEpoch); % start of sleep cycle
SleepCycle = intervalSet(Sto(1:end-1) , Sto(2:end));
Dur_SleepCyc = DurationEpoch(SleepCycle)/60e4;

clear Wake_prop IS_prop NREM_prop REM_prop
for s = 1:length(Sto)-1
    SmallEp = subset(SleepCycle , s);
    
    % variables
    clear D
    D = Data(Restrict(SmoothGamma_wide , subset(SleepCycle , s)));
    Gamma_interp(s,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
    clear D
    D = Data(Restrict(SmoothTheta , subset(SleepCycle , s)));
    Theta_interp(s,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
    clear D
    D = Data(Restrict(SmoothDelta_OB , subset(SleepCycle , s)));
    Delta_interp(s,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
    
    % states
    clear Wake_prop_pre IS_prop_pre NREM_prop_pre REM_prop_pre
    for i = 1:ceil(Dur_SleepCyc(s))-1
        Wake_prop_pre(i) = sum(DurationEpoch(and(Wake , intervalSet(Start(SmallEp)+(i-1)*60e4 , Start(SmallEp)+i*60e4))))/60e4;
        IS_prop_pre(i) = sum(DurationEpoch(and(ISEpoch , intervalSet(Start(SmallEp)+(i-1)*60e4 , Start(SmallEp)+i*60e4))))/60e4;
        NREM_prop_pre(i) = sum(DurationEpoch(and(SWSEpoch , intervalSet(Start(SmallEp)+(i-1)*60e4 , Start(SmallEp)+i*60e4))))/60e4;
        REM_prop_pre(i) = sum(DurationEpoch(and(REMEpoch , intervalSet(Start(SmallEp)+(i-1)*60e4 , Start(SmallEp)+i*60e4))))/60e4;
    end
    Wake_prop(s,:) = interp1(linspace(0,1,length(Wake_prop_pre)) , Wake_prop_pre , linspace(0,1,20));
    IS_prop(s,:) = interp1(linspace(0,1,length(IS_prop_pre)) , IS_prop_pre , linspace(0,1,20));
    NREM_prop(s,:) = interp1(linspace(0,1,length(NREM_prop_pre)) , NREM_prop_pre , linspace(0,1,20));
    REM_prop(s,:) = interp1(linspace(0,1,length(REM_prop_pre)) , REM_prop_pre , linspace(0,1,20));
    
%     % spectro
%     clear D
%     D = Data(Restrict(B_High_Sptsd , subset(SleepCycle , s))); D = D(1:100:end,:);
%     for i=1:77
%         B_High_Sp_Interp(s,i,:) = interp1(linspace(0,1,length(D(:,i))) , D(:,i) , linspace(0,1,100));
%     end
%     clear D
%     D = Data(Restrict(H_Sptsd , subset(SleepCycle , s))); D = D(1:2:end,:);
%     for i=1:261
%         H_Low_Sp_Interp(s,i,:) = interp1(linspace(0,1,length(D(:,i))) , D(:,i) , linspace(0,1,100));
%     end
%     clear D
%     D = Data(Restrict(B_Low_Sptsd , subset(SleepCycle , s))); D = D(1:2:end,:);
%     for i=1:261
%         B_Low_Sp_Interp(s,i,:) = interp1(linspace(0,1,length(D(:,i))) , D(:,i) , linspace(0,1,100));
%     end
end
Gamma_interp(10,:)=NaN;
B_High_Sp_Interp(10,:,:) = NaN;
H_Low_Sp_Interp(10,:,:) = NaN;
B_Low_Sp_Interp(10,:,:) = NaN;


%% figures
% states probability
figure
b=bar([nanmean(Wake_prop) ; nanmean(IS_prop) ; nanmean(NREM_prop) ; nanmean(REM_prop)]' , 'BarLayout' , 'stacked');
b(1).FaceColor = 'b'; 
b(2).FaceColor = [1 .5 0]; 
b(3).FaceColor = 'r';
b(4).FaceColor = 'g';
xticks([0:10:20]), xticklabels({'0','.5','1'}), xticklabels({'0','.5','1','1.5','2'}), xlabel('Time (sleep cycle)')
ylabel('States proportion'), ylim([0 1])
legend('Wake','IS','NREM','REM')
box off


% mean variables temporal evolution
figure
Data_to_use = zscore(Gamma_interp')';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h = shadedErrorBar(linspace(0 , 1 , 100) , nanmean(Data_to_use) , Conf_Inter,'-r',1); hold on; 
color= [1 .5 .5]; h.mainLine.Color=color; h.patch.FaceColor=color;
Data_to_use = zscore(Theta_interp')';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h = shadedErrorBar(linspace(0 , 1 , 100) , nanmean(Data_to_use) , Conf_Inter,'-r',1); hold on; 
color= [.5 .5 1]; h.mainLine.Color=color; h.patch.FaceColor=color;
Data_to_use = zscore(Delta_interp')';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h = shadedErrorBar(linspace(0 , 1 , 100) , nanmean(Data_to_use) , Conf_Inter,'-r',1); hold on; 
color= [.5 1 .5]; h.mainLine.Color=color; h.patch.FaceColor=color;
f=get(gca,'Children'); l=legend([f([6 4 2])],'OB gamma','HPC theta','OB delta');
xticks([0:.5:1]), xticklabels({'0','.5','1'}), xlabel('Time (sleep cycle)')
ylabel('Power (zscore)'), ylim([-1.5 2])
box off


% mean spectro
figure
subplot(311)
imagesc([1:200] , B1.Spectro{3} , [runmean(runmean(log10(squeeze(nanmean(B_High_Sp_Interp))),5)',5)' runmean(runmean(log10(squeeze(nanmean(B_High_Sp_Interp))),5)',5)']), axis xy
ylabel('OB frequency (Hz)'), ylim([20 100]), xticklabels({''}), caxis([2.1 3.6])
box off

subplot(312)
imagesc([1:200] , B2.Spectro{3} , [runmean(runmean(log10(squeeze(nanmean(H_Low_Sp_Interp))),5)',5)' runmean(runmean(log10(squeeze(nanmean(H_Low_Sp_Interp))),5)',5)']), axis xy
ylabel('HPC Frequency (Hz)'), ylim([0 10]), xticklabels({''}), caxis([3.5 5])
box off

subplot(313)
imagesc([1:200] , B2.Spectro{3} , [runmean(runmean(log10(squeeze(nanmean(B_Low_Sp_Interp))),5)',5)' runmean(runmean(log10(squeeze(nanmean(B_Low_Sp_Interp))),5)',5)']), axis xy
ylabel('OB Frequency (Hz)'), ylim([0 10]), xticks([0:50:200]), xticklabels({'0','.5','1','1.5','2'}), xlabel('Time (sleep cycle)'), caxis([3.5 4.8])
box off

colormap viridis



% pie chart
figure
a= pie([nanmean(nanmean(Wake_prop)) ; nanmean(nanmean(IS_prop)) ; nanmean(nanmean(NREM_prop)) ; nanmean(nanmean(REM_prop))]); 
set(a(1), 'FaceColor', 'b'); set(a(3), 'FaceColor', [1 .5 0]); set(a(5), 'FaceColor', 'r'); set(a(7), 'FaceColor', 'g');




%% tools




