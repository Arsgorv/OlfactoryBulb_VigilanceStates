function plot_lag_group(lag_min, LagCell, DrugColors)
% Group lagged correlation curves.

hold on
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
        h.patch.FaceColor = DrugColors{drug};
        h.edge(1).Color = DrugColors{drug};
        h.edge(2).Color = DrugColors{drug};
    else
        plot(lag_min, M, 'Color', DrugColors{drug}, 'LineWidth', 2)
        plot(lag_min, M+E, 'Color', DrugColors{drug})
        plot(lag_min, M-E, 'Color', DrugColors{drug})
    end
end
vline_compat(0,'--k')
yline_compat(0,'--r')
legend('Saline','Atropine')
makepretty_BM2
end
