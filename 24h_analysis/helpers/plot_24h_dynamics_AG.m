function fig = plot_24h_dynamics_AG(D_all, sessionNames, colors, lightOnIntervals, smoothWindow_h)
% plot_24h_dynamics_AG  State proportions across the 24-h recording, per
% session.  Two rows per session: stacked area (composition) at native bin
% resolution, and per-state smoothed lines (default 1-h moving-average) so
% trends are easier to read than the raw 30-min noise.
%
% INPUT
%   D_all              1xN cell of compute_24h_dynamics_AG outputs
%   sessionNames       1xN cellstr
%   colors             state_colors_AG output (optional)
%   lightOnIntervals   1xN cell of Nx2 matrices of recording-relative hours
%                      during which lights were ON. Each cell can be [] to
%                      skip shading for that session.
%   smoothWindow_h     moving-average window in hours for the bottom-row per-state
%                      lines. Default 1.0. Pass 0 to disable smoothing.
%
% OUTPUT
%   fig            figure handle

if nargin < 3 || isempty(colors), colors = state_colors_AG(); end
if nargin < 4, lightOnIntervals = {}; end
if nargin < 5 || isempty(smoothWindow_h), smoothWindow_h = 1.0; end
nSess = numel(D_all);
names = colors.names;
nState = 4;

fig = figure('Color','w','Units','normalized','Position',[.05 .05 .9 .7]);

for s = 1:nSess
    D = D_all{s};

    % --- top row: stacked area, raw bins
    subplot(2, nSess, s)
    h = area(D.binCenters_h, D.propMatrix);
    for i = 1:nState
        set(h(i), 'FaceColor', colors.colors{i}, 'EdgeColor','none', 'FaceAlpha', 0.9)
    end
    xlim([0 D.binEdges_h(end)])
    ylim([0 1])
    ylabel('Fraction of bin')
    xlabel('Time (h)')
    title(sprintf('%s, %d-min bins', sessionNames{s}, D.binSize_s/60), ...
          'FontWeight','bold','Interpreter','none')
    if s == nSess
        legend(names, 'Location','northeastoutside','Box','off')
    end
    set(gca,'TickDir','out','Box','off','FontSize',9)

    % --- bottom row: per-state smoothed lines
    subplot(2, nSess, nSess + s)
    binDt_h = D.binSize_s / 3600;
    if smoothWindow_h > 0 && binDt_h > 0
        nSmooth = max(1, round(smoothWindow_h / binDt_h));
        propSmooth = movmean(D.propMatrix, nSmooth, 1, 'omitnan', 'Endpoints','shrink');
        smoothLabel = sprintf('Per-state evolution (%.1f-h moving avg)', smoothWindow_h);
    else
        propSmooth = D.propMatrix;
        smoothLabel = 'Per-state evolution';
    end
    held = false;
    for i = 1:nState
        plot(D.binCenters_h, propSmooth(:,i), '-', ...
             'Color', colors.colors{i}, 'LineWidth', 1.8)
        if ~held, hold on, held = true; end
    end
    xlim([0 D.binEdges_h(end)])
    ylim([0 1])
    ylabel('Fraction of bin')
    xlabel('Time (h)')
    title(smoothLabel)
    set(gca,'TickDir','out','Box','off','FontSize',9)
    axBottom = gca;

    if numel(lightOnIntervals) >= s && ~isempty(lightOnIntervals{s})
        add_light_shading_AG(axBottom, lightOnIntervals{s}, D.binEdges_h(end), ...
            'colors', colors, 'alpha', 0.18);
    end
end

end
