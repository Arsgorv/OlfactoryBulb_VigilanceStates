function T = compute_transitions_cell_AG(epochs, names, nShuffle)
% compute_transitions_cell_AG  Transition matrix for an arbitrary number of
% mutually-exclusive epoch groups, with optional bout-shuffle baseline.
% Adjacency is determined by chronological order of bouts.
%
% INPUT
%   epochs     1xN cell of intervalSet, mutually exclusive (no overlap)
%   names      1xN cellstr labels
%   nShuffle   number of bout-label shuffles for the null. Default 0.
%
% OUTPUT struct T:
%   names              1xN cellstr
%   counts             [NxN]   transition counts (no self-transitions)
%   probs              [NxN]   row-normalized
%   shuffleProbs       [NxNxnShuffle] (or [])
%   pSign              sign of (probs - median(shuffle))
%
% Used to compute transitions over substates (Wake / N1s / N1l / N2s / N2l /
% REMs / REMl), but works for any cell of intervalSets.

if nargin < 3 || isempty(nShuffle), nShuffle = 0; end
nS = numel(epochs);
T.names = names;

% --- Build a chronologically-sorted bout sequence ---------------------------
labels = [];
starts = [];
for i = 1:nS
    if isempty(epochs{i}), continue, end
    sti = Start(epochs{i});
    if isempty(sti), continue, end
    labels = [labels; i*ones(numel(sti),1)]; %#ok<AGROW>
    starts = [starts; sti];                  %#ok<AGROW>
end
if isempty(labels)
    T.counts = zeros(nS); T.probs = zeros(nS);
    T.shuffleProbs = []; T.pSign = nan(nS); return
end
[~, sidx] = sort(starts);
labels = labels(sidx);

% --- Observed transitions ---------------------------------------------------
T.counts = zeros(nS);
for k = 1:numel(labels)-1
    a = labels(k); b = labels(k+1);
    if a == b, continue, end
    T.counts(a,b) = T.counts(a,b) + 1;
end
T.probs = row_normalize(T.counts);

% --- Shuffle baseline -------------------------------------------------------
if nShuffle <= 0
    T.shuffleProbs = []; T.pSign = nan(nS); return
end
T.shuffleProbs = zeros(nS, nS, nShuffle);
for s = 1:nShuffle
    seq = labels(randperm(numel(labels)));
    cnt = zeros(nS);
    for k = 1:numel(seq)-1
        a = seq(k); b = seq(k+1);
        if a == b, continue, end
        cnt(a,b) = cnt(a,b) + 1;
    end
    T.shuffleProbs(:,:,s) = row_normalize(cnt);
end
T.pSign = sign(T.probs - nanmedian(T.shuffleProbs, 3));
end


function P = row_normalize(M)
rs = sum(M,2); rs(rs==0) = NaN;
P = bsxfun(@rdivide, M, rs);
P(isnan(P)) = 0;
end
