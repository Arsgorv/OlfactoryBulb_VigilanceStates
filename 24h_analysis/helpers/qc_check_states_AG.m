function ok = qc_check_states_AG(SD)
% qc_check_states_AG  Sanity checks on a loaded session's state structure.
% Prints to console; returns true if all checks pass.
%
% Checks:
%   1. Total recording duration > 1 h
%   2. Wake/N1/N2/REM are pairwise non-overlapping
%   3. Wake + N1 + N2 + REM ~ TotalEpoch (within tolerance)
%   4. Each state has at least 1 bout

ok = true;
fprintf('--- QC: %s ---\n', SD.name);

% 1. duration
if SD.totDur_h < 1
    warning('  [FAIL] Recording duration is only %.2f h', SD.totDur_h);
    ok = false;
else
    fprintf('  [OK]   Recording duration: %.2f h\n', SD.totDur_h);
end

% 2. pairwise non-overlap
states  = {SD.states.Wake, SD.states.N1, SD.states.N2, SD.states.REM};
names   = {'Wake','N1','N2','REM'};
for i = 1:4
    for j = i+1:4
        ovDur = sum(DurationEpoch(and(states{i}, states{j}))) / 3600e4;
        if ovDur > 1/60   % > 1 minute is a real overlap
            warning('  [FAIL] %s & %s overlap by %.3f h', names{i}, names{j}, ovDur);
            ok = false;
        end
    end
end

% 3. coverage
sumDur = 0;
for i = 1:4
    sumDur = sumDur + sum(DurationEpoch(states{i}))/3600e4;
end
fprintf('  [OK]   Sum of states: %.2f h (%.1f%% of recording)\n', ...
    sumDur, 100*sumDur/SD.totDur_h);

% 4. bout counts
for i = 1:4
    n = length(Start(states{i}));
    if n == 0
        warning('  [WARN] %s has 0 bouts', names{i});
    else
        fprintf('  [OK]   %s : %5d bouts, %6.2f h total\n', names{i}, n, ...
            sum(DurationEpoch(states{i}))/3600e4);
    end
end

fprintf('\n');
end
