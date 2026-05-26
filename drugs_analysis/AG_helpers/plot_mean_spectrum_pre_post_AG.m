function plot_mean_spectrum_pre_post_AG(f, BeforeMat, AfterMat, color, lab)
%PLOT_MEAN_SPECTRUM_PRE_POST_AG  Group mean ± SE for pre/post mean spectra.
% BeforeMat, AfterMat: rows = sessions, columns = freqs (already aligned to f).
% color: per-drug color
% lab: per-drug label string

hold on
if isempty(BeforeMat) || isempty(AfterMat)
    return
end
M_b = nanmean(BeforeMat,1);
S_b = nanstd(BeforeMat,0,1)./sqrt(max(1,sum(any(isfinite(BeforeMat),2))));
M_a = nanmean(AfterMat,1);
S_a = nanstd(AfterMat,0,1)./sqrt(max(1,sum(any(isfinite(AfterMat),2))));

plot(f, M_b, '--', 'Color', color, 'LineWidth', 2.0, 'DisplayName', [lab ' before'])
plot(f, M_b+S_b, '--', 'Color', color, 'HandleVisibility','off')
plot(f, M_b-S_b, '--', 'Color', color, 'HandleVisibility','off')

plot(f, M_a, '-', 'Color', color, 'LineWidth', 2.5, 'DisplayName', [lab ' after'])
plot(f, M_a+S_a, '-', 'Color', color, 'HandleVisibility','off')
plot(f, M_a-S_a, '-', 'Color', color, 'HandleVisibility','off')
end
