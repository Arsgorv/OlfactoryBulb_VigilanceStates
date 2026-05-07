function fig = plot_state_correlations_AG(C_all, sessionNames, colors)
% plot_state_correlations_AG  Cycle-by-cycle state proportions and pairwise
% correlations between state proportions across cycles.
%
% Top row, per session :
%   N1 proportion across consecutive cycles (line)
%
% Bottom row :
%   pooled scatter REM vs N1 cycle proportion (Pearson + p)
%   pooled scatter REM vs N2
%   pooled scatter N1  vs N2
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

fig = figure('Color','w','Units','normalized','Position',[.05 .05 .9 .8]);

% --- Per-cycle state proportions, per session --------------------------------
% propPerCycle{s} is nCycles x 4
propPerCycle = cell(1, nSess);
for s = 1:nSess
    if isempty(C_all{s}.propByCycle)
        propPerCycle{s} = zeros(0,4);
        continue
    end
    P = C_all{s}.propByCycle;          % nCycles x nBins x 4
    propPerCycle{s} = squeeze(nanmean(P, 2));   % nCycles x 4
end

% --- Top row: N1 proportion across cycles, per session -----------------------
for s = 1:nSess
    subplot(2, nSess+1, s)
    if isempty(propPerCycle{s})
        axis off, continue
    end
    n1 = propPerCycle{s}(:, 2);
    plot(1:numel(n1), n1, '-o', 'Color', colors.colors{2}, ...
         'MarkerFaceColor', colors.colors{2}, 'LineWidth', 1.4, 'MarkerSize', 4)
    xlabel('Sleep cycle #')
    ylabel('N1 proportion')
    title(sessionNames{s}, 'Interpreter','none')
    box off, set(gca,'TickDir','out','FontSize',9)
end

% Per-state evolution panel: N1, N2, REM means across cycles, sessions overlaid
subplot(2, nSess+1, nSess+1)
held = false;
markers = {'o','s','^','d'};
for s = 1:nSess
    P = propPerCycle{s};
    if isempty(P), continue, end
    plot(1:size(P,1), P(:,2), '-', 'Color', colors.colors{2}, 'LineWidth', 1.2);
    if ~held, hold on, held = true; end
    plot(1:size(P,1), P(:,3), '-', 'Color', colors.colors{3}, 'LineWidth', 1.2)
    plot(1:size(P,1), P(:,4), '-', 'Color', colors.colors{4}, 'LineWidth', 1.2)
end
xlabel('Sleep cycle #'), ylabel('Proportion')
title('Per-state cycle proportion'), box off, set(gca,'TickDir','out','FontSize',9)
legend({'N1','N2','REM'}, 'Box','off','Location','best')

% --- Bottom row: pairwise correlations, sessions pooled ----------------------
P_pool = vertcat(propPerCycle{:});
pairs = {2 4 'N1','REM'; 3 4 'N2','REM'; 2 3 'N1','N2'};
for k = 1:size(pairs,1)
    subplot(2, nSess+1, (nSess+1)+k)
    a = P_pool(:, pairs{k,1});
    b = P_pool(:, pairs{k,2});
    keep = ~isnan(a) & ~isnan(b);
    a = a(keep); b = b(keep);
    if numel(a) < 3
        axis off, continue
    end
    plot(a, b, 'o', 'MarkerEdgeColor', 'k', ...
         'MarkerFaceColor', [.6 .6 .6], 'MarkerSize', 5)
    hold on
    [R, p] = corr(a, b, 'Type','Pearson');
    pf = polyfit(a, b, 1);
    xfit = linspace(min(a), max(a), 50);
    plot(xfit, polyval(pf, xfit), 'k-', 'LineWidth', 1.5)
    xlabel(sprintf('%s proportion', pairs{k,3}))
    ylabel(sprintf('%s proportion', pairs{k,4}))
    title(sprintf('R = %.2f   p = %.1g', R, p), 'FontWeight','normal')
    box off, set(gca,'TickDir','out','FontSize',9), axis square
end

end
