%% AtropineSalineExploration_AG_paper_v7
% Rigorous session-level analysis for ferret atropine/saline data, v7.
%
% Goal of this version is to test the updated hypothesis set
%
%   H1. OB gamma is NOT uniformly suppressed by atropine: test sub-bands
%       (low gamma 20-40, gamma 40-60, high gamma 60-80) separately.
%   H2. OB delta is NOT necessarily increased: characterize the low-frequency
%       reorganization while controlling for breathing.
%   H3. CBV decreases more after atropine than after saline; test HPC and
%       AEG/ACx separately AND with global-mean regression.
%   H4. HPC and AEG/ACx CBV share a strong global component.
%   H5. OB gamma is anti-correlated with CBV on slow timescales.
%   H6. Atropine reorganizes OB-CBV slow coupling: test a paired Delta-r per
%       session and pre-vs-post lag-correlation curves.
%
% Per-session unit of analysis. Helpers live in AG_helpers/. R2018b.
%
% Compared with v6, v7 adds:
%   * Mean OB power spectra panel pre vs post per drug (group AND per session)
%   * Within-Wake re-analysis (movement-thresholded accelerometer or sleep state)
%   * Bodily-variables figure (heart rate, breath rate, accelero, EMG proxy)
%   * Paired Delta-r per session for OB-CBV coupling, with bootstrap CIs
%   * Pre-half noise control as a session-internal null
%   * Block-permutation p-values for slow correlations
%   * LongSmoothSec robustness sweep as a Supp Fig
%   * Coverage strip below cross-session time courses
%   * Cleaner separation between mean spectra and log2-ratio
%   * Hypothesis-by-figure cross-walk saved alongside outputs
%
% Author: Arsenii G. 
% clear all
% close all

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
SaveFolder = '\\129.199.81.18\data5\Arsenii\OB_fUS_Arousal\Processed_data\Ficello\Figures_AG\AtropineSaline_AG_figures_v7\';
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

% Smoothing windows.
PowerSmoothSec = 0.3;
TraceSmoothSec = 10;
LongSmoothSec = 5*60; % review this. not sure is a good idea. 
LongSmoothSweepSec = [60 180 300 600 1200];      % robustness sweep for OB-CBV
DistributionSmoothBins = 5;
NInterp = 100;
PostTimeGridSec = InjExclusionSec:60:85*60;
LagSec = (-30:2:30)*60;

% OB spectral bands. Theta is now non-overlapping with delta. lowGamma is the
% sub-band that the cortical EEG-dissociation literature shows can rise under
% muscarinic blockade; gamma is canonical 40-60; highGamma is 60-80; gammaPeak
% search uses 25-95 to allow for a peak shift below the canonical 40 Hz.
Bands.delta     = [0.2 3];
Bands.theta     = [3 6];
Bands.beta      = [15 30];
Bands.lowGamma  = [20 40];
Bands.gamma     = [40 60];
Bands.highGamma = [60 80];
Bands.gammaPeakSearch = [25 95];

MiddleFreqGrid = 0:0.5:120;
LowFreqGrid    = 0:0.1:20;

UseFrequencyWeightForSpectrum = 1;       % display only
UseFrequencyWeightForBandMetrics = 0;    % stats: keep on raw power
UseMedianSpectrumForRatio = 1;

% Movement / state thresholding (BM convention for log10 accelero).
MoveLogThresh = 6.7;
AccSmoothSec = 3;

% Breath-rate exclusion notch in low-freq computation.
BreathNotchHalfWidth = 0.4;              % Hz, half-width around fundamental and 2x

% Coupling significance: block-permutation block length.
BlockPermBlockSec = 30;
BlockPermNPerm = 1000;

% Manual exclusion lists (substring match on path or session name).
ExcludeSessionNameContains = {};
LowerDoseSessionNameContains = {};
ExcludeLowerDoseSessions = 0;

MakeFinalFigures        = 1;
MakeSupplementaryFigures = 1;
MakeSingleSessionFigures = 1;
MakeBodilyFigure         = 1;
MakeWakeOnlyFigure       = 1;
MakeSweepFigure          = 1;

%% Session definition (same convention as v6)

SessionDefs = struct('path',{},'animal',{},'restraint',{},'drug_name',{},'drug_id',{},'source',{},'dose_tag',{},'include',{});

ForceFicelloMidpoint = 1;

animal_names = {'Ficello', 'Labneh', 'Shropshire', 'Brynza'};
setup_types  = {'head-fixed'};   % start with head-fixed; freely-moving is enabled by adding 'freely-moving' here
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

SeenSessionPaths = {};
for animal_idx = 1:length(animal_names)
    for setup_idx = 1:length(setup_types)
        for drug_idx = 1:length(DrugQueryNames)
            Dir = sessions{animal_idx}{setup_idx}{drug_idx};
            if isempty(Dir), continue, end
            if isstruct(Dir) && isfield(Dir, 'path')
                paths = Dir.path;
            elseif iscell(Dir)
                paths = Dir;
            elseif ischar(Dir)
                paths = {Dir};
            else
                continue
            end
            if ischar(paths), paths = {paths}; end
            paths = paths(:);
            for sess_idx = 1:length(paths)
                if isempty(paths{sess_idx}), continue, end
                sessionPath = paths{sess_idx};
                already = 0;
                for s = 1:length(SeenSessionPaths)
                    if strcmp(sessionPath, SeenSessionPaths{s}), already = 1; end
                end
                if already, continue, end
                SeenSessionPaths{end+1} = sessionPath;
                SessionDefs(end+1) = make_session_entry_AG(sessionPath, animal_names{animal_idx}, setup_types{setup_idx}, DrugNames{drug_idx}, drug_idx, 'PathForExperimentsOB', 'standard_or_unknown', 1);
            end
        end
    end
end

fprintf('Session definition: %d unique sessions loaded from PathForExperimentsOB.\n', length(SessionDefs));

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

%% Load sessions (deferred — memory-optimized)
%
% v7.1: do NOT load all sessions into AllSessions before analysis. With 25
% sessions, each carrying a multi-GB fUS cat_tsd and full spectrograms, that
% blows out RAM. Instead we keep only the small SessionDefs index here; the
% per-session loop below loads each session, analyzes it, then clears it
% before moving on. This keeps peak memory at roughly one session worth.

nSess = length(SessionDefs);
% Keep AllSessions defined but empty so existing helpers that take it as an
% argument (e.g. plot_group_log2ratio_clean) still receive a valid value.
% They fall back to MiddleFreqGrid/LowFreqGrid via evalin in get_frequency_vector.
AllSessions = struct([]);

%% Compute traces, metrics and per-session objects

if nSess > 0
    % Build a placeholder for initialize_metrics from the first SessionDef.
    ph = struct('name','', 'animal',SessionDefs(1).animal, 'restraint',SessionDefs(1).restraint, ...
                'drug_id',SessionDefs(1).drug_id, 'drug_name',SessionDefs(1).drug_name, ...
                'drug_sess',1, 'source',SessionDefs(1).source, 'dose_tag',SessionDefs(1).dose_tag);
    Metrics = repmat(initialize_metrics(ph), 1, nSess);
else
    Metrics = struct();
end

% Extra metric fields specific to v7: pre-half noise, sub-band raw peaks,
% within-Wake versions, paired Delta-r, breath rate summaries, block-perm p.
extraFields = { ...
    'pre_half_gamma_log','pre_half_delta_log','pre_half_lowgamma_log','pre_half_highgamma_log', ...
    'gamma_logratio_wake','delta_logratio_wake','lowgamma_logratio_wake','gamma_spec_logratio_wake','highgamma_logratio_wake', ...
    'gamma_peak_before_raw_hz','gamma_peak_after_raw_hz','gamma_peak_shift_raw_hz', ...
    'lowgamma_peak_before_raw_hz','lowgamma_peak_after_raw_hz', ...
    'highgamma_peak_before_raw_hz','highgamma_peak_after_raw_hz', ...
    'breath_rate_before_hz','breath_rate_after_hz', ...
    'low_freq_no_breath_logratio','delta_no_breath_logratio', ...
    'gamma_hpc_dr','gamma_aeg_dr','delta_hpc_dr', ...
    'gamma_hpc_p_block_after','gamma_aeg_p_block_after', ...
    'hpc_global_resid_dcbv_after_percent','aeg_global_resid_dcbv_after_percent', ...
    'beta_spec_logratio','pre_min','post_min','dt_ref_sec','frac_wake_before','frac_wake_after', ...
    'wake_source', ...
    'hpc_gamma_logratio','pfc_gamma_logratio','acx_gamma_logratio','hpc_theta_logratio', ...
    'hpc_gamma_logratio_wake','pfc_gamma_logratio_wake','acx_gamma_logratio_wake','hpc_theta_logratio_wake', ...
    'pre_half_hpc_gamma_log','pre_half_pfc_gamma_log','pre_half_acx_gamma_log','pre_half_hpc_theta_log', ...
    'aucx_spec_delta_logratio','aucx_spec_theta_logratio','aucx_spec_beta_logratio','aucx_spec_lowgamma_logratio','aucx_spec_gamma_logratio','aucx_spec_highgamma_logratio', ...
    'hpc_spec_delta_logratio','hpc_spec_theta_logratio','hpc_spec_beta_logratio','hpc_spec_lowgamma_logratio','hpc_spec_gamma_logratio','hpc_spec_highgamma_logratio', ...
    'pfcx_spec_delta_logratio','pfcx_spec_theta_logratio','pfcx_spec_beta_logratio','pfcx_spec_lowgamma_logratio','pfcx_spec_gamma_logratio','pfcx_spec_highgamma_logratio', ...
    'hrv_RMSSD_before_ms','hrv_RMSSD_after_ms','hrv_SDNN_before_ms','hrv_SDNN_after_ms', ...
    'hrv_meanRR_before_ms','hrv_meanRR_after_ms','hrv_pNN50_before_pct','hrv_pNN50_after_pct'};
