function thr = derive_state_threshold_pre_AG(x, idx_before, method, q)
%DERIVE_STATE_THRESHOLD_PRE_AG  Threshold from pre-injection only.
% method: 'percentile' (default) | 'median' | 'bigaussian'.
% q: percentile in 0-100 (default 60). For 'bigaussian' the threshold is
% the intersection of the two Gaussians fit on the pre-injection histogram.

if nargin < 3 || isempty(method), method = 'percentile'; end
if nargin < 4 || isempty(q), q = 60; end

x = x(:); idx_before = idx_before(:);
xp = x(idx_before & isfinite(x));
if length(xp) < 30
    thr = nanmedian(xp);
    return
end

switch lower(method)
    case 'median'
        thr = nanmedian(xp);
    case 'percentile'
        thr = simple_percentile(xp, q);
    case 'bigaussian'
        try
            [Y, X] = hist(xp, max(50, round(sqrt(length(xp)))));
            Y = Y / sum(Y);
            if exist('createFit2gauss','file') == 2 && exist('intersect_gaussians','file') == 2
                cf = createFit2gauss(X, Y, []);
                a  = coeffvalues(cf);
                thr = intersect_gaussians(a(2), a(5), a(3), a(6));
                if ~isfinite(thr) || thr < min(xp) || thr > max(xp)
                    thr = nanmedian(xp);
                end
            else
                thr = nanmedian(xp);
            end
        catch
            thr = nanmedian(xp);
        end
    otherwise
        thr = nanmedian(xp);
end
end
