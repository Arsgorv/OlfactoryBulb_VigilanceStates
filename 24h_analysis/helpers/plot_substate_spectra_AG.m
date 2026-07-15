function fig = plot_substate_spectra_AG(SS_all, sessionNames, mode)
% plot_substate_spectra_AG  Mean spectra for each substate, with one panel
% per recorded region (OB low, OB mid, HPC low, PFC low/mid, AuCx, ...).
% Region list is discovered from the SS structs at runtime, so adding a new
% spectrum file in load_session_AG is enough -- this plot adapts.
%
% Use the per-session view to inspect each animal; the 'summary' view
% averages across sessions and is the paper-supplement view that tests
% whether short-N1 bouts overlap the N2 spectrum (mis-classification) and
% whether long-N1 bouts dissociate between regions (HPC theta but PFC
% NREM-like -- the classical intermediate-stage-of-sleep signature).
%
% INPUT
%   SS_all         1xN cell of compute_substate_spectra_AG outputs
%   sessionNames   1xN cellstr
%   mode           'per_session' (default) | 'summary'
%
% OUTPUT
%   fig  figure handle

if nargin < 3 || isempty(mode), mode = 'per_session'; end

% Union of available regions across all sessions (keep order from the first)
regions = {};
for s = 1:numel(SS_all)
    for r = 1:numel(SS_all{s}.regions)
        rn = SS_all{s}.regions{r};
        if ~any(strcmp(regions, rn)), regions{end+1} = rn; end %#ok<AGROW>
    end
end
nR = numel(regions);
if nR == 0
    fig = figure('Color','w'); text(.5,.5,'no spectra available','Units','normalized', ...
        'HorizontalAlignment','center'); axis off
    return
end

regionLabels = pretty_region_labels_AG(regions);
freqLims     = freq_limits_AG(regions);

if strcmpi(mode, 'summary')
    fig = figure('Color','w','Units','normalized','Position',[.05 .2 .88 .55]);
    [Mavg, SEMavg, freqs, groupNames, groupCols] = pool_across_sessions(SS_all, regions);
    for r = 1:nR
        subplot(1, nR, r)
        if isempty(freqs.(regions{r})), axis off, continue, end
        plot_one_band(freqs.(regions{r}), Mavg.(regions{r}), SEMavg.(regions{r}), ...
                      groupCols, groupNames, freqLims{r})
        title(regionLabels{r}, 'Interpreter','none')
        if r == 1, ylabel('log10 power (mean +/- SEM across sessions)'); end
        xlabel('Frequency (Hz)')
        set(gca,'TickDir','out','Box','off','FontSize',9)
    end
    legend(groupNames, 'Box','off','Location','eastoutside','Interpreter','none')
    return
end

nSess = numel(SS_all);
fig = figure('Color','w','Units','normalized','Position',[.04 .04 .92 .92]);
for s = 1:nSess
    SS = SS_all{s};
    for r = 1:nR
        subplot(nSess, nR, (s-1)*nR + r)
        rn = regions{r};
        if ~isfield(SS.spec, rn) || isempty(SS.spec.(rn).f), axis off, continue, end
        plot_one_band(SS.spec.(rn).f, SS.spec.(rn).M, SS.spec.(rn).SEM, ...
                      SS.groupColors, SS.groupNames, freqLims{r})
        if r == 1, ylabel(sprintf('%s\nlog10 power', sessionNames{s}), 'Interpreter','none'); end
        if s == 1, title(regionLabels{r}, 'Interpreter','none'); end
        if s == nSess, xlabel('Frequency (Hz)'); end
        set(gca,'TickDir','out','Box','off','FontSize',8)
        if s == 1 && r == nR
            legend(SS.groupNames, 'Box','off','Location','eastoutside','Interpreter','none')
        end
    end
end

end


% =============================================================================
function plot_one_band(f, M, SEM, cols, names, xLim)
nG = size(M, 1);
held = false;
for g = 1:nG
    if all(isnan(M(g,:))), continue, end
    if ~held, hold on, held = true; end
    yU = M(g,:) + SEM(g,:);
    yL = M(g,:) - SEM(g,:);
    fill([f(:); flipud(f(:))], [yU(:); flipud(yL(:))], cols{g}, ...
        'EdgeColor','none','FaceAlpha', 0.18, 'HandleVisibility','off')
    plot(f, M(g,:), 'Color', cols{g}, 'LineWidth', 1.6)
end
xlim(xLim)
end


function [Mavg, SEMavg, freqs, groupNames, groupCols] = pool_across_sessions(SS_all, regions)
nSess = numel(SS_all);
% Pick the first session that has each region for axis info
groupNames = SS_all{1}.groupNames;
groupCols  = SS_all{1}.groupColors;
for r = 1:numel(regions)
    rn = regions{r};
    fAll = [];
    for s = 1:nSess
        if isfield(SS_all{s}.spec, rn) && ~isempty(SS_all{s}.spec.(rn).f)
            fAll = SS_all{s}.spec.(rn).f; break
        end
    end
    if isempty(fAll)
        Mavg.(rn) = []; SEMavg.(rn) = []; freqs.(rn) = [];
        continue
    end
    nG = numel(groupNames);
    nF = numel(fAll);
    stack = nan(nSess, nG, nF);
    for s = 1:nSess
        if ~isfield(SS_all{s}.spec, rn), continue, end
        Mi = SS_all{s}.spec.(rn).M;
        if isempty(Mi) || size(Mi,2) ~= nF, continue, end
        stack(s, :, :) = Mi;
    end
    Mavg.(rn) = squeeze(nanmean(stack, 1));
    nValid    = squeeze(sum(~isnan(stack), 1));
    nValid(nValid == 0) = NaN;
    SEMavg.(rn) = squeeze(nanstd(stack, 0, 1)) ./ sqrt(nValid);
    freqs.(rn)  = fAll;
end
end


function labs = pretty_region_labels_AG(regions)
labs = cell(size(regions));
for k = 1:numel(regions)
    switch regions{k}
        case 'OBlow',   labs{k} = 'OB low (0-10 Hz)';
        case 'OBgamma', labs{k} = 'OB mid (20-100 Hz)';
        case 'HPClow',  labs{k} = 'HPC low (0-10 Hz)';
        case 'HPCmid',  labs{k} = 'HPC mid (20-100 Hz)';
        case 'PFClow',  labs{k} = 'PFC low (0-10 Hz)';
        case 'PFCmid',  labs{k} = 'PFC mid (20-100 Hz)';
        case 'AuCxlow', labs{k} = 'AuCx low (0-10 Hz)';
        case 'AuCxmid', labs{k} = 'AuCx mid (20-100 Hz)';
        otherwise,      labs{k} = regions{k};
    end
end
end


function L = freq_limits_AG(regions)
L = cell(size(regions));
for k = 1:numel(regions)
    if contains(lower(regions{k}), 'mid') || contains(lower(regions{k}), 'gamma')
        L{k} = [20 100];
    else
        L{k} = [0 10];
    end
end
end
