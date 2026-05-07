function occ = state_occupancy(state, idx, n_states)
% Fraction of time spent in each state inside idx.

occ = nan(1,n_states);
state_epoch = state(idx);
good = isfinite(state_epoch);
if sum(good) == 0
    return
end
for st = 1:n_states
    occ(st) = sum(state_epoch(good) == st) / sum(good);
end
end
