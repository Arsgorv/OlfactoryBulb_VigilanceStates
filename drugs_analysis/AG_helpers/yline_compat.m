function yline_compat(y, style)
% Compatibility wrapper. Uses yline if available, otherwise plots manually.
% Reference lines are hidden from legends.

if exist('yline', 'file')
    h = yline(y, style, 'LineWidth', 1.5);
    set(h, 'HandleVisibility', 'off')
else
    xl = xlim;
    h = plot(xl, [y y], style, 'LineWidth', 1.5);
    set(h, 'HandleVisibility', 'off')
    xlim(xl)
end
end
