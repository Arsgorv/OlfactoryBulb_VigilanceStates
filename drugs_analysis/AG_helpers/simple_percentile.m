function p = simple_percentile(x, q)
% Percentile without relying on Statistics Toolbox. q is between 0 and 100.

x = x(:);
x = x(isfinite(x));
if isempty(x)
    p = NaN;
    return
end
x = sort(x);
pos = 1 + (length(x)-1) * q/100;
lo = floor(pos);
hi = ceil(pos);
if lo == hi
    p = x(lo);
else
    p = x(lo) + (x(hi)-x(lo))*(pos-lo);
end
end
