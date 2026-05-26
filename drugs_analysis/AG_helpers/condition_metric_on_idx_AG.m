function v = condition_metric_on_idx_AG(x, idx_period, idx_state)
%CONDITION_METRIC_ON_IDX_AG  Median of x over (idx_period & idx_state).

x = x(:); idx_period = idx_period(:); idx_state = idx_state(:);
mask = idx_period & idx_state & isfinite(x);
if sum(mask) < 10
    v = NaN;
else
    v = nanmedian(x(mask));
end
end
