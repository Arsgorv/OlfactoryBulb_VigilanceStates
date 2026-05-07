function y = smooth_by_time(x, t, smooth_sec)
% Smooth x using a window expressed in seconds.
% Uses runmean to stay close to existing pipeline. If smooth_sec<=0, no smoothing.

x = x(:);
t = t(:);
if isempty(x) || smooth_sec <= 0 || length(x) < 3
    y = x;
    return
end

dt = nanmedian(diff(t));
if isnan(dt) || dt <= 0
    win = 1;
else
    win = max(1, round(smooth_sec/dt));
end

y = runmean(x, win);
y = y(:);
end
