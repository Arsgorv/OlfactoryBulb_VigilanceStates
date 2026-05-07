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

%% Calculate NP LFP for SleepScoring (only when an NP probe is in HPC)
np_cfg = np_lfp_config(datapath);   % returns [] if NP is not applicable

if ~isempty(np_cfg)
    opts = struct();
    opts.np_channels = np_cfg.channels;   % 1-based within Probe*-LFP stream
    opts.probe       = np_cfg.probe;      % 'A' | 'B' | 'auto'
    opts.lfp_fs      = 1250;              % SleepScoring / SpectrumParametersBM assume 1250 Hz
    opts.force       = true;
    opts.save_style  = 'per_channel';     % ensures LFPData-compat mirror 
    if isfield(np_cfg,'segments'), opts.segments = np_cfg.segments; end

    Master_LFP_NP_preproc(sessions, opts);

    % Register ThetaREM channel = the theta-picking NP channel
    for sess = 1:numel(sessions)
        ctaDir = fullfile(sessions{sess}, 'ephys', 'ChannelsToAnalyse');
        if ~exist(ctaDir,'dir'), mkdir(ctaDir); end
        channel = np_cfg.theta_channel;
        save(fullfile(ctaDir, 'ThetaREM.mat'), 'channel');
    end
end

assert(exist(fullfile(sessions{sess},'ephys','LFPData',   ['LFP' num2str(channel) '.mat']),'file')==2 || ...
       exist(fullfile(sessions{sess},'ephys','LFPDataNP', ['LFP' num2str(channel) '.mat']),'file')==2, ...
       'ThetaREM channel %d has no LFP file.', channel);
   
%    % Sanity check: end-alignment sanity (only if OB .lfp exists)
%    load('LFPData/LFP350.mat'); ob = LFP;
%    load('LFPDataNP/LFP350.mat'); np = LFP;
%    r_ob = Range(ob); r_np = Range(np);
%    r_ob(end) - r_np(end)   % should be 0 ± a couple of ticks
%    
%    tEvent_master_s = 12345.678;   % a known TTL time on master clock
%    d_np = Data(np); r_np = Range(np);
%    k = find(r_np >= tEvent_master_s*1e4, 1, 'first');
%    
%    spike_master_s = np_apply_master_warp(spike_np_s, datapath, segName);
%    
%% Calculate necessary spectrograms (not necessary, but useful for SleepScoring and other analysis)
for sess = 1:numel(sessions)
    disp(['Working on ' sessions{sess}])
    
    calculate_spectrograms(sessions{sess},'')
end

%% Do the SleepScoring
for sess = 1:numel(sessions)
    disp(['Working on ' sessions{sess}])
    cd(fullfile(sessions{sess}, 'ephys'))
    
    SleepScoring_Ferret_FV_BAMG('recompute', 1, 'full_ob', 1)
end

%% Calculate brain powers (not necessary, but useful for SleepScoring and other analysis)
sm_w = 0;
for sess = 1:numel(sessions)
    disp(['Working on ' sessions{sess}])
    calculate_brain_power(fullfile(sessions{sess}, 'ephys'), sm_w)
end


% sm_w = 0;
% for sess = 1:numel(SessionDefs)
%     D = SessionDefs(sess);
%     datapath = D.path;
%     disp(['Working on ' datapath])
%     calculate_brain_power(datapath, sm_w)
% end

end