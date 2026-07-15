function paper_row4_cycle_dynamics_AG(fig, region, CT, C, REG, sessNames, colors) %#ok<INUSL>
% paper_row4_cycle_dynamics_AG  Row 4 panels (all square-ish for visual
% balance):
%   (1) Mean cycle-aligned z-scored power (OB gamma, HPC theta/delta, OB
%       delta) over two consecutive cycles. Mean +/- SEM across sessions.
%   (2) Cycle-wise N1/N2/REM Pearson R matrix (pooled across all cycles).
%   (3) N2 vs REM cycle-wise scatter with regression line, R and p.
%   (4) HPC theta autocorrelogram across the recording, ALL SESSIONS pooled
%       (mean of per-session autocorr matrices). Underneath: 25-min
%       regularity score and first-peak lag as a function of time, also
%       averaged across sessions.

x0 = region(1); y0 = region(2); w = region(3); h = region(4);
nP = 4; gap = 0.02;
ws = (w - (nP-1)*gap) / nP;
nSess = numel(CT);

% ============================================================
% (1) Mean cycle-aligned power (2 cycles)
% ============================================================
axes('Parent',fig,'Position',[x0 y0 ws h])
sigCols = struct('gamma',[0.70 0.70 0.10], 'theta',[0.30 0.70 0.55], 'delta',[0.50 0.30 0.70]);
sigOrder = {'gamma','theta','delta'};
sigLab = {'OB gamma','HPC \theta/\delta','OB delta'};
nB = 0;
for s = 1:nSess
    if isfield(CT{s},'nBins'), nB = max(nB, CT{s}.nBins); end
end
if nB > 0
    held = false; mainH = gobjects(1,3);
    for k = 1:3
        sn = sigOrder{k};
        stack = nan(nSess, nB);
        for s = 1:nSess
            mu = CT{s}.([sn '_mean']);
            if numel(mu) == nB, stack(s,:) = mu; end
        end
        mu  = nanmean(stack,1);
        nValid = sum(~isnan(stack),1); nValid(nValid==0) = NaN;
        sem = nanstd(stack,0,1) ./ sqrt(nValid);
        x   = linspace(0,2,2*nB);
        mu2 = [mu mu]; sem2 = [sem sem];
        hh = shadedErrorBar(x, mu2, sem2, {'-','Color',sigCols.(sn),'LineWidth',1.5}, 1);
        hh.mainLine.Color = sigCols.(sn);
        hh.patch.FaceColor = sigCols.(sn); hh.patch.FaceAlpha = 0.25;
        mainH(k) = hh.mainLine;
        if ~held, hold on; held = true; end
    end
    plot([1 1],[-3 3],'k:')
    xlim([0 2]); ylim([-2 2.2])
    legend(mainH, sigLab, 'Box','off','Location','best','FontSize',7)
end
xlabel('Time (cycle)'); ylabel('Power (z)')
title('Mean cycle power','FontWeight','normal','FontSize',9)
axis square
set(gca,'TickDir','out','Box','off','FontSize',8)

% ============================================================
% (2) Cycle-wise N1/N2/REM Pearson R matrix
% ============================================================
axes('Parent',fig,'Position',[x0+ws+gap y0 ws h])
P_pool = zeros(0,4);
for s = 1:nSess
    if ~isempty(C{s}.propByCycle)
        P_pool = [P_pool; squeeze(nanmean(C{s}.propByCycle,2))]; %#ok<AGROW>
    end
end
if size(P_pool,1) >= 3
    R = corr(P_pool(:,2:4),'Type','Pearson','Rows','complete');
else
    R = nan(3);
end
imagesc(R); axis square xy; caxis([-1 1])
colormap(gca, redblue_local()); cb = colorbar; ylabel(cb,'R','FontSize',7)
set(gca,'XTick',1:3,'XTickLabel',{'N1','N2','REM'}, ...
        'YTick',1:3,'YTickLabel',{'N1','N2','REM'}, ...
        'TickDir','out','FontSize',8)
for i = 1:3
    for j = 1:3
        text(j,i,sprintf('%.2f',R(i,j)),'HorizontalAlignment','center', ...
            'Color', txt_col_local(R(i,j)),'FontWeight','bold','FontSize',8);
    end
end
title('Cycle-wise R (N1/N2/REM)','FontWeight','normal','FontSize',9)

