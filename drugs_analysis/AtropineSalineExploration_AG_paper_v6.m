%% AtropineSalineExploration_AG_paper_v6
% Rigorous session-level exploratory analysis for ferret atropine/saline data.
%
% Scientific goal:
% 1. Test whether atropine uniformly suppresses OB gamma or instead
%    reorganizes separable gamma components.
% 2. Test whether atropine increases OB delta/theta or changes low-frequency
%    structure in a less trivial way.
% 3. For Ficello fUS sessions, test whether CBV-like power-Doppler signals
%    decrease after injection and whether this effect is stronger under atropine.
% 4. Test whether HPC and AEG/ACx CBV share a global component.
% 5. Test whether slow OB spectral state is coupled to CBV and whether
%    atropine changes this coupling.
%
% Analysis unit:
% Each session contributes one value per scalar metric. Do not infer drug
% effects from time points because all traces are strongly autocorrelated.
%
% MATLAB: written for R2018b and custom tsd/intervalSet code.
% Helper functions are in AG_helpers/ rather than at the bottom of this file.

clear all
close all

thisFile = mfilename('fullpath');
[thisFolder, ~, ~] = fileparts(thisFile);
helperFolder = fullfile(thisFolder, 'AG_helpers');
if exist(helperFolder, 'dir')
    addpath(helperFolder)
else
    warning('AG_helpers folder not found next to this script.')
end

%% Parameters

SaveFigures = 1;
SaveFolder = 'Z:\Arsenii\OB_fUS_Arousal\Processed_data\AtropineSaline_AG_figures_v6\';
if SaveFigures && ~exist(SaveFolder, 'dir')
    mkdir(SaveFolder);
end

wantedSlice = 'B';
DrugNames = {'Saline','Atropine'};
DrugQueryNames = {'saline','atropine'};
DrugColors = {[.3 .3 .3],[.3 1 .3]};
ColorBefore = [0.3010, 0.7450, 0.9330];
ColorAfter = [0.9290, 0.6940, 0.1250];

% Immediate peri-injection window excluded from pre/post summaries.
InjExclusionSec = 5*60;

% Smoothing windows. Band metrics use minimally smoothed traces. LongSmoothSec
% is used only for slow OB-CBV coupling.
PowerSmoothSec = 0.3;
TraceSmoothSec = 10;
LongSmoothSec = 5*60;
DistributionSmoothBins = 5;
NInterp = 100;
PostTimeGridSec = InjExclusionSec:60:85*60;
LagSec = (-30:2:30)*60;

% OB spectral bands. highGamma is intentionally non-overlapping with gamma.
Bands.delta = [0.5 4];
Bands.theta = [3 6];
Bands.lowGamma = [20 40];
Bands.gamma = [40 60];
Bands.highGamma = [60 80];
Bands.gammaPeakSearch = [25 90];
MiddleFreqGrid = 0:0.5:120;
LowFreqGrid = 0:0.1:20;
UseFrequencyWeightForSpectrum = 1;
UseFrequencyWeightForBandMetrics = 0;
UseMedianSpectrumForRatio = 1;

% Set these manually when lower-dose sessions are identified. By default they
% remain included but are labelled, so exclusion is explicit and reproducible.
ExcludeSessionNameContains = {};
LowerDoseSessionNameContains = {};
ExcludeLowerDoseSessions = 0;

MakeFinalFigures = 1;
MakeSupplementaryFigures = 1;
MakeSingleSessionFigures = 1;
MakeLegacyFigures = 0;

%% Session definition

SessionDefs = struct('path',{},'animal',{},'restraint',{},'drug_name',{},'drug_id',{},'source',{},'dose_tag',{},'include',{});

% Session discovery is intentionally simple here. We query the same database
% function for every animal x setup x drug combination, then flatten the
% returned paths into SessionDefs used by the rest of the script.
%
% Ficello injection is still treated specially downstream: by design, its
% injection is assumed to occur at the midpoint of the recording unless this
% flag is set to 0 and an inj_time variable is found.
ForceFicelloMidpoint = 1;

animal_names = {'Ficello', 'Labneh', 'Shropshire', 'Brynza'};
% animal_names = {'Labneh', 'Shropshire', 'Brynza'};
% animal_names = {'Ficello'};

% setup_types = {'head-fixed', 'freely-moving'};
setup_types = {'head-fixed'};

DrugQueryNames = {'saline','atropine'};

sessions = cell(length(animal_names), 1);
for animal_idx = 1:length(animal_names)
    for setup_idx = 1:length(setup_types)
        for drug_idx = 1:length(DrugQueryNames)
            try
                sessions{animal_idx}{setup_idx}{drug_idx} = PathForExperimentsOB(animal_names{animal_idx}, setup_types{setup_idx}, DrugQueryNames{drug_idx});
            catch
                try
                    sessions{animal_idx}{setup_idx}{drug_idx} = PathForExperimentsOB({animal_names{animal_idx}}, setup_types{setup_idx}, DrugQueryNames{drug_idx});
                catch ME
                    warning('PathForExperimentsOB failed for %s / %s / %s: %s', animal_names{animal_idx}, setup_types{setup_idx}, DrugQueryNames{drug_idx}, ME.message)
                    sessions{animal_idx}{setup_idx}{drug_idx} = [];
                end
            end
        end
    end
end

