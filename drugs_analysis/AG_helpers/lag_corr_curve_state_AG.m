function r_curve = lag_corr_curve_state_AG(t, x, y, idx_epoch, idx_state, lag_sec)
%LAG_CORR_CURVE_STATE_AG  Same as lag_corr_curve, but additionally restricted
% to a state mask. Useful for within-Wake coupling.

t = t(:); x = x(:); y = y(:);
idx_epoch = idx_epoch(:); idx_state = idx_state(:);
mask = idx_epoch & idx_state;
mask_num = double(mask);
r_curve = nan(1,length(lag_sec));
for k = 1:length(lag_sec)
    y_shift = interp1(t, y, t + lag_sec(k), 'linear', NaN);
    state_shift = interp1(t, mask_num, t + lag_sec(k), 'nearest', 0) > 0.5;
    idx_use = mask & state_shift(:) & isfinite(x) & isfinite(y_shift);
    r_curve(k) = corr_nan(x(idx_use), y_shift(idx_use));
end
end
