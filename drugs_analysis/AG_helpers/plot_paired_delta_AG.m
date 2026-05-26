function plot_paired_delta_AG(delta_cell, DrugColors, DrugNames)
%PLOT_PAIRED_DELTA_AG  Per-drug paired deltas (after - before) as scatter + median.

hold on
xpos = 1:length(delta_cell);
for drug = 1:length(delta_cell)
    d = delta_cell{drug};
    d = d(isfinite(d));
    if isempty(d), continue, end
    jitter = (rand(size(d))-0.5)*0.18;
    scatter(xpos(drug)+jitter, d, 30, DrugColors{drug}, 'filled')
    plot([xpos(drug)-0.22 xpos(drug)+0.22], [nanmedian(d) nanmedian(d)], 'Color', DrugColors{drug}, 'LineWidth', 3)
end
yline_compat(0,'--r')
set(gca,'XTick',xpos,'XTickLabel',DrugNames)
xtickangle(20)
xlim([0.4 length(delta_cell)+0.6])
makepretty_BM2
end
