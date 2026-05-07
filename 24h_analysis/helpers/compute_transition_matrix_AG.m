function T = compute_transition_matrix_AG(states, nShuffle)
% compute_transition_matrix_AG  State transition counts and probabilities,
% with an optional bout-shuffle baseline.
%
% INPUT
%   states     struct with Wake, N1, N2, REM (intervalSet, 1e-4 s)
%   nShuffle   number of bout-order shuffles for null distribution (default 0)
%
% OUTPUT struct T:
%   names              {'Wake','N1','N2','REM'}
%   counts             [4x4]  raw transition counts (no self-transitions)
%   probs              [4x4]  row-normalized transition probabilities
%   shuffleProbs       [4 x 4 x nShuffle]   null distribution (if nShuffle>0)
%   pTwoSided          [4x4]  two-sided p-values from shuffle (NaN if nShuffle=0)
%   pSign              [4x4]  +1 if observed > shuffle median, -1 otherwise
%
% Method
%   - "From state i to state j" counted via transEpoch (Baptiste convention).
%   - Bout-shuffle baseline: keep the *durations* and the *labels* of all bouts
%     but randomize the order of bouts. Self-transitions still excluded by
%     skipping consecutive same-label entries.

if nargin < 2 || isempty(nShuffle), nShuffle = 0; end

names = {'Wake','N1','N2','REM'};
S = {states.Wake, states.N1, states.N2, states.REM};
nStates = 4;

% --- Observed transitions ----------------------------------------------------
T.names  = names;
T.counts = zeros(nStates);
[aft_cell, ~] = transEpoch(S{:});
for i = 1:nStates
    for j = 1:nStates
        if i == j, continue, end
        try
            T.counts(i,j) = length(Start(aft_cell{i,j}));
        catch
            T.counts(i,j) = 0;
        end
    end
end
T.probs = row_normalize(T.counts);

% --- Bout-shuffle baseline ---------------------------------------------------
if nShuffle <= 0
    T.shuffleProbs = [];
    T.pTwoSided    = nan(nStates);
    T.pSign        = nan(nStates);
    return
end

% Build the *sequence* of bouts: each bout = (state idx, duration in 1e-4 s)
allLabels = [];
allDur    = [];
for i = 1:nStates
    if isempty(S{i}), continue, end
    sti = Start(S{i});
    eni = Stop(S{i});
    allLabels = [allLabels; i*ones(numel(sti),1)]; %#ok<AGROW>
    allDur    = [allDur;    eni - sti];            %#ok<AGROW>
end

if isempty(allLabels)
    T.shuffleProbs = [];
    T.pTwoSided    = nan(nStates);
    T.pSign        = nan(nStates);
    return
end

% In the observed sequence, bouts may interleave; we approximate the null
% distribution by drawing labels at random *with the empirical label counts*,
% which preserves marginals and randomizes order.
T.shuffleProbs = zeros(nStates, nStates, nShuffle);
for s = 1:nShuffle
    perm    = randperm(numel(allLabels));
    seq     = allLabels(perm);
    cnt     = zeros(nStates);
    for k = 1:numel(seq)-1
        a = seq(k); b = seq(k+1);
        if a == b, continue, end
        cnt(a,b) = cnt(a,b) + 1;
    end
    T.shuffleProbs(:,:,s) = row_normalize(cnt);
end

medShuf = nanmedian(T.shuffleProbs, 3);
T.pSign = sign(T.probs - medShuf);
T.pTwoSided = nan(nStates);
for i = 1:nStates
    for j = 1:nStates
        null_ij = squeeze(T.shuffleProbs(i,j,:));
        obs_ij  = T.probs(i,j);
        % two-sided empirical p-value
        T.pTwoSided(i,j) = ...
            mean(abs(null_ij - nanmedian(null_ij)) >= abs(obs_ij - nanmedian(null_ij)));
    end
end

end


function P = row_normalize(M)
rs = sum(M,2);
rs(rs == 0) = NaN;
P = bsxfun(@rdivide, M, rs);
P(isnan(P)) = 0;
end
