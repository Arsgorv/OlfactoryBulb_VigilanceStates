function SM = try_load_cache_AG(cachePath, requiredVersion)
% try_load_cache_AG  Return the cached SM struct if it exists and matches
% requiredVersion; otherwise return []. Never throws on bad files.
%
% Used by the main script to decide whether to load_session_AG (slow) or
% skip straight to using cached metrics.

SM = [];
if exist(cachePath, 'file') ~= 2, return, end
try
    L = load(cachePath, 'SM');
    if ~isfield(L,'SM'), return, end
    SMcand = L.SM;
    if isfield(SMcand,'cacheVersion') && SMcand.cacheVersion == requiredVersion
        SM = SMcand;
    end
catch
    SM = [];
end
end
