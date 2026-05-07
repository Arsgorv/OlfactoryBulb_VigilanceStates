function y_grid = interp_relative_time(t, x, t0, rel_grid_sec)
% Interpolate x(t) onto a true relative-time grid around t0.
% rel_grid_sec is in seconds relative to t0.

t = t(:);
x = x(:);
y_grid = interp1(t - t0, x, rel_grid_sec(:), 'linear', NaN);
y_grid = y_grid(:)';
end
