function [idx_moving, smooth_acc_log] = compute_moving_idx_AG(MovAcctsd, Tref, smooth_sec, log_thresh)
%COMPUTE_MOVING_IDX_AG  Boolean Moving index aligned to Tref.
% Smooths log10(|MovAcctsd|), thresholds, and interpolates onto Tref.
% Mirrors the freely-moving Baptiste convention (threshold on log10 acc).
%
% Inputs:
%   MovAcctsd: tsd of accelerometer magnitude (1e-4 s timestamps)
%   Tref:      reference time vector (seconds)
%   smooth_sec: smoothing window in seconds (e.g., 3)
%   log_thresh: threshold on log10(acc); BM scripts use 6.7
%
% Outputs:
%   idx_moving:     logical(size(Tref)) = true when above threshold
%   smooth_acc_log: smoothed log10(acc) interpolated onto Tref

idx_moving = false(size(Tref));
smooth_acc_log = nan(size(Tref));

if isempty(MovAcctsd)
    return
end

t_acc = Range(MovAcctsd, 's');
t_acc = t_acc(:);
d_acc = Data(MovAcctsd);
d_acc = d_acc(:);
good = isfinite(d_acc) & d_acc > 0;
if sum(good) < 5
    return
end

dt = nanmedian(diff(t_acc));
if isnan(dt) || dt <= 0
    win = 1;
else
    win = max(1, round(smooth_sec/dt));
end

la = log10(d_acc);
la(~good) = NaN;
la_smooth = nan(size(la));
la_smooth(good) = runmean(la(good), win);

smooth_acc_log = interp1(t_acc, la_smooth, Tref(:), 'linear', NaN);
idx_moving = smooth_acc_log >= log_thresh;
idx_moving(~isfinite(smooth_acc_log)) = false;
end
