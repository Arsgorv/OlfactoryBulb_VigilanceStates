function Grow = extract_group_row_AG(Group, drug, row)
%EXTRACT_GROUP_ROW_AG  Pull one session's row out of every Group.<f>{drug} matrix.
% Used to capture a session's Group contributions for caching, so a future run
% can replay them without recomputing. row is the row index written for this
% session within its drug group.

Grow = struct();
fn = fieldnames(Group);
for k = 1:numel(fn)
    Mk = Group.(fn{k}){drug};
    if size(Mk,1) >= row
        Grow.(fn{k}) = Mk(row,:);
    else
        Grow.(fn{k}) = [];
    end
end
end
