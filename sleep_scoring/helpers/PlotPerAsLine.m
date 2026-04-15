%PlotPerAsLine
% 29.11.2017 SB
%
% PlotPerAsLine(SWSEpcoh, 20, 'b', 'linewidth',10)
%
% Plot function to plot horizontal bars corresponding to epochs 
%
%
%INPUTS
% EpochToPlot               intervalSet - corresponding to an Epoch
% LineHeight                position of the bar
% Colors:                   color of the bar 
%
% linewidth (optional):     width of the bars; default is 5
% timescaling (optional):   factor to scale the timestamps to the graph; default is 1e4
%
%

function PlotPerAsLine(EpochToPlot, LineHeight, Colors, varargin)

%% Initiation
% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'linewidth'
            linewidth = varargin{i+1};
            if linewidth<=0
                error('Incorrect value for property ''linewidth''.');
            end
        case 'timescaling'
            timescaling = varargin{i+1};
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
if ~exist('linewidth','var')
    linewidth=5;
end
if ~exist('timescaling','var')
    timescaling=1e4;
end

%% plot
per_start = Start(EpochToPlot);
per_stop = Stop(EpochToPlot);
for k = 1:length(per_start)
    line([per_start(k) per_stop(k)]/timescaling, [LineHeight LineHeight], 'color',Colors, 'linewidth',linewidth);
end


end


