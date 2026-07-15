function fig = plot_state_pies_AG(M_all, sessionNames, colors, mode)
% plot_state_pies_AG  Pie diagrams of state composition.
%
% Two pies per session (or two summary pies for 'summary' mode):
%   - composition of recording  (Wake, N1, N2, REM)
%   - composition of sleep      (N1, N2, REM only)
%
% INPUT
%   M_all          1xN cell of compute_state_metrics_AG outputs
%   sessionNames   1xN cellstr
%   colors         state_colors_AG output
%   mode           'per_session' (default) | 'summary'  (cross-session mean)
%
% OUTPUT
%   fig  figure handle

if nargin < 3 || isempty(colors), colors = state_colors_AG(); end
if nargin < 4 || isempty(mode),   mode   = 'per_session'; end

nSess = numel(M_all);
names = colors.names;

% Per-session matrices
propTotal = nan(nSess, 4);
propSleep = nan(nSess, 4);
for s = 1:nSess
    propTotal(s,:) = M_all{s}.prop_total;
    propSleep(s,:) = M_all{s}.prop_sleep;
end

if strcmpi(mode,'summary')
    fig = figure('Color','w','Units','normalized','Position',[.2 .25 .5 .45]);
    pT = nanmean(propTotal, 1);
    pS = nanmean(propSleep, 1);
    subplot(1,2,1)
    draw_pie(pT, names, colors.colors);
    title(sprintf('Composition of recording (mean of %d sessions)', nSess))
    subplot(1,2,2)
    draw_pie(pS(2:4), names(2:4), colors.colors(2:4));
    title('Composition of sleep')
    return
end

fig = figure('Color','w','Units','normalized','Position',[.05 .1 .9 .7]);
for s = 1:nSess
    subplot(2, nSess, s)
    draw_pie(propTotal(s,:), names, colors.colors);
    title(sprintf('%s\nrecording', sessionNames{s}), 'Interpreter','none')
    subplot(2, nSess, nSess + s)
    draw_pie(propSleep(s, 2:4), names(2:4), colors.colors(2:4));
    title('sleep only')
end

end


function draw_pie(p, labels, cols)
p = p(:)';
keep = p > 0 & ~isnan(p);
p = p(keep);
labels = labels(keep);
cols   = cols(keep);
if isempty(p), axis off, return, end
h = pie(p);
% Color the wedges
for i = 1:numel(p)
    set(h(2*i-1), 'FaceColor', cols{i}, 'EdgeColor','w', 'LineWidth', 1.2)
    % Replace text label with state + percent
    pct = round(100 * p(i)/sum(p));
    set(h(2*i), 'String', sprintf('%s\n%d%%', labels{i}, pct), 'FontSize', 9)
end
end
