% FindThetaEpoch_SleepScoring
% 21.11.2017 SB
%
% [ThetaEpoch,smooth_Theta, Info] = FindThetaEpoch_SleepScoring(Epoch,Sleep,chH,mindur,filename)
% 
% This function calculates epochs of high theta
%
%
%%INPUT
% SleepEpoch        : sleep epochs
% minduration       : minimal duration  of theta epochs
% channel_HPC       : HPC channel
% foldername        : location of data & save location
% continuity        : fix continuity issue within theta/rem epochs
% controlepoch      : IntervalSet (1 start time, 1 end time) of epoch
%                     for mean and std value (gamma and theta)
%
%
%OUTPUT
% ThetaEpoch        : epoch of high theta during sleep (i.e REM)
% SmoothTheta       : tsd of theta / delta ratio used for scoring
% Info              : structure with all parameters used
%
%
% SEE
%   SleepScoringOBGamma
%

function [ThetaEpoch, SmoothTheta, ThetaRatioTSD, Info] = FindThetaEpoch_SleepScoring_Ferret_BM(SleepEpoch, Epoch, channel_HPC, minduration, varargin)


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
load(strcat([foldername,'LFPData/LFP',num2str(channel_HPC),'.mat']));
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
    Frequency{1} = [5 10];
    Frequency{2} = [2 5];
end

disp(['Note, that chosen Theta power is calculated as ratio of ' num2str(Frequency{1}(1)) '-' num2str(Frequency{1}(2))...
    'Hz / ' num2str(Frequency{2}(1)) '-' num2str(Frequency{2}(2)) 'Hz'])


%% find theta epochs
disp(' ');
disp('  ... Creating Theta Epochs ');

% get instantaneous Theta / delta ratio
FilTheta = FilterLFP(LFP,Frequency{1},1024);
FilDelta = FilterLFP(LFP,Frequency{2},1024);
hilbert_theta = abs(hilbert(Data(FilTheta)));
hilbert_delta = abs(hilbert(Data(FilDelta)));
hilbert_delta(hilbert_delta<10) = 10; % 100 mice values

theta_ratio = hilbert_theta./hilbert_delta;
ThetaRatioTSD = tsd(Range(FilTheta), theta_ratio);


% smooth Theta / delta ratio
SmoothTheta = tsd(Range(ThetaRatioTSD),runmean(Data(ThetaRatioTSD),ceil(smootime/median(diff(Range(ThetaRatioTSD,'s'))))));

% Get threshold
if isempty(ControlEpoch)
    log_theta = log(Data(Restrict(SmoothTheta,SleepEpoch)));
else
    log_theta = log(Data(Restrict(Restrict(SmoothTheta,SleepEpoch),ControlEpoch)));
end
theta_thresh = exp(GetThetaThresh(log_theta, 1, user_confirmation));

% define high theta epochs
ThetaEpoch = thresholdIntervals(SmoothTheta, theta_thresh, 'Direction','Above');
% ThetaEpoch = SleepEpoch-ThetaEpoch;             % what is the purpose of this ??

disp('----------------------------------')
disp(' ')
disp(['Number of epochs after high thresholding:                ' num2str(length(Start(ThetaEpoch)))])



%% generate output
Info.theta_thresh = theta_thresh;
Info.theta_mindur = minduration;
Info.theta_HPC_channel = channel_HPC;
if ~isempty(ControlEpoch), Info.controlepoch = 'yes'; end

end