function fig = plot_substate_transition_diagram_AG(T_sub_all, sessionNames)
% plot_substate_transition_diagram_AG  Network diagram of transitions between
% the 7 substates (Wake / N1 short / N1 long / N2 short / N2 long /
% REM short / REM long). Nodes are colored by the parent state (with darker
% shade for "short", lighter for "long"). Arrows colored by source, width
% scaled by transition probability.
%
% INPUT
%   T_sub_all      1xN cell of compute_transitions_cell_AG outputs
%   sessionNames   1xN cellstr
%
% OUTPUT
%   fig  figure handle
%
% Notes
%   - Layout is a circle so all 7 nodes are visible, with short/long pairs
%     adjacent.
%   - Self-transitions are 0 by construction.

nSess = numel(T_sub_all);
fig = figure('Color','w','Units','normalized','Position',[.05 .05 .45*nSess+.05 .65]);

minLW = 0.4; maxLW = 5;
minProb = 0.015;

for s = 1:nSess
    subplot(1, nSess, s)
    T = T_sub_all{s};
    nN = numel(T.names);

    % Circular layout: angle 0 at top, clockwise
    theta = linspace(pi/2, pi/2 - 2*pi*(nN-1)/nN, nN);
    xy = [cos(theta(:))  sin(theta(:))];

    % Build node colors from labels
    [nodeCols, isShort, isLong, parentIdx] = label_to_colors(T.names);

    hold on
    P = T.probs;
    % Edges
    for i = 1:nN
        for j = 1:nN
            if i == j, continue, end
            p = P(i,j);
            if p < minProb, continue, end
            lw  = minLW + (maxLW - minLW) * min(p, 1);
            col = nodeCols{i};
            draw_curved_arrow(xy(i,:), xy(j,:), col, lw)
        end
    end
    % Nodes
    for k = 1:nN
        plot(xy(k,1), xy(k,2), 'o', ...
             'MarkerSize', 28, 'LineWidth', 1.2, ...
             'MarkerFaceColor', nodeCols{k}, 'MarkerEdgeColor', 'k')
        text(xy(k,1), xy(k,2), shorten_label(T.names{k}), ...
             'HorizontalAlignment','center', 'Color','w', ...
             'FontWeight','bold','FontSize',9)
    end
    axis equal off
    xlim([-1.5 1.5]), ylim([-1.5 1.5])
    title(sessionNames{s}, 'Interpreter','none')
end

end


% =============================================================================
% local helpers
% =============================================================================
function s = shorten_label(name)
% "N1 short" -> "N1s", "REM long" -> "REMl"
parts = strsplit(name);
if numel(parts) == 1
    s = parts{1};
else
    s = sprintf('%s%s', parts{1}, parts{2}(1));
end
end


function [nodeCols, isShort, isLong, parentIdx] = label_to_colors(names)
% Map substate labels to colors using state_colors_AG.
cBase = state_colors_AG();
nN = numel(names);
nodeCols = cell(1, nN);
isShort  = false(1, nN);
isLong   = false(1, nN);
parentIdx = zeros(1, nN);
for k = 1:nN
    parts = strsplit(names{k});
    base  = parts{1};
    pIdx = find(strcmp(cBase.names, base), 1);
    if isempty(pIdx), pIdx = 1; end
    parentIdx(k) = pIdx;
    if numel(parts) == 1
        nodeCols{k} = cBase.colors{pIdx};
    elseif strcmp(parts{2}, 'short')
        nodeCols{k} = max(0, cBase.colors{pIdx} * 0.55);   % darker
        isShort(k) = true;
    else
        nodeCols{k} = cBase.colors{pIdx} + (1 - cBase.colors{pIdx}) * 0.45;
        isLong(k)  = true;
    end
end
end


function draw_curved_arrow(p0, p1, col, lw)
v  = p1 - p0; L = norm(v); if L == 0, return, end
u  = v / L;
n  = [-u(2) u(1)];
shrink = 0.10;
p0s = p0 + shrink * u;
p1s = p1 - shrink * u;
mid = 0.5*(p0s + p1s) + 0.13 * L * n;
t = linspace(0,1,40)';
B = (1-t).^2 .* p0s + 2*(1-t).*t .* mid + t.^2 .* p1s;
plot(B(:,1), B(:,2), '-', 'Color', col, 'LineWidth', lw)
tipDir = (p1s - B(end-1,:));
nrm = norm(tipDir);
if nrm == 0, return, end
tipDir = tipDir / nrm;
perp   = [-tipDir(2) tipDir(1)];
ahLen  = 0.06 + 0.015 * lw;
ahWid  = 0.04 + 0.012 * lw;
arrA = p1s - ahLen*tipDir + ahWid*perp;
arrB = p1s - ahLen*tipDir - ahWid*perp;
patch([p1s(1) arrA(1) arrB(1)], [p1s(2) arrA(2) arrB(2)], col, ...
      'EdgeColor', col)
end
