%% Parameters
smooth_win_list = [0.5 2 5 10 20 50 100 150 200 500];   % seconds
fs_plot = 10;   % 0.1s bins
ref_name  = 'Mean FR';
maxLagSec = 6;

% Get duration automatically from Var
t1 = 0;
for i = 1:numel(Var)
    t1 = max(t1, max(Range(Var{i})));  % in 1e-4 s
end
t1 = t1 * 1e-4;  % convert to seconds
t0 = 0;
t = (t0 : 1/fs_plot : t1)';

nVar = numel(Params);
idx_ref = find(contains(lower(Params), lower(ref_name)),1);
if isempty(idx_ref), idx_ref = 1; end
maxLag = round(maxLagSec * fs_plot);

% Storage
AllCorr = nan(nVar, nVar, numel(smooth_win_list));
AllPeakLag = nan(nVar, numel(smooth_win_list));
AllPeakR   = nan(nVar, numel(smooth_win_list));

%% Loop over smoothing windows
for wIdx = 1:numel(smooth_win_list)
    sw = smooth_win_list(wIdx);
    fprintf('--- Smoothing window: %.1f s ---\n', sw);

    % Smooth each variable
    Var_smooth = cell(size(Var));
    for i = 1:nVar
        rawData = Data(Var{i});
        win_samples = ceil(sw / median(diff(Range(Var{i},'s'))));
        smoothData = movmean(rawData, win_samples, 'omitnan');

        if ismember(i, [1 2 4])  % motion, OB gamma, EMG
            smoothData = log10(smoothData);
        end

        % manual z-score ignoring NaNs
        mu = mean(smoothData, 'omitnan');
        sg = std(smoothData, 'omitnan');
        smoothData = (smoothData - mu) ./ sg;

        Var_smooth{i} = tsd(Range(Var{i}), smoothData);
    end

    % Interpolate to common grid
    X = nan(numel(t), nVar);
    for i = 1:nVar
        ti = Range(Var_smooth{i}) * 1e-4;
        xi = Data(Var_smooth{i});
        xi = xi(:);
        [ti, idx] = unique(ti, 'stable');
        xi = xi(idx);
        X(:,i) = interp1(ti, xi, t, 'linear', NaN);
    end

    % Remove edges
    X([1:20e3 end-5e3:end],:) = [];

    % Correlation matrix
    R = corr(X, 'Rows','pairwise');
    AllCorr(:,:,wIdx) = R;

    % Cross-correlation vs reference
    peakLagSec = zeros(1,nVar);
    peakR = zeros(1,nVar);
    for i = 1:nVar
        xi = X(:,i);
        xr = X(:,idx_ref);
        mask = isfinite(xi) & isfinite(xr);
        xi(~mask) = 0;
        xr(~mask) = 0;
        [xc,lags] = xcorr(xi, xr, maxLag, 'coeff');
        [~,ix] = max(abs(xc));
        peakLagSec(i) = lags(ix) / fs_plot;
        peakR(i) = xc(ix);
    end

    AllPeakLag(:,wIdx) = peakLagSec;
    AllPeakR(:,wIdx)   = peakR;
end

%% --- Summary plots ---

% 1. Correlation vs smoothing window
figure('Color','w','Name','Correlation vs smoothing window');
for i = 1:nVar
    subplot(ceil(nVar/2),2,i)
    plot(smooth_win_list, squeeze(AllCorr(i,idx_ref,:)), '-o', 'LineWidth',1.5)
    set(gca,'XScale','log')
    xticks(smooth_win_list)
    xlabel('Smoothing window (s)')
    ylabel(sprintf('Corr with %s',Params{idx_ref}))
    title(Params{i})
    grid on
end

% 2. Peak R vs smoothing window
figure('Color','w','Name','Peak |R| vs smoothing window');
for i = 1:nVar
    subplot(ceil(nVar/2),2,i)
    plot(smooth_win_list, abs(AllPeakR(i,:)), '-o', 'LineWidth',1.5)
    set(gca,'XScale','log')
    xticks(smooth_win_list)
    xlabel('Smoothing window (s)')
    ylabel('Peak |R|')
    title(Params{i})
    grid on
end

% 3. Peak lag vs smoothing window
figure('Color','w','Name','Peak lag vs smoothing window');
for i = 1:nVar
    subplot(ceil(nVar/2),2,i)
    plot(smooth_win_list, AllPeakLag(i,:), '-o', 'LineWidth',1.5)
    set(gca,'XScale','log')
    xticks(smooth_win_list)
    xlabel('Smoothing window (s)')
    ylabel('Lag (s)')
    title(Params{i})
    grid on
end
