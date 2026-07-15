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

% Light grey lines connecting each session's points across the state columns
% make per-session trends readable.

% --- (1,1) % of recording, one box per state ---------------------------------
subplot(2,4,1)
Mat = nan(nSess, nState);
for s = 1:nSess, Mat(s,:) = 100 * M_all{s}.prop_total; end
A = mat_to_cell_AG(Mat);
MakeSpreadAndBoxPlot3_SB(A, colors.colors, 1:nState, names, ...
    'showpoints', 1, 'paired', 0, 'newfig', 0);
draw_session_lines_AG(1:nState, Mat);
ylabel('% of recording')
title('Composition of recording')
box off, set(gca,'FontSize',9,'TickDir','out')

% --- (1,2) % of sleep, N1/N2/REM only ---------------------------------------
subplot(2,4,2)
Mat = nan(nSess, 3);
for s = 1:nSess, Mat(s,:) = 100 * M_all{s}.prop_sleep(2:4); end
A = mat_to_cell_AG(Mat);
MakeSpreadAndBoxPlot3_SB(A, colors.colors(2:4), 1:3, names(2:4), ...
    'showpoints', 1, 'paired', 0, 'newfig', 0);
draw_session_lines_AG(1:3, Mat);
ylabel('% of sleep')
title('Composition of sleep')
box off, set(gca,'FontSize',9,'TickDir','out')

% --- (1,3) bout count per state ---------------------------------------------
subplot(2,4,3)
Mat = nan(nSess, nState);
for s = 1:nSess, Mat(s,:) = M_all{s}.nbouts; end
A = mat_to_cell_AG(Mat);
MakeSpreadAndBoxPlot3_SB(A, colors.colors, 1:nState, names, ...
    'showpoints', 1, 'paired', 0, 'newfig', 0);
draw_session_lines_AG(1:nState, Mat);
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


% =============================================================================
% local helpers
% =============================================================================
function A = mat_to_cell_AG(Mat)
A = cell(1, size(Mat,2));
for i = 1:size(Mat,2), A{i} = Mat(:,i); end
end

function draw_session_lines_AG(xPos, Mat)
% Light grey lines connecting each session's points across columns
hold on
for s = 1:size(Mat,1)
    plot(xPos, Mat(s,:), '-', 'Color', [.5 .5 .5 .45], 'LineWidth', 0.8, ...
         'HandleVisibility','off')
end
end
