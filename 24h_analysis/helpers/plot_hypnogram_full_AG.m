function fig = plot_hypnogram_full_AG(SD_all, sessionNames, colors, lightOnIntervals)
% plot_hypnogram_full_AG  Standalone hypnogram figure: one wide panel per
% session showing the staircase of vigilance state over the full 24 h.
%
% Accepts either full SD structs (from load_session_AG) or the light-weight
% cached SM structs (from compute_or_load_session_metrics_AG, schema v3+),
% as long as each element has fields .states (with Wake/N1/N2/REM) and
% .totDur_h / .totDur_ts.
%
% State y-values (so REM sits on top, matching clinical convention):
%   Wake = 4, N1 = 3, N2 = 2, REM = 1   (top-to-bottom: 4..1)
%   But clinical convention plots Wake at top and the rest below, so we use
%   y(Wake)=4, y(REM)=3, y(N1)=2, y(N2)=1 -- you can re-order in YTick if you
%   prefer.
%
% INPUT
%   SD_all              1xN cell of load_session_AG outputs
%   sessionNames        1xN cellstr
%   colors              state_colors_AG output
%   lightOnIntervals    1xN cell of Nx2 hours, or {}; shades light/dark
%
% OUTPUT
%   fig  figure handle

if nargin < 3 || isempty(colors), colors = state_colors_AG(); end
if nargin < 4, lightOnIntervals = {}; end

nSess = numel(SD_all);
% fig = figure('Color','w','Units','normalized','Position',[.04 .1 .92 .7]);

% Clinical-ish vertical order: Wake on top, REM next, then N1, then N2 at bottom
yOf = struct('Wake', 4, 'REM', 3, 'N1', 2, 'N2', 1);
yTicks = [1 2 3 4];
yLabels = {'N2','N1','REM','Wake'};
ax = gobjects(1,nSess);

for s = 1:nSess
%     ax(s) = subplot(nSess, 1, s);
    if nSess == 1
        SD = SD_all;
    else
        SD = SD_all{s};
    end
    [t_h, y] = build_hypnogram_AG(SD, yOf);
    % Draw colored line segments (constant within each bout)
    hold on
    n = numel(t_h) - 1;
    for k = 1:n
        if isnan(y(k)), continue, end
        col = color_for_y_AG(y(k), yOf, colors);
        plot([t_h(k) t_h(k+1)], [y(k) y(k)], '-', 'Color', col, 'LineWidth', 2.4)
        % vertical connectors between segments
        if k < n && ~isnan(y(k+1))
            plot([t_h(k+1) t_h(k+1)], [y(k) y(k+1)], '-', 'Color', [.5 .5 .5], 'LineWidth', 0.5)
        end
    end
    xlim([0 SD.totDur_h])
    ylim([0.5 4.5])
    set(gca, 'YTick', yTicks, 'YTickLabel', yLabels, ...
             'TickDir','out','Box','off','FontSize',9)
    if s == nSess, xlabel('Time in recording (h)'); end
    if nSess == 1
        title(sessionNames, 'Interpreter','none')
    else
        title(sessionNames{s}, 'Interpreter','none')
    end
    
    if nSess == 1
        if numel(lightOnIntervals) >= s && ~isempty(lightOnIntervals)
            add_light_shading_AG(gca, lightOnIntervals, SD.totDur_h, ...
                'colors', colors, 'alpha', 0.15);
        end
    else
        if numel(lightOnIntervals) >= s && ~isempty(lightOnIntervals{s})
            add_light_shading_AG(gca, lightOnIntervals{s}, SD.totDur_h, ...
                'colors', colors, 'alpha', 0.15);
        end
    end
end

end


function [t_h, y] = build_hypnogram_AG(SD, yOf)
% Build a piecewise-constant hypnogram. Returns edges (t_h, length N+1) and
% the state-y value for each segment (y, length N). Time in hours.
states  = {SD.states.Wake, SD.states.N1, SD.states.N2, SD.states.REM};
yvals   = [yOf.Wake yOf.N1 yOf.N2 yOf.REM];
edges = []; ystate = [];
for i = 1:4
    if isempty(states{i}), continue, end
    st = Start(states{i}); en = Stop(states{i});
    edges  = [edges; st; en]; %#ok<AGROW>
    ystate = [ystate; yvals(i)*ones(numel(st),1); yvals(i)*ones(numel(en),1)]; %#ok<AGROW>
end
[edges, sidx] = sort(edges);
ystate = ystate(sidx);
% Build piecewise: every transition is a new segment. Use the LAST y at each edge.
edges = unique([0; edges; SD.totDur_ts]);
y = nan(numel(edges)-1, 1);
midTs = (edges(1:end-1) + edges(2:end)) / 2;
for k = 1:numel(midTs)
    for i = 1:4
        if isempty(states{i}), continue, end
        if any(in_interval(midTs(k), Start(states{i}), Stop(states{i})))
            y(k) = yvals(i); break
        end
    end
end
t_h = edges / 3600e4;
end


function tf = in_interval(x, st, en)
tf = false(numel(st),1);
for k = 1:numel(st)
    if x >= st(k) && x < en(k), tf(k) = true; end
end
end


function col = color_for_y_AG(y, yOf, colors)
if     y == yOf.Wake, col = colors.colors{1};
elseif y == yOf.N1,   col = colors.colors{2};
elseif y == yOf.N2,   col = colors.colors{3};
elseif y == yOf.REM,  col = colors.colors{4};
else,                 col = [.5 .5 .5];
end
end
