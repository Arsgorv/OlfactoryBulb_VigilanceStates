function out = simple_mixed_rank_AG(T, fieldName)
%SIMPLE_MIXED_RANK_AG  One-value-per-animal sensitivity test for two drugs.
% Aggregates by animal x drug (median per cell), then runs a Wilcoxon rank-sum
% across animals between the two drug groups. Useful as a cheap mixed-model check.

out = struct();
out.metric = fieldName;
out.n_animals_saline = NaN; out.n_animals_atropine = NaN;
out.median_saline_animals = NaN; out.median_atropine_animals = NaN;
out.p_ranksum_animals = NaN;
if ~istable(T) || ~ismember(fieldName, T.Properties.VariableNames)
    return
end
animals = unique(T.animal);
sal_vals = []; atr_vals = [];
for a = 1:length(animals)
    is_a = strcmp(T.animal, animals{a});
    s = T.(fieldName)(is_a & T.drug_id == 1);
    s = s(isfinite(s));
    if ~isempty(s), sal_vals(end+1,1) = nanmedian(s); end
    a_ = T.(fieldName)(is_a & T.drug_id == 2);
    a_ = a_(isfinite(a_));
    if ~isempty(a_), atr_vals(end+1,1) = nanmedian(a_); end
end
out.n_animals_saline = length(sal_vals);
out.n_animals_atropine = length(atr_vals);
out.median_saline_animals = nanmedian(sal_vals);
out.median_atropine_animals = nanmedian(atr_vals);
if length(sal_vals) >= 2 && length(atr_vals) >= 2 && exist('ranksum','file') == 2
    try
        out.p_ranksum_animals = ranksum(sal_vals, atr_vals);
    catch
        out.p_ranksum_animals = NaN;
    end
end
end
