function C = compute_sleep_cycles_AG(states, mergeREM_s, dropREM_s, nBinsCycle)
% compute_sleep_cycles_AG  Define sleep cycles (REM-end to REM-end) and compute
% time-warped state proportions across each cycle.
%
% Cycle definition follows Baptiste's lab convention (SLeepCycles_Ferret_BM):
% REM episodes are first cleaned (merge close, drop short), then each cycle
% spans from the end of one REM to the end of the next.
%
% INPUT
%   states         struct with Wake, N1, N2, REM
%   mergeREM_s     merge REM bouts closer than this (default 180 s)
%   dropREM_s      drop REM bouts shorter than this (default 60 s)
%   nBinsCycle     number of equal bins per cycle (default 20)
%
% OUTPUT struct C:
%   cycleEpochs        intervalSet of all cycles
%   cycleDur_min       1xNcycles
%   propByCycle        [Ncycles x nBinsCycle x 4]  state proportion per bin
%   meanProp           [nBinsCycle x 4]  averaged across cycles
%   names              {'Wake','N1','N2','REM'}
%   cycleStartTime_h   1xNcycles, hours since recording start
%
% Notes
%   - Only complete cycles are returned. If <2 REM episodes survive cleaning,
%     all outputs are empty / NaN.
%   - Binning is *proportional* to each cycle's own duration, so bin edges
%     never overflow past the cycle end. The last bin is always entirely
%     within the cycle, which means at progress=1 (= REM end of next REM)
%     the bin should be ~100% REM by construction.

if nargin < 2 || isempty(mergeREM_s),  mergeREM_s = 180; end
if nargin < 3 || isempty(dropREM_s),   dropREM_s  = 60;  end
if nargin < 4 || isempty(nBinsCycle),  nBinsCycle = 20;  end

C.names = {'Wake','N1','N2','REM'};
REM = mergeCloseIntervals(states.REM, mergeREM_s*1e4);
REM = dropShortIntervals(REM,         dropREM_s *1e4);

remEnds = Stop(REM);
if numel(remEnds) < 2
    C.cycleEpochs      = intervalSet([],[]);
    C.cycleDur_min     = [];
    C.propByCycle      = [];
    C.meanProp         = nan(nBinsCycle,4);
    C.cycleStartTime_h = [];
    return
end

cycleStarts = remEnds(1:end-1);
cycleEnds   = remEnds(2:end);
C.cycleEpochs      = intervalSet(cycleStarts, cycleEnds);
C.cycleDur_min     = (cycleEnds - cycleStarts) / 60e4;
C.cycleStartTime_h = cycleStarts / 3600e4;

S = {states.Wake, states.N1, states.N2, states.REM};
nCycles = numel(cycleStarts);

C.propByCycle = nan(nCycles, nBinsCycle, 4);
edgesNorm = linspace(0, 1, nBinsCycle+1);    % 21 edges -> 20 bins

for c = 1:nCycles
    smallEp = subset(C.cycleEpochs, c);
    t0      = Start(smallEp);
    durTs   = Stop(smallEp) - t0;
    if durTs <= 0, continue, end

    for b = 1:nBinsCycle
        bStart = t0 + edgesNorm(b)   * durTs;
        bEnd   = t0 + edgesNorm(b+1) * durTs;
        binEp  = intervalSet(bStart, bEnd);
        binDur = bEnd - bStart;
        if binDur <= 0, continue, end
        for i = 1:4
            if ~isempty(S{i})
                C.propByCycle(c, b, i) = ...
                    sum(DurationEpoch(and(S{i}, binEp))) / binDur;
            end
        end
    end
end

C.meanProp = squeeze(nanmean(C.propByCycle, 1));   % nBinsCycle x 4
end
