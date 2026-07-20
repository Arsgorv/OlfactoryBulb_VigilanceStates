
clear all

cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20250103_LSP_saline')
% cd('/media/nas7/React_Passive_AG/OBG/Brynza/freely-moving/20240123_long/')
% cd('/media/nas7/React_Passive_AG/OBG/Labneh/freely-moving/20221221_long/')


% %% create data for session if necessary
% MakeCleanStates_Ferret_BM
% 
% CreateDeltaWavesSleep
% movefile('DeltaWaves.mat','DeltaWaves_PFCx.mat')
% CreateDeltaWavesSleep('structure','Bulb')
% movefile('DeltaWaves.mat','DeltaWaves_Bulb.mat')


%%
load('SleepScoring_OBGamma.mat', 'CleanStates')
load('DeltaWaves_Bulb.mat', 'deltas_Bulb')
load('DeltaWaves_PFCx.mat', 'deltas_PFCx')

load('ChannelsToAnalyse/Bulb_deep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M1,~] = PlotRipRaw(LFP, Start(and(deltas_Bulb , CleanStates.REM))/1e4 , 500, 1, 0, 0);
[M2,~] = PlotRipRaw(LFP, Start(and(deltas_Bulb , CleanStates.N1))/1e4 , 500, 1, 0, 0);
[M3,~] = PlotRipRaw(LFP, Start(and(deltas_Bulb , CleanStates.N2))/1e4 , 500, 1, 0, 0);

load('ChannelsToAnalyse/Bulb_sup.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M4,~] = PlotRipRaw(LFP, Start(and(deltas_Bulb , CleanStates.REM))/1e4 , 500, 1, 0, 0);
[M5,~] = PlotRipRaw(LFP, Start(and(deltas_Bulb , CleanStates.N1))/1e4 , 500, 1, 0, 0);
[M6,~] = PlotRipRaw(LFP, Start(and(deltas_Bulb , CleanStates.N2))/1e4 , 500, 1, 0, 0);


load('ChannelsToAnalyse/PFCx_deep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M7,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , CleanStates.REM))/1e4 , 500, 1, 0, 0);
[M8,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , CleanStates.N1))/1e4 , 500, 1, 0, 0);
[M9,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , CleanStates.N2))/1e4 , 500, 1, 0, 0);

load('ChannelsToAnalyse/PFCx_sup.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M10,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , CleanStates.REM))/1e4 , 500, 1, 0, 0);
[M11,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , CleanStates.N1))/1e4 , 500, 1, 0, 0);
[M12,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , CleanStates.N2))/1e4 , 500, 1, 0, 0);


figure
subplot(121)
shadedErrorBar(M1(:,1), runmean(M3(:,2),5) , runmean(M3(:,4),5) ,'-b',1);
hold on
shadedErrorBar(M1(:,1), runmean(M6(:,2),5)-5e2 , runmean(M6(:,4),5) ,'-r',1);
xlabel('Time (s)'), ylabel('Amplitude (a.u.)'), t=title(['OB, n = ' num2str(length(Start(and(deltas_Bulb , CleanStates.N2)))) ' events']); t.FontSize=10;
ylim([-1.2e3 1.5e3])
makepretty
vline(0,'--k')
f=get(gca,'Children'); legend([f([3 1])],'deep','sup');

subplot(122)
shadedErrorBar(M1(:,1), runmean(M9(:,2),5) , runmean(M9(:,4),5) ,'-b',1);
hold on
shadedErrorBar(M1(:,1), runmean(M12(:,2),5)-7e2 , runmean(M12(:,4),5) ,'-r',1);
xlabel('Time (s)'), ylabel('Amplitude (a.u.)'), t=title(['PFC, n = ' num2str(length(Start(and(deltas_Bulb , CleanStates.N2)))) ' events']); t.FontSize=10;
ylim([-1.2e3 1.5e3])
makepretty
vline(0,'--k')


%% cross-corr
load('SleepScoring_OBGamma.mat', 'CleanStates')
load('DeltaWaves_Bulb.mat')
load('DeltaWaves_PFCx.mat')

% Get event times in seconds
ts1 = Start(and(deltas_Bulb , CleanStates.N2)) / 1e4;
ts2 = Start(and(deltas_PFCx , CleanStates.N2)) / 1e4;

% Parameters
binSize = 0.1; % seconds
win = 10;      % seconds
edges = -win:binSize:win;
binCenters = edges(1:end-1) + binSize/2;

