function ax = paper_panel_phase_space_AG(parentFig, region, SD, colors)
% paper_panel_phase_space_AG
%
% Two stacked phase-space panels with marginal histograms:
%   top    : theta/delta vs gamma
%   bottom : theta/delta vs delta
%
% Adjusted to look more like the reference:
%   - sparser scatter clouds
%   - threshold lines on histograms
%   - cleaner Bagur-like appearance

if nargin < 4 || isempty(colors)
    colors = state_colors_AG();
end
if isempty(parentFig)
    parentFig = gcf;
end
figure(parentFig)

ax = gobjects(1,6);

if isempty(region)
    region = [0.68 0.08 0.30 0.86];
end

SmoothGammaNew = get_signal_AG(SD.sig, 'SmoothGammaNew', 'SmoothGamma');
SmoothThetaNew = get_signal_AG(SD.sig, 'SmoothThetaNew', 'SmoothTheta');
SmoothDeltaNew = get_signal_AG(SD.sig, 'SmoothDeltaNew', 'SmoothDelta_OB', 'SmoothDelta');

SmoothGamma = SmoothGammaNew;
SmoothTheta = SmoothThetaNew;

if isempty(SmoothGammaNew) || isempty(SmoothThetaNew) || isempty(SmoothDeltaNew)
    ax(1) = axes('Parent', parentFig, 'Position', region);
    axis off
    text(.5,.5,'signals missing','Units','normalized', ...
        'HorizontalAlignment','center')
    return
end

Wake     = get_epoch_AG(SD.states, 'Wake', 'WakeEpoch');
REMEpoch = get_epoch_AG(SD.states, 'REM', 'REMEpoch');
SWSEpoch = get_epoch_AG(SD.states, 'SWS', 'N2', 'SWSEpoch');
ISEpoch  = get_epoch_AG(SD.states, 'IS', 'N1', 'ISEpoch');

Sleep = get_epoch_AG(SD.states, 'Sleep', 'SleepEpoch');
if epoch_isempty_AG(Sleep)
    Sleep = epoch_or_AG(REMEpoch, epoch_or_AG(SWSEpoch, ISEpoch));
end

SWSEpochWithIS = epoch_or_AG(SWSEpoch, ISEpoch);

Info = get_info_AG(SD);
Colors = get_phase_colors_AG(colors);

% Make phase-space sparse
dtPlot = 2.5;   % seconds between plotted points

% ===================== TOP: theta/delta vs gamma =====================
ax(1) = axes('Parent', parentFig, 'Position', local_pos_AG(region, 1, 2, 2, 3));
hold on

[xREM, yREM]   = get_phase_points_AG(SmoothGammaNew, SmoothThetaNew, REMEpoch, dtPlot, 'log', 'log');
[xSWS, ySWS]   = get_phase_points_AG(SmoothGammaNew, SmoothThetaNew, SWSEpochWithIS, dtPlot, 'log', 'log');
[xWake, yWake] = get_phase_points_AG(SmoothGammaNew, SmoothThetaNew, Wake, dtPlot, 'log', 'log');

scatter(xREM,  yREM,  4, Colors.REM,  'filled', 'MarkerFaceAlpha', 0.45, 'MarkerEdgeAlpha', 0.15)
scatter(xSWS,  ySWS,  4, Colors.SWS,  'filled', 'MarkerFaceAlpha', 0.45, 'MarkerEdgeAlpha', 0.15)
scatter(xWake, yWake, 4, Colors.Wake, 'filled', 'MarkerFaceAlpha', 0.35, 'MarkerEdgeAlpha', 0.10)

legend('REM','N2','Wake', 'Location','northeast', 'Box','off')
box off
set(gca,'XTick',[],'YTick',[],'FontSize',8)

x_l = xlim;
y_l = ylim;
ys = get(gca,'YLim');
xs = get(gca,'XLim');

% left histogram: theta/delta
ax(2) = axes('Parent', parentFig, 'Position', local_pos_AG(region, 1, 1, 2, 1));
hold on

