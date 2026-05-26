function p = block_perm_corr_p_AG(x, y, block_sec, dt_sec, n_perm)
%BLOCK_PERM_CORR_P_AG  Two-sided block-permutation p-value for Pearson r.
% Reshuffles y in contiguous blocks of length ~block_sec; recomputes r.
% Uses corrcoef so no Statistics Toolbox is required.

if nargin < 5 || isempty(n_perm), n_perm = 2000; end
x = x(:); y = y(:);
good = isfinite(x) & isfinite(y);
if sum(good) < 20
    p = NaN; return
end
xg = x(good); yg = y(good);
C = corrcoef(xg, yg);
r_obs = C(1,2);

block_n = max(2, round(block_sec/dt_sec));
n = length(yg);
n_blocks = ceil(n / block_n);

count = 0;
for k = 1:n_perm
    perm = randperm(n_blocks);
    y_perm = nan(size(yg));
    pos = 1;
    for b = 1:n_blocks
        src = perm(b);
        idx_src = ((src-1)*block_n + 1):min(src*block_n, n);
        idx_dst = pos:min(pos + length(idx_src) - 1, n);
        y_perm(idx_dst) = yg(idx_src);
        pos = pos + length(idx_src);
    end
    good2 = isfinite(y_perm);
    if sum(good2) < 10, continue, end
    Cperm = corrcoef(xg(good2), y_perm(good2));
    r_perm = Cperm(1,2);
    if abs(r_perm) >= abs(r_obs)
        count = count + 1;
    end
end
p = (count + 1) / (n_perm + 1);
end
