function fig = plot_bout_features_AG(BF_all, sessionNames)
% plot_bout_features_AG  Box-plot characterization of substates: each panel
% shows one feature, x = state subgroups (Wake / N1 short / N1 long / N2 short
% / N2 long / REM short / REM long), bouts pooled across sessions. Uses
% MakeSpreadAndBoxPlot3_SB.
%
% INPUT
%   BF_all         1xN cell of compute_bout_features_AG outputs. Subgroup
%                  names must be identical across cells (they are, by
%                  construction).
%   sessionNames   1xN cellstr (currently unused; sessions are pooled here.
%                  Kept in the signature for future per-session variants.)
%
% OUTPUT
%   fig  figure handle

if isempty(BF_all), fig = []; return, end

% Use first session's group structure as the reference; pool by group name
groupNames  = BF_all{1}.groupNames;
groupColors = BF_all{1}.groupColors;
featNames   = BF_all{1}.featNames;
nG = numel(groupNames);
nF = numel(featNames);

% Pool feature values across sessions for matching group names
Xpool = cell(nF, nG);
for s = 1:numel(BF_all)
    BF = BF_all{s};
    for g = 1:numel(BF.groupNames)
        gIdx = find(strcmp(groupNames, BF.groupNames{g}), 1);
        if isempty(gIdx), continue, end
        for f = 1:nF
            Xpool{f, gIdx} = [Xpool{f, gIdx}; BF.X{f, g}(:)];
        end
    end
end

% --- Layout: 2 rows x 3 cols (6 features) ------------------------------------
% Convert the bout-duration feature (last one) from minutes to seconds for
% display, since the user's primary unit for bouts is seconds.
durIdx = find(strcmp(featNames, 'Bout duration (min)'), 1);
if ~isempty(durIdx)
    featNames{durIdx} = 'Bout duration (s)';
    for g = 1:nG
        if ~isempty(Xpool{durIdx, g})
            Xpool{durIdx, g} = Xpool{durIdx, g} * 60;   % min -> s
        end
    end
end

fig = figure('Color','w','Units','normalized','Position',[.04 .05 .92 .82]);
useLog = [true true true true false true];   % EMG, Accelero, gamma, delta, ratio, duration
for f = 1:nF
    subplot(2, 3, f)
    A = Xpool(f, :);
    for g = 1:nG
        if isempty(A{g}), A{g} = NaN; end
    end
    MakeSpreadAndBoxPlot3_SB(A, groupColors, 1:nG, groupNames, ...
        'showpoints', 0, 'paired', 0, 'newfig', 0);
    if useLog(f)
        set(gca,'YScale','log')
    end
    ylabel(featNames{f})
    title(featNames{f})
    xtickangle(30)
    set(gca,'TickDir','out','Box','off','FontSize',9)
end

end
