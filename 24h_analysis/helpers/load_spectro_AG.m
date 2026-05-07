function out = load_spectro_AG(sessionPath, fname)
% load_spectro_AG  Load a *_Spectrum.mat file produced by the OB pipeline.
%
% INPUT
%   sessionPath  session folder
%   fname        spectrum file name, e.g. 'B_Low_Spectrum.mat'
%
% OUTPUT
%   out.tsd      tsd of spectrogram (rows = time, cols = freq)
%   out.f        frequency vector
% Returns [] if the file does not exist.

out = [];
fpath = fullfile(sessionPath, fname);
if ~exist(fpath, 'file')
    warning('load_spectro_AG: %s not found in %s', fname, sessionPath);
    return
end
S = load(fpath, 'Spectro');
if ~isfield(S, 'Spectro')
    warning('load_spectro_AG: %s does not contain a Spectro variable', fname);
    return
end
% Spectro = {power_matrix, time_in_seconds, freqs}
out.tsd = tsd(S.Spectro{2}*1e4, S.Spectro{1});
out.f   = S.Spectro{3};
end
