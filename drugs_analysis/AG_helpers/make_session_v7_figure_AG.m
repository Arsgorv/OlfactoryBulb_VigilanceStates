function make_session_v7_figure_AG(A, M, ColorBefore, ColorAfter, Bands, SaveFigures, SaveFolder)
%MAKE_SESSION_V7_FIGURE_AG  Extended per-session QC + biology figure for v7.
% A: per-session Ana struct (with extra fields used here)
% M: per-session Metrics struct
% Saves PNG when SaveFigures=1.

if ~isfield(A, 'Tref') || isempty(A.Tref), return, end

figure('Name', ['QCv7 ' A.drug_name ' ' A.name], 'Position', [50 50 1700 950]);
sgtitle([A.animal ' ' A.restraint ' ' A.name ' - ' A.drug_name])

% Row 1: traces
subplot(4,5,[1 2 3])
plot(A.Tref/60, A.gamma_norm, 'Color', [0.9290, 0.6940, 0.1250], 'LineWidth', 1.4); hold on
plot(A.Tref/60, A.delta_norm, 'Color', [0.3010, 0.7450, 0.9330], 'LineWidth', 1.4)
if isfield(A, 'hpc_norm') && any(isfinite(A.hpc_norm))
    plot(A.Tref/60, A.hpc_norm, 'k', 'LineWidth', 1)
end
if isfield(A,'aeg_norm') && any(isfinite(A.aeg_norm))
    plot(A.Tref/60, A.aeg_norm, 'Color', [.6 .2 .6], 'LineWidth', 1)
end
vline_compat(A.t_inj/60, '--r')
yline_compat(1, '--k')
xlabel('Time (min)'), ylabel('baseline ratio')
legend({'OB gamma','OB delta','HPC CBV','AEG CBV'},'Location','best')
title('Baseline-normalized traces')
makepretty_BM2

subplot(4,5,4)
plot_distribution_pair(safe_log(A.gamma(A.idx_before)), safe_log(A.gamma(A.idx_after)), ColorBefore, ColorAfter)
xlabel('log gamma'), ylabel('p')
title('Gamma'), makepretty_BM2

subplot(4,5,5)
plot_distribution_pair(safe_log(A.delta(A.idx_before)), safe_log(A.delta(A.idx_after)), ColorBefore, ColorAfter)
xlabel('log delta'), ylabel('p')
title('Delta'), makepretty_BM2

% Row 2: spectra
subplot(4,5,6)
if isfield(A, 'low_f')
    plot(A.low_f, A.low_before_plot, '--', 'Color', ColorBefore, 'LineWidth', 1.6); hold on
    plot(A.low_f, A.low_after_plot,  '-',  'Color', ColorAfter,  'LineWidth', 2.0)
    xlim([0 20])
end
xlabel('Hz'), ylabel('f * power')
title('Low spectrum (mean)'), makepretty_BM2

subplot(4,5,7)
if isfield(A, 'middle_f')
    plot(A.middle_f, A.middle_before_plot, '--', 'Color', ColorBefore, 'LineWidth', 1.6); hold on
    plot(A.middle_f, A.middle_after_plot,  '-',  'Color', ColorAfter,  'LineWidth', 2.0)
    xlim([20 100])
    vline_compat(Bands.lowGamma(1),'--r'); vline_compat(Bands.lowGamma(2),'--r')
    vline_compat(Bands.gamma(1),'--k'); vline_compat(Bands.gamma(2),'--k')
    vline_compat(Bands.highGamma(1),'--b'); vline_compat(Bands.highGamma(2),'--b')
end
xlabel('Hz'), title('Middle spectrum (mean)'), makepretty_BM2

subplot(4,5,8)
if isfield(A,'low_f')
    plot(A.low_f, A.low_log2ratio, 'k', 'LineWidth', 1.6); hold on
    yline_compat(0,'--r'); xlim([0 20])
end
xlabel('Hz'), ylabel('log2 a/b')
title('Low log2 ratio'), makepretty_BM2

subplot(4,5,9)
if isfield(A,'middle_f')
    plot(A.middle_f, A.middle_log2ratio, 'k', 'LineWidth', 1.6); hold on
    yline_compat(0,'--r'); xlim([20 100])
end
xlabel('Hz'), title('Middle log2 ratio'), makepretty_BM2

subplot(4,5,10)
if isfield(A,'meanImg') && ~isempty(A.meanImg)
    imagesc(A.meanImg); axis image off
    title('mean fUS image')
else
    axis off
    text(0.5,0.5,'no fUS','HorizontalAlignment','center')
end

% Row 3: bodily and state
subplot(4,5,11)
if isfield(A,'breath_rate') && any(isfinite(A.breath_rate))
    plot(A.Tref/60, A.breath_rate, 'k', 'LineWidth', 1)
    vline_compat(A.t_inj/60,'--r')
    xlabel('Time (min)'), ylabel('Breath (Hz)'), title('Breath rate')
