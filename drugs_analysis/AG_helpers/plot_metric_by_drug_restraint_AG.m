function plot_metric_by_drug_restraint_AG(T, fieldName, DrugColors)
%PLOT_METRIC_BY_DRUG_RESTRAINT_AG Plot session-level values split by restraint and drug.

hold on
restrLabels = {'head-fixed','freely-moving'};
xBase = [1 2 4 5];
allY = [];
for r = 1:2
    for drug = 1:2
        idx = T.drug_id == drug & strcmp(T.restraint, restrLabels{r});
        if ~ismember(fieldName, T.Properties.VariableNames)
            continue
        end
        y = T.(fieldName)(idx);
        y = y(isfinite(y));
        allY = [allY; y(:)];
        if isempty(y)
            continue
        end
        if r == 1
            x = xBase(drug);
        else
            x = xBase(drug + 2);
        end
        jitter = (rand(size(y))-0.5)*0.18;
        scatter(x + jitter, y, 30, DrugColors{drug}, 'filled')
        plot([x-0.22 x+0.22], [nanmedian(y) nanmedian(y)], 'Color', DrugColors{drug}, 'LineWidth', 3)
    end
end
yline_compat(0,'--r')
set(gca,'XTick',xBase,'XTickLabel',{'HF Sal','HF Atr','FM Sal','FM Atr'})
xtickangle(35)
xlim([0.3 5.7])
if ~isempty(allY)
    yl = ylim;
    if yl(1) == yl(2)
        ylim(yl + [-1 1]*0.1)
    end
end
makepretty_BM2
