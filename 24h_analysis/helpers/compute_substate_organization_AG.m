function ORG = compute_substate_organization_AG(BF, C, totDur_h, timeBin_h)
% compute_substate_organization_AG  How short vs long bouts of N1/N2/REM are
% organized (a) across the recording and (b) within the sleep cycle.
%
% INPUT
%   BF          output of compute_bout_features_AG (must contain groupEpochs,
%               groupNames, boutStarts_h, X, featNames)
%   C           output of compute_sleep_cycles_AG (for cycle phase)
%   totDur_h    recording duration in hours
%   timeBin_h   bin width (h) for the "fraction long over recording" curve.
%               Default 2.
%
% OUTPUT struct ORG:
%   states              {'N1','N2','REM'}
%   timeBinCenters_h    1 x nTB
%   nShort{si}, nLong{si}   bout counts per time bin
%   fracLong{si}        nLong/(nShort+nLong) per time bin (NaN if empty)
%   phaseShort{si}      vector of within-cycle phase [0,1] for short bouts
%   phaseLong{si}       same for long bouts
%   sigFeatIdx(si)      index into BF.featNames of the discriminating feature
%   sigShort{si}, sigLong{si}   feature values short/long (for signature panel)
%   sigName{si}         label of the discriminating feature
%
% Notes
%   - Within-cycle phase uses each bout's temporal MIDPOINT and the cycle
%     (REM-end to REM-end) that contains it. Bouts outside any cycle (e.g.
%     during long wake before first sleep) are dropped from the phase arrays.

if nargin < 4 || isempty(timeBin_h), timeBin_h = 2; end

ORG.states   = {'N1','N2','REM'};
ORG.timeBin_h = timeBin_h;

edges_h = 0:timeBin_h:max(timeBin_h, ceil(totDur_h));
ORG.timeBinCenters_h = edges_h(1:end-1) + timeBin_h/2;

% Cycle bounds
cs = []; ce = [];
if ~isempty(C.cycleEpochs) && numel(Start(C.cycleEpochs)) > 0
    cs = Start(C.cycleEpochs);
    ce = Stop(C.cycleEpochs);
end

% Discriminating feature per state: OB delta for N1/N2, HPC theta/delta for REM
sigFeatByState = struct('N1', 'OB delta', 'N2', 'OB delta', 'REM', 'HPC theta/delta');

for si = 1:numel(ORG.states)
    sName  = ORG.states{si};
    gShort = find(strcmp(BF.groupNames, [sName ' short']), 1);
    gLong  = find(strcmp(BF.groupNames, [sName ' long']),  1);

    [tShort_h, midShort_ts] = bout_times_AG(BF, gShort);
    [tLong_h,  midLong_ts]  = bout_times_AG(BF, gLong);

    % (a) fraction long over recording time
    nS = histcounts(tShort_h, edges_h);
    nL = histcounts(tLong_h,  edges_h);
    ORG.nShort{si} = nS;
    ORG.nLong{si}  = nL;
    fl = nL ./ max(1, (nS + nL));
    fl(nS + nL == 0) = NaN;
    ORG.fracLong{si} = fl;

    % (b) within-cycle phase
    ORG.phaseShort{si} = bout_phase_AG(midShort_ts, cs, ce);
    ORG.phaseLong{si}  = bout_phase_AG(midLong_ts,  cs, ce);

    % (c) discriminating feature short vs long
    featLabel = sigFeatByState.(sName);
    fIdx = find(strcmp(BF.featNames, featLabel), 1);
    ORG.sigFeatIdx(si) = fIdx;
    ORG.sigName{si}    = featLabel;
    if ~isempty(gShort) && ~isempty(fIdx), ORG.sigShort{si} = BF.X{fIdx, gShort}; else, ORG.sigShort{si} = []; end
    if ~isempty(gLong)  && ~isempty(fIdx), ORG.sigLong{si}  = BF.X{fIdx, gLong};  else, ORG.sigLong{si}  = []; end
end

end


% =============================================================================
% local helpers
% =============================================================================
function [t_h, mid_ts] = bout_times_AG(BF, g)
t_h = []; mid_ts = [];
if isempty(g) || isempty(BF.groupEpochs{g}), return, end
st = Start(BF.groupEpochs{g});
if isempty(st), return, end
en = Stop(BF.groupEpochs{g});
t_h    = st / 3600e4;
mid_ts = (st + en) / 2;
end


function ph = bout_phase_AG(mid_ts, cs, ce)
ph = [];
if isempty(mid_ts) || isempty(cs), return, end
ph = nan(numel(mid_ts), 1);
for i = 1:numel(mid_ts)
    k = find(mid_ts(i) >= cs & mid_ts(i) < ce, 1);
    if ~isempty(k)
        ph(i) = (mid_ts(i) - cs(k)) / (ce(k) - cs(k));
    end
end
ph = ph(~isnan(ph));
end
