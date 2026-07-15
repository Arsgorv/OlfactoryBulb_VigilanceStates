%% Paper_Figure_v7
% Final paper figure from cached v7 outputs + stats verification table.
%
% Layout (3 rows x 6 cols, subplot(3,6,N)):
%   1            : OB Middle mean spectrum (20-100 Hz)
%   2            : OB Middle log2 ratio
%   [3 4]        : combined box plot of 3 OB sub-bands (low \gamma, \gamma 40-60, high \gamma)
%                  -- TOP ROW ONLY (no longer spans into row 2)
%   [5 6]        : OB low gamma 20-40 Hz time course
%   7            : OB Low mean spectrum (0-20 Hz)
%   8            : OB Low log2 ratio
%   9            : HPC theta 4-8 Hz box plot (classical atropine result)
%   10           : OB gamma peak shift (Hz) box plot
%   [11 12]      : OB gamma 40-60 Hz time course
%   13,14,15,16  : OB power distributions (delta, low \gamma, γ, high \gamma)
%   [17 18]      : OB high gamma 60-80 Hz time course

clear all
close all

thisFile = mfilename('fullpath');
[thisFolder, ~, ~] = fileparts(thisFile);
addpath(fullfile(thisFolder, 'AG_helpers'));

SaveFolder = '\\129.199.81.18\data5\Arsenii\OB_fUS_Arousal\Processed_data\Ficello\Figures_AG\AtropineSaline_AG_figures_v7\';
SessionCacheDir = fullfile(SaveFolder, 'session_cache_v7');

DrugNames = {'Saline','Atropine'};
DrugColors = {[.3 .3 .3], [0.45 0.72 0.55]};
ColorBefore = [0.3010, 0.7450, 0.9330];
ColorAfter  = [0.9290, 0.6940, 0.1250];

% --- Load Group struct + grids ---
G = load(fullfile(SaveFolder, 'AtropineSaline_group_v7.mat'));
Group = G.Group;
Bands = G.Bands;
LowFreqGrid    = G.LowFreqGrid;
MiddleFreqGrid = G.MiddleFreqGrid;
PostTimeGridSec = G.PostTimeGridSec;
x_post_h = PostTimeGridSec/3600;

% --- Load session metrics (CSV) ---
T = readtable(fullfile(SaveFolder, 'AtropineSaline_session_metrics_v7.csv'));

% --- Build sub-band time-course matrices from per-session caches ---
% with fallbacks: if saline cache lacks the sub-band TC field, fall back to
% Group.gamma_after_real for 40-60 only; for low \gamma / high \gamma, the saline row
% will be absent (warn).
[M_sal_lg, M_atr_lg] = group_subband_timecourse_from_cache_AG(SessionCacheDir, 'lowgamma_after_real',  PostTimeGridSec);
[M_sal_g,  M_atr_g ] = group_subband_timecourse_from_cache_AG(SessionCacheDir, 'gamma_brainpower_after_real', PostTimeGridSec);
[M_sal_hg, M_atr_hg] = group_subband_timecourse_from_cache_AG(SessionCacheDir, 'highgamma_after_real', PostTimeGridSec);

% Fallbacks for gamma 40-60 (legacy SleepScoring_OBGamma BrainPower envelope)
if size(M_sal_g,1) < 2 && isfield(Group,'gamma_after_real')
    M_sal_g = Group.gamma_after_real{1};
    if size(M_atr_g,1) < 2, M_atr_g = Group.gamma_after_real{2}; end
end

if size(M_sal_lg,1) < 2
    warning(['Saline LOW gamma time courses not in cache. Re-run ' ...
             'AtropineSalineExploration_AG_paper_v7.m to populate them (~10 s/session).'])
end
if size(M_sal_hg,1) < 2
    warning(['Saline HIGH gamma time courses not in cache. Re-run ' ...
             'AtropineSalineExploration_AG_paper_v7.m to populate them.'])
end

% --- Load per-session Ana from caches (for distributions) ---
Ana = load_per_session_envelopes_AG(SessionCacheDir);

%% --- Figure ---
fig = figure('Name','Paper figure v7','Position',get(0,'ScreenSize'),'WindowState','maximized');

% --- helper: panels-with-square-axes ---
sq = @() set(gca,'PlotBoxAspectRatio',[1 1 1]);

% (1) OB Middle mean spectrum
subplot(3,6,1)
plot_mean_spectrum_pre_post_AG(MiddleFreqGrid, Group.middle_before_fweighted{1}, ...
    Group.middle_after_fweighted{1}, DrugColors{1}, DrugNames{1});
