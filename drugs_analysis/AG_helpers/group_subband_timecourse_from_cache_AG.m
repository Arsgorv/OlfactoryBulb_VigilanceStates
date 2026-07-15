function [M_sal, M_atr] = group_subband_timecourse_from_cache_AG(SessionCacheDir, bandFieldName, PostTimeGridSec)
M_sal = nan(0, length(PostTimeGridSec));
M_atr = nan(0, length(PostTimeGridSec));
files = dir(fullfile(SessionCacheDir, '*_v7.mat'));
for f = 1:length(files)
    cf = fullfile(files(f).folder, files(f).name);
    try
        L = load(cf, 'Grow', 'drug_cached');
        if ~isfield(L, 'Grow') || ~isfield(L.Grow, bandFieldName), continue, end
        v = L.Grow.(bandFieldName);
        if isempty(v) || all(~isfinite(v)), continue, end   % skip empty / all-NaN
        if L.drug_cached == 1
            M_sal(end+1, 1:numel(v)) = v(:)';
        elseif L.drug_cached == 2
            M_atr(end+1, 1:numel(v)) = v(:)';
        end
    catch
    end
end
end
