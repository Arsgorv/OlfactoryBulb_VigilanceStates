function fig = plot_substate_organization_AG(ORG_all, BF_all, sessionNames, colors)
% plot_substate_organization_AG  Clear visual comparison of short vs long
% bouts for N1/N2/REM. 3 rows (one per state) x 3 columns:
%   Col 1: fraction of bouts that are LONG across the recording (per session),
%          i.e. evolution of the short/long mix over time.
%   Col 2: within-cycle phase distribution of short vs long bouts (pooled),
%          i.e. whether short/long bouts sit at different points of the cycle.
%   Col 3: the discriminating HPC/OB feature, short vs long distributions
%          (pooled), i.e. how their physiology differs.
%
% INPUT
%   ORG_all        1xN cell of compute_substate_organization_AG outputs
%   BF_all         1xN cell of compute_bout_features_AG outputs (for colors/labels)
%   sessionNames   1xN cellstr
%   colors         state_colors_AG output (optional)
%
% OUTPUT
%   fig  figure handle

if nargin < 4 || isempty(colors), colors = state_colors_AG(); end
nSess  = numel(ORG_all);
states = ORG_all{1}.states;
nState = numel(states);

fig = figure('Color','w','Units','normalized','Position',[.04 .03 .9 .92]);

sessLineStyle = {'-','--',':','-.'};

for si = 1:nState
    sName = states{si};
    pIdx  = find(strcmp(colors.names, sName), 1);
    cShort = max(0, colors.colors{pIdx} * 0.55);
    cLong  = colors.colors{pIdx} + (1 - colors.colors{pIdx}) * 0.45;

    % ----- Col 1: fraction long over recording -----
    subplot(nState, 3, (si-1)*3 + 1)
    held = false; legH = []; legL = {};
    for s = 1:nSess
        ORG = ORG_all{s};
        ph = plot(ORG.timeBinCenters_h, ORG.fracLong{si}, ...
            sessLineStyle{mod(s-1,4)+1}, 'Color', colors.colors{pIdx}, ...
            'LineWidth', 1.8, 'Marker','o', 'MarkerSize',3, ...
            'MarkerFaceColor', colors.colors{pIdx});
        if ~held, hold on, held = true; end
        legH(end+1) = ph; legL{end+1} = sessionNames{s}; %#ok<AGROW>
    end
    plot(xlim, [0.5 0.5], 'k:', 'LineWidth', 0.8)
    ylim([0 1])
    xlabel('Time in recording (h)')
    ylabel(sprintf('%s: fraction long', sName))
    if si == 1
        title('Short/long mix over recording')
        legend(legH, legL, 'Box','off','Location','best','Interpreter','none')
    end
    set(gca,'TickDir','out','Box','off','FontSize',9)

    % ----- Col 2: within-cycle phase distribution -----
    subplot(nState, 3, (si-1)*3 + 2)
    pShort = []; pLong = [];
    for s = 1:nSess
        pShort = [pShort; ORG_all{s}.phaseShort{si}(:)]; %#ok<AGROW>
        pLong  = [pLong;  ORG_all{s}.phaseLong{si}(:)];  %#ok<AGROW>
    end
    edges = linspace(0, 1, 11);
    xc = edges(1:end-1) + diff(edges)/2;
    held = false;
    if ~isempty(pShort)
        h = histcounts(pShort, edges, 'Normalization','probability');
        stairs(xc, h, 'Color', cShort, 'LineWidth', 2); hold on; held = true;
    end
    if ~isempty(pLong)
        h = histcounts(pLong, edges, 'Normalization','probability');
        stairs(xc, h, 'Color', cLong, 'LineWidth', 2);
        if ~held, hold on, held = true; end
    end
    xlim([0 1])
    xlabel('Cycle progress (0 = prev REM end, 1 = next)')
    ylabel('Fraction of bouts')
    if si == 1
        title('Where in the cycle')
        legend({'short','long'}, 'Box','off','Location','best')
    end
    set(gca,'TickDir','out','Box','off','FontSize',9)

    % ----- Col 3: discriminating feature short vs long -----
    subplot(nState, 3, (si-1)*3 + 3)
    sShort = []; sLong = [];
    for s = 1:nSess
        sShort = [sShort; ORG_all{s}.sigShort{si}(:)]; %#ok<AGROW>
        sLong  = [sLong;  ORG_all{s}.sigLong{si}(:)];  %#ok<AGROW>
    end
    allv = [sShort; sLong];
    allv = allv(~isnan(allv) & allv > 0);
    held = false;
    if ~isempty(allv)
        edgesF = linspace(min(allv), max(allv), 25);
        xcF = edgesF(1:end-1) + diff(edgesF)/2;
        if ~isempty(sShort)
            h = histcounts(sShort, edgesF, 'Normalization','probability');
            stairs(xcF, h, 'Color', cShort, 'LineWidth', 2); hold on; held = true;
        end
        if ~isempty(sLong)
            h = histcounts(sLong, edgesF, 'Normalization','probability');
            stairs(xcF, h, 'Color', cLong, 'LineWidth', 2);
            if ~held, hold on, held = true; end
        end
    end
    xlabel(ORG_all{1}.sigName{si})
    ylabel('Fraction of bouts')
    if si == 1
        title('Discriminating signature')
        legend({'short','long'}, 'Box','off','Location','best')
    end
    set(gca,'TickDir','out','Box','off','FontSize',9)
end

end
