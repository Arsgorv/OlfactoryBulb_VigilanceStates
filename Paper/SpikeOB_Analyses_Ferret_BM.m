
% for spikes
edit Find_SpikesinOB_Quickly_BM.m


%% average FR in sleep states
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241205_TORCs')
load('SleepScoring_OBGamma.mat', 'Wake', 'ISEpoch', 'SWSEpoch', 'REMEpoch', 'spikes_OB')

MeanFR_Wake = length(Range(Restrict(spikes_OB , Wake)))./(sum(DurationEpoch(Wake))./1e4);
MeanFR_IS = length(Range(Restrict(spikes_OB , ISEpoch)))./(sum(DurationEpoch(ISEpoch))./1e4);
MeanFR_SWS = length(Range(Restrict(spikes_OB , SWSEpoch)))./(sum(DurationEpoch(SWSEpoch))./1e4);
MeanFR_REM = length(Range(Restrict(spikes_OB , REMEpoch)))./(sum(DurationEpoch(REMEpoch))./1e4);

Cols={[0 0 1],[.8 .5 .2],[1 0 0],[0 1 0]};

figure
b{1} = bar(1 , MeanFR_Wake,'FaceColor' , Cols{1} , 'FaceAlpha' , .7);
hold on
b{2} = bar(2 , MeanFR_IS,'FaceColor' , Cols{2} , 'FaceAlpha' , .7);
b{3} = bar(3 , MeanFR_SWS,'FaceColor' , Cols{3} , 'FaceAlpha' , .7);
b{4} = bar(4 , MeanFR_REM,'FaceColor' , Cols{4} , 'FaceAlpha' , .7);
xticks([1:4]), xticklabels({'Wake','IS','SWS','REM'}), xtickangle(45)
ylabel('spikes/s')
box off


%% spikes and delta oscillations
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241205_TORCs')
Cols={[0 0 1],[.8 .5 .2],[1 0 0],[0 1 0]};

load('LFPData/LFP21.mat')

load('SleepScoring_OBGamma.mat', 'spikes_OB' , 'Wake' , 'ISEpoch' , 'SWSEpoch' , 'REMEpoch' , 'TotalNoiseEpoch')
Wake = Wake-TotalNoiseEpoch;

LFP_delta = FilterLFP(LFP , [.5 4] , 1024);
analyticSig = hilbert(Data(LFP_delta));
phaseLFP = angle(analyticSig);    % phase in radians (-pi to pi)

PhaseTsd = tsd(Range(LFP_delta), phaseLFP);
PhaseTsd_Wake = Restrict(PhaseTsd , Wake);
PhaseTsd_IS = Restrict(PhaseTsd , SWSEpoch);
PhaseTsd_SWS = Restrict(PhaseTsd , ISEpoch);
PhaseTsd_REM = Restrict(PhaseTsd , REMEpoch);

spk_times = Range(spikes_OB);         % spike times (1e-4 s units, same as LFP)
spike_phase_Wake = Data(Restrict(PhaseTsd_Wake, spk_times));
spike_phase_IS = Data(Restrict(PhaseTsd_IS, spk_times));
spike_phase_SWS = Data(Restrict(PhaseTsd_SWS, spk_times));
spike_phase_REM = Data(Restrict(PhaseTsd_REM, spk_times));

figure;
subplot(221)
polarhistogram(spike_phase_Wake, 20, 'FaceColor', Cols{1}, 'FaceAlpha', 0.7)
title('Wake')

subplot(222)
polarhistogram(spike_phase_IS, 20, 'FaceColor', Cols{2}, 'FaceAlpha', 0.7)
title('IS')

subplot(223)
polarhistogram(spike_phase_SWS, 20, 'FaceColor', Cols{3}, 'FaceAlpha', 0.7)
title('SWS')

subplot(224)
polarhistogram(spike_phase_REM, 20, 'FaceColor', Cols{4}, 'FaceAlpha', 0.7)
title('REM')


%% spikes and gamma oscillations
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241205_TORCs')

load('LFPData/LFP21.mat')

load('SleepScoring_OBGamma.mat', 'spikes_OB' , 'Wake' , 'ISEpoch' , 'SWSEpoch' , 'REMEpoch')
Wake = Wake-TotalNoiseEpoch;

LFP_gamma = FilterLFP(LFP , [40 60] , 1024);
analyticSig = hilbert(Data(LFP_gamma));
phaseLFP = angle(analyticSig);    % phase in radians (-pi to pi)

PhaseTsd = tsd(Range(LFP_gamma), phaseLFP);
PhaseTsd_Wake = Restrict(PhaseTsd , Wake);
PhaseTsd_IS = Restrict(PhaseTsd , SWSEpoch);
PhaseTsd_SWS = Restrict(PhaseTsd , ISEpoch);
PhaseTsd_REM = Restrict(PhaseTsd , REMEpoch);

spk_times = Range(spikes_OB);         % spike times (1e-4 s units, same as LFP)
spike_phase_Wake = Data(Restrict(PhaseTsd_Wake, spk_times));
spike_phase_IS = Data(Restrict(PhaseTsd_IS, spk_times));
spike_phase_SWS = Data(Restrict(PhaseTsd_SWS, spk_times));
spike_phase_REM = Data(Restrict(PhaseTsd_REM, spk_times));

figure;
subplot(221)
polarhistogram(spike_phase_Wake, 20, 'FaceColor', Cols{1}, 'FaceAlpha', 0.7)
title('Wake')

subplot(222)
polarhistogram(spike_phase_IS, 20, 'FaceColor', Cols{2}, 'FaceAlpha', 0.7)
title('IS')

subplot(223)
polarhistogram(spike_phase_SWS, 20, 'FaceColor', Cols{3}, 'FaceAlpha', 0.7)
title('SWS')

subplot(224)
polarhistogram(spike_phase_REM, 20, 'FaceColor', Cols{4}, 'FaceAlpha', 0.7)
title('REM')




%% spikes and delta waves
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241205_TORCs')
load('SleepScoring_OBGamma.mat', 'SWSEpoch','spikes_OB')
load('DeltaWaves_Bulb.mat')

delta_OB_SWS = and(deltas_Bulb , SWSEpoch);

% Get event times in seconds
% ts1 = (Start(delta_OB_SWS) + (Stop(delta_OB_SWS) - Start(delta_OB_SWS))/2)/1e4;
ts1 = Start(delta_OB_SWS)/1e4;
ts2 = Range(spikes_OB) / 1e4;

% Parameters
binSize = 0.01; % seconds
win = 1;      % seconds
edges = -win:binSize:win;
binCenters = edges(1:end-1) + binSize/2;

% -------- Cross-correlation ts1 vs ts2 --------
ccg_counts = zeros(size(edges)-[0 1]);
for i = 1:length(ts1)
    diffs = ts2 - ts1(i);
    diffs = diffs(abs(diffs) <= win);
    ccg_counts = ccg_counts + histcounts(diffs, edges);
end


% -------- Plot results --------
figure;
bar(binCenters, ccg_counts, 1, 'FaceColor','k','FaceAlpha',.7)
xlabel('Time lag (s)'); ylabel('Count')
title('Cross-correlogram: Delta OB relative to spikes OB')
xlim([-.25 .25]); 
vline(0 , '--r')


