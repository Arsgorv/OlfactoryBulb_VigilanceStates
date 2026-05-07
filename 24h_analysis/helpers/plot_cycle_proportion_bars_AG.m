function fig = plot_cycle_proportion_bars_AG(C_all, sessionNames, colors)
% plot_cycle_proportion_bars_AG  State proportions along the warped sleep
% cycle, one stacked vertical bar per warped bin (matches the "panel d"
% style in the reference figure).
%
% INPUT
%   C_all          1xN cell of compute_sleep_cycles_AG outputs
%   sessionNames   1xN cellstr
%   colors         state_colors_AG output (optional)
%
% OUTPUT
%   fig            figure handle

if nargin < 3 || isempty(colors), colors = state_colors_AG(); end
nSess = numel(C_all);
names = colors.names;
nState = 4;

fig = figure('Color','w','Units','normalized','Position',[.1 .15 .8 .55]);

for s = 1:nSess
    subplot(1, nSess, s)
    if isempty(C_all{s}.cycleStartTime_h)
        text(.5,.5,'no complete cycles','Units','normalized', ...
             'HorizontalAlignment','center')
        axis off
        continue
    end
    nB = size(C_all{s}.meanProp, 1);
    xPos = linspace(0,1,nB);
    hb = bar(xPos, C_all{s}.meanProp, 'stacked', 'BarWidth', 1);
    for i = 1:nState
        set(hb(i), 'FaceColor', colors.colors{i}, 'EdgeColor','none')
    end
    xlim([-0.05 1.05])
    ylim([0 1])
    xlabel('Time (sleep cycle)')
    ylabel('States proportion')
    title(sessionNames{s}, 'FontWeight','bold','Interpreter','none')
    if s == nSess
        legend(names, 'Location','northeastoutside','Box','on')
    end
    set(gca,'TickDir','out','Box','off','FontSize',10)
end

end
