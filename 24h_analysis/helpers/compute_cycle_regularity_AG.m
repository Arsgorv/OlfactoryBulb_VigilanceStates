function REG = compute_cycle_regularity_AG(SD, params)
% compute_cycle_regularity_AG  Sliding-window autocorrelation of the HPC
% theta/delta signal to quantify how regular the REM/cycle rhythm is across
% the recording. The autocorrelation of theta/delta peaks at the dominant
% REM-recurrence period (= sleep-cycle length), so:
%   - the autocorrelation value at the expected cycle lag = "regularity score"
%   - the lag of the first autocorrelation peak = dominant cycle period
%
% INPUT
%   SD       output of load_session_AG
%   params   optional struct with fields (defaults in parentheses):
%              .sig          'HPCtheta' | 'OBdelta' | 'OBgamma'  ('HPCtheta')
%              .binSize_s    bin width for the coarse time series      (60)
%              .window_h     sliding window length                     (3)
%              .step_h       step between windows                      (1)
%              .maxLag_min   max lag in the autocorrelogram            (60)
%              .targetLag_min lag (min) for the regularity score       (25)
%              .minPeakLag_min minimum lag for first-peak detection    (8)
%
% OUTPUT struct REG:
%   lag_min          1 x (2*maxLagBins+1)  lag axis in minutes
%   winCenter_h      1 x nWin               window-center time in hours
%   acorr            (nLag x nWin)          two-sided autocorrelation
%   regScore         1 x nWin               autocorr at targetLag_min
%   firstPeakLag     1 x nWin               lag (min) of first autocorr peak
%   targetLag_min, sigName

if nargin < 2, params = struct(); end
def = struct('sig','HPCtheta','binSize_s',60,'window_h',3,'step_h',1, ...
             'maxLag_min',60,'targetLag_min',25,'minPeakLag_min',8);
fn = fieldnames(def);
for k = 1:numel(fn)
    if ~isfield(params, fn{k}), params.(fn{k}) = def.(fn{k}); end
end

% --- pick signal ------------------------------------------------------------
switch lower(params.sig)
    case 'hpctheta', sig = SD.sig.SmoothTheta;     REG.sigName = 'HPC theta/delta';
    case 'obdelta',  sig = SD.sig.SmoothDelta_OB;  REG.sigName = 'OB delta';
    case 'obgamma',  sig = SD.sig.SmoothGamma;     REG.sigName = 'OB gamma';
    otherwise,       sig = SD.sig.SmoothTheta;     REG.sigName = 'HPC theta/delta';
end
REG.targetLag_min = params.targetLag_min;

if isempty(sig)
    REG.lag_min = []; REG.winCenter_h = []; REG.acorr = [];
    REG.regScore = []; REG.firstPeakLag = [];
    return
end

% --- bin into coarse time series (fast, via accumarray) ---------------------
binTs = params.binSize_s * 1e4;
nBin  = floor(SD.totDur_ts / binTs);
R = Range(sig); D = Data(sig);
binIdx = floor(R / binTs) + 1;
valid  = binIdx >= 1 & binIdx <= nBin & ~isnan(D);
binned = accumarray(binIdx(valid), D(valid), [nBin 1], @mean, NaN);
binned = fillmissing(binned, 'linear', 'EndValues', 'nearest');

% --- sliding-window autocorrelation -----------------------------------------
maxLagBins = round(params.maxLag_min * 60 / params.binSize_s);
winBins    = round(params.window_h  * 3600 / params.binSize_s);
stepBins   = round(params.step_h    * 3600 / params.binSize_s);
minPeakBin = round(params.minPeakLag_min * 60 / params.binSize_s);
targetBin  = round(params.targetLag_min  * 60 / params.binSize_s);

if winBins > nBin
    winBins = nBin;
end
winStarts = 1:stepBins:(nBin - winBins + 1);
if isempty(winStarts), winStarts = 1; end
nWin = numel(winStarts);

lagBins = -maxLagBins:maxLagBins;
REG.lag_min      = lagBins * params.binSize_s / 60;
REG.winCenter_h  = nan(1, nWin);
REG.acorr        = nan(numel(lagBins), nWin);
REG.regScore     = nan(1, nWin);
REG.firstPeakLag = nan(1, nWin);

for w = 1:nWin
    seg = binned(winStarts(w):winStarts(w) + winBins - 1);
    c   = autocorr_coeff_AG(seg, maxLagBins);     % two-sided, c(maxLagBins+1)=lag0
    REG.acorr(:, w)   = c;
    REG.winCenter_h(w) = (winStarts(w) + winBins/2) * params.binSize_s / 3600;

    % regularity score at target lag
    posIdx = maxLagBins + 1 + targetBin;
    if posIdx <= numel(c), REG.regScore(w) = c(posIdx); end

    % first peak in positive lags beyond minPeakBin
    cpos = c(maxLagBins+1 : end);          % lag 0 .. maxLag
    for L = minPeakBin+1 : numel(cpos)-1
        if cpos(L) > cpos(L-1) && cpos(L) >= cpos(L+1)
            REG.firstPeakLag(w) = (L-1) * params.binSize_s / 60;
            break
        end
    end
end

end


function c = autocorr_coeff_AG(x, maxLag)
% Normalized two-sided autocorrelation (c(0)=1), no toolbox dependency.
x = x(:);
x = x - mean(x);
N = numel(x);
denom = sum(x.^2);
c0 = zeros(maxLag+1, 1);
if denom == 0
    c0(:) = NaN;
else
    for L = 0:maxLag
        c0(L+1) = sum(x(1:N-L) .* x(1+L:N)) / denom;
    end
end
c = [flipud(c0(2:end)); c0];   % -maxLag .. maxLag
end
