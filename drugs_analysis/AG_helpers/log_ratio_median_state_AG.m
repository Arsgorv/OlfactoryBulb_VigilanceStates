function lr = log_ratio_median_state_AG(x, idx_before, idx_after, idx_state)
%LOG_RATIO_MEDIAN_STATE_AG  log(median(after & state)/median(before & state)).

x = x(:); idx_state = idx_state(:);
b_idx = idx_before(:) & idx_state & isfinite(x);
a_idx = idx_after(:)  & idx_state & isfinite(x);
if sum(b_idx) < 10 || sum(a_idx) < 10
    lr = NaN; return
end
b = nanmedian(x(b_idx));
a = nanmedian(x(a_idx));
if b <= 0 || a <= 0 || isnan(b) || isnan(a)
    lr = NaN;
else
    lr = log(a) - log(b);
end
end
