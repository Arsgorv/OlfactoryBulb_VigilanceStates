function fig = plot_sleep_cycles_AG(C_all, sessionNames, colors)
% plot_sleep_cycles_AG  Sleep-cycle composition (REM-end to REM-end).
% Row 1: averaged stacked-area composition.
% Row 2: per-cycle mosaic (each column = one cycle, time-warped).
% Row 3: cycle-duration distribution per session, MakeSpread/Box style.
%
% INPUT
%   C_all          1xN cell of compute_sleep_cycles_AG outputs
%   sessionNames   1xN cellstr
%   colors         state_colors_AG output
%
% OUTPUT
%   fig            figure handle

if nargin < 3 || isempty(colors), colors = state_colors_AG(); end
nSess = numel(C_all);
names = colors.names;
nState = 4;

fig = figure('Color','w','Units','normalized','Position',[.05 .03 .9 .92]);
nRow = 3;

for s = 1:nSess
    C = C_all{s};

    % --- top: averaged composition stacked area ------------------------------
    subplot(nRow, nSess, s)
    if isempty(C.cycleStartTime_h)
        text(.5,.5,'no complete cycles','Units','normalized', ...
             'HorizontalAlignment','center')
        axis off
    else
        nBins = size(C.meanProp,1);
        h = area(linspace(0,1,nBins), C.meanProp);
        for i = 1:nState
            set(h(i), 'FaceColor', colors.colors{i}, 'EdgeColor','none', 'FaceAlpha', 0.9)
        end
        xlim([0 1]), ylim([0 1])
        xlabel('Cycle progress (0 = prev REM end, 1 = next REM end)')
        ylabel('Fraction of cycle bin')
        title(sprintf('%s  (mean of %d cycles, median %.1f min)', ...
            sessionNames{s}, numel(C.cycleStartTime_h), median(C.cycleDur_min)), ...
            'FontWeight','bold','Interpreter','none')
        if s == nSess
            legend(names, 'Location','northeastoutside','Box','off')
        end
        set(gca,'TickDir','out','Box','off','FontSize',9)
    end

    % --- bottom: per-cycle mosaic --------------------------------------------
    subplot(nRow, nSess, nSess + s)
    if isempty(C.cycleStartTime_h)
        axis off
    else
        nC = size(C.propByCycle,1);
        nB = size(C.propByCycle,2);
        % build an RGB image: for each (cycle, bin) compose color = sum_i prop_i * color_i
        rgb = zeros(nB, nC, 3);
        for c = 1:nC
            for b = 1:nB
                p = squeeze(C.propByCycle(c,b,:));
                p(isnan(p)) = 0;
                if sum(p) == 0, continue, end
                col = [0 0 0];
                for i = 1:nState
                    col = col + p(i) * colors.colors{i};
                end
                rgb(b, c, :) = col;
            end
        end
        image(1:nC, linspace(0,1,nB), rgb)
        axis xy
        xlabel('Cycle index')
        ylabel('Cycle progress')
        title('Per-cycle mosaic')
        set(gca,'TickDir','out','Box','off','FontSize',9)
    end
end

% --- row 3: cycle duration per session, MakeSpread/Box ---------------------
subplot(nRow, nSess, (2*nSess+1):(3*nSess))
A = cell(1, nSess);
sessCols = cell(1, nSess);
greys = linspace(0.25, 0.7, max(2, nSess));
for s = 1:nSess
    if isempty(C_all{s}.cycleDur_min)
        A{s} = NaN;
    else
        A{s} = C_all{s}.cycleDur_min(:);
    end
    sessCols{s} = greys(s) * [1 1 1];
end
MakeSpreadAndBoxPlot3_SB(A, sessCols, 1:nSess, sessionNames, ...
    'showpoints', 1, 'paired', 0, 'newfig', 0);
ylabel('Cycle duration (min)')
title('Sleep-cycle durations (REM-end to REM-end)')
set(gca,'TickDir','out','Box','off','FontSize',9)

end
