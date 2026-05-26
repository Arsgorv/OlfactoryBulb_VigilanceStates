function out = try_load_optional_AG(matfile, varNames)
%TRY_LOAD_OPTIONAL_AG Load a list of variables from a .mat file if present.
% Returns a struct with one field per variable that was found. Missing
% variables and missing files do not throw.

out = struct();
if ~exist(matfile, 'file')
    return
end
info = whos('-file', matfile);
have = {info.name};
toLoad = intersect(varNames, have);
if isempty(toLoad)
    return
end
tmp = load(matfile, toLoad{:});
fns = fieldnames(tmp);
for k = 1:length(fns)
    out.(fns{k}) = tmp.(fns{k});
end
end
