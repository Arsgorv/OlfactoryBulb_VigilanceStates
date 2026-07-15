function save_current_figure(SaveFigures, SaveFolder, filename)
%SAVE_CURRENT_FIGURE  Save the current figure as PNG and SVG.
if ~SaveFigures, return, end
[~, base, ext] = fileparts(filename);
if isempty(ext), ext = '.png'; end
pngPath = fullfile(SaveFolder, [base ext]);
svgPath = fullfile(SaveFolder, [base '.svg']);
try, saveas(gcf, pngPath); catch ME, warning('PNG save failed: %s', ME.message); end
try, saveas(gcf, svgPath); catch ME, warning('SVG save failed: %s', ME.message); end
end
