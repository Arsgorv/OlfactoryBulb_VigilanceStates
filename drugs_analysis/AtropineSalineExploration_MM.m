%% Load data for single session figure
sessionType = 'atropine';
A = PathForExperimentsArousal('Ficello', sessionType, 'all');
sessions = A.path';
wantedSlice = 'B';
AllSessions = struct();

for i = 1:length(sessions)
    
    datapath = sessions{i};
    % Session name 
    [~, sessionName] = fileparts(datapath);
    
    AllSessions(i).name = sessionName;
    AllSessions(i).path = datapath;
    
    % fUS data
    fus_file = dir(strcat(datapath, '/fUS/RP_data_*slice_', wantedSlice, '.mat'));
    
    if ~isempty(fus_file)
        tmp = load(fullfile(datapath, 'fUS', fus_file.name), 'cat_tsd', 'masks');
        AllSessions(i).fUS.cat_tsd = tmp.cat_tsd;
        AllSessions(i).fUS.masks  = tmp.masks;
    end
    
    % LFP (not used)
%     if contains(datapath, 'Ficello')
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP56.mat'));
%         AllSessions(i).LFP = tmp.LFP;
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP60.mat'));
%         AllSessions(i).Heart = tmp.LFP;
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP10.mat'));
%         AllSessions(i).LFPGamma = tmp.LFP;
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP58.mat'));
%         AllSessions(i).LFPRespiration = tmp.LFP;
%         
%     elseif contains(datapath, 'Kosichka')
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP21.mat'));
%         AllSessions(i).LFP = tmp.LFP;
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP4.mat'));
%         AllSessions(i).LFPGamma = tmp.LFP;
%     end
%     
    % Brain Powers gamma and delta
    GammaPowerFile = fullfile(datapath, 'ephys/SleepScoring_OBGamma.mat');
    
    if exist(GammaPowerFile, 'file')
        tmp = load(GammaPowerFile);
        AllSessions(i).GammaPower = tmp.BrainPower.Power{1,1};
        AllSessions(i).DeltaPower = tmp.BrainPower.Power{1,2};
    end
    
    % Spectrogram Middle Freq high pass 
    specFile = fullfile(datapath, 'ephys/B_Middle_Spectrum_HighPass.mat');
    
    if exist(specFile, 'file')
        
        load(specFile); % loads Spectro

        datb = Spectro{1};
        
        sptsdB = tsd(Spectro{2}*1e4, datb);
        fB = Spectro{3};
        
        % Limits
        CMax.OB = max(max(Data(sptsdB)))*1.05;
        CMin.OB = min(min(Data(sptsdB)))*0.95;
        
        % Store
        AllSessions(i).SpectroMiddle.sptsdB = sptsdB;
        AllSessions(i).SpectroMiddle.fB = fB;
        AllSessions(i).SpectroMiddle.CMin = CMin;
        AllSessions(i).SpectroMiddle.CMax = CMax;
        clear Spectro
    end
    
    % Spectrogram Low Freq high pass 
    
    specFile = fullfile(datapath, 'ephys/B_Low_Spectrum.mat');
    
    if exist(specFile, 'file')
        
        load(specFile);         
        datb = Spectro{1};
        
        sptsdB = tsd(Spectro{2}*1e4, datb);
        fB = Spectro{3};
        
        % Limits
        CMax.OB = max(max(Data(sptsdB)))*1.05;
        CMin.OB = min(min(Data(sptsdB)))*0.95;
        
        % Store
        AllSessions(i).SpectroLow.sptsdB = sptsdB;
        AllSessions(i).SpectroLow.fB = fB;
        AllSessions(i).SpectroLow.CMin = CMin;
        AllSessions(i).SpectroLow.CMax = CMax;
        clear Spectro
    end
    
    % Epochs 
    
    masterFile = fullfile(datapath, 'Master_sync.mat');
    
    if exist(masterFile, 'file')
        
        tmp = load(masterFile);
        
        % If Epochs already exists inside file
        if isfield(tmp, 'Epochs')
            AllSessions(i).Epochs = tmp.Epochs;
        end
        
    else
        warning('No Master_sync.mat for session %s', S.name)
    end
    disp('session loaded')
end

%% Single session figures
SmoothingWindow = 10;
step = 20; % subsampling for scatter plot
SaveFolder = '/home/arsenii/data5/Arsenii/OB_fUS_Arousal/Processed_data/Ficello/Figures'; % adapte le chemin
colorBefore= [0.3010, 0.7450, 0.9330];
colorAfter = [0.9290, 0.6940, 0.1250];
if ~exist(SaveFolder, 'dir')
    mkdir(SaveFolder);
