
clear all

LineHeight = 9.5;
Colors.N1 = [1 .5 0];
Colors.N2 = 'r';
Colors.REM = 'g';
Colors.Wake = 'b';
Colors.Noise = 'k';

smootime = 10;

%%
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241130_LSP/')
load('SleepScoring_OBGamma.mat', 'CleanStates','SmoothTheta', 'SmoothGamma')

load([pwd filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
FilDelta = FilterLFP(LFP,[.5 4],1024);
hilbert_delta = abs(hilbert(Data(FilDelta)));
SmoothDelta_OB = tsd(Range(LFP),runmean(hilbert_delta,ceil(smootime/median(diff(Range(LFP,'s'))))));

load([pwd filesep 'ChannelsToAnalyse/PFCx_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
FilDelta = FilterLFP(LFP,[.5 4],1024);
hilbert_delta = abs(hilbert(Data(FilDelta)));
SmoothDelta_PFC = tsd(Range(LFP),runmean(hilbert_delta,ceil(smootime/median(diff(Range(LFP,'s'))))));

Bh = load('B_Middle_Spectrum.mat');
Bh_Sptsd = tsd(Bh.Spectro{2}*1e4 , Bh.Spectro{1});

H = load('H_Low_Spectrum.mat');
H_Sptsd = tsd(H.Spectro{2}*1e4 , H.Spectro{1});

B = load('B_Low_Spectrum.mat');
B_Sptsd = tsd(B.Spectro{2}*1e4 , B.Spectro{1});

P = load('PFCx_Low_Spectrum.mat');
P_Sptsd = tsd(P.Spectro{2}*1e4 , P.Spectro{1});


%% pharmacological confirmation
%% paper figures
figure
subplot(3,1,1:2)
R = Range(H_Sptsd); D = Data(H_Sptsd);
imagesc(R(1:2:end)/3.6e7 , H.Spectro{3} , runmean(runmean(log10(D(1:2:end,:)'),5)',50)'), axis xy
ylabel('Frequency (Hz)'), ylim([0 10]), caxis([3.5 5]), xticklabels({''}), c=caxis;
u=colorbar; u.Ticks=[c(1) c(2)]; u.TickLabels={'0','1'}; u.FontSize=15; u.Label.String = 'Power (a.u.)'; u.Label.FontSize=12; set(u.Label,'Rotation',270)
makepretty

PlotPerAsLine(CleanStates.Wake,LineHeight,Colors.Wake,'timescaling',3.6e7);
PlotPerAsLine(CleanStates.REM,LineHeight,Colors.REM,'timescaling',3.6e7);
PlotPerAsLine(CleanStates.N1,LineHeight,Colors.N1,'timescaling',3.6e7);
PlotPerAsLine(CleanStates.N2,LineHeight,Colors.N2,'timescaling',3.6e7);

subplot(313)
plot(Range(Restrict(SmoothTheta , CleanStates.Sleep),'s')/3.6e3 , runmean(Data(Restrict(SmoothTheta , CleanStates.Sleep)),1e4) , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)]), ylim([0 12])
xlabel('Time (h)'), ylabel('Theta power (a.u.)')
vline(2,'--r')
makepretty


%% extended 
figure
subplot(6,2,[1 3])
imagesc(Range(Bh_Sptsd)/3.6e7 , Bh.Spectro{3} , runmean(runmean(log10(Data(Bh_Sptsd)'),5)',50)'), axis xy
ylabel('HPC frequency (Hz)'), ylim([20 100]), caxis([3.5 5]), xticklabels({''}), 
% makepretty

% PlotPerAsLine(Wake,LineHeight,Colors.Wake,'timescaling',3.6e7);
% PlotPerAsLine(REMEpoch,LineHeight,Colors.REM,'timescaling',3.6e7);
% PlotPerAsLine(N1,LineHeight,Colors.N1,'timescaling',3.6e7);
% PlotPerAsLine(N2,LineHeight,Colors.N2,'timescaling',3.6e7);

subplot(625)
plot(Range(SmoothGamma,'s')/3.6e3 , runmean(Data(SmoothGamma),1e4) , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothGamma,'s')/3.6e3)]), xticklabels({''}), ylabel('OB gamma'),% ylim([0 12])
vline(2,'--r')
%text(2.1,12,'Atropine injection','FontSize',15,'Color','r')
% makepretty


subplot(6,2,[7 9])
imagesc(Range(H_Sptsd)/3.6e7 , H.Spectro{3} , runmean(runmean(log10(Data(H_Sptsd)'),5)',50)'), axis xy
ylabel('HPC frequency (Hz)'), ylim([0 10]), caxis([3.5 5]), xticklabels({''}), 
% makepretty

% PlotPerAsLine(Wake,LineHeight,Colors.Wake,'timescaling',3.6e7);
% PlotPerAsLine(REMEpoch,LineHeight,Colors.REM,'timescaling',3.6e7);
% PlotPerAsLine(N1,LineHeight,Colors.N1,'timescaling',3.6e7);
% PlotPerAsLine(N2,LineHeight,Colors.N2,'timescaling',3.6e7);

subplot(6,2,11)
plot(Range(Restrict(SmoothTheta , CleanStates.Sleep),'s')/3.6e3 , runmean(Data(Restrict(SmoothTheta , CleanStates.Sleep)),1e4) , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)]), ylim([0 12]), xticklabels({''}), ylabel('Theta/Delta')
% makepretty
vline(2,'--r')


subplot(6,2,[2 4])
imagesc(Range(B_Sptsd)/3.6e7 , B.Spectro{3} , runmean(runmean(log10(Data(B_Sptsd)'),5)',50)'), axis xy
ylabel('OB frequency (Hz)'), ylim([0 10]), caxis([3.5 5]), 
%makepretty

% PlotPerAsLine(Wake,LineHeight,Colors.Wake,'timescaling',3.6e7);
% PlotPerAsLine(REMEpoch,LineHeight,Colors.REM,'timescaling',3.6e7);
% PlotPerAsLine(N1,LineHeight,Colors.N1,'timescaling',3.6e7);
% PlotPerAsLine(N2,LineHeight,Colors.N2,'timescaling',3.6e7);

subplot(626)
plot(Range(Restrict(SmoothDelta_OB , CleanStates.Sleep),'s')/3.6e3 , runmean(Data(Restrict(SmoothDelta_OB , CleanStates.Sleep)),1e4) , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothDelta_OB,'s')/3.6e3)]), ylim([2e2 1e3])
xlabel('time (hours)'), ylabel('OB Delta power')
vline(2,'--r')
% makepretty


subplot(6,2,[8 10])
imagesc(Range(P_Sptsd)/3.6e7 , B.Spectro{3} , runmean(runmean(log10(Data(P_Sptsd)'),5)',50)'), axis xy
ylabel('PFC frequency (Hz)'), ylim([0 10]), caxis([3.5 5])
% makepretty

% PlotPerAsLine(Wake,LineHeight,Colors.Wake,'timescaling',3.6e7);
% PlotPerAsLine(REMEpoch,LineHeight,Colors.REM,'timescaling',3.6e7);
% PlotPerAsLine(N1,LineHeight,Colors.N1,'timescaling',3.6e7);
% PlotPerAsLine(N2,LineHeight,Colors.N2,'timescaling',3.6e7);

subplot(6,2,12)
plot(Range(Restrict(SmoothDelta_PFC , CleanStates.Sleep),'s')/3.6e3 , runmean(Data(Restrict(SmoothDelta_PFC , CleanStates.Sleep)),1e4) , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothDelta_PFC,'s')/3.6e3)]), ylim([0 1.2e3])
xlabel('time (hours)'), ylabel('PFC Delta power')
vline(2,'--r')
% makepretty


colormap viridis



%% all
clear all

Dir_atrop{1} = PathForExperimentsOB({'Labneh'}, 'freely-moving','atropine');
Dir_atrop{2} = PathForExperimentsOB({'Brynza'}, 'freely-moving','atropine');
Dir_atrop{3} = PathForExperimentsOB({'Shropshire'}, 'freely-moving','atropine');

Dir_saline{1} = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir_saline{2} = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir_saline{3} = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');

% Dir{1} = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
% Dir{2} = PathForExperimentsOB({'Shropshire'}, 'freely-moving', 'atropine');


for ferret=1:3
    for sess=1:length(Dir_atrop{ferret}.path)
        
        clear inj_time Sleep REMEpoch smooth_01_05 SWSEpoch
        load([Dir_atrop{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'Wake','Sleep','REMEpoch','SWSEpoch','Epoch', 'smooth_01_05', 'inj_time')
        %         load([Dir{ferret}.path{sess} filesep 'H_Low_Spectrum.mat'])
        %         H_Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
        %         load([Dir{ferret}.path{sess} filesep 'B_Low_Spectrum.mat'])
        %         B_Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
        
        try
            inj_time;
        catch
            inj_time = max(Range(smooth_01_05))/2;
        end
        
        % epochs
        Before_Injection = intervalSet(inj_time-2.2*3600e4 , -600e4+inj_time);
        After_Injection = intervalSet(inj_time+600e4 , inj_time+2.2*3600e4);
        
        % spectro
        %         HPC_Sp_Bef_NREM = Restrict(B_Sptsd,and(Before_Injection , SWSEpoch));
        %         HPC_Sp_Bef_REM = Restrict(B_Sptsd,and(Before_Injection , REMEpoch));
        %         HPC_Sp_Aft = Restrict(B_Sptsd,and(After_Injection , Sleep));
        %         OB_Sp_Bef_NREM = Restrict(H_Sptsd,and(Before_Injection , SWSEpoch));
        %         OB_Sp_Bef_REM = Restrict(H_Sptsd,and(Before_Injection , REMEpoch));
        %         OB_Sp_Aft = Restrict(H_Sptsd,and(After_Injection , Sleep));
        %
        %         % mean sp
        %         HPC_MeanSp_Bef_NREM{ferret}(sess,:) = nanmean(Data(HPC_Sp_Bef_NREM));
        %         HPC_MeanSp_Bef_REM{ferret}(sess,:) = nanmean(Data(HPC_Sp_Bef_REM));
        %         HPC_MeanSp_Aft{ferret}(sess,:) = nanmean(Data(HPC_Sp_Aft));
        %         OB_MeanSp_Bef_NREM{ferret}(sess,:) = nanmean(Data(OB_Sp_Bef_NREM));
        %         OB_MeanSp_Bef_REM{ferret}(sess,:) = nanmean(Data(OB_Sp_Bef_REM));
        %         OB_MeanSp_Aft{ferret}(sess,:) = nanmean(Data(OB_Sp_Aft));
        
        % states prop
        for states=1:3
            if states==1
                State = Wake;
            elseif states==2
                State = SWSEpoch;
            elseif states==3
                State = REMEpoch;
            end
            if states<2
                State_Prop_Pre_at{states}{ferret}(sess) = sum(DurationEpoch(and(State , Before_Injection)))./sum(DurationEpoch(Before_Injection));
                State_Prop_Post_at{states}{ferret}(sess) = sum(DurationEpoch(and(State , After_Injection)))./sum(DurationEpoch(After_Injection));
            else
                State_Prop_Pre_at{states}{ferret}(sess) = sum(DurationEpoch(and(State , Before_Injection)))./sum(DurationEpoch(and(Before_Injection,Sleep)));
                State_Prop_Post_at{states}{ferret}(sess) = sum(DurationEpoch(and(State , After_Injection)))./sum(DurationEpoch(and(Before_Injection,Sleep)));
            end
        end
        
        disp([ferret sess])
    end
    
    for sess=1:length(Dir_saline{ferret}.path)
        
        clear inj_time Sleep REMEpoch smooth_01_05 SWSEpoch
        load([Dir_saline{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'Wake','Sleep','REMEpoch','SWSEpoch','Epoch', 'smooth_01_05', 'inj_time')
        %         load([Dir{ferret}.path{sess} filesep 'H_Low_Spectrum.mat'])
        %         H_Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
        %         load([Dir{ferret}.path{sess} filesep 'B_Low_Spectrum.mat'])
        %         B_Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
        
        try
            inj_time;
        catch
            inj_time = max(Range(smooth_01_05))/2;
        end
        
        % epochs
        Before_Injection = intervalSet(inj_time-2.2*3600e4 , -600e4+inj_time);
        After_Injection = intervalSet(inj_time+600e4 , inj_time+2.2*3600e4);
        
        % spectro
        %         HPC_Sp_Bef_NREM = Restrict(B_Sptsd,and(Before_Injection , SWSEpoch));
        %         HPC_Sp_Bef_REM = Restrict(B_Sptsd,and(Before_Injection , REMEpoch));
        %         HPC_Sp_Aft = Restrict(B_Sptsd,and(After_Injection , Sleep));
        %         OB_Sp_Bef_NREM = Restrict(H_Sptsd,and(Before_Injection , SWSEpoch));
        %         OB_Sp_Bef_REM = Restrict(H_Sptsd,and(Before_Injection , REMEpoch));
        %         OB_Sp_Aft = Restrict(H_Sptsd,and(After_Injection , Sleep));
        %
        %         % mean sp
        %         HPC_MeanSp_Bef_NREM{ferret}(sess,:) = nanmean(Data(HPC_Sp_Bef_NREM));
        %         HPC_MeanSp_Bef_REM{ferret}(sess,:) = nanmean(Data(HPC_Sp_Bef_REM));
        %         HPC_MeanSp_Aft{ferret}(sess,:) = nanmean(Data(HPC_Sp_Aft));
        %         OB_MeanSp_Bef_NREM{ferret}(sess,:) = nanmean(Data(OB_Sp_Bef_NREM));
        %         OB_MeanSp_Bef_REM{ferret}(sess,:) = nanmean(Data(OB_Sp_Bef_REM));
        %         OB_MeanSp_Aft{ferret}(sess,:) = nanmean(Data(OB_Sp_Aft));
        
        % states prop
        for states=1:3
            if states==1
                State = Wake;
            elseif states==2
                State = SWSEpoch;
            elseif states==3
                State = REMEpoch;
            end
            if states<2
                State_Prop_Pre_sal{states}{ferret}(sess) = sum(DurationEpoch(and(State , Before_Injection)))./sum(DurationEpoch(Before_Injection));
                State_Prop_Post_sal{states}{ferret}(sess) = sum(DurationEpoch(and(State , After_Injection)))./sum(DurationEpoch(After_Injection));
            else
                State_Prop_Pre_sal{states}{ferret}(sess) = sum(DurationEpoch(and(State , Before_Injection)))./sum(DurationEpoch(and(Before_Injection,Sleep)));
                State_Prop_Post_sal{states}{ferret}(sess) = sum(DurationEpoch(and(State , After_Injection)))./sum(DurationEpoch(and(Before_Injection,Sleep)));
            end
        end
        
        disp([ferret sess])
    end
end

REM_pre_sal_all = []; REM_post_sal_all = [];
REM_pre_at_all = []; REM_post_at_all = [];
% MeanSp_HPC_Bef_NREM_all = []; MeanSp_HPC_Bef_REM_all = []; MeanSp_HPC_Aft_all = [];
% MeanSp_OB_Bef_NREM_all = []; MeanSp_OB_Bef_REM_all = []; MeanSp_OB_Aft_all = [];
for ferret=1:3
    REM_pre_sal_all = [REM_pre_sal_all State_Prop_Pre_sal{3}{ferret}];
    REM_post_sal_all = [REM_post_sal_all State_Prop_Post_sal{3}{ferret}];
    
    REM_pre_at_all = [REM_pre_at_all State_Prop_Pre_at{3}{ferret}];
    REM_post_at_all = [REM_post_at_all State_Prop_Post_at{3}{ferret}];
    
    %         MeanSp_HPC_Bef_NREM_all = [MeanSp_HPC_Bef_NREM_all ; HPC_MeanSp_Bef_NREM{ferret}(sess,:)];
    
end
REM_post_at_all(REM_post_at_all>.1)=NaN; % waiting to be corrected


% figures
Cols = {[.3 .3 .3],[.2 .8 .2]};
X = 1:2;
Legends = {'Post saline','Post atropine'};

figure
MakeSpreadAndBoxPlot3_SB({REM_post_sal_all REM_post_at_all},Cols,X,Legends,'showpoints',1,'paired',0,'size_points',10);
ylabel('REM prop')


figure
Data_to_use = HPC_MeanSp_Bef_NREM{3};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(Spectro{3} , nanmean(Data_to_use) , Conf_Inter ,'-r',1); hold on;
Data_to_use = HPC_MeanSp_Bef_REM{3};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(Spectro{3} , nanmean(Data_to_use) , Conf_Inter ,'-g',1); hold on;
Data_to_use = HPC_MeanSp_Aft{3};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(Spectro{3} , nanmean(Data_to_use) , Conf_Inter ,'-g',1); hold on;
col = [.6 .3 .3]; h.mainLine.Color=col; h.patch.FaceColor=col; h.edge(1).Color=col; h.edge(2).Color=col;
xlabel('Frequency (Hz)'), ylabel('Power (a.u.)'), xlim([0 10])
f=get(gca,'Children'); l=legend([f([9 5 1])],'REM bef','NREM bef','Sleep aft');
makepretty



%% EMG
load('ChannelsToAnalyse/EMG.mat', 'channel')
load(['LFPData/LFP' num2str(channel) '.mat'])

FilLFP = FilterLFP(LFP,[50 300],1024);
EMG_tsd = tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));


figure
plot(Range(EMG_tsd,'s')/3.6e3 , runmean(Data(EMG_tsd),1e4) , 'k' , 'LineWidth',1)
xlim([0 max(Range(EMG_tsd,'s')/3.6e3)]),% ylim([0 1.2e3])
xlabel('Time (hours)'), ylabel('EMG power')
yyaxis right
plot(Range(SmoothTheta,'s')/3.6e3 , runmean(Data(SmoothTheta),1e4) , 'k' , 'LineWidth',1)
makepretty





%% influence on OB gamma


load('SleepScoring_OBGamma.mat')


smootime = 30;
load([pwd filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
LFP = Restrict(LFP , Sleep);
% LFP = Restrict(LFP , and(Sleep , intervalSet(0 , 2*3600e4)));
FilGamma = FilterLFP(LFP,[40 75],1024);
hilbert_gamma = abs(hilbert(Data(FilGamma)));
SmoothGamma_wide = tsd(Range(LFP),runmean(hilbert_gamma,ceil(smootime/median(diff(Range(LFP,'s'))))));
theta_thresh = exp(GetThetaThresh(log(Data(Restrict(SmoothGamma_wide , intervalSet(0 , 2*3600e4)))), 1, 1)); close
GammaEpoch_OB = thresholdIntervals(SmoothGamma_wide, theta_thresh, 'Direction','Above');
SmoothGamma_wide = Restrict(SmoothGamma_wide , Sleep);

B1 = load([pwd filesep 'B_Middle_Spectrum.mat']);
B_High_Sptsd = tsd(B1.Spectro{2}*1e4 , B1.Spectro{1});
Range_Mid = B1.Spectro{3};

H = load([pwd filesep 'H_Low_Spectrum.mat']);
H_Sptsd = tsd(H.Spectro{2}*1e4 , H.Spectro{1});

LineHeight = 9.5;
Colors.N1 = [1 .5 0];
Colors.N2 = [1 0 0];
Colors.REM = 'g';
Colors.Wake = 'b';
Colors.Noise = 'k';



figure
subplot(411) % OB High
clear D R, D = Data(B_High_Sptsd); D = D(1:100:end,:); R = Range(B_High_Sptsd); R = R(1:100:end);
imagesc(R/3.6e7 , B1.Spectro{3} , runmean(runmean(log10(D'),2)',50)'), axis xy
ylabel('OB frequency (Hz)')
colormap viridis, ylim([30 100]), caxis([2.6 2.7]), xticklabels({''}), box off
xlim([0 4.5])

PlotPerAsLine(CleanStates.Wake,97,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(CleanStates.REM,97,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(CleanStates.N1,97,Colors.N1,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(CleanStates.N2,97,Colors.N2,'timescaling',3.6e7,'linewidth',10);

subplot(412)
clear D R, D = movmean(Data(SmoothGamma_wide),5e4,'omitnan'); D(D>800) = NaN; D = D(1:100:end); R = Range(SmoothGamma_wide); R = R(1:100:end);
plot(R/3.6e7 , D , '.k' , 'MarkerSize',1)
xlim([0 max(Range(SmoothGamma_wide,'s')/3.6e3)]), xticklabels({''})
box off
ylabel('OB Gamma power')
xlim([0 4.5]), ylim([190 270])
hline(theta_thresh,'--r')


subplot(413) % HPC 
imagesc(Range(H_Sptsd)/3.6e7 , H.Spectro{3} , runmean(runmean(log10(Data(H_Sptsd)'),5)',50)'), axis xy
ylabel('HPC Frequency (Hz)'), ylim([0 10]), caxis([3.5 5]), xticklabels({''}), box off
xlim([0 4.5])

PlotPerAsLine(CleanStates.Wake,9.5,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(CleanStates.REM,9.5,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(CleanStates.N1,9.5,Colors.N1,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(CleanStates.N2,9.5,Colors.N2,'timescaling',3.6e7,'linewidth',10);

subplot(414)
clear R D, D = movmean(Data(SmoothTheta),1e4,'omitnan'); D(D>14.5) = NaN; D = D(1:100:end); R = Range(SmoothTheta); R = R(1:100:end);
plot(R/3.6e7 , D , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)]), ylim([0 12]), xlim([0 4.5])
box off
ylabel('HPC Theta/Delta'), xlabel('Time (hours)')







%% plot 2d


cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241126_LSP/')



load('SleepScoring_OBGamma.mat', 'Epoch', 'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch', 'SmoothGamma', 'SmoothTheta', 'Epoch_S1', 'Epoch_S2')
smootime = 3;


load('ChannelsToAnalyse/EMG.mat', 'channel')
load(['LFPData/LFP' num2str(channel) '.mat'])

Epoch = intervalSet(0 , 2e7);
LFP = Restrict(LFP , Epoch);
FilLFP=FilterLFP(LFP,[50 300],1024);
EMGData=tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));
EMGData=Restrict(EMGData,Epoch);

SmoothGamma = Restrict(SmoothGamma , Epoch);
SmoothGamma_intf = Restrict(SmoothGamma,EMGData);


figure
subplot(6,6,32:36)
[Y,X] = hist(log10(Data(SmoothGamma)),1000);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
box off
v1=vline(2.5,'-r'); v1.LineWidth=3;
xlabel('OB gamma power (log scale)'); xlim([2.1 3.1])

subplot(6,6,[25 19 13 7 1])
[Y,X] = hist(log10(Data(EMGData)),1000);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
set(gca,'XDir','reverse'), camroll(270), box off
v2=vline(3.5,'-r'); v2.LineWidth=3;
xlabel('EMG power (log scale)'), xlim([2.5 6])

subplot(6,6,[2:6 8:12 14:18 20:24 26:30])
X = log10(Data(SmoothGamma_intf)); Y = log10(Data(EMGData));
plot(X(1:500:end) , Y(1:500:end) , '.k' , 'MarkerSize' , 3)
axis square
xlim([2.1 3.1]), ylim([2.5 6])
v1=vline(2.5,'-r'); v1.LineWidth=3;
v2=hline(3.5,'-r'); v2.LineWidth=3;






clear all

load('SleepScoring_OBGamma.mat', 'Epoch', 'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch', 'SmoothGamma', 'SmoothTheta', 'Epoch_S1', 'Epoch_S2')
smootime = 3;


load('ChannelsToAnalyse/EMG.mat', 'channel')
load(['LFPData/LFP' num2str(channel) '.mat'])

Epoch = intervalSet(8.5e7 , 11e7);
LFP = Restrict(LFP , Epoch);
FilLFP=FilterLFP(LFP,[50 300],1024);
EMGData=tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));
EMGData=Restrict(EMGData,Epoch);

SmoothGamma = Restrict(SmoothGamma , Epoch);
SmoothGamma_intf = Restrict(SmoothGamma,EMGData);


figure
subplot(6,6,32:36)
[Y,X] = hist(log10(Data(SmoothGamma)),1000);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
box off
v1=vline(2.5,'-r'); v1.LineWidth=3;
xlabel('OB gamma power (log scale)'); xlim([2.1 3.1])

subplot(6,6,[25 19 13 7 1])
[Y,X] = hist(log10(Data(EMGData)),1000);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
set(gca,'XDir','reverse'), camroll(270), box off
v2=vline(3.5,'-r'); v2.LineWidth=3;
xlabel('EMG power (log scale)'), xlim([2.5 6])

subplot(6,6,[2:6 8:12 14:18 20:24 26:30])
X = log10(Data(SmoothGamma_intf)); Y = log10(Data(EMGData));
plot(X(1:500:end) , Y(1:500:end) , '.k' , 'MarkerSize' , 3)
axis square
xlim([2.1 3.1]), ylim([2.5 6])
v1=vline(2.5,'-r'); v1.LineWidth=3;
v2=hline(3.5,'-r'); v2.LineWidth=3;




