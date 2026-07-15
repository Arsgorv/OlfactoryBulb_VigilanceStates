function plot_group_log2ratio_clean(AllSessions, RatioCell, specType, DrugColors, smoothBins)
hold on
DrugLabels = {'Saline','Atropine'};
ymin = 0; ymax = 0;
for drug = 1:2
    D = remove_empty_rows(RatioCell{drug});
    if isempty(D), continue, end
    f = get_frequency_vector(AllSessions, specType);
    if smoothBins > 1
        for ii = 1:size(D,1)
            row_i = D(ii,:);
            good = isfinite(row_i);
            if sum(good) > smoothBins
                row_i(good) = runmean(row_i(good)', smoothBins)';
            end
            D(ii,:) = row_i;
        end
    end
    n = size(D,1);
    if n >= 2
        h = shadedErrorBar_BM(f, D, {'-', 'Color', DrugColors{drug}, 'LineWidth', 2.5}, 1);
        try, h.mainLine.DisplayName = DrugLabels{drug}; end
        try, h.patch.FaceAlpha = 0.5; end
        hide_shaded_legend_extras_AG(h);
    else
        plot(f, nanmean(D,1), '-', 'Color', DrugColors{drug}, 'LineWidth', 2.5, 'DisplayName', DrugLabels{drug})
    end
    % Track data range so we can set ylim explicitly (avoids auto-clip when
    % legend or vlines force the axes to a weird range).
    Mline = nanmean(D,1);
    if all(~isfinite(Mline)), continue, end
    ymin = min(ymin, min(Mline) - 0.05);
    ymax = max(ymax, max(Mline) + 0.05);
end
yline_compat(0,'--r')
if ymax > ymin, ylim([ymin ymax]), end
legend('show','Location','best')
xlabel('Frequency (Hz)')
end
