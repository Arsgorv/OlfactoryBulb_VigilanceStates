function fig = plot_state_composition_AG(M_all, sessionNames, colors, boutThresholds_min)
% plot_state_composition_AG  State proportions and bout statistics across
% sessions, using the lab's MakeSpreadAndBoxPlot3_SB style. Bout durations
% are reported in seconds.
%
% Layout (2 rows x 4 columns)
%   (1,1) % of recording        - 4 box plots, one per state, sessions as points
%   (1,2) % of sleep            - 3 box plots (N1/N2/REM), sessions as points
%   (1,3) bout count per state  - 4 box plots
%   (1,4) bout duration (log y) - 4 box plots, all bouts pooled across sessions
%   (2,1..4) per-state bout-duration distributions (log-x), one panel per state.
%            If boutThresholds_min is provided, a dashed vertical line marks
%            the short/long classification cutoff per state.
%
% INPUT
%   M_all                1xN cell of compute_state_metrics_AG outputs
%   sessionNames         1xN cellstr
%   colors               state_colors_AG output
%   boutThresholds_min   optional struct .Wake .N1 .N2 .REM with thresholds
%                        in MINUTES (kept in min for caller convenience). The
%                        function converts to seconds internally for plotting.
%
% OUTPUT
%   fig            figure handle

if nargin < 3 || isempty(colors), colors = state_colors_AG(); end
if nargin < 4, boutThresholds_min = struct(); end
nSess  = numel(M_all);
names  = colors.names;
nState = 4;

fig = figure('Color','w','Units','normalized','Position',[.06 .06 .88 .82]);

% --- (1,1) % of recording, one box per state ---------------------------------
subplot(2,4,1)
A = cell(1, nState);
for i = 1:nState
    v = nan(1, nSess);
    for s = 1:nSess, v(s) = 100 * M_all{s}.prop_total(i); end
    A{i} = v;
end
MakeSpreadAndBoxPlot3_SB(A, colors.colors, 1:nState, names, ...
    'showpoints', 1, 'paired', 0, 'newfig', 0);
ylabel('% of recording')
title('Composition of recording')
box off, set(gca,'FontSize',9,'TickDir','out')

% --- (1,2) % of sleep, N1/N2/REM only ---------------------------------------
subplot(2,4,2)
A = cell(1,3);
for i = 1:3
    v = nan(1, nSess);
    for s = 1:nSess, v(s) = 100 * M_all{s}.prop_sleep(i+1); end
    A{i} = v;
end
MakeSpreadAndBoxPlot3_SB(A, colors.colors(2:4), 1:3, names(2:4), ...
    'showpoints', 1, 'paired', 0, 'newfig', 0);
ylabel('% of sleep')
title('Composition of sleep')
box off, set(gca,'FontSize',9,'TickDir','out')

% --- (1,3) bout count per state ---------------------------------------------
subplot(2,4,3)
A = cell(1, nState);
for i = 1:nState
    v = nan(1, nSess);
    for s = 1:nSess, v(s) = M_all{s}.nbouts(i); end
    A{i} = v;
end
MakeSpreadAndBoxPlot3_SB(A, colors.colors, 1:nState, names, ...
    'showpoints', 1, 'paired', 0, 'newfig', 0);
ylabel('# bouts')
title('Bouts per state')
box off, set(gca,'FontSize',9,'TickDir','out')

% --- (1,4) bout duration in seconds, all bouts pooled per state -------------
subplot(2,4,4)
A = cell(1, nState);
for i = 1:nState
    pooled = [];
    for s = 1:nSess
        b = M_all{s}.bouts{i};
        if ~isempty(b), pooled = [pooled; b(:)]; end %#ok<AGROW>
    end
    A{i} = pooled;
end
MakeSpreadAndBoxPlot3_SB(A, colors.colors, 1:nState, names, ...
    'showpoints', 0, 'paired', 0, 'newfig', 0);
set(gca,'YScale','log')
ylabel('Bout duration (s)')
title('Bout durations (pooled)')
box off, set(gca,'FontSize',9,'TickDir','out')

% --- (2,1..4) per-state bout-duration distributions, log-x, in seconds -----
% Threshold map (in seconds) for the dashed vertical lines
thr_s = struct('Wake', [], 'N1', [], 'N2', [], 'REM', []);
fnms = {'Wake','N1','N2','REM'};
for k = 1:4
    if isfield(boutThresholds_min, fnms{k}) && ~isempty(boutThresholds_min.(fnms{k}))
        thr_s.(fnms{k}) = boutThresholds_min.(fnms{k}) * 60;
    end
end

for i = 1:nState
    subplot(2,4,4+i)
    held = false;
    legHandles = [];
    legLabels  = {};
    for s = 1:nSess
        b = M_all{s}.bouts{i};
        if isempty(b), continue, end
        edges = logspace(log10(0.5), log10(max([b(:); 1])*1.1), 35);
        h = histcounts(b, edges, 'Normalization','probability');
        x = sqrt(edges(1:end-1).*edges(2:end));
        styles = {'-','--',':','-.'};
        sty = styles{mod(s-1,numel(styles))+1};
        ph = stairs(x, h, 'Color', colors.colors{i}, ...
                    'LineWidth', 1.6, 'LineStyle', sty);
        legHandles(end+1) = ph; %#ok<AGROW>
        legLabels{end+1}  = sessionNames{s}; %#ok<AGROW>
        if ~held, hold on, held = true; end
    end
    if held, set(gca,'XScale','log'); end

    % Threshold line for short/long classification
    thrVal = thr_s.(names{i});
    if ~isempty(thrVal)
        yl = get(gca, 'YLim');
        plot([thrVal thrVal], yl, '--', 'Color', [.2 .2 .2], 'LineWidth', 1.2)
        text(thrVal, yl(2)*0.95, sprintf(' thr = %g s', thrVal), ...
             'FontSize', 8, 'Color', [.2 .2 .2], 'VerticalAlignment','top')
    end

    title(names{i})
    if i == 1, ylabel('PDF'); end
    if i == nState && ~isempty(legHandles)
        legend(legHandles, legLabels, 'Box','off','Location','northeast', ...
               'Interpreter','none')
    end
    xlabel('Bout duration (s)')
    set(gca,'TickDir','out','Box','off','FontSize',9)
end

end
