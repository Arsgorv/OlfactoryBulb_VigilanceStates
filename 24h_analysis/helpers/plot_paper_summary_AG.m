function fig = plot_paper_summary_AG(M_all, T_all, C_all, SS_all, LD_all, sessionNames, colors)
% plot_paper_summary_AG  Single supplementary figure pulling together the
% headline session-averaged results suitable for a paper:
%
%   (a) pie of session-mean recording composition
%   (b) pie of session-mean sleep composition
%   (c) bar of state proportion across sessions (mean +/- SEM, points)
%   (d) bar of bout duration across sessions (mean +/- SEM, log y)
%   (e) session-averaged transition probability heatmap (4 states)
%   (f) session-averaged time-warped sleep-cycle composition (stacked area)
%   (g) substate mean OB low spectra (key panel for the N1-short vs N2 test)
%   (h) light vs dark proportion box plot (Wake/N1/N2/REM)
%
% INPUT
%   M_all, T_all, C_all, SS_all, LD_all   per-session metric cells (any may
%                                         contain empty entries; those are
%                                         skipped silently)
%   sessionNames  1xN cellstr
%   colors        state_colors_AG output

if nargin < 7 || isempty(colors), colors = state_colors_AG(); end
nSess = numel(M_all);
names = colors.names;
nState = 4;

fig = figure('Color','w','Units','normalized','Position',[.03 .03 .94 .92]);

% --- (a) recording pie ------------------------------------------------------
subplot(3, 4, 1)
propTotal = nan(nSess, nState);
for s = 1:nSess, propTotal(s,:) = M_all{s}.prop_total; end
draw_pie_local(nanmean(propTotal,1), names, colors.colors)
title('a) Mean recording composition')

% --- (b) sleep pie ----------------------------------------------------------
subplot(3, 4, 2)
propSleep = nan(nSess, nState);
for s = 1:nSess, propSleep(s,:) = M_all{s}.prop_sleep; end
draw_pie_local(nanmean(propSleep(:,2:4),1), names(2:4), colors.colors(2:4))
title('b) Mean sleep composition')

% --- (c) state proportion box plot ------------------------------------------
subplot(3, 4, 3)
A = cell(1,nState);
for i = 1:nState, A{i} = 100*propTotal(:,i); end
MakeSpreadAndBoxPlot3_SB(A, colors.colors, 1:nState, names, ...
    'showpoints',1,'paired',0,'newfig',0);
ylabel('% of recording'), title('c) Composition per session')
set(gca,'TickDir','out','Box','off','FontSize',9)

% --- (d) mean bout duration box plot ----------------------------------------
subplot(3, 4, 4)
boutMed = nan(nSess, nState);
for s = 1:nSess, boutMed(s,:) = M_all{s}.bout_med; end
A = cell(1,nState);
for i = 1:nState, A{i} = boutMed(:,i); end
MakeSpreadAndBoxPlot3_SB(A, colors.colors, 1:nState, names, ...
    'showpoints',1,'paired',0,'newfig',0);
set(gca,'YScale','log'), ylabel('Median bout duration (s)')
title('d) Bout duration per session')
set(gca,'TickDir','out','Box','off','FontSize',9)

% --- (e) session-averaged transition heatmap --------------------------------
subplot(3, 4, 5)
Pstack = nan(nState, nState, nSess);
for s = 1:nSess
    if ~isempty(T_all{s}) && isfield(T_all{s},'probs')
        Pstack(:,:,s) = T_all{s}.probs;
    end
end
Pavg = nanmean(Pstack, 3);
imagesc(Pavg); axis square xy; caxis([0 1]); colormap(gca, viridis)
cb = colorbar; ylabel(cb,'P(to|from)')
set(gca,'XTick',1:nState,'XTickLabel',names, ...
        'YTick',1:nState,'YTickLabel',names,'FontSize',9,'TickDir','out')
xlabel('To'), ylabel('From')
title('e) Mean transition probability')
for i = 1:nState
    for j = 1:nState
        v = Pavg(i,j); if isnan(v), continue, end
        txtCol = 'w'; if v < 0.4, txtCol = 'k'; end
        text(j, i, sprintf('%.2f', v), 'HorizontalAlignment','center', ...
            'Color', txtCol, 'FontWeight','bold','FontSize',8)
    end
end

% --- (f) session-averaged cycle composition (stacked area) -------------------
subplot(3, 4, 6)
nBins = 0;
for s = 1:nSess
    if ~isempty(C_all{s}) && ~isempty(C_all{s}.meanProp)
        nBins = max(nBins, size(C_all{s}.meanProp,1));
    end
end
if nBins > 0
    stack = nan(nSess, nBins, nState);
    for s = 1:nSess
        if ~isempty(C_all{s}.meanProp)
            stack(s,:,:) = C_all{s}.meanProp;
        end
    end
    Mcycle = squeeze(nanmean(stack, 1));
    h = area(linspace(0,1,nBins), Mcycle);
    for i = 1:nState
        set(h(i),'FaceColor',colors.colors{i},'EdgeColor','none','FaceAlpha',0.9)
    end
    xlim([0 1]), ylim([0 1])
    xlabel('Cycle progress'), ylabel('Fraction of cycle bin')
