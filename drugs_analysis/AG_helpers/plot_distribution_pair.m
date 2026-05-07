function plot_distribution_pair(before, after, color_before, color_after)
% Probability histograms with shared edges.

before = before(isfinite(before));
after = after(isfinite(after));
if isempty(before) || isempty(after)
    return
end
xmin = min([before(:); after(:)]);
xmax = max([before(:); after(:)]);
if xmin == xmax
    xmin = xmin - 0.5;
    xmax = xmax + 0.5;
end
edges = linspace(xmin, xmax, 150);
centers = (edges(1:end-1)+edges(2:end))/2;
Y = histcounts(before, edges, 'Normalization', 'probability');
plot(centers, runmean(Y,5), 'Color', color_before, 'LineWidth', 1.5); hold on
Y = histcounts(after, edges, 'Normalization', 'probability');
plot(centers, runmean(Y,5), 'Color', color_after, 'LineWidth', 1.5);
legend('Before','After')
end
