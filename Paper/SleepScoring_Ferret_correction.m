function SleepScoring_Ferret_correction(varargin)

%==========================================================================
% Details: Sleep Scoring Using Olfactory Bulb and Hippocampal LFP
%          This function creates SleepScoring_OBGamma with sleep scoring 
%          variables and figures 
%          This function is adapted to ferret data processing and based on
%          the original script developed by Sophie Bagur
%
% INPUTS:
%       VARARGINs:
%       - plotfigure    overview figure of sleep scoring if 1; default is 1
%       - recompute     Recompute events (0 or 1)
%       - smoothwindow  Smoothing. Default = 3 
%       - stimepoch     If stim are present length of stim (optional)
%       - continuity    Enables REMEpoch continuity scripts (selectively analyze
%                       epoch containing REMEpoch). Default = 1
%       - controlepoch  IntervalSet (1 start time, 1 end time) of epoch
%                       for mean and std value (gamma and theta)
% 
% OUTPUT:
%
% NOTES:
%
%   Written by Sophie Bagur - 01-12-2017
%   Updated 2020-11 Dima - added SleepScoring_Accelero_OBgamma('PlotFigure',1)
%   Updated 2021-03/10 Samuel Laventure 
%                   added: - REMEpoch continuity
%                          - Streamlining saving process + aesthetic
%                          - Corrected REMEpoch epoch minduration
%                          - Added Theta channel
%   Adapted for ferrets by Baptiste and Arsenii -- 2024
%      
%  see also, SleepScoringAccelerometer SleepScoringOBGamma
%==========================================================================



% BM: smooth time for OB gamma is 3s as min duration for sleep
% for HPC theta and OB delta smooth time is 10s, min duration is 20s for
% REMEpoch and NREMEpoch, check cleanSleepStates_BM for more info
% noise is considered as Wake (might be corrected)

%% INITITATION
% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'plotfigure'
            PlotFigure = varargin{i+1};
            if PlotFigure~=0 && PlotFigure ~=1
                error('Incorrect value for property ''PlotFigure''.');
            end
        case 'recompute'
            recompute = varargin{i+1};
            if recompute~=0 && recompute ~=1
                error('Incorrect value for property ''recompute''.');
            end
        case 'smoothwindow'
            smootime = varargin{i+1};
            if smootime<=0
                error('Incorrect value for property ''smoothwindow''.');
            end
        case 'stimepoch'
            StimEpoch = varargin{i+1};
            if ~isobject(StimEpoch)
                error('Incorrect value for property ''stimepoch''.');
            end
        case 'continuity'
            continuity = varargin{i+1};
            if continuity~=0 && continuity ~=1
                error('Incorrect value for property ''continuity''.');
            end
        case 'controlepoch'
            ControlEpoch = varargin{i+1};
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

% check if exist and assign default value if not
if ~exist('PlotFigure','var')
    PlotFigure=1;
end
% smoothing
try
    smootime;
catch
    smootime = 3;
end
% recompute?
if ~exist('recompute','var')
    recompute=0;
end
% REMEpoch continuity enable
if ~exist('continuity','var')
    continuity=1;
end
% fill ControlEpoch
if ~exist('ControlEpoch','var')
    ControlEpoch=[];
end

% params
minduration = 3;     % abs cut off duration for epochs (sec)
smootime_sleep = 10;     % for sleep variables only (ie HPC theta and OB delta)

%check if already exist
if ~recompute
    if exist('SleepScoring_OBGamma.mat','file')==2 && exist('SleepScoring_Accelero.mat','file')==2
        disp('Scoring both already generated')
        return
    end
end


% initilize diary function (save the content of the command line)
diary('SleepScoring_history.txt')