end
title('f) Mean sleep cycle')
set(gca,'TickDir','out','Box','off','FontSize',9)

% --- (g) substate mean OB-low spectra (the N1-short test) -------------------
% After the multi-region refactor, each session's spectra live under
% SS.spec.<region>. Use OBlow if available; fall back to whichever low-band
% spectrum exists.
subplot(3, 4, 7)
region = pick_region_for_paper_AG(SS_all, {'OBlow','HPClow','PFClow','AuCxlow'});
if ~isempty(region)
    % Find an SS that actually has this region for axis info
    refSS = [];
    for s = 1:nSess
        if isfield(SS_all{s},'spec') && isfield(SS_all{s}.spec, region) ...
                && ~isempty(SS_all{s}.spec.(region).f)
            refSS = SS_all{s}; break
        end
    end
    if ~isempty(refSS)
        nG = numel(refSS.groupNames);
        nF = numel(refSS.spec.(region).f);
        stack = nan(nSess, nG, nF);
        for s = 1:nSess
            if ~isfield(SS_all{s},'spec') || ~isfield(SS_all{s}.spec, region), continue, end
            Mi = SS_all{s}.spec.(region).M;
            if isempty(Mi) || size(Mi,2) ~= nF, continue, end
            stack(s,:,:) = Mi;
        end
        Mavg = squeeze(nanmean(stack, 1));
        held = false;
        for g = 1:nG
            if all(isnan(Mavg(g,:))), continue, end
            plot(refSS.spec.(region).f, Mavg(g,:), 'Color', refSS.groupColors{g}, ...
                 'LineWidth', 1.4)
            if ~held, hold on, held = true; end
        end
        xlim([0 10])
        xlabel('Frequency (Hz)'), ylabel(sprintf('log10 %s power', region))
        legend(refSS.groupNames, 'Box','off','Location','eastoutside', ...
            'Interpreter','none','FontSize',7)
    end
end
title('g) Mean low-band spectrum / substate')
set(gca,'TickDir','out','Box','off','FontSize',9)

% --- (h) light vs dark state proportion -------------------------------------
subplot(3, 4, 8)
prop = nan(nSess, 2, nState);
for s = 1:nSess
    if ~isempty(LD_all{s}) && ~isempty(LD_all{s}.propTotal)
        prop(s,:,:) = LD_all{s}.propTotal;
    end
end
A = cell(1, 2*nState); Cols = cell(1, 2*nState); Xpos = nan(1,2*nState); Lab = cell(1,2*nState);
for i = 1:nState
    A{2*i-1}    = 100*squeeze(prop(:,1,i));
    A{2*i}      = 100*squeeze(prop(:,2,i));
    Cols{2*i-1} = colors.colors{i};
    Cols{2*i}   = max(0, colors.colors{i} * 0.55);
    Xpos(2*i-1) = 3*(i-1)+1;
    Xpos(2*i)   = 3*(i-1)+2;
    Lab{2*i-1}  = sprintf('%sL', names{i});
    Lab{2*i}    = sprintf('%sD', names{i});
end
MakeSpreadAndBoxPlot3_SB(A, Cols, Xpos, Lab, ...
    'showpoints',1,'paired',0,'newfig',0);
ylabel('% of condition')
title('h) Light vs Dark composition')
xtickangle(45)
set(gca,'TickDir','out','Box','off','FontSize',9)

% --- bottom row: free for hypnogram/cycle traces in a future revision -------
% (left empty deliberately; place specific session examples there in final paper)

end


function draw_pie_local(p, labels, cols)
p = p(:)'; keep = p > 0 & ~isnan(p);
p = p(keep); labels = labels(keep); cols = cols(keep);
if isempty(p), axis off, return, end
h = pie(p);
for i = 1:numel(p)
    set(h(2*i-1), 'FaceColor', cols{i}, 'EdgeColor','w', 'LineWidth', 1)
    pct = round(100 * p(i)/sum(p));
    set(h(2*i), 'String', sprintf('%s %d%%', labels{i}, pct), 'FontSize', 8)
end
end


function region = pick_region_for_paper_AG(SS_all, preferenceList)
% Return the first preferred region that actually has data in any session.
region = '';
for k = 1:numel(preferenceList)
    candidate = preferenceList{k};
    for s = 1:numel(SS_all)
        if isempty(SS_all{s}) || ~isfield(SS_all{s},'spec'), continue, end
        if ~isfield(SS_all{s}.spec, candidate),               continue, end
        SP = SS_all{s}.spec.(candidate);
        if ~isempty(SP.f) && any(~isnan(SP.M(:)))
            region = candidate; return
        end
    end
end
end
