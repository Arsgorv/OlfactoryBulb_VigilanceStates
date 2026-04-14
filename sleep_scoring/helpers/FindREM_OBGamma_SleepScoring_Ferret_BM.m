
% see FindThetaEpoch_SleepScoring_Ferret_BM
% 29/08/2025

function [GammaHighEpoch_OB, SmoothGamma_high, Info] = FindREM_OBGamma_SleepScoring_Ferret_BM(SleepEpoch, Epoch, channel_OB, minduration, varargin)


%% Initiation
if nargin < 3
    error('Incorrect number of parameters.');
end

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'user_confirmation'
            user_confirmation = varargin{i+1};
            if user_confirmation~=0 && user_confirmation ~=1
                error('Incorrect value for property ''user_confirmation''.');
            end
        case 'foldername'
            foldername = (varargin{i+1});
        case 'smoothwindow'
            smootime = (varargin{i+1});
        case 'stimepoch'
            StimEpoch = (varargin{i+1});
        case 'continuity'
            continuity = (varargin{i+1});
        case 'controlepoch'
            ControlEpoch = varargin{i+1};
        case 'frequency'
            Frequency = varargin{i+1};
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
if ~exist('user_confirmation','var')
    user_confirmation=1;
end
if ~exist('continuity','var')
    continuity=0;
end
if ~exist('foldername','var')
    foldername = pwd;
elseif foldername(end)~=filesep
    foldername(end+1) = filesep;
end
% fill ControlEpoch
if ~exist('ControlEpoch','var')
    ControlEpoch=[];
end


% load HPC LFP
load(strcat([foldername,'LFPData/LFP',num2str(channel_OB),'.mat']));
Time = Range(LFP);
% TotalEpoch = intervalSet(Time(1),Time(end));
TotalEpoch = Epoch; % modif by BM on 20/10/2022
LFP = Restrict(LFP , TotalEpoch);
if exist('StimEpoch')
    LFP = Restrict(LFP,TotalEpoch-StimEpoch);
end

% params
try
    smootime;
catch
    smootime=10; % changed by BM on 21/10/2024 for ferrets only
end


% add by BM on 06/02/2024
% choose gamma frequency 
if ~exist('Frequency','var')
    disp('no frequency precised')
    Frequency = input('what frequency do you want for OB gamma REM scoring? (in [])');
end

disp(['Note, that REM is computed using ' num2str(Frequency(1)) '-' num2str(Frequency(2)) ' power'])


%% find theta epochs
disp(' ');
disp('  ... Creating REM Epochs ');

LFP = Restrict(LFP , SleepEpoch);
FilGamma = FilterLFP(LFP,[50 75],1024);
hilbert_gamma = abs(hilbert(Data(FilGamma)));
SmoothGamma_high = tsd(Range(LFP),runmean(hilbert_gamma,ceil(smootime/median(diff(Range(LFP,'s'))))));
gamma_high_thresh = exp(GetThetaThresh(log(Data(SmoothGamma_high)), 1, 1)); close
GammaHighEpoch_OB = thresholdIntervals(SmoothGamma_high, gamma_high_thresh, 'Direction','Above');

disp('----------------------------------')
disp(' ')
disp(['Number of epochs after high thresholding:                ' num2str(length(Start(GammaHighEpoch_OB)))])



%% generate output
Info.gamma_high_thresh = gamma_high_thresh;
Info.gamma_high_mindur = minduration;
Info.gamma_high_channel = channel_OB;
if ~isempty(ControlEpoch), Info.controlepoch = 'yes'; end

end