thetaSleep = log(Data(Restrict(SmoothTheta, Sleep)));
[~, rawN, ~] = nhist(thetaSleep, ...
    'maxx', max(thetaSleep), ...
    'noerror', ...
    'xlabel', 'Theta/Delta power', ...
    'ylabel', []);

axis xy
xlim(y_l)
view(90,-90)

if isfield(Info, 'theta_thresh') && ~isempty(Info.theta_thresh)
    line([log(Info.theta_thresh) log(Info.theta_thresh)], [0 max(rawN)], ...
        'LineWidth', 4, 'Color', 'r');
end

set(gca,'YTick',[],'XLim',ys,'FontSize',8)

% bottom histogram: gamma
ax(3) = axes('Parent', parentFig, 'Position', local_pos_AG(region, 3, 2, 1, 3));
hold on

gammaAll = log(Data(SmoothGamma));
[~, rawN, ~] = nhist(gammaAll, ...
    'maxx', max(gammaAll), ...
    'noerror', ...
    'xlabel', 'Gamma power', ...
    'ylabel', []);

xlim(x_l)

if isfield(Info, 'gamma_thresh') && ~isempty(Info.gamma_thresh)
    line([log(Info.gamma_thresh) log(Info.gamma_thresh)], [0 max(rawN)], ...
        'LineWidth', 4, 'Color', 'r');
end

set(gca,'YTick',[],'XLim',xs,'FontSize',8)

% ===================== BOTTOM: theta/delta vs delta =====================
ax(4) = axes('Parent', parentFig, 'Position', local_pos_AG(region, 4, 2, 2, 3));
hold on

% use natural log here as well, to look more like the second image
[xREM, yREM] = get_phase_points_AG(SmoothDeltaNew, SmoothThetaNew, REMEpoch, dtPlot, 'log', 'log');
[xSWS, ySWS] = get_phase_points_AG(SmoothDeltaNew, SmoothThetaNew, SWSEpoch, dtPlot, 'log', 'log');
[xIS,  yIS]  = get_phase_points_AG(SmoothDeltaNew, SmoothThetaNew, ISEpoch,  dtPlot, 'log', 'log');

scatter(xREM, yREM, 4, Colors.REM, 'filled', 'MarkerFaceAlpha', 0.45, 'MarkerEdgeAlpha', 0.15)
scatter(xSWS, ySWS, 4, Colors.SWS, 'filled', 'MarkerFaceAlpha', 0.45, 'MarkerEdgeAlpha', 0.15)
scatter(xIS,  yIS,  4, Colors.IS,  'filled', 'MarkerFaceAlpha', 0.35, 'MarkerEdgeAlpha', 0.10)

legend('REM','N2','N1', 'Location','northeast', 'Box','off')
box off
set(gca,'XTick',[],'YTick',[],'FontSize',8)

x_l = xlim;
y_l = ylim;
ys = get(gca,'YLim');
xs = get(gca,'XLim');

% left histogram: theta/delta
ax(5) = axes('Parent', parentFig, 'Position', local_pos_AG(region, 4, 1, 2, 1));
hold on

thetaSleep = log(Data(Restrict(SmoothTheta, Sleep)));
[~, rawN, ~] = nhist(thetaSleep, ...
    'maxx', max(thetaSleep), ...
    'noerror', ...
    'xlabel', 'Theta/Delta power', ...
    'ylabel', []);

axis xy
xlim(y_l)
view(90,-90)

if isfield(Info, 'theta_thresh') && ~isempty(Info.theta_thresh)
    line([log(Info.theta_thresh) log(Info.theta_thresh)], [0 max(rawN)], ...
        'LineWidth', 4, 'Color', 'r');
end

set(gca,'YTick',[],'XLim',ys,'FontSize',8)

% bottom histogram: delta
ax(6) = axes('Parent', parentFig, 'Position', local_pos_AG(region, 6, 2, 1, 3));
hold on

deltaVals = log(Data(Restrict(SmoothDeltaNew, SWSEpochWithIS)));
[~, rawN, ~] = nhist(deltaVals, ...
    'maxx', max(deltaVals), ...
    'noerror', ...
    'xlabel', 'Delta power', ...
    'ylabel', []);

xlim(x_l)

