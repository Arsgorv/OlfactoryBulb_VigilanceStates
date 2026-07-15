function plot_mean_spectrum_pre_post_AG(f, BeforeMat, AfterMat, color, lab)
% Mean +/- SEM with HALF-transparent patches via shadedErrorBar_BM.
hold on
if isempty(BeforeMat) || isempty(AfterMat), return, end
nb = sum(any(isfinite(BeforeMat),2));
na = sum(any(isfinite(AfterMat ),2));
if nb >= 2
    h = shadedErrorBar_BM(f, BeforeMat, {'--', 'Color', color, 'LineWidth', 2.0}, 1);
    try, h.mainLine.DisplayName = [lab ' before']; end
    try, h.patch.FaceAlpha = 0.5; end
    hide_shaded_legend_extras_AG(h);
else
    plot(f, nanmean(BeforeMat,1), '--', 'Color', color, 'LineWidth', 2.0, 'DisplayName', [lab ' before'])
end
if na >= 2
    h = shadedErrorBar_BM(f, AfterMat, {'-', 'Color', color, 'LineWidth', 2.5}, 1);
    try, h.mainLine.DisplayName = [lab ' after']; end
    try, h.patch.FaceAlpha = 0.5; end
    hide_shaded_legend_extras_AG(h);
else
    plot(f, nanmean(AfterMat,1), '-', 'Color', color, 'LineWidth', 2.5, 'DisplayName', [lab ' after'])
end
end
