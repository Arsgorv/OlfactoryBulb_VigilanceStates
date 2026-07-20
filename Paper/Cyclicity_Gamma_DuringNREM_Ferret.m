
% BM
clear all
close all

Dir1 = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);

%%
set(0,'DefaultFigureWindowStyle','docked')

% Study SmoothGamma cyclicity (~70 s) during long SWS (>=15 min)
wantFerrets = 1:3;              % adjust as needed
minSWS_sec  = 10*60;            % 10 minutes
targetT_sec = 100;               % target period ~70 s
zwin_sec    = 150;              % sliding z-score window (keep > targetT)
acfLag_sec  = 300;              % show +/-100 s in ACF
use_decimate = true;            % set false to just pick every Nth sample

% Welch period band of interest (shown in period, seconds)
perBands = [20 200];            % cover 20..200 s generously around 70 s
nFreqDense = 3000;              % dense sampling within band for display

% plotting helper (requires shadedErrorBar on path)
doShaded = true;

for ferret = wantFerrets
    r_all{ferret}   = [];  % store ACF rows for this ferret (episodes stacked)
    pxx_all{ferret} = [];  % store PSD rows for this ferret (episodes stacked)
    perGrid = [];  % will set once per ferret (common period axis)
    
    for sess = 1:length(Dir{ferret}.path)
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], ...
            'SmoothGamma','SWSEpoch');
        SWSEpoch = mergeCloseIntervals(SWSEpoch , 3e4);
        
        % --- derive raw sampling rate from tsd timestamps ---
        ti = Range(SmoothGamma,'s');
        fs_raw = 1 / median(diff(ti),'omitnan');
        if ~isfinite(fs_raw) || fs_raw<=0
            warning('Bad fs_raw in %s, skipping session', Dir{ferret}.path{sess});
            continue
        end
        
        % choose decimation so fs ~ 12.5 Hz (you can change target)
        fs_target = 12.5;
        decim = max(1, round(fs_raw / fs_target));
        fs     = fs_raw / decim;
        
        % build Welch target frequency grid for this session (common across episodes)
        % we want dense points in 20..200 s => f in [1/200, 1/20] Hz
        f_lo = 1/perBands(2);
        f_hi = 1/perBands(1);
        f_dense = linspace(f_lo, f_hi, nFreqDense);
        per_dense = 1 ./ f_dense;
        
        % iterate SWS episodes longer than 10 min
        neps = length(Start(SWSEpoch));
        for ep = 1:neps
            if DurationEpoch(subset(SWSEpoch, ep)) <= minSWS_sec*1e4

            % restrict to this SWS episode
            sg_ep = Restrict(SmoothGamma, subset(SWSEpoch, ep));
            x = Data(sg_ep);
            t = Range(sg_ep,'s');
            
            % decimate / sub-sample
            if use_decimate
                % anti-alias decimation (Signal Processing Toolbox)
                try
                    x_ds = decimate(double(x), decim); %#ok<DDECCT>
                catch
                    % fallback: simple subsample if decimate unavailable
                    x_ds = double(x(1:decim:end));
                end
                fs_ds = fs; %#ok<NASGU>
            else
                x_ds = double(x(1:decim:end));
                fs_ds = fs; %#ok<NASGU>
            end
            
            % sliding z-score to remove slow drifts (keep window >> 70 s)
            zwin = max(10, round(zwin_sec * fs));
            mu  = movmean(x_ds, zwin, 'omitnan');
            sd  = movstd( x_ds, zwin, 'omitnan');
            sd(sd==0) = NaN;
            xz_pre = (x_ds - mu) ./ sd;
            
            % optional light smoothing (<< 70 s) to improve ACF SNR
            %             sm_win = round(3*fs); % 3 s
            %             xz = movmean(xz_pre, sm_win, 'omitnan');
            xz = xz_pre;
            
            % ensure finite
            xz(~isfinite(xz)) = 0;
            
            % ---------- Autocorrelation (ACF) ----------
            maxLag = round(acfLag_sec * fs);
            [ac, lags] = xcorr(xz, maxLag, 'coeff');  % autocorr
            r_all{ferret}(end+1,:) = ac; %#ok<SAGROW>
            
            % ---------- Welch PSD focused on 20..200 s ----------
            % Use a long window: ~5–8 cycles of 70 s, but not longer than the episode
            L  = numel(xz);
            wLen = min(L, round(6*targetT_sec*fs));  % ~6 cycles
            if wLen < 2*fs
                % episode too short after decimation
                continue
            end
            nover = round(0.5*wLen);
            % Ask pwelch to compute at our dense frequency grid
            [pxx_ep, f_ep] = pwelch(xz, wLen, nover, f_dense, fs);
            % store
            pxx_all{ferret}(end+1,:) = pxx_ep(:); %#ok<SAGROW>
            perGrid = per_dense(:); % same for all eps in this ferret
        end
    end
        disp(Dir{ferret}.path{sess})
    end
    
    % ---------- aggregate this ferret ----------
    r_all{ferret}(r_all{ferret}==0) = NaN;
    pxx_all{ferret}(pxx_all{ferret}==0) = NaN;
    
    
    % ---------- plots for this ferret ----------
    figure('Color','w','Name',sprintf('Ferret %d — SmoothGamma SWS≥10min',ferret));
    
    % ACF (±100 s)
    subplot(1,2,1); hold on
    Data_to_use = r_all{ferret};
    Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
    h=shadedErrorBar(lags , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
    xlabel('Lag (s)'); ylabel('Autocorr (coeff)')
    xlim([-acfLag_sec acfLag_sec]); grid on; box off
    title('Autocorrelation (episode mean \pm SEM)')
    
    % PSD in period domain (20–200 s band, dense)
    subplot(1,2,2); hold on
    Data_to_use = pxx_all{ferret};
    Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
    h=shadedErrorBar(1./f_ep , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
    set(gca,'XScale','log'); grid on; box off
    xlabel('Period (s)'); ylabel('Power (Welch)')
    xlim([perBands(1) perBands(2)])
    %     % highlight ~70 s
    %     [~,i70] = min(abs(perGrid - targetT_sec));
    %     if ~isempty(i70) && isfinite(i70)
    %         plot(perGrid(i70), pxx_all(:,i70), 'ro','LineWidth',1.5,'MarkerSize',6)
    %         text(perGrid(i70), pxx_all(:,i70), '  ~70 s','Color','r','VerticalAlignment','bottom')
    %     end
    title('Welch PSD (20–200 s, dense freq grid)')
end


%%



for ferret=1:3
    R_all_f(ferret,:) = nanmean(r_all{ferret});
    PXX_all_f(ferret,:) = nanmean(pxx_all{ferret});
end



figure
Data_to_use = PXX_all_f;
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(f_ep , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
set(gca,'XScale','log'); grid on; box off
xlabel('Period (s)'); ylabel('Power (Welch)')
% xlim([perBands(1) perBands(2)])


