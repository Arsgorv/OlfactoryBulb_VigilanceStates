function D = remove_empty_rows(D)
% Remove rows that are all NaN or all zero-empty placeholders.

if isempty(D)
    return
end
bad = all(~isfinite(D),2) | all(D == 0 | ~isfinite(D),2);
D = D(~bad,:);
end
