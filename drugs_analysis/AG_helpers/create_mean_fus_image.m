function meanImg = create_mean_fus_image(cat_tsd, masks)
% Only for display/QC. Recomputes mean image without storing the full movie.

fUSData = Data(cat_tsd.data);
fUSDataReshaped = reshape(fUSData', cat_tsd.Nx, cat_tsd.Ny, size(fUSData,1));
meanFrame = mean(fUSDataReshaped, 3);
frame_double = double(meanFrame);
frame_log = log(frame_double + 1);
frame_log = frame_log - min(frame_log(:));
if max(frame_log(:)) > 0
    frame_log = frame_log / max(frame_log(:));
end
meanImg = uint8(frame_log * 255);
end
