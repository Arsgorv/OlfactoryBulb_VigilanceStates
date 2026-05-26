function brate = compute_breath_rate_AG(RespRate_tsd, Tref, smooth_sec)
%COMPUTE_BREATH_RATE_AG Resample existing RespRate_tsd onto Tref.
% RespRate_tsd is produced by MakeRespi_ForSession_Ferret and stored in
% SleepScoring_OBGamma.mat.
%
% Inputs:
%   RespRate_tsd: tsd in Hz, timestamps in 1e-4 s
%   Tref:         reference time vector (seconds)
%   smooth_sec:   smoothing window in seconds (e.g., 5)
%
% Output:
%   brate: vector(size(Tref)) of instantaneous breath rate, Hz

brate = nan(size(Tref));
if isempty(RespRate_tsd)
    return
end
t_r = Range(RespRate_tsd, 's');
t_r = t_r(:);
d_r = Data(RespRate_tsd);
d_r = d_r(:);
good = isfinite(d_r) & d_r > 0;
if sum(good) < 5
    return
end

dt = nanmedian(diff(t_r));
if isnan(dt) || dt <= 0
    win = 1;
else
    win = max(1, round(smooth_sec/dt));
end
d_s = nan(size(d_r));
d_s(good) = runmean(d_r(good), win);

brate = interp1(t_r, d_s, Tref(:), 'linear', NaN);
end
