
load('DLC/DLC_data.mat', 'areas_pupil')

% Settings
zThresh     = 3;        % robust z threshold for outlier removal (increase to be less aggressive)
smooth_sec  = 1.0;      % smoothing window (seconds)
useMedianSm = false;    % true = movmedian, false = movmean

i = 4;
tU = Range(areas_pupil);         % time in 1e-4 s units
x  = Data(areas_pupil); x = x(:);% column

% remove non-finite and duplicate timestamps (keep first occurrence)
ok = isfinite(tU) & isfinite(x);
tU = tU(ok);  x = x(ok);
[tU, idx] = unique(tU, 'stable');
x = x(idx);

% robust global outlier detection (MAD-based)
medx = median(x,'omitnan');
madx = median(abs(x - medx),'omitnan');   % median absolute deviation
if madx == 0
    q = prctile(x,[25 75]);
    scale = (q(2)-q(1))/1.349;            % ~std from IQR
    if scale == 0
        out = false(size(x));
    else
        z = (x - medx) / scale;
        out = abs(z) > zThresh;
    end
else
    z = 0.6745*(x - medx)/madx;           % robust z-score
    out = abs(z) > zThresh;
end

x_clean = x;
x_clean(out) = NaN;                       % remove outliers (mark as NaN)

% back to tsd (column vectors, same time units)
Clean_pupil_size  = tsd(tU, x_clean);

save('SleepScoring_OBGamma.mat','Clean_pupil_size','-append')




