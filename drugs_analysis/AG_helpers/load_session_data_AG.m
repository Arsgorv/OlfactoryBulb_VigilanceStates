function S = load_session_data_AG(D, wantedSlice, ForceFicelloMidpoint)
%LOAD_SESSION_DATA_AG  Load all per-session data needed by v7.

datapath = D.path;
[~, sessionName] = fileparts(datapath);

S = struct();
S.name = sessionName;
S.path = datapath;
S.animal = D.animal;
S.restraint = D.restraint;
S.drug_id = D.drug_id;
S.drug_name = D.drug_name;
S.source = D.source;
S.dose_tag = D.dose_tag;
S.inj_time_sec = NaN;
S.force_midpoint_injection = strcmp(D.animal, 'Ficello') && ForceFicelloMidpoint;
S.drug_sess = NaN;

% --- fUS volume + ROI masks ---
fus_file = dir(fullfile(datapath, 'fUS', ['RP_data_*slice_' wantedSlice '.mat']));
if ~isempty(fus_file)
    tmp = load(fullfile(datapath, 'fUS', fus_file(1).name), 'cat_tsd', 'masks');
    S.fUS.cat_tsd = tmp.cat_tsd;
    S.fUS.masks   = tmp.masks;
end

% --- BrainPower (multi-region) + inj_time + RespRate_tsd if precomputed ---
BrainPowerFile = fullfile(datapath, 'ephys', 'SleepScoring_OBGamma.mat');
if ~exist(BrainPowerFile, 'file')
    BrainPowerFile = fullfile(datapath, 'SleepScoring_OBGamma.mat');
end
if exist(BrainPowerFile, 'file')
    tmp = load(BrainPowerFile);
    if isfield(tmp, 'BrainPower')
        sn = tmp.BrainPower.signal_names;
        powerMap = { ...
            'OBGammaPower',  'OB_gamma'; ...
            'OBDeltaPower',  'OB_delta'; ...
            'HPCGammaPower', 'HPC_gamma'; ...
            'HPCThetaPower', 'HPC_theta'; ...
            'PFCGammaPower', 'PFC_gamma'; ...
            'ACxGammaPower', 'ACx_gamma'};
        for pm = 1:size(powerMap,1)
            ix = find(strcmp(sn, powerMap{pm,2}), 1);
            if ~isempty(ix)
                S.(powerMap{pm,1}) = tmp.BrainPower.Power{1, ix};
            end
        end
    elseif isfield(tmp, 'SmoothGamma')
        S.OBGammaPower = tmp.SmoothGamma;
        warning('Using SmoothGamma as OBGammaPower for %s.', sessionName)
    end

    % Inj time
    if isfield(tmp, 'inj_time') && ~S.force_midpoint_injection
        S.inj_time_sec = convert_inj_time_to_sec_AG(tmp.inj_time);
    elseif isfield(tmp, 'inj_time') && S.force_midpoint_injection
        warning('Ficello %s: stored inj_time but ForceFicelloMidpoint=1; using midpoint.', sessionName);
    end

    % Precomputed RespRate_tsd (if MakeRespi_ForSession_Ferret was run for this session).
    if isfield(tmp, 'RespRate_tsd')
        S.RespRate_tsd_precomputed = tmp.RespRate_tsd;
    end
else
    warning('No SleepScoring_OBGamma.mat for %s', sessionName)
end

% --- Respi LFP (raw, kept for in-session Hilbert IF computation) ---
respiCTA = fullfile(datapath, 'ephys', 'ChannelsToAnalyse', 'respi.mat');
if ~exist(respiCTA, 'file')
    respiCTA = fullfile(datapath, 'ChannelsToAnalyse', 'respi.mat');
end
if exist(respiCTA, 'file')
    chS = load(respiCTA, 'channel');
    if isfield(chS,'channel') && ~isempty(chS.channel) && isfinite(chS.channel(1))
        respi_ch = chS.channel(1);
        lfpFile = fullfile(datapath, 'ephys', 'LFPData', ['LFP' num2str(respi_ch) '.mat']);
        if ~exist(lfpFile,'file')
            lfpFile = fullfile(datapath, 'LFPData', ['LFP' num2str(respi_ch) '.mat']);
        end
        if exist(lfpFile, 'file')
            lS = load(lfpFile, 'LFP');
            if isfield(lS,'LFP'), S.RespLFP_tsd = lS.LFP; end
        end
    end
end

% --- Accelero (QC only in head-fixed) ---
behavFile = fullfile(datapath, 'behavResources.mat');
if exist(behavFile, 'file')
    tmp = load(behavFile, 'MovAcctsd');
    if isfield(tmp, 'MovAcctsd'), S.MovAcctsd = tmp.MovAcctsd; end
end

% --- HeartBeatInfo ---
hbFile = fullfile(datapath, 'ephys', 'HeartBeatInfo.mat');
if ~exist(hbFile, 'file'), hbFile = fullfile(datapath, 'HeartBeatInfo.mat'); end
if exist(hbFile, 'file')
    tmp = load(hbFile, 'EKG');
    if isfield(tmp, 'EKG')
        S.EKG = tmp.EKG;
        if isfield(tmp.EKG, 'HBRate'), S.HeartRate = tmp.EKG.HBRate; end
    end
end

% --- EMG / EKG envelopes via channel config (kept for QC) ---
chans = get_lfp_channels_AG(datapath);
S.lfp_channels = chans;
if isfinite(chans.EMG)
    S.EMGEnvelope = compute_lfp_envelope_AG(datapath, chans.EMG, [50 300], 1);
end
if isfinite(chans.EKG)
    S.EKGEnvelope = compute_lfp_envelope_AG(datapath, chans.EKG, [5 40], 0.5);
end

% --- Region spectra (B + AuCx + H + PFCx) x (Low + Middle) for plotting ---
regionMap = { ...
    'B',    'OB';   ...
    'AuCx', 'AuCx'; ...
    'H',    'HPC';  ...
    'PFCx', 'PFCx'};
for rr = 1:size(regionMap,1)
    prefix = regionMap{rr,1};
    nicename = regionMap{rr,2};
    for rng = {'Low','Middle'}
        r_out = load_region_spectrum_AG(datapath, prefix, rng{1});
        if isempty(r_out), continue, end
        if strcmp(prefix, 'B')
            fld = ['Spectro' rng{1}];
            S.(fld).sptsdB = r_out.sptsd;
            S.(fld).fB    = r_out.f;
        else
            S.RegionSpectra.(nicename).(rng{1}).sptsd = r_out.sptsd;
            S.RegionSpectra.(nicename).(rng{1}).f     = r_out.f;
        end
    end
end

disp(['Loaded ' D.animal ' ' D.restraint ' ' D.drug_name ' session: ' sessionName])
end