stringFields = {'wake_source'};
for s = 1:nSess
    for f_ = 1:length(extraFields)
        if any(strcmp(extraFields{f_}, stringFields))
            if ~isfield(Metrics(s), extraFields{f_})
                Metrics(s).(extraFields{f_}) = '';
            end
        else
            if ~isfield(Metrics(s), extraFields{f_})
                Metrics(s).(extraFields{f_}) = NaN;
            end
        end
    end
end

Ana = struct();

Group = struct();
for drug = 1:2
    Group.gamma_after_norm{drug}  = [];
    Group.delta_after_norm{drug}  = [];
    Group.hpc_after_norm{drug}    = [];
    Group.aeg_after_norm{drug}    = [];
    Group.gamma_before_norm{drug} = [];
    Group.delta_before_norm{drug} = [];
    Group.hpc_before_norm{drug}   = [];
    Group.aeg_before_norm{drug}   = [];
    Group.middle_log2ratio{drug}  = [];
    Group.low_log2ratio{drug}     = [];
    Group.middle_before_fweighted{drug} = [];
    Group.middle_after_fweighted{drug}  = [];
    Group.low_before_fweighted{drug}    = [];
    Group.low_after_fweighted{drug}     = [];
    Group.lag_gamma_hpc_before{drug} = [];
    Group.lag_gamma_hpc_after{drug}  = [];
    Group.lag_gamma_aeg_before{drug} = [];
    Group.lag_gamma_aeg_after{drug}  = [];
    Group.state_occ_before{drug} = [];
    Group.state_occ_after{drug}  = [];
    Group.gamma_after_real{drug}  = [];
    Group.delta_after_real{drug}  = [];
    Group.hpc_dcbv_after_real{drug} = [];
    Group.aeg_dcbv_after_real{drug} = [];
    Group.heart_after_real{drug}  = [];
    Group.breath_after_real{drug} = [];
    Group.acc_after_real{drug}    = [];
    % LongSmoothSec robustness sweep: r_after for gamma-HPC at each smoothing.
    Group.sweep_r_after_gamma_hpc{drug} = nan(0, length(LongSmoothSweepSec));
end

