function durs = split_pre_post_durations_AG(Tref, idx_before, idx_after)
%SPLIT_PRE_POST_DURATIONS_AG Pre/post epoch durations in minutes.
durs = struct();
durs.pre_min  = (sum(idx_before) * nanmedian(diff(Tref))) / 60;
durs.post_min = (sum(idx_after)  * nanmedian(diff(Tref))) / 60;
end
