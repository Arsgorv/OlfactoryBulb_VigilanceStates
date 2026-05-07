function r_curve = lag_corr_curve(t, x, y, idx_epoch, lag_sec)
% Lagged correlation r(lag)=corr(x(t), y(t+lag)).
% Positive lag means y/CBV follows x/OB power.
% Important: y(t+lag) must remain inside the same epoch. Without this guard,
% pre-injection correlations at positive lags can accidentally use peri/post-
% injection CBV values, contaminating the pre-injection coupling estimate.

t = t(:);
x = x(:);
y = y(:);
idx_epoch = idx_epoch(:);
epoch_numeric = double(idx_epoch);
r_curve = nan(1,length(lag_sec));

for k = 1:length(lag_sec)
    y_shift = interp1(t, y, t + lag_sec(k), 'linear', NaN);
    idx_shift_epoch = interp1(t, epoch_numeric, t + lag_sec(k), 'nearest', 0) > 0.5;
    idx_use = idx_epoch & idx_shift_epoch(:) & isfinite(x) & isfinite(y_shift);
    r_curve(k) = corr_nan(x(idx_use), y_shift(idx_use));
end
end
