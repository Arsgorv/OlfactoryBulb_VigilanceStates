function vline_compat(x, style)
% Compatibility wrapper. Uses xline if available, otherwise plots manually.
% Reference lines are hidden from legends.

if exist('xline', 'file')
    h = xline(x, style, 'LineWidth', 1.5);
    set(h, 'HandleVisibility', 'off')
else
    yl = ylim;
    h = plot([x x], yl, style, 'LineWidth', 1.5);
    set(h, 'HandleVisibility', 'off')
    ylim(yl)
end
end
