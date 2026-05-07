function peak_freq = spectrum_peak_frequency(spec_row, f, search_band, use_f_weight)
% Peak frequency within search_band from one spectrum.

f = f(:)';
spec_row = spec_row(:)';
fidx = f >= search_band(1) & f <= search_band(2);
if sum(fidx) == 0
    peak_freq = NaN;
    return
end
sp = spec_row;
if use_f_weight
    sp = f .* sp;
end
[~, imax] = max(sp(fidx));
f_sub = f(fidx);
peak_freq = f_sub(imax);
end
