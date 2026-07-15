function LD = compute_light_dark_stats_AG(SD, lightOnIntervals_h)
% compute_light_dark_stats_AG  State proportions and bout statistics during
% lights-on vs lights-off, for one session.
%
% INPUT
%   SD                    output of load_session_AG
%   lightOnIntervals_h    Nx2 matrix of recording-relative hours during which
%                         lights were ON. The complement within [0,totDur_h]
%                         is treated as "dark".
%
% OUTPUT struct LD:
%   conds         {'light','dark'}
%   stateNames    {'Wake','N1','N2','REM'}
%   propTotal     [2 x 4]  state fraction of L/D recording time
%   meanBoutDur_s [2 x 4]  mean bout duration (s)
%   medBoutDur_s  [2 x 4]  median bout duration (s)
%   nBouts        [2 x 4]  bout count
%   condDur_h     [2 x 1]  total L and D duration in this session
%
% Notes
%   - A bout is counted as belonging to a condition if its MIDPOINT falls in
%     that condition. Bouts that straddle a transition are assigned to one
%     side; we don't split them.
%   - propTotal sums to at most 1 per condition (the residual is unscored
%     time or noise).

LD.conds      = {'light','dark'};
LD.stateNames = {'Wake','N1','N2','REM'};

if isempty(lightOnIntervals_h)
    LD.propTotal     = nan(2,4);
    LD.meanBoutDur_s = nan(2,4);
    LD.medBoutDur_s  = nan(2,4);
    LD.nBouts        = nan(2,4);
    LD.condDur_h     = nan(2,1);
    return
end

T = SD.totDur_h;
darkIntervals_h = invert_intervals_AG(lightOnIntervals_h, T);

lightEp = intervals_h_to_set(lightOnIntervals_h);
darkEp  = intervals_h_to_set(darkIntervals_h);
condEp  = {lightEp, darkEp};

LD.condDur_h = nan(2,1);
LD.condDur_h(1) = sum(DurationEpoch(lightEp)) / 3600e4;
LD.condDur_h(2) = sum(DurationEpoch(darkEp))  / 3600e4;

states = {SD.states.Wake, SD.states.N1, SD.states.N2, SD.states.REM};

LD.propTotal     = nan(2,4);
LD.meanBoutDur_s = nan(2,4);
LD.medBoutDur_s  = nan(2,4);
LD.nBouts        = nan(2,4);

for c = 1:2
    cE = condEp{c};
    cDur_ts = sum(DurationEpoch(cE));
    for i = 1:4
        if isempty(states{i}) || cDur_ts == 0, continue, end
        % proportion of condition spent in state i
        LD.propTotal(c,i) = sum(DurationEpoch(and(states{i}, cE))) / cDur_ts;
        % bouts of state i whose midpoint falls in condition c
        st = Start(states{i}); en = Stop(states{i});
        if isempty(st), continue, end
        mid = (st + en)/2;
        sel = mid_in_intervals(mid, condEp{c});
        dur = (en(sel) - st(sel)) / 1e4;
        LD.nBouts(c,i)        = numel(dur);
        if ~isempty(dur)
            LD.meanBoutDur_s(c,i) = mean(dur);
            LD.medBoutDur_s(c,i)  = median(dur);
        end
    end
end
end


function E = intervals_h_to_set(M)
% Mx2 hours -> intervalSet in 1e-4 s
if isempty(M), E = intervalSet([],[]); return, end
st = M(:,1) * 3600e4;
en = M(:,2) * 3600e4;
keep = en > st;
E = intervalSet(st(keep), en(keep));
end


function out = invert_intervals_AG(I, T)
if isempty(I), out = [0 T]; return, end
I = sortrows(I);
out = zeros(0,2);
prevEnd = 0;
for k = 1:size(I,1)
    if I(k,1) > prevEnd
        out(end+1,:) = [prevEnd I(k,1)]; %#ok<AGROW>
    end
    prevEnd = max(prevEnd, I(k,2));
end
if prevEnd < T
    out(end+1,:) = [prevEnd T]; %#ok<AGROW>
end
end


function sel = mid_in_intervals(mid_ts, condEp)
% True for each mid_ts that falls inside condEp
cs = Start(condEp); ce = Stop(condEp);
sel = false(size(mid_ts));
for k = 1:numel(cs)
    sel = sel | (mid_ts >= cs(k) & mid_ts < ce(k));
end
end
