
load([pwd filesep 'SleepScoring_OBGamma.mat'], 'Wake','TotalNoiseEpoch','Epoch','Sleep', 'SmoothGamma')
smootime = 10;

try
    load([pwd filesep 'ChannelsToAnalyse/ThetaREM.mat'])
catch
    load([pwd filesep 'ChannelsToAnalyse/dHPC_deep.mat'])
end
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
LFP = Restrict(LFP , Sleep);

Frequency{1}=[3 6];
Frequency{2}=[.2 3];
FilTheta = FilterLFP(LFP,Frequency{1},1024);
FilDelta = FilterLFP(LFP,Frequency{2},1024);
hilbert_theta = abs(hilbert(Data(FilTheta)));
hilbert_delta = abs(hilbert(Data(FilDelta)));
hilbert_delta(hilbert_delta<10) = 10;
theta_ratio = hilbert_theta./hilbert_delta;
ThetaRatioTSD = tsd(Range(FilTheta), theta_ratio);
SmoothTheta = tsd(Range(ThetaRatioTSD),runmean(Data(ThetaRatioTSD),ceil(smootime/median(diff(Range(ThetaRatioTSD,'s'))))));
log_theta = log(Data(SmoothTheta));
theta_thresh = exp(GetThetaThresh(log_theta, 1, 1));
ThetaEpoch2 = thresholdIntervals(SmoothTheta, theta_thresh, 'Direction','Above');

load([pwd filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
FilDelta = FilterLFP(LFP,[.5 4],1024);
hilbert_delta = abs(hilbert(Data(FilDelta)));
SmoothDelta_OB = tsd(Range(LFP),runmean(hilbert_delta,ceil(smootime/median(diff(Range(LFP,'s'))))));

log_delta_NREM = log(Data(Restrict(SmoothDelta_OB , Sleep-ThetaEpoch2)));
delta_thresh = exp(GetThetaThresh(log_delta_NREM, 1, 1));
N1 = thresholdIntervals(SmoothDelta_OB, delta_thresh, 'Direction','Below');

TotEpoch = intervalSet(0 , max(Range(SmoothDelta_OB)));
Wake = or(Wake,TotalNoiseEpoch);
Wake = mergeCloseIntervals(Wake,10e4);
Sleep = TotEpoch-Wake;

REMEpoch = and(Sleep , ThetaEpoch2);
SWSEpoch = Sleep-REMEpoch;
N1 = and(N1 , SWSEpoch);
N2 = SWSEpoch-N1;

[REMEpoch, N2, N1, Wake] = cleanSleepStates_BM(REMEpoch, N2, N1, Wake, TotEpoch);
CleanStates.Wake = Wake;
CleanStates.N1 = N1;
CleanStates.N2 = N2;
CleanStates.REM = REMEpoch;
CleanStates.Sleep = or(or(REMEpoch , N1) , N2);

save('SleepScoring_OBGamma.mat','CleanStates','SmoothDelta_OB','-append')

