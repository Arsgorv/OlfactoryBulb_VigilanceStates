function plot_group_log2ratio(AllSessions, RatioCell, specType, DrugColors)
% Group mean of per-session log2(after/before) spectra.

hold on
for drug = 1:2
    D = remove_empty_rows(RatioCell{drug});
    if isempty(D)
        continue
    end
    f = get_frequency_vector(AllSessions, specType);
    M = nanmean(D,1);
    E = nanstd(D,0,1)./sqrt(size(D,1));
    if exist('shadedErrorBar', 'file')
        h = shadedErrorBar(f, M, E, '-k', 1);
        h.mainLine.Color = DrugColors{drug};
        h.patch.FaceColor = DrugColors{drug};
        h.edge(1).Color = DrugColors{drug};
        h.edge(2).Color = DrugColors{drug};
    else
        plot(f, M, 'Color', DrugColors{drug}, 'LineWidth', 2)
        plot(f, M+E, 'Color', DrugColors{drug})
        plot(f, M-E, 'Color', DrugColors{drug})
    end
end
yline_compat(0,'--r')
legend('Saline','Atropine')
xlabel('Frequency (Hz)')
makepretty_BM2
end
