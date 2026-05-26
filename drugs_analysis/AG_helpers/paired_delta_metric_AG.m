function [delta_per, ci_lo, ci_hi, p_signrank] = paired_delta_metric_AG(before_vec, after_vec, n_boot)
%PAIRED_DELTA_METRIC_AG Per-session delta = after - before with bootstrap CI and signrank p.
% Inputs are vectors of length n_sessions.
% n_boot defaults to 5000.

if nargin < 3 || isempty(n_boot)
    n_boot = 5000;
end
before_vec = before_vec(:);
after_vec = after_vec(:);
good = isfinite(before_vec) & isfinite(after_vec);
delta_per = nan(size(before_vec));
delta_per(good) = after_vec(good) - before_vec(good);

ci_lo = NaN; ci_hi = NaN; p_signrank = NaN;
d = delta_per(good);
if length(d) < 3
    return
end

% bootstrap median CI
n = length(d);
boot_med = nan(n_boot,1);
for b = 1:n_boot
    idx = randi(n, n, 1);
    boot_med(b) = nanmedian(d(idx));
end
ci_lo = simple_percentile(boot_med, 2.5);
ci_hi = simple_percentile(boot_med, 97.5);

if exist('signrank', 'file') == 2
    try
        p_signrank = signrank(d);
    catch
        p_signrank = NaN;
    end
end
end
