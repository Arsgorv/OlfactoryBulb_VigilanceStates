function plot_metric_by_drug(T, fieldName, Cols, X, Legends)
% Session-level box/spread plot by drug. Robust to empty fields.

if ~ismember(fieldName, T.Properties.VariableNames)
    axis off, text(0.5,0.5,sprintf('field "%s" missing',fieldName), ...
        'HorizontalAlignment','center','Interpreter','none'); return
end
data1 = T.(fieldName)(T.drug_id == 1);
data2 = T.(fieldName)(T.drug_id == 2);
data1 = data1(isfinite(data1));
data2 = data2(isfinite(data2));
% MakeSpreadAndBoxPlot3_SB errors on empty cells (calls min([])). Replace
% empties with NaN so the function can at least draw axis placeholders.
if isempty(data1), data1 = NaN; end
if isempty(data2), data2 = NaN; end
if exist('MakeSpreadAndBoxPlot3_SB','file') == 2
    try
        MakeSpreadAndBoxPlot3_SB({data1 data2}, Cols, X, Legends, 'showpoints', 1, 'paired', 0);
    catch ME
        warning('MakeSpreadAndBoxPlot3_SB failed for %s: %s -- using fallback', fieldName, ME.message)
        plot_box_or_spread({data1 data2}, Cols, X, Legends)
    end
else
    plot_box_or_spread({data1 data2}, Cols, X, Legends)
end
yline_compat(0,'--r')
end
