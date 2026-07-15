function PS = compute_paper_stats_AG(M, C, T, LD, BF, SessionNames, animalMap)
% compute_paper_stats_AG  Aggregates per-session metrics into the descriptive
% and inferential stats needed for the paper figure caption + methods.
%
% INPUT
%   M, C, T, LD, BF   per-session metric cells (any may be empty)
%   SessionNames      1xN cellstr
%   animalMap         struct mapping session-name prefixes to animal IDs,
%                     e.g. struct('Tvo_','Tvorozhok','Mochi_','Mochi').
%                     If [], the first underscore-delimited token is used.
%
% OUTPUT struct PS:
%   nSessions, nAnimals, animalOfSession{}, sessionDur_h(:)
%   states            {'Wake','N1','N2','REM'}
%   perSession.<state>   struct with prop_total, prop_sleep, n_bouts,
%                        median_bout_dur_s  -- each a 1xnSess vector
%   perSession.cycleDur_min_median  1xnSess
%   perSession.nCycles              1xnSess
%   summary.<state>      mean, sd, median, q25, q75 for prop_total and
%                        prop_sleep across sessions
%   lightDark.<state>    propL, propD vectors + Wilcoxon p (signed-rank)
%   correlations.<pair>  R, p, n_cycles (pooled cycle-wise)
%   tests                cell array of test names actually applied
%
% Notes
%   - Tests are reported only when nSessions >= 4 (Wilcoxon signed-rank) or
%     n >= 3 (Pearson). Below that we just report descriptives.

PS.nSessions = numel(M);
PS.states    = {'Wake','N1','N2','REM'};

% --- Animal assignment ------------------------------------------------------
PS.animalOfSession = cell(1, PS.nSessions);
if nargin < 7 || isempty(animalMap)
    % Use first underscore-separated token
    for s = 1:PS.nSessions
        tok = strsplit(SessionNames{s}, '_');
        PS.animalOfSession{s} = tok{1};
    end
else
    fn = fieldnames(animalMap);
    for s = 1:PS.nSessions
        match = '';
        for k = 1:numel(fn)
            if startsWith(SessionNames{s}, fn{k})
                match = animalMap.(fn{k}); break
            end
        end
        if isempty(match)
            tok = strsplit(SessionNames{s}, '_');
            match = tok{1};
        end
        PS.animalOfSession{s} = match;
    end
end
PS.nAnimals = numel(unique(PS.animalOfSession));

% --- Per-session base metrics -----------------------------------------------
PS.sessionDur_h = nan(1, PS.nSessions);
for s = 1:PS.nSessions
    if ~isempty(M{s}), PS.sessionDur_h(s) = M{s}.recording_h; end
end

for i = 1:4
    sn = PS.states{i};
    prop_total = nan(1, PS.nSessions);
    prop_sleep = nan(1, PS.nSessions);
    nbouts     = nan(1, PS.nSessions);
    medBoutDur = nan(1, PS.nSessions);
    for s = 1:PS.nSessions
        if isempty(M{s}), continue, end
        prop_total(s) = M{s}.prop_total(i);
        prop_sleep(s) = M{s}.prop_sleep(i);
        nbouts(s)     = M{s}.nbouts(i);
        medBoutDur(s) = M{s}.bout_med(i);
    end
    PS.perSession.(sn).prop_total       = prop_total;
    PS.perSession.(sn).prop_sleep       = prop_sleep;
    PS.perSession.(sn).n_bouts          = nbouts;
    PS.perSession.(sn).median_bout_dur_s= medBoutDur;
end

% --- Cycle stats -------------------------------------------------------------
PS.perSession.cycleDur_min_median = nan(1, PS.nSessions);
PS.perSession.nCycles             = nan(1, PS.nSessions);
for s = 1:PS.nSessions
    if isempty(C{s}) || isempty(C{s}.cycleDur_min), continue, end
    PS.perSession.cycleDur_min_median(s) = median(C{s}.cycleDur_min);
    PS.perSession.nCycles(s)             = numel(C{s}.cycleDur_min);
end

% --- Cross-session summary statistics (mean/SD/median/IQR) -------------------
for i = 1:4
    sn = PS.states{i};
    for fld = {'prop_total','prop_sleep','n_bouts','median_bout_dur_s'}
        v = PS.perSession.(sn).(fld{1});
        PS.summary.(sn).(fld{1}) = describe_AG(v);
    end
