function make_single_session_figure(A, S, M, ColorBefore, ColorAfter, Bands, SaveFigures, SaveFolder)
% Single-session QC figure. No inferential statistics here: time points are
% autocorrelated, so before/after stars would be pseudoreplicated.

TFUS = A.TFUS;
idx_before = A.idx_before;
idx_after = A.idx_after;
step = 20;

figure('Name', [A.drug_name ' ' A.name], 'Position', [50 50 1600 950]);
sgtitle([A.name ' - ' A.drug_name ' - injection assumed at session midpoint'])

subplot(4,5,[1 2 3 4 5])
plot(TFUS/60, A.gamma_norm, 'Color', [0.9290, 0.6940, 0.1250]); hold on
plot(TFUS/60, A.delta_norm, 'Color', [0.3010, 0.7450, 0.9330]);
plot(TFUS/60, A.hpc_norm, 'k');
plot(TFUS/60, A.aeg_norm, 'Color', [.5 .5 .5]);
vline_compat(A.t_mid/60, '--r')
yline_compat(1, '--k')
xlabel('Time (min)')
ylabel('baseline norm')
legend('OB gamma','OB delta','HPC CBV','AEG/ACx CBV')
title('Normalized traces')
makepretty_BM2

subplot(4,5,6)
plot_scatter_corr(safe_log(A.gamma(idx_before)), safe_log(A.hpc(idx_before)), ColorBefore); hold on
plot_scatter_corr(safe_log(A.gamma(idx_after)), safe_log(A.hpc(idx_after)), ColorAfter);
xlabel('log OB gamma')
ylabel('log HPC CBV')
title(['Gamma-HPC r after=' num2str(M.gamma_hpc_r_after,2)])
makepretty_BM2

subplot(4,5,7)
plot_scatter_corr(safe_log(A.gamma(idx_before)), safe_log(A.aeg(idx_before)), ColorBefore); hold on
plot_scatter_corr(safe_log(A.gamma(idx_after)), safe_log(A.aeg(idx_after)), ColorAfter);
xlabel('log OB gamma')
ylabel('log AEG/ACx CBV')
title(['Gamma-AEG r after=' num2str(M.gamma_aeg_r_after,2)])
makepretty_BM2

subplot(4,5,8)
plot_scatter_corr(safe_log(A.hpc(idx_before)), safe_log(A.aeg(idx_before)), ColorBefore); hold on
plot_scatter_corr(safe_log(A.hpc(idx_after)), safe_log(A.aeg(idx_after)), ColorAfter);
xlabel('log HPC CBV')
ylabel('log AEG/ACx CBV')
title(['HPC-AEG r after=' num2str(M.hpc_aeg_r_after,2)])
makepretty_BM2

subplot(4,5,9)
plot_distribution_pair(safe_log(A.gamma(idx_before)), safe_log(A.gamma(idx_after)), ColorBefore, ColorAfter)
xlabel('log OB gamma')
ylabel('probability')
title('Gamma distribution')
makepretty_BM2

subplot(4,5,10)
plot_distribution_pair(safe_log(A.delta(idx_before)), safe_log(A.delta(idx_after)), ColorBefore, ColorAfter)
xlabel('log OB delta')
ylabel('probability')
title('Delta distribution')
makepretty_BM2

subplot(4,5,11)
if isfield(A, 'low_f')
    plot(A.low_f, A.low_before_plot, 'Color', ColorBefore, 'LineWidth', 2); hold on
    plot(A.low_f, A.low_after_plot, 'Color', ColorAfter, 'LineWidth', 2);
    xlim([0 20])
    vline_compat(Bands.delta(1),'--r'); vline_compat(Bands.delta(2),'--r')
end
xlabel('Frequency (Hz)')
ylabel('f * power')
title('Low mean spectrum')
makepretty_BM2

subplot(4,5,12)
if isfield(A, 'low_f')
    plot(A.low_f, A.low_log2ratio, 'k', 'LineWidth', 2); hold on
    yline_compat(0,'--r')
    xlim([0 20])
    vline_compat(Bands.delta(1),'--r'); vline_compat(Bands.delta(2),'--r')
end
xlabel('Frequency (Hz)')
ylabel('log2 after/before')
title('Low spectrum ratio')
makepretty_BM2

subplot(4,5,13)
if isfield(A, 'middle_f')
    plot(A.middle_f, A.middle_before_plot, 'Color', ColorBefore, 'LineWidth', 2); hold on
    plot(A.middle_f, A.middle_after_plot, 'Color', ColorAfter, 'LineWidth', 2);
    xlim([20 100])
    vline_compat(Bands.gamma(1),'--r'); vline_compat(Bands.gamma(2),'--r')
end
xlabel('Frequency (Hz)')
ylabel('f * power')
title('Middle mean spectrum')
makepretty_BM2

subplot(4,5,14)
if isfield(A, 'middle_f')
    plot(A.middle_f, A.middle_log2ratio, 'k', 'LineWidth', 2); hold on
    yline_compat(0,'--r')
    xlim([20 100])
    vline_compat(Bands.gamma(1),'--r'); vline_compat(Bands.gamma(2),'--r')
end
xlabel('Frequency (Hz)')
ylabel('log2 after/before')
title('Middle spectrum ratio')
makepretty_BM2

subplot(4,5,15)
imagesc(A.meanImg); axis image off; colormap(gca,'gray'); hold on
try
    B = bwboundaries(A.masks.Hippocampus);
    plot(B{1}(:,2), B{1}(:,1), 'r')
    B = bwboundaries(A.masks.AEG);
    plot(B{1}(:,2), B{1}(:,1), 'r')
end
title('fUS ROIs')

subplot(4,5,16)
plot(TFUS/60, A.log_gamma_long, 'Color', [0.9290, 0.6940, 0.1250]); hold on
plot(TFUS/60, A.log_hpc_long, 'k');
plot(TFUS/60, A.log_aeg_long, 'Color', [.5 .5 .5]);
vline_compat(A.t_mid/60, '--r')
xlabel('Time (min)')
ylabel('long smoothed log')
title('Long timescale coupling signals')
makepretty_BM2

subplot(4,5,17)
D = A.gamma_norm(idx_after);
D = D(1:step:end);
plot(D, 'Color', [0.9290, 0.6940, 0.1250], 'LineWidth', 1.5); hold on
D = A.hpc_norm(idx_after);
D = D(1:step:end);
plot(D, 'k', 'LineWidth', 1.5);
yline_compat(1,'--r')
xlabel('subsampled post points')
ylabel('norm')
title('Post gamma and HPC')
makepretty_BM2

subplot(4,5,18)
plot_state_bar(A.OBState, idx_before, idx_after)
title('OB state occupancy')
makepretty_BM2

subplot(4,5,19)
bar([M.gamma_logratio M.delta_logratio M.hpc_cbv_logratio M.aeg_cbv_logratio])
set(gca,'XTickLabel',{'gamma','delta','HPC','AEG'})
yline_compat(0,'--r')
ylabel('log after/before')
title('Session effects')
makepretty_BM2

subplot(4,5,20)
bar([M.gamma_hpc_r_after M.gamma_aeg_r_after M.hpc_aeg_r_after])
set(gca,'XTickLabel',{'G-HPC','G-AEG','HPC-AEG'})
ylabel('r after')
title('After coupling')
makepretty_BM2

if SaveFigures
    filename = fullfile(SaveFolder, ['SingleSession_' A.drug_name '_' A.name '.png']);
    saveas(gcf, filename);
end
end
