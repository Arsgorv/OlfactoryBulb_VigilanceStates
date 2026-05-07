function CT = compute_cycle_traces_AG(SD, C, nBins, doSpectro)
% compute_cycle_traces_AG  Time-warp smooth traces (and optionally
% spectrograms) onto sleep-cycle progress (0 = previous REM end, 1 = next
% REM end). Z-scores each cycle independently, so each row reflects within-
% cycle dynamics rather than absolute power.
%
% INPUT
%   SD          output of load_session_AG
%   C           output of compute_sleep_cycles_AG
%   nBins       number of warped time bins per cycle (default 100)
%   doSpectro   true to also compute cycle-aligned mean spectrograms.
%               Spectro fields are nFreqs x nBins (averaged across cycles).
%               Default true.
%
% OUTPUT struct CT:
%   nBins, nCycles
%   gamma_z, theta_z, delta_z   [nCycles x nBins]  z-scored per cycle
%   gamma_mean, theta_mean, delta_mean      [1 x nBins]
%   gamma_sem,  theta_sem,  delta_sem
%   spec.OBgamma   {.f, .M}    .M is nFreqs x nBins, mean log10 power
%   spec.HPClow    same
%   spec.OBlow     same
%
% Notes
%   - z-scoring is across-cycle (per cycle, on its own data) for the trace
%     means, so the displayed mean reflects normalized dynamics.
%   - spectrogram interpolation uses subsampling for speed.

if nargin < 3 || isempty(nBins),     nBins = 100;  end
if nargin < 4 || isempty(doSpectro), doSpectro = true; end

CT.nBins   = nBins;
CT.nCycles = 0;

if isempty(C.cycleEpochs) || numel(Start(C.cycleEpochs)) == 0
    CT.gamma_z = []; CT.theta_z = []; CT.delta_z = [];
    CT.gamma_mean = nan(1,nBins); CT.theta_mean = nan(1,nBins); CT.delta_mean = nan(1,nBins);
    CT.gamma_sem  = nan(1,nBins); CT.theta_sem  = nan(1,nBins); CT.delta_sem  = nan(1,nBins);
    CT.spec = struct();
    return
end

nC = length(Start(C.cycleEpochs));
CT.nCycles = nC;

xq = linspace(0,1,nBins);

% --- traces ------------------------------------------------------------------
gammaI = nan(nC, nBins);
thetaI = nan(nC, nBins);
deltaI = nan(nC, nBins);

for c = 1:nC
    ep = subset(C.cycleEpochs, c);
    [gammaI(c,:)] = warp_signal(SD.sig.SmoothGamma,    ep, xq);
    [thetaI(c,:)] = warp_signal(SD.sig.SmoothTheta,    ep, xq);
    [deltaI(c,:)] = warp_signal(SD.sig.SmoothDelta_OB, ep, xq);
end

% z-score per cycle (each row independently)
CT.gamma_z = zscore_rowwise(gammaI);
CT.theta_z = zscore_rowwise(thetaI);
CT.delta_z = zscore_rowwise(deltaI);

CT.gamma_mean = nanmean(CT.gamma_z, 1);
CT.theta_mean = nanmean(CT.theta_z, 1);
CT.delta_mean = nanmean(CT.delta_z, 1);
CT.gamma_sem  = sem(CT.gamma_z);
CT.theta_sem  = sem(CT.theta_z);
CT.delta_sem  = sem(CT.delta_z);

% --- spectrograms ------------------------------------------------------------
CT.spec = struct();
if doSpectro
    CT.spec.OBgamma = warp_spectro(SD.spec.OBgamma, C.cycleEpochs, xq);
    CT.spec.HPClow  = warp_spectro(SD.spec.HPClow,  C.cycleEpochs, xq);
    CT.spec.OBlow   = warp_spectro(SD.spec.OBlow,   C.cycleEpochs, xq);
end

end


% =============================================================================
% local helpers
% =============================================================================
function vq = warp_signal(sig, ep, xq)
vq = nan(size(xq));
if isempty(sig), return, end
d = Data(Restrict(sig, ep));
if isempty(d) || numel(d) < 2, return, end
xs = linspace(0,1,numel(d));
vq = interp1(xs, d, xq, 'linear');
end


function S = warp_spectro(SP, cycleEpochs, xq)
S = struct('f',[],'M',[]);
if isempty(SP), return, end
nC = length(Start(cycleEpochs));
% Subsample raw spectro for speed
fullR = Range(SP.tsd);
fullD = Data(SP.tsd);
ds = max(1, round(numel(fullR) / 5e4));
SPsub = tsd(fullR(1:ds:end), fullD(1:ds:end, :));
nF = numel(SP.f);
M = nan(nC, nF, numel(xq));
for c = 1:nC
    ep = subset(cycleEpochs, c);
    d  = Data(Restrict(SPsub, ep));   % nT x nF
    if size(d,1) < 2, continue, end
    xs = linspace(0,1,size(d,1));
    for f = 1:nF
        M(c,f,:) = interp1(xs, d(:,f), xq, 'linear');
    end
end
S.f = SP.f;
S.M = squeeze(nanmean(log10(M + eps), 1));   % nFreqs x nBins
end


function Z = zscore_rowwise(M)
Z = nan(size(M));
for i = 1:size(M,1)
    r = M(i,:);
    mu = nanmean(r);
    sd = nanstd(r);
    if sd > 0
        Z(i,:) = (r - mu) / sd;
    end
end
end


function s = sem(M)
s = nanstd(M, 0, 1) ./ sqrt(sum(~isnan(M), 1));
end
