function print_paper_stats_AG(PS, SessionNames, outDir)
% print_paper_stats_AG  Pretty-print the per-session and summary stats from
% compute_paper_stats_AG to the console; also save a plain-text and a CSV
% copy under outDir/paper_stats_<timestamp>.{txt,csv} if outDir is non-empty.
%
% INPUT
%   PS            output of compute_paper_stats_AG
%   SessionNames  1xN cellstr
%   outDir        directory to save text + CSV. Pass [] to skip.

if nargin < 3, outDir = ''; end

% --- Build output as a cell of lines so we can both print and save -----------
L = {};
L{end+1} = sprintf('==================== PAPER STATS ====================');
L{end+1} = sprintf('n_sessions = %d   n_animals = %d', PS.nSessions, PS.nAnimals);
uA = unique(PS.animalOfSession);
L{end+1} = sprintf('animals    = %s', strjoin(uA, ', '));
L{end+1} = sprintf('recording  : mean = %.2f h  median = %.2f h  range = [%.2f, %.2f]', ...
    PS.summary.sessionDur_h.mean, PS.summary.sessionDur_h.median, ...
    min(PS.sessionDur_h), max(PS.sessionDur_h));
L{end+1} = '';

% --- Per-session table ------------------------------------------------------
L{end+1} = '---- Table 1. Per-session metrics ----';
header = sprintf('%-20s | %-8s | %-6s | %-6s | %-6s | %-6s | %-6s | %-7s | %-7s', ...
    'Session','Animal','Dur(h)','%Wake','%N1','%N2','%REM','#Cyc','MedCyc(min)');
L{end+1} = header;
L{end+1} = repmat('-', 1, numel(header));
for s = 1:PS.nSessions
    L{end+1} = sprintf('%-20s | %-8s | %6.2f | %6.1f | %6.1f | %6.1f | %6.1f | %7d | %7.1f', ...
        SessionNames{s}, PS.animalOfSession{s}, PS.sessionDur_h(s), ...
        100*PS.perSession.Wake.prop_total(s), ...
        100*PS.perSession.N1.prop_total(s), ...
        100*PS.perSession.N2.prop_total(s), ...
        100*PS.perSession.REM.prop_total(s), ...
        PS.perSession.nCycles(s), ...
        PS.perSession.cycleDur_min_median(s));
end
L{end+1} = '';

% --- Cross-session summary ----------------------------------------------------
L{end+1} = '---- Table 2. Cross-session summary (% of recording) ----';
L{end+1} = sprintf('%-6s | %-15s | %-15s | %-15s | %-5s', ...
    'State','mean +/- SD','median [IQR]','% of sleep','n');
L{end+1} = repmat('-', 1, 75);
for i = 1:4
    sn = PS.states{i};
    sT = PS.summary.(sn).prop_total;
    sS = PS.summary.(sn).prop_sleep;
    L{end+1} = sprintf('%-6s | %5.1f +/- %5.1f | %5.1f [%5.1f, %5.1f] | %5.1f +/- %5.1f | %5d', ...
        sn, 100*sT.mean, 100*sT.sd, 100*sT.median, 100*sT.q25, 100*sT.q75, ...
        100*sS.mean, 100*sS.sd, sT.n);
end
L{end+1} = '';

% --- Bout statistics summary -------------------------------------------------
L{end+1} = '---- Table 3. Bout statistics (median bout duration, s) ----';
L{end+1} = sprintf('%-6s | %-15s | %-15s | %-15s | %-5s', ...
    'State','#bouts/session','median(s)','IQR(s)','n');
L{end+1} = repmat('-', 1, 75);
for i = 1:4
    sn = PS.states{i};
    sn_nb = PS.summary.(sn).n_bouts;
    sn_md = PS.summary.(sn).median_bout_dur_s;
    L{end+1} = sprintf('%-6s | %5.0f +/- %5.0f | %5.1f +/- %5.1f | [%5.1f, %5.1f] | %5d', ...
        sn, sn_nb.mean, sn_nb.sd, sn_md.median, sn_md.sd, sn_md.q25, sn_md.q75, sn_md.n);
