function bp = spectrum_band_timeseries(spec, f, band, use_f_weight)
% Band-power time series from spectrogram.
% If use_f_weight=1, the displayed f*power convention is also used for the band.

f = f(:)';
fidx = f >= band(1) & f <= band(2);
if sum(fidx) == 0
    bp = nan(size(spec,1),1);
    return
end
if use_f_weight
    weighted = bsxfun(@times, spec(:,fidx), f(fidx));
else
    weighted = spec(:,fidx);
end
bp = nanmean(weighted, 2);
end
