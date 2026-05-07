function f = get_frequency_vector(AllSessions, specType)
% Gets first available frequency vector of requested type.

f = [];
if strcmp(specType, 'middle')
    try
        f = evalin('base', 'MiddleFreqGrid');
        if ~isempty(f)
            return
        end
    catch
    end
elseif strcmp(specType, 'low')
    try
        f = evalin('base', 'LowFreqGrid');
        if ~isempty(f)
            return
        end
    catch
    end
end
for i = 1:length(AllSessions)
    if strcmp(specType, 'middle') && isfield(AllSessions(i), 'SpectroMiddle')
        f = AllSessions(i).SpectroMiddle.fB;
        return
    elseif strcmp(specType, 'low') && isfield(AllSessions(i), 'SpectroLow')
        f = AllSessions(i).SpectroLow.fB;
        return
    end
end
end
