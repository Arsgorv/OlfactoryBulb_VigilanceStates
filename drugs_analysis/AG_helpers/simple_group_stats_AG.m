function Stats = simple_group_stats_AG(T, fieldName)
%SIMPLE_GROUP_STATS_AG Session-level two-drug comparison with robust summaries.
% Drug id: 1=saline, 2=atropine. Values are typically log(after/before).

Stats = struct();
Stats.metric = fieldName;
Stats.n_saline = NaN;
Stats.n_atropine = NaN;
Stats.median_saline = NaN;
Stats.median_atropine = NaN;
Stats.delta_median_atropine_minus_saline = NaN;
Stats.p_ranksum = NaN;
Stats.p_ttest2 = NaN;
Stats.p_saline_signrank_vs0 = NaN;
Stats.p_atropine_signrank_vs0 = NaN;

if isempty(T) || ~istable(T) || ~ismember(fieldName, T.Properties.VariableNames)
    return
end

y1 = T.(fieldName)(T.drug_id == 1);
y2 = T.(fieldName)(T.drug_id == 2);
y1 = y1(isfinite(y1));
y2 = y2(isfinite(y2));
Stats.n_saline = length(y1);
Stats.n_atropine = length(y2);
Stats.median_saline = nanmedian(y1);
Stats.median_atropine = nanmedian(y2);
Stats.delta_median_atropine_minus_saline = Stats.median_atropine - Stats.median_saline;

if length(y1) >= 2 && length(y2) >= 2
    if exist('ranksum', 'file') == 2
        try
            Stats.p_ranksum = ranksum(y1, y2);
        catch
            Stats.p_ranksum = NaN;
        end
    end
    if exist('ttest2', 'file') == 2
        try
            [~, Stats.p_ttest2] = ttest2(y1, y2);
        catch
            Stats.p_ttest2 = NaN;
        end
    end
end

if length(y1) >= 2 && exist('signrank', 'file') == 2
    try
        Stats.p_saline_signrank_vs0 = signrank(y1, 0);
    catch
        Stats.p_saline_signrank_vs0 = NaN;
    end
end
if length(y2) >= 2 && exist('signrank', 'file') == 2
    try
        Stats.p_atropine_signrank_vs0 = signrank(y2, 0);
    catch
        Stats.p_atropine_signrank_vs0 = NaN;
    end
end
