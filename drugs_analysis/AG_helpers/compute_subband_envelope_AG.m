function env_tsd = compute_subband_envelope_AG(datapath, channel_id, band_hz, smooth_sec, fs)
%COMPUTE_SUBBAND_ENVELOPE_AG  Hilbert envelope of bandpassed LFP at a given band.
% Mirrors the algorithm of calculate_brain_power.m (FilterLFP + |hilbert| +
% runmean) so the resulting tsd is directly comparable to BrainPower.Power{i}.
%
% Inputs:
%   datapath   : session folder (with LFPData/LFP<ch>.mat)
%   channel_id : integer LFP channel
%   band_hz    : 2-element [low high] in Hz
%   smooth_sec : smoothing window (seconds)
%   fs         : sampling rate (default 1024, matching calculate_brain_power)
%
% Output:
%   env_tsd : tsd of envelope power; [] if channel/file missing.

if nargin < 5 || isempty(fs), fs = 1024; end
env_tsd = [];
if ~isfinite(channel_id), return, end

lfpFile = fullfile(datapath, 'ephys', 'LFPData', ['LFP' num2str(channel_id) '.mat']);
if ~exist(lfpFile, 'file')
    lfpFile = fullfile(datapath, 'LFPData', ['LFP' num2str(channel_id) '.mat']);
end
if ~exist(lfpFile, 'file')
    warning('compute_subband_envelope_AG: LFP%d.mat not found in %s', channel_id, datapath);
    return
end
L = load(lfpFile, 'LFP');
if ~isfield(L,'LFP'), return, end
LFP = L.LFP;

Fil = FilterLFP(LFP, band_hz, fs);
env = abs(hilbert(Data(Fil)));

dt = median(diff(Range(Fil,'s')));
win = max(1, ceil(smooth_sec/dt));
sm = runmean(env, win);

env_tsd = tsd(Range(Fil), sm);
end
