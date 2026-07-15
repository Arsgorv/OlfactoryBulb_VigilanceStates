% Sleep24h_PaperFigure_AG
%
% Builds the final paper figure consolidating the headline results of the
% 24-h sleep analysis. Layout (top to bottom):
%
%   Row 1 (top half):
%     Left  - one example session: 24-h hypnogram, OB-mid spectrogram + OB
%             gamma trace, HPC-low spectrogram + theta/delta trace, OB-low
%             spectrogram + OB delta trace.
%     Right - two phase-space scatters (theta/delta vs OB gamma, theta/delta
%             vs OB delta), colored by state.
%
%   Row 2 :  pie all states + pie sleep + composition box + #bouts box +
%            bout-duration box + cycle-duration box.
%
%   Row 3 :  mean cycle composition (stacked area) + 24-h state evolution +
%            cleaned transition diagram.
%
%   Row 4 :  z-scored power along 2 cycles + cycle-wise R matrix + HPC
%            theta autocorrelogram.
%
% The script also prints a stats table (per session, summary, light/dark
% Wilcoxon, cycle-wise Pearson R) to console and saves text + CSV copies.
%
% RAM-light: loads cached metrics for every session and only the example
% session's full SD just-in-time.

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
SessionNames = {'T_0417', 'T_0424', 'T_0529', 'M_0521', 'M_0527', 'M_0604', 'M_0608'};

% Per-session light schedule (recording-relative hours of lights-ON intervals)
LightOnIntervals = {...
    [0 4.83; 19.83 24],... % T_0417
    [16.87 24.4],... % T_0424
    [0 11.9],... % T_0529
    [0 12.7],... % M_0521
    [0 11.9],... % M_0527
    [0 13],... % M_0604
    [0 10.83],... % M_0608    
    };


% Animal mapping: session-name prefix -> animal ID. Used for stats reporting.
animalMap.Tvo_   = 'Tvorozhok';
animalMap.Mochi_ = 'Mochi';

% Single-session example shown in row 1
ExampleSessionPath = 'Z:\Arsenii\OBG\Mochi\20260527_24h\ephys';
ExampleSessionName = 'Mochi_Session_0527';
ExampleLightOn     = [0 11.9];

OutputDir          = 'D:\Arsenii\GitHub\NeuroMeta\OlfactoryBulb_VigilanceStates\24h_analysis\figures';
cacheFilename      = 'Sleep24hMetrics_AG.mat';
CACHE_VERSION      = 3;

saveFigure   = true;
figFormats   = {'png','svg'};
figBaseName  = 'Sleep24h_PaperFigure';

% Transition-diagram cosmetic policy (lower threshold per request)
diagOpts.minProb             = 0.05;
diagOpts.requireAboveShuffle = true;
diagOpts.minDiffFromShuffle  = 0.01;

% Example session loader options. Skip everything we don't draw to keep RAM
% manageable; downsample the smoothed signals 10x (still smooth at the 24-h
% time scale of the paper figure).
exampleLoaderOpts = struct( ...
    'skipEMG',             true, ...
    'skipAccelero',        true, ...
    'skipOptionalSpectra', true, ...
    'downsampleSmooth',    10);

% =============================================================================
% PATH SETUP
% =============================================================================
thisDir   = fileparts(mfilename('fullpath'));
helperDir = fullfile(thisDir, 'helpers');
addpath(helperDir);

colors = state_colors_AG();
nSess  = numel(SessionPaths);

% =============================================================================
% PHASE 1: load cached metrics for all sessions (RAM-light)
% =============================================================================
fprintf('=== Loading cached metrics ===\n');
M = cell(1,nSess); C = cell(1,nSess); T = cell(1,nSess);
T_sub = cell(1,nSess); BF = cell(1,nSess); LD = cell(1,nSess);
SS = cell(1,nSess); CT = cell(1,nSess); REG = cell(1,nSess);
SInfo = cell(1,nSess);

for s = 1:nSess
    cachePath = fullfile(SessionPaths{s}, cacheFilename);
    SM = try_load_cache_AG(cachePath, CACHE_VERSION);
    if isempty(SM)
        error(['No cache for %s. Run Sleep24h_Analysis_Main_AG once for ' ...
               'this session to populate the cache.'], SessionNames{s});
    end
    fprintf('  [%s] OK (cache v%d, %d cycles)\n', SessionNames{s}, ...
        SM.cacheVersion, numel(SM.C.cycleDur_min));
    M{s}=SM.M; C{s}=SM.C; T{s}=SM.T; T_sub{s}=SM.T_sub; BF{s}=SM.BF;
    LD{s}=SM.LD; SS{s}=SM.SS; CT{s}=SM.CT; REG{s}=SM.REG;
    SInfo{s} = struct('name',SM.sessionName,'path',SM.sessionPath, ...
                      'states',SM.states,'totDur_h',SM.totDur_h,'totDur_ts',SM.totDur_ts);
    clear SM
end

% =============================================================================
% PHASE 2: compute stats + print table
% =============================================================================
fprintf('\n=== Computing stats ===\n');
PS = compute_paper_stats_AG(M, C, T, LD, BF, SessionNames, animalMap);
print_paper_stats_AG(PS, SessionNames, OutputDir);

% =============================================================================
% PHASE 3: load full SD for the example session ONLY
% =============================================================================
fprintf('\n=== Loading example session for row 1 ===\n');
SD_example = load_session_AG(ExampleSessionPath, ExampleSessionName, exampleLoaderOpts);

% =============================================================================
% PHASE 4: build the figure
% =============================================================================
fprintf('\n=== Drawing paper figure ===\n');
fig = figure('Color','w','Units','inches','Position',[0.5 0.5 12 14], ...
             'Name','Paper figure','NumberTitle','off');

% --- Row 1: example session overview (left) + phase space (right) -----------
row1.y = 0.55; row1.h = 0.42;
paper_panel_session_overview_AG(fig, [0.04 row1.y 0.60 row1.h], ...
    SD_example, colors, ExampleLightOn);
paper_panel_phase_space_AG(fig, [0.70 row1.y 0.27 row1.h], ...
    SD_example, colors);

% Free the full SD before drawing the rest (the cached metrics are enough)
% clear SD_example

% --- Row 2: composition + bouts + cycle duration ----------------------------
row2.y = 0.37; row2.h = 0.14;
paper_row2_composition_AG(fig, [0.03 row2.y 0.94 row2.h], M, C, PS, ...
                          SessionNames, colors);

% --- Row 3: cycle composition + state evolution + diagram + transition mat --
row3.y = 0.20; row3.h = 0.14;
paper_row3_dynamics_AG(fig, [0.03 row3.y 0.94 row3.h], C, T, M, SInfo, ...
                       LightOnIntervals, colors, diagOpts);

% --- Row 4: cycle power + R matrix + N2-REM scatter + autocorr composite ---
row4.y = 0.03; row4.h = 0.15;
paper_row4_cycle_dynamics_AG(fig, [0.03 row4.y 0.94 row4.h], CT, C, REG, ...
                             SessionNames, colors);

% --- Save -------------------------------------------------------------------
if saveFigure
    if ~exist(OutputDir,'dir'), mkdir(OutputDir); end
    save_figure_AG(fig, OutputDir, figBaseName, figFormats);
    fprintf('Saved paper figure to %s\n', OutputDir);
end

fprintf('Done.\n');
