function fig = plot_cycle_power_traces_AG(CT_all, sessionNames)
% plot_cycle_power_traces_AG  Z-scored power along sleep cycles for OB gamma,
% HPC theta/delta and OB delta. Mean +/- SEM across cycles, drawn over TWO
% concatenated cycles to ease reading of cycle boundaries.
%
% INPUT
%   CT_all         1xN cell of compute_cycle_traces_AG outputs
%   sessionNames   1xN cellstr
%
% OUTPUT
%   fig  figure handle

nSess = numel(CT_all);
fig = figure('Color','w','Units','normalized','Position',[.05 .15 .9 .55]);

% Colors as in user's reference panel: gamma yellow-green, theta teal, delta purple
sigCols = struct( ...
    'gamma', [0.70 0.70 0.10], ...
    'theta', [0.30 0.70 0.55], ...
    'delta', [0.50 0.30 0.70]);

for s = 1:nSess
    subplot(1, nSess, s)
    CT = CT_all{s};
    if CT.nCycles < 2 || all(isnan(CT.gamma_mean))
        text(.5,.5,'no cycles','Units','normalized','HorizontalAlignment','center')
        axis off, continue
    end

    x  = linspace(0, 2, 2*CT.nBins);
    held = false;
    mainLines = gobjects(1,3);
    sigOrder = {'gamma','theta','delta'};
    sigLabels = {'OB gamma','HPC theta/delta','OB delta'};

    for k = 1:3
        sn = sigOrder{k};
        m  = CT.([sn '_mean']);
        e  = CT.([sn '_sem']);
        m2 = [m m];
        e2 = [e e];
        col = sigCols.(sn);
        h = shadedErrorBar(x, m2, e2, {'-','Color',col,'LineWidth',1.6}, 1);
        h.mainLine.Color = col; h.patch.FaceColor = col; h.patch.FaceAlpha = 0.25;
        mainLines(k) = h.mainLine;
        if ~held, hold on, held = true; end
    end

    plot([1 1],[-3 3],'k:','LineWidth',1.0)
    xlim([0 2]), ylim([-2 2.2])
    xlabel('Time (sleep cycle)')
    ylabel('Power (z-score)')
    title(sessionNames{s}, 'FontWeight','bold','Interpreter','none')
    if s == nSess
        legend(mainLines, sigLabels, 'Location','northeastoutside','Box','off')
    end
    set(gca,'TickDir','out','Box','off','FontSize',10)
end

end
