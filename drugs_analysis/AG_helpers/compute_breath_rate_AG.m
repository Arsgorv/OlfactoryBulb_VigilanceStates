function brate = compute_breath_rate_AG(LFP_or_tsd, Tref, smooth_sec)
%COMPUTE_BREATH_RATE_AG  Breath rate (Hz) on Tref via Hilbert IF on bandpassed respi LFP.
%
% LFP_or_tsd : tsd of the raw respiration channel (loaded from
%              LFPData/LFP<respi_ch>.mat), OR a tsd that already contains
%              instantaneous breath rate in Hz (auto-detected by value range).
% Tref       : reference time vector (seconds) to which the breath rate is
%              interpolated.
% smooth_sec : smoothing window (seconds) applied with movmedian then movmean.
%
% Pipeline (matches MakeRespi_ForSession_Ferret.m):
%   1) FilterLFP at [0.3 2.5] Hz
%   2) Hilbert -> instantaneous phase, unwrap
%   3) Instantaneous frequency = (fs / 2pi) * gradient(phase)
%   4) Clamp to physiological range [0.3 2.0] Hz; out-of-range -> NaN
%   5) Smoothing: movmedian(2s) -> movmean(2s)
%   6) Interpolate onto Tref

brate = nan(size(Tref));
if isempty(LFP_or_tsd)
    return
end

t_raw = Range(LFP_or_tsd, 's'); t_raw = t_raw(:);
d_raw = Data(LFP_or_tsd);       d_raw = d_raw(:);
if length(d_raw) < 50
    return
end

% Auto-detect: if the median absolute value is in a physiological Hz range,
% assume it's already a breath-rate tsd (e.g., precomputed RespRate_tsd)
% and just resample.
med_abs = nanmedian(abs(d_raw));
if med_abs > 0.05 && med_abs < 10
    % already in Hz
    if smooth_sec > 0
        dt_in = nanmedian(diff(t_raw));
        win = max(1, round(smooth_sec/max(dt_in,1e-6)));
        d_sm = nan(size(d_raw));
        good = isfinite(d_raw);
        d_sm(good) = runmean(d_raw(good), win);
    else
        d_sm = d_raw;
    end
    brate = interp1(t_raw, d_sm, Tref(:), 'linear', NaN);
    return
end

% Otherwise treat as raw LFP -> compute IF.
dt_raw = nanmedian(diff(t_raw));
if ~isfinite(dt_raw) || dt_raw <= 0
    return
end
fs = round(1/dt_raw);

% Bandpass 0.3 - 2.5 Hz to isolate respiration (FilterLFP convention).
if exist('FilterLFP','file') == 2
    LFP_breath = FilterLFP(LFP_or_tsd, [0.3 2.5], fs);
    x_f = Data(LFP_breath);
else
    % Fallback: simple FIR via fir1 if FilterLFP missing.
    nyq = fs/2;
    b = fir1(round(fs*4), [0.3 2.5]/nyq);
    x_f = filtfilt(b, 1, d_raw);
end

% Hilbert instantaneous frequency.
good = isfinite(x_f);
hx = hilbert(double(x_f(good)));
phi = unwrap(angle(hx));
dphi = gradient(phi);
f_inst_g = (fs/(2*pi)) * dphi;

f_inst = nan(size(x_f));
f_inst(good) = f_inst_g;

% Physiological range (ferret/rat: ~0.3-2 Hz at rest; tighten to 2 Hz to
% drop spurious harmonics).
f_inst(f_inst < 0.3 | f_inst > 2) = NaN;

% Smoothing: 2 s median + 2 s mean (paramless, matches MakeRespi).
win = max(1, round(2*fs));
f_med = movmedian(f_inst, win, 'omitnan');
f_smooth = movmean(f_med, win, 'omitnan');

% Optional extra smoothing.
if smooth_sec > 0
    win2 = max(1, round(smooth_sec*fs));
    g2 = isfinite(f_smooth);
    if sum(g2) > 5
        tmp = nan(size(f_smooth));
        tmp(g2) = runmean(f_smooth(g2), win2);
        f_smooth = tmp;
    end
end

brate = interp1(t_raw, f_smooth, Tref(:), 'linear', NaN);
end
