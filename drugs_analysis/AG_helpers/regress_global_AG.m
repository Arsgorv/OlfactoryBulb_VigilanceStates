function [residual, beta, global_signal] = regress_global_AG(x, varargin)
%REGRESS_GLOBAL_AG  Remove a global signal from x via OLS.
% global_signal = mean over all time-aligned reference signals (varargin).
% Returns residual = x - beta*global_signal (with intercept) on finite samples.
% NaN positions in x are preserved.

x = x(:);
if isempty(varargin)
    residual = x;
    beta = NaN;
    global_signal = nan(size(x));
    return
end

refs = nan(length(x), length(varargin));
for k = 1:length(varargin)
    v = varargin{k};
    refs(:,k) = v(:);
end
global_signal = nanmean(refs, 2);

good = isfinite(x) & isfinite(global_signal);
residual = nan(size(x));
if sum(good) < 5
    beta = NaN;
    return
end

Xr = [ones(sum(good),1), global_signal(good)];
beta_full = Xr \ x(good);
beta = beta_full(2);
residual(good) = x(good) - Xr * beta_full;
end
