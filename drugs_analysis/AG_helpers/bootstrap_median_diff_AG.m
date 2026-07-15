function [lo, hi, dM] = bootstrap_median_diff_AG(x, y, nBoot, alpha)
%BOOTSTRAP_MEDIAN_DIFF_AG  Bootstrap CI for median(y) - median(x).
if nargin < 3 || isempty(nBoot), nBoot = 5000; end
if nargin < 4 || isempty(alpha), alpha = 0.05; end
x = x(isfinite(x)); y = y(isfinite(y));
if length(x) < 2 || length(y) < 2
    lo = NaN; hi = NaN; dM = NaN; return
end
dM = median(y) - median(x);
d = nan(nBoot,1);
nx = length(x); ny = length(y);
for k = 1:nBoot
    d(k) = median(y(randi(ny, ny, 1))) - median(x(randi(nx, nx, 1)));
end
lo = simple_percentile(d, 100*alpha/2);
hi = simple_percentile(d, 100*(1 - alpha/2));
end
