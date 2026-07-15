function plot_lag_group_clean(lag_min, LagCell, DrugColors)
hold on
DrugLabels = {'Saline','Atropine'};
for drug = 1:2
    D = remove_empty_rows(LagCell{drug});
    if isempty(D), continue, end
    n = size(D,1);
    if n >= 2
        h = shadedErrorBar_BM(lag_min, D, {'-', 'Color', DrugColors{drug}, 'LineWidth', 2.5}, 1);
        try, h.mainLine.DisplayName = DrugLabels{drug}; end
        hide_shaded_legend_extras_AG(h);
    else
        plot(lag_min, nanmean(D,1), '-', 'Color', DrugColors{drug}, 'LineWidth', 2.5, 'DisplayName', DrugLabels{drug})
    end
end
vline_compat(0,'--k'), yline_compat(0,'--r'), legend('show'), makepretty_BM2
end
