% Sleep24h_Analysis_Main_AG
%
% Exploratory analysis and paper-quality figures for two 24-hour ferret sleep
% recordings. States are taken from CleanStates (Wake / N1 / N2 / REM) saved
% in SleepScoring_OBGamma.mat by MakeCleanStates_Ferret_BM.
%
% This script ONLY orchestrates: every analytical or plotting routine lives in
% its own .m file under ./helpers/. To regenerate any figure, modify the
% corresponding helper.
%
% Author : Arsenii Goriachenkov, May 2026
% Reference scripts : Ferret_Paper_SleeScoring_Illustration,
%                     Ferret_Paper_Spectrograms_SleepStates,
%                     TransitionsMatrices_SleepStates_BM,
%                     SLeepCycles_Ferret_BM
%
% USAGE
%   1. Edit the "USER INPUTS" block below with the two session paths.
%   2. Make sure NeuroMeta and PrgGithub are on the MATLAB path (the helpers
%      below depend on transEpoch, FilterLFP, makepretty_BM2, runmean, etc.).
%   3. Run this script. Figures land in OutputDir.

% clear all  %#ok<CLALL>
% close all

% =============================================================================
% USER INPUTS
% =============================================================================
SessionPaths = { ...
    'Z:\Arsenii\OBG\Tvorozhok\20260417_24h\ephys', ...  
    'Z:\Arsenii\OBG\Tvorozhok\20260424_24h\ephys',...
    'W:\Arsenii\OBG_project\Tvorozhok\freely-moving\20260529_24h\ephys',...
    'Z:\Arsenii\OBG\Mochi\20260521_24h\ephys',...
    'Z:\Arsenii\OBG\Mochi\20260527_24h\ephys',...
    'W:\Arsenii\OBG_project\Mochi\freely-moving\20260604_24h\ephys',...
    'W:\Arsenii\OBG_project\Mochi\freely-moving\20260608_24h\ephys',...
    };  
% 'W:\Arsenii\OBG_project\Mochi\freely-moving\20260608_24h\ephys',...
% , 'M_0608'
SessionNames = {'T_0417', 'T_0424', 'T_0529', 'M_0521', 'M_0527', 'M_0604', 'M_0608'};

OutputDir    = 'D:\Arsenii\GitHub\NeuroMeta\OlfactoryBulb_VigilanceStates\24h_analysis\figures';

% Analysis parameters
binSize_s          = 60*60;   % 30-min bins for 24-h dynamics
smoothWindow_h     = 1.0;    % moving-average window (h) for per-state lines
mergeREM_s         = 180;    % REM cleaning before cycle definition
dropREM_s          = 60;
nBinsCycle         = 20;     % bins per sleep cycle for time-warping (Fig 4)
nBinsCycleTraces   = 100;    % bins per sleep cycle for cycle-aligned traces / spectrograms
nShuffleTransition = 1000;   % bout-shuffle baseline for transitions; 0 to skip
doCycleSpectro     = true;   % time-warp spectrograms onto cycle (slow but useful)
saveFigs           = true;
figFormats         = {'png','svg'};

% Metrics caching: on the first run we compute everything and save a small
% .mat next to the session data. On later runs we load the cache and skip
% the heavy computes. Set forceRecompute = true when you change any analysis
% parameter (the helper will warn if cached params differ but will still use
% the cache unless you force a refresh).
forceRecompute     = false;
cacheFilename      = 'Sleep24hMetrics_AG.mat';  % saved as <sessionPath>/<cacheFilename>

% Bout-duration thresholds (minutes) splitting "short" from "long" bouts
% per state. Defaults match the trough between modes seen in your bout-
% duration histograms. Pass [] for any state to skip the split.
boutThresholds_min.N1   = 0.5;     % 30 s
boutThresholds_min.N2   = 2.0;     % 120 s
boutThresholds_min.REM  = 2.5;     % 150 s
boutThresholds_min.Wake = [];      % keep Wake as a single group