end
L{end+1} = '';

% --- Light vs Dark ----------------------------------------------------------
L{end+1} = '---- Table 4. Light vs Dark (% of condition, paired by session) ----';
L{end+1} = sprintf('%-6s | %-13s | %-13s | %-10s | %-5s | %-30s', ...
    'State','Light mean','Dark mean','p-value','n','test');
L{end+1} = repmat('-', 1, 95);
for i = 1:4
    sn = PS.states{i};
    LD_ = PS.lightDark.(sn);
    L{end+1} = sprintf('%-6s | %5.1f +/- %5.1f | %5.1f +/- %5.1f | %10.4g | %5d | %-30s', ...
        sn, 100*nanmean(LD_.propL), 100*nanstd(LD_.propL), ...
        100*nanmean(LD_.propD), 100*nanstd(LD_.propD), ...
        LD_.p_signrank, LD_.n, LD_.test);
end
L{end+1} = '';

% --- Cycle-wise state correlations -----------------------------------------
L{end+1} = '---- Table 5. Cycle-wise state-proportion correlations (pooled) ----';
L{end+1} = sprintf('%-10s | %-7s | %-10s | %-6s | %-25s', 'Pair','R','p','n','test');
L{end+1} = repmat('-', 1, 75);
pairs = fieldnames(PS.correlations);
for k = 1:numel(pairs)
    c = PS.correlations.(pairs{k});
    L{end+1} = sprintf('%-10s | %+6.3f | %10.4g | %6d | %-25s', ...
        pairs{k}, c.R, c.p, c.n, c.test);
end
L{end+1} = '';

% --- Tests used -------------------------------------------------------------
L{end+1} = '---- Tests applied in this paper figure ----';
for k = 1:numel(PS.tests)
    L{end+1} = sprintf('  - %s', PS.tests{k});
end
L{end+1} = '';
L{end+1} = sprintf(['NOTE: with n_animals = %d, between-animal inferential stats are ' ...
                   'not meaningful; light/dark tests are within-session paired.'], PS.nAnimals);
L{end+1} = '======================================================';

% --- Print ------------------------------------------------------------------
for k = 1:numel(L), fprintf('%s\n', L{k}); end

% --- Save -------------------------------------------------------------------
if ~isempty(outDir)
    if ~exist(outDir,'dir'), mkdir(outDir); end
    stamp = datestr(now,'yyyymmdd_HHMMSS'); %#ok<DATST>
    fid = fopen(fullfile(outDir, sprintf('paper_stats_%s.txt', stamp)), 'w');
    if fid > 0
        for k = 1:numel(L), fprintf(fid, '%s\n', L{k}); end
        fclose(fid);
    end
    % CSV (per-session table only)
    csvF = fopen(fullfile(outDir, sprintf('paper_stats_%s.csv', stamp)), 'w');
    if csvF > 0
        fprintf(csvF, 'Session,Animal,RecDur_h,Wake_pct,N1_pct,N2_pct,REM_pct,nCycles,medCycle_min\n');
        for s = 1:PS.nSessions
            fprintf(csvF, '%s,%s,%.2f,%.2f,%.2f,%.2f,%.2f,%d,%.2f\n', ...
                SessionNames{s}, PS.animalOfSession{s}, PS.sessionDur_h(s), ...
                100*PS.perSession.Wake.prop_total(s), ...
                100*PS.perSession.N1.prop_total(s), ...
                100*PS.perSession.N2.prop_total(s), ...
                100*PS.perSession.REM.prop_total(s), ...
                PS.perSession.nCycles(s), PS.perSession.cycleDur_min_median(s));
        end
        fclose(csvF);
    end
end

end