% Convert the nested sessions cell array into the flat SessionDefs structure.
% Duplicate paths are skipped to avoid double-counting if an animal appears
% twice in animal_names.
SeenSessionPaths = {};
for animal_idx = 1:length(animal_names)
    for setup_idx = 1:length(setup_types)
        for drug_idx = 1:length(DrugQueryNames)
            Dir = sessions{animal_idx}{setup_idx}{drug_idx};
            if isempty(Dir)
                continue
            end
            if isstruct(Dir) && isfield(Dir, 'path')
                paths = Dir.path;
            elseif iscell(Dir)
                paths = Dir;
            elseif ischar(Dir)
                paths = {Dir};
            else
                warning('Unsupported session output for %s / %s / %s.', animal_names{animal_idx}, setup_types{setup_idx}, DrugQueryNames{drug_idx})
                continue
            end
            if ischar(paths)
                paths = {paths};
            end
            paths = paths(:);
            for sess_idx = 1:length(paths)
                if isempty(paths{sess_idx})
                    continue
                end
                sessionPath = paths{sess_idx};
                alreadySeen = 0;
                for seen_idx = 1:length(SeenSessionPaths)
                    if strcmp(sessionPath, SeenSessionPaths{seen_idx})
                        alreadySeen = 1;
                    end
                end
                if alreadySeen
                    continue
                end
                SeenSessionPaths{end+1} = sessionPath;
                SessionDefs(end+1) = make_session_entry_AG(sessionPath, animal_names{animal_idx}, setup_types{setup_idx}, DrugNames{drug_idx}, drug_idx, 'PathForExperimentsOB', 'standard_or_unknown', 1);
            end
        end
    end
end

fprintf('Session definition: %d unique sessions loaded from PathForExperimentsOB.\n', length(SessionDefs));

% Explicit low-dose and exclusion flags. These rely on substring matching of
% the session path or name, so they are easy to edit without touching analysis.
for i = 1:length(SessionDefs)
    [~, nm] = fileparts(SessionDefs(i).path);
    tokenText = [SessionDefs(i).path ' ' nm];
    for k = 1:length(LowerDoseSessionNameContains)
        if ~isempty(strfind(tokenText, LowerDoseSessionNameContains{k}))
            SessionDefs(i).dose_tag = 'low_dose_candidate';
        end
    end
    for k = 1:length(ExcludeSessionNameContains)
        if ~isempty(strfind(tokenText, ExcludeSessionNameContains{k}))
            SessionDefs(i).include = 0;
        end
    end
    if ExcludeLowerDoseSessions && strcmp(SessionDefs(i).dose_tag, 'low_dose_candidate')
        SessionDefs(i).include = 0;
    end
end

SessionDefs = SessionDefs([SessionDefs.include] == 1);

%% Load sessions

AllSessions = struct();
sessionCounter = 0;
for i = 1:length(SessionDefs)
    D = SessionDefs(i);
    datapath = D.path;
    [~, sessionName] = fileparts(datapath);

    sessionCounter = sessionCounter + 1;
    AllSessions(sessionCounter).name = sessionName;
    AllSessions(sessionCounter).path = datapath;
    AllSessions(sessionCounter).animal = D.animal;
    AllSessions(sessionCounter).restraint = D.restraint;
    AllSessions(sessionCounter).drug_id = D.drug_id;
    AllSessions(sessionCounter).drug_name = D.drug_name;
    AllSessions(sessionCounter).drug_sess = sessionCounter;
    AllSessions(sessionCounter).source = D.source;
    AllSessions(sessionCounter).dose_tag = D.dose_tag;
    AllSessions(sessionCounter).inj_time_sec = NaN;
    AllSessions(sessionCounter).force_midpoint_injection = strcmp(D.animal, 'Ficello') && ForceFicelloMidpoint;

    % fUS is optional and expected mainly for Ficello.
    fus_file = dir(fullfile(datapath, 'fUS', ['RP_data_*slice_' wantedSlice '.mat']));
    if ~isempty(fus_file)
        tmp = load(fullfile(datapath, 'fUS', fus_file(1).name), 'cat_tsd', 'masks');
        AllSessions(sessionCounter).fUS.cat_tsd = tmp.cat_tsd;
        AllSessions(sessionCounter).fUS.masks = tmp.masks;
    end

    % OB gamma/delta and injection time when available.
    GammaPowerFile = fullfile(datapath, 'ephys', 'SleepScoring_OBGamma.mat');
    if ~exist(GammaPowerFile, 'file')
        GammaPowerFile = fullfile(datapath, 'SleepScoring_OBGamma.mat');
    end
    if exist(GammaPowerFile, 'file')
        tmp = load(GammaPowerFile);
        if isfield(tmp, 'BrainPower')
            AllSessions(sessionCounter).GammaPower = tmp.BrainPower.Power{1,1};
            AllSessions(sessionCounter).DeltaPower = tmp.BrainPower.Power{1,2};
        elseif isfield(tmp, 'SmoothGamma')
            AllSessions(sessionCounter).GammaPower = tmp.SmoothGamma;
            warning('Using SmoothGamma as GammaPower for %s because BrainPower was not found.', sessionName)
        else
            warning('No BrainPower or SmoothGamma in %s', GammaPowerFile)
        end
        if isfield(tmp, 'inj_time') && ~AllSessions(sessionCounter).force_midpoint_injection
            AllSessions(sessionCounter).inj_time_sec = convert_inj_time_to_sec_AG(tmp.inj_time);
        end
    else
        warning('No SleepScoring_OBGamma.mat for session %s', sessionName)
    end

    % Optional movement, heart, and sleep state information for QC/confounds.
    behavFile = fullfile(datapath, 'behavResources.mat');
    if exist(behavFile, 'file')
        tmp = load(behavFile);
        if isfield(tmp, 'MovAcctsd')
            AllSessions(sessionCounter).MovAcctsd = tmp.MovAcctsd;
        end
    end
    hbFile = fullfile(datapath, 'ephys', 'HeartBeatInfo.mat');
    if ~exist(hbFile, 'file')
        hbFile = fullfile(datapath, 'HeartBeatInfo.mat');
    end
    if exist(hbFile, 'file')
        tmp = load(hbFile);
        if isfield(tmp, 'EKG') && isfield(tmp.EKG, 'HBRate')
            AllSessions(sessionCounter).HeartRate = tmp.EKG.HBRate;
        end
    end

    % Middle OB spectrum.
    specFile = fullfile(datapath, 'ephys', 'B_Middle_Spectrum_HighPass.mat');
    if ~exist(specFile, 'file')
        specFile = fullfile(datapath, 'ephys', 'B_Middle_Spectrum.mat');
    end
    if ~exist(specFile, 'file')
        specFile = fullfile(datapath, 'B_Middle_Spectrum.mat');
    end
    if exist(specFile, 'file')
        tmp = load(specFile);
        if isfield(tmp, 'Spectro')
            AllSessions(sessionCounter).SpectroMiddle.sptsdB = tsd(tmp.Spectro{2}*1e4, tmp.Spectro{1});
            AllSessions(sessionCounter).SpectroMiddle.fB = tmp.Spectro{3};
        end
    end

    % Low OB spectrum.
    specFile = fullfile(datapath, 'ephys', 'B_Low_Spectrum.mat');
    if ~exist(specFile, 'file')
        specFile = fullfile(datapath, 'B_Low_Spectrum.mat');
    end
    if exist(specFile, 'file')
        tmp = load(specFile);
        if isfield(tmp, 'Spectro')
            AllSessions(sessionCounter).SpectroLow.sptsdB = tsd(tmp.Spectro{2}*1e4, tmp.Spectro{1});
            AllSessions(sessionCounter).SpectroLow.fB = tmp.Spectro{3};
        end
    end

    disp(['Loaded ' D.animal ' ' D.restraint ' ' D.drug_name ' session: ' sessionName])
