function plot_hypnogram_AG(states, colors, yLevel, varargin)
% plot_hypnogram_AG  Draw a colored hypnogram bar at a single y level on the
% current axes. State epochs are plotted as horizontal line segments.
%
% INPUT
%   states     cell {Wake, N1, N2, REM} of intervalSet (1e-4 s)
%   colors     state_colors_AG output (uses .colors)
%   yLevel     y-coordinate of the line
%
% OPTIONAL name-value
%   'lw'           line width (default 6)
%   'timescaling'  divisor to convert raw ts to plot units (default 3.6e7 -> hours)
%
% Drawing follows Baptiste's PlotPerAsLine pattern but is condensed and uses
% the lab color convention via state_colors_AG.

p = inputParser;
addParameter(p, 'lw',          6);
addParameter(p, 'timescaling', 3.6e7);
parse(p, varargin{:});
lw = p.Results.lw;
ts = p.Results.timescaling;

held = ishold;
hold on
for i = 1:4
    if isempty(states{i}), continue, end
    sti = Start(states{i});
    eni = Stop(states{i});
    for k = 1:numel(sti)
        line([sti(k) eni(k)]/ts, [yLevel yLevel], ...
             'Color', colors.colors{i}, 'LineWidth', lw)
    end
end
if ~held, hold off; end
end
