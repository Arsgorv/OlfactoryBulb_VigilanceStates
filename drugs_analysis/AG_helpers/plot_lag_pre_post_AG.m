function plot_lag_pre_post_AG(lag_min, BeforeCell, AfterCell, DrugColors)
%PLOT_LAG_PRE_POST_AG  Side-by-side pre and post lag-correlation curves.

hold on
DrugLabels = {'Saline','Atropine'};
for drug = 1:2
    Db = remove_empty_rows(BeforeCell{drug});
    Da = remove_empty_rows(AfterCell{drug});
    if ~isempty(Db)
        Mb = nanmean(Db,1);
        Eb = nanstd(Db,0,1)./sqrt(size(Db,1));
        plot(lag_min, Mb, '--', 'Color', DrugColors{drug}, 'LineWidth', 1.6, 'DisplayName', [DrugLabels{drug} ' before'])
        plot(lag_min, Mb+Eb, '--', 'Color', DrugColors{drug}, 'HandleVisibility','off')
        plot(lag_min, Mb-Eb, '--', 'Color', DrugColors{drug}, 'HandleVisibility','off')
    end
    if ~isempty(Da)
        Ma = nanmean(Da,1);
        Ea = nanstd(Da,0,1)./sqrt(size(Da,1));
        plot(lag_min, Ma, '-', 'Color', DrugColors{drug}, 'LineWidth', 2.5, 'DisplayName', [DrugLabels{drug} ' after'])
        plot(lag_min, Ma+Ea, '-', 'Color', DrugColors{drug}, 'HandleVisibility','off')
        plot(lag_min, Ma-Ea, '-', 'Color', DrugColors{drug}, 'HandleVisibility','off')
    end
end
vline_compat(0,'--k')
yline_compat(0,'--r')
legend('show','Location','best')
xlabel('CBV lag relative to OB (min)')
ylabel('r')
makepretty_BM2
end