plot_mean_spectrum_pre_post_AG(MiddleFreqGrid, Group.middle_before_fweighted{2}, ...
    Group.middle_after_fweighted{2}, DrugColors{2}, DrugNames{2});
xlim([20 100])

vline_compat(Bands.gamma(1),'--k');    vline_compat(Bands.gamma(2),'--k')
vline_compat(Bands.highGamma(1),'--k');vline_compat(Bands.highGamma(2),'--k')
xlabel('Hz'), ylabel('f*power'), title('OB Middle 20-100 Hz')
legend('show','Location','best')
sq()

% (2) OB Middle log2 ratio
subplot(3,6,2)
plot_group_log2ratio_clean([], Group.middle_log2ratio, 'middle', DrugColors, 5)
xlim([20 100])
vline_compat(Bands.gamma(1),'--k');    vline_compat(Bands.gamma(2),'--k')
vline_compat(Bands.highGamma(1),'--k');vline_compat(Bands.highGamma(2),'--k')
title('OB Middle log2 ratio'), sq()

% [3 4] combined sub-band box plot (TOP ROW ONLY) — 3 groups

% subplot(3,6,3)
% cla
% hold on
% 
% boxFields = {'lowgamma_brainpower_logratio', ...
%              'gamma_brainpower_logratio', ...
%              'highgamma_brainpower_logratio'};
% 
% boxLabels = {'low \gamma 20-40', ...
%              '\gamma 40-60', ...
%              'high \gamma 60-80'};
% 
% allData = cell(1, 2*length(boxFields));
% allCols = cell(1, 2*length(boxFields));
% allX    = zeros(1, 2*length(boxFields));
% pWithin = NaN(1, length(boxFields));
% 
% groupStride = 3;
% withinGroup = 0.8;
% 
% for b = 1:length(boxFields)
% 
%     fldName = boxFields{b};
% 
%     if ismember(fldName, T.Properties.VariableNames)
%         d1 = T.(fldName)(T.drug_id == 1);
%         d2 = T.(fldName)(T.drug_id == 2);
% 
%         d1 = d1(isfinite(d1));
%         d2 = d2(isfinite(d2));
%     else
%         d1 = [];
%         d2 = [];
%     end
% 
%     if isempty(d1), d1 = NaN; end
%     if isempty(d2), d2 = NaN; end
% 
%     base = (b-1)*groupStride + 1;
% 
%     allData{2*b-1} = d1;
%     allData{2*b}   = d2;
% 
%     allCols{2*b-1} = DrugColors{1};
%     allCols{2*b}   = DrugColors{2};
% 
%     allX(2*b-1) = base - withinGroup/2;
%     allX(2*b)   = base + withinGroup/2;
% 
%     d1stat = d1(isfinite(d1));
%     d2stat = d2(isfinite(d2));
% 
%     if length(d1stat) > 1 && length(d2stat) > 1
%         pWithin(b) = ranksum(d1stat, d2stat);
%     end
% end
% 
% if exist('MakeSpreadAndBoxPlot3_SB','file') == 2
%     try
%         MakeSpreadAndBoxPlot3_SB(allData, allCols, allX, repmat({''},1,length(allData)), ...
%             'showpoints', 1, ...
%             'paired', 0);
%     catch ME
%         warning('MakeSpreadAndBoxPlot3_SB failed: %s', ME.message)
%     end
% end
% 
% finiteAll = [];
% for i = 1:length(allData)
%     d = allData{i};
%     finiteAll = [finiteAll; d(isfinite(d))];
% end
% 
% if isempty(finiteAll)
%     dataMin = -1;
%     dataMax = 1;
% else
%     dataMin = min(finiteAll);
%     dataMax = max(finiteAll);
% end
% 
% yr = dataMax - dataMin;
% if yr == 0
%     yr = 1;
% end
% 
% % Remove automatic significance stars from MakeSpreadAndBoxPlot3_SB
% hText = findall(gca, 'Type', 'text');
% 
% for i = 1:length(hText)
%     s = get(hText(i), 'String');
% 
%     if iscell(s)
%         if isempty(s)
%             s = '';
%         else
%             s = s{1};
%         end
%     end
% 
%     if ischar(s)
%         s = strtrim(s);
% 
%         if strcmp(s,'*') || strcmp(s,'**') || strcmp(s,'***') || ...
%            strcmp(s,'****') || strcmpi(s,'n.s.') || strcmpi(s,'ns')
%             delete(hText(i))
%         end
%     end
% end
% 
% % Remove automatic significance bracket lines above the data cloud
% hLine = findall(gca, 'Type', 'line');
% 
% for i = 1:length(hLine)
%     ydat = get(hLine(i), 'YData');
% 
%     if isnumeric(ydat) && ~isempty(ydat)
%         if min(ydat) > dataMax + 0.03*yr
%             delete(hLine(i))
%         end
%     end
% end
% 
% groupCenters = ((1:length(boxFields))-1)*groupStride + 1;
% 
% set(gca, 'XTick', groupCenters, 'XTickLabel', boxLabels)
% xlim([0 max(allX)+1])
% 
% yLow = min([dataMin 0]) - 0.15*yr;
% yHigh = dataMax + 0.45*yr;
% ylim([yLow yHigh])
% 
% yline_compat(0,'--r')
% 
% % Draw only within-band saline vs atropine brackets
% for b = 1:length(boxFields)
% 
%     if ~isfinite(pWithin(b))
%         continue
%     end
% 
%     if pWithin(b) >= 0.05
%         continue
%     end
% 
%     x1 = allX(2*b-1);
%     x2 = allX(2*b);
% 
%     d1 = allData{2*b-1};
%     d2 = allData{2*b};
% 
%     dBoth = [d1(:); d2(:)];
%     dBoth = dBoth(isfinite(dBoth));
% 
%     if isempty(dBoth)
%         continue
%     end
% 
%     y = max(dBoth) + 0.10*yr;
%     h = 0.035*yr;
% 
%     plot([x1 x1 x2 x2], [y y+h y+h y], ...
%         'k', 'LineWidth', 1.5)
% 
%     if pWithin(b) < 0.001
%         txt = '***';
%     elseif pWithin(b) < 0.01
%         txt = '**';
%     else
%         txt = '*';
%     end
% 
%     text(mean([x1 x2]), y+h+0.015*yr, txt, ...
%         'HorizontalAlignment', 'center', ...
%         'VerticalAlignment', 'bottom', ...
%         'FontWeight', 'bold', ...
%         'FontSize', 9)
% end
% 
% ylabel('log(after/before)')
% title('OB sub-band log-ratios')
% 
% box off
% set(gca, 'TickDir', 'out')


