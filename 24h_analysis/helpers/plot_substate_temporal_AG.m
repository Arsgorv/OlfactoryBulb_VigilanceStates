function fig = plot_substate_temporal_AG(BF_all, sessionNames, lightOnIntervals, totDur_h)
% plot_substate_temporal_AG  When in the recording do short vs long bouts of
% each state occur? Each panel shows one state for one session: x = bout
% start time (h since recording start), y = bout duration (s, log scale).
% A dashed horizontal line marks the short/long threshold; bouts below are
% drawn in the parent state's "darker" color, bouts above in the "lighter"
% color (matching the substate transition diagram).
%
% Optional: light-on bands shaded behind each panel if lightOnIntervals
% provided.
%
% INPUT
%   BF_all              1xN cell of compute_bout_features_AG outputs
%   sessionNames        1xN cellstr
%   lightOnIntervals    1xN cell of light-on intervals (recording-relative h),
%                       or {} to skip shading.
%   totDur_h            1xN vector of recording durations (h) per session
%
% OUTPUT
%   fig  figure handle

if nargin < 3, lightOnIntervals = {}; end
if nargin < 4 || isempty(totDur_h), totDur_h = []; end

nSess = numel(BF_all);
states = {'N1','N2','REM'};         % only the states with short/long split
nState = numel(states);
colors = state_colors_AG();

fig = figure('Color','w','Units','normalized','Position',[.04 .04 .9 .9]);

for r = 1:nState
    parentName = states{r};
    pIdx = find(strcmp(colors.names, parentName), 1);
    cShort = max(0, colors.colors{pIdx} * 0.55);
    cLong  = colors.colors{pIdx} + (1-colors.colors{pIdx}) * 0.45;

    for s = 1:nSess
        subplot(nState, nSess, (r-1)*nSess + s)
        BF = BF_all{s};
        thr_min = BF.thresholds_min.(parentName);

        gShort = find(strcmp(BF.groupNames, sprintf('%s short', parentName)), 1);
        gLong  = find(strcmp(BF.groupNames, sprintf('%s long',  parentName)), 1);

        held = false;
        if ~isempty(gShort) && ~isempty(BF.boutStarts_h{gShort})
            t = BF.boutStarts_h{gShort};
            d = (Stop(BF.groupEpochs{gShort}) - Start(BF.groupEpochs{gShort})) / 1e4;
            scatter(t, d, 14, cShort, 'filled', 'MarkerFaceAlpha', 0.55, ...
                'MarkerEdgeColor', 'none')
            held = true; hold on
        end
        if ~isempty(gLong) && ~isempty(BF.boutStarts_h{gLong})
            t = BF.boutStarts_h{gLong};
            d = (Stop(BF.groupEpochs{gLong}) - Start(BF.groupEpochs{gLong})) / 1e4;
            scatter(t, d, 14, cLong, 'filled', 'MarkerFaceAlpha', 0.6, ...
                'MarkerEdgeColor', 'none')
            if ~held, hold on, held = true; end
        end

        % Threshold line
        if ~isempty(thr_min)
            thr_s = thr_min * 60;
            xl = get(gca, 'XLim');
            if ~isempty(totDur_h) && numel(totDur_h) >= s, xl = [0 totDur_h(s)]; end
            plot(xl, [thr_s thr_s], '--', 'Color', [.2 .2 .2], 'LineWidth', 1.0)
        end

        set(gca,'YScale','log','TickDir','out','Box','off','FontSize',9)
        if ~isempty(totDur_h) && numel(totDur_h) >= s
            xlim([0 totDur_h(s)])
        end
        xlabel('Bout start time (h)')
        ylabel(sprintf('%s bout duration (s)', parentName))
        title(sprintf('%s - %s', sessionNames{s}, parentName), 'Interpreter','none')

        % Light/dark shading
        if numel(lightOnIntervals) >= s && ~isempty(lightOnIntervals{s}) ...
                && ~isempty(totDur_h) && numel(totDur_h) >= s
            add_light_shading_AG(gca, lightOnIntervals{s}, totDur_h(s), ...
                'colors', colors, 'alpha', 0.15);
        end

        if r == 1 && s == nSess
            legend({sprintf('%s short', parentName), sprintf('%s long', parentName)}, ...
                'Box','off','Location','northeast')
        end
    end
end

end
