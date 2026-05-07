function inj_sec = convert_inj_time_to_sec_AG(inj_time)
%CONVERT_INJ_TIME_TO_SEC_AG Convert common Buzcode/tsd time units to seconds.
% inj_time in many BM scripts is in 1e-4 s ticks; smaller values may already
% be seconds. This function only converts scalar values.

inj_sec = NaN;
if isempty(inj_time) || ~isnumeric(inj_time)
    return
end
inj_time = inj_time(1);
if ~isfinite(inj_time)
    return
end
if inj_time > 1e5
    inj_sec = inj_time/1e4;
else
    inj_sec = inj_time;
end