for sess = 1:nSess
    % Memory-optimized loading: load THIS session's data, process, then
    % clear at the end of the iteration so peak memory ~ one session.
    S = load_session_data_AG(SessionDefs(sess), wantedSlice, ForceFicelloMidpoint);
    S.drug_sess = sess;
    drug = S.drug_id;
    % Field-by-field copy to keep the extraFields already present in
    % Metrics(sess) (preallocation added them to all elements). Replacing
    % Metrics(sess) wholesale with the bare initialize_metrics(S) struct
    % triggers "Subscripted assignment between dissimilar structures".
    M0 = initialize_metrics(S);
    fns0 = fieldnames(M0);
    for k0 = 1:length(fns0)
        Metrics(sess).(fns0{k0}) = M0.(fns0{k0});
    end
    clear M0 fns0 k0
    Metrics(sess).animal = S.animal;
    Metrics(sess).restraint = S.restraint;
    Metrics(sess).source = S.source;
    Metrics(sess).dose_tag = S.dose_tag;
    for f_ = 1:length(extraFields)
        if any(strcmp(extraFields{f_}, stringFields))
            Metrics(sess).(extraFields{f_}) = '';
        else
            Metrics(sess).(extraFields{f_}) = NaN;
        end
    end

    if ~isfield(S, 'OBGammaPower') || ~isfield(S, 'OBDeltaPower')
        warning('Skipping session %s: OB gamma/delta missing.', S.name)
        continue
    end

    % --- OB band-power traces ---
    Gamma = S.OBGammaPower;  GammaData = Data(Gamma); TGamma = Range(Gamma,'s'); TGamma = TGamma(:);
    GammaData = smooth_by_time(GammaData(:), TGamma, PowerSmoothSec);
    Delta = S.OBDeltaPower;  DeltaData = Data(Delta); TDelta = Range(Delta,'s'); TDelta = TDelta(:);
    DeltaData = smooth_by_time(DeltaData(:), TDelta, PowerSmoothSec);

    % --- Optional multi-region BrainPower traces ---
    % For each available region/band we just compute a log-ratio after/before
    % later in the session loop. Values are NaN when the field is absent.
    OtherPow = struct();
    OtherPow.HPC_gamma = []; OtherPow.PFC_gamma = []; OtherPow.ACx_gamma = [];
    OtherPow.HPC_theta = [];
    if isfield(S, 'HPCGammaPower'), OtherPow.HPC_gamma = S.HPCGammaPower; end
    if isfield(S, 'PFCGammaPower'), OtherPow.PFC_gamma = S.PFCGammaPower; end
    if isfield(S, 'ACxGammaPower'), OtherPow.ACx_gamma = S.ACxGammaPower; end
    if isfield(S, 'HPCThetaPower'), OtherPow.HPC_theta = S.HPCThetaPower; end

    % --- fUS ROI traces (only for sessions with fUS) ---
    hasFUS = 0; TFUS = []; trace_hipp = []; trace_AEG = [];
    hpc_norm = []; aeg_norm = []; hpc_dcbv_percent = []; aeg_dcbv_percent = [];
    if isfield(S, 'fUS') && isfield(S.fUS, 'cat_tsd') && isfield(S.fUS, 'masks') && ...
            isfield(S.fUS.masks, 'Hippocampus') && isfield(S.fUS.masks, 'AEG')
        hasFUS = 1;
        cat_tsd = S.fUS.cat_tsd;
        masks = S.fUS.masks;
        % Cast to single precision while reshaping to halve fUS memory.
        % cat_tsd.data is a tsd of (Nt, Nx*Ny) doubles; reshape via permute
        % to avoid a transpose copy, then drop the original Data() copy.
        fUSData = single(Data(cat_tsd.data));
        Nt = size(fUSData, 1);
        fUSDataReshaped = permute(reshape(fUSData, Nt, cat_tsd.Nx, cat_tsd.Ny), [2 3 1]);
        clear fUSData
        TFUS = Range(cat_tsd.data,'s'); TFUS = TFUS(:);
        mask_hipp = masks.Hippocampus; mask_AEG = masks.AEG;
        trace_hipp = nan(Nt,1); trace_AEG = nan(Nt,1);
        for t = 1:Nt
            frame = fUSDataReshaped(:,:,t);
            trace_hipp(t) = nanmean(frame(mask_hipp));
            trace_AEG(t)  = nanmean(frame(mask_AEG));
        end
        % Mean fUS image (for the per-session figure) — compute BEFORE freeing
        % the volume. nanmean over time -> Nx-by-Ny image.
        meanImg = double(nanmean(fUSDataReshaped, 3));
        clear fUSDataReshaped
        % Free the cat_tsd reference too; we have the per-frame ROI traces now.
        S.fUS.cat_tsd = []; clear cat_tsd
        trace_hipp = double(smooth_by_time(trace_hipp, TFUS, TraceSmoothSec));
        trace_AEG  = double(smooth_by_time(trace_AEG,  TFUS, TraceSmoothSec));
    else
        meanImg = [];
    end

    % --- Reference time base ---
    if hasFUS, Tref = TFUS; else, Tref = TGamma; end

    if isfinite(S.inj_time_sec)
        t_inj = S.inj_time_sec;
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
    if isnan(gamma_baseline) || gamma_baseline <= 0, gamma_baseline = 1; end
    if isnan(delta_baseline) || delta_baseline <= 0, delta_baseline = 1; end
    gamma_norm = Gamma_trace ./ gamma_baseline;
    delta_norm = Delta_trace ./ delta_baseline;

    % --- fUS dCBV ---
    if hasFUS
        hpc_baseline = nanmedian(trace_hipp(idx_before));
        aeg_baseline = nanmedian(trace_AEG(idx_before));
        hpc_dcbv = (trace_hipp - hpc_baseline) ./ hpc_baseline;
        aeg_dcbv = (trace_AEG  - aeg_baseline) ./ aeg_baseline;
        hpc_norm = 1 + hpc_dcbv; aeg_norm = 1 + aeg_dcbv;
        hpc_dcbv_percent = 100*hpc_dcbv; aeg_dcbv_percent = 100*aeg_dcbv;

        % global-mean regressed CBV residuals
        hpc_resid = regress_global_AG(hpc_dcbv_percent, hpc_dcbv_percent, aeg_dcbv_percent);
        aeg_resid = regress_global_AG(aeg_dcbv_percent, hpc_dcbv_percent, aeg_dcbv_percent);
        Metrics(sess).hpc_global_resid_dcbv_after_percent = nanmedian(hpc_resid(idx_after));
        Metrics(sess).aeg_global_resid_dcbv_after_percent = nanmedian(aeg_resid(idx_after));
    else
        hpc_norm = nan(size(Tref)); aeg_norm = nan(size(Tref));
        hpc_dcbv_percent = nan(size(Tref)); aeg_dcbv_percent = nan(size(Tref));
        trace_hipp = nan(size(Tref));  trace_AEG  = nan(size(Tref));
    end

    log_gamma_long = smooth_by_time(safe_log(Gamma_metric), Tref, LongSmoothSec);
    log_delta_long = smooth_by_time(safe_log(Delta_metric), Tref, LongSmoothSec);
    log_hpc_long   = smooth_by_time(safe_log(trace_hipp),   Tref, LongSmoothSec);
    log_aeg_long   = smooth_by_time(safe_log(trace_AEG),    Tref, LongSmoothSec);

    log_gamma = safe_log(Gamma_metric); log_delta = safe_log(Delta_metric);
    gamma_thr = nanmedian(log_gamma(idx_before));
    delta_thr = nanmedian(log_delta(idx_before));
    OBState = nan(size(Tref));
    OBState(log_gamma >= gamma_thr & log_delta <  delta_thr) = 1;
    OBState(log_gamma <  gamma_thr & log_delta >= delta_thr) = 2;
    OBState(log_gamma >= gamma_thr & log_delta >= delta_thr) = 3;
    OBState(log_gamma <  gamma_thr & log_delta <  delta_thr) = 4;

    % --- Wake idx on Tref ---
    % Head-fixed: EMG envelope is the only useful Wake proxy; accelero is
    %             pinned and uninformative.
    % Freely-moving: prefer EMG when available, fall back to accelero.
    % All thresholds are derived from PRE-injection samples only, by design,
    % to avoid being contaminated by atropine-driven state changes.
    idx_moving = false(size(Tref));
    smooth_acc_log = nan(size(Tref));
    log_emg_env  = nan(size(Tref));
    wake_source  = 'none';
    if isfield(S, 'EMGEnvelope') && ~isempty(S.EMGEnvelope)
        t_emg = Range(S.EMGEnvelope, 's'); t_emg = t_emg(:);
        d_emg = Data(S.EMGEnvelope);       d_emg = d_emg(:);
        good = isfinite(d_emg) & d_emg > 0;
        if sum(good) > 50
            le = nan(size(d_emg)); le(good) = log10(d_emg(good));
            log_emg_env = interp1(t_emg, le, Tref(:), 'linear', NaN);
            emg_thr = derive_state_threshold_pre_AG(log_emg_env, idx_before, 'percentile', 60);
            idx_moving = log_emg_env >= emg_thr;
            idx_moving(~isfinite(log_emg_env)) = false;
            wake_source = 'EMG_pre_threshold';
        end
    end
    if strcmp(wake_source, 'none') && strcmp(S.restraint, 'freely-moving') && isfield(S, 'MovAcctsd')
        [idx_moving, smooth_acc_log] = compute_moving_idx_AG(S.MovAcctsd, Tref, AccSmoothSec, MoveLogThresh);
        wake_source = 'accelero_BM_threshold';
    elseif isfield(S, 'MovAcctsd')
        % keep accelero log for the QC plot, but do not use for state
        [~, smooth_acc_log] = compute_moving_idx_AG(S.MovAcctsd, Tref, AccSmoothSec, MoveLogThresh);
    end
    Metrics(sess).wake_source       = wake_source;
    Metrics(sess).frac_wake_before  = sum(idx_moving & idx_before) / max(1, sum(idx_before));
    Metrics(sess).frac_wake_after   = sum(idx_moving & idx_after)  / max(1, sum(idx_after));

    % --- Heart rate and breath rate on Tref ---
    heart_rate = nan(size(Tref));
    if isfield(S, 'HeartRate')
        t_hr = Range(S.HeartRate,'s'); t_hr = t_hr(:);
        d_hr = Data(S.HeartRate); d_hr = d_hr(:);
        good = isfinite(d_hr) & d_hr > 0;
        if sum(good) > 5
            heart_rate = interp1(t_hr(good), d_hr(good), Tref(:), 'linear', NaN);
        end
    end
    breath_rate = nan(size(Tref));
    if isfield(S, 'RespRate_tsd') && ~isempty(S.RespRate_tsd)
        breath_rate = compute_breath_rate_AG(S.RespRate_tsd, Tref, 5);
    end

    Metrics(sess).breath_rate_before_hz = nanmedian(breath_rate(idx_before));
    Metrics(sess).breath_rate_after_hz  = nanmedian(breath_rate(idx_after));
    breath_med_session = nanmedian([Metrics(sess).breath_rate_before_hz Metrics(sess).breath_rate_after_hz]);

    % --- Group time courses on real-time grid ---
    row = size(Group.gamma_after_norm{drug},1) + 1;
    Group.middle_log2ratio{drug}(row,1:length(MiddleFreqGrid)) = NaN;
    Group.middle_before_fweighted{drug}(row,1:length(MiddleFreqGrid)) = NaN;
    Group.middle_after_fweighted{drug}(row,1:length(MiddleFreqGrid)) = NaN;
    Group.low_log2ratio{drug}(row,1:length(LowFreqGrid)) = NaN;
    Group.low_before_fweighted{drug}(row,1:length(LowFreqGrid)) = NaN;
    Group.low_after_fweighted{drug}(row,1:length(LowFreqGrid)) = NaN;
    Group.state_occ_before{drug}(row,:) = state_occupancy(OBState, idx_before, 4);
    Group.state_occ_after{drug}(row,:)  = state_occupancy(OBState, idx_after, 4);
    Group.gamma_before_norm{drug}(row,:) = interp_epoch_to_unit_time(gamma_norm, idx_before, NInterp);
    Group.gamma_after_norm{drug}(row,:)  = interp_epoch_to_unit_time(gamma_norm, idx_after, NInterp);
    Group.delta_before_norm{drug}(row,:) = interp_epoch_to_unit_time(delta_norm, idx_before, NInterp);
    Group.delta_after_norm{drug}(row,:)  = interp_epoch_to_unit_time(delta_norm, idx_after, NInterp);
    Group.hpc_before_norm{drug}(row,:)   = interp_epoch_to_unit_time(hpc_norm,   idx_before, NInterp);
    Group.hpc_after_norm{drug}(row,:)    = interp_epoch_to_unit_time(hpc_norm,   idx_after,  NInterp);
    Group.aeg_before_norm{drug}(row,:)   = interp_epoch_to_unit_time(aeg_norm,   idx_before, NInterp);
    Group.aeg_after_norm{drug}(row,:)    = interp_epoch_to_unit_time(aeg_norm,   idx_after,  NInterp);
    Group.gamma_after_real{drug}(row,:)  = interp_relative_time(Tref, gamma_norm,   t_inj, PostTimeGridSec);
    Group.delta_after_real{drug}(row,:)  = interp_relative_time(Tref, delta_norm,   t_inj, PostTimeGridSec);
    Group.hpc_dcbv_after_real{drug}(row,:) = interp_relative_time(Tref, hpc_dcbv_percent, t_inj, PostTimeGridSec);
    Group.aeg_dcbv_after_real{drug}(row,:) = interp_relative_time(Tref, aeg_dcbv_percent, t_inj, PostTimeGridSec);
    Group.heart_after_real{drug}(row,:)  = interp_relative_time(Tref, heart_rate,    t_inj, PostTimeGridSec);
    Group.breath_after_real{drug}(row,:) = interp_relative_time(Tref, breath_rate,   t_inj, PostTimeGridSec);
    Group.acc_after_real{drug}(row,:)    = interp_relative_time(Tref, smooth_acc_log,t_inj, PostTimeGridSec);

    % --- Scalar OB band metrics ---
    Metrics(sess).inj_time_min = t_inj/60;
    Metrics(sess).n_ref_before = sum(idx_before);
    Metrics(sess).n_ref_after  = sum(idx_after);
    durs = split_pre_post_durations_AG(Tref, idx_before, idx_after);
    Metrics(sess).pre_min  = durs.pre_min;
    Metrics(sess).post_min = durs.post_min;
    Metrics(sess).dt_ref_sec = nanmedian(diff(Tref));
    Metrics(sess).has_fus = hasFUS;

    Metrics(sess).gamma_logratio = log_ratio_median(Gamma_metric, idx_before, idx_after);
    Metrics(sess).delta_logratio = log_ratio_median(Delta_metric, idx_before, idx_after);

    % Pre-half noise control
    Metrics(sess).pre_half_gamma_log = pre_half_noise_AG(Gamma_metric, idx_before);
    Metrics(sess).pre_half_delta_log = pre_half_noise_AG(Delta_metric, idx_before);

    % Within-Wake variants
    Metrics(sess).gamma_logratio_wake = log_ratio_median_state_AG(Gamma_metric, idx_before, idx_after, idx_moving);
    Metrics(sess).delta_logratio_wake = log_ratio_median_state_AG(Delta_metric, idx_before, idx_after, idx_moving);

    % --- Multi-region BrainPower log-ratios (HPC_gamma, PFC_gamma, ACx_gamma, HPC_theta) ---
    otherFlds = fieldnames(OtherPow);
    for of = 1:length(otherFlds)
        nm = otherFlds{of};
        outFld   = [lower(nm) '_logratio'];        % e.g. 'hpc_gamma_logratio'
        outWake  = [lower(nm) '_logratio_wake'];
        outHalf  = ['pre_half_' lower(nm) '_log'];
        if isempty(OtherPow.(nm))
            Metrics(sess).(outFld)  = NaN;
            Metrics(sess).(outWake) = NaN;
            Metrics(sess).(outHalf) = NaN;
            continue
        end
        T_ = Range(OtherPow.(nm), 's'); T_ = T_(:);
        D_ = Data(OtherPow.(nm));        D_ = smooth_by_time(D_(:), T_, PowerSmoothSec);
        D_ref = interp1(T_, D_, Tref, 'linear', NaN);
        Metrics(sess).(outFld)  = log_ratio_median(D_ref, idx_before, idx_after);
        Metrics(sess).(outWake) = log_ratio_median_state_AG(D_ref, idx_before, idx_after, idx_moving);
        Metrics(sess).(outHalf) = pre_half_noise_AG(D_ref, idx_before);
    end

    % --- HRV from EKG.HBTimes ---
    pre_window  = [Tref(find(idx_before,1,'first')), Tref(find(idx_before,1,'last'))];
    post_window = [Tref(find(idx_after,1,'first')),  Tref(find(idx_after,1,'last'))];
    if isfield(S, 'EKG')
        hrv_b = compute_hrv_metrics_AG(S.EKG, pre_window);
        hrv_a = compute_hrv_metrics_AG(S.EKG, post_window);
        Metrics(sess).hrv_RMSSD_before_ms = hrv_b.RMSSD_ms;
        Metrics(sess).hrv_RMSSD_after_ms  = hrv_a.RMSSD_ms;
        Metrics(sess).hrv_SDNN_before_ms  = hrv_b.SDNN_ms;
        Metrics(sess).hrv_SDNN_after_ms   = hrv_a.SDNN_ms;
        Metrics(sess).hrv_meanRR_before_ms = hrv_b.mean_RR_ms;
        Metrics(sess).hrv_meanRR_after_ms  = hrv_a.mean_RR_ms;
        Metrics(sess).hrv_pNN50_before_pct = hrv_b.pNN50_pct;
        Metrics(sess).hrv_pNN50_after_pct  = hrv_a.pNN50_pct;
    end

    % --- fUS scalar metrics ---
    if hasFUS
        Metrics(sess).hpc_cbv_logratio = log_ratio_median(trace_hipp, idx_before, idx_after);
        Metrics(sess).aeg_cbv_logratio = log_ratio_median(trace_AEG,  idx_before, idx_after);
        Metrics(sess).hpc_dcbv_after_percent = nanmedian(hpc_dcbv_percent(idx_after));
        Metrics(sess).aeg_dcbv_after_percent = nanmedian(aeg_dcbv_percent(idx_after));
        Metrics(sess).hpc_aeg_r_before = corr_nan(safe_log(trace_hipp(idx_before)), safe_log(trace_AEG(idx_before)));
        Metrics(sess).hpc_aeg_r_after  = corr_nan(safe_log(trace_hipp(idx_after)),  safe_log(trace_AEG(idx_after)));
        Metrics(sess).gamma_hpc_r_before = corr_nan(log_gamma_long(idx_before), log_hpc_long(idx_before));
        Metrics(sess).gamma_hpc_r_after  = corr_nan(log_gamma_long(idx_after),  log_hpc_long(idx_after));
        Metrics(sess).gamma_aeg_r_before = corr_nan(log_gamma_long(idx_before), log_aeg_long(idx_before));
        Metrics(sess).gamma_aeg_r_after  = corr_nan(log_gamma_long(idx_after),  log_aeg_long(idx_after));
        Metrics(sess).delta_hpc_r_before = corr_nan(log_delta_long(idx_before), log_hpc_long(idx_before));
        Metrics(sess).delta_hpc_r_after  = corr_nan(log_delta_long(idx_after),  log_hpc_long(idx_after));
        Metrics(sess).gamma_hpc_r_detr_before = corr_nan(detrend_nan(log_gamma_long(idx_before)), detrend_nan(log_hpc_long(idx_before)));
        Metrics(sess).gamma_hpc_r_detr_after  = corr_nan(detrend_nan(log_gamma_long(idx_after)),  detrend_nan(log_hpc_long(idx_after)));
        Metrics(sess).gamma_aeg_r_detr_before = corr_nan(detrend_nan(log_gamma_long(idx_before)), detrend_nan(log_aeg_long(idx_before)));
        Metrics(sess).gamma_aeg_r_detr_after  = corr_nan(detrend_nan(log_gamma_long(idx_after)),  detrend_nan(log_aeg_long(idx_after)));

        % Paired Delta-r per session
        Metrics(sess).gamma_hpc_dr = Metrics(sess).gamma_hpc_r_after - Metrics(sess).gamma_hpc_r_before;
        Metrics(sess).gamma_aeg_dr = Metrics(sess).gamma_aeg_r_after - Metrics(sess).gamma_aeg_r_before;
        Metrics(sess).delta_hpc_dr = Metrics(sess).delta_hpc_r_after - Metrics(sess).delta_hpc_r_before;

        % Block-permutation p-values for after-period correlation
        dt_ref = nanmedian(diff(Tref));
        x_after = log_gamma_long(idx_after); y_h = log_hpc_long(idx_after); y_a = log_aeg_long(idx_after);
        Metrics(sess).gamma_hpc_p_block_after = block_perm_corr_p_AG(x_after, y_h, BlockPermBlockSec, dt_ref, BlockPermNPerm);
        Metrics(sess).gamma_aeg_p_block_after = block_perm_corr_p_AG(x_after, y_a, BlockPermBlockSec, dt_ref, BlockPermNPerm);

        % Lag correlation curves
        Group.lag_gamma_hpc_before{drug}(row,:) = lag_corr_curve(Tref, log_gamma_long, log_hpc_long, idx_before, LagSec);
        Group.lag_gamma_hpc_after{drug}(row,:)  = lag_corr_curve(Tref, log_gamma_long, log_hpc_long, idx_after,  LagSec);
        Group.lag_gamma_aeg_before{drug}(row,:) = lag_corr_curve(Tref, log_gamma_long, log_aeg_long, idx_before, LagSec);
        Group.lag_gamma_aeg_after{drug}(row,:)  = lag_corr_curve(Tref, log_gamma_long, log_aeg_long, idx_after,  LagSec);

        % LongSmoothSec robustness sweep (after, gamma-HPC)
        sweep_r = nan(1,length(LongSmoothSweepSec));
        for ks = 1:length(LongSmoothSweepSec)
            ws = LongSmoothSweepSec(ks);
            xg = smooth_by_time(safe_log(Gamma_metric), Tref, ws);
            xh = smooth_by_time(safe_log(trace_hipp),   Tref, ws);
            sweep_r(ks) = corr_nan(xg(idx_after), xh(idx_after));
        end
        Group.sweep_r_after_gamma_hpc{drug}(row,:) = sweep_r;
    else
        Group.lag_gamma_hpc_before{drug}(row,:) = nan(1,length(LagSec));
        Group.lag_gamma_hpc_after{drug}(row,:)  = nan(1,length(LagSec));
        Group.lag_gamma_aeg_before{drug}(row,:) = nan(1,length(LagSec));
        Group.lag_gamma_aeg_after{drug}(row,:)  = nan(1,length(LagSec));
        Group.sweep_r_after_gamma_hpc{drug}(row,:) = nan(1,length(LongSmoothSweepSec));
    end

    % --- Spectrograms: mean spectra and band metrics ---
    if isfield(S, 'SpectroMiddle')
        sptsdB = S.SpectroMiddle.sptsdB;
        spec   = Data(sptsdB);
        t_spec = Range(sptsdB,'s'); t_spec = t_spec(:);
        f      = S.SpectroMiddle.fB(:)';
        [idx_sb, idx_sa] = injection_epoch_indices(t_spec, t_inj, InjExclusionSec);
        Spec_before_mean = epoch_spectrum(spec, idx_sb, 'mean');
        Spec_after_mean  = epoch_spectrum(spec, idx_sa, 'mean');
        Spec_before_med  = epoch_spectrum(spec, idx_sb, 'median');
        Spec_after_med   = epoch_spectrum(spec, idx_sa, 'median');

        % Plotting variant (frequency-weighted)
        if UseFrequencyWeightForSpectrum
            Spec_before_plot = f .* Spec_before_mean;
            Spec_after_plot  = f .* Spec_after_mean;
        else
            Spec_before_plot = Spec_before_mean;
            Spec_after_plot  = Spec_after_mean;
        end
        Spec_before_plot_grid = interp1(f, Spec_before_plot, MiddleFreqGrid, 'linear', NaN);
        Spec_after_plot_grid  = interp1(f, Spec_after_plot,  MiddleFreqGrid, 'linear', NaN);
        Group.middle_before_fweighted{drug}(row,:) = Spec_before_plot_grid;
        Group.middle_after_fweighted{drug}(row,:)  = Spec_after_plot_grid;

        % Ratio: prefer median of unweighted spectra
        if UseMedianSpectrumForRatio
            Sb = Spec_before_med; Sa = Spec_after_med;
        else
            Sb = Spec_before_mean; Sa = Spec_after_mean;
        end
        MiddleRatioNative = log2((Sa + eps) ./ (Sb + eps));
        Group.middle_log2ratio{drug}(row,:) = interp1(f, MiddleRatioNative, MiddleFreqGrid, 'linear', NaN);

        % Sub-band metrics on raw power
        lowGammaSpec  = spectrum_band_timeseries(spec, f, Bands.lowGamma,  UseFrequencyWeightForBandMetrics);
        gammaSpec     = spectrum_band_timeseries(spec, f, Bands.gamma,     UseFrequencyWeightForBandMetrics);
        highGammaSpec = spectrum_band_timeseries(spec, f, Bands.highGamma, UseFrequencyWeightForBandMetrics);
        betaSpec      = spectrum_band_timeseries(spec, f, Bands.beta,      UseFrequencyWeightForBandMetrics);
        Metrics(sess).lowgamma_spec_logratio  = log_ratio_median(lowGammaSpec,  idx_sb, idx_sa);
        Metrics(sess).gamma_spec_logratio     = log_ratio_median(gammaSpec,     idx_sb, idx_sa);
        Metrics(sess).highgamma_spec_logratio = log_ratio_median(highGammaSpec, idx_sb, idx_sa);
        Metrics(sess).beta_spec_logratio = log_ratio_median(betaSpec, idx_sb, idx_sa);
        Metrics(sess).pre_half_lowgamma_log  = pre_half_noise_AG(lowGammaSpec,  idx_sb);
        Metrics(sess).pre_half_highgamma_log = pre_half_noise_AG(highGammaSpec, idx_sb);

        % Within-Wake variants for sub-bands.
        if any(idx_moving)
            idx_moving_spec = interp1(Tref, double(idx_moving), t_spec, 'nearest', 0) > 0.5;
        else
            idx_moving_spec = false(size(t_spec));
        end
        Metrics(sess).lowgamma_logratio_wake  = log_ratio_median_state_AG(lowGammaSpec,  idx_sb, idx_sa, idx_moving_spec);
        Metrics(sess).gamma_spec_logratio_wake= log_ratio_median_state_AG(gammaSpec,     idx_sb, idx_sa, idx_moving_spec);
        Metrics(sess).highgamma_logratio_wake = log_ratio_median_state_AG(highGammaSpec, idx_sb, idx_sa, idx_moving_spec);

        % Peaks: report both raw (unweighted) and f-weighted, and within sub-bands.
        Metrics(sess).gamma_peak_before_hz = spectrum_peak_frequency(Spec_before_med, f, Bands.gammaPeakSearch, UseFrequencyWeightForSpectrum);
        Metrics(sess).gamma_peak_after_hz  = spectrum_peak_frequency(Spec_after_med,  f, Bands.gammaPeakSearch, UseFrequencyWeightForSpectrum);
        Metrics(sess).gamma_peak_shift_hz  = Metrics(sess).gamma_peak_after_hz - Metrics(sess).gamma_peak_before_hz;

        [pkB_raw, ~] = subband_peak_AG(Spec_before_med, f, Bands.gammaPeakSearch);
        [pkA_raw, ~] = subband_peak_AG(Spec_after_med,  f, Bands.gammaPeakSearch);
        Metrics(sess).gamma_peak_before_raw_hz = pkB_raw;
        Metrics(sess).gamma_peak_after_raw_hz  = pkA_raw;
        Metrics(sess).gamma_peak_shift_raw_hz  = pkA_raw - pkB_raw;

        [pkB_lo, ~] = subband_peak_AG(Spec_before_med, f, Bands.lowGamma);
        [pkA_lo, ~] = subband_peak_AG(Spec_after_med,  f, Bands.lowGamma);
        Metrics(sess).lowgamma_peak_before_raw_hz = pkB_lo;
        Metrics(sess).lowgamma_peak_after_raw_hz  = pkA_lo;

        [pkB_hi, ~] = subband_peak_AG(Spec_before_med, f, Bands.highGamma);
        [pkA_hi, ~] = subband_peak_AG(Spec_after_med,  f, Bands.highGamma);
        Metrics(sess).highgamma_peak_before_raw_hz = pkB_hi;
        Metrics(sess).highgamma_peak_after_raw_hz  = pkA_hi;

        Ana(sess).middle_f = MiddleFreqGrid;
        Ana(sess).middle_before_plot = Spec_before_plot_grid;
        Ana(sess).middle_after_plot  = Spec_after_plot_grid;
        Ana(sess).middle_log2ratio   = Group.middle_log2ratio{drug}(row,:);
    end

    if isfield(S, 'SpectroLow')
        sptsdB = S.SpectroLow.sptsdB;
        spec   = Data(sptsdB);
        t_spec = Range(sptsdB,'s'); t_spec = t_spec(:);
        f      = S.SpectroLow.fB(:)';
        [idx_sb, idx_sa] = injection_epoch_indices(t_spec, t_inj, InjExclusionSec);
        Spec_before_mean = epoch_spectrum(spec, idx_sb, 'mean');
        Spec_after_mean  = epoch_spectrum(spec, idx_sa, 'mean');
        Spec_before_med  = epoch_spectrum(spec, idx_sb, 'median');
        Spec_after_med   = epoch_spectrum(spec, idx_sa, 'median');

        if UseFrequencyWeightForSpectrum
            Spec_before_plot = f .* Spec_before_mean;
            Spec_after_plot  = f .* Spec_after_mean;
        else
            Spec_before_plot = Spec_before_mean;
            Spec_after_plot  = Spec_after_mean;
        end
        Spec_before_plot_grid = interp1(f, Spec_before_plot, LowFreqGrid, 'linear', NaN);
        Spec_after_plot_grid  = interp1(f, Spec_after_plot,  LowFreqGrid, 'linear', NaN);
        Group.low_before_fweighted{drug}(row,:) = Spec_before_plot_grid;
        Group.low_after_fweighted{drug}(row,:)  = Spec_after_plot_grid;

        if UseMedianSpectrumForRatio
            Sb = Spec_before_med; Sa = Spec_after_med;
        else
            Sb = Spec_before_mean; Sa = Spec_after_mean;
        end
        LowRatioNative = log2((Sa + eps) ./ (Sb + eps));
        Group.low_log2ratio{drug}(row,:) = interp1(f, LowRatioNative, LowFreqGrid, 'linear', NaN);

        deltaSpec = spectrum_band_timeseries(spec, f, Bands.delta, UseFrequencyWeightForBandMetrics);
        thetaSpec = spectrum_band_timeseries(spec, f, Bands.theta, UseFrequencyWeightForBandMetrics);
        Metrics(sess).delta_spec_logratio = log_ratio_median(deltaSpec, idx_sb, idx_sa);
        Metrics(sess).theta_spec_logratio = log_ratio_median(thetaSpec, idx_sb, idx_sa);

        % Low-frequency power excluding breath fundamental and harmonic (uses the
        % session-median breath rate; per-bin breath-rate notching would be
        % overkill given the notch width).
        deltaSpec_noBreath = spectrum_band_outside_breath_AG(spec, f, Bands.delta, breath_med_session, BreathNotchHalfWidth);
        lowfSpec_noBreath  = spectrum_band_outside_breath_AG(spec, f, [Bands.delta(1) Bands.theta(2)], breath_med_session, BreathNotchHalfWidth);
        Metrics(sess).delta_no_breath_logratio    = log_ratio_median(deltaSpec_noBreath, idx_sb, idx_sa);
        Metrics(sess).low_freq_no_breath_logratio = log_ratio_median(lowfSpec_noBreath,  idx_sb, idx_sa);

        Ana(sess).low_f = LowFreqGrid;
        Ana(sess).low_before_plot = Spec_before_plot_grid;
        Ana(sess).low_after_plot  = Spec_after_plot_grid;
        Ana(sess).low_log2ratio   = Group.low_log2ratio{drug}(row,:);
    end

    % --- Multi-region spectra: AuCx, HPC (H), PFCx, Low + Middle ---
    % For each region/range combination, compute mean spectrum pre/post and a
    % per-band log-ratio. Plot panels are added in Final Figure 6.
    if isfield(S, 'RegionSpectra')
        regs = fieldnames(S.RegionSpectra);
        for rk = 1:length(regs)
            reg = regs{rk};
            for rng = {'Low','Middle'}
                if ~isfield(S.RegionSpectra.(reg), rng{1}), continue, end
                R = S.RegionSpectra.(reg).(rng{1});
                spec   = Data(R.sptsd);
                t_spec = Range(R.sptsd, 's'); t_spec = t_spec(:);
                f      = R.f(:)';
                [idx_sb_r, idx_sa_r] = injection_epoch_indices(t_spec, t_inj, InjExclusionSec);
                Sb_med = epoch_spectrum(spec, idx_sb_r, 'median');
                Sa_med = epoch_spectrum(spec, idx_sa_r, 'median');
                if strcmp(rng{1}, 'Low')
                    bandsToTest = {{'delta',Bands.delta}, {'theta',Bands.theta}};
                    grid = LowFreqGrid;
                else
                    bandsToTest = {{'beta',Bands.beta}, {'lowGamma',Bands.lowGamma}, ...
                                   {'gamma',Bands.gamma},  {'highGamma',Bands.highGamma}};
                    grid = MiddleFreqGrid;
                end
                for bk = 1:length(bandsToTest)
                    bnm  = bandsToTest{bk}{1};
                    band = bandsToTest{bk}{2};
                    bp_ts = spectrum_band_timeseries(spec, f, band, UseFrequencyWeightForBandMetrics);
                    % Use a `_spec_` infix so spectrum-derived multi-region
                    % metrics do not collide with the BrainPower-derived ones
                    % (e.g. hpc_gamma_logratio is BrainPower; hpc_spec_gamma_logratio is spectrum).
                    fld = [lower(reg) '_spec_' bnm '_logratio'];
                    Metrics(sess).(fld) = log_ratio_median(bp_ts, idx_sb_r, idx_sa_r);
                end
                % store per-session mean spectra for QC plots
                if UseFrequencyWeightForSpectrum
                    pb = f .* epoch_spectrum(spec, idx_sb_r, 'mean');
                    pa = f .* epoch_spectrum(spec, idx_sa_r, 'mean');
                else
                    pb = epoch_spectrum(spec, idx_sb_r, 'mean');
                    pa = epoch_spectrum(spec, idx_sa_r, 'mean');
                end
                Ana(sess).Region.(reg).(rng{1}).f          = grid;
                Ana(sess).Region.(reg).(rng{1}).before     = interp1(f, pb, grid, 'linear', NaN);
                Ana(sess).Region.(reg).(rng{1}).after      = interp1(f, pa, grid, 'linear', NaN);
                Ana(sess).Region.(reg).(rng{1}).log2ratio  = interp1(f, log2((Sa_med + eps) ./ (Sb_med + eps)), grid, 'linear', NaN);
            end
        end
    end

    % --- Per-session struct for plots and traceability ---
    Ana(sess).name = S.name;
    Ana(sess).animal = S.animal;
    Ana(sess).restraint = S.restraint;
    Ana(sess).drug_name = S.drug_name;
    Ana(sess).drug_id = drug;
    Ana(sess).Tref = Tref;
    Ana(sess).t_inj = t_inj;
    Ana(sess).idx_before = idx_before;
    Ana(sess).idx_after  = idx_after;
    Ana(sess).idx_moving = idx_moving;
    Ana(sess).smooth_acc_log = smooth_acc_log;
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
    Ana(sess).log_hpc_long   = log_hpc_long;
    Ana(sess).log_aeg_long   = log_aeg_long;
    Ana(sess).OBState = OBState;
    Ana(sess).breath_rate = breath_rate;
    Ana(sess).heart_rate  = heart_rate;
    if hasFUS
        Ana(sess).meanImg = meanImg;
        Ana(sess).masks   = S.fUS.masks;
    else
        Ana(sess).meanImg = [];
    end

    if MakeSingleSessionFigures
        make_session_v7_figure_AG(Ana(sess), Metrics(sess), ColorBefore, ColorAfter, Bands, SaveFigures, SaveFolder)
        % Free figure handles immediately so we don't accumulate 25 figures.
        close all
    end
    disp(['Analyzed v7 ' S.animal ' ' S.restraint ' ' S.drug_name ' session: ' S.name])

    % --- Memory cleanup for the next iteration (v7.1) ---
    % Drop the loaded session struct and any large intermediates. Only the
    % small Metrics(sess) / Ana(sess) / Group entries persist across loop
    % iterations.
    clear S Gamma Delta GammaData DeltaData TGamma TDelta ...
          Gamma_metric Delta_metric Gamma_trace Delta_trace ...
          gamma_norm delta_norm log_gamma log_delta log_gamma_long log_delta_long ...
          trace_hipp trace_AEG hpc_norm aeg_norm hpc_dcbv hpc_dcbv_percent aeg_dcbv aeg_dcbv_percent ...
          hpc_resid aeg_resid log_hpc_long log_aeg_long ...
          OBState heart_rate breath_rate smooth_acc_log log_emg_env idx_moving ...
          spec t_spec f Sb Sa Spec_before_mean Spec_after_mean Spec_before_med Spec_after_med ...
          Spec_before_plot Spec_after_plot Spec_before_plot_grid Spec_after_plot_grid ...
          MiddleRatioNative LowRatioNative deltaSpec thetaSpec lowGammaSpec gammaSpec highGammaSpec betaSpec ...
          deltaSpec_noBreath lowfSpec_noBreath ...
          R Sb_med Sa_med pb pa bp_ts ...
          meanImg sweep_r x_after y_h y_a TFUS dt_ref pre_window post_window ...
          OtherPow hrv_b hrv_a otherFlds chans