% ============================================================
% (3) N1 vs N2 cycle-wise scatter (pooled across all sessions' cycles)
% ============================================================
axes('Parent',fig,'Position',[x0+2*(ws+gap) y0 ws h])
if size(P_pool,1) >= 3
    a = P_pool(:,2); b = P_pool(:,3);   % col 2 = N1, col 3 = N2
    keep = ~isnan(a) & ~isnan(b);
    a = a(keep); b = b(keep);
    plot(a, b, 'o', 'MarkerEdgeColor','k', 'MarkerFaceColor',[.6 .6 .6], ...
        'MarkerSize', 4)
    hold on
    if numel(a) >= 3
        [Rab, pab] = corr(a, b, 'Type','Pearson');
        pf = polyfit(a, b, 1);
        xfit = linspace(min(a), max(a), 50);
        plot(xfit, polyval(pf, xfit), 'k-', 'LineWidth', 1.5)
        title(sprintf('N1 vs N2   R = %.2f   p = %.1g', Rab, pab), ...
              'FontWeight','normal','FontSize',9)
    else
        title('N1 vs N2','FontWeight','normal','FontSize',9)
    end
end
xlabel('N1 proportion'); ylabel('N2 proportion')
axis square
set(gca,'TickDir','out','Box','off','FontSize',8)

% ============================================================
% (4) HPC theta autocorr composite: imagesc + 25-min reg score + first peak lag
%     ALL SESSIONS POOLED (mean across sessions)
% ============================================================
% Sub-panel split inside the 4th column: 3 stacked sub-axes
panelX = x0 + 3*(ws+gap); panelW = ws;
subGap = 0.005;
hSub = (h - 2*subGap) / 3 * [1.4 0.8 0.8];   % top imagesc gets more room
hSub = hSub / sum(hSub) * (h - 2*subGap);
panelY3 = y0 + h - hSub(1);
panelY2 = panelY3 - subGap - hSub(2);
panelY1 = panelY2 - subGap - hSub(3);

% Find a session with non-empty REG to seed axes vectors
lagAll = []; tAll = []; targetLag = 25;
for s = 1:nSess
    if isempty(REG{s}.lag_min), continue, end
    lagAll = REG{s}.lag_min;
    tAll = REG{s}.winCenter_h;
    if isfield(REG{s},'targetLag_min'), targetLag = REG{s}.targetLag_min; end
    break
end

% --- (4a) autocorrelogram imagesc, mean across sessions ---
axesAC = axes('Parent',fig,'Position',[panelX panelY3 panelW hSub(1)]);
if isempty(lagAll)
    axis(axesAC,'off')
else
    stack = nan(numel(lagAll), numel(tAll), nSess);
    for s = 1:nSess
        if isempty(REG{s}.acorr), continue, end
        if all(size(REG{s}.acorr) == [numel(lagAll) numel(tAll)])
            stack(:,:,s) = REG{s}.acorr;
        end
    end
    imagesc(axesAC, tAll, lagAll, nanmean(stack,3))
    axis(axesAC,'xy'); colormap(axesAC, viridis)
    hold(axesAC,'on'); plot(axesAC, get(axesAC,'XLim'), [targetLag targetLag], 'w--','LineWidth',1)
    ylabel(axesAC, 'Lag (min)')
    title(axesAC, sprintf('HPC \\theta autocorr (mean across %d sessions)', nSess), ...
          'FontWeight','normal','FontSize',9)
    set(axesAC,'TickDir','out','FontSize',7,'XTickLabel',[])
end
axis square; caxis([-0.35 0.5])
% --- (4b) 25-min regularity score over time ---
axesRG = axes('Parent',fig,'Position',[panelX panelY2 panelW hSub(2)]);
if isempty(tAll)
    axis(axesRG,'off')
else
    stack = nan(nSess, numel(tAll));
    for s = 1:nSess
        if ~isempty(REG{s}.regScore) && numel(REG{s}.regScore) == numel(tAll)
            stack(s,:) = REG{s}.regScore;
        end
    end
    mu = nanmean(stack,1);
    plot(axesRG, tAll, mu, 'k-', 'LineWidth', 1.6)
    hold(axesRG,'on'); plot(axesRG, get(axesRG,'XLim'), [0 0], 'k:', 'LineWidth', 0.5)
    ylabel(axesRG, sprintf('%g-min reg', targetLag))
    set(axesRG,'TickDir','out','Box','off','FontSize',7,'XTickLabel',[])
end
axis square
% --- (4c) first-peak lag over time ---
axesFP = axes('Parent',fig,'Position',[panelX panelY1 panelW hSub(3)]);
if isempty(tAll)
    axis(axesFP,'off')
else
    stack = nan(nSess, numel(tAll));
    for s = 1:nSess
        if ~isempty(REG{s}.firstPeakLag) && numel(REG{s}.firstPeakLag) == numel(tAll)
            stack(s,:) = REG{s}.firstPeakLag;
        end
    end
    mu = nanmean(stack,1);
    plot(axesFP, tAll, mu, 'k-', 'LineWidth', 1.6)
    hold(axesFP,'on'); plot(axesFP, get(axesFP,'XLim'), [targetLag targetLag], '--', ...
        'Color',[.8 .3 .3],'LineWidth',1)
    xlabel(axesFP, 'Time in recording (h)')
    ylabel(axesFP, '1st peak (min)')
    set(axesFP,'TickDir','out','Box','off','FontSize',7)
end
axis square

end


function c = txt_col_local(R)
if abs(R) > 0.55, c = 'w'; else, c = 'k'; end
end


function cmap = redblue_local()
n = 128;
b = [linspace(0.0,1.0,n)' linspace(0.2,1.0,n)' linspace(0.6,1.0,n)'];
r = [linspace(1.0,0.6,n)' linspace(1.0,0.0,n)' linspace(1.0,0.0,n)'];
cmap = [b; r];
end