disp(' ')
disp(' ')
disp('MOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBS')
disp(' ')
disp(' ')
disp('============================================================')
disp('|                                                          |')
disp('|              S L E E P    S C O R I N G                  |')
disp('|                     by MOBs lab                          |')
disp('|                                                          |')
disp('============================================================')
disp(' ')
disp('                                           _   _  ')
disp('   Written by Marie Lacroix               (q\_/p) ') 
disp('              Karim Benchenane        .-.  |. .|  ')
disp('              Sophie Bagur               \ =\,/=  ')
disp('              Karim El Kambi              )/ _ \  ')
disp('              Samuel Laventure           (/\):(/\ ')
disp('                                          \_   _/ ')
disp('                                          `""^""` ')   
disp(' ')   

%% Load necessary channels

foldername=pwd;
if foldername(end)~=filesep
    foldername(end+1)=filesep;
end

% OB
if exist('ChannelsToAnalyse/Bulb_deep.mat','file')==2
    load('ChannelsToAnalyse/Bulb_deep.mat')
    channel_bulb=channel;
    doob=1;
else
    dowiob=input('No OB channel, do you want to do only accelerometer-based scoring? 1/0 ');
    if ~dowiob
        error('No OB channel, do not want to continue. Terminated by user');
    else
        doob=0;
    end
end

% HPC theta for REMEpoch detection
% Modified by S. Laventure 18/10/2021
% - Looks for ThetaREM instead of HPC_deep or else. 

if exist('ChannelsToAnalyse/ThetaREM.mat','file')==2
    load('ChannelsToAnalyse/ThetaREM.mat')
    channel_theta=channel;
else
    channel=input('Please set a channel for Theta REMEpoch detection: ');
    save([pwd '/ChannelsToAnalyse/ThetaREM.mat'],'channel');
    channel_theta=channel;
end

%% create file
Info.minduration=minduration;


%% Get Noise epochs & save
load('SleepScoring_OBGamma.mat', 'Epoch','TotalNoiseEpoch','SubNoiseEpoch','Info')
Info_temp = Info;
Info_OB = Info_temp;
% Info_accelero = Info_temp;

%% Find gamma epochs
load('SleepScoring_OBGamma.mat', 'Sleep','SmoothGamma')

Info_OB=ConCatStruct(Info_OB,Info_temp); clear Info_temp;
SleepOB = Sleep;

%% Find immobility epochs
load('SleepScoring_Accelero.mat', 'ImmobilityEpoch', 'MovementEpoch', 'tsdMovement',  'microSleepEpochAcc', 'microWakeEpochAcc' );
Info_accelero = load('SleepScoring_Accelero.mat', 'Info');
Info_accelero = Info_accelero.Info;
% if ~isempty(ImmobilityEpoch)
%     is_accelero = true;
% else
    is_accelero = false;
% end
%% Find Theta epoch

if doob
    disp(' ')
    disp('------------------------------------------------------------')
    disp(' STEP 4: DEFINING NREMEpoch and REMEpoch WITH HPC THETA')
    disp('         for OB Gamma scoring')
    disp('------------------------------------------------------------')
    disp(' ') 
    % restricted to sleep with OB gamma
    % CHANGE WITH MICE --> delta between .1-2 Hz, theta between 3-6 Hz
    Frequency{1}=[3 6]; Frequency{2}=[.2 3]; % changed by BM on 20/08/2025 4-6 to 3-6
    if ~exist('StimEpoch')
        [ThetaEpoch_OB, SmoothTheta, ~, Info_temp] = ...
            FindThetaEpoch_SleepScoring_Ferret_BM(SleepOB, Epoch, channel_theta, minduration, 'foldername', foldername,...
            'smoothwindow', smootime_sleep,'continuity',continuity,'controlepoch',ControlEpoch,'frequency',Frequency);
    else
        [ThetaEpoch_OB, SmoothTheta, ~, Info_temp] = ...
            FindThetaEpoch_SleepScoring_Ferret_BM(SleepOB, Epoch, channel_theta, minduration, 'foldername', foldername,...
            'smoothwindow', smootime_sleep, 'stimepoch', StimEpoch,'continuity',continuity,'controlepoch',ControlEpoch);
    end
    Info_OB=ConCatStruct(Info_OB,Info_temp); 
    Info_OB.theta_thresh = Info_temp.theta_thresh;
    Info_OB.theta_mindur = Info_temp.theta_mindur;
    Info_OB.theta_HPC_channel = Info_temp.theta_HPC_channel;
    clear ThetaEpoch; clear Info_temp;
