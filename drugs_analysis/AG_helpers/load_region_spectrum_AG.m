function out = load_region_spectrum_AG(datapath, region_prefix, range_tag)
%LOAD_REGION_SPECTRUM_AG  Load <prefix>_<range>_Spectrum[.mat or _HighPass.mat].
% prefix examples: 'B' (OB), 'AuCx', 'H', 'PFCx'.
% range_tag: 'Low' or 'Middle'.
% Returns struct with .sptsd (tsd), .f (freq vector); empty if missing.

out = [];
candidates = { ...
    fullfile(datapath, 'ephys', [region_prefix '_' range_tag '_Spectrum_HighPass.mat']), ...
    fullfile(datapath, 'ephys', [region_prefix '_' range_tag '_Spectrum.mat']), ...
    fullfile(datapath, [region_prefix '_' range_tag '_Spectrum.mat']) };
specFile = '';
for k = 1:length(candidates)
    if exist(candidates{k}, 'file')
        specFile = candidates{k}; break
    end
end
if isempty(specFile), return, end
S = load(specFile, 'Spectro');
if ~isfield(S,'Spectro'), return, end
out = struct();
out.sptsd = tsd(S.Spectro{2}*1e4, S.Spectro{1});
out.f = S.Spectro{3};
end
