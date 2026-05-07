function plot_group_log2ratio_clean(AllSessions, RatioCell, specType, DrugColors, smoothBins)
% Paper-style group mean of per-session log2(after/before) spectra.

hold on
DrugLabels = {'Saline','Atropine'};
for drug = 1:2
    D = remove_empty_rows(RatioCell{drug});
    if isempty(D)
        continue
    end
    f = get_frequency_vector(AllSessions, specType);
    M = nanmean(D,1);
    E = nanstd(D,0,1)./sqrt(size(D,1));
    if smoothBins > 1
        M = runmean(M(:), smoothBins)';
        E = runmean(E(:), smoothBins)';
    end
    if exist('shadedErrorBar', 'file')
        h = shadedErrorBar(f, M, E, '-k', 1);
        h.mainLine.Color = DrugColors{drug};
        h.mainLine.LineWidth = 2.5;
        h.mainLine.DisplayName = DrugLabels{drug};
        h.patch.FaceColor = DrugColors{drug};
        h.patch.FaceAlpha = 0.18;
        h.patch.HandleVisibility = 'off';
        h.edge(1).HandleVisibility = 'off';
        h.edge(2).HandleVisibility = 'off';
    else
        plot(f, M, 'Color', DrugColors{drug}, 'LineWidth', 2.5, 'DisplayName', DrugLabels{drug})
        plot(f, M+E, 'Color', DrugColors{drug}, 'HandleVisibility','off')
        plot(f, M-E, 'Color', DrugColors{drug}, 'HandleVisibility','off')
    end
end
yline_compat(0,'--r')
legend('show')
xlabel('Frequency (Hz)')
makepretty_BM2
end
