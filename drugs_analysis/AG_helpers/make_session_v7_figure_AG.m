function make_session_v7_figure_AG(A, M, ColorBefore, ColorAfter, Bands, SaveFigures, SaveFolder)
%MAKE_SESSION_V7_FIGURE_AG  Per-session QC figure (v7.1).
% Layout:
%   Row 1: ephys traces (OB gamma+delta) on left, CBV traces (HPC+AEG) on right
%   Row 2: OB Low spectrum (mean), OB Middle spectrum (mean), peak gamma shift,
%          gamma/delta distributions
%   Row 3: bodily variables (HR, breath rate, accelero, OBState) + scalar summary
%   Row 4: pre-half noise, gamma-CBV r, CBV %, mean fUS image

if ~isfield(A, 'Tref') || isempty(A.Tref), return, end

figure('Name', ['QCv7 ' A.drug_name ' ' A.name], ...
    'Position', get(0,'ScreenSize'), 'WindowState', 'maximized');
sgtitle([A.animal ' ' A.restraint ' ' A.name ' - ' A.drug_name])

% Row 1, panel 1: ephys baseline-normalized traces (gamma + delta)
subplot(4,5,[1 2])
plot(A.Tref/60, A.gamma_norm, 'Color', [0.9290, 0.6940, 0.1250], 'LineWidth', 1.2); hold on
plot(A.Tref/60, A.delta_norm, 'Color', [0.3010, 0.7450, 0.9330], 'LineWidth', 1.2)
vline_compat(A.t_inj/60, '--r'); yline_compat(1, '--k')
xlabel('Time (min)'), ylabel('Ephys (norm to pre)')
legend({'OB gamma 40-60 Hz','OB delta 0.5-4 Hz'}, 'Location','best')
title('Ephys: OB band power'), makepretty_BM2

% Row 1, panel 2: CBV traces (HPC + AEG)
subplot(4,5,[3 4])
if isfield(A,'hpc_dcbv_percent') && any(isfinite(A.hpc_dcbv_percent))
    plot(A.Tref/60, A.hpc_dcbv_percent, 'k', 'LineWidth', 1.3); hold on
    plot(A.Tref/60, A.aeg_dcbv_percent, 'Color', [.6 .2 .6], 'LineWidth', 1.3)
    vline_compat(A.t_inj/60, '--r'); yline_compat(0, '--k')
    legend({'HPC dCBV','AEG/ACx dCBV'}, 'Location','best')
    title('Hemodynamics: fUS dCBV (%)')
else
    axis off, text(0.5,0.5,'no fUS in this session','HorizontalAlignment','center')
    title('Hemodynamics: fUS dCBV (%)')
end
xlabel('Time (min)'), ylabel('dCBV (%)')
makepretty_BM2

% Row 1 right side: mean fUS image
subplot(4,5,5)
if isfield(A,'meanImg') && ~isempty(A.meanImg)
    imagesc(A.meanImg); axis image off, colormap(gca,'gray')
    title('Mean fUS image')
else
    axis off, text(0.5,0.5,'no fUS','HorizontalAlignment','center')
    title('Mean fUS image')
end

% Row 2 panels: spectra and distributions
subplot(4,5,6)
if isfield(A, 'low_f')
    plot(A.low_f, A.low_before_plot, '--', 'Color', ColorBefore, 'LineWidth', 1.6); hold on
    plot(A.low_f, A.low_after_plot,  '-',  'Color', ColorAfter,  'LineWidth', 2.0)
    xlim([0 20])
    vline_compat(Bands.delta(1),'--r'); vline_compat(Bands.delta(2),'--r')
    vline_compat(Bands.theta(1),'--k'); vline_compat(Bands.theta(2),'--k')
end
xlabel('Hz'), ylabel('f*power (display)')
title('OB Low spectrum, 0-20 Hz (mean)'), makepretty_BM2

subplot(4,5,7)
if isfield(A, 'middle_f')
    plot(A.middle_f, A.middle_before_plot, '--', 'Color', ColorBefore, 'LineWidth', 1.6); hold on
    plot(A.middle_f, A.middle_after_plot,  '-',  'Color', ColorAfter,  'LineWidth', 2.0)
    xlim([20 100])
    vline_compat(Bands.lowGamma(1),'--r'); vline_compat(Bands.lowGamma(2),'--r')
    vline_compat(Bands.gamma(1),'--k'); vline_compat(Bands.gamma(2),'--k')
    vline_compat(Bands.highGamma(1),'--b'); vline_compat(Bands.highGamma(2),'--b')
end
xlabel('Hz'), title('OB Middle spectrum, 20-100 Hz (mean)'), makepretty_BM2

subplot(4,5,8)
if isfield(A,'low_f')
    plot(A.low_f, A.low_log2ratio, 'k', 'LineWidth', 1.6); hold on
    yline_compat(0,'--r'); xlim([0 20])
end
xlabel('Hz'), ylabel('log2 a/b')
title('Low log2 ratio (0-20 Hz)'), makepretty_BM2