% -------- Cross-correlation ts1 vs ts2 --------
ccg_counts = zeros(size(edges)-[0 1]);
for i = 1:length(ts1)
    diffs = ts2 - ts1(i);
    diffs = diffs(abs(diffs) <= win);
    ccg_counts = ccg_counts + histcounts(diffs, edges);
end

% -------- Auto-correlation ts1 (Bulb) --------
acg1_counts = zeros(size(edges)-[0 1]);
for i = 1:length(ts1)
    diffs = ts1 - ts1(i);
    diffs(diffs==0) = []; % remove self
    diffs = diffs(abs(diffs) <= win);
    acg1_counts = acg1_counts + histcounts(diffs, edges);
end

% -------- Auto-correlation ts2 (PFCx) --------
acg2_counts = zeros(size(edges)-[0 1]);
for i = 1:length(ts2)
    diffs = ts2 - ts2(i);
    diffs(diffs==0) = []; % remove self
    diffs = diffs(abs(diffs) <= win);
    acg2_counts = acg2_counts + histcounts(diffs, edges);
end

% -------- Plot results --------
figure;

subplot(131)
bar(binCenters, ccg_counts, 1, 'FaceColor','k','FaceAlpha',.7)
xlabel('Time lag (s)'); ylabel('Count')
title('Cross-correlogram: PFCx relative to Bulb')
xlim([-4 4]); xticks(-4:2:4)

subplot(132)
bar(binCenters, acg1_counts, 1, 'FaceColor','b','FaceAlpha',.7)
xlabel('Time lag (s)'); ylabel('Count')
title('Auto-correlogram: Bulb events')
xlim([-4 4]); xticks(-4:2:4)

subplot(133)
bar(binCenters, acg2_counts, 1, 'FaceColor','r','FaceAlpha',.7)
xlabel('Time lag (s)'); ylabel('Count')
title('Auto-correlogram: PFCx events')
xlim([-4 4]); xticks(-4:2:4)



%% all ferrets
clear all

Dir1 = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);


%
for ferret=1:3
    for sess=1:length(Dir{ferret}.path)
        clear CleanStates deltas_Bulb
        try
            load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'],'CleanStates')
            load([Dir{ferret}.path{sess} filesep 'DeltaWaves_Bulb.mat'])
            
            DeltaWaveDens_REM{ferret}(sess) = length(Start(and(deltas_Bulb , CleanStates.REM)))./(sum(DurationEpoch(CleanStates.REM))./1e4);
            DeltaWaveDens_N1{ferret}(sess) = length(Start(and(deltas_Bulb , CleanStates.N1)))./(sum(DurationEpoch(CleanStates.N1))./1e4);
            DeltaWaveDens_N2{ferret}(sess) = length(Start(and(deltas_Bulb , CleanStates.N2)))./(sum(DurationEpoch(CleanStates.N2))./1e4);
        end
    end
    DeltaWaveDens_REM{ferret}(DeltaWaveDens_REM{ferret}==0) = NaN;
    DeltaWaveDens_N1{ferret}(DeltaWaveDens_N1{ferret}==0) = NaN;
    DeltaWaveDens_N2{ferret}(DeltaWaveDens_N2{ferret}==0) = NaN;
end





% figures
Cols = {[.2 .5 .8],[.8 .5 .2],[.5 .2 .8]};
X = 1:3;
Legends = {'F1','F2','F3'};

figure
subplot(131)
MakeSpreadAndBoxPlot3_SB(DeltaWaveDens_REM,Cols,X,Legends,'showpoints',1,'paired',0,'size_points',10);
ylabel('Delta occurence (#/s)'), ylim([0 1.2])

subplot(132)
MakeSpreadAndBoxPlot3_SB(DeltaWaveDens_N1,Cols,X,Legends,'showpoints',1,'paired',0,'size_points',10);
ylim([0 1.2])

subplot(133)
MakeSpreadAndBoxPlot3_SB(DeltaWaveDens_N2,Cols,X,Legends,'showpoints',1,'paired',0,'size_points',10);
ylim([0 1.2])





%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HEAD RESTRAINT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

cd('/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241211_TORCs')

load('SleepScoring_OBGamma.mat', 'CleanStates')
load('LFPData/LFP105.mat')
load('DeltaWaves_Bulb.mat')

%%
Sniff = Detect_Sniff_From_Piezzo(LFP);

D_zsc = zscore_sliding(Data(LFP) , 1250*5);
D_zsc_tsd = tsd(Range(LFP) , D_zsc);
LFP_breathing = FilterLFP(D_zsc_tsd , [.3 2]);

