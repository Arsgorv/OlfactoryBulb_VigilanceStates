function Group = append_group_row_AG(Group, Grow, drug)
%APPEND_GROUP_ROW_AG  Append a cached session's Group row back into Group.
% Mirrors the inline "Group.<f>{drug}(row,:) = ..." accumulation used during
% fresh computation, so cached and freshly-computed sessions interleave
% correctly in SessionDefs order.

fn = fieldnames(Grow);
for k = 1:numel(fn)
    name = fn{k};
    v = Grow.(name);
    if ~isfield(Group, name)
        Group.(name) = {[],[]};
    end
    r = size(Group.(name){drug},1) + 1;
    if isempty(v)
        w = size(Group.(name){drug},2);
        if w < 1, w = 1; end
        Group.(name){drug}(r,1:w) = NaN;
    else
        Group.(name){drug}(r,1:numel(v)) = v;
    end
end
end
