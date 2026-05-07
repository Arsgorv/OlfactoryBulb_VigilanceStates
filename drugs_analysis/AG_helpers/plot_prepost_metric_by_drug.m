function plot_prepost_metric_by_drug(T, fieldBefore, fieldAfter, DrugColors)
% Paired before/after values within each session, plotted separately by drug.

hold on
xpos = [1 2 4 5];
labels = {'Saline before','Saline after','Atropine before','Atropine after'};
for drug = 1:2
    idx = T.drug_id == drug;
    before = T.(fieldBefore)(idx);
    after = T.(fieldAfter)(idx);
    good = isfinite(before) & isfinite(after);
    before = before(good);
    after = after(good);
    if drug == 1
        xb = xpos(1); xa = xpos(2);
    else
        xb = xpos(3); xa = xpos(4);
    end
    for i = 1:length(before)
        plot([xb xa], [before(i) after(i)], '-', 'Color', 0.65*DrugColors{drug} + 0.35*[1 1 1], 'LineWidth', 0.7)
    end
    scatter(xb*ones(size(before)), before, 18, DrugColors{drug}, 'filled')
    scatter(xa*ones(size(after)), after, 18, DrugColors{drug}, 'filled')
    plot([xb xa], [nanmedian(before) nanmedian(after)], '-', 'Color', DrugColors{drug}, 'LineWidth', 4)
end
yline_compat(0,'--r')
set(gca,'XTick',xpos,'XTickLabel',labels)
xtickangle(35)
xlim([0.4 5.6])
makepretty_BM2
end
