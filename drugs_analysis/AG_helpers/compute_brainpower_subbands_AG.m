function BP = compute_brainpower_subbands_AG(datapath, ob_ch, smooth_sec, bands)
%COMPUTE_BRAINPOWER_SUBBANDS_AG  Per-session OB sub-band envelope tsds.
% Returns a struct with one tsd per sub-band, using the same Hilbert-envelope
% + runmean pipeline as calculate_brain_power.m (band -> 'envelope power').
%
% Inputs:
%   datapath   : session folder
%   ob_ch      : OB LFP channel id (from get_lfp_channels_AG or
%                ChannelsToAnalyse/Bulb_deep.mat)
%   smooth_sec : smoothing window (seconds)
%   bands      : struct with .delta .theta .beta .lowGamma .gamma .highGamma
%                Each a [low high] in Hz.

BP = struct();
if ~isfinite(ob_ch), return, end

fn = fieldnames(bands);
for k = 1:numel(fn)
    nm = fn{k};
    bnd = bands.(nm);
    if numel(bnd) ~= 2, continue, end
    try
        BP.(nm) = compute_subband_envelope_AG(datapath, ob_ch, bnd, smooth_sec);
    catch ME
        warning('compute_brainpower_subbands_AG: band %s failed: %s', nm, ME.message);
        BP.(nm) = [];
    end
end
end