% Substate organization figure: time-bin width (h) for the short/long mix curve
substateTimeBin_h = 2;

% Cycle-regularity (HPC theta autocorrelation) parameters
regularityParams.sig           = 'HPCtheta';  % 'HPCtheta'|'OBdelta'|'OBgamma'
regularityParams.binSize_s     = 60;          % 1-min coarse bins
regularityParams.window_h      = 3;           % sliding window length
regularityParams.step_h        = 1;           % step between windows
regularityParams.maxLag_min    = 60;          % autocorrelogram half-width
regularityParams.targetLag_min = 25;          % expected cycle period (regularity score)
regularityParams.minPeakLag_min= 8;           % ignore peaks below this lag

% Light schedule, per session, as Nx2 matrices of LIGHTS-ON intervals in
% recording-relative hours. Pass [] to skip shading. Use the convention:
% recording starts at hour 0; lights ON during the rows of the matrix.
%
% Session_0417: started 15:10. Lights ON until 20:00 (4h50min after start),
% OFF until 11:00 next day (19h50min after start), ON until end (~23.95 h).
%
% Session_0424: started 19:41. Lights OFF for the first 1012 min = 16.875 h,
% then ON until end (~24.37 h).
LightOnIntervals = {...
    [0 4.83; 19.83 24],... % T_0417
    [16.87 24.4],... % T_0424
    [0 11.9],... % T_0529
    [0 12.7],... % M_0521
    [0 11.9],... % M_0527
    [0 13],... % M_0604
    [0 10.83],... % M_0608    
    };


% =============================================================================
% PATH SETUP
% =============================================================================
thisDir   = fileparts(mfilename('fullpath'));
helperDir = fullfile(thisDir, 'helpers');
addpath(helperDir);

if saveFigs && ~exist(OutputDir,'dir'), mkdir(OutputDir); end

colors = state_colors_AG();
nSess  = numel(SessionPaths);

% =============================================================================
% PHASE 1: per-session metrics with smart SD loading
% =============================================================================
% For each session we first try to load the cache. If valid, no SD is loaded
% (saves time and RAM). If the cache is missing or stale, we load the SD just
% for that session, compute, save, and immediately free the SD before moving
% on. RAM never holds more than one SD at a time, even with many sessions.
% =============================================================================
fprintf('=== Phase 1: per-session metrics (one session in RAM at a time) ===\n');

CACHE_VERSION_EXPECTED = 3;   % must match compute_or_load_session_metrics_AG

analysisParams = struct( ...
    'binSize_s',           binSize_s, ...
    'mergeREM_s',          mergeREM_s, ...
    'dropREM_s',           dropREM_s, ...
    'nBinsCycle',          nBinsCycle, ...
    'nBinsCycleTraces',    nBinsCycleTraces, ...
    'nShuffleTransition',  nShuffleTransition, ...
    'doCycleSpectro',      doCycleSpectro, ...
    'boutThresholds_min',  boutThresholds_min, ...
    'substateTimeBin_h',   substateTimeBin_h, ...
    'regularityParams',    regularityParams);

% Pre-allocate per-session metric cells (all small, all RAM-friendly)
M     = cell(1, nSess);
D     = cell(1, nSess);
C     = cell(1, nSess);
T     = cell(1, nSess);
T_sub = cell(1, nSess);
BF    = cell(1, nSess);
CT    = cell(1, nSess);
ORG   = cell(1, nSess);
REG   = cell(1, nSess);
SS    = cell(1, nSess);
LD    = cell(1, nSess);

% Light-weight session info per session (states + totDur), filled from cache.
% This is enough for the hypnogram + light/dark figures without needing the
% raw signals or spectrograms.
SInfo = cell(1, nSess);

qcOK = true(1, nSess);