end

%% Save session metrics and drug statistics

MetricsTable = struct2table(Metrics);
if ~ismember('has_fus', MetricsTable.Properties.VariableNames)
    MetricsTable.has_fus = false(height(MetricsTable),1);
end

StatFields = {'gamma_logratio','delta_logratio','beta_spec_logratio', ...
    'lowgamma_spec_logratio','gamma_spec_logratio','highgamma_spec_logratio', ...
    'delta_spec_logratio','theta_spec_logratio', ...
    'gamma_peak_shift_hz','gamma_peak_shift_raw_hz', ...
    'hpc_dcbv_after_percent','aeg_dcbv_after_percent', ...                       % primary CBV metric
    'hpc_global_resid_dcbv_after_percent','aeg_global_resid_dcbv_after_percent', ...
    'hpc_cbv_logratio','aeg_cbv_logratio', ...                                    % secondary CBV metric
    'hpc_aeg_r_before','hpc_aeg_r_after', ...
    'gamma_hpc_r_before','gamma_hpc_r_after','gamma_aeg_r_before','gamma_aeg_r_after', ...
    'gamma_hpc_r_detr_before','gamma_hpc_r_detr_after', ...
    'gamma_hpc_dr','gamma_aeg_dr','delta_hpc_dr', ...
    'pre_half_gamma_log','pre_half_delta_log', ...
    'gamma_logratio_wake','delta_logratio_wake','gamma_spec_logratio_wake','lowgamma_logratio_wake','highgamma_logratio_wake', ...
    'breath_rate_before_hz','breath_rate_after_hz', ...
    'low_freq_no_breath_logratio','delta_no_breath_logratio', ...
    'hpc_gamma_logratio','pfc_gamma_logratio','acx_gamma_logratio','hpc_theta_logratio', ...
    'hpc_gamma_logratio_wake','pfc_gamma_logratio_wake','acx_gamma_logratio_wake','hpc_theta_logratio_wake', ...
    'hpc_spec_gamma_logratio','hpc_spec_lowgamma_logratio','hpc_spec_highgamma_logratio','hpc_spec_delta_logratio','hpc_spec_theta_logratio', ...
    'pfcx_spec_gamma_logratio','pfcx_spec_lowgamma_logratio','pfcx_spec_highgamma_logratio','pfcx_spec_delta_logratio','pfcx_spec_theta_logratio', ...
    'aucx_spec_gamma_logratio','aucx_spec_lowgamma_logratio','aucx_spec_highgamma_logratio','aucx_spec_delta_logratio','aucx_spec_theta_logratio', ...
    'hrv_RMSSD_before_ms','hrv_RMSSD_after_ms','hrv_SDNN_before_ms','hrv_SDNN_after_ms','hrv_meanRR_before_ms','hrv_meanRR_after_ms','hrv_pNN50_before_pct','hrv_pNN50_after_pct'};