subplot(3,6,3)
boxFields = {'lowgamma_brainpower_logratio','gamma_brainpower_logratio','highgamma_brainpower_logratio'};
boxLabels = {'low \gamma 20-40','\gamma 40-60','high \gamma 60-80'};
% Build the full 6-entry data/colors/X-positions and call MakeSpreadAndBoxPlot3_SB
% ONCE so its internal significance bracket aligns correctly with the boxes.
allData = cell(1, 2*length(boxFields));
allCols = cell(1, 2*length(boxFields));
allX    = zeros(1, 2*length(boxFields));
groupStride = 3;             % space between sub-band groups (in x units)
withinGroup = 0.8;           % space between saline/atropine within a group
for b = 1:length(boxFields)
    fldName = boxFields{b};
    if ismember(fldName, T.Properties.VariableNames)
        d1 = T.(fldName)(T.drug_id==1); d1 = d1(isfinite(d1));
        d2 = T.(fldName)(T.drug_id==2); d2 = d2(isfinite(d2));
    else
        d1 = NaN; d2 = NaN;
    end
    if isempty(d1), d1 = NaN; end
    if isempty(d2), d2 = NaN; end
    base = (b-1)*groupStride + 1;
    allData{2*b-1} = d1; allData{2*b} = d2;
    allCols{2*b-1} = DrugColors{1}; allCols{2*b} = DrugColors{2};
    allX(2*b-1) = base - withinGroup/2;
    allX(2*b)   = base + withinGroup/2;
end
if exist('MakeSpreadAndBoxPlot3_SB','file') == 2
    try
        MakeSpreadAndBoxPlot3_SB(allData, allCols, allX, repmat({''},1,length(allData)), ...
                                 'showpoints', 1, 'paired', 0);
    catch ME
        warning('MakeSpreadAndBoxPlot3_SB failed: %s', ME.message)
    end
end
yline_compat(0,'--r')
% Place x-tick labels at the center of each sub-band group
groupCenters = ((1:length(boxFields))-1)*groupStride + 1;
set(gca,'XTick',groupCenters,'XTickLabel',boxLabels)
xlim([0 max(allX)+1])
ylabel('log(after/before)'), title('OB sub-band log-ratios')

