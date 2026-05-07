function plot_group_timecourse_clean(x, DataCell, DrugColors, baselineValue)
% Paper-style group time course: individual sessions faintly, median thick.

hold on
DrugLabels = {'Saline','Atropine'};
for drug = 1:2
    D = remove_empty_rows(DataCell{drug});
    if isempty(D)
        continue
    end
    for i = 1:size(D,1)
        plot(x, D(i,:), 'Color', 0.65*DrugColors{drug} + 0.35*[1 1 1], 'LineWidth', 0.5, 'HandleVisibility','off')
    end
    M = nanmedian(D,1);
    E = nanstd(D,0,1)./sqrt(sum(any(isfinite(D),2)));
    if exist('shadedErrorBar', 'file')
        h = shadedErrorBar(x, M, E, '-k', 1);
        h.mainLine.Color = DrugColors{drug};
        h.mainLine.LineWidth = 2.5;
        h.mainLine.DisplayName = DrugLabels{drug};
        h.patch.FaceColor = DrugColors{drug};
        h.patch.FaceAlpha = 0.18;
        h.patch.HandleVisibility = 'off';
        h.edge(1).HandleVisibility = 'off';
        h.edge(2).HandleVisibility = 'off';
    else
        plot(x, M, 'Color', DrugColors{drug}, 'LineWidth', 2.5, 'DisplayName', DrugLabels{drug})
        plot(x, M+E, 'Color', DrugColors{drug}, 'HandleVisibility','off')
        plot(x, M-E, 'Color', DrugColors{drug}, 'HandleVisibility','off')
    end
end
if ~isnan(baselineValue)
    yline_compat(baselineValue,'--r')
end
xlabel('time after injection (h)')
legend('show')
makepretty_BM2
end
