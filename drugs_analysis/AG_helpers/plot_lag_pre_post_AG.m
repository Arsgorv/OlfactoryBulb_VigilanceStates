function plot_lag_pre_post_AG(lag_min, BeforeCell, AfterCell, DrugColors)
hold on
DrugLabels = {'Saline','Atropine'};
for drug = 1:2
    Db = remove_empty_rows(BeforeCell{drug});
    Da = remove_empty_rows(AfterCell{drug});
    if ~isempty(Db) && size(Db,1) >= 2
        h = shadedErrorBar_BM(lag_min, Db, {'--', 'Color', DrugColors{drug}, 'LineWidth', 1.6}, 1);
        try, h.mainLine.DisplayName = [DrugLabels{drug} ' before']; end
        hide_shaded_legend_extras_AG(h);
    elseif ~isempty(Db)
        plot(lag_min, nanmean(Db,1), '--', 'Color', DrugColors{drug}, 'LineWidth', 1.6, 'DisplayName', [DrugLabels{drug} ' before'])
    end
    if ~isempty(Da) && size(Da,1) >= 2
        h = shadedErrorBar_BM(lag_min, Da, {'-', 'Color', DrugColors{drug}, 'LineWidth', 2.5}, 1);
        try, h.mainLine.DisplayName = [DrugLabels{drug} ' after']; end
        hide_shaded_legend_extras_AG(h);
    elseif ~isempty(Da)
        plot(lag_min, nanmean(Da,1), '-', 'Color', DrugColors{drug}, 'LineWidth', 2.5, 'DisplayName', [DrugLabels{drug} ' after'])
    end
end
vline_compat(0,'--k'), yline_compat(0,'--r')
legend('show','Location','best')
xlabel('CBV lag relative to OB (min)'), ylabel('r')
makepretty_BM2
end
