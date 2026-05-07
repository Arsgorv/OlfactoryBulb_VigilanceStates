function D = compute_24h_dynamics_AG(states, totDur_ts, binSize_s)
% compute_24h_dynamics_AG  Time-resolved state proportions across the recording.
%
% INPUT
%   states       struct with Wake, N1, N2, REM
%   totDur_ts    total recording duration in 1e-4 s (1 hour = 3600e4)
%   binSize_s    bin size in seconds (default 1800 = 30 min)
%
% OUTPUT struct D:
%   binCenters_h    1xNbins, bin centers in hours since recording start
%   binEdges_h      1x(Nbins+1)
%   propMatrix      [Nbins x 4]  fraction of bin in each state
%   names           {'Wake','N1','N2','REM'}
%
% Notes
%   - Last (partial) bin is dropped to avoid normalization issues.
%   - Each row sums to <= 1; the residual corresponds to "unscored" time
%     (TotalNoiseEpoch / gaps). Dropping it keeps proportions interpretable.

if nargin < 3 || isempty(binSize_s)
    binSize_s = 1800;   % 30 min
end

binSize_ts = binSize_s * 1e4;
nbins      = floor(totDur_ts / binSize_ts);
edges_ts   = (0:nbins) * binSize_ts;             % 1 x (nbins+1)
centers_ts = edges_ts(1:end-1) + binSize_ts/2;

names = {'Wake','N1','N2','REM'};
S     = {states.Wake, states.N1, states.N2, states.REM};

propMatrix = zeros(nbins, 4);
for b = 1:nbins
    binEp = intervalSet(edges_ts(b), edges_ts(b+1));
    for i = 1:4
        if ~isempty(S{i})
            propMatrix(b,i) = sum(DurationEpoch(and(S{i}, binEp))) / binSize_ts;
        end
    end
end

D.binCenters_h = centers_ts / 3600e4;
D.binEdges_h   = edges_ts   / 3600e4;
D.propMatrix   = propMatrix;
D.names        = names;
D.binSize_s    = binSize_s;
end
