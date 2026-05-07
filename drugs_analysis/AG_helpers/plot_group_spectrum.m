function plot_group_spectrum(AllSessions, SpecBeforeCell, SpecAfterCell, specType, DrugColors)
% Plots after spectra normalized only visually against before spectra.
% This panel is descriptive; use log2 ratio panel for the main effect.

hold on
for drug = 1:2
    D1 = remove_empty_rows(SpecBeforeCell{drug});
    D2 = remove_empty_rows(SpecAfterCell{drug});
    if isempty(D1) || isempty(D2)
        continue
    end
    f = get_frequency_vector(AllSessions, specType);
    M1 = nanmean(D1,1);
    M2 = nanmean(D2,1);
    plot(f, M1, '--', 'Color', DrugColors{drug}, 'LineWidth', 1.5)
    plot(f, M2, '-', 'Color', DrugColors{drug}, 'LineWidth', 2.5)
end
legend('Saline before','Saline after','Atropine before','Atropine after')
xlabel('Frequency (Hz)')
makepretty_BM2
end
