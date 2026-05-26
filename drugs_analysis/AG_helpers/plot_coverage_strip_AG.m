function plot_coverage_strip_AG(x, DataCell, DrugColors)
%PLOT_COVERAGE_STRIP_AG  Bar strip showing n sessions contributing per x-bin.

hold on
DrugLabels = {'Saline','Atropine'};
for drug = 1:length(DataCell)
    D = DataCell{drug};
    if isempty(D), continue, end
    n = sum(isfinite(D),1);
    plot(x, n, '-', 'Color', DrugColors{drug}, 'LineWidth', 1.8, 'DisplayName', DrugLabels{drug})
end
xlabel('time')
ylabel('n sess')
ylim([0 max(1, max(cellfun(@(D) max(sum(isfinite(D),1)), DataCell(~cellfun('isempty',DataCell)))))+1])
makepretty_BM2
end
