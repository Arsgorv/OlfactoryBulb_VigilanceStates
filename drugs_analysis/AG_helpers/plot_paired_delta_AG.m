function plot_paired_delta_AG(delta_cell, DrugColors, DrugNames)
cleaned = cell(size(delta_cell));
for k = 1:length(delta_cell)
    d = delta_cell{k}; d = d(isfinite(d));
    if isempty(d), d = NaN; end
    cleaned{k} = d;
end
if exist('MakeSpreadAndBoxPlot3_SB','file') == 2
    try
        MakeSpreadAndBoxPlot3_SB(cleaned, DrugColors, 1:length(cleaned), DrugNames, 'showpoints', 1, 'paired', 0);
    catch ME
        warning('MakeSpreadAndBoxPlot3_SB failed in plot_paired_delta_AG: %s', ME.message)
        hold on
        for k = 1:length(cleaned)
            d = cleaned{k}; d = d(isfinite(d));
            if isempty(d), continue, end
            scatter(k+(rand(size(d))-0.5)*0.18, d, 30, DrugColors{k}, 'filled')
            plot([k-0.22 k+0.22], [nanmedian(d) nanmedian(d)], 'Color', DrugColors{k}, 'LineWidth', 3)
        end
        set(gca,'XTick',1:length(cleaned),'XTickLabel',DrugNames); xtickangle(20)
    end
else
    hold on
    for k = 1:length(cleaned)
        d = cleaned{k}; d = d(isfinite(d));
        if isempty(d), continue, end
        scatter(k+(rand(size(d))-0.5)*0.18, d, 30, DrugColors{k}, 'filled')
        plot([k-0.22 k+0.22], [nanmedian(d) nanmedian(d)], 'Color', DrugColors{k}, 'LineWidth', 3)
    end
    set(gca,'XTick',1:length(cleaned),'XTickLabel',DrugNames); xtickangle(20)
end
yline_compat(0,'--r')
makepretty_BM2
end
