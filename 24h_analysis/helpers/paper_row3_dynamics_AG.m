function paper_row3_dynamics_AG(fig, region, C, T, M, SInfo, LightOnIntervals, colors, diagOpts) %#ok<INUSL>
% paper_row3_dynamics_AG  Four panels: mean sleep cycle (stacked area, axis
% square) | 24-h state evolution (stacked area at 90-min bins) | cleaned
% mean transition diagram (nodes scaled by state proportion) | 4x4 mean
% transition matrix (imagesc with numeric labels).

x0 = region(1); y0 = region(2); w = region(3); h = region(4);
nP = 4; gap = 0.025;
ws = (w - (nP-1)*gap) / nP;
nState = 4; names = colors.names;
nSess = numel(C);

% Cross-session mean state proportions (for node scaling on diagram)
propTotal = nan(nSess, 4);
for s = 1:nSess, propTotal(s,:) = M{s}.prop_total; end
propMean = nanmean(propTotal, 1);

% =====================================================================
% (1) Mean sleep cycle (stacked area, axis square)
% =====================================================================
axes('Parent',fig,'Position',[x0 y0 ws h])
nBins = 0;
for s = 1:nSess
    if ~isempty(C{s}.meanProp), nBins = max(nBins, size(C{s}.meanProp,1)); end
end
if nBins > 0
    stack = nan(nSess, nBins, 4);
    for s = 1:nSess
        if ~isempty(C{s}.meanProp), stack(s,:,:) = C{s}.meanProp; end
    end
    Mcycle = squeeze(nanmean(stack, 1));
    ha = area(linspace(0,1,nBins), Mcycle);
    for i = 1:nState
        set(ha(i),'FaceColor',colors.colors{i},'EdgeColor','none','FaceAlpha',0.9)
    end
    xlim([0 1]); ylim([0 1])
end
xlabel('Cycle progress'); ylabel('State proportion')
title('Mean sleep cycle','FontWeight','normal','FontSize',9)
axis square
set(gca,'TickDir','out','Box','off','FontSize',8)

% =====================================================================
% (2) 24-h state evolution: stacked area, 90-min bins (cross-session mean)
% =====================================================================
ax2 = axes('Parent',fig,'Position',[x0+ws+gap y0 ws h]);
binSize_h = 1.5;   % 90 min
maxDur_h = 0; for s = 1:nSess, maxDur_h = max(maxDur_h, SInfo{s}.totDur_h); end
edges_h = 0:binSize_h:maxDur_h;
nBinsH  = numel(edges_h)-1;
ctr_h   = edges_h(1:end-1) + binSize_h/2;
if nBinsH >= 1
    Mavg = nan(nBinsH, 4);
    for i = 1:4
        Mat = nan(nSess, nBinsH);
        for s = 1:nSess
            stEpoch = SInfo{s}.states.(names{i});
            for b = 1:nBinsH
                bStart = (b-1) * binSize_h * 3600e4;
                bEnd   =  b    * binSize_h * 3600e4;
                if bStart >= SInfo{s}.totDur_ts, continue, end
                bEnd = min(bEnd, SInfo{s}.totDur_ts);
                binEp = intervalSet(bStart, bEnd);
                Mat(s,b) = sum(DurationEpoch(and(stEpoch, binEp))) / (bEnd - bStart);
            end
        end
        Mavg(:,i) = nanmean(Mat,1);
    end
    % Renormalize each bin to 1 (in case sessions had unscored gaps)
    rowSum = sum(Mavg, 2);
    rowSum(rowSum == 0) = 1;
    Mavg = bsxfun(@rdivide, Mavg, rowSum);

    ha = area(ax2, ctr_h, Mavg);
    for i = 1:4
        set(ha(i),'FaceColor',colors.colors{i},'EdgeColor','none','FaceAlpha',0.9)
    end
end
xlim(ax2, [0 maxDur_h]); ylim(ax2, [0 1])
xlabel(ax2, sprintf('Time in recording (h)  -  %g-min bins', binSize_h*60))
ylabel(ax2, 'State proportion')
title(ax2, 'State evolution', 'FontWeight','normal','FontSize',9)
set(ax2,'TickDir','out','Box','off','FontSize',8)

% =====================================================================
% (3) Mean transition diagram (axis square, nodes scaled by state proportion)
% =====================================================================
ax3 = axes('Parent',fig,'Position',[x0+2*(ws+gap) y0 ws h]); hold(ax3,'on')
xy = [1.7 0; 0 1.7; -1.7 0; 0 -1.7];

Pstack = nan(4,4,nSess);
for s = 1:nSess
    if ~isempty(T{s}) && isfield(T{s},'probs'), Pstack(:,:,s) = T{s}.probs; end
end
Pavg = nanmean(Pstack,3);

