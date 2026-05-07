function lr = log_ratio_median(x, idx_before, idx_after)
% log(median(after)/median(before)). This is more stable than mean ratios
% for positive skewed signals and turns ratios into additive effects.

b = nanmedian(x(idx_before));
a = nanmedian(x(idx_after));
if b <= 0 || a <= 0 || isnan(b) || isnan(a)
    lr = NaN;
else
    lr = log(a) - log(b);
end
end