else
    axis off, text(0.5,0.5,'no respi','HorizontalAlignment','center')
end
makepretty_BM2

subplot(4,5,12)
if isfield(A,'heart_rate') && any(isfinite(A.heart_rate))
    plot(A.Tref/60, A.heart_rate, 'k', 'LineWidth', 1)
    vline_compat(A.t_inj/60,'--r')
    xlabel('Time (min)'), ylabel('HR (Hz)'), title('Heart rate')
else
    axis off, text(0.5,0.5,'no HR','HorizontalAlignment','center')
end
makepretty_BM2

subplot(4,5,13)
if isfield(A,'smooth_acc_log') && any(isfinite(A.smooth_acc_log))
    plot(A.Tref/60, A.smooth_acc_log, 'k', 'LineWidth', 1); hold on
    if isfield(A,'idx_moving')
        idx = A.idx_moving;
        plot(A.Tref(idx)/60, A.smooth_acc_log(idx), '.', 'Color', [.6 .8 .2], 'MarkerSize', 4)
    end
    vline_compat(A.t_inj/60,'--r')
    xlabel('Time (min)'), ylabel('log10 acc'), title('Accelero (Moving=green)')
else
    axis off, text(0.5,0.5,'no MovAcc','HorizontalAlignment','center')
end
makepretty_BM2

subplot(4,5,14)
plot(A.Tref/60, A.OBState, '.', 'Color', [.4 .4 .4], 'MarkerSize', 2)
vline_compat(A.t_inj/60,'--r')
xlabel('Time (min)'), ylabel('state id'), ylim([0.5 4.5])
title('OB 4-state map'), makepretty_BM2

subplot(4,5,15)
hold on
b = sum(A.idx_before)/length(A.Tref); a = sum(A.idx_after)/length(A.Tref);
bar([b a], 'FaceColor', [.7 .7 .7])
set(gca,'XTickLabel',{'before','after'})
ylabel('frac of session')
title(sprintf('Pre %.1f min, Post %.1f min', sum(A.idx_before)*nanmedian(diff(A.Tref))/60, sum(A.idx_after)*nanmedian(diff(A.Tref))/60))
makepretty_BM2

% Row 4: scalar summary
subplot(4,5,16)
metricsList = {'gamma_logratio','delta_logratio','lowgamma_spec_logratio','gamma_spec_logratio','highgamma_spec_logratio','theta_spec_logratio'};
labels = {'gamma','delta','low\gamma','\gamma','high\gamma','\theta'};
yvals = nan(1,length(metricsList));
for k = 1:length(metricsList)
    if isfield(M, metricsList{k}) && ~isempty(M.(metricsList{k}))
        yvals(k) = M.(metricsList{k});
    end
end
bar(yvals, 'FaceColor', [.5 .5 .9])
set(gca,'XTick',1:length(metricsList),'XTickLabel',labels)
ylabel('log after/before')
yline_compat(0,'--r')
title('Session scalar summary')
makepretty_BM2

subplot(4,5,17)
if isfield(M,'hpc_dcbv_after_percent') && isfinite(M.hpc_dcbv_after_percent)
    bar([M.hpc_dcbv_after_percent, M.aeg_dcbv_after_percent])
    set(gca,'XTickLabel',{'HPC','AEG'})
    ylabel('post dCBV %'), yline_compat(0,'--r')
else
    axis off, text(0.5,0.5,'no fUS','HorizontalAlignment','center')
end
title('CBV change'), makepretty_BM2

subplot(4,5,18)
if isfield(M,'gamma_hpc_r_before') && isfinite(M.gamma_hpc_r_before)
    bar([M.gamma_hpc_r_before M.gamma_hpc_r_after; M.gamma_aeg_r_before M.gamma_aeg_r_after]')
    set(gca,'XTickLabel',{'HPC','AEG'})
    ylabel('r')
    legend({'before','after'},'Location','best')
else
    axis off, text(0.5,0.5,'no fUS','HorizontalAlignment','center')
end
title('Gamma-CBV r'), makepretty_BM2

subplot(4,5,19)
if isfield(M,'pre_half_gamma_log') && isfinite(M.pre_half_gamma_log)
    bar([M.pre_half_gamma_log M.gamma_logratio])
    set(gca,'XTickLabel',{'pre1->pre2','before->after'})
    ylabel('log ratio'), yline_compat(0,'--r')
else
    axis off
end
title('Pre-half noise (gamma)'), makepretty_BM2

subplot(4,5,20)
if isfield(M,'gamma_peak_before_hz') && isfinite(M.gamma_peak_before_hz)
    bar([M.gamma_peak_before_hz M.gamma_peak_after_hz])
    set(gca,'XTickLabel',{'before','after'})
    ylabel('peak Hz')
end
title('Gamma peak'), makepretty_BM2

if SaveFigures
    saveas(gcf, fullfile(SaveFolder, ['QCv7_' A.drug_name '_' A.animal '_' A.name '.png']))
end
end