else
    disp(' ')
    disp('------------------------------------------------------------')
    disp(' STEP 4: SKIPPED')
    disp('         no OB Gamma')
    disp('------------------------------------------------------------')
    disp(' ')  
end
disp(' ')
disp('Defining theta epochs for OB Gamma: DONE')
disp(' ')

% restricted to immobility epoch
if is_accelero
    disp(' ')
    disp('------------------------------------------------------------')
    disp(' STEP 5: DEFINING NREMEpoch and REMEpoch WITH HPC THETA')
    disp('         for accelero scoring')
    disp('------------------------------------------------------------')
    disp(' ') 
    disp(' '),disp(' '),disp('Theta Epochs for accelero')
    if ~exist('StimEpoch')
        [ThetaEpoch_acc, SmoothTheta, ThetaRatioTSD, Info_temp] = ...
            FindThetaEpoch_SleepScoring_Ferret_BM(ImmobilityEpoch, Epoch, channel_theta, minduration,...
            'foldername', foldername,'smoothwindow', smootime_sleep,'continuity',continuity,'frequency',Frequency);
    else
        [ThetaEpoch_acc, SmoothTheta, ThetaRatioTSD, Info_temp] = ...
            FindThetaEpoch_SleepScoring_Ferret_BM(ImmobilityEpoch, Epoch, channel_theta, minduration,...
            'foldername', foldername,'smoothwindow', smootime_sleep, 'stimepoch', StimEpoch,'continuity',continuity);
    end
    Info_accelero = ConCatStruct(Info_accelero,Info_temp); 
    Info_accelero.theta_thresh = Info_temp.theta_thresh;
    Info_accelero.theta_mindur = Info_temp.theta_mindur;
    Info_accelero.theta_HPC_channel = Info_temp.theta_HPC_channel;
    clear Info_temp;
else
    disp(' ')
    disp('------------------------------------------------------------')
    disp(' STEP 5: SKIPPED')
    disp('         no accelero data')
    disp('------------------------------------------------------------')
    disp(' ') 
end
disp(' ')
disp('Defining theta epochs for accelero: DONE')
disp(' ')

%% Find intermediate sleep
if doob
    disp(' ')
    disp('------------------------------------------------------------')
    disp(' STEP 6: DEFINING NREMEpoch and ISEpoch using 0.5-4 Hz rhythm')
    disp('------------------------------------------------------------')
    disp(' ')
    disp('0.5-4 Hz Epochs')
    
    % changed by BM on 02/03/2025 SleepOB--> SleepOB-ThetaEpoch_OB, focus only on NREMEpoch to subdivise it
    [DeltaEpoch, SmoothDelta_OB, Info_temp] = Find_Delta_Epoch(SleepOB-ThetaEpoch_OB, Epoch, channel_bulb, minduration,...
        'foldername', foldername, 'smoothwindow', smootime_sleep); 
    
    Info_OB = ConCatStruct(Info_OB,Info_temp);  
    Info_OB.delta_thresh = Info_temp.delta_thresh;
    Info_OB.mindur_Delta = Info_temp.mindur_Delta;
    Info_OB.channel_bulb = Info_temp.channel_bulb;
    clear Info_temp;
    
    disp(' ')
    disp('0.5-4 Hz: DONE')
    disp(' ')
else
    disp(' ')
    disp('------------------------------------------------------------')
    disp(' STEP 6 SKIPPED: NO 0.5-4 Hz')
    disp('------------------------------------------------------------')
    disp(' ')    
end