% Get event times in seconds
ts1 = Start(and(deltas_Bulb , CleanStates.Sleep)) / 1e4;
ts2 = Range(Sniff) / 1e4;

% Parameters
binSize = 0.1; % seconds
win = 10;      % seconds
edges = -win:binSize:win;
binCenters = edges(1:end-1) + binSize/2;

% -------- Cross-correlation ts1 vs ts2 --------
ccg_counts = zeros(size(edges)-[0 1]);
for i = 1:length(ts1)
    diffs = ts2 - ts1(i);
    diffs = diffs(abs(diffs) <= win);
    ccg_counts = ccg_counts + histcounts(diffs, edges);
end



% --- 2. Compute instantaneous phase via Hilbert transform ---
analyticSig = hilbert(Data(LFP_breathing));
phaseLFP = angle(analyticSig);        % radians [-pi, pi]
PhaseTsd = tsd(Range(LFP_breathing), phaseLFP);

% --- 3. Get phase values at spike times ---
delta_times = Start(deltas_Bulb) + (Stop(deltas_Bulb)-Start(deltas_Bulb))/2;         % spike times (1e-4 s units)
delta_phase = Data(Restrict(PhaseTsd, delta_times));

% --- 4. Plot polar histogram of spike phases ---
figure;
polarhistogram(delta_phase, 20)       % 20 bins
title('OB spike phases relative to bulb delta (0.5–4 Hz)')



%% comparing amplitude of events
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241211_TORCs')

load('LFPData/LFP105.mat')
Sniff = Detect_Sniff_From_Piezzo(LFP);
load('SleepScoring_OBGamma.mat', 'Sleep','Wake' , 'SWSEpoch')

load('ChannelsToAnalyse/Bulb_sup.mat')
OB_sup = load(['LFPData/LFP' num2str(channel) '.mat']);
load('ChannelsToAnalyse/Bulb_deep.mat')
OB_deep = load(['LFPData/LFP' num2str(channel) '.mat']);

load('DeltaWaves_Bulb.mat')

[M_wake_sup,~] = PlotRipRaw(OB_sup.LFP, Range(Restrict(Sniff , Wake))/1e4 , 1000 , 0, 0, 0);
[M_wake_deep,~] = PlotRipRaw(OB_deep.LFP, Range(Restrict(Sniff , Wake))/1e4 , 1000 , 0, 0, 0);
[M_sleep_sup,~] = PlotRipRaw(OB_sup.LFP, Range(Restrict(Sniff , Sleep))/1e4 , 1000 , 0, 0, 0);
[M_sleep_deep,~] = PlotRipRaw(OB_deep.LFP, Range(Restrict(Sniff , Sleep))/1e4 , 1000 , 0, 0, 0);
[M_delta_deep,~] = PlotRipRaw(OB_deep.LFP, Start(and(deltas_Bulb , SWSEpoch))/1e4 , 1000 , 0, 0, 0);
[M_delta_sup,~] = PlotRipRaw(OB_sup.LFP, Start(and(deltas_Bulb , SWSEpoch))/1e4 , 1000 , 0, 0, 0);


figure
subplot(131)
plot(M_wake_sup(:,1) , M_wake_sup(:,2) , 'r')
hold on
plot(M_wake_sup(:,1) , M_wake_deep(:,2) , 'b')
xlim([-.5 1]), xlabel('Time (s)'), ylabel('Amplitude (a.u.)')
vline(0 , '--r')
title('Sniff Wake')
makepretty
ylim([-600 800]); y_l = ylim;

subplot(132)
plot(M_wake_sup(:,1) , M_sleep_sup(:,2) , 'r')
hold on
plot(M_wake_sup(:,1) , M_sleep_deep(:,2) , 'b')
xlim([-.5 1]), ylim(y_l), xlabel('Time (s)'), ylabel('Amplitude (a.u.)')
vline(0 , '--r')
title('Sniff Sleep')
makepretty

subplot(133)
plot(M_wake_sup(:,1) , M_delta_sup(:,2) , 'r')
hold on
plot(M_wake_sup(:,1) , M_delta_deep(:,2) , 'b')
xlim([-.5 1]), ylim(y_l), xlabel('Time (s)'), ylabel('Amplitude (a.u.)')
vline(0 , '--r')
title('Delta SWS')
makepretty










