function plot_animal_session_points_AG(T, fieldName, DrugColors)
%PLOT_ANIMAL_SESSION_POINTS_AG Plot values per animal, color by drug.

hold on
if isempty(T) || ~istable(T) || ~ismember(fieldName, T.Properties.VariableNames)
    return
end
animals = unique(T.animal, 'stable');
for a = 1:length(animals)
    for drug = 1:2
        idx = strcmp(T.animal, animals{a}) & T.drug_id == drug;
        y = T.(fieldName)(idx);
        y = y(isfinite(y));
        if isempty(y)
            continue
        end
        x = a + (drug-1.5)*0.22 + (rand(size(y))-0.5)*0.10;
        scatter(x, y, 30, DrugColors{drug}, 'filled')
        plot([a + (drug-1.5)*0.22 - 0.08, a + (drug-1.5)*0.22 + 0.08], [nanmedian(y) nanmedian(y)], 'Color', DrugColors{drug}, 'LineWidth', 3)
    end
end
yline_compat(0,'--r')
set(gca,'XTick',1:length(animals),'XTickLabel',animals)
xtickangle(35)
makepretty_BM2
