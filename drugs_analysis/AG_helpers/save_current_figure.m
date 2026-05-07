function save_current_figure(SaveFigures, SaveFolder, filename)
if SaveFigures
    saveas(gcf, fullfile(SaveFolder, filename));
end
end