if isfield(Info, 'delta_thresh') && ~isempty(Info.delta_thresh)
    line([log(Info.delta_thresh) log(Info.delta_thresh)], [0 max(rawN)], ...
        'LineWidth', 4, 'Color', 'r');
end

set(gca,'YTick',[],'XLim',xs,'FontSize',8)

end


function [x, y] = get_phase_points_AG(sigX, sigY, epoch, dtPlot, transformX, transformY)

x = [];
y = [];

if isempty(sigX) || isempty(sigY) || epoch_isempty_AG(epoch)
    return
end

sx = Restrict(sigX, epoch);
sy = Restrict(sigY, ts(Range(sx)));

if isempty(Range(sx)) || isempty(Range(sy))
    return
end

R = Range(sx);
dx = Data(sx);
dy = Data(sy);

if numel(R) < 2
    return
end

step = max(1, round(dtPlot * 1e4 / median(diff(R))));
R = R(1:step:end);
dx = dx(1:step:end);
dy = dy(1:step:end);

dx = max(dx, eps);
dy = max(dy, eps);

switch lower(transformX)
    case 'log10'
        x = log10(dx);
    otherwise
        x = log(dx);
end

switch lower(transformY)
    case 'log10'
        y = log10(dy);
    otherwise
        y = log(dy);
end

end


function pos = local_pos_AG(region, row, col, rowSpan, colSpan)

nRows = 6;
nCols = 4;

x0 = region(1);
y0 = region(2);
w  = region(3);
h  = region(4);

gapX = 0.012;
gapY = 0.018;

cellW = (w - (nCols - 1) * gapX) / nCols;
cellH = (h - (nRows - 1) * gapY) / nRows;

x = x0 + (col - 1) * (cellW + gapX);
y = y0 + (nRows - row - rowSpan + 1) * (cellH + gapY);

ww = colSpan * cellW + (colSpan - 1) * gapX;
hh = rowSpan * cellH + (rowSpan - 1) * gapY;

pos = [x y ww hh];

end


function sig = get_signal_AG(sigStruct, varargin)

sig = [];
for i = 1:numel(varargin)
    if isfield(sigStruct, varargin{i})
        sig = sigStruct.(varargin{i});
        return
    end
end

end


function ep = get_epoch_AG(stateStruct, varargin)

ep = [];
for i = 1:numel(varargin)
    if isfield(stateStruct, varargin{i})
        ep = stateStruct.(varargin{i});
        return
    end
end

end


function out = epoch_or_AG(ep1, ep2)

if epoch_isempty_AG(ep1)
    out = ep2;
    return
end
if epoch_isempty_AG(ep2)
    out = ep1;
    return
end

out = or(ep1, ep2);

end


function tf = epoch_isempty_AG(ep)

tf = true;
if isempty(ep)
    return
end

try
    tf = isempty(Start(ep));
catch
    tf = isempty(ep);
end

end


function Info = get_info_AG(SD)

Info = struct();
if isfield(SD, 'Info')
    Info = SD.Info;
elseif isfield(SD, 'info')
    Info = SD.info;
end

end


function Colors = get_phase_colors_AG(colors)

Colors = struct();
Colors.Wake = pick_color_AG(colors, {'Wake'}, [0 0 1]);
Colors.REM  = pick_color_AG(colors, {'REM'},  [0 0.9 0.2]);
Colors.SWS  = pick_color_AG(colors, {'SWS','N2','NREM'}, [1 0.2 0.2]);
Colors.IS   = pick_color_AG(colors, {'IS','N1'}, [0.85 0.55 0.2]);

end


function c = pick_color_AG(colors, names, fallback)

c = fallback;

if isempty(colors)
    return
end

for i = 1:numel(names)
    if isstruct(colors) && isfield(colors, names{i})
        c = colors.(names{i});
        return
    end
end

if isstruct(colors) && isfield(colors, 'names') && isfield(colors, 'colors')
    for i = 1:numel(names)
        idx = find(strcmpi(colors.names, names{i}), 1);
        if ~isempty(idx)
            c = colors.colors{idx};
            return
        end
    end
end

end