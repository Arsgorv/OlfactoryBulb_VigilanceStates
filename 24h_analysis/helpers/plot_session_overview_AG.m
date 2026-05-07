function fig = plot_session_overview_AG(SD, colors, lightOnIntervals_h)
% plot_session_overview_AG  Single-session "scoring sanity" figure: OB-gamma
% and OB-low and HPC-low spectrograms aligned with their smoothed scoring
% features, accelerometer, EMG and a hypnogram bar - all over the full 24 h.
%
% INPUT
%   SD                    output of load_session_AG
%   colors                output of state_colors_AG (optional)
%   lightOnIntervals_h    Nx2 matrix of recording-relative hours during which
%                         lights were ON. If provided, light/dark bands are
%                         shaded behind the EMG and accelero panels (the
%                         panels least likely to be visually overwhelmed by
%                         a colored spectrogram). Pass [] to skip.
%
% OUTPUT
%   fig      handle to the created figure

if nargin < 2 || isempty(colors), colors = state_colors_AG(); end
if nargin < 3, lightOnIntervals_h = []; end

states = {SD.states.Wake, SD.states.N1, SD.states.N2, SD.states.REM};
hypY = 1.05;   % hypnogram line, in normalized panel height units later

fig = figure('Color','w','Units','normalized','Position',[.05 .05 .55 .9]);
nRow = 8;

% --- Panel 1: OB middle (gamma) spectrogram + hypnogram ----------------------
ax(1) = subplot(nRow,1,1);
plot_spectro_panel(SD.spec.OBgamma, [20 100], [2.1 3.6]);
ylabel({'OB','20-100 Hz'})
plot_hypnogram_AG(states, colors, get_top_y(gca), 'lw', 8);
title(SD.name, 'FontWeight','bold','Interpreter','none')

% --- Panel 2: smooth OB gamma ------------------------------------------------
ax(2) = subplot(nRow,1,2);
plot_smooth_signal(SD.sig.SmoothGamma, 1e4, 800);
ylabel({'OB','gamma pow'})

% --- Panel 3: HPC low spectrogram + hypnogram --------------------------------
ax(3) = subplot(nRow,1,3);
plot_spectro_panel(SD.spec.HPClow, [0 10], [3.5 5.4]);
ylabel({'HPC','0-10 Hz'})
plot_hypnogram_AG(states, colors, get_top_y(gca), 'lw', 8);

% --- Panel 4: smooth theta/delta ratio ---------------------------------------
ax(4) = subplot(nRow,1,4);
plot_smooth_signal(SD.sig.SmoothTheta, 1e4, 14.5);
ylabel({'HPC','theta/delta'})

% --- Panel 5: OB low spectrogram + hypnogram ---------------------------------
ax(5) = subplot(nRow,1,5);
plot_spectro_panel(SD.spec.OBlow, [0 10], [3.5 4.4]);
ylabel({'OB','0-10 Hz'})
plot_hypnogram_AG(states, colors, get_top_y(gca), 'lw', 8);

% --- Panel 6: smooth OB delta ------------------------------------------------
ax(6) = subplot(nRow,1,6);
plot_smooth_signal(SD.sig.SmoothDelta_OB, 1e4, 700);
ylabel({'OB','delta pow'})

% --- Panel 7: accelerometer --------------------------------------------------
ax(7) = subplot(nRow,1,7);
plot_smooth_signal(SD.sig.MovAcctsd, 100, []);
ylabel({'Accelero'})

% --- Panel 8: EMG ------------------------------------------------------------
ax(8) = subplot(nRow,1,8);
plot_smooth_signal(SD.sig.EMG_tsd, 1e4, []);
ylabel({'EMG','50-300 Hz'})
xlabel('Time (h)')

% Common formatting: link x-axes, set 0..totDur_h, hide x-tick-labels except bottom
linkaxes(ax, 'x')
xlim(ax(end), [0 SD.totDur_h])
for k = 1:numel(ax)-1
    set(ax(k), 'XTickLabel', []);
end
for k = 1:numel(ax)
    set(ax(k), 'TickDir','out','Box','off','FontSize',9)
end
colormap(viridis)

% Light/dark shading on the smooth-trace and EMG/accelero panels only.
% Spectrograms are opaque and would obscure the bands — skip them.
if ~isempty(lightOnIntervals_h)
    add_light_shading_AG(ax([2 4 6 7 8]), lightOnIntervals_h, SD.totDur_h, ...
        'colors', colors, 'alpha', 0.18);
end

end


% =============================================================================
% local helper subroutines (this file only — kept here because they are figure-
% panel boilerplate. They are NOT user-facing helpers.)
% =============================================================================

function plot_spectro_panel(SP, freqLim, cLim)
if isempty(SP)
    text(.5,.5,'spectrogram missing','Units','normalized','HorizontalAlignment','center')
    axis off
    return
end
% Subsample heavily to keep figure size sane
D = Data(SP.tsd);
R = Range(SP.tsd);
ds = max(1, round(numel(R)/15000));
D = D(1:ds:end, :);
R = R(1:ds:end);
imagesc(R/3.6e7, SP.f, runmean(runmean(log10(D'),2)',10)')
axis xy
ylim(freqLim)
if ~isempty(cLim), caxis(cLim); end
end


function plot_smooth_signal(sig, dsfac, ymax)
if isempty(sig)
    text(.5,.5,'signal missing','Units','normalized','HorizontalAlignment','center')
    axis off
    return
end
R = Range(sig);
D = Data(sig);
ds = max(1, round(numel(R)/dsfac));
plot(R(1:ds:end)/3.6e7, D(1:ds:end), 'k', 'LineWidth', 0.5)
if ~isempty(ymax), ylim([0 ymax]); end
box off
end


function y = get_top_y(ax)
yl = get(ax,'YLim');
y  = yl(2) - 0.02*(yl(2)-yl(1));
end
