function ax = paper_panel_session_overview_AG(parentFig, region, SD, colors, lightOnIntervals_h)
% paper_panel_session_overview_AG  Draw the single-session 7-panel overview
% (hypnogram + 3 spectro/trace pairs) inside a rectangular region of an
% existing figure. Used by the paper figure script.
%
% INPUT
%   parentFig             figure handle to draw into
%   region                [x y w h] in normalized figure coords; the seven
%                         stacked sub-panels are packed inside this rectangle
%   SD                    output of load_session_AG (full session data)
%   colors                state_colors_AG output
%   lightOnIntervals_h    Nx2 hours, optional light-on intervals
%
% OUTPUT
%   ax  1x7 array of axes handles in top-to-bottom order:
%       [hypnogram, OBmid spectro, OBgamma trace, HPClow spectro,
%        HPC theta/delta trace, OBlow spectro, OB delta trace]

if nargin < 5, lightOnIntervals_h = []; end
if nargin < 4 || isempty(colors), colors = state_colors_AG(); end

x0 = region(1); y0 = region(2); w = region(3); h = region(4);
nP = 7;
gap = 0.004;
hP  = (h - (nP-1)*gap) / nP;

% top-to-bottom: hypnogram, OBmid, gamma, HPC, theta/delta, OBlow, delta
panelY = y0 + h - hP - (0:nP-1) * (hP + gap);
ax = gobjects(1, nP);
for k = 1:nP
    ax(k) = axes('Parent', parentFig, 'Position', [x0 panelY(k) w hP]);
end

states = {SD.states.Wake, SD.states.N1, SD.states.N2, SD.states.REM};

% --- (1) hypnogram --------------------------------------------------------
axes(ax(1)); hold on
% plot_hypnogram_bar_AG(states, colors, 1, 'timescaling', 3.6e7);
plot_hypnogram_full_AG(SD, SD.name, colors, lightOnIntervals_h);

xlim([0 SD.totDur_h]); ylim([0.5 5])
set(gca, 'YTick', [], 'XTick', [], 'TickDir','out', 'Box','off')

% --- (2) OB middle spectrogram --------------------------------------------
axes(ax(2))
draw_spectro_AG(SD.spec.OBgamma, [20 100], [2.1 3.6])
ylabel('OB f (Hz)')
set(gca,'XTickLabel',[],'FontSize',8,'TickDir','out','Box','off')
hline([40 60], '--w');
caxis([2.2 3.4])

% --- (3) OB gamma trace ---------------------------------------------------
axes(ax(3))
draw_smooth_AG(SD.sig.SmoothGamma, 1e4, 800)
ylabel('OB \gamma')
set(gca,'XTickLabel',[],'FontSize',8,'TickDir','out','Box','off')
ylim([100 800])

% --- (4) HPC low spectrogram ---------------------------------------------
axes(ax(4))
draw_spectro_AG(SD.spec.HPClow, [0 10], [3.5 5.4])
ylabel('HPC f (Hz)')
set(gca,'XTickLabel',[],'FontSize',8,'TickDir','out','Box','off')
hline([3 6], '--w');
caxis([3.8 5.6])

% --- (5) HPC theta/delta trace --------------------------------------------
axes(ax(5))
draw_smooth_AG(SD.sig.SmoothTheta, 1e4, 14)
ylabel('HPC \theta/\delta')
set(gca,'XTickLabel',[],'FontSize',8,'TickDir','out','Box','off')
ylim([0 5])

% --- (6) OB low spectrogram ----------------------------------------------
axes(ax(6))
draw_spectro_AG(SD.spec.OBlow, [0 10], [3.5 4.4])
ylabel('OB f (Hz)')
set(gca,'XTickLabel',[],'FontSize',8,'TickDir','out','Box','off')
hline([0.5 4], '--w');
caxis([3.1 3.7])

% --- (7) OB delta trace --------------------------------------------------
axes(ax(7))
draw_smooth_AG(SD.sig.SmoothDelta_OB, 1e4, 700)
ylabel('OB \delta')
xlabel('Time (h)')
set(gca,'FontSize',8,'TickDir','out','Box','off')
ylim([50 250])

% Link x-axes
linkaxes(ax, 'x'); xlim(ax(end), [0 SD.totDur_h])
colormap(parentFig, viridis)

% Light/dark shading on the trace panels (not on hypnogram/spectro)
if ~isempty(lightOnIntervals_h)
    add_light_shading_AG(ax([3 5 7]), lightOnIntervals_h, SD.totDur_h, ...
        'colors', colors, 'alpha', 0.3);
end

end


% =========================================================================
function plot_hypnogram_bar_AG(states, colors, yLevel, varargin)
p = inputParser;
addParameter(p,'timescaling', 3.6e7);
parse(p, varargin{:})
ts = p.Results.timescaling;
for i = 1:4
    if isempty(states{i}), continue, end
    sti = Start(states{i}); eni = Stop(states{i});
    for k = 1:numel(sti)
        line([sti(k) eni(k)]/ts, [yLevel yLevel], ...
             'Color', colors.colors{i}, 'LineWidth', 6)
    end
end
end


function draw_spectro_AG(SP, freqLim, cLim)
if isempty(SP)
    text(.5,.5,'spectrogram missing','Units','normalized', ...
        'HorizontalAlignment','center'); axis off; return
end
D = Data(SP.tsd); R = Range(SP.tsd);
ds = max(1, round(numel(R)/15000));
D = D(1:ds:end, :); R = R(1:ds:end);
imagesc(R/3.6e7, SP.f, runmean(runmean(log10(D'),2)',10)')
axis xy; ylim(freqLim)
if ~isempty(cLim), caxis(cLim); end
end


function draw_smooth_AG(sig, dsfac, ymax)
if isempty(sig)
    text(.5,.5,'signal missing','Units','normalized', ...
        'HorizontalAlignment','center'); axis off; return
end
R = Range(sig); D = Data(sig);
ds = max(1, round(numel(R)/dsfac));
plot(R(1:ds:end)/3.6e7, D(1:ds:end), 'k', 'LineWidth', 0.5)
if ~isempty(ymax), ylim([0 ymax]); end
box off
end
