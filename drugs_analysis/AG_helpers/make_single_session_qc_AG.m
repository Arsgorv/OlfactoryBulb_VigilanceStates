function make_single_session_qc_AG(A, M, ColorBefore, ColorAfter, Bands, SaveFigures, SaveFolder)
%MAKE_SINGLE_SESSION_QC_AG Exploratory single-session figure for OB-only or OB+fUS sessions.

if ~isfield(A, 'Tref') || isempty(A.Tref)
    return
end

figure('Name', ['QC ' A.drug_name ' ' A.name], 'Position', [50 50 1550 900]);
sgtitle([A.animal ' ' A.restraint ' ' A.name ' - ' A.drug_name])

subplot(3,5,[1 2 3])
plot(A.Tref/60, A.gamma_norm, 'Color', [0.9290, 0.6940, 0.1250], 'LineWidth', 1.5); hold on
plot(A.Tref/60, A.delta_norm, 'Color', [0.3010, 0.7450, 0.9330], 'LineWidth', 1.5)
if isfield(A, 'hpc_norm') && any(isfinite(A.hpc_norm))
    plot(A.Tref/60, A.hpc_norm, 'k', 'LineWidth', 1)
end
vline_compat(A.t_inj/60, '--r')
yline_compat(1, '--k')
xlabel('Time (min)')
ylabel('baseline ratio')
legend('OB gamma','OB delta','HPC CBV')
title('Baseline-normalized traces')
makepretty_BM2

subplot(3,5,4)
plot_distribution_pair(safe_log(A.gamma(A.idx_before)), safe_log(A.gamma(A.idx_after)), ColorBefore, ColorAfter)
xlabel('log gamma')
ylabel('probability')
title('Gamma distribution')
makepretty_BM2

subplot(3,5,5)
plot_distribution_pair(safe_log(A.delta(A.idx_before)), safe_log(A.delta(A.idx_after)), ColorBefore, ColorAfter)
xlabel('log delta')
ylabel('probability')
title('Delta distribution')
makepretty_BM2

subplot(3,5,6)
if isfield(A, 'low_f')
    plot(A.low_f, A.low_log2ratio, 'k', 'LineWidth', 2); hold on
    yline_compat(0,'--r')
    vline_compat(Bands.delta(1),'--r'); vline_compat(Bands.delta(2),'--r')
    vline_compat(Bands.theta(1),'--k'); vline_compat(Bands.theta(2),'--k')
    xlim([0 20])
end
xlabel('Hz')
ylabel('log2 after/before')
title('Low spectrum ratio')
makepretty_BM2

subplot(3,5,7)
if isfield(A, 'middle_f')
    plot(A.middle_f, A.middle_log2ratio, 'k', 'LineWidth', 2); hold on
    yline_compat(0,'--r')
    vline_compat(Bands.lowGamma(1),'--r'); vline_compat(Bands.lowGamma(2),'--r')
    vline_compat(Bands.gamma(1),'--k'); vline_compat(Bands.gamma(2),'--k')
    vline_compat(Bands.highGamma(1),'--b'); vline_compat(Bands.highGamma(2),'--b')
    xlim([20 100])
end
xlabel('Hz')
ylabel('log2 after/before')
title('Middle spectrum ratio')
makepretty_BM2

subplot(3,5,8)
bar([M.lowgamma_spec_logratio M.gamma_spec_logratio M.highgamma_spec_logratio])
set(gca,'XTickLabel',{'20-40','40-60','60-80'})
yline_compat(0,'--r')
ylabel('log ratio')
title('Gamma subbands')
makepretty_BM2

subplot(3,5,9)
bar([M.delta_spec_logratio M.theta_spec_logratio])
set(gca,'XTickLabel',{'0.5-4','3-6'})
yline_compat(0,'--r')
ylabel('log ratio')
title('Low-frequency bands')
makepretty_BM2

subplot(3,5,10)
plot_state_bar(A.OBState, A.idx_before, A.idx_after)
title('OB quadrant occupancy')
makepretty_BM2

subplot(3,5,11)
if isfield(A, 'hpc') && any(isfinite(A.hpc))
    plot_scatter_corr(safe_log(A.gamma(A.idx_before)), safe_log(A.hpc(A.idx_before)), ColorBefore); hold on
    plot_scatter_corr(safe_log(A.gamma(A.idx_after)), safe_log(A.hpc(A.idx_after)), ColorAfter)
    xlabel('log gamma')
    ylabel('log HPC CBV')
else
    text(0.1, 0.5, 'No fUS for this session')
    axis off
end
title('Gamma-HPC')
makepretty_BM2

subplot(3,5,12)
if isfield(A, 'aeg') && any(isfinite(A.aeg))
    plot_scatter_corr(safe_log(A.gamma(A.idx_before)), safe_log(A.aeg(A.idx_before)), ColorBefore); hold on
    plot_scatter_corr(safe_log(A.gamma(A.idx_after)), safe_log(A.aeg(A.idx_after)), ColorAfter)
    xlabel('log gamma')
    ylabel('log AEG/ACx CBV')
else
    text(0.1, 0.5, 'No fUS for this session')
    axis off
end
title('Gamma-AEG')
makepretty_BM2

subplot(3,5,13)
if isfield(A, 'hpc') && any(isfinite(A.hpc))
    plot(A.Tref/60, A.hpc_dcbv_percent, 'k'); hold on
    plot(A.Tref/60, A.aeg_dcbv_percent, 'Color', [.5 .5 .5])
    vline_compat(A.t_inj/60, '--r')
    yline_compat(0,'--k')
    xlabel('Time (min)')
    ylabel('dCBV (%)')
    legend('HPC','AEG')
else
    text(0.1, 0.5, 'No fUS for this session')
    axis off
end
title('CBV traces')
makepretty_BM2

subplot(3,5,14)
if isfield(A, 'meanImg')
    imagesc(A.meanImg); axis image off; colormap(gca,'gray'); hold on
    try
        B = bwboundaries(A.masks.Hippocampus);
        plot(B{1}(:,2), B{1}(:,1), 'r')
        B = bwboundaries(A.masks.AEG);
        plot(B{1}(:,2), B{1}(:,1), 'r')
    catch
    end
else
    text(0.1, 0.5, 'No fUS image')
    axis off
end
title('fUS ROIs')

subplot(3,5,15)
bar([M.gamma_logratio M.delta_logratio M.hpc_cbv_logratio M.aeg_cbv_logratio])
set(gca,'XTickLabel',{'gamma','delta','HPC','AEG'})
yline_compat(0,'--r')
ylabel('log after/before')
title('Core effects')
makepretty_BM2

if SaveFigures
    filename = fullfile(SaveFolder, ['QC_' A.animal '_' A.restraint '_' A.drug_name '_' A.name '.png']);
    saveas(gcf, filename);
end
