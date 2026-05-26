function bp = spectrum_band_outside_breath_AG(spec, f, band, breath_hz, harmonic_half_width)
%SPECTRUM_BAND_OUTSIDE_BREATH_AG  Mean band power excluding breath fundamental and harmonic.
% breath_hz: scalar dominant breath rate to exclude (Hz). Pass NaN to skip exclusion.
% harmonic_half_width: half-width of exclusion notch in Hz (e.g., 0.4)

f = f(:)';
fidx = f >= band(1) & f <= band(2);

if isfinite(breath_hz) && breath_hz > 0
    notch1 = abs(f - breath_hz) <= harmonic_half_width;
    notch2 = abs(f - 2*breath_hz) <= harmonic_half_width;
    fidx = fidx & ~notch1 & ~notch2;
end
if sum(fidx) == 0
    bp = nan(size(spec,1),1);
    return
end
bp = nanmean(spec(:,fidx), 2);
end
