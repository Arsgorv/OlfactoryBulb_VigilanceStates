function [idx_before, idx_after] = injection_epoch_indices(t, t_mid, exclusion_sec)
% Returns pre/post indices around an assumed injection time.
% The immediate peri-injection window is excluded.

t = t(:);
idx_before = t < (t_mid - exclusion_sec);
idx_after  = t > (t_mid + exclusion_sec);
end
