function Master_SleepScoring_preproc(sessions)
% Full original preprocessing of the OB project can be found here: Ferret_ProcessData_BM.m

%% Prepare data
github_location = {'D:\Arsenii\GitHub\NeuroMeta'; '/home/mathilde/GitHub'};
python_location = 'C:\Users\Arsenii Goriachenkov\.conda\envs\sleepscoring\python.exe';

for sess = 1:numel(sessions)
    datapath = sessions{sess};
    disp(['Working on ' datapath])
    
    fix_folder_structure(datapath)
    copy_ExpeInfo(datapath)
    
    if ispc 
        % Windows LB1
        convertEvents2Mat_wrapper(datapath, python_location, github_location{1});
    else
        % Linux
        convertEvents2Mat_wrapper(datapath, github_location{2});
    end
end

%% PreProcess data
sess = 1;
while sess <= numel(sessions)
    disp(['Working on ' sessions{sess}])
    cd(fullfile(sessions{sess}, 'ephys'))
    GUI_StepOne_ExperimentInfo
    sess = sess + 1;
end

%% Run manifest + make high-level epochs + per-run sync (only for React Active experiment)
for sess = 1:numel(sessions)
    disp(['Working on ' sessions{sess}])
    
    RAE_make_run_manifest(sessions{sess});
end

%% Calculate NP LFP (if you have Neuropixels probe in hpc, we can use its LFP for sleep scoring)
if contains(datapath, 'Tvorozhok')
    % hpc_deep = 155;
    % hpc_mid_1 = 220;
    % hpc_mid_2 = 305;
    % hpc_sup = 370;
    hpc_sup = 350;
elseif contains(datapath, 'Mochi')
    hpc_sup = 300;
end

opts = struct();
% opts.np_channels = [hpc_deep hpc_mid_1 hpc_mid_2 hpc_sup]; % 1-based within ProbeA-LFP stream
opts.np_channels = [hpc_sup]; % 1-based within ProbeA-LFP stream

opts.lfp_fs = 2500;
opts.force = true; 

Master_LFP_NP_preproc(sessions, opts); 

if ~exist('hpc_sup','var') || isempty(hpc_sup)
    error('hpc_sup is not defined in the workspace.');
end

% Add ThetaREM channel
for sess = 1:numel(sessions)

    thetaFile = fullfile(sessions{sess}, 'ephys', 'ChannelsToAnalyse', 'ThetaREM.mat');

%     if ~exist(thetaFile, 'file')
%         warning('ThetaREM.mat not found (skipping): %s', thetaFile);
%         continue
%     end
% 
%     v = whos('-file', thetaFile);
%     hasThetaRem = any(strcmp({v.name}, 'ThetaRem')) || any(strcmpi({v.name}, 'ThetaREM')) || any(strcmpi({v.name}, 'thetaRem'));
%     if ~hasThetaRem
%         warning('ThetaRem variable not found inside: %s (will still append channel)', thetaFile);
%     end
% 
    channel = hpc_sup;
    save(thetaFile, 'channel');  % keeps ThetaRem and any other variables
end

%% Calculate necessary spectrograms (not necessary, but useful for SleepScoring and other analysis)
for sess = 1:numel(sessions)
    disp(['Working on ' sessions{sess}])
    
    calculate_spectrograms(sessions{sess},'')
end

%% Calculate brain powers (not necessary, but useful for SleepScoring and other analysis)
sm_w = 0.1;
for sess = 1:numel(sessions)
    disp(['Working on ' sessions{sess}])
    calculate_brain_power(fullfile(sessions{sess}, 'ephys'), sm_w)
end

%% Do the SleepScoring
for sess = 1:numel(sessions)
    disp(['Working on ' sessions{sess}])
    cd(fullfile(sessions{sess}, 'ephys'))
    
    SleepScoring_Ferret_FV_BAMG('recompute', 1, 'full_ob', 1)
end


end