end
PS.summary.cycleDur_min_median = describe_AG(PS.perSession.cycleDur_min_median);
PS.summary.nCycles             = describe_AG(PS.perSession.nCycles);
PS.summary.sessionDur_h        = describe_AG(PS.sessionDur_h);

% --- Light vs dark (paired Wilcoxon signed-rank) ----------------------------
PS.tests = {};
for i = 1:4
    sn = PS.states{i};
    propL = nan(1, PS.nSessions);
    propD = nan(1, PS.nSessions);
    for s = 1:PS.nSessions
        if isempty(LD{s}) || isempty(LD{s}.propTotal), continue, end
        propL(s) = LD{s}.propTotal(1, i);
        propD(s) = LD{s}.propTotal(2, i);
    end
    PS.lightDark.(sn).propL = propL;
    PS.lightDark.(sn).propD = propD;
    PS.lightDark.(sn).delta = propD - propL;
    n_paired = sum(~isnan(propL) & ~isnan(propD));
    if n_paired >= 4
        try
            p_signrank = signrank(propL(~isnan(propL) & ~isnan(propD)), ...
                                  propD(~isnan(propL) & ~isnan(propD)));
        catch
            p_signrank = NaN;
        end
        PS.lightDark.(sn).p_signrank = p_signrank;
        PS.lightDark.(sn).n          = n_paired;
        PS.lightDark.(sn).test       = 'Wilcoxon signed-rank';
    else
        PS.lightDark.(sn).p_signrank = NaN;
        PS.lightDark.(sn).n          = n_paired;
        PS.lightDark.(sn).test       = sprintf('descriptive only (n=%d)', n_paired);
    end
end
PS.tests{end+1} = 'Wilcoxon signed-rank (light vs dark proportion, paired by session)';

% --- Cycle-wise correlations (pooled cycles across sessions) ----------------
P_pool = zeros(0, 4);
for s = 1:PS.nSessions
    if isempty(C{s}) || isempty(C{s}.propByCycle), continue, end
    P_pool = [P_pool; squeeze(nanmean(C{s}.propByCycle, 2))]; %#ok<AGROW>
end
pairs = {2 3 'N1_N2'; 2 4 'N1_REM'; 3 4 'N2_REM'};
for k = 1:size(pairs,1)
    a = P_pool(:, pairs{k,1});
    b = P_pool(:, pairs{k,2});
    keep = ~isnan(a) & ~isnan(b);
    if sum(keep) >= 3
        [R, p] = corr(a(keep), b(keep), 'Type','Pearson');
        n = sum(keep);
    else
        R = NaN; p = NaN; n = sum(keep);
    end
    PS.correlations.(pairs{k,3}) = struct('R',R,'p',p,'n',n,'test','Pearson R, pooled cycles');
end
PS.tests{end+1} = 'Pearson R (state-proportion covariation, cycle-wise pooled)';

% --- Within-session paired N1/N2/REM proportion test (Friedman, if enough) --
if PS.nSessions >= 4
    Mat = nan(PS.nSessions, 3);
    for s = 1:PS.nSessions
        if isempty(M{s}), continue, end
        Mat(s,:) = M{s}.prop_sleep(2:4);
    end
    keep = all(~isnan(Mat), 2);
    if sum(keep) >= 4
        try
            p_friedman = friedman(Mat(keep,:), 1, 'off');
            PS.friedmanSleep.p = p_friedman;
            PS.friedmanSleep.n = sum(keep);
            PS.tests{end+1} = 'Friedman test (N1/N2/REM proportion of sleep, paired)';
        catch
            PS.friedmanSleep.p = NaN;
            PS.friedmanSleep.n = sum(keep);
        end
    end
end

end


function S = describe_AG(v)
v = v(:);
v = v(~isnan(v));
if isempty(v)
    S = struct('mean',NaN,'sd',NaN,'median',NaN,'q25',NaN,'q75',NaN,'n',0);
    return
end
S.mean   = mean(v);
S.sd     = std(v);
S.median = median(v);
S.q25    = quantile(v, 0.25);
S.q75    = quantile(v, 0.75);
S.n      = numel(v);
end
