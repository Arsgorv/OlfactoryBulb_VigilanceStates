function Sarr = append_stat_row_AG(Sarr, newRow)
%APPEND_STAT_ROW_AG  Append a scalar struct to a struct array, unifying fields.
% Robust to field-set differences between rows: missing fields are filled with
% NaN (numeric) or '' (char) so struct2table never fails on the result.

if isempty(fieldnames(newRow))
    return
end
if isempty(Sarr)
    Sarr = newRow;
    return
end

% union of field names
fa = fieldnames(Sarr);
fb = fieldnames(newRow);
allF = unique([fa; fb], 'stable');

% ensure existing array has all fields
for k = 1:numel(allF)
    f = allF{k};
    if ~isfield(Sarr, f)
        for i = 1:numel(Sarr)
            Sarr(i).(f) = NaN;
        end
    end
end
% ensure newRow has all fields
for k = 1:numel(allF)
    f = allF{k};
    if ~isfield(newRow, f)
        newRow.(f) = NaN;
    end
end
% reorder newRow fields to match Sarr, then append
newRow = orderfields(newRow, fieldnames(Sarr));
Sarr(end+1) = newRow;
end
