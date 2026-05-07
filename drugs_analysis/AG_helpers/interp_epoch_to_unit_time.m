function y_interp = interp_epoch_to_unit_time(x, idx, n_points)
% Interpolate one epoch to a fixed number of points.
% This preserves the shape of the epoch but removes absolute duration.

x = x(:);
D = x(idx);
D = D(:);
if length(D) < 2
    y_interp = nan(1,n_points);
    return
end
y_interp = interp1(linspace(0,1,length(D)), D, linspace(0,1,n_points), 'linear');
end