%% not used
%% display all delta waves waveform
figure
subplot(131)
shadedErrorBar(M1(:,1), runmean(M1(:,2),5) , runmean(M1(:,4),5) ,'-b',1);
hold on
shadedErrorBar(M1(:,1), runmean(M2(:,2),5)-5e2 , runmean(M2(:,4),5) ,'-r',1);
f=get(gca,'Children'); legend([f(3),f(1)],'OB sup','OB deep');
xlabel('time (ms)'), ylabel('amplitude (a.u.)'), title('REM'), ylim([-1.2e3 1.5e3])
makepretty
vline(0,'--k')

subplot(132)
shadedErrorBar(M1(:,1), runmean(M3(:,2),5) , runmean(M3(:,4),5) ,'-b',1);
hold on
shadedErrorBar(M1(:,1), runmean(M4(:,2),5)-5e2 , runmean(M4(:,4),5) ,'-r',1);
xlabel('time (ms)'), title('IS'), ylim([-1.2e3 1.5e3])
makepretty
vline(0,'--k')

subplot(133)
shadedErrorBar(M1(:,1), runmean(M5(:,2),5) , runmean(M5(:,4),5) ,'-b',1);
hold on
shadedErrorBar(M1(:,1), runmean(M6(:,2),5)-5e2 , runmean(M6(:,4),5) ,'-r',1);
xlabel('Time (ms)'), ylabel('Amplitude (a.u.)'), ylim([-1.2e3 1.5e3])
makepretty
vline(0,'--k')


%% co-occurence with Deltas PFC
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20250103_LSP_saline')
load('SleepScoring_OBGamma.mat', 'SWSEpoch', 'REMEpoch')

% on PFC delta
load('DeltaWaves_PFCx.mat', 'deltas_PFCx')

load('ChannelsToAnalyse/PFCx_deltadeep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M1,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , SWSEpoch))/1e4 , 500, 1, 1, 1);
close

load('ChannelsToAnalyse/PFCx_deltasup.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M2,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , SWSEpoch))/1e4 , 500, 1, 1, 1);
close



figure
subplot(221)
plot(M1(:,1) , runmean(M1(:,2),5))
hold on
plot(M1(:,1) , runmean(M2(:,2),5)-500)
legend('PFC deep','PFC sup')
ylabel('amplitude (a.u.)')
vline(0,'--k'), text(0,1500,'PFC delta','FontSize',15)
makepretty



load('ChannelsToAnalyse/Bulb_deep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M3,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , SWSEpoch))/1e4 , 500, 1, 1, 1);
close

load('ChannelsToAnalyse/Bulb_sup.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M4,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , SWSEpoch))/1e4 , 500, 1, 1, 1);
close


subplot(222)
plot(M1(:,1) , runmean(M3(:,2),5))
hold on
plot(M1(:,1) , runmean(M4(:,2),5)-200)
legend('OB deep','OB sup')
vline(0,'--k'), text(0,400,'PFC delta','FontSize',15), ylim([-1e3 1.5e3])
makepretty



% on OB delta
load('DeltaWaves_Bulb.mat', 'deltas_Bulb')

load('ChannelsToAnalyse/PFCx_deltadeep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M5,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , SWSEpoch))/1e4 , 500, 1, 1, 1);
close

load('ChannelsToAnalyse/PFCx_deltasup.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M6,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , SWSEpoch))/1e4 , 500, 1, 1, 1);
close


subplot(223)
plot(M1(:,1) , runmean(M5(:,2),5))
hold on
plot(M1(:,1) , runmean(M6(:,2),5)-200)
legend('PFC deep','PFC sup')
xlabel('time (ms)'), ylabel('amplitude (a.u.)'), ylim([-1e3 1.5e3])
vline(0,'--k'), text(0,1500,'OB delta','FontSize',15)
makepretty


load('ChannelsToAnalyse/Bulb_deep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M7,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , SWSEpoch))/1e4 , 500, 1, 1, 1);
close

load('ChannelsToAnalyse/Bulb_sup.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
[M8,~] = PlotRipRaw(LFP, Start(and(deltas_PFCx , SWSEpoch))/1e4 , 500, 1, 1, 1);
close

subplot(224)
plot(M1(:,1) , runmean(M7(:,2),5))
hold on
plot(M1(:,1) , runmean(M8(:,2),5)-500)
legend('OB deep','OB sup')
xlabel('time (ms)')
vline(0,'--k'), text(0,400,'OB delta','FontSize',15), ylim([-1e3 1.5e3])
makepretty

% do with random times