for s = 1:nSess
    sessName = SessionNames{s};
    sessPath = SessionPaths{s};
    cachePath = fullfile(sessPath, cacheFilename);

    paramsThisSess = analysisParams;
    if numel(LightOnIntervals) >= s
        paramsThisSess.lightOnIntervals_h = LightOnIntervals{s};
    else
        paramsThisSess.lightOnIntervals_h = [];
    end

    % Try to use the cache first; only touch SD if we must compute
    SM = try_load_cache_AG(cachePath, CACHE_VERSION_EXPECTED);
    if ~isempty(SM) && ~forceRecompute
        fprintf('  [%s] using cached metrics (no SD load)\n', sessName);
    else
        % Cache miss or forced refresh -> load SD, compute, free SD
        fprintf('  [%s] loading SD and computing metrics\n', sessName);
        SD_one = load_session_AG(sessPath, sessName);
        qcOK(s) = qc_check_states_AG(SD_one);
        SM = compute_or_load_session_metrics_AG( ...
            SD_one, paramsThisSess, true, cachePath);   % forceRecompute=true here
        clear SD_one
    end

    % Stash the slices we need downstream
    M{s}     = SM.M;
    D{s}     = SM.D;
    C{s}     = SM.C;
    T{s}     = SM.T;
    T_sub{s} = SM.T_sub;
    BF{s}    = SM.BF;
    CT{s}    = SM.CT;
    ORG{s}   = SM.ORG;
    REG{s}   = SM.REG;
    SS{s}    = SM.SS;
    LD{s}    = SM.LD;
    SInfo{s} = struct( ...
        'name',       SM.sessionName, ...
        'path',       SM.sessionPath, ...
        'states',     SM.states, ...
        'totDur_h',   SM.totDur_h, ...
        'totDur_ts',  SM.totDur_ts);
    clear SM
end

if ~all(qcOK)
    warning('One or more sessions failed QC during their compute pass. Inspect log.');
end

% =============================================================================
% FIGURES
% =============================================================================
fprintf('\n=== Drawing figures ===\n');

% Fig 1 (per session): scoring sanity overview. This is the only figure that
% requires the full SD (spectrograms + raw signals). Make it opt-in to keep
% the default run RAM-light. Each session is loaded just-in-time and freed
% before the next.
doSessionOverview = false;  % set true to re-generate Fig 1 across sessions
if doSessionOverview
    for s = 1:nSess
        fprintf('Fig 1 - overview for %s\n', SessionNames{s});
        if numel(LightOnIntervals) >= s
            loi = LightOnIntervals{s};
        else
            loi = [];
        end
        SD_one = load_session_AG(SessionPaths{s}, SessionNames{s});
        fig1 = plot_session_overview_AG(SD_one, colors, loi);
        if saveFigs
            save_figure_AG(fig1, OutputDir, ...
                sprintf('Fig1_overview_%s', SessionNames{s}), figFormats);
        end
        close(fig1)
        clear SD_one
    end
end

% Fig 2: state composition + bout statistics (with threshold lines on histograms)
fprintf('Fig 2 - state composition\n');
fig2 = plot_state_composition_AG(M, SessionNames, colors, boutThresholds_min);
if saveFigs, save_figure_AG(fig2, OutputDir, 'Fig2_state_composition', figFormats); end

% Fig 3: 24-h dynamics (with smoothed per-state evolution)
fprintf('Fig 3 - 24-h dynamics\n');
fig3 = plot_24h_dynamics_AG(D, SessionNames, colors, LightOnIntervals, smoothWindow_h);
if saveFigs, save_figure_AG(fig3, OutputDir, 'Fig3_24h_dynamics', figFormats); end

% Fig 4: sleep cycles (mean composition + per-cycle mosaic + cycle-duration box)
fprintf('Fig 4 - sleep-cycle composition\n');
fig4 = plot_sleep_cycles_AG(C, SessionNames, colors);
if saveFigs, save_figure_AG(fig4, OutputDir, 'Fig4_sleep_cycles', figFormats); end

