function S = make_session_entry_AG(path, animal, restraint, drugName, drugId, sourceName, doseTag, includeSession)
%MAKE_SESSION_ENTRY_AG Small constructor for one analysis session.

if nargin < 6 || isempty(sourceName)
    sourceName = 'manual';
end
if nargin < 7 || isempty(doseTag)
    doseTag = 'standard_or_unknown';
end
if nargin < 8 || isempty(includeSession)
    includeSession = 1;
end

S = struct();
S.path = path;
S.animal = animal;
S.restraint = restraint;
S.drug_name = drugName;
S.drug_id = drugId;
S.source = sourceName;
S.dose_tag = doseTag;
S.include = includeSession;