% Mean of shuffle medians across sessions
haveShuf = false;
Pmed = zeros(4); nShufSess = 0;
for s = 1:nSess
    if isfield(T{s},'shuffleProbs') && ~isempty(T{s}.shuffleProbs)
        Pmed = Pmed + nanmedian(T{s}.shuffleProbs,3);
        nShufSess = nShufSess + 1;
        haveShuf = true;
    end
end
if haveShuf, Pmed = Pmed / max(1, nShufSess); end

% Draw filtered edges
for i = 1:4
    for j = 1:4
        if i == j, continue, end
        p = Pavg(i,j);
        if p < diagOpts.minProb, continue, end
        if haveShuf
            d = p - Pmed(i,j);
            if diagOpts.requireAboveShuffle && d <= 0, continue, end
            if abs(d) < diagOpts.minDiffFromShuffle, continue, end
        end
        lw = 0.4 + 5.6*min(p,1);
        draw_curved_arrow_AG_local(xy(i,:), xy(j,:), colors.colors{i}, lw);
    end
end

% Scale node markers by state proportion (sqrt for visual area). Sizes are
% kept small enough that the arrow endpoints (shrunk by 0.5 in unit coords;
% see draw_curved_arrow_AG_local) sit OUTSIDE the markers. With a 2-inch
% diagram axes, 1 unit ~= 0.65 in. MarkerSize is in points (1 pt = 1/72 in).
% Max 28 pt = 0.39 in = 0.6 units diameter = 0.3 units radius < shrink.
baseMarker  = 10;
scaleMarker = 20;
nodeSizes = baseMarker + scaleMarker * sqrt(propMean / max(propMean));

for k = 1:4
    plot(ax3, xy(k,1), xy(k,2), 'o', 'MarkerSize', nodeSizes(k), ...
         'LineWidth', 1.2, ...
         'MarkerFaceColor', colors.colors{k}, 'MarkerEdgeColor','k')
    text(ax3, xy(k,1), xy(k,2), sprintf('%s\n%d%%', names{k}), ...
         'HorizontalAlignment','center', 'Color','w', ...
         'FontWeight','bold','FontSize',7)
end
axis(ax3,'equal'); axis(ax3,'off')
xlim(ax3,[-2 2]); ylim(ax3,[-2 2])
title(ax3,'Mean transitions','FontWeight','normal','FontSize',9)

% =====================================================================
% (4) Transition matrix (imagesc, axis square)
% =====================================================================
ax4 = axes('Parent',fig,'Position',[x0+3*(ws+gap) y0 ws h]);
imagesc(ax4, Pavg)
axis(ax4, 'square'); axis(ax4, 'xy')
caxis(ax4, [0 1])
colormap(ax4, viridis)
cb = colorbar(ax4); ylabel(cb,'P(to|from)','FontSize',7)
set(ax4, 'XTick',1:4,'XTickLabel',names, ...
         'YTick',1:4,'YTickLabel',names, ...
         'TickDir','out','FontSize',8)
xlabel(ax4,'To state'); ylabel(ax4,'From state')
title(ax4,'Mean transition matrix','FontWeight','normal','FontSize',9)
for i = 1:4
    for j = 1:4
        v = Pavg(i,j); if isnan(v), continue, end
        txt = 'w'; if v < 0.4, txt = 'k'; end
        text(ax4, j, i, sprintf('%.2f', v), 'HorizontalAlignment','center', ...
            'Color', txt, 'FontWeight','bold','FontSize',7.5)
    end
end
end


function draw_curved_arrow_AG_local(p0, p1, col, lw)
% Curved arrow from p0 to p1, tip recessed by 'shrink' units so it sits
% outside the node markers (max ~0.3 unit radius with the sizes used in
% paper_row3_dynamics_AG). Arrowhead is larger than in the original so it
% reads at print size.
v = p1 - p0; L = norm(v); if L == 0, return, end
u = v / L; nrm = [-u(2) u(1)];
shrink = 0.50;
p0s = p0 + shrink*u; p1s = p1 - shrink*u;
mid = 0.5*(p0s + p1s) + 0.18*L*nrm;
t = linspace(0,1,40)';
B = (1-t).^2.*p0s + 2*(1-t).*t.*mid + t.^2.*p1s;
plot(B(:,1), B(:,2), '-', 'Color', col, 'LineWidth', lw)
tipDir = p1s - B(end-1,:);
nm = norm(tipDir); if nm == 0, return, end
tipDir = tipDir / nm;
perp = [-tipDir(2) tipDir(1)];
ahLen = 0.12 + 0.020*lw;
ahWid = 0.09 + 0.018*lw;
arrA = p1s - ahLen*tipDir + ahWid*perp;
arrB = p1s - ahLen*tipDir - ahWid*perp;
patch([p1s(1) arrA(1) arrB(1)], [p1s(2) arrA(2) arrB(2)], col, 'EdgeColor', col)
end
