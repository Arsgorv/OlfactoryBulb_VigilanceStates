function r = corr_nan(x, y)
% Correlation after removing NaNs/Infs. Uses corrcoef to avoid toolbox assumptions.

x = x(:);
y = y(:);
good = isfinite(x) & isfinite(y);
if sum(good) < 5
    r = NaN;
    return
end
C = corrcoef(x(good), y(good));
r = C(1,2);
end
