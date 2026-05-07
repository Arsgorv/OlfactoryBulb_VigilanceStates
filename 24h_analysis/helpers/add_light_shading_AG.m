function add_light_shading_AG(ax, lightOnIntervals_h, recordingDur_h, varargin)
% add_light_shading_AG  Overlay light/dark background bands on time-axis plots.
%
% INPUT
%   ax                    axes handle (or vector of handles)
%   lightOnIntervals_h    Nx2 matrix of [startHour endHour] in recording-relative
%                         hours during which lights were ON. The complement of
%                         these intervals (within [0, recordingDur_h]) is shaded
%                         as "lights OFF".
%   recordingDur_h        recording duration in hours
%
% OPTIONAL name-value
%   'colors'   state_colors_AG output (uses .bgLight, .bgDark). Default = call.
%   'alpha'    transparency of the bands (default 0.25)
%
% Notes
%   Bands are drawn in the BACKGROUND of each axes (uistack -> bottom). If the
%   axes already contain a colored image (e.g. spectrogram with viridis), the
%   spectrogram itself is opaque so the band only shows above/below it where
%   the data does not paint.

p = inputParser;
addParameter(p, 'colors', []);
addParameter(p, 'alpha',  0.25);
parse(p, varargin{:});
colors = p.Results.colors;
if isempty(colors), colors = state_colors_AG(); end
alpha = p.Results.alpha;

if nargin < 2 || isempty(lightOnIntervals_h)
    return
end

% Build dark intervals = [0, T] minus light intervals
darkIntervals = invert_intervals(lightOnIntervals_h, recordingDur_h);

if ~isvector(ax), ax = ax(:); end

for k = 1:numel(ax)
    a = ax(k);
    yl = get(a, 'YLim');
    held = ishold(a); hold(a, 'on')

    for i = 1:size(lightOnIntervals_h,1)
        x0 = lightOnIntervals_h(i,1);
        x1 = lightOnIntervals_h(i,2);
        if x1 <= x0, continue, end
        patch(a, [x0 x1 x1 x0], [yl(1) yl(1) yl(2) yl(2)], colors.bgLight, ...
            'EdgeColor','none', 'FaceAlpha', alpha, 'HandleVisibility','off')
    end
    for i = 1:size(darkIntervals,1)
        x0 = darkIntervals(i,1);
        x1 = darkIntervals(i,2);
        if x1 <= x0, continue, end
        patch(a, [x0 x1 x1 x0], [yl(1) yl(1) yl(2) yl(2)], colors.bgDark, ...
            'EdgeColor','none', 'FaceAlpha', alpha, 'HandleVisibility','off')
    end
    % Push patches behind any existing data
    ch = get(a, 'Children');
    isPatch = strcmp(get(ch,'Type'), 'patch');
    set(a, 'Children', [ch(~isPatch); ch(isPatch)])
    set(a, 'YLim', yl)
    if ~held, hold(a, 'off'), end
end

end


function out = invert_intervals(I, T)
% Complement of intervals I within [0 T]
if isempty(I), out = [0 T]; return, end
I = sortrows(I);
out = zeros(0,2);
prevEnd = 0;
for k = 1:size(I,1)
    if I(k,1) > prevEnd
        out(end+1,:) = [prevEnd I(k,1)]; %#ok<AGROW>
    end
    prevEnd = max(prevEnd, I(k,2));
end
if prevEnd < T
    out(end+1,:) = [prevEnd T]; %#ok<AGROW>
end
end
