function plot_group_timecourse_clean(x, DataCell, DrugColors, baselineValue)
hold on
DrugLabels = {'Saline','Atropine'};
for drug = 1:2
    D = remove_empty_rows(DataCell{drug});
    if isempty(D), continue, end
    n = size(D,1);
    if n >= 2
        h = shadedErrorBar_BM(x, D, {'-', 'Color', DrugColors{drug}, 'LineWidth', 2.5}, 1);
        try, h.mainLine.DisplayName = DrugLabels{drug}; end
        try, h.patch.FaceAlpha = 0.5; end                     % half-transparent
        hide_shaded_legend_extras_AG(h);
    else
        plot(x, nanmedian(D,1), '-', 'Color', DrugColors{drug}, 'LineWidth', 2.5, 'DisplayName', DrugLabels{drug})
    end
end
if ~isnan(baselineValue), yline_compat(baselineValue,'--r'), end
xlabel('time after injection (h)')
legend('show')
makepretty_BM2
end