subplot(4,5,9)
if isfield(A,'middle_f')
    plot(A.middle_f, A.middle_log2ratio, 'k', 'LineWidth', 1.6); hold on
    yline_compat(0,'--r'); xlim([20 100])
end
xlabel('Hz'), title('Middle log2 ratio (20-100 Hz)'), makepretty_BM2

subplot(4,5,10)
plot_distribution_pair(safe_log(A.gamma(A.idx_before)), safe_log(A.gamma(A.idx_after)), ColorBefore, ColorAfter)
xlabel('log OB gamma 40-60 Hz')
title('Gamma distribution'), makepretty_BM2

% Row 3: bodily and state
subplot(4,5,11)
if isfield(A,'breath_rate') && any(isfinite(A.breath_rate))
    plot(A.Tref/60, A.breath_rate, 'k', 'LineWidth', 1)
    vline_compat(A.t_inj/60,'--r')
    xlabel('Time (min)'), ylabel('Hz')
    title('Breath rate (Hz; Hilbert IF 0.3-2.5 Hz)')
else
    axis off, text(0.5,0.5,'no respi','HorizontalAlignment','center')
end
makepretty_BM2

subplot(4,5,12)
if isfield(A,'heart_rate') && any(isfinite(A.heart_rate))
    plot(A.Tref/60, A.heart_rate, 'k', 'LineWidth', 1)
    vline_compat(A.t_inj/60,'--r')
    xlabel('Time (min)'), ylabel('Hz')
    title('Heart rate')
else
    axis off, text(0.5,0.5,'no HR','HorizontalAlignment','center')
end
makepretty_BM2

subplot(4,5,13)
plot(A.Tref/60, A.OBState, '.', 'Color', [.4 .4 .4], 'MarkerSize', 2)
vline_compat(A.t_inj/60,'--r')
xlabel('Time (min)'), ylabel('state id'), ylim([0.5 4.5])
title('OB 4-state (gammaXdelta thresholds)'), makepretty_BM2

subplot(4,5,14)
plot_distribution_pair(safe_log(A.delta(A.idx_before)), safe_log(A.delta(A.idx_after)), ColorBefore, ColorAfter)
xlabel('log OB delta 0.5-4 Hz')
title('Delta distribution'), makepretty_BM2

subplot(4,5,15)
b = sum(A.idx_before)/length(A.Tref); a = sum(A.idx_after)/length(A.Tref);
bar([b a], 'FaceColor', [.7 .7 .7])
set(gca,'XTickLabel',{'before','after'})
ylabel('frac of session')
title(sprintf('Pre %.1f min, Post %.1f min', ...
    sum(A.idx_before)*nanmedian(diff(A.Tref))/60, ...
    sum(A.idx_after)*nanmedian(diff(A.Tref))/60))
makepretty_BM2

% Row 4: scalar summary, CBV change, gamma-CBV r, pre-half noise, gamma peak
subplot(4,5,16)
metricsList = {'gamma_logratio','delta_logratio', ...
               'beta_brainpower_logratio','lowgamma_brainpower_logratio', ...
               'gamma_brainpower_logratio','highgamma_brainpower_logratio'};
labels = {'\gamma 40-60','\delta 0.5-4','\beta 15-30','low\gamma 20-40','\gamma 40-60 env','high\gamma 60-80'};
yvals = nan(1,length(metricsList));
for k = 1:length(metricsList)
    if isfield(M, metricsList{k}) && ~isempty(M.(metricsList{k}))
        yvals(k) = M.(metricsList{k});
    end
end
bar(yvals, 'FaceColor', [.5 .5 .9])
set(gca,'XTick',1:length(metricsList),'XTickLabel',labels), xtickangle(20)
ylabel('log after/before')
yline_compat(0,'--r')
title('Session OB band summary')
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
    ylabel('r'), yline_compat(0,'--r')
    legend({'before','after'},'Location','best')
else
    axis off, text(0.5,0.5,'no fUS','HorizontalAlignment','center')
end
title('OB gamma 40-60 Hz vs CBV (r, 5-min smooth)'), makepretty_BM2

subplot(4,5,19)
if isfield(M,'pre_half_gamma_log') && isfinite(M.pre_half_gamma_log)
    bar([M.pre_half_gamma_log M.gamma_logratio])
    set(gca,'XTickLabel',{'pre1->pre2','before->after'})
    ylabel('log ratio'), yline_compat(0,'--r')
end
title('Pre-half noise control (gamma)'), makepretty_BM2

subplot(4,5,20)
if isfield(M,'gamma_peak_before_raw_hz') && isfinite(M.gamma_peak_before_raw_hz)
    bar([M.gamma_peak_before_raw_hz M.gamma_peak_after_raw_hz])
    set(gca,'XTickLabel',{'before','after'})
    ylabel('peak Hz')
end
title('Gamma peak (raw spec, 25-95 Hz search)'), makepretty_BM2

if SaveFigures
    saveas(gcf, fullfile(SaveFolder, ['QCv7_' A.drug_name '_' A.animal '_' A.name '.png']))
end
end
