function fig = plot_state_correlations_AG(C_all, sessionNames, colors)
% plot_state_correlations_AG  How N1, N2 and REM proportions co-vary across
% sleep cycles.
%
% Layout (2 rows x max(nSess+1, 3) cols):
%   Row 1: per-session line plot of N1/N2/REM proportions across cycles
%          (one panel per session), followed by a 3x3 correlation matrix
%          heatmap pooled across sessions.
%   Row 2: 3 pairwise scatter plots (N1-N2, N1-REM, N2-REM), pooled across
%          sessions, color-coded by session, with regression line and R/p.
%
% INPUT
%   C_all          1xN cell of compute_sleep_cycles_AG outputs
%   sessionNames   1xN cellstr
%   colors         state_colors_AG output
%
% OUTPUT
%   fig  figure handle

if nargin < 3 || isempty(colors), colors = state_colors_AG(); end
nSess = numel(C_all);
nCol  = max(nSess + 1, 3);

% Compute per-cycle (mean across cycle bins) state proportions per session
propPerCycle = cell(1, nSess);
for s = 1:nSess
    if isempty(C_all{s}.propByCycle)
        propPerCycle{s} = zeros(0,4);
    else
        propPerCycle{s} = squeeze(nanmean(C_all{s}.propByCycle, 2));
    end
end

fig = figure('Color','w','Units','normalized','Position',[.05 .05 .9 .8]);

% =============================================================================
% Row 1: per-session per-cycle proportion lines + correlation matrix
% =============================================================================
sessMarkers = {'o','s','^','d','v'};
for s = 1:nSess
    subplot(2, nCol, s)
    P = propPerCycle{s};
    if isempty(P), axis off, continue, end
    held = false;
    plot(1:size(P,1), P(:,2), '-', 'Color', colors.colors{2}, 'LineWidth', 1.6); hold on; held = true;
    plot(1:size(P,1), P(:,3), '-', 'Color', colors.colors{3}, 'LineWidth', 1.6);
    plot(1:size(P,1), P(:,4), '-', 'Color', colors.colors{4}, 'LineWidth', 1.6);
    xlabel('Sleep cycle #'); ylabel('Proportion of cycle')
    title(sessionNames{s}, 'Interpreter','none')
    box off, set(gca,'TickDir','out','FontSize',9)
    ylim([0 1])
    if s == 1
        legend({'N1','N2','REM'}, 'Box','off','Location','best')
    end
end

% Correlation matrix in last column of row 1
subplot(2, nCol, nCol)
P_pool = vertcat(propPerCycle{:});
if size(P_pool, 1) >= 3
    R = corr(P_pool(:, 2:4), 'Type','Pearson', 'Rows','complete');
else
    R = nan(3);
end
imagesc(R)
caxis([-1 1])
colormap(gca, redblue_AG())
cb = colorbar; ylabel(cb, 'Pearson R')
labelsRC = {'N1','N2','REM'};
set(gca, 'XTick', 1:3, 'XTickLabel', labelsRC, ...
         'YTick', 1:3, 'YTickLabel', labelsRC, ...
         'TickDir','out','FontSize',9)
axis square
title('Cycle-wise correlations')
for i = 1:3
    for j = 1:3
        text(j, i, num2str(R(i,j),'%.2f'), ...
            'HorizontalAlignment','center', 'FontWeight','bold', ...
            'Color', textColor(R(i,j)))
    end
end

% =============================================================================
% Row 2: pairwise scatter plots, sessions color-coded
% =============================================================================
pairs = { ...
    2 3 'N1' 'N2'; ...
    2 4 'N1' 'REM'; ...
    3 4 'N2' 'REM'};
sessCols = makeSessionColors(nSess);

for k = 1:3
    subplot(2, nCol, nCol + k)
    held = false;
    legHandles = []; legLabels = {};

    aPool = []; bPool = [];
    for s = 1:nSess
        P = propPerCycle{s};
        if isempty(P), continue, end
        a = P(:, pairs{k,1});
        b = P(:, pairs{k,2});
        keep = ~isnan(a) & ~isnan(b);
        a = a(keep); b = b(keep);
        ph = plot(a, b, sessMarkers{mod(s-1,numel(sessMarkers))+1}, ...
            'MarkerEdgeColor','k','MarkerFaceColor', sessCols{s}, 'MarkerSize', 6);
        if ~held, hold on, held = true; end
        legHandles(end+1) = ph; %#ok<AGROW>
        legLabels{end+1}  = sessionNames{s}; %#ok<AGROW>
        aPool = [aPool; a]; %#ok<AGROW>
        bPool = [bPool; b]; %#ok<AGROW>
    end
    if numel(aPool) >= 3
        [R, p] = corr(aPool, bPool, 'Type','Pearson');
        pf = polyfit(aPool, bPool, 1);
        xfit = linspace(min(aPool), max(aPool), 50);
        plot(xfit, polyval(pf, xfit), 'k-', 'LineWidth', 1.5)
        title(sprintf('R = %.2f   p = %.1g', R, p), 'FontWeight','normal')
    end
    xlabel(sprintf('%s proportion', pairs{k,3}))
    ylabel(sprintf('%s proportion', pairs{k,4}))
    box off, set(gca,'TickDir','out','FontSize',9), axis square
    if k == 3 && ~isempty(legHandles)
        legend(legHandles, legLabels, 'Box','off','Location','best','Interpreter','none')
    end
end

end


% =============================================================================
% local helpers
% =============================================================================
function c = textColor(R)
% black for light cells, white for dark cells
if abs(R) > 0.55, c = 'w'; else, c = 'k'; end
end

function cmap = redblue_AG()
n = 128;
b = [linspace(0.0,1.0,n)' linspace(0.2,1.0,n)' linspace(0.6,1.0,n)'];
r = [linspace(1.0,0.6,n)' linspace(1.0,0.0,n)' linspace(1.0,0.0,n)'];
cmap = [b; r];
end

function cols = makeSessionColors(n)
base = {[.10 .55 .80], [.85 .55 .15], [.45 .25 .85], [.20 .65 .25], [.80 .20 .55]};
cols = cell(1, n);
for k = 1:n
    cols{k} = base{mod(k-1, numel(base)) + 1};
end
end
