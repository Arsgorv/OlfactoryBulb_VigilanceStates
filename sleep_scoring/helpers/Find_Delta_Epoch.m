
% This function calculates epochs of high delta (0.5-4Hz)
%

function [DeltaEpoch, SmoothDelta, Info] = Find_Delta_Epoch(Sleep_notREM, Epoch, channel_bulb, minduration, varargin)

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'foldername'
            foldername = (varargin{i+1});
        case 'smoothwindow'
            smootime = (varargin{i+1});
        case 'continuity'
            continuity = (varargin{i+1});
            
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%%
load(strcat([foldername,'LFPData/LFP',num2str(channel_bulb),'.mat']));

% params
try
    smootime;
catch
    smootime=10; % added by BM for homogeneity with Theta Epoch definition for ferrets
end


disp(' ');
disp('... Creating 0.5-4Hz Epochs ');
Fil_Delta = FilterLFP(LFP,[.5 4],1024);
tEnveloppe = tsd(Range(Fil_Delta), abs(hilbert(Data(Fil_Delta))) );
SmoothDelta  = tsd(Range(tEnveloppe), runmean(Data(tEnveloppe), ...
    ceil(smootime/median(diff(Range(tEnveloppe,'s'))))));

Delta_thresh = GetGaussianThresh_BM(log10(Data(Restrict(SmoothDelta , Sleep_notREM))), 1, 1); % 25/07/2025 AG: we don't have SWSEpoch here. I change it to Sleep_notREM? 
Delta_thresh = 10^Delta_thresh;

DeltaEpoch = thresholdIntervals(SmoothDelta , Delta_thresh , 'Direction','Above');

disp('----------------------------------')
disp(' ')
disp(['Number of epochs after high thresholding:       ' num2str(length(Start(DeltaEpoch)))])


%% generate output
Info.delta_thresh = Delta_thresh;
Info.mindur_Delta = minduration;
Info.channel_bulb = channel_bulb;

% Changed on 09/10/2024 by AG to align with SB SleepScoring
% save(strcat(filename,'StateEpochSB'),'Epoch_Delta', 'smooth_Delta','thresh_Delta','ThetaI','-v7.3','-append');
% save(strcat(filename,'SleepScoring_OBGamma'),'Epoch_Delta', 'smooth_Delta','thresh_Delta','ThetaI','-v7.3','-append');

end