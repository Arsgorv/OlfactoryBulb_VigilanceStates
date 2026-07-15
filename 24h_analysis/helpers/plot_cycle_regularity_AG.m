function fig = plot_cycle_regularity_AG(REG_all, sessionNames)
% plot_cycle_regularity_AG  Three-panel view of REM/cycle regularity across
% the recording, per session, from the sliding-window autocorrelation of the
% HPC theta/delta signal.
%
%   Row 1: autocorrelogram heatmap (lag x time), with reference lines at the
%          target cycle lag and 2x that lag.
%   Row 2: regularity score (autocorr at the target lag) over time.
%   Row 3: first-peak lag (dominant cycle period) over time, with a reference
%          line at the target lag.
%
% INPUT
%   REG_all        1xN cell of compute_cycle_regularity_AG outputs
%   sessionNames   1xN cellstr
%
% OUTPUT
%   fig  figure handle

nSess = numel(REG_all);
fig = figure('Color','w','Units','normalized','Position',[.06 .04 .3*nSess+.1 .92]);

for s = 1:nSess
    REG = REG_all{s};
    if isempty(REG.acorr)
        for r = 1:3
            subplot(3, nSess, (r-1)*nSess + s); axis off
        end
        continue
    end
    tgt = REG.targetLag_min;

    % --- Row 1: autocorrelogram heatmap ---
    subplot(3, nSess, s)
    imagesc(REG.winCenter_h, REG.lag_min, REG.acorr)
    axis xy
    colormap(viridis)
    cb = colorbar; ylabel(cb, 'autocorr')
    hold on
    plot(xlim, [tgt tgt],   'w--', 'LineWidth', 1)
    plot(xlim, [2*tgt 2*tgt], 'w:', 'LineWidth', 1)
    ylabel('Lag (min)')
    xlabel('Time in recording (h)')
    title(sprintf('%s - %s autocorr', sessionNames{s}, REG.sigName), ...
          'Interpreter','none')
    set(gca,'TickDir','out','FontSize',9)

    % --- Row 2: regularity score over time ---
    subplot(3, nSess, nSess + s)
    plot(REG.winCenter_h, REG.regScore, 'k-', 'LineWidth', 1.8)
    xlabel('Time in recording (h)')
    ylabel(sprintf('%g min regularity score', tgt))
    box off, set(gca,'TickDir','out','FontSize',9)

    % --- Row 3: first peak lag over time ---
    subplot(3, nSess, 2*nSess + s)
    plot(REG.winCenter_h, REG.firstPeakLag, 'k-', 'LineWidth', 1.8)
    hold on
    plot(xlim, [tgt tgt], '--', 'Color', [.8 .3 .3], 'LineWidth', 1)
    xlabel('Time in recording (h)')
    ylabel('First peak lag (min)')
    box off, set(gca,'TickDir','out','FontSize',9)
end

end