% Fig 5: transition matrices (heatmap + observed-shuffle)
fprintf('Fig 5 - transition matrices\n');
fig5 = plot_transition_matrix_AG(T, SessionNames, colors);
if saveFigs, save_figure_AG(fig5, OutputDir, 'Fig5_transition_matrices', figFormats); end

% Fig 6: substate (short vs long bout) characterization
fprintf('Fig 6 - substate features (short vs long)\n');
fig6 = plot_bout_features_AG(BF, SessionNames);
if saveFigs, save_figure_AG(fig6, OutputDir, 'Fig6_substate_features', figFormats); end

% Fig 7: state-transition graph diagram (4 states)
fprintf('Fig 7 - transition diagram (4 states)\n');
fig7 = plot_transition_diagram_AG(T, SessionNames, colors);
if saveFigs, save_figure_AG(fig7, OutputDir, 'Fig7_transition_diagram', figFormats); end

% Fig 7b: substate transition diagram (7 nodes incl. short/long)
fprintf('Fig 7b - substate transition diagram (7 nodes)\n');
fig7b = plot_substate_transition_diagram_AG(T_sub, SessionNames);
if saveFigs, save_figure_AG(fig7b, OutputDir, 'Fig7b_substate_transition_diagram', figFormats); end

% Fig 7c: substate temporal characterization (when in the recording do
% short/long bouts occur?)
fprintf('Fig 7c - substate temporal scatter\n');
totDur_h = nan(1, nSess);
for s = 1:nSess, totDur_h(s) = SInfo{s}.totDur_h; end
fig7c = plot_substate_temporal_AG(BF, SessionNames, LightOnIntervals, totDur_h);
if saveFigs, save_figure_AG(fig7c, OutputDir, 'Fig7c_substate_temporal', figFormats); end

% Fig 8: per-cycle stacked-bar composition (panel-d style)
fprintf('Fig 8 - cycle proportion bars\n');
fig8 = plot_cycle_proportion_bars_AG(C, SessionNames, colors);
if saveFigs, save_figure_AG(fig8, OutputDir, 'Fig8_cycle_proportion_bars', figFormats); end

% Fig 9: cycle-aligned z-scored power traces
fprintf('Fig 9 - cycle power traces\n');
fig9 = plot_cycle_power_traces_AG(CT, SessionNames);
if saveFigs, save_figure_AG(fig9, OutputDir, 'Fig9_cycle_power_traces', figFormats); end

% Fig 10: cycle-aligned spectrograms (x2 cycles)
if doCycleSpectro
    fprintf('Fig 10 - cycle spectrograms\n');
    fig10 = plot_cycle_spectrograms_AG(CT, SessionNames);
    if saveFigs, save_figure_AG(fig10, OutputDir, 'Fig10_cycle_spectrograms', figFormats); end
end

% Fig 11: cycle-by-cycle state-proportion correlations (N1 across cycles, REM vs N1, etc.)
fprintf('Fig 11 - cycle-state correlations\n');
fig11 = plot_state_correlations_AG(C, SessionNames, colors);
if saveFigs, save_figure_AG(fig11, OutputDir, 'Fig11_state_correlations', figFormats); end

% Fig 12: substate organization (short/long over recording + within-cycle + signature)
fprintf('Fig 12 - substate organization\n');
fig12 = plot_substate_organization_AG(ORG, BF, SessionNames, colors);
if saveFigs, save_figure_AG(fig12, OutputDir, 'Fig12_substate_organization', figFormats); end

% Fig 13: HPC theta / cycle regularity along the session
fprintf('Fig 13 - cycle regularity\n');
fig13 = plot_cycle_regularity_AG(REG, SessionNames);
if saveFigs, save_figure_AG(fig13, OutputDir, 'Fig13_cycle_regularity', figFormats); end

