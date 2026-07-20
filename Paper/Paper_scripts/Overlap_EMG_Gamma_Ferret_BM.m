
%% figures
clear all
load('/media/nas7/React_Passive_AG/OBG/Data_Paper/Overlap_EMG_Gamma.mat')

Cols = {[.2 .5 .8],[.8 .5 .2],[.5 .2 .8]};
X = 1:3;
Legends = {'F1','F2','F3'};

figure
MakeSpreadAndBoxPlot3_SB({Overlap(1,:) Overlap(2,:) Overlap(3,:)},Cols,X,Legends,'showpoints',1,'paired',0,'showsigstar','none');
ylabel('Score agreement'), ylim([0 1])
makepretty_BM2


%% generqte data
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
smootime = 3;
% for ferret 1, take channel 12

%% data
for ferret=3%1:3
    for sess=4:length(Dir{ferret}.path)
        try
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'Epoch', 'SmoothGamma')
        load([Dir{ferret}.path{sess} filesep 'ChannelsToAnalyse/EMG.mat'], 'channel')
        load([Dir{ferret}.path{sess} filesep 'LFPData/LFP' num2str(channel) '.mat'])
        
        % EMG part
        LFP = Restrict(LFP , Epoch);
        FilLFP=FilterLFP(LFP,[50 300],1024);
        EMGData=tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));
        
        clf
        emg_thresh = GetGaussianThresh_BM(log10(Data(EMGData)), 1 , 1);
        
        LowEMG_Epoch = thresholdIntervals(EMGData,10^(emg_thresh),'Direction','Below');
        LowEMG_Epoch = mergeCloseIntervals(LowEMG_Epoch, minduration*1e4);
        LowEMG_Epoch = dropShortIntervals(LowEMG_Epoch, minduration*1e4);
        
        HighEMG_Epoch = thresholdIntervals(EMGData,exp(emg_thresh),'Direction','Above');
        HighEMG_Epoch = mergeCloseIntervals(HighEMG_Epoch, minduration*1e4);
        HighEMG_Epoch = dropShortIntervals(HighEMG_Epoch, minduration*1e4);
        
        
        % Gamma part
        SmoothGamma = Restrict(SmoothGamma , Epoch);
        clf
        gamma_thresh = GetGaussianThresh_BM(log10(Data(SmoothGamma)), 1 , 1);
        
        LowGamma_Epoch = thresholdIntervals(SmoothGamma,10^(gamma_thresh),'Direction','Below');
        LowGamma_Epoch = mergeCloseIntervals(LowGamma_Epoch, minduration*1e4);
        LowGamma_Epoch = dropShortIntervals(LowGamma_Epoch, minduration*1e4);
        
        HighGamma_Epoch = thresholdIntervals(SmoothGamma,exp(gamma_thresh),'Direction','Above');
        HighGamma_Epoch = mergeCloseIntervals(HighGamma_Epoch, minduration*1e4);
        HighGamma_Epoch = dropShortIntervals(HighGamma_Epoch, minduration*1e4);
        
        % Intersection
        Overlap(ferret,sess) = (sum(DurationEpoch(and(LowGamma_Epoch , LowEMG_Epoch)))+sum(DurationEpoch(and(HighGamma_Epoch , HighEMG_Epoch))))./...
            (sum(DurationEpoch(LowGamma_Epoch)) + sum(DurationEpoch(HighGamma_Epoch)));
        
        end
    end
end
Overlap(1,[3 6:8])=NaN;
Overlap(2,1)=NaN;
Overlap(3,2)=NaN;
Overlap(Overlap==0)=NaN;









