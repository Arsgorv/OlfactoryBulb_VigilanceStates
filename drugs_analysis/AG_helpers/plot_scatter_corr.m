function plot_scatter_corr(x, y, col)
% Subsampled scatter with alpha-like small points. Correlation is shown in title elsewhere.

x = x(:); y = y(:);
good = isfinite(x) & isfinite(y);
x = x(good); y = y(good);
if length(x) > 1000
    step = ceil(length(x)/1000);
    x = x(1:step:end); y = y(1:step:end);
end
scatter(x, y, 8, col, 'filled')
grid on
end
