function [peak_raw, peak_fweighted] = subband_peak_AG(spec_row, f, sub_band)
%SUBBAND_PEAK_AG  Peak in a sub-band, returning both raw and f-weighted variants.

f = f(:)';
spec_row = spec_row(:)';
fidx = f >= sub_band(1) & f <= sub_band(2);
if sum(fidx) == 0
    peak_raw = NaN; peak_fweighted = NaN; return
end
fs = f(fidx);
[~, ix] = max(spec_row(fidx));
peak_raw = fs(ix);
[~, ix] = max(fs .* spec_row(fidx));
peak_fweighted = fs(ix);
end
