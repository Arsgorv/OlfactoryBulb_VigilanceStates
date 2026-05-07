function plot_group_timecourse(x, DataCell, DrugColors)
% Median +/- SEM across sessions.

hold on
DrugLabels = {'Saline','Atropine'};
for drug = 1:2
    D = DataCell{drug};
    if isempty(D)
        continue
    end
    D = remove_empty_rows(D);
    M = nanmedian(D,1);
    E = nanstd(D,0,1)./sqrt(sum(any(isfinite(D),2)));
    if exist('shadedErrorBar', 'file')
        h = shadedErrorBar(x, M, E, '-k', 1);
        h.mainLine.Color = DrugColors{drug};
        h.mainLine.DisplayName = DrugLabels{drug};
        h.patch.FaceColor = DrugColors{drug};
        h.patch.HandleVisibility = 'off';
        h.edge(1).Color = DrugColors{drug};
        h.edge(2).Color = DrugColors{drug};
        h.edge(1).HandleVisibility = 'off';
        h.edge(2).HandleVisibility = 'off';
    else
        plot(x, M, 'Color', DrugColors{drug}, 'LineWidth', 2, 'DisplayName', DrugLabels{drug})
        h1 = plot(x, M+E, 'Color', DrugColors{drug}); set(h1,'HandleVisibility','off')
        h2 = plot(x, M-E, 'Color', DrugColors{drug}); set(h2,'HandleVisibility','off')
    end
end
legend('show')
xlabel('time after injection window (h)')
makepretty_BM2
end