end

%% Compute traces, metrics and per-session objects

nSess = length(AllSessions);
if nSess > 0
    Metrics = repmat(initialize_metrics(AllSessions(1)), 1, nSess);
else
    Metrics = struct();
end
Ana = struct();

Group = struct();
for drug = 1:2
    Group.gamma_after_norm{drug} = [];
    Group.delta_after_norm{drug} = [];
    Group.hpc_after_norm{drug} = [];
    Group.aeg_after_norm{drug} = [];
    Group.gamma_before_norm{drug} = [];
    Group.delta_before_norm{drug} = [];
    Group.hpc_before_norm{drug} = [];
    Group.aeg_before_norm{drug} = [];
    Group.middle_log2ratio{drug} = [];
    Group.low_log2ratio{drug} = [];
    Group.middle_before_fweighted{drug} = [];
    Group.middle_after_fweighted{drug} = [];
    Group.low_before_fweighted{drug} = [];
    Group.low_after_fweighted{drug} = [];
    Group.lag_gamma_hpc_before{drug} = [];
    Group.lag_gamma_hpc_after{drug} = [];
    Group.lag_gamma_aeg_before{drug} = [];
    Group.lag_gamma_aeg_after{drug} = [];
    Group.state_occ_before{drug} = [];
    Group.state_occ_after{drug} = [];
    Group.gamma_after_real{drug} = [];
    Group.delta_after_real{drug} = [];
    Group.hpc_dcbv_after_real{drug} = [];
    Group.aeg_dcbv_after_real{drug} = [];
end

