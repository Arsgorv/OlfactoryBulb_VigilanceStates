function fig = plot_transition_diagram_AG(T_all, sessionNames, colors, opts)
% plot_transition_diagram_AG  Network-style state-transition diagram. Nodes
% colored by state, arrows colored by source, arrow width proportional to
% transition probability. Self-transitions (diagonal) are excluded by design.
%
% INPUT
%   T_all          1xN cell of compute_transition_matrix_AG outputs
%   sessionNames   1xN cellstr
%   colors         state_colors_AG output (optional)
%   opts           struct, optional:
%     .minProb              minimum P(i->j) to draw an edge (default 0.10)
%     .requireAboveShuffle  if true and shuffle was computed, hide edges where
%                           the observed probability is not above the shuffle
%                           median (default true)
%     .minDiffFromShuffle   minimum |obs - median(shuffle)| to draw an edge
%                           when shuffle is available (default 0.02)
%
% OUTPUT
%   fig  figure handle

if nargin < 3 || isempty(colors), colors = state_colors_AG(); end
if nargin < 4, opts = struct(); end
if ~isfield(opts,'minProb'),             opts.minProb             = 0.05; end
if ~isfield(opts,'requireAboveShuffle'), opts.requireAboveShuffle = true; end
if ~isfield(opts,'minDiffFromShuffle'),  opts.minDiffFromShuffle  = 0.02; end

nSess = numel(T_all);
names = colors.names;
nS = 4;

fig = figure('Color','w','Units','normalized','Position',[.1 .1 .35*nSess+.1 .55]);

% Node positions (square diamond layout)
xy = [ 1  0;     %  Wake
       0  1;     %  N1
      -1  0;     %  N2
       0 -1];    %  REM

minLW = 0.3;
maxLW = 6;

for s = 1:nSess
    subplot(1, nSess, s)
    P = T_all{s}.probs;
    haveShuf = isfield(T_all{s},'shuffleProbs') && ~isempty(T_all{s}.shuffleProbs);
    if haveShuf, Pmed = nanmedian(T_all{s}.shuffleProbs, 3); end
    hold on
    % --- Edges (filtered by probability and shuffle-significance) ---
    for i = 1:nS
        for j = 1:nS
            if i == j, continue, end
            p = P(i, j);
            if p < opts.minProb, continue, end
            if haveShuf
                d = p - Pmed(i, j);
                if opts.requireAboveShuffle && d <= 0, continue, end
                if abs(d) < opts.minDiffFromShuffle,  continue, end
            end
            lw  = minLW + (maxLW - minLW) * p;
            col = colors.colors{i};
            draw_curved_arrow(xy(i,:), xy(j,:), col, lw)
        end
    end
    % --- Nodes ---
    for k = 1:nS
        plot(xy(k,1), xy(k,2), 'o', ...
             'MarkerSize', 36, ...
             'MarkerFaceColor', colors.colors{k}, ...
             'MarkerEdgeColor', 'k', 'LineWidth', 1.2)
        text(xy(k,1), xy(k,2), names{k}, ...
             'HorizontalAlignment','center', 'Color', 'w', ...
             'FontWeight','bold','FontSize',12)
    end
    axis equal off
    xlim([-1.6 1.6]), ylim([-1.6 1.6])
    title(sessionNames{s}, 'Interpreter','none')
end

end


function draw_curved_arrow(p0, p1, col, lw)
% Draw a slightly curved arrow from p0 to p1. Curvature is to the LEFT of
% the direction of travel so reciprocal arrows don't overlap.
v  = p1 - p0;
L  = norm(v);
u  = v / L;
n  = [-u(2) u(1)];           % left-perpendicular (rotate +90 deg)
% pull endpoints in toward node centers so arrow doesn't disappear under nodes
shrink = 0.18;
p0s = p0 + shrink * u;
p1s = p1 - shrink * u;
% control point: midpoint shifted along n
mid = 0.5*(p0s + p1s) + 0.18 * L * n;
% Quadratic Bezier
t = linspace(0,1,40)';
B = (1-t).^2 .* p0s + 2*(1-t).*t .* mid + t.^2 .* p1s;
plot(B(:,1), B(:,2), '-', 'Color', col, 'LineWidth', lw)
% arrowhead at the tip
ah = mid - p1s;
ah = ah / norm(ah);
% tip at p1s, two points back along the curve direction
tipDir = (p1s - B(end-1,:)); tipDir = tipDir / norm(tipDir);
perp   = [-tipDir(2) tipDir(1)];
ahLen  = 0.07 + 0.02 * lw;
ahWid  = 0.05 + 0.015 * lw;
arrA = p1s - ahLen*tipDir + ahWid*perp;
arrB = p1s - ahLen*tipDir - ahWid*perp;
patch([p1s(1) arrA(1) arrB(1)], [p1s(2) arrA(2) arrB(2)], col, ...
      'EdgeColor', col)
end
