function sp = epoch_spectrum(spec, idx, mode_name)
% Mean or median spectrum over time for one epoch.
% No temporal smoothing is applied here.

if strcmp(mode_name, 'median')
    sp = nanmedian(spec(idx,:), 1);
else
    sp = nanmean(spec(idx,:), 1);
end
end
