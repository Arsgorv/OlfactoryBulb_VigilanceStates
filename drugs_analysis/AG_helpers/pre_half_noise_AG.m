function lr = pre_half_noise_AG(x, idx_before)
%PRE_HALF_NOISE_AG  Internal noise control: log(median(pre2)/median(pre1)).
% Splits the pre period in temporal halves and returns the same kind of
% scalar as log_ratio_median, but within the pre period only. This gives
% a session-internal null estimate for "after vs before" effects.

x = x(:);
idx_before = idx_before(:);
idx_pos = find(idx_before);
if length(idx_pos) < 10
    lr = NaN; return
end
mid = idx_pos(round(end/2));
idx1 = false(size(x)); idx1(idx_pos(idx_pos <= mid)) = true;
idx2 = false(size(x)); idx2(idx_pos(idx_pos >  mid)) = true;
lr = log_ratio_median(x, idx1, idx2);
end
