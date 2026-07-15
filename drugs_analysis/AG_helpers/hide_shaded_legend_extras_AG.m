function hide_shaded_legend_extras_AG(h)
%HIDE_SHADED_LEGEND_EXTRAS_AG  Suppress legend entries for patch + edge handles
% created by shadedErrorBar_BM. mainLine is kept (with its DisplayName).

if isempty(h) || ~isstruct(h), return, end
flds = {'patch','edge'};
for kk = 1:length(flds)
    if isfield(h, flds{kk})
        v = h.(flds{kk});
        for ii = 1:numel(v)
            try
                set(v(ii), 'HandleVisibility', 'off');
                v(ii).Annotation.LegendInformation.IconDisplayStyle = 'off';
            catch
            end
        end
    end
end
end
