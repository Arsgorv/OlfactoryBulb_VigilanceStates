
clear all
load('/media/nas7/React_Passive_AG/OBG/Data_Paper/TransitionsEMG_OB_new.mat')


ferret=1; sess=18;

% EMG-OB
figure
subplot(121)
Data_to_use = EMG_Data_WakeSleep{ferret}{sess}; 
Data_to_use = zscore(log10(Data_to_use(:,1:500:end))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
hold on
Data_to_use = Gamma_Data_WakeSleep{ferret}{sess}; 
Data_to_use = zscore(log10(Data_to_use(:,1:500:end))')'; Data_to_use(4,:)=NaN;
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.6 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
text(-3,1.2,'Wake','FontSize',15), text(3,1.2,'Sleep','FontSize',15)
xlabel('Time (s)'), ylabel('Norm. power'), ylim([-1.5 2.2])
f=get(gca,'Children'); legend([f([5 3])],'EMG','OB');
box off, vline(0,'--r')

subplot(122)
Data_to_use = EMG_Data_SleepWake{ferret}{sess}; 
Data_to_use = zscore(log10(Data_to_use(:,1:500:end))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
hold on
Data_to_use = Gamma_Data_SleepWake{ferret}{sess}; 
Data_to_use = zscore(log10(Data_to_use(:,1:500:end))')'; Data_to_use(4,:)=NaN;
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.6 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
text(-3,1.2,'Wake','FontSize',15), text(3,1.2,'Sleep','FontSize',15)
xlabel('Time (s)'), ylabel('Norm. power'), ylim([-1.5 2.2])
box off, vline(0,'--r')






% Acc-OB
figure
subplot(121)
Data_to_use = Acc_Data_WakeSleep{ferret}{sess}; 
Data_to_use = zscore(log10(Data_to_use(:,1:20:end))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
hold on
Data_to_use = Gamma_Data_WakeSleep{ferret}{sess}; 
Data_to_use = zscore(log10(Data_to_use(:,1:500:end))')'; Data_to_use(4,:)=NaN;
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.6 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
text(-3,1.2,'Wake','FontSize',15), text(3,1.2,'Sleep','FontSize',15)
xlabel('Time (s)'), ylabel('Norm. power'), ylim([-1.5 2.2])
f=get(gca,'Children'); legend([f([5 3])],'Motion','OB');
box off, vline(0,'--r')

subplot(122)
Data_to_use = Acc_Data_SleepWake{ferret}{sess}; 
Data_to_use = zscore(log10(Data_to_use(:,1:20:end))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
hold on
Data_to_use = Gamma_Data_SleepWake{ferret}{sess}; 
Data_to_use = zscore(log10(Data_to_use(:,1:500:end))')'; Data_to_use(4,:)=NaN;
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.6 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
text(-3,1.2,'Wake','FontSize',15), text(3,1.2,'Sleep','FontSize',15)
xlabel('Time (s)'), ylabel('Norm. power'), ylim([-1.5 2.2])
box off, vline(0,'--r')




%%
clear all

% sessions
Dir1 = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);

minduration = 3;
smootime = 1;
win = 20; % window around transition in s

%%
for ferret=1:3
    for sess=1:length(Dir{ferret}.path)
        try
            
            load([Dir{ferret}.path{sess} filesep 'SleepScoring_Accelero.mat'],  'Wake', 'Sleep','SWSEpoch','Epoch', 'TotalNoiseEpoch')
            load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'],'SmoothGamma')
            load([Dir{ferret}.path{sess} filesep 'ChannelsToAnalyse/EMG.mat'], 'channel')
            load([Dir{ferret}.path{sess} filesep 'LFPData/LFP' num2str(channel) '.mat'])
            load([Dir{ferret}.path{sess} filesep 'behavResources.mat'], 'MovAcctsd')
            
            if sum(DurationEpoch(SWSEpoch))/3600e4>1
%                 LFP = Restrict(LFP , Epoch);
                FilLFP = FilterLFP(LFP,[50 300],1024);
                EMG_tsd = tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));
                Acc_tsd = tsd(Range(MovAcctsd),runmean_BM(Data(MovAcctsd),ceil(smootime/median(diff(Range(MovAcctsd,'s'))))));
                
                Wake = or(Wake,TotalNoiseEpoch);
                Wake = mergeCloseIntervals(Wake,1e4);
                Wake = dropShortIntervals(Wake,30e4);
                Sleep = dropShortIntervals(Sleep,30e4);
                
                [~,bef_cell]=transEpoch(Sleep,Wake);
                
                clear Trans_Wake_Sleep Trans_Sleep_Wake
                Trans_Wake_Sleep = Start(bef_cell{1,2}); % beginning of all sleep that is preceded by Wake
                Trans_Sleep_Wake = Start(bef_cell{2,1}); % beginning of all Wake  that is preceded by sleep
                
                for i=1:length(Trans_Wake_Sleep)
                    SmallEp = intervalSet(Trans_Wake_Sleep(i)-win*1e4 , Trans_Wake_Sleep(i)+win*1e4);
                    EMG_Data_WakeSleep{ferret}{sess}(i,1:length(Data(Restrict(EMG_tsd , SmallEp)))) = Data(Restrict(EMG_tsd , SmallEp));
                    Gamma_Data_WakeSleep{ferret}{sess}(i,1:length(Data(Restrict(SmoothGamma , SmallEp)))) = Data(Restrict(SmoothGamma , SmallEp));
                    Acc_Data_WakeSleep{ferret}{sess}(i,1:length(Data(Restrict(Acc_tsd , SmallEp)))) = Data(Restrict(Acc_tsd , SmallEp));
                end
                for i=1:length(Trans_Sleep_Wake)
                    SmallEp = intervalSet(Trans_Sleep_Wake(i)-win*1e4 , Trans_Sleep_Wake(i)+win*1e4);
                    EMG_Data_SleepWake{ferret}{sess}(i,1:length(Data(Restrict(EMG_tsd , SmallEp)))) = Data(Restrict(EMG_tsd , SmallEp));
                    Gamma_Data_SleepWake{ferret}{sess}(i,1:length(Data(Restrict(SmoothGamma , SmallEp)))) = Data(Restrict(SmoothGamma , SmallEp));
                    Acc_Data_SleepWake{ferret}{sess}(i,1:length(Data(Restrict(Acc_tsd , SmallEp)))) = Data(Restrict(Acc_tsd , SmallEp));
                end
                
                Z{ferret}{sess}{1} = zscore(EMG_Data_WakeSleep{ferret}{sess}')';
                ind = nanmean(Z{ferret}{sess}{1}(:,1:2e3)')<0;
                Z{ferret}{sess}{1}(ind,:) = NaN;
                
                Z{ferret}{sess}{2} = zscore(Gamma_Data_WakeSleep{ferret}{sess}')';
                Z{ferret}{sess}{2}(ind,:) = NaN;
                
                Z{ferret}{sess}{3} = zscore(Acc_Data_WakeSleep{ferret}{sess}')';
                Z{ferret}{sess}{3}(ind,:) = NaN;
                
                Z{ferret}{sess}{4} = zscore(EMG_Data_SleepWake{ferret}{sess}')';
                ind = nanmean(Z{ferret}{sess}{4}(:,1:2e3)')>.7;
                Z{ferret}{sess}{4}(ind,:) = NaN;
                
                Z{ferret}{sess}{5} = zscore(Gamma_Data_SleepWake{ferret}{sess}')';
                Z{ferret}{sess}{5}(ind,:) = NaN;
                
                Z{ferret}{sess}{6} = zscore(Acc_Data_SleepWake{ferret}{sess}')';
                Z{ferret}{sess}{6}(ind,:) = NaN;
                
                for i=1:6
                    MeanData{ferret}{i}(sess,:) = runmean(nanmean(Z{ferret}{sess}{i}),round(length(Z{ferret}{sess}{i})/10));
                end
                
                disp([ferret,sess])
                
            end
        end
    end
end

for ferret=1:3
    for i=1:6
        MeanData{ferret}{i}(MeanData{ferret}{i}==0) = NaN;
    end
end


%%
% EMG-OB
figure
subplot(121)
Data_to_use = MeanData{ferret}{1}; Data_to_use = Data_to_use(:,1:500:end);
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
Data_to_use = MeanData{ferret}{2}; Data_to_use = Data_to_use(:,1:500:end);
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.6 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
f=get(gca,'Children'); legend([f([3 1])],'EMG','OB');
makepretty
text(-3,1.2,'Wake','FontSize',15), text(3,1.2,'Sleep','FontSize',15)
vline(0,'--r'), xlabel('time (s)'), ylabel('Norm. power'), ylim([-1 2])

subplot(122)
Data_to_use = MeanData{ferret}{4}; Data_to_use = Data_to_use(:,1:500:end);
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
Data_to_use = MeanData{ferret}{5}; Data_to_use = Data_to_use(:,1:500:end);
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.6 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
makepretty
text(-3,1.2,'Sleep','FontSize',15), text(3,1.2,'Wake','FontSize',15)
vline(0,'--r'), xlabel('time (s)'), ylabel('Norm. power'), ylim([-1 2])



% Acc-OB
figure
subplot(121)
Data_to_use = MeanData{ferret}{3}; Data_to_use = Data_to_use(:,1:50:end);
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
Data_to_use = MeanData{ferret}{2}; Data_to_use = Data_to_use(:,1:500:end);
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
color= [.6 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color;
f=get(gca,'Children'); legend([f([3 1])],'Motion','OB');
makepretty
text(-3,1.2,'Wake','FontSize',15), text(3,1.2,'Sleep','FontSize',15)
xlabel('time (s)'), ylabel('Norm. power'), ylim([-1 2.5]), vline(0,'--r')

subplot(122)
Data_to_use = MeanData{ferret}{6}; Data_to_use = Data_to_use(:,1:50:end);
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
color= [.2 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
Data_to_use = MeanData{ferret}{5}; Data_to_use = Data_to_use(:,1:500:end);
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(linspace(-win,win,length(Data_to_use)) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
color= [.6 .2 .2]; h.mainLine.Color=color; h.patch.FaceColor=color; 
makepretty
text(-3,1.2,'Sleep','FontSize',15), text(3,1.2,'Wake','FontSize',15)
xlabel('time (s)'), ylabel('Norm. power'), ylim([-1 2.5]), vline(0,'--r')





