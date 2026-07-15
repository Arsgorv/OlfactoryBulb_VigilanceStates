function [SM, fromCache] = compute_or_load_session_metrics_AG(SD, P, forceRecompute, cachePath)
% compute_or_load_session_metrics_AG  Per-session metrics with on-disk caching.
%
% On first call, computes all the per-session analysis structs (M, D, C, T,
% T_sub, BF, CT, ORG, REG) and saves them next to the session data. On later
% calls, loads the cached file unless forceRecompute is true. Parameter
% changes are detected and reported, but the cached values are still used --
% pass forceRecompute=true to actually recompute when you change parameters.
%
% INPUT
%   SD              output of load_session_AG (loaded each run; cheap-ish)
%   P               struct of analysis parameters (see field list below)
%   forceRecompute  if true, ignore any cache and recompute. Default false.
%   cachePath       optional override of the cache file path. Default
%                   fullfile(SD.path, 'Sleep24hMetrics_AG.mat').
%
% OUTPUT
%   SM        struct with fields: M, D, C, T, T_sub, BF, CT, ORG, REG, params,
%             cacheVersion, computedAt
%   fromCache true if loaded from cache, false if (re)computed.
%
% Required fields of P
%   .binSize_s          (24-h dynamics bin width, seconds)
%   .mergeREM_s         (REM cleaning before cycle definition)
%   .dropREM_s
%   .nBinsCycle
%   .nBinsCycleTraces
%   .nShuffleTransition
%   .doCycleSpectro
%   .boutThresholds_min (struct: Wake/N1/N2/REM)
%   .substateTimeBin_h
%   .regularityParams   (struct, see compute_cycle_regularity_AG)

if nargin < 3 || isempty(forceRecompute), forceRecompute = false; end
if nargin < 4 || isempty(cachePath)
    cachePath = fullfile(SD.path, 'Sleep24hMetrics_AG.mat');
end

CACHE_VERSION = 3;   % v3: stores light-weight session info (states, totDur, name, path)
                     %     so SD-less downstream figures (hypnogram, etc.) work
fromCache = false;

% ------------------------------ Try the cache ------------------------------
if exist(cachePath, 'file') == 2 && ~forceRecompute
    try
        L = load(cachePath, 'SM');
        SM = L.SM;
        if isfield(SM,'cacheVersion') && SM.cacheVersion == CACHE_VERSION
            fromCache = true;
            % Report parameter differences (loud, but non-fatal)
            warn_param_diffs_AG(SM.params, P, SD.name);
            fprintf('  [%s] loaded metrics from cache (%s)\n', SD.name, cachePath);
            return
        else
            fprintf('  [%s] cache schema mismatch, recomputing\n', SD.name);
        end
    catch ME
        warning('Could not read cache for %s (%s). Recomputing.', SD.name, ME.message);
    end
end

% ------------------------------ Compute --------------------------------------
if isempty(SD)
    error(['compute_or_load_session_metrics_AG: cache miss for %s but SD was ' ...
        'not provided. Load the session first or pass forceRecompute=false.'], ...
        cachePath);
end
fprintf('  [%s] computing metrics...\n', SD.name);
SM.M     = compute_state_metrics_AG(SD.states, SD.states.TotalEpoch);
SM.D     = compute_24h_dynamics_AG(SD.states, SD.totDur_ts, P.binSize_s);
SM.C     = compute_sleep_cycles_AG(SD.states, P.mergeREM_s, P.dropREM_s, P.nBinsCycle);
SM.T     = compute_transition_matrix_AG(SD.states, P.nShuffleTransition);
SM.BF    = compute_bout_features_AG(SD, P.boutThresholds_min);
SM.T_sub = compute_transitions_cell_AG(SM.BF.groupEpochs, SM.BF.groupNames, ...
                                       P.nShuffleTransition);
SM.CT    = compute_cycle_traces_AG(SD, SM.C, P.nBinsCycleTraces, P.doCycleSpectro);
SM.ORG   = compute_substate_organization_AG(SM.BF, SM.C, SD.totDur_h, P.substateTimeBin_h);
SM.REG   = compute_cycle_regularity_AG(SD, P.regularityParams);
SM.SS    = compute_substate_spectra_AG(SD, SM.BF);
if isfield(P,'lightOnIntervals_h') && ~isempty(P.lightOnIntervals_h)
    SM.LD = compute_light_dark_stats_AG(SD, P.lightOnIntervals_h);
else
    SM.LD = struct('conds',{{'light','dark'}},'stateNames',{{'Wake','N1','N2','REM'}}, ...
        'propTotal',nan(2,4),'meanBoutDur_s',nan(2,4),'medBoutDur_s',nan(2,4), ...
        'nBouts',nan(2,4),'condDur_h',nan(2,1));
end

% Light-weight session info -- so SD-less figures (hypnogram, etc.) work
SM.states      = SD.states;        % intervalSet handles only; small
SM.totDur_h    = SD.totDur_h;
SM.totDur_ts   = SD.totDur_ts;

% bookkeeping
SM.params       = P;
SM.cacheVersion = CACHE_VERSION;
SM.computedAt   = datestr(now, 'yyyy-mm-dd HH:MM:SS');     %#ok<DATST>
SM.sessionName  = SD.name;
SM.sessionPath  = SD.path;

% ------------------------------ Save -----------------------------------------
try
    save(cachePath, 'SM', '-v7.3');
    fprintf('  [%s] cached metrics to %s\n', SD.name, cachePath);
catch ME
    warning('Could not save cache for %s (%s).', SD.name, ME.message);
end

end


function warn_param_diffs_AG(pCache, pNow, sessName)
% Print parameter changes between cached run and current call.
fnCache = fieldnames(pCache);
fnNow   = fieldnames(pNow);
allFn   = unique([fnCache; fnNow]);
diffs = {};
for k = 1:numel(allFn)
    f = allFn{k};
    a = []; b = [];
    if isfield(pCache, f), a = pCache.(f); end
    if isfield(pNow,   f), b = pNow.(f);   end
    if ~isequaln(a, b)
        diffs{end+1} = f; %#ok<AGROW>
    end
end
if ~isempty(diffs)
    fprintf('  [%s] WARN: cached params differ from current ([%s]). Pass forceRecompute=true to refresh.\n', ...
        sessName, strjoin(diffs, ', '));
end
end
