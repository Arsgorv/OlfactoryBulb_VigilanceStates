function plot_metric_by_drug(T, fieldName, Cols, X, Legends)
% Session-level box/spread plot by drug.

data1 = T.(fieldName)(T.drug_id == 1);
data2 = T.(fieldName)(T.drug_id == 2);
data1 = data1(isfinite(data1));
data2 = data2(isfinite(data2));
plot_box_or_spread({data1 data2}, Cols, X, Legends)
yline_compat(0,'--r')
makepretty_BM2
end