Stats = struct();
for k = 1:length(StatFields)
    Stats(k) = simple_group_stats_AG(MetricsTable, StatFields{k});
end
StatsTable = struct2table(Stats);

% One value per animal sensitivity test
AnimalStats = struct();
for k = 1:length(StatFields)
    AnimalStats(k) = simple_mixed_rank_AG(MetricsTable, StatFields{k});
end
AnimalStatsTable = struct2table(AnimalStats);

if SaveFigures
    writetable(MetricsTable, fullfile(SaveFolder, 'AtropineSaline_session_metrics_v7.csv'));
    writetable(StatsTable,   fullfile(SaveFolder, 'AtropineSaline_drug_stats_v7.csv'));
    writetable(AnimalStatsTable, fullfile(SaveFolder, 'AtropineSaline_animal_stats_v7.csv'));
    % NOTE: workspace .mat save intentionally REMOVED — in v6 it produced
    % >70 GB files (AllSessions and Ana hold the raw spectrograms and fUS
    % cat_tsd). All figures are regenerated from CSVs + the small Group
    % struct, which is saved as a separate compact file:
    save(fullfile(SaveFolder, 'AtropineSaline_group_v7.mat'), 'Group','Bands','LongSmoothSweepSec','PostTimeGridSec','LagSec','MiddleFreqGrid','LowFreqGrid','-v7.3')
