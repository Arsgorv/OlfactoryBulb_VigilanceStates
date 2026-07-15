function paper_row2_composition_AG(fig, region, M, C, PS, sessNames, colors) %#ok<INUSL>
% paper_row2_composition_AG  Draws the composition / bouts / cycle-duration
% row of the paper figure: pie all states, pie sleep, composition box,
% bouts box, bout-duration box, cycle-duration box (one column per animal).

x0 = region(1); y0 = region(2); w = region(3); h = region(4);
nP = 6;
relW = [0.10 0.10 0.16 0.16 0.16 0.32];
gap = 0.012;
xs = x0 + cumsum([0, relW(1:end-1)*w]) + (0:nP-1)*gap;
ws = relW * w;

nSess = numel(M); names = colors.names;
propTotal = nan(nSess,4); propSleep = nan(nSess,4);
for s = 1:nSess
    propTotal(s,:) = M{s}.prop_total;
    propSleep(s,:) = M{s}.prop_sleep;
end

% Pie 1: all states
axes('Parent',fig,'Position',[xs(1) y0 ws(1) h])
pp = nanmean(propTotal,1); pp = pp/sum(pp);
hp = pie(pp);
for i = 1:numel(pp), set(hp(2*i-1),'FaceColor',colors.colors{i},'EdgeColor','w'); end
for i = 1:numel(pp), set(hp(2*i),'String',sprintf('%s %d%%',names{i},round(100*pp(i))),'FontSize',7); end
title('Mean composition','FontWeight','normal','FontSize',9)

% Pie 2: sleep only
axes('Parent',fig,'Position',[xs(2) y0 ws(2) h])
ps = nanmean(propSleep(:,2:4),1); ps = ps/sum(ps);
hp = pie(ps);
for i = 1:numel(ps), set(hp(2*i-1),'FaceColor',colors.colors{i+1},'EdgeColor','w'); end
for i = 1:numel(ps), set(hp(2*i),'String',sprintf('%s %d%%',names{i+1},round(100*ps(i))),'FontSize',7); end
title('Sleep only','FontWeight','normal','FontSize',9)

% Composition box (% of recording)
axes('Parent',fig,'Position',[xs(3) y0 ws(3) h])
A = cell(1,4); for i = 1:4, A{i} = 100*propTotal(:,i); end
MakeSpreadAndBoxPlot3_SB(A, colors.colors, 1:4, names, ...
    'showpoints',1,'paired',0,'newfig',0);
hold on; for s = 1:nSess, plot(1:4, 100*propTotal(s,:), '-', 'Color',[.5 .5 .5 .4]); end
ylabel('% of recording'); title('Composition','FontWeight','normal','FontSize',9)
axis square; set(gca,'TickDir','out','Box','off','FontSize',8); xtickangle(20)

% Bouts box
axes('Parent',fig,'Position',[xs(4) y0 ws(4) h])
Mat = nan(nSess,4); A = cell(1,4);
for i = 1:4, for s = 1:nSess, Mat(s,i) = M{s}.nbouts(i); end, A{i} = Mat(:,i); end
MakeSpreadAndBoxPlot3_SB(A, colors.colors, 1:4, names, ...
    'showpoints',1,'paired',0,'newfig',0);
hold on; for s = 1:nSess, plot(1:4, Mat(s,:), '-', 'Color',[.5 .5 .5 .4]); end
ylabel('# bouts'); title('Bouts','FontWeight','normal','FontSize',9)
axis square; set(gca,'TickDir','out','Box','off','FontSize',8); xtickangle(20)

% Bout-duration box (median per session)
axes('Parent',fig,'Position',[xs(5) y0 ws(5) h])
Mat = nan(nSess,4); A = cell(1,4);
for i = 1:4, for s = 1:nSess, Mat(s,i) = M{s}.bout_med(i); end, A{i} = Mat(:,i); end
MakeSpreadAndBoxPlot3_SB(A, colors.colors, 1:4, names, ...
    'showpoints',1,'paired',0,'newfig',0);
hold on; for s = 1:nSess, plot(1:4, Mat(s,:), '-', 'Color',[.5 .5 .5 .4]); end
set(gca,'YScale','log'); ylabel('Bout dur (s)')
title('Bout duration','FontWeight','normal','FontSize',9)
axis square; set(gca,'TickDir','out','Box','off','FontSize',8); xtickangle(20)

% Cycle duration: one column per animal
axes('Parent',fig,'Position',[xs(6) y0 ws(6) h])
animals = unique(PS.animalOfSession,'stable');
nA = numel(animals);
A = cell(1, nA); Cols = cell(1, nA);
greys = linspace(0.25, 0.7, max(2,nA));
for a = 1:nA
    sessThis = find(strcmp(PS.animalOfSession, animals{a}));
    pooled = [];
    for s = sessThis
        if ~isempty(C{s}) && ~isempty(C{s}.cycleDur_min)
            pooled = [pooled; C{s}.cycleDur_min(:)]; %#ok<AGROW>
        end
    end
    A{a} = pooled;
    Cols{a} = greys(a)*[1 1 1];
end
MakeSpreadAndBoxPlot3_SB(A, Cols, 1:nA, animals, ...
    'showpoints',0,'paired',0,'newfig',0);
ylabel('Cycle duration (min)')
title('Cycle duration / animal','FontWeight','normal','FontSize',9)

axis square; set(gca,'TickDir','out','Box','off','FontSize',8); xtickangle(20)
end
