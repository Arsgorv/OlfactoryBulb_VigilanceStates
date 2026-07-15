function fig = plot_light_dark_comparison_AG(LD_all, sessionNames, colors)
% plot_light_dark_comparison_AG  Light vs dark comparison across sessions
% for the four states. Three panels:
%   (1) State proportion (% of condition duration)
%   (2) Mean bout duration (s, log y)
%   (3) Bout count per hour (normalized by condition duration)
%
% Within each panel, x = state, with two boxes per state (light, dark).
% Sessions are the data points inside each box; lines connect each session's
% light value to its dark value to emphasize within-session shifts.
%
% INPUT
%   LD_all         1xN cell of compute_light_dark_stats_AG outputs
%   sessionNames   1xN cellstr (unused here, kept for signature consistency)
%   colors         state_colors_AG output
%
% OUTPUT
%   fig  figure handle

if nargin < 3 || isempty(colors), colors = state_colors_AG(); end
nSess  = numel(LD_all);
states = colors.names;
nState = 4;

% Pull out matrices [nSess x 2 x nState]
prop = nan(nSess, 2, nState);
dur  = nan(nSess, 2, nState);
rate = nan(nSess, 2, nState);
for s = 1:nSess
    if isempty(LD_all{s}.propTotal), continue, end
    prop(s,:,:) = LD_all{s}.propTotal;
    dur(s,:,:)  = LD_all{s}.meanBoutDur_s;
    rate(s,:,:) = LD_all{s}.nBouts ./ LD_all{s}.condDur_h;   % bouts/hour
end

fig = figure('Color','w','Units','normalized','Position',[.05 .15 .9 .55]);
metrics = { ...
    prop, '% of condition',     false, 'Proportion (light vs dark)'; ...
    dur,  'Mean bout duration (s)', true,  'Bout duration (light vs dark)'; ...
    rate, 'Bouts per hour',     false, 'Bout count rate (light vs dark)'};

for m = 1:size(metrics,1)
    subplot(1, 3, m)
    X = metrics{m,1};
    A = cell(1, 2*nState);
    Cols = cell(1, 2*nState);
    Labels = cell(1, 2*nState);
    Xpos = nan(1, 2*nState);
    for i = 1:nState
        % Light box
        if m == 1, v = squeeze(X(:,1,i))*100; else, v = squeeze(X(:,1,i)); end
        A{2*i-1}     = v;
        Cols{2*i-1}  = colors.colors{i};                           % light: full color
        Labels{2*i-1}= sprintf('%s L', states{i});
        Xpos(2*i-1)  = 3*(i-1) + 1;
        % Dark box
        if m == 1, v = squeeze(X(:,2,i))*100; else, v = squeeze(X(:,2,i)); end
        A{2*i}     = v;
        Cols{2*i}  = max(0, colors.colors{i} * 0.55);              % dark: darker
        Labels{2*i}= sprintf('%s D', states{i});
        Xpos(2*i)  = 3*(i-1) + 2;
    end
    MakeSpreadAndBoxPlot3_SB(A, Cols, Xpos, Labels, ...
        'showpoints', 1, 'paired', 0, 'newfig', 0);
    % Connect L and D values per session for each state
    hold on
    for i = 1:nState
        for s = 1:nSess
            if m == 1
                yL = X(s,1,i)*100; yD = X(s,2,i)*100;
            else
                yL = X(s,1,i);     yD = X(s,2,i);
            end
            if ~isnan(yL) && ~isnan(yD)
                plot([Xpos(2*i-1) Xpos(2*i)], [yL yD], '-', ...
                    'Color', [.5 .5 .5 .6], 'LineWidth', 0.8)
            end
        end
    end
    if metrics{m,3}, set(gca,'YScale','log'); end
    ylabel(metrics{m,2})
    title(metrics{m,4})
    xtickangle(45)
    set(gca,'TickDir','out','Box','off','FontSize',9)
end

end
