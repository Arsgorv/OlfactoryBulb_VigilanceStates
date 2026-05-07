function y = detrend_nan(x)
% Detrend a vector while preserving NaN positions.

x = x(:);
y = nan(size(x));
good = isfinite(x);
if sum(good) < 5
    return
end
y(good) = detrend(x(good));
end
