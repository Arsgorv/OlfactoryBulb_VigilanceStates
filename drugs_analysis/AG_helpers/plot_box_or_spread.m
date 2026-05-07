function plot_box_or_spread(dataCell, Cols, X, Legends)
% Use current custom plotting function if available. Fallback to simple boxplot.

allDataCheck = [];
for kk = 1:length(dataCell)
    allDataCheck = [allDataCheck; dataCell{kk}(:)];
end
allDataCheck = allDataCheck(isfinite(allDataCheck));
if isempty(allDataCheck)
    text(0.1, 0.5, 'No finite data')
    axis off
    return
end

if exist('MakeSpreadAndBoxPlot3_SB', 'file')
    MakeSpreadAndBoxPlot3_SB(dataCell, Cols, X, Legends, 'showpoints', 1, 'paired', 0);
else
    allData = [];
    group = [];
    for k = 1:length(dataCell)
        d = dataCell{k};
        d = d(:);
        allData = [allData; d];
        group = [group; k*ones(length(d),1)];
    end
    boxplot(allData, group, 'Labels', Legends)
    hold on
    for k = 1:length(dataCell)
        d = dataCell{k};
        scatter(k*ones(size(d)), d, 20, Cols{k}, 'filled')
    end
end
end
