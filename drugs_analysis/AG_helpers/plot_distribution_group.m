function plot_distribution_group(Ana, fieldName, DrugColors, ColorBefore, ColorAfter)
% Per-session distributions, then averaged by condition/epoch.

edges = [];
allData = [];
for i = 1:length(Ana)
    if isfield(Ana(i), fieldName)
        x = safe_log(Ana(i).(fieldName));
        allData = [allData; x(isfinite(x))];
    end
end
if isempty(allData)
    return
end
lo = simple_percentile(allData, 1);
hi = simple_percentile(allData, 99);
if lo == hi
    lo = lo - 0.5;
    hi = hi + 0.5;
end
edges = linspace(lo, hi, 200);
centers = (edges(1:end-1)+edges(2:end))/2;

labels = {'Saline before','Saline after','Atropine before','Atropine after'};
colors = {ColorBefore, ColorAfter, ColorBefore, ColorAfter};
lineStyles = {'-','-','--','--'};

plotCounter = 0;
for drug = 1:2
    for epoch = 1:2
        AllY = [];
        for i = 1:length(Ana)
            if ~isfield(Ana(i), fieldName) || Ana(i).drug_id ~= drug
                continue
            end
            if epoch == 1
                idx = Ana(i).idx_before;
            else
                idx = Ana(i).idx_after;
            end
            x = safe_log(Ana(i).(fieldName));
            x = x(idx);
            x = x(isfinite(x));
            if length(x) > 10
                Y = histcounts(x, edges, 'Normalization', 'probability');
                AllY = [AllY; Y];
            end
        end
        if isempty(AllY)
            continue
        end
        M = runmean(nanmean(AllY,1), 5);
        plotCounter = plotCounter + 1;
        if drug == 1
            col = colors{epoch};
        else
            col = DrugColors{drug};
            if epoch == 1
                col = [0 0.5 0];
            end
        end
        plot(centers, M, lineStyles{plotCounter}, 'Color', col, 'LineWidth', 2); hold on
    end
end
legend(labels)
makepretty_BM2
end
