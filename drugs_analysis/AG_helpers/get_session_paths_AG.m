function paths = get_session_paths_AG(animal, restraint, drugName)
%GET_SESSION_PATHS_AG Return paths from PathForExperimentsOB if available.
% This keeps session discovery outside the main script and lets manual Ficello
% fUS sessions stay hard-coded.

paths = {};
if exist('PathForExperimentsOB', 'file') ~= 2
    warning('PathForExperimentsOB not found. No auto sessions loaded for %s %s %s.', animal, restraint, drugName)
    return
end

try
    Dir = PathForExperimentsOB({animal}, restraint, drugName);
catch ME
    warning('PathForExperimentsOB failed for %s %s %s: %s', animal, restraint, drugName, ME.message)
    return
end

if isfield(Dir, 'path')
    paths = Dir.path;
    if ischar(paths)
        paths = {paths};
    end
    paths = paths(:);
end

% Some existing ferret datasets label saline/control freely-moving sessions as
% 'none' rather than 'saline'. Try that fallback only when saline returned no
% sessions.
if isempty(paths) && strcmp(drugName, 'saline')
    try
        Dir = PathForExperimentsOB({animal}, restraint, 'none');
        if isfield(Dir, 'path')
            paths = Dir.path;
            if ischar(paths)
                paths = {paths};
            end
            paths = paths(:);
        end
    catch
    end
end
