function save_figure_AG(fig, outDir, baseName, formats)
% save_figure_AG  Save a figure as both .fig and the requested raster/vector
% formats. Creates outDir if missing.
%
% INPUT
%   fig        figure handle
%   outDir     destination folder
%   baseName   file stem (no extension)
%   formats    cellstr of formats, default {'png','pdf'}

if nargin < 4 || isempty(formats), formats = {'png','pdf'}; end
if ~exist(outDir, 'dir'), mkdir(outDir); end
set(fig, 'PaperPositionMode','auto')

savefig(fig, fullfile(outDir, [baseName '.fig']))
for k = 1:numel(formats)
    fmt = formats{k};
    switch lower(fmt)
        case 'png'
            print(fig, fullfile(outDir, [baseName '.png']), '-dpng', '-r200')
        case 'pdf'
            print(fig, fullfile(outDir, [baseName '.pdf']), '-dpdf', '-bestfit')
        case 'svg'
            print(fig, fullfile(outDir, [baseName '.svg']), '-dsvg')
        case 'eps'
            print(fig, fullfile(outDir, [baseName '.eps']), '-depsc')
    end
end
fprintf('  saved: %s.{fig,%s}\n', baseName, strjoin(formats,','));
end
