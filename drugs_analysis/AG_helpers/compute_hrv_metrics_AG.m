function out = compute_hrv_metrics_AG(EKG, idx_period_t_ts, smooth_sec)
%COMPUTE_HRV_METRICS_AG  Heart-rate variability metrics from EKG struct.
% EKG must have HBTimes (ts in 1e-4 s) and HBRate (tsd, Hz).
% idx_period_t_ts: [t_start_s t_end_s] period in seconds within which to compute.
% Returns: mean_RR_ms, RMSSD_ms, SDNN_ms, breath_HRV_proxy (high-frequency component
% as std of HR change between consecutive beats, normalized).

out = struct('mean_HR_hz',NaN,'mean_RR_ms',NaN,'RMSSD_ms',NaN,'SDNN_ms',NaN,'pNN50_pct',NaN);
if isempty(EKG) || ~isstruct(EKG)
    return
end
if nargin < 3 || isempty(smooth_sec), smooth_sec = 0; end

if isfield(EKG, 'HBTimes')
    if isa(EKG.HBTimes, 'double')
        t_beats = EKG.HBTimes(:);
    else
        t_beats = Range(EKG.HBTimes, 's');
    end
    t_beats = t_beats(:);
    if max(t_beats) > 1e5
        t_beats = t_beats / 1e4; % heuristic: convert 1e-4 s ticks to seconds
    end
else
    return
end
if length(idx_period_t_ts) >= 2
    keep = t_beats >= idx_period_t_ts(1) & t_beats <= idx_period_t_ts(2);
    t_beats = t_beats(keep);
end
if length(t_beats) < 5
    return
end
RR = diff(t_beats) * 1000; % ms
RR = RR(isfinite(RR) & RR > 200 & RR < 2500); % physiological range, generous
if length(RR) < 3
    return
end

out.mean_RR_ms = nanmean(RR);
out.mean_HR_hz = 1000/out.mean_RR_ms;
out.SDNN_ms   = nanstd(RR);
out.RMSSD_ms  = sqrt(nanmean(diff(RR).^2));
out.pNN50_pct = 100 * sum(abs(diff(RR)) > 50) / max(1, length(RR)-1);
end