end

for i = 1:length(AllSessions)
    
    S = AllSessions(i);
    
    % fUS 
    cat_tsd = S.fUS.cat_tsd;
    masks   = S.fUS.masks;
    
    fUSData = Data(cat_tsd.data);
    fUSDataReshaped = reshape(fUSData', cat_tsd.Nx, cat_tsd.Ny, size(fUSData,1)');
    Nt = size(fUSDataReshaped,3);
    
    TFUS = Range(cat_tsd.data,'s');
    
    % Injection: middle of fUS recording
    NpointsBeforeSplit = round(length(TFUS)/2);
    
    t_mid = TFUS(round(length(TFUS)/2));
    idx_before = TFUS <= t_mid-60;
    idx_after  = TFUS >  t_mid+60;
    
    % Hipp and AEG fUS traces
    mask_hipp = masks.Hippocampus; 
    mask_AEG = masks.AEG;
    trace = zeros(Nt,1);
    for t = 1:Nt
        frame = fUSDataReshaped(:,:,t);
        trace_hipp(t) = mean(frame(mask_hipp));
        trace_AEG(t) = mean(frame(mask_AEG));
    end
    
    trace_hipp = runmean(trace_hipp, SmoothingWindow);
    trace_zscored_hipp = zscore_basedOnBeginning(trace_hipp, NpointsBeforeSplit - 100);
    
    trace_AEG = runmean(trace_AEG, SmoothingWindow);
    trace_zscored_AEG = zscore_basedOnBeginning(trace_AEG, NpointsBeforeSplit - 100);
    
    % Gamma
    Gamma = S.GammaPower;
    
    GammaData = Data(Gamma);
    GammaData = runmean(GammaData, round(0.3 * 1250)); %smoothing on 300 ms
    TGamma = Range(Gamma,'s');
    
    Gamma_interp = interp1(TGamma, GammaData, TFUS, 'linear','extrap');
    Gamma_interp = runmean(Gamma_interp, SmoothingWindow);
    Gamma_interp_zscored = zscore_basedOnBeginning(Gamma_interp, NpointsBeforeSplit - 100);

    % Subsample for scatter plots
    
    fUS_before_hipp = trace_hipp(idx_before); 
    fUS_after_hipp = trace_hipp(idx_after);
    fUS_before_sub_hipp = fUS_before_hipp(1:step:end);
    fUS_after_sub_hipp = fUS_after_hipp(1:step:end);
    
    fUS_before_AEG = trace_AEG(idx_before); 
    fUS_after_AEG = trace_AEG(idx_after);
    fUS_before_sub_AEG = fUS_before_AEG(1:step:end);
    fUS_after_sub_AEG = fUS_after_AEG(1:step:end);GammaData = runmean(GammaData, round(0.3 * 1250));
    
    gamma_before = Gamma_interp(idx_before);
    gamma_after = Gamma_interp(idx_after);
    gamma_before_sub = gamma_before(1:step:end);   
    gamma_after_sub = gamma_after(1:step:end);
    
    % figure 
    
    figure('Name', S.name, 'Position', [100 100 1500 950]);
    sgtitle('Zscored only based on before injection stats')

    % Spectrogram
    ax1 = subplot(4,5,[1 2 3 4 5]);
    
    if isfield(S,'SpectroMiddle')
        sptsdB = S.SpectroMiddle.sptsdB;
        fB = S.SpectroMiddle.fB;
        D = Data(sptsdB); D = D(1:100:end,:); R = Range(sptsdB, 's'); R = R(1:100:end);
        imagesc(R/60, fB, runmean(runmean(log10(D'),2)',10)'), axis xy 
        caxis([2.1 3.6]),
        colormap(ax1, 'parula') 
        axis xy, %caxis(10*log10([S.SpectroMiddle.CMin.OB S.SpectroMiddle.CMax.OB]))
        ylabel('Freq (Hz)');
        xlabel('Time (min)');
        xlim([0, 180]);
        xline(t_mid/60, '--k', 'LineWidth', 2);
        title([S.name ' - Spectrogram'])
    end
    
    % fUS and Gamma traces
    
    ax2 = subplot(4,5,[6 7 8 9 10]);
    
    plot(TFUS/60, -trace_zscored_hipp); hold on
    plot(TFUS/60, -trace_zscored_AEG); 
    offset = min(Gamma_interp_zscored);
    plot(TFUS/60, Gamma_interp_zscored - offset);
    xline(t_mid/60, '--k', 'LineWidth', 2);
    
    legend('- HPC dCBV','-AEG dCBV', 'OB Gamma power');
    xlabel('Time (min)');
    ylabel('Z-score');
    title('Traces');
    xlim([0, 180]);
    linkaxes([ax1, ax2], 'x');
    
    % scatter plot gamma power vs fUS
    
    subplot(4,5,11) ;

    scatter(log(gamma_before_sub), log(fUS_before_sub_hipp), 10, colorBefore ,'filled'); hold on
    scatter(log(gamma_after_sub), log(fUS_after_sub_hipp),  10, colorAfter ,'filled');

    xlabel('log(OB Gamma power)');
    ylabel('log(HPC dCBV)');

    legend('Before','After');
    grid on;
    
    subplot(4,5,12) ;

    scatter(log(gamma_before_sub), log(fUS_before_sub_AEG), 10, colorBefore ,'filled'); hold on
    scatter(log(gamma_after_sub), log(fUS_after_sub_AEG),  10, colorAfter ,'filled');

    xlabel('log(OB Gamma power)');
    ylabel('log(AEG dCBV)');

    legend('Before','After');
    grid on;
    
    s3 = subplot(4,5,13);
    meanImg = mean(fUSDataReshaped, 3);
    frame_double = double(meanImg);
    frame_log = log(frame_double + 1);
    frame_log = frame_log - min(frame_log(:));
    frame_log = frame_log / max(frame_log(:));
    meanImg = uint8(frame_log * 255);
    imagesc(meanImg)
    hold on; 
    B = bwboundaries(masks.Hippocampus);
    plot(B{1}(:,2), B{1}(:,1), 'r')
    B = bwboundaries(masks.AEG);
    plot(B{1}(:,2), B{1}(:,1), 'r')
    colormap(s3, 'gray')
    
    
    % Gamma boxplot
    subplot(4,5,18)

    Cols = {colorBefore,colorAfter};
    X = 1:2;
    Legends = {'Before','After'};
    MakeSpreadAndBoxPlot3_SB({gamma_before gamma_after},Cols,X,Legends,'showpoints',0,'paired',0);
    ylabel('OB gamma power')
%     makepretty_BM2

    % fUS boxplot
    subplot(4,5,16)    
    X = 1:2;
    Legends = {'Before','After'};
    MakeSpreadAndBoxPlot3_SB({fUS_before_hipp fUS_after_hipp},Cols,X,Legends,'showpoints',0,'paired',0);
    ylabel('HPC dCBV')
%     makepretty_BM2

    subplot(4,5,17)    
    X = 1:2;
    Legends = {'Before','After'};
    MakeSpreadAndBoxPlot3_SB({fUS_before_AEG fUS_after_AEG},Cols,X,Legends,'showpoints',0,'paired',0);
    ylabel('AEG dCBV')
%     makepretty_BM2

    
    %  mean spectrum across time: for Middle and low spectra
    
    if isfield(S,'SpectroMiddle')
        
        sptsdB = S.SpectroMiddle.sptsdB;
        fB     = S.SpectroMiddle.fB;
        
        spec = Data(sptsdB); % time x freq
        t_spec = Range(sptsdB,'s');
        
        % Same split as fUS
        idx_before_spec = t_spec <= (t_mid - 60);
        idx_after_spec  = t_spec >  (t_mid + 60);
        
        % Mean over time
        Spec_before = nanmean(spec(idx_before_spec,:), 1);
        Spec_after  = nanmean(spec(idx_after_spec,:),  1);
    end

    subplot(4,5,15)
    
    plot(fB, fB.*Spec_before, 'Color' , colorBefore,'LineWidth',2); hold on
    plot(fB, fB.*Spec_after, 'Color' ,  colorAfter,'LineWidth',2);
    
    xlabel('Frequency (Hz)')
    ylabel('Power')
    title('Mean Middle spectrum')
    xlim([20, 100])
    legend('Before','After')
    grid on
    
    
    if isfield(S,'SpectroLow')
        
        sptsdB = S.SpectroLow.sptsdB;
        fB     = S.SpectroLow.fB;
        
        spec = Data(sptsdB); % time x freq
        t_spec = Range(sptsdB,'s');
        
        % Same split as fUS
        idx_before_spec = t_spec <= (t_mid - 60);
        idx_after_spec  = t_spec >  (t_mid + 60);
        
        % Mean over time
        Spec_before = nanmean(spec(idx_before_spec,:), 1);
        Spec_after  = nanmean(spec(idx_after_spec,:),  1);
    end

    subplot(4,5,14)
    
    plot(fB, fB.*Spec_before, 'Color' , colorBefore,'LineWidth',2); hold on
    plot(fB, fB.*Spec_after, 'Color' ,  colorAfter,'LineWidth',2);
    
    xlabel('Frequency (Hz)')
    ylabel('Power')
    xlim([0, 10])
    title('Mean Low spectrum')
    legend('Before','After')
    grid on
    
    
    % Gamma power density  
    
    subplot(4,5,20)
    gamma_before_full = Gamma_interp(idx_before);
    gamma_after_full  = Gamma_interp(idx_after);
    smoothingParam=5;
    [Y_tot,X_tot]=hist(log(gamma_before_full),1000); Y_tot=Y_tot/sum(Y_tot);
    plot(X_tot , runmean(Y_tot, smoothingParam)  , 'Color' ,colorBefore)
    hold on
    [Y_tot,X_tot]=hist(log(gamma_after_full),1000); Y_tot=Y_tot/sum(Y_tot);
     plot(X_tot , runmean(Y_tot, smoothingParam) , 'Color' ,  colorAfter)
%     [f1, x1] = ksdensity(gamma_before_full);
%     [f2, x2] = ksdensity(gamma_after_full);
% 
%     plot(x1, f1, 'b','LineWidth',2); hold on
%     plot(x2, f2, 'r','LineWidth',2);
%     set(gca, 'XScale', 'log')  
    xlabel('Gamma ')
    ylabel('Density')
    title('OB Gamma power distribution')
    legend('Before','After')
    grid on
    
        
    % delta power density
    
    Delta = S.DeltaPower;
    
    DeltaData = Data(Delta);
    DeltaData = runmean(DeltaData, round(0.3 * 1250)); % smoothing on 300 ms
    TDelta = Range(Delta,'s');
    Delta_interp = interp1(TDelta, DeltaData, TFUS, 'linear','extrap');
    Delta_interp = runmean(Delta_interp, SmoothingWindow);
    delta_before_full = Delta_interp(idx_before);
    delta_after_full  = Delta_interp(idx_after);
    
    subplot(4,5,19)
    
    [Y_tot,X_tot]=hist(log(delta_before_full),1000); Y_tot=Y_tot/sum(Y_tot);
    plot(X_tot , runmean(Y_tot, smoothingParam)  , 'Color' ,colorBefore)
    hold on
    [Y_tot,X_tot]=hist(log(delta_after_full),1000); Y_tot=Y_tot/sum(Y_tot);
     plot(X_tot , runmean(Y_tot, smoothingParam)  , 'Color' , colorAfter)
%     [f1, x1] = ksdensity(delta_before_full);
%     [f2, x2] = ksdensity(delta_after_full);
% 
%     plot(x1, f1, 'b','LineWidth',2); hold on
%     plot(x2, f2, 'r','LineWidth',2);
    xlabel('Delta ')
    ylabel('Density')
    title('OB Delta power distribution')
    legend('Before','After')
    grid on
    
    
    
    session_name = S.name;
    filename = fullfile(SaveFolder, [sessionType '_' session_name '.png']);
    %saveas(gcf, filename);
end

%% Load data for Across session figures

clear all

A = PathForExperimentsArousal('Ficello', 'atropine', 'all');
B = PathForExperimentsArousal('Ficello', 'saline', 'all');
sessions = [A.path'; B.path'];

wantedSlice = 'B';
AllSessions = struct();

for i = 1:length(sessions)
    
    datapath = sessions{i};
    % Session name
    [~, sessionName] = fileparts(datapath);
    
    AllSessions(i).name = sessionName;
    AllSessions(i).path = datapath;
    
    % fUS
    fus_file = dir(strcat(datapath, '/fUS/RP_data_*slice_', wantedSlice, '.mat'));
    
    if ~isempty(fus_file)
        load(fullfile(datapath, 'fUS', fus_file.name), 'cat_tsd', 'masks');
        
        fUSData = Data(cat_tsd.data);
        fUSDataReshaped = reshape(fUSData', cat_tsd.Nx, cat_tsd.Ny, size(fUSData,1)');
        Nt = size(fUSDataReshaped,3);
        
        TFUS = Range(cat_tsd.data,'s');
        mask_hipp = masks.Hippocampus;
        mask_AEG = masks.AEG;
        trace = zeros(Nt,1);
        for t = 1:Nt
            frame = fUSDataReshaped(:,:,t);
            trace_hipp(t) = mean(frame(mask_hipp));
            trace_AEG(t) = mean(frame(mask_AEG));
        end
        
        meanImg = mean(fUSDataReshaped, 3);
        frame_double = double(meanImg);
        frame_log = log(frame_double + 1);
        frame_log = frame_log - min(frame_log(:));
        frame_log = frame_log / max(frame_log(:));
        meanImg = uint8(frame_log * 255);
    
        AllSessions(i).fUS.mask_AEG = mask_AEG;
        AllSessions(i).fUS.mask_hipp  = mask_hipp;
        AllSessions(i).fUS.trace_AEG = trace_AEG;
        AllSessions(i).fUS.trace_hipp  = trace_hipp;
        AllSessions(i).fUS.meanImg  = meanImg;
        AllSessions(i).fUS.TFUS = TFUS;
        
    end
    
    % LFP
%     if contains(datapath, 'Ficello')
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP56.mat'));
%         AllSessions(i).LFP = tmp.LFP;
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP60.mat'));
%         AllSessions(i).Heart = tmp.LFP;
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP10.mat'));
%         AllSessions(i).LFPGamma = tmp.LFP;
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP58.mat'));
%         AllSessions(i).LFPRespiration = tmp.LFP;
%         
%     elseif contains(datapath, 'Kosichka')
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP21.mat'));
%         AllSessions(i).LFP = tmp.LFP;
%         
%         tmp = load(fullfile(datapath, 'ephys/LFPData/LFP4.mat'));
%         AllSessions(i).LFPGamma = tmp.LFP;
%     end
    
    % GammaPower
    GammaPowerFile = fullfile(datapath, 'ephys/SleepScoring_OBGamma.mat');
    
    if exist(GammaPowerFile, 'file')
        tmp = load(GammaPowerFile);
        %         AllSessions(i).SmoothGamma = tmp.SmoothGamma;
        AllSessions(i).GammaPower = tmp.BrainPower.Power{1,1};
        AllSessions(i).DeltaPower = tmp.BrainPower.Power{1,2};
    end
    
    % Spectrogram 
    specFile = fullfile(datapath, 'ephys/B_Middle_Spectrum_HighPass.mat');
    
    if exist(specFile, 'file')
        
        load(specFile); % loads Spectro
        %load(fullfile(datapath, 'ephys/SleepScoring_OBGamma'));
        
        datb = Spectro{1};
        
        sptsdB = tsd(Spectro{2}*1e4, datb);
        fB = Spectro{3};
        
        % Limits
        CMax.OB = max(max(Data(sptsdB)))*1.05;
        CMin.OB = min(min(Data(sptsdB)))*0.95;
        
        % Store
        AllSessions(i).SpectroMiddle.sptsdB = sptsdB;
        AllSessions(i).SpectroMiddle.fB = fB;
        AllSessions(i).SpectroMiddle.CMin = CMin;
        AllSessions(i).SpectroMiddle.CMax = CMax;
        clear Spectro
    end
    
    specFile = fullfile(datapath, 'ephys/B_Low_Spectrum.mat');
    
    if exist(specFile, 'file')
        
        load(specFile); % loads Spectro
        
        datb = Spectro{1};
        
        sptsdB = tsd(Spectro{2}*1e4, datb);
        fB = Spectro{3};
        
        % Limits
        CMax.OB = max(max(Data(sptsdB)))*1.05;
        CMin.OB = min(min(Data(sptsdB)))*0.95;
        
        % Store
        AllSessions(i).SpectroLow.sptsdB = sptsdB;
        AllSessions(i).SpectroLow.fB = fB;
        AllSessions(i).SpectroLow.CMin = CMin;
        AllSessions(i).SpectroLow.CMax = CMax;
        clear Spectro
    end
    masterFile = fullfile(datapath, 'Master_sync.mat');
    
    if exist(masterFile, 'file')
        
        tmp = load(masterFile);
        if isfield(tmp, 'Epochs')
            AllSessions(i).Epochs = tmp.Epochs;
        end
        
    else
        warning('No Master_sync.mat for session %s', S.name)
    end
    disp('session loaded')
    clear fUSData
    clear fUSDataReshaped
    clear sptsdB
end


%% Across session figures: Mean traces across sessions and box plots 

% inspired by Ferret_Atropine_HeadRestraint_BM.m
 % drugs: 1:saline, 2:atropine
 
for sess=1:10
    if sess<=5
        drug=2;
    else
        drug=1;
    end
    SmoothGamma = AllSessions(sess).GammaPower;
    SmoothGammaData = Data(SmoothGamma);
    TFUS = AllSessions(sess).fUS.TFUS;
    t_mid = TFUS(round(length(TFUS)/2));
    TGamma = Range(SmoothGamma, 's');
    t_before = TGamma < t_mid;
    t_after = TGamma>=t_mid;
    clear D, D = SmoothGammaData(t_before);
    Smooth_Gamma_interp{drug}(1,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
    clear D, D = SmoothGammaData(t_after);
    Smooth_Gamma_interp{drug}(2,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
    
    Smooth_Gamma_mean{drug}(1,sess) = nanmean(SmoothGammaData(t_before));
    Smooth_Gamma_mean{drug}(2,sess) = nanmean(SmoothGammaData(t_after));
    
    
    SmoothDelta = AllSessions(sess).DeltaPower;
    SmoothDeltaData = Data(SmoothDelta);
    TFUS = AllSessions(sess).fUS.TFUS;
    t_mid = TFUS(round(length(TFUS)/2));
    TDelta= Range(SmoothDelta, 's');
    t_before = TDelta < t_mid;
    t_after = TDelta>=t_mid;
    clear D, D =SmoothDeltaData(t_before);
    Smooth_Delta_interp{drug}(1,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
    clear D, D = SmoothDeltaData(t_after);
    Smooth_Delta_interp{drug}(2,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
   
    
    % spectrogram
    
    B_Sptsd = AllSessions(sess).SpectroMiddle.sptsdB;
    T_Sptsd = Range(B_Sptsd, 's');
    t_before = T_Sptsd < t_mid;
    t_after = T_Sptsd>=t_mid;
    OB_Sp = Data(B_Sptsd); 
    OB_MiddleSpectrum_Bef_Inj{drug}(sess,:) = nanmean(OB_Sp(t_before,:));
    OB_MiddleSpectrum_Aft_Inj{drug}(sess,:) = nanmean(OB_Sp(t_after, :));
    
    % fUS 
    HippTrace = AllSessions(sess).fUS.trace_hipp;
    TFUS = AllSessions(sess).fUS.TFUS;
    t_mid = TFUS(round(length(TFUS)/2));
    t_before = TFUS < t_mid;
    t_after = TFUS>=t_mid;
    clear D, D = HippTrace(t_before);
    hippCBV_interp{drug}(1,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
    clear D, D = HippTrace(t_after);
    hippCBV_interp{drug}(2,sess,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
    
    hippCBV_mean{drug}(1,sess) = nanmean(HippTrace(t_before));
    hippCBV_mean{drug}(2,sess) = nanmean(HippTrace(t_after));
        
end

Cols = {[.3 .3 .3],[.3 1 .3]};
X = 1:2;
Legends = {'Saline','Atropine'};

figure
subplot(2,3,1:2)
Data_to_use = squeeze(Smooth_Gamma_interp{1}(2,:,:))./nanmean(squeeze(Smooth_Gamma_interp{1}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1.5,100), Mean_All_Sp , Conf_Inter ,'-k',1); hold on

Data_to_use = squeeze(Smooth_Gamma_interp{2}(2,:,:))./nanmean(squeeze(Smooth_Gamma_interp{2}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1.5,100), Mean_All_Sp , Conf_Inter ,'-g',1);
title('Head restraint after injection'); ylim([0 2]); yline(1,'--r'); ylabel('OB Gamma power (norm)');
makepretty_BM2


subplot(233)
MakeSpreadAndBoxPlot3_SB({Smooth_Gamma_mean{1}(2,:)./Smooth_Gamma_mean{1}(1,:)...
    Smooth_Gamma_mean{2}(2,:)./Smooth_Gamma_mean{2}(1,:)},Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('OB Gamma power (norm)')
makepretty_BM2

subplot(2,3,4:5)
Data_to_use = squeeze(hippCBV_interp{1}(2,:,:))./nanmean(squeeze(hippCBV_interp{1}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1.5,100), Mean_All_Sp , Conf_Inter ,'-k',1); hold on
Data_to_use = squeeze(hippCBV_interp{2}(2,:,:))./nanmean(squeeze(hippCBV_interp{2}(1,:,:))')';
Data_to_use = movmean(Data_to_use',10)';
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
Mean_All_Sp=nanmedian(Data_to_use);
shadedErrorBar(linspace(0,1.5,100), Mean_All_Sp , Conf_Inter ,'-g',1);
title('Head restraint after injection'); ylim([0.5 1.5]); yline(1,'--r'); ylabel('HPC dCBV (norm)');
makepretty_BM2


subplot(236)
MakeSpreadAndBoxPlot3_SB({hippCBV_mean{1}(2,:)./hippCBV_mean{1}(1,:)...
    hippCBV_mean{2}(2,:)./hippCBV_mean{2}(1,:)},Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('HPC dCBV  (norm)')
makepretty_BM2

%% Across session figures: Mean spectrum

figure
subplot(1,4,1:2)
clear Spectro
Spectro{3} = AllSessions(1).SpectroMiddle.fB;
OB_MiddleSpectrum_Bef_Inj_Saline = OB_MiddleSpectrum_Bef_Inj{1};
OB_MiddleSpectrum_Bef_Inj_Atropine = OB_MiddleSpectrum_Bef_Inj{2};
OB_MiddleSpectrum_Bef_Inj_Saline(1:5, :)=[];

OB_MiddleSpectrum_Aft_Inj_Saline = OB_MiddleSpectrum_Aft_Inj{1};
OB_MiddleSpectrum_Aft_Inj_Atropine = OB_MiddleSpectrum_Aft_Inj{2};
OB_MiddleSpectrum_Aft_Inj_Saline(1:5, :)=[];


[~,MaxPowerValues1,f1] = Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_MiddleSpectrum_Bef_Inj_Saline , 'color' , 'k');
[~,MaxPowerValues2,f2] = Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_MiddleSpectrum_Bef_Inj_Atropine , 'color' , 'k');
[~,MaxPowerValues3,Freq_Max1] = Plot_MeanSpectrumForMice_BM((Spectro{3}.*OB_MiddleSpectrum_Aft_Inj_Saline)./MaxPowerValues1');
[~,MaxPowerValues4,Freq_Max2] = Plot_MeanSpectrumForMice_BM((Spectro{3}.*OB_MiddleSpectrum_Aft_Inj_Atropine)./MaxPowerValues2');
clf
subplot(1,4,1:2)
Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_MiddleSpectrum_Aft_Inj_Saline , 'color' , 'k' , 'power_norm_value' , MaxPowerValues1);
Plot_MeanSpectrumForMice_BM(Spectro{3}.*OB_MiddleSpectrum_Aft_Inj_Atropine , 'color' , 'g' , 'power_norm_value' , MaxPowerValues2);
xlim([20 100]), %ylim([0 1.1])
makepretty_BM2, axis square
f=get(gca,'Children'); legend([f(5),f(1)],'Saline','Atropine');

subplot(143)
MakeSpreadAndBoxPlot3_SB({MaxPowerValues3 MaxPowerValues4},Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('OB gamma power (norm)')
makepretty_BM2

subplot(144)
MakeSpreadAndBoxPlot3_SB({Freq_Max1 Freq_Max2},Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('OB gamma freq (Hz)')
makepretty_BM2

%% Accross session figures: Brain power distribution


Gamma_before_all = cell(1,2);
Gamma_after_all  = cell(1,2);
Delta_before_all = cell(1,2);
Delta_after_all  = cell(1,2);

SmoothingWindow = 3;
for drug = 1:2
    Gamma_before_all{drug} = [];
    Gamma_after_all{drug}  = [];
    Delta_before_all{drug} = [];
    Delta_after_all{drug}  = [];
end

for sess=1:10
    if sess<=5
        drug=2;
    else
        drug=1;
    end
    Gamma = AllSessions(sess).GammaPower;
    GammaData = Data(Gamma);
    SmoothGamma = runmean(GammaData, round(0.3 * 1250));
    
    TFUS = AllSessions(sess).fUS.TFUS;
    t_mid = TFUS(round(length(TFUS)/2));
    TGamma = Range(Gamma, 's');

    Gamma_interp = interp1(TGamma, SmoothGamma, TFUS, 'linear', 'extrap');
    
    t_before = TFUS < t_mid-61;
    t_after = TFUS>=t_mid+61;
    gamma_before_full = runmean(Gamma_interp(t_before), SmoothingWindow); 
    gamma_after_full = runmean(Gamma_interp(t_after), SmoothingWindow); 
    Gamma_before_all{drug} = [Gamma_before_all{drug}, log(gamma_before_full(:))];
    Gamma_after_all{drug}  = [Gamma_after_all{drug},  log(gamma_after_full(:))];
    
    
    Delta = AllSessions(sess).DeltaPower;
    DeltaData = Data(Delta);
    SmoothDelta = runmean(DeltaData, round(0.3 * 1250));
    
    TFUS = AllSessions(sess).fUS.TFUS;
    t_mid = TFUS(round(length(TFUS)/2));
    TDelta = Range(Delta, 's');

    Delta_interp = interp1(TDelta, SmoothDelta, TFUS, 'linear', 'extrap');
    
    t_before = TFUS < t_mid-61;
    t_after = TFUS>=t_mid+61;
    Delta_before_full = runmean(Delta_interp(t_before), SmoothingWindow); 
    Delta_after_full = runmean(Delta_interp(t_after), SmoothingWindow); 
    Delta_before_all{drug} = [Delta_before_all{drug}, log(Delta_before_full(:))];
    Delta_after_all{drug}  = [Delta_after_all{drug},  log(Delta_after_full(:))];
    
    
end


smoothingParam = 5;

colors = {
    [0 0 1],        % Drug1 Before (blue)
    [0 0.5 1],      % Drug1 After (light blue)
    [1 0 0],        % Drug2 Before (red)
    [1 0.5 0]       % Drug2 After (orange)
};

labels = {
    'Saline Before', 'Saline After', ...
    'Atropine Before', 'Atropine After'
};

figure(1)
subplot(1,2,1)
hold on
sgtitle('Brain Powe distributions across sessions');
data_all = {
    Gamma_before_all{1}, Gamma_after_all{1}, ...
    Gamma_before_all{2}, Gamma_after_all{2}
};
hLegend = gobjects(1,4); 
for k = 1:4
    
    data = data_all{k};
    
    edges = linspace(3.5, 7, 1001); % 1000 bins → 1001 edges
    AllY = [];
    for iSess = 1:5
        Ysess = histcounts(data(:, iSess), edges, 'Normalization','probability');
        Ysess = Ysess / sum(Ysess);
        AllY = [AllY; Ysess];
    end

    % Compute bin centers
    X = (edges(1:end-1) + edges(2:end)) / 2;
    Conf_Inter = nanstd(AllY)/sqrt(size(AllY,1));
    Conf_Inter = runmean(Conf_Inter, smoothingParam); 
    MeanY = mean(AllY,1);
    MeanY = runmean(MeanY, smoothingParam); 
    h=shadedErrorBar(X,MeanY, Conf_Inter,'-k',1);   hold on;
    h.mainLine.Color=colors{k}; h.patch.FaceColor=colors{k}; h.edge(1).Color=colors{k}; h.edge(2).Color=colors{k};
    hLegend(k) = h.mainLine;
end

xlabel('log(Gamma power)'); ylabel('Density');

legend(hLegend, labels, 'Location', 'best');

subplot(1,2,2)
hold on

data_all = {
    Delta_before_all{1}, Delta_after_all{1}, ...
    Delta_before_all{2}, Delta_after_all{2}
};
hLegend = gobjects(1,4); 
for k = 1:4
    
    data = data_all{k};
    
    edges = linspace(5, 9, 1001); % 1000 bins → 1001 edges
    AllY = [];
    for iSess = 1:5
        Ysess = histcounts(data(:, iSess), edges, 'Normalization','probability');
        Ysess = Ysess / sum(Ysess);
        AllY = [AllY; Ysess];
    end

    % Compute bin centers
    X = (edges(1:end-1) + edges(2:end)) / 2;
    Conf_Inter = nanstd(AllY)/sqrt(size(AllY,1));
    Conf_Inter = runmean(Conf_Inter, smoothingParam); 
    MeanY = mean(AllY,1);
    MeanY = runmean(MeanY, smoothingParam); 
    h=shadedErrorBar(X,MeanY, Conf_Inter,'-k',1);   hold on;
    h.mainLine.Color=colors{k}; h.patch.FaceColor=colors{k}; h.edge(1).Color=colors{k}; h.edge(2).Color=colors{k};
    hLegend(k) = h.mainLine;
end

xlabel('log(Delta power)'); ylabel('Density');

legend(hLegend, labels, 'Location', 'best');




function makepretty_BM2()
% set some graphical attributes of the current axis

set(get(gca, 'XLabel'), 'FontSize', 22);
set(get(gca, 'YLabel'), 'FontSize', 22);
set(gca, 'FontSize', 16);
box off
set(gca,'Linewidth',2)
set(get(gca, 'Title'), 'FontSize', 18);
end

function x_zscored = zscore_basedOnBeginning(x, N)

Baseline = x(1:N);
mu = mean(Baseline);
sigma = std(Baseline);
% Apply z-score using baseline mean and std
x_zscored = (x - mu) / sigma;

end 