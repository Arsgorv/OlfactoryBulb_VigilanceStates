function plot_lag_group_clean(lag_min, LagCell, DrugColors)
% Paper-style lagged correlation curves.

hold on
DrugLabels = {'Saline','Atropine'};
for drug = 1:2
    D = remove_empty_rows(LagCell{drug});
    if isempty(D)
        continue
    end
    M = nanmean(D,1);
    E = nanstd(D,0,1)./sqrt(size(D,1));
    if exist('shadedErrorBar', 'file')
        h = shadedErrorBar(lag_min, M, E, '-k', 1);
        h.mainLine.Color = DrugColors{drug};
        h.mainLine.LineWidth = 2.5;
        h.mainLine.DisplayName = DrugLabels{drug};
        h.patch.FaceColor = DrugColors{drug};
        h.patch.FaceAlpha = 0.18;
        h.patch.HandleVisibility = 'off';
        h.edge(1).HandleVisibility = 'off';
        h.edge(2).HandleVisibility = 'off';
    else
        plot(lag_min, M, 'Color', DrugColors{drug}, 'LineWidth', 2.5, 'DisplayName', DrugLabels{drug})
        plot(lag_min, M+E, 'Color', DrugColors{drug}, 'HandleVisibility','off')
        plot(lag_min, M-E, 'Color', DrugColors{drug}, 'HandleVisibility','off')
    end
end
vline_compat(0,'--k')
yline_compat(0,'--r')
legend('show')
makepretty_BM2
end
