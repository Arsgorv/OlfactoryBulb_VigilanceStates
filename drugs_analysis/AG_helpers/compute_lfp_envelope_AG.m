function env_tsd = compute_lfp_envelope_AG(datapath, channel_id, band_hz, smooth_sec)
%COMPUTE_LFP_ENVELOPE_AG  Load LFP<ch>.mat, bandpass + Hilbert envelope, smooth.
% Returns a tsd. If LFP file or channel is missing, returns []. band_hz can be
% [] to use raw LFP envelope (full band).

env_tsd = [];
if ~isfinite(channel_id), return, end
lfpFile = fullfile(datapath, 'ephys', 'LFPData', ['LFP' num2str(channel_id) '.mat']);
if ~exist(lfpFile, 'file')
    lfpFile = fullfile(datapath, 'LFPData', ['LFP' num2str(channel_id) '.mat']);
end
if ~exist(lfpFile, 'file')
    warning('LFP%d.mat not found in %s', channel_id, datapath); return
end
S = load(lfpFile, 'LFP');
if ~isfield(S,'LFP'), return, end
LFP = S.LFP;
if ~isempty(band_hz) && exist('FilterLFP','file') == 2
    LFP = FilterLFP(LFP, band_hz);
end
t  = Range(LFP);     % 1e-4 s
d  = Data(LFP);
% envelope via Hilbert magnitude (pad NaNs as zeros for transform)
good = isfinite(d);
e = nan(size(d));
if sum(good) > 5
    e(good) = abs(hilbert(d(good)));
end
if smooth_sec > 0
    fs = 1/(median(diff(t))*1e-4);
    win = max(1, round(smooth_sec*fs));
    eg = e(good);
    eg = runmean(eg, win);
    e(good) = eg;
end
env_tsd = tsd(t, e);
end