for sess = 1:nSess
    S = AllSessions(sess);
    drug = S.drug_id;
    Metrics(sess) = initialize_metrics(S);
    Metrics(sess).animal = S.animal;
    Metrics(sess).restraint = S.restraint;
    Metrics(sess).source = S.source;
    Metrics(sess).dose_tag = S.dose_tag;

    if ~isfield(S, 'GammaPower') || ~isfield(S, 'DeltaPower')
        warning('Skipping session %s because OB gamma/delta powers are missing.', S.name)
        continue
    end

    Gamma = S.GammaPower;
    GammaData = Data(Gamma);
    TGamma = Range(Gamma,'s');
    TGamma = TGamma(:);
    GammaData = smooth_by_time(GammaData(:), TGamma, PowerSmoothSec);

    Delta = S.DeltaPower;
    DeltaData = Data(Delta);
    TDelta = Range(Delta,'s');
    TDelta = TDelta(:);
    DeltaData = smooth_by_time(DeltaData(:), TDelta, PowerSmoothSec);

    hasFUS = 0;
    TFUS = [];
    trace_hipp = [];
    trace_AEG = [];
    hpc_norm = [];
    aeg_norm = [];
    hpc_dcbv_percent = [];
    aeg_dcbv_percent = [];

    if isfield(S, 'fUS') && isfield(S.fUS, 'cat_tsd') && isfield(S.fUS, 'masks') && ...
            isfield(S.fUS.masks, 'Hippocampus') && isfield(S.fUS.masks, 'AEG')
        hasFUS = 1;
        cat_tsd = S.fUS.cat_tsd;
        masks = S.fUS.masks;
        fUSData = Data(cat_tsd.data);
        fUSDataReshaped = reshape(fUSData', cat_tsd.Nx, cat_tsd.Ny, size(fUSData,1));
        Nt = size(fUSDataReshaped,3);
        TFUS = Range(cat_tsd.data,'s');
        TFUS = TFUS(:);

        mask_hipp = masks.Hippocampus;
        mask_AEG = masks.AEG;
        trace_hipp = nan(Nt,1);
        trace_AEG = nan(Nt,1);
        for t = 1:Nt
            frame = fUSDataReshaped(:,:,t);
            trace_hipp(t) = nanmean(frame(mask_hipp));
            trace_AEG(t) = nanmean(frame(mask_AEG));
        end
        clear fUSData fUSDataReshaped
        trace_hipp = smooth_by_time(trace_hipp, TFUS, TraceSmoothSec);
        trace_AEG = smooth_by_time(trace_AEG, TFUS, TraceSmoothSec);
    end

    % Reference time base: fUS if present, otherwise OB gamma time.
    if hasFUS
        Tref = TFUS;
    else
        Tref = TGamma;
    end

    if isfinite(S.inj_time_sec)
        t_inj = S.inj_time_sec;
    elseif hasFUS
        t_inj = Tref(round(length(Tref)/2));
    else
        t_inj = Tref(round(length(Tref)/2));
    end

    [idx_before, idx_after] = injection_epoch_indices(Tref, t_inj, InjExclusionSec);
    if sum(idx_before) < 10 || sum(idx_after) < 10
        warning('Session %s has few pre/post points after exclusion.', S.name)
    end

    Gamma_metric = interp1(TGamma, GammaData, Tref, 'linear', NaN);
    Delta_metric = interp1(TDelta, DeltaData, Tref, 'linear', NaN);
    Gamma_trace = smooth_by_time(Gamma_metric, Tref, TraceSmoothSec);
    Delta_trace = smooth_by_time(Delta_metric, Tref, TraceSmoothSec);

    gamma_baseline = nanmedian(Gamma_metric(idx_before));
    delta_baseline = nanmedian(Delta_metric(idx_before));
    gamma_trace_baseline = nanmedian(Gamma_trace(idx_before));
    delta_trace_baseline = nanmedian(Delta_trace(idx_before));
    gamma_norm = Gamma_trace ./ gamma_trace_baseline;
    delta_norm = Delta_trace ./ delta_trace_baseline;

    if hasFUS
        hpc_baseline = nanmedian(trace_hipp(idx_before));
        aeg_baseline = nanmedian(trace_AEG(idx_before));
        hpc_dcbv = (trace_hipp - hpc_baseline) ./ hpc_baseline;
        aeg_dcbv = (trace_AEG - aeg_baseline) ./ aeg_baseline;
        hpc_norm = 1 + hpc_dcbv;
        aeg_norm = 1 + aeg_dcbv;
        hpc_dcbv_percent = 100*hpc_dcbv;
        aeg_dcbv_percent = 100*aeg_dcbv;
    else
        hpc_norm = nan(size(Tref));
        aeg_norm = nan(size(Tref));
        hpc_dcbv_percent = nan(size(Tref));
        aeg_dcbv_percent = nan(size(Tref));
        trace_hipp = nan(size(Tref));
        trace_AEG = nan(size(Tref));
    end

    log_gamma_long = smooth_by_time(safe_log(Gamma_metric), Tref, LongSmoothSec);
    log_delta_long = smooth_by_time(safe_log(Delta_metric), Tref, LongSmoothSec);
    log_hpc_long = smooth_by_time(safe_log(trace_hipp), Tref, LongSmoothSec);
    log_aeg_long = smooth_by_time(safe_log(trace_AEG), Tref, LongSmoothSec);

    log_gamma = safe_log(Gamma_metric);
    log_delta = safe_log(Delta_metric);
    gamma_thr = nanmedian(log_gamma(idx_before));
    delta_thr = nanmedian(log_delta(idx_before));
    OBState = nan(size(Tref));
    OBState(log_gamma >= gamma_thr & log_delta <  delta_thr) = 1;
    OBState(log_gamma <  gamma_thr & log_delta >= delta_thr) = 2;
    OBState(log_gamma >= gamma_thr & log_delta >= delta_thr) = 3;
    OBState(log_gamma <  gamma_thr & log_delta <  delta_thr) = 4;

    row = size(Group.gamma_after_norm{drug},1) + 1;
    Group.middle_log2ratio{drug}(row,1:length(MiddleFreqGrid)) = NaN;
    Group.middle_before_fweighted{drug}(row,1:length(MiddleFreqGrid)) = NaN;
    Group.middle_after_fweighted{drug}(row,1:length(MiddleFreqGrid)) = NaN;
    Group.low_log2ratio{drug}(row,1:length(LowFreqGrid)) = NaN;
    Group.low_before_fweighted{drug}(row,1:length(LowFreqGrid)) = NaN;
    Group.low_after_fweighted{drug}(row,1:length(LowFreqGrid)) = NaN;
    Group.state_occ_before{drug}(row,:) = state_occupancy(OBState, idx_before, 4);
    Group.state_occ_after{drug}(row,:) = state_occupancy(OBState, idx_after, 4);
    Group.gamma_before_norm{drug}(row,:) = interp_epoch_to_unit_time(gamma_norm, idx_before, NInterp);
    Group.gamma_after_norm{drug}(row,:) = interp_epoch_to_unit_time(gamma_norm, idx_after, NInterp);
    Group.delta_before_norm{drug}(row,:) = interp_epoch_to_unit_time(delta_norm, idx_before, NInterp);
    Group.delta_after_norm{drug}(row,:) = interp_epoch_to_unit_time(delta_norm, idx_after, NInterp);
    Group.hpc_before_norm{drug}(row,:) = interp_epoch_to_unit_time(hpc_norm, idx_before, NInterp);
    Group.hpc_after_norm{drug}(row,:) = interp_epoch_to_unit_time(hpc_norm, idx_after, NInterp);
    Group.aeg_before_norm{drug}(row,:) = interp_epoch_to_unit_time(aeg_norm, idx_before, NInterp);
    Group.aeg_after_norm{drug}(row,:) = interp_epoch_to_unit_time(aeg_norm, idx_after, NInterp);
    Group.gamma_after_real{drug}(row,:) = interp_relative_time(Tref, gamma_norm, t_inj, PostTimeGridSec);
    Group.delta_after_real{drug}(row,:) = interp_relative_time(Tref, delta_norm, t_inj, PostTimeGridSec);
    Group.hpc_dcbv_after_real{drug}(row,:) = interp_relative_time(Tref, hpc_dcbv_percent, t_inj, PostTimeGridSec);
    Group.aeg_dcbv_after_real{drug}(row,:) = interp_relative_time(Tref, aeg_dcbv_percent, t_inj, PostTimeGridSec);

    Metrics(sess).inj_time_min = t_inj/60;
    Metrics(sess).n_ref_before = sum(idx_before);
    Metrics(sess).n_ref_after = sum(idx_after);
    Metrics(sess).n_fus_before = NaN;
    Metrics(sess).n_fus_after = NaN;
    if hasFUS
        Metrics(sess).n_fus_before = sum(idx_before);
        Metrics(sess).n_fus_after = sum(idx_after);
    end
    Metrics(sess).has_fus = hasFUS;
    Metrics(sess).gamma_logratio = log_ratio_median(Gamma_metric, idx_before, idx_after);
    Metrics(sess).delta_logratio = log_ratio_median(Delta_metric, idx_before, idx_after);
    
    if hasFUS
        Metrics(sess).hpc_cbv_logratio = log_ratio_median(trace_hipp, idx_before, idx_after);
        Metrics(sess).aeg_cbv_logratio = log_ratio_median(trace_AEG, idx_before, idx_after);
        Metrics(sess).hpc_dcbv_after_percent = nanmedian(hpc_dcbv_percent(idx_after));
        Metrics(sess).aeg_dcbv_after_percent = nanmedian(aeg_dcbv_percent(idx_after));
        Metrics(sess).hpc_aeg_r_before = corr_nan(safe_log(trace_hipp(idx_before)), safe_log(trace_AEG(idx_before)));
        Metrics(sess).hpc_aeg_r_after = corr_nan(safe_log(trace_hipp(idx_after)), safe_log(trace_AEG(idx_after)));
        Metrics(sess).gamma_hpc_r_before = corr_nan(log_gamma_long(idx_before), log_hpc_long(idx_before));
        Metrics(sess).gamma_hpc_r_after = corr_nan(log_gamma_long(idx_after), log_hpc_long(idx_after));
        Metrics(sess).gamma_aeg_r_before = corr_nan(log_gamma_long(idx_before), log_aeg_long(idx_before));
        Metrics(sess).gamma_aeg_r_after = corr_nan(log_gamma_long(idx_after), log_aeg_long(idx_after));
        Metrics(sess).delta_hpc_r_before = corr_nan(log_delta_long(idx_before), log_hpc_long(idx_before));
        Metrics(sess).delta_hpc_r_after = corr_nan(log_delta_long(idx_after), log_hpc_long(idx_after));
        Metrics(sess).gamma_hpc_r_detr_before = corr_nan(detrend_nan(log_gamma_long(idx_before)), detrend_nan(log_hpc_long(idx_before)));
        Metrics(sess).gamma_hpc_r_detr_after = corr_nan(detrend_nan(log_gamma_long(idx_after)), detrend_nan(log_hpc_long(idx_after)));
        Metrics(sess).gamma_aeg_r_detr_before = corr_nan(detrend_nan(log_gamma_long(idx_before)), detrend_nan(log_aeg_long(idx_before)));
        Metrics(sess).gamma_aeg_r_detr_after = corr_nan(detrend_nan(log_gamma_long(idx_after)), detrend_nan(log_aeg_long(idx_after)));
        
        Group.lag_gamma_hpc_before{drug}(row,:) = lag_corr_curve(Tref, log_gamma_long, log_hpc_long, idx_before, LagSec);
        Group.lag_gamma_hpc_after{drug}(row,:) = lag_corr_curve(Tref, log_gamma_long, log_hpc_long, idx_after, LagSec);
        Group.lag_gamma_aeg_before{drug}(row,:) = lag_corr_curve(Tref, log_gamma_long, log_aeg_long, idx_before, LagSec);
        Group.lag_gamma_aeg_after{drug}(row,:) = lag_corr_curve(Tref, log_gamma_long, log_aeg_long, idx_after, LagSec);
    else
        Group.lag_gamma_hpc_before{drug}(row,:) = nan(1,length(LagSec));
        Group.lag_gamma_hpc_after{drug}(row,:) = nan(1,length(LagSec));
        Group.lag_gamma_aeg_before{drug}(row,:) = nan(1,length(LagSec));
        Group.lag_gamma_aeg_after{drug}(row,:) = nan(1,length(LagSec));
    end

    if isfield(S, 'SpectroMiddle')
        sptsdB = S.SpectroMiddle.sptsdB;
        spec = Data(sptsdB);
        t_spec = Range(sptsdB,'s');
        t_spec = t_spec(:);
        f = S.SpectroMiddle.fB(:)';
        [idx_spec_before, idx_spec_after] = injection_epoch_indices(t_spec, t_inj, InjExclusionSec);
        Spec_before_mean = epoch_spectrum(spec, idx_spec_before, 'mean');
        Spec_after_mean = epoch_spectrum(spec, idx_spec_after, 'mean');
        Spec_before_med = epoch_spectrum(spec, idx_spec_before, 'median');
        Spec_after_med = epoch_spectrum(spec, idx_spec_after, 'median');
        if UseFrequencyWeightForSpectrum
            Spec_before_plot = f .* Spec_before_mean;
            Spec_after_plot = f .* Spec_after_mean;
        else
            Spec_before_plot = Spec_before_mean;
            Spec_after_plot = Spec_after_mean;
        end
        Spec_before_plot_grid = interp1(f, Spec_before_plot, MiddleFreqGrid, 'linear', NaN);
        Spec_after_plot_grid = interp1(f, Spec_after_plot, MiddleFreqGrid, 'linear', NaN);
        Group.middle_before_fweighted{drug}(row,:) = Spec_before_plot_grid;
        Group.middle_after_fweighted{drug}(row,:) = Spec_after_plot_grid;
        if UseMedianSpectrumForRatio
            Spec_before_ratio = Spec_before_med;
            Spec_after_ratio = Spec_after_med;
        else
            Spec_before_ratio = Spec_before_mean;
            Spec_after_ratio = Spec_after_mean;
        end
        MiddleRatioNative = log2((Spec_after_ratio + eps) ./ (Spec_before_ratio + eps));
        Group.middle_log2ratio{drug}(row,:) = interp1(f, MiddleRatioNative, MiddleFreqGrid, 'linear', NaN);

        lowGammaSpec = spectrum_band_timeseries(spec, f, Bands.lowGamma, UseFrequencyWeightForBandMetrics);
        gammaSpec = spectrum_band_timeseries(spec, f, Bands.gamma, UseFrequencyWeightForBandMetrics);
        highGammaSpec = spectrum_band_timeseries(spec, f, Bands.highGamma, UseFrequencyWeightForBandMetrics);
        Metrics(sess).lowgamma_spec_logratio = log_ratio_median(lowGammaSpec, idx_spec_before, idx_spec_after);
        Metrics(sess).gamma_spec_logratio = log_ratio_median(gammaSpec, idx_spec_before, idx_spec_after);
        Metrics(sess).highgamma_spec_logratio = log_ratio_median(highGammaSpec, idx_spec_before, idx_spec_after);
        Metrics(sess).gamma_peak_before_hz = spectrum_peak_frequency(Spec_before_med, f, Bands.gammaPeakSearch, UseFrequencyWeightForSpectrum);
        Metrics(sess).gamma_peak_after_hz = spectrum_peak_frequency(Spec_after_med, f, Bands.gammaPeakSearch, UseFrequencyWeightForSpectrum);
        Metrics(sess).gamma_peak_shift_hz = Metrics(sess).gamma_peak_after_hz - Metrics(sess).gamma_peak_before_hz;
        Ana(sess).middle_f = MiddleFreqGrid;
        Ana(sess).middle_before_plot = Spec_before_plot_grid;
        Ana(sess).middle_after_plot = Spec_after_plot_grid;
        Ana(sess).middle_log2ratio = Group.middle_log2ratio{drug}(row,:);
    end

    if isfield(S, 'SpectroLow')
        sptsdB = S.SpectroLow.sptsdB;
        spec = Data(sptsdB);
        t_spec = Range(sptsdB,'s');
        t_spec = t_spec(:);
        f = S.SpectroLow.fB(:)';
        [idx_spec_before, idx_spec_after] = injection_epoch_indices(t_spec, t_inj, InjExclusionSec);
        Spec_before_mean = epoch_spectrum(spec, idx_spec_before, 'mean');
        Spec_after_mean = epoch_spectrum(spec, idx_spec_after, 'mean');
        Spec_before_med = epoch_spectrum(spec, idx_spec_before, 'median');
        Spec_after_med = epoch_spectrum(spec, idx_spec_after, 'median');
        if UseFrequencyWeightForSpectrum
            Spec_before_plot = f .* Spec_before_mean;
            Spec_after_plot = f .* Spec_after_mean;
        else
            Spec_before_plot = Spec_before_mean;
            Spec_after_plot = Spec_after_mean;
        end
        Spec_before_plot_grid = interp1(f, Spec_before_plot, LowFreqGrid, 'linear', NaN);
        Spec_after_plot_grid = interp1(f, Spec_after_plot, LowFreqGrid, 'linear', NaN);
        Group.low_before_fweighted{drug}(row,:) = Spec_before_plot_grid;
        Group.low_after_fweighted{drug}(row,:) = Spec_after_plot_grid;
        if UseMedianSpectrumForRatio
            Spec_before_ratio = Spec_before_med;
            Spec_after_ratio = Spec_after_med;
        else
            Spec_before_ratio = Spec_before_mean;
            Spec_after_ratio = Spec_after_mean;
        end
        LowRatioNative = log2((Spec_after_ratio + eps) ./ (Spec_before_ratio + eps));
        Group.low_log2ratio{drug}(row,:) = interp1(f, LowRatioNative, LowFreqGrid, 'linear', NaN);
        deltaSpec = spectrum_band_timeseries(spec, f, Bands.delta, UseFrequencyWeightForBandMetrics);
        thetaSpec = spectrum_band_timeseries(spec, f, Bands.theta, UseFrequencyWeightForBandMetrics);
        Metrics(sess).delta_spec_logratio = log_ratio_median(deltaSpec, idx_spec_before, idx_spec_after);
        Metrics(sess).theta_spec_logratio = log_ratio_median(thetaSpec, idx_spec_before, idx_spec_after);
        Ana(sess).low_f = LowFreqGrid;
        Ana(sess).low_before_plot = Spec_before_plot_grid;
        Ana(sess).low_after_plot = Spec_after_plot_grid;
        Ana(sess).low_log2ratio = Group.low_log2ratio{drug}(row,:);
    end

    Ana(sess).name = S.name;
    Ana(sess).animal = S.animal;
    Ana(sess).restraint = S.restraint;
    Ana(sess).drug_name = S.drug_name;
    Ana(sess).drug_id = drug;
    Ana(sess).Tref = Tref;
    Ana(sess).t_inj = t_inj;
    Ana(sess).idx_before = idx_before;
    Ana(sess).idx_after = idx_after;
    Ana(sess).gamma = Gamma_metric;
    Ana(sess).delta = Delta_metric;
    Ana(sess).gamma_norm = gamma_norm;
    Ana(sess).delta_norm = delta_norm;
    Ana(sess).hpc = trace_hipp;
    Ana(sess).aeg = trace_AEG;
    Ana(sess).hpc_norm = hpc_norm;
    Ana(sess).aeg_norm = aeg_norm;
    Ana(sess).hpc_dcbv_percent = hpc_dcbv_percent;
    Ana(sess).aeg_dcbv_percent = aeg_dcbv_percent;
    Ana(sess).log_gamma_long = log_gamma_long;
    Ana(sess).log_delta_long = log_delta_long;
    Ana(sess).log_hpc_long = log_hpc_long;
    Ana(sess).log_aeg_long = log_aeg_long;
    Ana(sess).OBState = OBState;
    if hasFUS
        Ana(sess).meanImg = create_mean_fus_image(S.fUS.cat_tsd, S.fUS.masks);
        Ana(sess).masks = S.fUS.masks;
    end

    if MakeSingleSessionFigures
        make_single_session_qc_AG(Ana(sess), Metrics(sess), ColorBefore, ColorAfter, Bands, SaveFigures, SaveFolder)
    end

    disp(['Analyzed ' S.animal ' ' S.restraint ' ' S.drug_name ' session: ' S.name])
end

%% Save session metrics and drug statistics

MetricsTable = struct2table(Metrics);
if ~ismember('has_fus', MetricsTable.Properties.VariableNames)
    MetricsTable.has_fus = false(height(MetricsTable),1);
end

StatFields = {'gamma_logratio','delta_logratio','lowgamma_spec_logratio','gamma_spec_logratio','highgamma_spec_logratio',...
    'delta_spec_logratio','theta_spec_logratio','gamma_peak_shift_hz','hpc_cbv_logratio','aeg_cbv_logratio',...
    'hpc_aeg_r_before','hpc_aeg_r_after','gamma_hpc_r_before','gamma_hpc_r_after','gamma_aeg_r_before','gamma_aeg_r_after',...
    'gamma_hpc_r_detr_before','gamma_hpc_r_detr_after','gamma_aeg_r_detr_before','gamma_aeg_r_detr_after'};
Stats = struct();
for k = 1:length(StatFields)
    Stats(k) = simple_group_stats_AG(MetricsTable, StatFields{k});
end
StatsTable = struct2table(Stats);

if SaveFigures
    writetable(MetricsTable, fullfile(SaveFolder, 'AtropineSaline_session_metrics_v6.csv'));
    writetable(StatsTable, fullfile(SaveFolder, 'AtropineSaline_drug_stats_v6.csv'));
    save(fullfile(SaveFolder, 'AtropineSaline_workspace_v6.mat'), 'AllSessions', 'Ana', 'Metrics', 'MetricsTable', 'StatsTable', 'Group', 'Bands')
end

%% Final Figure 1: OB effects across all sessions

if MakeFinalFigures
    x_post_h = PostTimeGridSec/3600;
    figure('Name','Figure 1 - OB drug effects across sessions','Position',[100 100 1500 850]);
    sgtitle('OB band-power effects: session-level tests across available animals')

    subplot(2,4,1)
    plot_group_timecourse_clean(x_post_h, Group.gamma_after_real, DrugColors, 1)
    ylabel('OB gamma / baseline')
    title('40-60 Hz BrainPower')

    subplot(2,4,2)
    plot_group_timecourse_clean(x_post_h, Group.delta_after_real, DrugColors, 1)
    ylabel('OB delta / baseline')
    title('0.5-4 Hz BrainPower')

    subplot(2,4,3)
    plot_metric_by_drug_restraint_AG(MetricsTable, 'gamma_logratio', DrugColors)
    ylabel('log after/before')
    title('Gamma by restraint')

    subplot(2,4,4)
    plot_metric_by_drug_restraint_AG(MetricsTable, 'delta_logratio', DrugColors)
    ylabel('log after/before')
    title('Delta by restraint')

    subplot(2,4,5)
    plot_animal_session_points_AG(MetricsTable, 'gamma_logratio', DrugColors)
    ylabel('log after/before')
    title('Gamma by animal')

    subplot(2,4,6)
    plot_animal_session_points_AG(MetricsTable, 'delta_logratio', DrugColors)
    ylabel('log after/before')
    title('Delta by animal')

    subplot(2,4,7)
    plot_metric_by_drug(MetricsTable, 'gamma_peak_shift_hz', DrugColors, 1:2, DrugNames)
    ylabel('after-before peak Hz')
    title('Gamma peak shift')

    subplot(2,4,8)
    plot_metric_by_drug(MetricsTable, 'theta_spec_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log after/before')
    title('Theta/low-frequency')

    save_current_figure(SaveFigures, SaveFolder, 'Figure_1_OB_all_sessions.png')
end

%% Final Figure 2: OB spectral reorganization

if MakeFinalFigures
    figure('Name','Figure 2 - OB spectral reorganization','Position',[100 100 1500 850]);
    sgtitle('Atropine can dissociate OB spectral components')

    subplot(2,3,1)
    plot_group_log2ratio_clean(AllSessions, Group.low_log2ratio, 'low', DrugColors, DistributionSmoothBins)
    xlim([0 20])
    ylabel('log2 after/before')
    title('Low-frequency spectrum')
    vline_compat(Bands.delta(1),'--r'); vline_compat(Bands.delta(2),'--r')
    vline_compat(Bands.theta(1),'--k'); vline_compat(Bands.theta(2),'--k')

    subplot(2,3,2)
    plot_group_log2ratio_clean(AllSessions, Group.middle_log2ratio, 'middle', DrugColors, DistributionSmoothBins)
    xlim([20 100])
    ylabel('log2 after/before')
    title('Gamma-range spectrum')
    vline_compat(Bands.lowGamma(1),'--r'); vline_compat(Bands.lowGamma(2),'--r')
    vline_compat(Bands.gamma(1),'--k'); vline_compat(Bands.gamma(2),'--k')
    vline_compat(Bands.highGamma(1),'--b'); vline_compat(Bands.highGamma(2),'--b')

    subplot(2,3,3)
    plot_metric_by_drug(MetricsTable, 'theta_spec_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log after/before')
    title('3-6 Hz')

    subplot(2,3,4)
    plot_metric_by_drug(MetricsTable, 'lowgamma_spec_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log after/before')
    title('20-40 Hz')

    subplot(2,3,5)
    plot_metric_by_drug(MetricsTable, 'gamma_spec_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log after/before')
    title('40-60 Hz')

    subplot(2,3,6)
    plot_metric_by_drug(MetricsTable, 'highgamma_spec_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log after/before')
    title('60-80 Hz')

    save_current_figure(SaveFigures, SaveFolder, 'Figure_2_OB_spectral_reorganization.png')
end

%% Final Figure 3: Ficello fUS drug effects

if MakeFinalFigures
    fUSMetrics = MetricsTable(MetricsTable.has_fus == 1,:);
    figure('Name','Figure 3 - fUS CBV drug effects','Position',[100 100 1500 850]);
    sgtitle('fUS-derived CBV effects in sessions with fUS')

    subplot(2,4,1)
    plot_group_timecourse_clean(x_post_h, Group.hpc_dcbv_after_real, DrugColors, 0)
    ylabel('HPC dCBV (%)')
    title('HPC time course')

    subplot(2,4,2)
    plot_group_timecourse_clean(x_post_h, Group.aeg_dcbv_after_real, DrugColors, 0)
    ylabel('AEG/ACx dCBV (%)')
    title('AEG/ACx time course')

    subplot(2,4,3)
    plot_metric_by_drug(fUSMetrics, 'hpc_cbv_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log after/before')
    title('HPC CBV')

    subplot(2,4,4)
    plot_metric_by_drug(fUSMetrics, 'aeg_cbv_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log after/before')
    title('AEG/ACx CBV')

    subplot(2,4,5)
    plot_prepost_metric_by_drug(fUSMetrics, 'hpc_aeg_r_before', 'hpc_aeg_r_after', DrugColors)
    ylabel('r(log HPC, log AEG)')
    title('Global CBV component')

    subplot(2,4,6)
    plot_metric_by_drug(fUSMetrics, 'hpc_dcbv_after_percent', DrugColors, 1:2, DrugNames)
    ylabel('median post dCBV (%)')
    title('HPC dCBV')

    subplot(2,4,7)
    plot_metric_by_drug(fUSMetrics, 'aeg_dcbv_after_percent', DrugColors, 1:2, DrugNames)
    ylabel('median post dCBV (%)')
    title('AEG/ACx dCBV')

    subplot(2,4,8)
    plot_metric_by_drug(fUSMetrics, 'hpc_aeg_r_after', DrugColors, 1:2, DrugNames)
    ylabel('r after')
    title('HPC-AEG after')

    save_current_figure(SaveFigures, SaveFolder, 'Figure_3_fUS_CBV_effects.png')
end

%% Final Figure 4: OB-CBV coupling in fUS sessions

if MakeFinalFigures
    fUSMetrics = MetricsTable(MetricsTable.has_fus == 1,:);
    figure('Name','Figure 4 - OB-CBV coupling','Position',[100 100 1500 850]);
    sgtitle('Long-timescale OB-CBV coupling and atropine')

    subplot(2,3,1)
    plot_prepost_metric_by_drug(fUSMetrics, 'gamma_hpc_r_before', 'gamma_hpc_r_after', DrugColors)
    ylabel('r(log gamma, log HPC)')
    title('Gamma-HPC')

    subplot(2,3,2)
    plot_prepost_metric_by_drug(fUSMetrics, 'gamma_aeg_r_before', 'gamma_aeg_r_after', DrugColors)
    ylabel('r(log gamma, log AEG)')
    title('Gamma-AEG/ACx')

    subplot(2,3,3)
    plot_prepost_metric_by_drug(fUSMetrics, 'delta_hpc_r_before', 'delta_hpc_r_after', DrugColors)
    ylabel('r(log delta, log HPC)')
    title('Delta-HPC')

    subplot(2,3,4)
    plot_prepost_metric_by_drug(fUSMetrics, 'gamma_hpc_r_detr_before', 'gamma_hpc_r_detr_after', DrugColors)
    ylabel('detrended r')
    title('Gamma-HPC detrended')

    subplot(2,3,5)
    plot_lag_group_clean(LagSec/60, Group.lag_gamma_hpc_after, DrugColors)
    xlabel('CBV lag relative to OB gamma (min)')
    ylabel('r')
    title('Gamma-HPC lag after')

    subplot(2,3,6)
    plot_lag_group_clean(LagSec/60, Group.lag_gamma_aeg_after, DrugColors)
    xlabel('CBV lag relative to OB gamma (min)')
    ylabel('r')
    title('Gamma-AEG lag after')

    save_current_figure(SaveFigures, SaveFolder, 'Figure_4_OB_CBV_coupling.png')
end

%% Supplementary Figure 1: distributions and OB state occupancy

if MakeSupplementaryFigures
    figure('Name','Supplementary Figure 1 - OB distributions and states','Position',[100 100 1500 800]);
    sgtitle('OB power distributions and simple gamma/delta state occupancy')

    subplot(2,4,[1 2])
    plot_distribution_group(Ana, 'gamma', DrugColors, ColorBefore, ColorAfter)
    xlabel('log OB gamma power')
    ylabel('probability')
    title('Gamma distributions')

    subplot(2,4,[3 4])
    plot_distribution_group(Ana, 'delta', DrugColors, ColorBefore, ColorAfter)
    xlabel('log OB delta power')
    ylabel('probability')
    title('Delta distributions')

    StateLabels = {'Ghi/Dlo','Glo/Dhi','Ghi/Dhi','Glo/Dlo'};
    for st = 1:4
        subplot(2,4,st+4)
        plot_state_change_by_drug(Group, st, DrugColors, DrugNames)
        ylim([-0.4 0.4])
        ylabel('after - before fraction')
        title(StateLabels{st})
    end

    save_current_figure(SaveFigures, SaveFolder, 'Figure_S1_distributions_and_states.png')
end

%% Supplementary Figure 2: metric statistics overview

if MakeSupplementaryFigures
    figure('Name','Supplementary Figure 2 - session-level stats','Position',[100 100 1600 900]);
    sgtitle('Session-level effect-size overview; do not treat as final mixed model')
    fieldsToPlot = {'gamma_spec_logratio','lowgamma_spec_logratio','highgamma_spec_logratio','delta_spec_logratio','theta_spec_logratio','hpc_cbv_logratio','gamma_hpc_r_after','gamma_hpc_r_detr_after'};
    for k = 1:length(fieldsToPlot)
        subplot(2,4,k)
        plot_metric_by_drug(MetricsTable, fieldsToPlot{k}, DrugColors, 1:2, DrugNames)
        ylabel('session metric')
        title(fieldsToPlot{k}, 'Interpreter', 'none')
    end
    save_current_figure(SaveFigures, SaveFolder, 'Figure_S2_stats_overview.png')
end

%% Compact numerical summary

disp(' ')
disp('MetricsTable contains one row per session. StatsTable contains simple two-drug session-level summaries.')
disp('For publication-grade inference, use animal/restraint-aware mixed or permutation models outside this exploratory plotting script.')
disp('Core variables: AllSessions, Ana, MetricsTable, StatsTable, Group, Bands.')