%% Define behavioural epochs
disp(' ')
disp('------------------------------------------------------------')
disp(' STEP 6: DEFINING SLEEP STAGES')
disp('------------------------------------------------------------')
disp(' ') 
if doob
    
    Wake = or(Epoch-SleepOB,TotalNoiseEpoch);
    REMEpoch = and(SleepOB , ThetaEpoch_OB);
    SWSEpoch = and(SleepOB , DeltaEpoch)-REMEpoch;
    ISEpoch = SleepOB-or(REMEpoch , SWSEpoch);
    [REMEpoch, SWSEpoch, ISEpoch, Wake , Sleep] = cleanSleepStates_BM(REMEpoch, SWSEpoch, ISEpoch, Wake, Epoch);
%     Wake = Wake-TotalNoiseEpoch;
    
    ThetaEpoch =  ThetaEpoch_OB;
    Info = Info_OB;
    
    disp('           >>>  Saving OBgamma stages  <<<')
    disp(' ')
    save('SleepScoring_OBGamma', 'ISEpoch', 'DeltaEpoch', 'REMEpoch','SWSEpoch','Wake', ...
        'Sleep','SmoothGamma','ThetaEpoch','SmoothTheta', 'SmoothDelta_OB', 'Info',...
        'Epoch','SubNoiseEpoch','TotalNoiseEpoch','-append');
    
    clear ThetaEpoch Info Sleep;
end

if is_accelero
    
    Wake = or(Epoch-ImmobilityEpoch,TotalNoiseEpoch);
    REMEpoch = and(ImmobilityEpoch , ThetaEpoch_acc);
    SWSEpoch = and(ImmobilityEpoch , DeltaEpoch)-REMEpoch;
    ISEpoch = SleepOB-or(REMEpoch , SWSEpoch);
    [REMEpoch, SWSEpoch, ISEpoch, Wake , Sleep] = cleanSleepStates_BM(REMEpoch, SWSEpoch, ISEpoch, Wake, Epoch);
%     Wake = Wake-TotalNoiseEpoch;
    
    ThetaEpoch =  ThetaEpoch_acc;
    Info = Info_accelero;
    
    disp('           >>>  Saving Accelero stages  <<<')
    disp(' ')
    save('SleepScoring_Accelero', 'ISEpoch', 'DeltaEpoch', 'REMEpoch','SWSEpoch','Wake', ...
        'ImmobilityEpoch','tsdMovement','ThetaEpoch','SmoothTheta', 'SmoothDelta_OB', 'Info',...
        'Epoch','SubNoiseEpoch','TotalNoiseEpoch','-append');
    
    clear ThetaEpoch Info Sleep;
end
disp(' ')
disp('Defining sleep stages: DONE')
disp(' ')

%% Make sleep scoring figure if PlotFigure is 1
if PlotFigure
    disp(' ')
    disp('------------------------------------------------------------')
    disp(' STEP 7: CREATING FIGURES')
    disp('------------------------------------------------------------')
    disp(' ') 
    
    %% Calculate spectra if they don't alread exist
    % Hpc low Spectrum
    if ~(exist('H_Low_Spectrum.mat', 'file') == 2)
        LowSpectrumSB(foldername,channel_theta,'H');
    end
        
%     OB Middle Spectrum
    if exist('B_Middle_Spectrum.mat')==0
        MiddleSpectrum_BM(foldername,channel_bulb,'B');
        disp('Middle Bulb Spectrum done')
    end
    
    % OB Low spectrum
    if ~exist('B_Low_Spectrum.mat')
        LowSpectrumSB(foldername,channel_bulb,'B');
        disp('Low Bulb Spectrum done')
    end
    
    
    %% Make figure
    Figure_SleepScoring_OBGamma_Ferret(foldername)
    
    %Accelerometer
    % Make figure
    if is_accelero
        ratio_display_movement = (max(Data(ThetaRatioTSD))-min(Data(ThetaRatioTSD)))/(max(Data(tsdMovement))-min(Data(tsdMovement)));
        Figure_SleepScoring_Accelero(ratio_display_movement, foldername)
    end
    
end
disp(' '), disp(' ')
disp('           SLEEP SCORING COMPLETED')
disp(' ')
disp('    "It could be worse, you could be') 
disp('     studying mice" - anonym, 2024')
disp(' ')
disp('MOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBSMOBS')
diary off

end