% [5 6] low gamma 20-40 time course
subplot(3,6,[5 6])
plot_sal_atr_tc(x_post_h, M_sal_lg, M_atr_lg, DrugColors, DrugNames);
yline_compat(1,'--r'), xlabel('time after injection (h)'), ylabel('low \gamma / baseline')
title('OB low \gamma 20-40 Hz time course'), legend('show','Location','best')

% (7) OB Low mean spectrum
subplot(3,6,7)
plot_mean_spectrum_pre_post_AG(LowFreqGrid, Group.low_before_fweighted{1}, ...
    Group.low_after_fweighted{1}, DrugColors{1}, DrugNames{1});
plot_mean_spectrum_pre_post_AG(LowFreqGrid, Group.low_before_fweighted{2}, ...
    Group.low_after_fweighted{2}, DrugColors{2}, DrugNames{2});
xlim([0 20])
vline_compat(Bands.theta(1),'--k'); vline_compat(Bands.theta(2),'--k')
xlabel('Hz'), ylabel('f*power'), title('OB Low 0-20 Hz')
legend('show','Location','best'), sq()

% (8) OB Low log2 ratio
subplot(3,6,8)
plot_group_log2ratio_clean([], Group.low_log2ratio, 'low', DrugColors, 5)
xlim([0 20])
vline_compat(Bands.delta(1),'--r'); vline_compat(Bands.delta(2),'--r')
vline_compat(Bands.theta(1),'--k'); vline_compat(Bands.theta(2),'--k')
title('OB Low log2 ratio'), sq()

% (9) HPC theta box plot (classical atropine-sensitive result)
subplot(3,6,9)
plot_metric_by_drug(T, 'hpc_theta_logratio', DrugColors, 1:2, DrugNames)
ylabel('log(after/before)'), title('HPC \theta 4-8 Hz (BrainPower)')
sq()

% (10) OB gamma peak shift box plot
subplot(3,6,10)
plot_metric_by_drug(T, 'gamma_peak_shift_raw_hz', DrugColors, 1:2, DrugNames)
ylabel('after - before peak (Hz)'), title('OB \gamma peak shift (25-95 Hz search)')
sq()

% [11 12] gamma 40-60 time course
subplot(3,6,[11 12])
plot_sal_atr_tc(x_post_h, M_sal_g, M_atr_g, DrugColors, DrugNames);
yline_compat(1,'--r'), xlabel('time after injection (h)'), ylabel('\gamma / baseline')
title('OB \gamma 40-60 Hz time course'), legend('show','Location','best')

% (13,14,15,16) power distributions (sample-level, using cached Ana)
distSpecs = {'delta','OB \delta 0.5-4 Hz', false; ...
             'lowgamma','OB low \gamma 20-40 Hz', true; ...
             'gamma','OB \gamma 40-60 Hz', false; ...
             'highgamma','OB high \gamma 60-80 Hz', true};
for d = 1:4
    subplot(3,6, 12+d)
    fld = distSpecs{d,1};
    needsBP = distSpecs{d,3};
    have_data = false;
    if ~needsBP
        % delta and gamma 40-60 are directly in Ana (from SleepScoring_OBGamma)
        if ~isempty(Ana) && isfield(Ana, fld)
            plot_distribution_group(Ana, fld, DrugColors, ColorBefore, ColorAfter)
            have_data = true;
        end
    else
        % low \gamma / high \gamma: fall back to time-course samples (per session ~80 pts)
        if strcmp(fld,'lowgamma'), Msal = M_sal_lg; Matr = M_atr_lg;
        else,                       Msal = M_sal_hg; Matr = M_atr_hg; end
        if ~isempty(Msal) || ~isempty(Matr)
            hold on
            for drug = 1:2
                if drug == 1, Mu = Msal; else, Mu = Matr; end
                if isempty(Mu), continue, end
                vals = log(Mu(:)); vals = vals(isfinite(vals));
                if isempty(vals), continue, end
                [yk, xk] = ksdensity(vals);
                plot(xk, yk, '-', 'Color', DrugColors{drug}, 'LineWidth', 2, ...
                     'DisplayName', [DrugNames{drug} ' after'])
            end
            legend('show','Location','best')
            have_data = true;
        end
    end
    if ~have_data
        axis off, text(0.5,0.5,'no data','HorizontalAlignment','center')
    end
    xlabel('log band power')
    title(distSpecs{d,2}),sq()
