function SS = compute_substate_spectra_AG(SD, BF)
% compute_substate_spectra_AG  Mean spectrum per substate, for every region
% whose spectrogram is available on disk for this session.
%
% Built to test, e.g., whether short-N1 bouts are physiologically N2-like
% (mis-classification) or whether long-N1 bouts dissociate across regions
% (HPC theta but PFC NREM-like, the classical IS signature).
%
% INPUT
%   SD    output of load_session_AG (uses SD.spec.*)
%   BF    output of compute_bout_features_AG (groupNames/Epochs/Colors)
%
% OUTPUT struct SS:
%   groupNames, groupColors
%   regions          1xR cellstr: which regions were present in SD.spec
%   spec.<region>.f                freq vector
%   spec.<region>.M    [nGroups x nF]  mean log10 power
%   spec.<region>.SEM  [nGroups x nF]
%   spec.<region>.N    [nGroups x 1]   # time bins
%
% Regions: any field of SD.spec that is non-empty. Typical: OBlow, OBgamma,
% HPClow, HPCmid, PFClow, PFCmid, AuCxlow, AuCxmid.

SS.groupNames  = BF.groupNames;
SS.groupColors = BF.groupColors;

% Discover regions present in SD.spec
specFields = fieldnames(SD.spec);
SS.regions = {};
SS.spec    = struct();
for r = 1:numel(specFields)
    rn = specFields{r};
    SP = SD.spec.(rn);
    if isempty(SP) || ~isstruct(SP) || isempty(SP.tsd), continue, end
    SS.regions{end+1} = rn; %#ok<AGROW>
    SS.spec.(rn) = mean_spec_per_group(SP, BF.groupEpochs);
end
end


function out = mean_spec_per_group(SP, groupEpochs)
out = struct('f',[],'M',[],'SEM',[],'N',[]);
if isempty(SP) || isempty(SP.tsd), return, end
nG = numel(groupEpochs);
nF = numel(SP.f);
out.f   = SP.f;
out.M   = nan(nG, nF);
out.SEM = nan(nG, nF);
out.N   = zeros(nG, 1);
for g = 1:nG
    if isempty(groupEpochs{g}) || isempty(Start(groupEpochs{g})), continue, end
    D = Data(Restrict(SP.tsd, groupEpochs{g}));
    if size(D,1) < 2, continue, end
    L = log10(D + eps);
    out.M(g,:)   = nanmean(L, 1);
    out.SEM(g,:) = nanstd(L, 0, 1) ./ sqrt(sum(~isnan(L), 1));
    out.N(g)     = size(L, 1);
end
end