% Fig 14: substate mean spectra (key panel for the N1-short = N2 hypothesis)
fprintf('Fig 14 - substate mean spectra (per session)\n');
fig14 = plot_substate_spectra_AG(SS, SessionNames, 'per_session');
if saveFigs, save_figure_AG(fig14, OutputDir, 'Fig14_substate_spectra', figFormats); end

fprintf('Fig 14b - substate mean spectra (cross-session average)\n');
fig14b = plot_substate_spectra_AG(SS, SessionNames, 'summary');
if saveFigs, save_figure_AG(fig14b, OutputDir, 'Fig14b_substate_spectra_summary', figFormats); end

% Fig 15: light vs dark comparison
fprintf('Fig 15 - light vs dark comparison\n');
fig15 = plot_light_dark_comparison_AG(LD, SessionNames, colors);
if saveFigs, save_figure_AG(fig15, OutputDir, 'Fig15_light_dark_comparison', figFormats); end

% Fig 16: state pies (per session and cross-session summary)
fprintf('Fig 16 - state pies (per session)\n');
fig16 = plot_state_pies_AG(M, SessionNames, colors, 'per_session');
if saveFigs, save_figure_AG(fig16, OutputDir, 'Fig16_state_pies', figFormats); end

fprintf('Fig 16b - state pies (summary)\n');
fig16b = plot_state_pies_AG(M, SessionNames, colors, 'summary');
if saveFigs, save_figure_AG(fig16b, OutputDir, 'Fig16b_state_pies_summary', figFormats); end

% Fig 17: standalone full-recording hypnogram (runs from cached states; no SD)
fprintf('Fig 17 - full hypnogram\n');
fig17 = plot_hypnogram_full_AG(SInfo, SessionNames, colors, LightOnIntervals);
if saveFigs, save_figure_AG(fig17, OutputDir, 'Fig17_hypnogram_full', figFormats); end

% Fig 18: paper supplementary summary (8-panel cross-session figure)
fprintf('Fig 18 - paper supplementary summary\n');
fig18 = plot_paper_summary_AG(M, T, C, SS, LD, SessionNames, colors);
if saveFigs, save_figure_AG(fig18, OutputDir, 'Fig18_paper_supplementary_summary', figFormats); end

% =============================================================================
% PRINT A SUMMARY TABLE
% =============================================================================
fprintf('\n=== Summary ===\n');
fprintf('%-12s | %-7s | %-7s | %-7s | %-7s | %-7s\n', ...
    'Session','Total h','Wake h','N1 h','N2 h','REM h');
for s = 1:nSess
    fprintf('%-12s | %7.2f | %7.2f | %7.2f | %7.2f | %7.2f\n', ...
        SessionNames{s}, M{s}.recording_h, M{s}.dur_h(1), M{s}.dur_h(2), ...
        M{s}.dur_h(3), M{s}.dur_h(4));
end

fprintf('\n%-12s | %-9s | %-9s | %-9s | %-9s\n', ...
    'Session','%Rec Wake','%Rec N1','%Rec N2','%Rec REM');
for s = 1:nSess
    fprintf('%-12s | %9.1f | %9.1f | %9.1f | %9.1f\n', SessionNames{s}, ...
        100*M{s}.prop_total(1), 100*M{s}.prop_total(2), ...
        100*M{s}.prop_total(3), 100*M{s}.prop_total(4));
end

fprintf('\n%-12s | %-9s | %-9s | %-9s\n', 'Session','%Slp N1','%Slp N2','%Slp REM');
for s = 1:nSess
    fprintf('%-12s | %9.1f | %9.1f | %9.1f\n', SessionNames{s}, ...
        100*M{s}.prop_sleep(2), 100*M{s}.prop_sleep(3), 100*M{s}.prop_sleep(4));
end

fprintf('\nDone. Figures in: %s\n', OutputDir);
