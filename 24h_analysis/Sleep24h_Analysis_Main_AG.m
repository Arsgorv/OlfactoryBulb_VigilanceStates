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

clear all  %#ok<CLALL>
close all

% =============================================================================
% USER INPUTS
% =============================================================================
SessionPaths = { ...
    'Z:\Arsenii\OBG\Tvorozhok\20260417_24h\ephys', ...  
    'Z:\Arsenii\OBG\Tvorozhok\20260424_24h\ephys'};      

SessionNames = {'Session_0417', 'Session_0424'};

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

% Bout-duration thresholds (minutes) splitting "short" from "long" bouts
% per state. Defaults match the trough between modes seen in your bout-
% duration histograms. Pass [] for any state to skip the split.
boutThresholds_min.N1   = 0.5;     % 30 s
boutThresholds_min.N2   = 2.0;     % 120 s
boutThresholds_min.REM  = 2.5;     % 150 s
boutThresholds_min.Wake = [];      % keep Wake as a single group

% Light schedule, per session, as Nx2 matrices of LIGHTS-ON intervals in
% recording-relative hours. Pass [] to skip shading. Use the convention:
% recording starts at hour 0; lights ON during the rows of the matrix.
%
% Session_0417: started 15:10. Lights ON until 20:00 (4h50min after start),
% OFF until 11:00 next day (19h50min after start), ON until end (~23.95 h).
%
% Session_0424: started 19:41. Lights OFF for the first 1012 min = 16.875 h,
% then ON until end (~24.37 h).
LightOnIntervals = { ...
    [ 0    4.83;  19.83  24.0 ], ...     % Session_0417
    [16.87 24.4              ]};         % Session_0424

% =============================================================================
% PATH SETUP
% =============================================================================
thisDir   = fileparts(mfilename('fullpath'));
helperDir = fullfile(thisDir, 'helpers');
addpath(helperDir);

if saveFigs && ~exist(OutputDir,'dir'), mkdir(OutputDir); end

% =============================================================================
% LOAD AND QC
% =============================================================================
nSess = numel(SessionPaths);
SD    = cell(1, nSess);
fprintf('=== Loading %d sessions ===\n', nSess);
for s = 1:nSess
    fprintf('Loading %s ...\n', SessionNames{s});
    SD{s} = load_session_AG(SessionPaths{s}, SessionNames{s});
end

fprintf('\n=== QC ===\n');
qcOK = true(1, nSess);
for s = 1:nSess
    qcOK(s) = qc_check_states_AG(SD{s});
end
if ~all(qcOK)
    warning('One or more sessions failed QC. Inspect above before trusting figures.');
end

colors = state_colors_AG();

% =============================================================================
% COMPUTE METRICS
% =============================================================================
fprintf('\n=== Computing metrics ===\n');
M     = cell(1, nSess);   % per-state composition + bouts
D     = cell(1, nSess);   % 24-h dynamics
C     = cell(1, nSess);   % sleep cycles
T     = cell(1, nSess);   % 4-state transitions
T_sub = cell(1, nSess);   % 7-state (substate) transitions
BF    = cell(1, nSess);   % per-bout features (short/long)
CT    = cell(1, nSess);   % cycle-aligned traces + spectrograms

for s = 1:nSess
    fprintf('  %s\n', SessionNames{s});
    M{s}     = compute_state_metrics_AG(SD{s}.states, SD{s}.states.TotalEpoch);
    D{s}     = compute_24h_dynamics_AG(SD{s}.states, SD{s}.totDur_ts, binSize_s);
    C{s}     = compute_sleep_cycles_AG(SD{s}.states, mergeREM_s, dropREM_s, nBinsCycle);
    T{s}     = compute_transition_matrix_AG(SD{s}.states, nShuffleTransition);
    BF{s}    = compute_bout_features_AG(SD{s}, boutThresholds_min);
    T_sub{s} = compute_transitions_cell_AG(BF{s}.groupEpochs, BF{s}.groupNames, ...
                                           nShuffleTransition);
    CT{s}    = compute_cycle_traces_AG(SD{s}, C{s}, nBinsCycleTraces, doCycleSpectro);
end

% =============================================================================
% FIGURES
% =============================================================================
fprintf('\n=== Drawing figures ===\n');

% Fig 1 (per session): scoring sanity overview
for s = 1:nSess
    fprintf('Fig 1 - overview for %s\n', SessionNames{s});
    if numel(LightOnIntervals) >= s
        loi = LightOnIntervals{s};
    else
        loi = [];
    end
    fig1 = plot_session_overview_AG(SD{s}, colors, loi);
    if saveFigs
        save_figure_AG(fig1, OutputDir, ...
            sprintf('Fig1_overview_%s', SessionNames{s}), figFormats);
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
for s = 1:nSess, totDur_h(s) = SD{s}.totDur_h; end
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