end

% [17 18] high gamma time course
subplot(3,6,[17 18])
plot_sal_atr_tc(x_post_h, M_sal_hg, M_atr_hg, DrugColors, DrugNames);
yline_compat(1,'--r'), xlabel('time after injection (h)'), ylabel('high \gamma / baseline')
title('OB high \gamma 60-80 Hz time course'), legend('show','Location','best')

sgtitle('Paper figure v7: OB sub-band reorganization under atropine')
save_current_figure(1, SaveFolder, 'Sup5_atropine.svg');

%% --- STATS VERIFICATION TABLE ---
statsRows = {};
primaryMetrics = { ...
    'beta_brainpower_logratio',      'OB beta 15-30 Hz (BrainPower env)'; ...
    'lowgamma_brainpower_logratio',  'OB low gamma 20-40 Hz (BrainPower env)'; ...
    'gamma_brainpower_logratio',     'OB gamma 40-60 Hz (BrainPower env)'; ...
    'highgamma_brainpower_logratio', 'OB high gamma 60-80 Hz (BrainPower env)'; ...
    'theta_brainpower_logratio',     'OB theta 4-8 Hz (BrainPower env)'; ...
    'delta_brainpower_logratio',     'OB delta 0.5-4 Hz (BrainPower env)'; ...
    'gamma_logratio',                'OB gamma (legacy BrainPower)'; ...
    'delta_logratio',                'OB delta (legacy BrainPower)'; ...
    'gamma_spec_logratio',           'OB gamma 40-60 Hz (Middle spectrogram)'; ...
    'lowgamma_spec_logratio',        'OB low gamma 20-40 Hz (Middle spectrogram)'; ...
    'highgamma_spec_logratio',       'OB high gamma 60-80 Hz (Middle spectrogram)'; ...
    'beta_spec_logratio',            'OB beta 15-30 Hz (Middle spectrogram)'; ...
    'theta_spec_logratio',           'OB theta 4-8 Hz (Low spectrogram)'; ...
    'delta_spec_logratio',           'OB delta 0.5-4 Hz (Low spectrogram)'; ...
    'hpc_theta_logratio',            'HPC theta 4-8 Hz (BrainPower)'; ...
    'hpc_gamma_logratio',            'HPC gamma 40-60 Hz (BrainPower)'; ...
    'pfc_gamma_logratio',            'PFC gamma 40-60 Hz (BrainPower)'; ...
    'acx_gamma_logratio',            'ACx gamma 40-60 Hz (BrainPower)'; ...
    'gamma_peak_shift_raw_hz',       'OB gamma peak shift, raw (Hz)'; ...
    'hpc_dcbv_after_percent',        'HPC dCBV after injection (%)'; ...
    'aeg_dcbv_after_percent',        'AEG dCBV after injection (%)'; ...
    'hpc_aeg_r_after',               'HPC-AEG correlation (post)'; ...
    'gamma_hpc_r_after',             'OB gamma - HPC CBV correlation (post)'; ...
    'gamma_hpc_dr',                  'OB gamma - HPC CBV paired Delta-r'; ...
    'breath_rate_before_hz',         'Breath rate before injection (Hz)'; ...
    'breath_rate_after_hz',          'Breath rate after injection (Hz)'; ...
    'hrv_RMSSD_after_ms',            'HRV RMSSD after injection (ms)'; ...
    'hrv_SDNN_after_ms',             'HRV SDNN after injection (ms)' };

