function Ana = load_per_session_envelopes_AG(SessionCacheDir)
%LOAD_PER_SESSION_ENVELOPES_AG  Build an Ana-like struct array from cache files.
% Reads Arow from each session_cache_v7/*.mat. Returns a struct array with
% the fields needed for plot_distribution_group: drug_id, idx_before,
% idx_after, gamma, delta (+ any other BP envelopes the cache holds).

files = dir(fullfile(SessionCacheDir, '*_v7.mat'));
Ana = struct([]);
for f = 1:length(files)
    cf = fullfile(files(f).folder, files(f).name);
    try
        L = load(cf, 'Arow');
        if ~isfield(L,'Arow') || isempty(L.Arow), continue, end
        if isempty(Ana)
            Ana = L.Arow;
        else
            % Field-by-field merge so heterogeneous fields are tolerated
            allFlds = union(fieldnames(Ana), fieldnames(L.Arow));
            idx = numel(Ana) + 1;
            for k = 1:numel(allFlds)
                fn = allFlds{k};
                if isfield(L.Arow, fn)
                    Ana(idx).(fn) = L.Arow.(fn);
                else
                    Ana(idx).(fn) = [];
                end
            end
        end
    catch
    end
end
end
