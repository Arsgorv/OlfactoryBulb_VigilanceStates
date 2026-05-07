function M = compute_state_metrics_AG(states, totalEpoch)
% compute_state_metrics_AG  Per-state composition and bout statistics.
%
% INPUT
%   states       struct with fields Wake, N1, N2, REM (intervalSet, units 1e-4 s)
%   totalEpoch   intervalSet covering the whole valid recording
%
% OUTPUT struct M:
%   names                  {'Wake','N1','N2','REM'}
%   dur_h                  [1x4] total time in each state, hours
%   prop_total             [1x4] fraction of recording (sums to <=1)
%   prop_sleep             [1x4] fraction of *sleep* (Wake = NaN, others sum to ~1)
%   nbouts                 [1x4] number of bouts per state
%   bouts                  cell {1x4} of bout-duration vectors (seconds)
%   bout_med, bout_q25, bout_q75   [1x4]   median/IQR of bout durations
%   recording_h            scalar, total recording duration (hours)
%
% Notes
%   - "prop_sleep" uses N1+N2+REM as denominator, *not* Sleep epoch from scoring,
%     so the three numbers always sum exactly to 1 (avoids confusion when
%     CleanStates.Sleep slightly differs from N1+N2+REM after cleaning).
%   - Bouts are returned in seconds.

names = {'Wake','N1','N2','REM'};
S     = {states.Wake, states.N1, states.N2, states.REM};

if nargin < 2 || isempty(totalEpoch)
    % Build a TotalEpoch from union of all states
    totalEpoch = intervalSet(0, 0);
    for i = 1:numel(S)
        totalEpoch = or(totalEpoch, S{i});
    end
end

recording_dur = sum(DurationEpoch(totalEpoch));   % 1e-4 s

dur_ts   = zeros(1,4);
nbouts   = zeros(1,4);
bouts    = cell(1,4);
for i = 1:4
    if isempty(S{i})
        continue
    end
    bouts{i}  = DurationEpoch(S{i})/1e4;          % s
    dur_ts(i) = sum(DurationEpoch(S{i}));
    nbouts(i) = length(Start(S{i}));
end

dur_h      = dur_ts / 3600e4;
prop_total = dur_ts ./ recording_dur;

sleep_dur = sum(dur_ts(2:4));                     % N1 + N2 + REM
if sleep_dur > 0
    prop_sleep      = nan(1,4);
    prop_sleep(2:4) = dur_ts(2:4) ./ sleep_dur;
else
    prop_sleep = nan(1,4);
end

bout_med = nan(1,4); bout_q25 = nan(1,4); bout_q75 = nan(1,4);
for i = 1:4
    if ~isempty(bouts{i})
        bout_med(i) = median(bouts{i});
        bout_q25(i) = quantile(bouts{i}, 0.25);
        bout_q75(i) = quantile(bouts{i}, 0.75);
    end
end

M.names       = names;
M.dur_h       = dur_h;
M.prop_total  = prop_total;
M.prop_sleep  = prop_sleep;
M.nbouts      = nbouts;
M.bouts       = bouts;
M.bout_med    = bout_med;
M.bout_q25    = bout_q25;
M.bout_q75    = bout_q75;
M.recording_h = recording_dur / 3600e4;
end