for k = 1:size(primaryMetrics,1)
    metric = primaryMetrics{k,1};
    nice   = primaryMetrics{k,2};
    if ~ismember(metric, T.Properties.VariableNames)
        statsRows(end+1,:) = {metric, nice, 0, 0, 0, 0, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 'field missing'}; %#ok<*AGROW>
        continue
    end
    s = T.(metric)(T.drug_id == 1); s = s(isfinite(s));
    a = T.(metric)(T.drug_id == 2); a = a(isfinite(a));
    n_s = length(s); n_a = length(a);
    animals_s = unique(T.animal(T.drug_id == 1 & isfinite(T.(metric))));
    animals_a = unique(T.animal(T.drug_id == 2 & isfinite(T.(metric))));
    n_anim_s = length(animals_s); n_anim_a = length(animals_a);
    med_s = median_safe(s); iqr_s = iqr_safe(s);
    med_a = median_safe(a); iqr_a = iqr_safe(a);
    p_rs = NaN;
    if n_s >= 2 && n_a >= 2 && exist('ranksum','file') == 2
        try, p_rs = ranksum(s, a); catch, end
    end
    p_anim = NaN;
    sal_anim_meds = []; atr_anim_meds = [];
    for ai = 1:length(animals_s)
        v = T.(metric)(strcmp(T.animal, animals_s{ai}) & T.drug_id == 1);
        v = v(isfinite(v));
        if ~isempty(v), sal_anim_meds(end+1) = median(v); end
    end
    for ai = 1:length(animals_a)
        v = T.(metric)(strcmp(T.animal, animals_a{ai}) & T.drug_id == 2);
        v = v(isfinite(v));
        if ~isempty(v), atr_anim_meds(end+1) = median(v); end
    end
    if length(sal_anim_meds) >= 2 && length(atr_anim_meds) >= 2 && exist('ranksum','file') == 2
        try, p_anim = ranksum(sal_anim_meds, atr_anim_meds); catch, end
    end
    [ci_lo, ci_hi, dM] = bootstrap_median_diff_AG(s, a, 5000, 0.05);
    test_name = 'Wilcoxon rank-sum (sessions)';
    statsRows(end+1,:) = {metric, nice, n_s, n_a, n_anim_s, n_anim_a, ...
                          med_s, iqr_s, med_a, iqr_a, dM, ci_lo, ci_hi, p_rs, p_anim, test_name};
end

StatsT = cell2table(statsRows, 'VariableNames', ...
    {'metric','description','n_saline_sessions','n_atropine_sessions', ...
     'n_saline_animals','n_atropine_animals','median_saline','IQR_saline', ...
     'median_atropine','IQR_atropine','delta_median_atr_minus_sal', ...
     'CI95_low','CI95_high','p_ranksum_sessions','p_ranksum_animals','test'});
sigStars = repmat({''}, height(StatsT), 1);
for k = 1:height(StatsT)
    p = StatsT.p_ranksum_sessions(k);
    if isfinite(p)
        if p < 0.001, sigStars{k} = '***';
        elseif p < 0.01, sigStars{k} = '**';
        elseif p < 0.05, sigStars{k} = '*';
        elseif p < 0.10, sigStars{k} = '.';
        end
    end
end
StatsT.sig = sigStars;
writetable(StatsT, fullfile(SaveFolder, 'Paper_Stats_Verification_v7.csv'));

% disp(' '), disp('=== STATS VERIFICATION (top 20 rows) ==='), disp(' ')
% disp(StatsT(1:min(20,height(StatsT)),:))

disp(' '), disp('Saved:')
disp(['  Paper figure (PNG + SVG) -> ' SaveFolder 'Paper_Figure_v7.{png,svg}'])
disp(['  Stats CSV               -> ' SaveFolder 'Paper_Stats_Verification_v7.csv'])

%% --- local helpers ---
function plot_sal_atr_tc(x, M_sal, M_atr, DrugColors, DrugNames)
hold on
if ~isempty(M_sal) && size(M_sal,1) >= 2
    h = shadedErrorBar_BM(x, M_sal, {'-','Color',DrugColors{1},'LineWidth',2.5}, 1);
    try, h.mainLine.DisplayName = DrugNames{1}; end
    try, h.patch.FaceAlpha = 0.5; end
    hide_shaded_legend_extras_AG(h);
elseif ~isempty(M_sal)
    plot(x, nanmean(M_sal,1), '-', 'Color', DrugColors{1}, 'LineWidth', 2.5, 'DisplayName', DrugNames{1})
end
if ~isempty(M_atr) && size(M_atr,1) >= 2
    h = shadedErrorBar_BM(x, M_atr, {'-','Color',DrugColors{2},'LineWidth',2.5}, 1);
    try, h.mainLine.DisplayName = DrugNames{2}; end
    try, h.patch.FaceAlpha = 0.5; end
    hide_shaded_legend_extras_AG(h);
elseif ~isempty(M_atr)
    plot(x, nanmean(M_atr,1), '-', 'Color', DrugColors{2}, 'LineWidth', 2.5, 'DisplayName', DrugNames{2})
end
end

function v = median_safe(x), x = x(isfinite(x)); if isempty(x), v = NaN; else, v = median(x); end, end
function v = iqr_safe(x), x = x(isfinite(x)); if length(x) < 2, v = NaN; else, v = simple_percentile(x,75) - simple_percentile(x,25); end, end