end
hypothesis_crosswalk_AG(SaveFigures, SaveFolder);

%% Final Figure 1: OB band power across sessions, with mean spectra panels

if MakeFinalFigures
    x_post_h = PostTimeGridSec/3600;
    figure('Name','Figure 1 - OB drug effects across sessions','Position',[100 60 1700 900]);
    sgtitle('OB band-power effects: time courses, mean spectra, scalar effects')

    subplot(3,4,1)
    plot_group_timecourse_clean(x_post_h, Group.gamma_after_real, DrugColors, 1)
    ylabel('OB gamma / baseline'), title('Gamma 40-60 (BrainPower)')

    subplot(3,4,2)
    plot_group_timecourse_clean(x_post_h, Group.delta_after_real, DrugColors, 1)
    ylabel('OB delta / baseline'), title('Delta 0.5-3 (BrainPower)')

    subplot(3,4,3)
    plot_metric_by_drug(MetricsTable, 'gamma_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('Gamma logratio')

    subplot(3,4,4)
    plot_metric_by_drug(MetricsTable, 'delta_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('Delta logratio')

    subplot(3,4,5)
    for drug = 1:2
        plot_mean_spectrum_pre_post_AG(LowFreqGrid, Group.low_before_fweighted{drug}, Group.low_after_fweighted{drug}, DrugColors{drug}, DrugNames{drug});
    end
    xlim([0 20])
    xlabel('Hz'), ylabel('f * power (display)')
    title('Group mean Low spectrum (before/after)')
    legend('show','Location','best'), makepretty_BM2

    subplot(3,4,6)
    for drug = 1:2
        plot_mean_spectrum_pre_post_AG(MiddleFreqGrid, Group.middle_before_fweighted{drug}, Group.middle_after_fweighted{drug}, DrugColors{drug}, DrugNames{drug});
    end
    xlim([20 100])
    vline_compat(Bands.lowGamma(1),'--r'); vline_compat(Bands.lowGamma(2),'--r')
    vline_compat(Bands.gamma(1),'--k'); vline_compat(Bands.gamma(2),'--k')
    vline_compat(Bands.highGamma(1),'--b'); vline_compat(Bands.highGamma(2),'--b')
    xlabel('Hz'), title('Group mean Middle spectrum (before/after)')
    legend('show','Location','best'), makepretty_BM2

    subplot(3,4,7)
    plot_animal_session_points_AG(MetricsTable, 'gamma_logratio', DrugColors)
    ylabel('log a/b'), title('Gamma by animal')

    subplot(3,4,8)
    plot_animal_session_points_AG(MetricsTable, 'delta_logratio', DrugColors)
    ylabel('log a/b'), title('Delta by animal')

    subplot(3,4,9)
    plot_metric_by_drug(MetricsTable, 'gamma_peak_shift_raw_hz', DrugColors, 1:2, DrugNames)
    ylabel('after-before peak Hz'), title('Gamma peak shift (raw)')

    subplot(3,4,10)
    plot_metric_by_drug(MetricsTable, 'theta_spec_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('Theta logratio (4-8)')

    subplot(3,4,11)
    plot_coverage_strip_AG(x_post_h, Group.gamma_after_real, DrugColors)
    title('Coverage (n sess) for time courses')

    subplot(3,4,12)
    plot_metric_by_drug(MetricsTable, 'beta_spec_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('Beta 15-30')

    save_current_figure(SaveFigures, SaveFolder, 'Figure_1_OB_all_sessions.png')
end

%% Final Figure 2: OB spectral reorganization (sub-bands and peaks)

if MakeFinalFigures
    figure('Name','Figure 2 - OB spectral reorganization','Position',[100 60 1700 850]);
    sgtitle('Differential effects across OB sub-bands')

    subplot(2,4,1)
    plot_group_log2ratio_clean(AllSessions, Group.low_log2ratio, 'low', DrugColors, DistributionSmoothBins)
    xlim([0 20]), ylabel('log2 a/b'), title('Low log2 ratio')
    vline_compat(Bands.delta(1),'--r'); vline_compat(Bands.delta(2),'--r')
    vline_compat(Bands.theta(1),'--k'); vline_compat(Bands.theta(2),'--k')

    subplot(2,4,2)
    plot_group_log2ratio_clean(AllSessions, Group.middle_log2ratio, 'middle', DrugColors, DistributionSmoothBins)
    xlim([20 100]), ylabel('log2 a/b'), title('Middle log2 ratio')
    vline_compat(Bands.lowGamma(1),'--r'); vline_compat(Bands.lowGamma(2),'--r')
    vline_compat(Bands.gamma(1),'--k'); vline_compat(Bands.gamma(2),'--k')
    vline_compat(Bands.highGamma(1),'--b'); vline_compat(Bands.highGamma(2),'--b')

    subplot(2,4,3)
    plot_metric_by_drug(MetricsTable, 'lowgamma_spec_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('Low gamma 20-40')

    subplot(2,4,4)
    plot_metric_by_drug(MetricsTable, 'gamma_spec_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('Gamma 40-60')

    subplot(2,4,5)
    plot_metric_by_drug(MetricsTable, 'highgamma_spec_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('High gamma 60-80')

    subplot(2,4,6)
    plot_metric_by_drug(MetricsTable, 'delta_spec_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('Delta 0.5-3')

    subplot(2,4,7)
    plot_metric_by_drug(MetricsTable, 'low_freq_no_breath_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('Low freq, breath-notched')

    subplot(2,4,8)
    % Sub-band peak shifts (raw, unweighted) summary
    hold on
    bar([nanmedian(MetricsTable.lowgamma_peak_after_raw_hz(MetricsTable.drug_id==1)) - nanmedian(MetricsTable.lowgamma_peak_before_raw_hz(MetricsTable.drug_id==1)), ...
         nanmedian(MetricsTable.highgamma_peak_after_raw_hz(MetricsTable.drug_id==1)) - nanmedian(MetricsTable.highgamma_peak_before_raw_hz(MetricsTable.drug_id==1)); ...
         nanmedian(MetricsTable.lowgamma_peak_after_raw_hz(MetricsTable.drug_id==2)) - nanmedian(MetricsTable.lowgamma_peak_before_raw_hz(MetricsTable.drug_id==2)), ...
         nanmedian(MetricsTable.highgamma_peak_after_raw_hz(MetricsTable.drug_id==2)) - nanmedian(MetricsTable.highgamma_peak_before_raw_hz(MetricsTable.drug_id==2))])
    set(gca,'XTickLabel',{'Saline','Atropine'})
    legend({'low gamma','high gamma'},'Location','best')
    ylabel('peak shift Hz')
    title('Sub-band peak shift (median)')
    yline_compat(0,'--r'), makepretty_BM2

    save_current_figure(SaveFigures, SaveFolder, 'Figure_2_OB_spectral_reorganization.png')
end

%% Final Figure 3: fUS CBV drug effects (with global-regressed control)

if MakeFinalFigures
    fUSMetrics = MetricsTable(MetricsTable.has_fus == 1,:);
    figure('Name','Figure 3 - fUS CBV drug effects','Position',[100 60 1700 900]);
    sgtitle('fUS CBV: time courses, region effects, global-regressed residuals')

    subplot(3,4,1)
    plot_group_timecourse_clean(x_post_h, Group.hpc_dcbv_after_real, DrugColors, 0)
    ylabel('HPC dCBV (%)'), title('HPC dCBV time course')

    subplot(3,4,2)
    plot_group_timecourse_clean(x_post_h, Group.aeg_dcbv_after_real, DrugColors, 0)
    ylabel('AEG dCBV (%)'), title('AEG dCBV time course')

    % Primary CBV metric: dCBV percent (per recommendation 3).
    subplot(3,4,3)
    plot_metric_by_drug(fUSMetrics, 'hpc_dcbv_after_percent', DrugColors, 1:2, DrugNames)
    ylabel('post dCBV %'), title('HPC dCBV (post)  [PRIMARY]')

    subplot(3,4,4)
    plot_metric_by_drug(fUSMetrics, 'aeg_dcbv_after_percent', DrugColors, 1:2, DrugNames)
    ylabel('post dCBV %'), title('AEG dCBV (post)  [PRIMARY]')

    subplot(3,4,5)
    plot_metric_by_drug(fUSMetrics, 'hpc_global_resid_dcbv_after_percent', DrugColors, 1:2, DrugNames)
    ylabel('residual dCBV %'), title('HPC, global-mean regressed')

    subplot(3,4,6)
    plot_metric_by_drug(fUSMetrics, 'aeg_global_resid_dcbv_after_percent', DrugColors, 1:2, DrugNames)
    ylabel('residual dCBV %'), title('AEG, global-mean regressed')

    % CBV log-ratio kept as a sanity panel (secondary).
    subplot(3,4,7)
    plot_metric_by_drug(fUSMetrics, 'hpc_cbv_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('HPC log-ratio (secondary)')

    subplot(3,4,8)
    plot_metric_by_drug(fUSMetrics, 'aeg_cbv_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('AEG log-ratio (secondary)')

    subplot(3,4,9)
    plot_prepost_metric_by_drug(fUSMetrics, 'hpc_aeg_r_before', 'hpc_aeg_r_after', DrugColors)
    ylabel('r(log HPC, log AEG)'), title('HPC-AEG correlation')

    subplot(3,4,10)
    plot_coverage_strip_AG(x_post_h, Group.hpc_dcbv_after_real, DrugColors)
    title('HPC time-course coverage')

    subplot(3,4,11)
    plot_coverage_strip_AG(x_post_h, Group.aeg_dcbv_after_real, DrugColors)
    title('AEG time-course coverage')

    subplot(3,4,12)
    plot_metric_by_drug(fUSMetrics, 'hpc_aeg_r_after', DrugColors, 1:2, DrugNames)
    ylabel('r after'), title('HPC-AEG r (after)')

    save_current_figure(SaveFigures, SaveFolder, 'Figure_3_fUS_CBV_effects.png')
end

%% Final Figure 4: OB-CBV slow coupling and atropine

if MakeFinalFigures
    fUSMetrics = MetricsTable(MetricsTable.has_fus == 1,:);
    % Cell of paired delta-r per drug (gamma-HPC and gamma-AEG)
    drs_hpc = cell(1,2); drs_aeg = cell(1,2);
    for drug = 1:2
        idx = fUSMetrics.drug_id == drug;
        drs_hpc{drug} = fUSMetrics.gamma_hpc_dr(idx);
        drs_aeg{drug} = fUSMetrics.gamma_aeg_dr(idx);
    end

    figure('Name','Figure 4 - OB-CBV coupling','Position',[100 60 1700 900]);
    sgtitle('Long-timescale OB-CBV coupling and the atropine effect')

    subplot(2,4,1)
    plot_prepost_metric_by_drug(fUSMetrics, 'gamma_hpc_r_before', 'gamma_hpc_r_after', DrugColors)
    ylabel('r(log gamma, log HPC)'), title('Gamma-HPC pre vs post')

    subplot(2,4,2)
    plot_prepost_metric_by_drug(fUSMetrics, 'gamma_aeg_r_before', 'gamma_aeg_r_after', DrugColors)
    ylabel('r(log gamma, log AEG)'), title('Gamma-AEG pre vs post')

    subplot(2,4,3)
    plot_paired_delta_AG(drs_hpc, DrugColors, DrugNames)
    ylabel('Delta-r (after - before)'), title('Gamma-HPC: paired Delta-r')

    subplot(2,4,4)
    plot_paired_delta_AG(drs_aeg, DrugColors, DrugNames)
    ylabel('Delta-r (after - before)'), title('Gamma-AEG: paired Delta-r')

    subplot(2,4,5)
    plot_lag_pre_post_AG(LagSec/60, Group.lag_gamma_hpc_before, Group.lag_gamma_hpc_after, DrugColors)
    title('Gamma-HPC lag (pre vs post)')

    subplot(2,4,6)
    plot_lag_pre_post_AG(LagSec/60, Group.lag_gamma_aeg_before, Group.lag_gamma_aeg_after, DrugColors)
    title('Gamma-AEG lag (pre vs post)')

    subplot(2,4,7)
    plot_prepost_metric_by_drug(fUSMetrics, 'gamma_hpc_r_detr_before', 'gamma_hpc_r_detr_after', DrugColors)
    ylabel('detrended r'), title('Gamma-HPC detrended')

    subplot(2,4,8)
    plot_prepost_metric_by_drug(fUSMetrics, 'delta_hpc_r_before', 'delta_hpc_r_after', DrugColors)
    ylabel('r(log delta, log HPC)'), title('Delta-HPC pre vs post')

    save_current_figure(SaveFigures, SaveFolder, 'Figure_4_OB_CBV_coupling.png')
end

%% Final Figure 5: Bodily variables across sessions

if MakeFinalFigures && MakeBodilyFigure
    figure('Name','Figure 5 - bodily variables','Position',[100 60 1700 850]);
    sgtitle('Heart rate, breath rate, accelerometer (Wake proxy)')

    subplot(2,4,1)
    plot_group_timecourse_clean(x_post_h, Group.heart_after_real, DrugColors, NaN)
    ylabel('Heart rate (Hz)'), title('Heart rate time course')

    subplot(2,4,2)
    plot_group_timecourse_clean(x_post_h, Group.breath_after_real, DrugColors, NaN)
    ylabel('Breath rate (Hz)'), title('Breath rate time course')

    subplot(2,4,3)
    plot_group_timecourse_clean(x_post_h, Group.acc_after_real, DrugColors, NaN)
    ylabel('log10 accelero'), title('Accelero time course')

    subplot(2,4,4)
    plot_metric_by_drug(MetricsTable, 'frac_wake_after', DrugColors, 1:2, DrugNames)
    ylabel('Wake fraction (post)'), title('Wake/Movement fraction')

    subplot(2,4,5)
    plot_prepost_metric_by_drug(MetricsTable, 'breath_rate_before_hz','breath_rate_after_hz', DrugColors)
    ylabel('Breath (Hz)'), title('Breath rate (paired)')

    subplot(2,4,6)
    plot_prepost_metric_by_drug(MetricsTable, 'hrv_RMSSD_before_ms','hrv_RMSSD_after_ms', DrugColors)
    ylabel('RMSSD (ms)'), title('HRV: RMSSD (paired)')

    subplot(2,4,7)
    plot_prepost_metric_by_drug(MetricsTable, 'hrv_SDNN_before_ms','hrv_SDNN_after_ms', DrugColors)
    ylabel('SDNN (ms)'), title('HRV: SDNN (paired)')

    subplot(2,4,8)
    plot_prepost_metric_by_drug(MetricsTable, 'hrv_meanRR_before_ms','hrv_meanRR_after_ms', DrugColors)
    ylabel('mean RR (ms)'), title('mean RR (paired)')

    save_current_figure(SaveFigures, SaveFolder, 'Figure_5_bodily_variables.png')
end

%% Final Figure 6: Multi-region OB-style power and spectra (HPC, PFC, ACx, AuCx)

if MakeFinalFigures
    figure('Name','Figure 6 - multi-region power and spectra','Position',[100 60 1700 950]);
    sgtitle('Drug effect across brain regions (when channels are available)')

    % Row 1: BrainPower-derived per-region log-ratios
    subplot(3,4,1)
    plot_metric_by_drug(MetricsTable, 'hpc_gamma_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('HPC gamma (BrainPower)')

    subplot(3,4,2)
    plot_metric_by_drug(MetricsTable, 'pfc_gamma_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('PFC gamma (BrainPower)')

    subplot(3,4,3)
    plot_metric_by_drug(MetricsTable, 'acx_gamma_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('ACx gamma (BrainPower)')

    subplot(3,4,4)
    plot_metric_by_drug(MetricsTable, 'hpc_theta_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('HPC theta (BrainPower)')

    % Row 2: Spectrum-derived sub-band log-ratios per region (gamma)
    subplot(3,4,5)
    plot_metric_by_drug(MetricsTable, 'hpc_spec_gamma_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('HPC spec gamma 40-60')

    subplot(3,4,6)
    plot_metric_by_drug(MetricsTable, 'pfcx_spec_gamma_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('PFCx spec gamma 40-60')

    subplot(3,4,7)
    plot_metric_by_drug(MetricsTable, 'aucx_spec_gamma_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('AuCx spec gamma 40-60')

    subplot(3,4,8)
    plot_metric_by_drug(MetricsTable, 'aucx_spec_lowgamma_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('AuCx spec low-gamma 20-40')

    % Row 3: Spectrum-derived low-frequency log-ratios per region
    subplot(3,4,9)
    plot_metric_by_drug(MetricsTable, 'hpc_spec_delta_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('HPC spec delta')

    subplot(3,4,10)
    plot_metric_by_drug(MetricsTable, 'hpc_spec_theta_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('HPC spec theta')

    subplot(3,4,11)
    plot_metric_by_drug(MetricsTable, 'pfcx_spec_theta_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('PFCx spec theta')

    subplot(3,4,12)
    plot_metric_by_drug(MetricsTable, 'aucx_spec_theta_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('AuCx spec theta')

    save_current_figure(SaveFigures, SaveFolder, 'Figure_6_multi_region.png')
end

%% Supplementary Figure S1: Within-Wake re-analysis

if MakeSupplementaryFigures && MakeWakeOnlyFigure
    figure('Name','Sup S1 - Within-Wake re-analysis','Position',[100 60 1500 800]);
    sgtitle('Same OB sub-band tests, restricted to Moving (log10 acc > threshold) time')

    subplot(2,3,1)
    plot_metric_by_drug(MetricsTable, 'gamma_logratio_wake', DrugColors, 1:2, DrugNames)
    ylabel('log a/b (Wake-only)'), title('Gamma (Wake-only)')

    subplot(2,3,2)
    plot_metric_by_drug(MetricsTable, 'lowgamma_logratio_wake', DrugColors, 1:2, DrugNames)
    ylabel('log a/b (Wake-only)'), title('Low gamma (Wake-only)')

    subplot(2,3,3)
    plot_metric_by_drug(MetricsTable, 'highgamma_logratio_wake', DrugColors, 1:2, DrugNames)
    ylabel('log a/b (Wake-only)'), title('High gamma (Wake-only)')

    subplot(2,3,4)
    plot_metric_by_drug(MetricsTable, 'gamma_spec_logratio_wake', DrugColors, 1:2, DrugNames)
    ylabel('log a/b (Wake-only)'), title('Gamma spec (Wake-only)')

    subplot(2,3,5)
    plot_metric_by_drug(MetricsTable, 'delta_logratio_wake', DrugColors, 1:2, DrugNames)
    ylabel('log a/b (Wake-only)'), title('Delta (Wake-only)')

    subplot(2,3,6)
    plot_metric_by_drug(MetricsTable, 'delta_no_breath_logratio', DrugColors, 1:2, DrugNames)
    ylabel('log a/b'), title('Delta, breath-notched')

    save_current_figure(SaveFigures, SaveFolder, 'Figure_S1_WakeOnly_and_breath.png')
end

%% Supplementary Figure S2: LongSmoothSec robustness sweep

if MakeSupplementaryFigures && MakeSweepFigure
    figure('Name','Sup S2 - LongSmoothSec sweep','Position',[100 60 1200 600]);
    sgtitle('OB gamma - HPC CBV slow correlation vs smoothing window (after-injection epoch)')

    hold on
    DrugLabels = {'Saline','Atropine'};
    for drug = 1:2
        D = remove_empty_rows(Group.sweep_r_after_gamma_hpc{drug});
        if isempty(D), continue, end
        M = nanmean(D,1);
        E = nanstd(D,0,1)./sqrt(size(D,1));
        if exist('shadedErrorBar','file')
            h = shadedErrorBar(LongSmoothSweepSec/60, M, E, '-k', 1);
            h.mainLine.Color = DrugColors{drug}; h.mainLine.LineWidth = 2.5;
            h.mainLine.DisplayName = DrugLabels{drug};
            h.patch.FaceColor = DrugColors{drug}; h.patch.FaceAlpha = 0.18;
        else
            plot(LongSmoothSweepSec/60, M, 'Color', DrugColors{drug}, 'LineWidth', 2.5, 'DisplayName', DrugLabels{drug})
        end
    end
    yline_compat(0,'--r')
    xlabel('Smoothing window (min)')
    ylabel('r(log gamma, log HPC) after')
    legend('show','Location','best')
    makepretty_BM2

    save_current_figure(SaveFigures, SaveFolder, 'Figure_S2_LongSmoothSweep.png')
end

%% Supplementary Figure S3: Pre-half noise control

if MakeSupplementaryFigures
    figure('Name','Sup S3 - Pre-half noise vs effect','Position',[100 60 1500 600]);
    sgtitle('Within-pre split-half null vs the actual pre-vs-post effect')

    subplot(1,3,1)
    hold on
    for drug = 1:2
        idx = MetricsTable.drug_id == drug;
        x = MetricsTable.pre_half_gamma_log(idx); x = x(isfinite(x));
        y = MetricsTable.gamma_logratio(idx);    y = y(isfinite(y));
        scatter(ones(size(x))-0.2 + 0.4*(drug-1), x, 30, DrugColors{drug}, 'o')
        scatter(ones(size(y))*2-0.2 + 0.4*(drug-1), y, 30, DrugColors{drug}, 'filled')
    end
    set(gca,'XTick',[1 2],'XTickLabel',{'pre1->pre2','before->after'})
    yline_compat(0,'--r')
    ylabel('log ratio'), title('Gamma'), makepretty_BM2

    subplot(1,3,2)
    hold on
    for drug = 1:2
        idx = MetricsTable.drug_id == drug;
        x = MetricsTable.pre_half_delta_log(idx); x = x(isfinite(x));
        y = MetricsTable.delta_logratio(idx);    y = y(isfinite(y));
        scatter(ones(size(x))-0.2 + 0.4*(drug-1), x, 30, DrugColors{drug}, 'o')
        scatter(ones(size(y))*2-0.2 + 0.4*(drug-1), y, 30, DrugColors{drug}, 'filled')
    end
    set(gca,'XTick',[1 2],'XTickLabel',{'pre1->pre2','before->after'})
    yline_compat(0,'--r')
    ylabel('log ratio'), title('Delta'), makepretty_BM2

    subplot(1,3,3)
    hold on
    for drug = 1:2
        idx = MetricsTable.drug_id == drug;
        x = MetricsTable.pre_half_lowgamma_log(idx); x = x(isfinite(x));
        y = MetricsTable.lowgamma_spec_logratio(idx); y = y(isfinite(y));
        scatter(ones(size(x))-0.2 + 0.4*(drug-1), x, 30, DrugColors{drug}, 'o')
        scatter(ones(size(y))*2-0.2 + 0.4*(drug-1), y, 30, DrugColors{drug}, 'filled')
    end
    set(gca,'XTick',[1 2],'XTickLabel',{'pre1->pre2','before->after'})
    yline_compat(0,'--r')
    ylabel('log ratio'), title('Low gamma'), makepretty_BM2

    save_current_figure(SaveFigures, SaveFolder, 'Figure_S3_pre_half_noise_vs_effect.png')
end

%% Supplementary Figure S4: Distributions and OB state occupancy (kept from v6)

if MakeSupplementaryFigures
    figure('Name','Sup S4 - OB distributions and 4-state occupancy','Position',[100 60 1500 800]);
    sgtitle('OB power distributions and OB 4-state occupancy. Note: pre values near 25% by construction.')

    subplot(2,4,[1 2])
    plot_distribution_group(Ana, 'gamma', DrugColors, ColorBefore, ColorAfter)
    xlabel('log OB gamma power'), ylabel('p'), title('Gamma distributions')

    subplot(2,4,[3 4])
    plot_distribution_group(Ana, 'delta', DrugColors, ColorBefore, ColorAfter)
    xlabel('log OB delta power'), ylabel('p'), title('Delta distributions')

    StateLabels = {'Ghi/Dlo','Glo/Dhi','Ghi/Dhi','Glo/Dlo'};
    for st = 1:4
        subplot(2,4,st+4)
        plot_state_change_by_drug(Group, st, DrugColors, DrugNames)
        ylim([-0.4 0.4])
        ylabel('after - before fraction')
        title(StateLabels{st})
    end

    save_current_figure(SaveFigures, SaveFolder, 'Figure_S4_distributions_and_states.png')
end

%% Compact numerical summary

disp(' ')
disp('Outputs of v7:')
disp('  AllSessions          : raw loaded data per session')
disp('  Ana                  : per-session derived traces and labels')
disp('  Metrics              : per-session scalar metrics')
disp('  MetricsTable         : table version of Metrics, one row per session')
disp('  StatsTable           : two-drug session-level summary statistics')
disp('  AnimalStatsTable     : per-animal sensitivity test (rank-sum across animals)')
disp('  Group                : group time courses, spectra, lag curves, sweep curves')
disp(' ')
disp('Saved CSV files:')
disp('  AtropineSaline_session_metrics_v7.csv')
disp('  AtropineSaline_drug_stats_v7.csv')
disp('  AtropineSaline_animal_stats_v7.csv')
disp('  AtropineSaline_hypothesis_crosswalk_v7.csv')
disp('Saved compact group struct: AtropineSaline_group_v7.mat (~MB, no raw data).')
disp('NOTE: full workspace .mat is intentionally NOT saved in v7 (was >70 GB in v6).')
disp('All figures saved as PNG in SaveFolder.')
disp(' ')
disp('For publication-grade inference, run a mixed-effects model (fitlme) on the saved CSV')
disp('using "metric ~ drug*restraint + (1|animal)", and compare Delta-r distributions across')
disp('drugs with paired Wilcoxon (Fig 4) instead of unpaired tests.')

