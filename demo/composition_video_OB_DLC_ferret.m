function composition_video_OB_DLC_ferret
%% Parameters
vid_name = 'test';

% bin = 0.8; % 0.2 = x1; 0.4 = x2; 0.8 = x4
rec = 'Arb'; % 'Full_Rec', 'Thirds', 'Arb'
sub_rec = 'First'; % 'First', 'Second', 'Third'
SS_base = '0.1-0.5'; % '0.1-0.5', '1-8'

% In case you want to set your own beginning and end, define it here:
% REM#2 302
% arb_begin = 82400; % this is the number of a frame starting from the time_1st_trig
% arb_end = 94500; % this is the number of a frame starting from the time_1st_trig

% arb_begin = 92880; % this is the number of a frame starting from the time_1st_trig
% arb_end = 92990; % this is the number of a frame starting from the time_1st_trig

% arb_begin = 92980; % this is the number of a frame starting from the time_1st_trig
% arb_end = 92990; % this is the number of a frame starting from the time_1st_trig

% arb_begin = 1; % this is the number of a frame starting from the time_1st_trig
% arb_end = 100; % this is the number of a frame starting from the time_1st_trig

arb_begin = 36600; % this is the number of a frame starting from the time_1st_trig
arb_end = 42900; % this is the number of a frame starting from the time_1st_trig

% REM#2 0227
% arb_begin = 107615; % this is the number of a frame starting from the time_1st_trig
% arb_end = 107715; % this is the number of a frame starting from the time_1st_trig

% control and adjust the chosen time by the following lines
time(arb_begin)
time(arb_end)

%% Load data
disp('load scoring')
load('StateEpochSB.mat')
load('StateEpochBM.mat')
load('behavResources.mat')

%% Defining Epochs
TotalEpoch=intervalSet(0*1e4,max(Range(smooth_ghi)));

smooth_ghi_new = Restrict(smooth_ghi,TotalEpoch);
smooth_01_05_new = Restrict(smooth_01_05, TotalEpoch);

t=Range(smooth_01_05_new);
ti=t(5:500:end);

smooth_ghi_new = Restrict(smooth_ghi_new,ts(ti));
smooth_01_05_new = Restrict(smooth_01_05_new,ts(ti));

begin=Start(TotalEpoch)/1e4;
begin=begin(1);
endin=Stop(TotalEpoch)/1e4;
endin=endin(end);

% define the DLC time
try
    %     file=dir('*frames.csv');
catch
    file=dir([pwd '/DLC/' '*frames.csv']);
end

data_csv = csvread(fullfile([pwd '/DLC/' ],file.name)); %loads the csv from line 3 to the end (to skip the Header)
dateStr = regexp(file.name, '\d{8}', 'match');
date = dateStr{1};
%
% time_trig = data_csv;
% time_trig = time_trig - time_trig(1);
try
    load([pwd '/DLC/DLC_data.mat'])
catch
    load([pwd '/DLC/DLC_iteration_1/DLC_data.mat'])
end
time = time_trig + time_1st_trig;

%% Load spectrum
disp('loading middle spectrum...')
load('B_Middle_Spectrum.mat')
Spectro_B = Spectro;
sptsdB=tsd(Spectro_B{2}*1e4,Spectro_B{1});
fB=Spectro{3};

% OB
disp('loading OB LFP...')
% load(['LFPData/LFP','26','.mat'])
% LFPB1 = FilterLFP(LFP,[1 200],1024);
load(['LFPData/LFP','24','.mat'])
LFPB2 = FilterLFP(LFP,[1 200],1024);

% screw
disp('loading screw LFP...')
load(['LFPData/LFP','1','.mat'])
LFP_screw = FilterLFP(LFP,[1 200],1024);

% % EMG_1
disp('loading EMG LFP...')
load(['LFPData/LFP','12','.mat'])
LFP_EMG_1 = FilterLFP(LFP,[1 200],1024);

% EMG_2
load(['LFPData/LFP','19','.mat'])
LFP_EMG_2 = FilterLFP(LFP,[1 200],1024);

% Low 1-8 Hz spectrum
% disp('loading low spectrum...')
% load('B_Low_Spectrum.mat')
% Spectro_H = Spectro;
% sptsdH=tsd(Spectro_H{2}*1e4,Spectro_H{1});
% fH=Spectro{3};

% UltraLow 0.1-0.5 Hz spectrum
disp('loading ultralow spectrum...')
load('B_UltraLow_Spectrum.mat')
Spectro_UL = Spectro;
sptsdUL=tsd(Spectro_UL{2}*1e4,Spectro_UL{1});
sptsdUL = Restrict(sptsdUL, TotalEpoch);
fUl=Spectro{3};

% Reference spectrum
disp('loading reference spectrum...')
load('Ref_Low_Spectrum.mat')
Spectro_ref = Spectro;
sptsdRef=tsd(Spectro_ref{2}*1e4,Spectro_ref{1});
sptsdRef = Restrict(sptsdRef, TotalEpoch);
fRef=Spectro{3};

%% Select the case

switch rec
    case 'Full_Rec'
        % Record and display full
        begin_recording = 1;
        stop_recording = max(Range(LFPB2,'s'));
        spectro_window = [min(Range(LFPB2,'s')) max(Range(LFPB2,'s'))];
    case 'Thirds'
        switch sub_rec
            case 'First'
                % Record and display splitting by thirds
                %1st
                begin_recording = 1;
                stop_recording = max(Range(LFPB2,'s'))/3;
                spectro_window = [0 max(Range(LFPB2,'s'))/3];
            case 'Second'
                %2nd
                begin_recording = max(Range(LFPB2,'s'))/3;
                stop_recording = 2*(max(Range(LFPB2,'s'))/3);
                spectro_window = [max(Range(LFPB2,'s'))/3 2*(max(Range(LFPB2,'s'))/3)];
            case 'Third'
                %3rd
                begin_recording = 2*(max(Range(LFPB2,'s'))/3);
                stop_recording = max(Range(LFPB2,'s'));
                spectro_window = [2*(max(Range(LFPB2,'s'))/3) max(Range(LFPB2,'s'))];
        end
    case 'Arb'
        begin_recording = arb_begin;
        stop_recording = arb_end;
end

switch SS_base
    case '0.1-0.5'
        disp(['You chose ' SS_base ' case'])
        
        Selected_S2 = and(Sleep,Epoch_01_05); %NREM
        Selected_S1 = and(Sleep,TotalEpoch-Epoch_01_05); %REM
        Selected_smooth = smooth_01_05_new;
        
        Selected_Spectro = Spectro_UL;
        Selected_sptsd = sptsdUL;
        Selected_f = fUl;
    case '1-8'
        disp(['You chose ' SS_base ' case'])
        
        Selected_S2 = S2_epoch;
        Selected_S1 = S1_epoch;
        Selected_smooth = smooth_1_8_new;
        
        Selected_Spectro = Spectro_H;
        Selected_sptsd = sptsdH;
        Selected_f = fH;
end

%% Read the video
% if you can't read the video, decode it first, so you become independent of the codec
% ffmpeg -i video_pupil_20230227133559_fixed.avi -vcodec rawvideo raw_camera_video.avi
video = VideoReader('raw_camera_video.avi');
% video = VideoReader('video_pupil_20230227133559_fixed.avi');
frame = read(video, [arb_begin arb_end]);
size(frame,4)
video_time_line = linspace(1, size(frame,4), size(frame,4))';
duration = video.Duration;
frameRate = video.FrameRate;
numFrames = duration * frameRate;

%% Plot figures
figure

% Spectrograms
SpecP_g = subplot(8, 8, 1:4); % spectro Gamma
SpecP_g.Position = [0.05 0.88 0.42  0.12];

SpecP_screw = subplot(8, 8, 17:21); % spectro Cortex
SpecP_screw.Position = [0.05 0.56 0.42 0.12];

SpecP_0105 = subplot(8, 8, 9:12); % spectro 0.1-0.5
SpecP_0105.Position = [0.05 0.72 0.42 0.12];

% Scatters
ScatP_0105 = subplot(8, 8, [55:56,63:64]); % Scatter 0.1-0.5 - Gamma
ScatP_0105.Position = [0.76 0.04 0.18 0.24];
axis square

ScatP_screw = subplot(8, 8, [53:54,61:62]); % Scatter Cortex - Gamma
ScatP_screw.Position = [0.54 0.04 0.18 0.24];
axis square

%% Plot Gamma spectrogram
set(gcf,'CurrentAxes',SpecP_g)

try
    datb=Data(sptsdB);
    for k=1:size(datb,2)
        datbnew(:,k)=runmean(datb(:,k),100);
    end
    set(gcf,'CurrentAxes',SpecP_g)
    imagesc(Range(sptsdB,'s'),fB,10*log10(datbnew')), axis xy, caxis([27 40]);
    colormap('jet')
    ylim([20 100])
    hold on
    line([begin endin],[94 94],'linewidth',10,'color','w')
    sleepstart=Start(Selected_S1); %changed on 26/06 from S2 to S1
    sleepstop=Stop(Selected_S1); %changed on 26/06 from S2 to S1
    for k=1:length(sleepstart)
        line([sleepstart(k)/1e4 sleepstop(k)/1e4],[94 94],'color',[0.4660 0.6740 0.1880],'linewidth',5);
    end
    sleepstart=Start(Selected_S2);%changed on 26/06 from S1 to S2
    sleepstop=Stop(Selected_S2);%changed on 26/06 from S1 to S2
    for k=1:length(sleepstart)
        line([sleepstart(k)/1e4 sleepstop(k)/1e4],[94 94],'color',[1 0.2 0.2],'linewidth',5);
    end
    sleepstart=Start(Wake);
    sleepstop=Stop(Wake);
    for k=1:length(sleepstart)
        line([sleepstart(k)/1e4 sleepstop(k)/1e4],[94 94],'color',[0 0.4470 0.7410],'linewidth',5);
    end
catch
    title('No Middle OB spectrum')
end
ylabel('Frequency (Hz)')
% clim([26 54])
yyaxis right
plot(Range(smooth_ghi,'s'),Data(smooth_ghi),'-k','linewidth',1)
ylim([0 2000])
Gamma_line = line([1 1],ylim,'linewidth',2,'color', [0.6350 0.0780 0.1840]);

line(xlim,[1 1]*gamma_thresh,'linewidth',1.2,'color','r')
ylabel('Gamma power')
set(gca,'FontSize',8)

%% Plot Spectrogram 0.1-0.5
set(gcf,'CurrentAxes',SpecP_0105)

imagesc(Range(Selected_sptsd,'s'),Selected_f,10*log10(Data(Selected_sptsd))'), axis xy;
colormap('jet')
hold on
switch SS_base
    case '0.1-0.5'
        caxis([25 60])
        line_height = [0.95 0.95];
    case '1-8'
        caxis([30 55])
        line_height = [19 19];
end

line([begin endin],line_height,'linewidth',10,'color','w')

% S2
sleepstart=Start(Selected_S1); %changed on 26/06 from S2 to S1
sleepstop=Stop(Selected_S1);%changed on 26/06 from S2 to S1
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],line_height,'color',[0.4660 0.6740 0.1880],'linewidth',5);
end
% S1
sleepstart=Start(Selected_S2);%changed on 26/06 from S1 to S2
sleepstop=Stop(Selected_S2);%changed on 26/06 from S1 to S2
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],line_height,'color',[1 0.2 0.2],'linewidth',5);
end
% Wake
sleepstart=Start(Wake);
sleepstop=Stop(Wake);
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],line_height,'color',[0 0.4470 0.7410],'linewidth',5);
end
% clim([34 62])
ylabel('Frequency (Hz)')
Line_0105 = line([1 1],ylim,'linewidth',2,'color',[0.6350 0.0780 0.1840]);

yyaxis right
% ylim([0 30])
% ylim([0 35])
switch SS_base
    case '0.1-0.5'
        plot(Range(smooth_01_05_new,'s'),Data(smooth_01_05_new),'-k','linewidth',1)
        line(xlim,[1 1]*thresh_01_05,'linewidth',1.5,'color','r')
        ylabel('0.1-0.5 Hz')
    case '1-8'
        plot(Range(smooth_1_8_new,'s'),Data(smooth_1_8_new),'-k','linewidth',1.5)
        line(xlim,[1 1]*OneEight_thresh,'linewidth',2,'color','r')
        ylabel('1-8 Hz')
end
set(gca,'FontSize',8)

%% Plot Screw spectrogram
set(gcf,'CurrentAxes',SpecP_screw)

imagesc(Range(sptsdRef,'s'),fRef,10*log10(Data(sptsdRef))'), axis xy;
colormap('jet')
hold on
caxis([17 35])

line_height = [19 19];
line([begin endin],line_height,'linewidth',10,'color','w')

% S2
sleepstart=Start(REMEpoch);
sleepstop=Stop(REMEpoch);
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],line_height,'color',[0.4660 0.6740 0.1880],'linewidth',5);
end
% S1
sleepstart=Start(SWSEpoch);
sleepstop=Stop(SWSEpoch);
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],line_height,'color',[1 0.2 0.2],'linewidth',5);
end
% Wake
sleepstart=Start(Wake);
sleepstop=Stop(Wake);
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],line_height,'color',[0 0.4470 0.7410],'linewidth',5);
end
% clim([34 62])
ylabel('Frequency (Hz)')
ScrewLine = line([1 1],ylim,'linewidth',2,'color',[0.6350 0.0780 0.1840]);

yyaxis right

plot(Range(smooth_Theta,'s'),Data(smooth_Theta),'-k','linewidth',1)
line(xlim,[1 1]*theta_thresh,'linewidth',1.5,'color','r')
ylabel('screw')

set(gca,'FontSize',8)

xlabel('Time (s)')

%% Plot screw - Gamma scatter
set(gcf,'CurrentAxes',ScatP_screw)

%S2
plot(log(Data(Restrict(smooth_ghi,SWSEpoch))),log(Data(Restrict(smooth_Theta,SWSEpoch))),'.','color',[1 0.6 0.6],'MarkerSize',3);
hold on
%S1
plot(log(Data(Restrict(smooth_ghi,REMEpoch))),log(Data(Restrict(smooth_Theta,REMEpoch))),'.','color',[0.76 0.87 0.38],'MarkerSize',3);
%Wake
plot(log(Data(Restrict(smooth_ghi,Wake))),log(Data(Restrict(smooth_Theta,Wake))),'.','color',[0.6 0.6 1],'MarkerSize',3);
%Trace
Worm_screw = plot(log(Data(Restrict(smooth_ghi,intervalSet(5*1e4,15*1e4)))),log(Data(Restrict(smooth_Theta,intervalSet(5*1e4,15*1e4)))),'linewidth',2,'color',[0.6350 0.0780 0.1840]);

%% Plot 0.1-0.5 - Gamma scatter
set(gcf,'CurrentAxes',ScatP_0105)

%S1
%changed on 26/06 from S1 to S2
plot(log(Data(Restrict(smooth_ghi_new,Selected_S2))),log(Data(Restrict(Selected_smooth,Selected_S2))),'.','color',[1 0.6 0.6],'MarkerSize',3);
hold on
%S2
%changed on 26/06 from S2 to S1
plot(log(Data(Restrict(smooth_ghi_new,Selected_S1))),log(Data(Restrict(Selected_smooth,Selected_S1))),'.','color',[0.76 0.87 0.38],'MarkerSize',3);
%Wake
plot(log(Data(Restrict(smooth_ghi_new,Wake))),log(Data(Restrict(Selected_smooth,Wake))),'.','color',[.6 .6 1],'MarkerSize',3);
%Trace
Worm_0105 = plot(log(Data(Restrict(smooth_ghi_new,intervalSet(5*1e4,15*1e4)))),log(Data(Restrict(Selected_smooth,intervalSet(5*1e4,15*1e4)))),'linewidth',2,'color',[0.6350 0.0780 0.1840]);

%% Make it pretty
for i = 1:2
    if i == 1
        set(gcf,'CurrentAxes',ScatP_0105)
    elseif i == 2
        set(gcf,'CurrentAxes',ScatP_screw)
    end
    try
        legend('S2','S1','Wake')
        l=findobj(gcf,'tag','legend');
        a=get(l,'children');
        try
            set(a(1),'markersize',20); % This line changes the legend marker size
            set(a(4),'markersize',20); % This line changes the legend marker size
            set(a(7),'markersize',20); % This line changes the legend marker size
        catch
            set(a(5),'markersize',20); % This line changes the legend marker size
            set(a(8),'markersize',20); % This line changes the legend marker size
            set(a(11),'markersize',20); % This line changes the legend marker size
        end
    catch
        [a,icons,plots,legend_text]=legend('S2','S1','Wake');
        set(icons(5),'MarkerSize',20)
        set(icons(7),'MarkerSize',20)
        set(icons(9),'MarkerSize',20)
    end
    xlabel('OB Gamma Power')
    if i == 1
        switch SS_base
            case '0.1-0.5'
                ylabel('0.1-0.5 Hz power')
            case '1-8'
                ylabel('1-8 Hz power')
        end
    elseif i == 2
        ylabel('screw delta power')
    end
    
    set(gca,'FontSize',8)
end

%% Plot LFP traces

% Cortex LFP
plot_cortex_lfp = subplot(8, 8, 5:8);
plot(Range(LFP_screw,'s'),Data(LFP_screw),'k','color',[0 0.5 0.5])
plot_cortex_lfp.Position = [0.52 0.93 0.43 0.07];
Line_1 = line([1 1],ylim,'linewidth',2,'color',[0.6350 0.0780 0.1840]);
ylim([median(Data(LFP_screw))-800 median(Data(LFP_screw))+800])
title('Screw LFP (1ch)')

% OB (24th) LFP
plot_OB_lfp = subplot(8, 8, 13:16);
plot(Range(LFPB2,'s'),Data(LFPB2),'k', 'color',[0 0.5 0.5])
plot_OB_lfp.Position = [0.52 0.81 0.43 0.07];
Line_2 = line([1 1],ylim,'linewidth',2,'color',[0.6350 0.0780 0.1840]);
ylim([median(Data(LFPB2))-4e3 median(Data(LFPB2))+4e3])
title('OB LFP (24ch)')

% EMG LFP (12th channel at the moment; to switch for the 19th channel use LFP_EMG_2)
plot_EMG = subplot(8, 8, 21:24);
plot(Range(LFP_EMG_1,'s'),Data(LFP_EMG_1),'k','color',[0.6 0 0])
plot_EMG.Position = [0.52 0.69 0.43 0.07];
Line_3 = line([1 1],ylim,'linewidth',2,'color',[0.6350 0.0780 0.1840]);
ylim([median(Data(LFP_EMG_1))-500 median(Data(LFP_EMG_1))+500])
title('EMG LFP (12ch)')

% Nostril velocity x
plot_nostril_velocity_x = subplot(8, 8, 29:32);
plot_nostril_velocity_x.Position = [0.52 0.57 0.43 0.07];
clear temp; temp = runmean_BM(sqrt(zscore(velocity_nostril_center(:, 1))), 4);
area(time, temp, 'FaceColor',[0.8 0.2 0], 'FaceAlpha', 0.3);
% xlim([4280 4300])
ylim([0 max(temp)])
Line_4 = line([1 1],ylim,'linewidth',2,'color',[0.6350 0.0780 0.1840]);
title('Nostril Velocity_x')

% Pupil velocity x
plot_pupil_velocity_x = subplot(8, 8, 37:40);
plot_pupil_velocity_x.Position =  [0.52 0.45 0.43 0.07];
clear temp; temp = runmean_BM(sqrt(zscore(velocity_pupil_center(:, 1))), 4);
area(time, temp, 'FaceColor',[0.4 0.5 0], 'FaceAlpha', 0.3);
% xlim([20 40])
ylim([0 max(temp)])
Line_5 = line([1 1],ylim,'linewidth',2,'color',[0.6350 0.0780 0.1840]);
title('Pupil Velocity_x')

% Pupil and eye areas
plot_pupil_eye_area = subplot(8, 8, 45:48);
plot_pupil_eye_area.Position = [0.52 0.33 0.43 0.07];
normalized_pupil_area = (areas_pupil - min(areas_pupil))/(max(areas_pupil)-min(areas_pupil));
normalized_eye_area = (areas_eye - min(areas_eye))/(max(areas_eye)-min(areas_eye));
clear temp; temp = runmean_BM(normalized_eye_area, 10);
area(time, temp, 'FaceColor',[0.2 0.5 0.5], 'FaceAlpha', .2);
hold on
clear temp; temp = runmean_BM(normalized_pupil_area, 10);
area(time, temp, 'FaceColor',[0.7 0.5 0], 'FaceAlpha', .2);
hline(median(normalized_pupil_area), 'r--', 'pupil mean')
Line_6 = line([1 1],ylim,'linewidth',2,'color',[0.6350 0.0780 0.1840]);
hold off
title('Eye and Pupil area')
legend({'eye area';'pupil area'})
% xlim([3800 4400])
xlabel('time, sec')

LFP_lines = [Line_1 Line_2 Line_3 Line_4 Line_5 Line_6]';

%% Plot DLC video

plot_DLC_video = subplot(8, 8, [33:36, 41:44, 49:52]);
imshow(frame(:, :, :, video_time_line(1)))
plot_DLC_video.Position = [0.012 0 0.5 0.5]; %0227

%% Removed from the figure
% % Pupil center x
% plot_pupil_center_x = subplot(8, 6, 39:42);
% plot_pupil_center_x.Position = [0.44 0.15 0.51 0.075];
% % plot(time, pupil_center(:, 1),'k','color',[0.6 0 0])
% clear temp; temp = runmean_BM(zscore(pupil_center(:, 1)), 40);
% area(time, temp, 'FaceColor',[0.4 0.5 0], 'FaceAlpha', 0.3);
% % xlim([1000 8000])
% ylim([median(zscore(pupil_center(:, 1)))-5.5 median(zscore(pupil_center(:, 1)))+5.5])
% Line_5 = line([1 1],ylim,'linewidth',2,'color','k');
% title('Pupil Center_x')

% % Accelero LFP
% plot_accelero = subplot(8, 6, 21:24);
% clear A, A=log(Data(MovAcctsd)); A(A==-Inf)=15; A = runmean_BM(A , ceil(.05/median(diff(Range(MovAcctsd,'s')))));
% B=runmean_BM(A , ceil(3/median(diff(Range(MovAcctsd,'s')))));
% A=(A-min(B)); A=A/max(B);
% area(Range(MovAcctsd,'s'),A*8, 'FaceColor', [0.6 0 0])
% u=hline((log(Immobility_thresh)-min(B))/max(B) , '--k'); u.LineWidth = 4;
% plot_accelero.Position = [0.44 0.51 0.51 0.075];
% title('Accelerometer')
% plot(Range(LFP_vtrig, 's'), Data(LFP_vtrig))
% hold on
% LFPLine1 = line([1 1],ylim,'linewidth',2,'color','k');
%
% Line_8 = line([1 1],ylim,'linewidth',2,'color','k');

%% Link axes
ax_lfp = [plot_cortex_lfp; plot_OB_lfp; plot_EMG];
ax_dlc = [plot_pupil_eye_area; plot_pupil_velocity_x; plot_nostril_velocity_x];
linkaxes(ax_lfp, 'x');
linkaxes(ax_dlc, 'x');

figure_title = suptitle(['Composition video of the session ' date]);

%% clear RAM
% clearvars('-except', 'vid_name', 'begin_recording', 'stop_recording', 'time',...
% 'ScatP_screw', 'Worm_screw', 'smooth_ghi', 'smooth_Theta', 'REMEpoch', 'SWSEpoch', 'Wake',...
% 'ScatP_0105', 'Worm_0105', 'smooth_ghi_new', 'Selected_smooth', 'Selected_S1', 'Selected_S2',...
% 'SpecP_g', 'Gamma_line', 'SpecP_0105', 'Line_0105', 'SpecP_screw', 'ScrewLine','ax_lfp', 'LFP_lines', 'ax_dlc',...
% 'plot_DLC_video', 'frame', 'video_time_line', 'arb_begin')

%% Record the video

% check the real number of frames in the video (takes some time)
% ffmpeg -i video.avi -map 0:v:0 -c copy -f null -

writerObj = VideoWriter(vid_name);
writerObj.FrameRate = 10;
writerObj.Quality = 100;

open(writerObj);

State= {'S1','S2','Wake'};
clear j k; j = 1;
for k = begin_recording : stop_recording
    
    CentreValue = time(k);
    
    %% worm in Scatter cortex
    set(gcf,'CurrentAxes',ScatP_screw)
    set(Worm_screw,'XData',runmean(log(Data(Restrict(smooth_ghi,intervalSet((CentreValue-4)*1e4,(CentreValue+4)*1e4)))),3),...
        'YData',runmean(log(Data(Restrict(smooth_Theta,intervalSet((CentreValue-4)*1e4,(CentreValue+4)*1e4)))),3));
    
    LitEpoch = intervalSet((CentreValue-4)*1e4,(CentreValue+4)*1e4);
    REM_overlap = sum(Stop(and(LitEpoch,REMEpoch))-Start(and(LitEpoch,REMEpoch)));
    if isempty(REM_overlap), REM_overlap = 0; end
    SWS_overlap = sum(Stop(and(LitEpoch,SWSEpoch))-Start(and(LitEpoch,SWSEpoch)));
    if isempty(SWS_overlap), SWS_overlap = 0; end
    Wake_overlap = sum(Stop(and(LitEpoch,Wake))-Start(and(LitEpoch,Wake)));
    if isempty(Wake_overlap), Wake_overlap = 0; end
    [val,ind] = max([REM_overlap,SWS_overlap,Wake_overlap]);
    
    %% worm in Scatter 0105
    set(gcf,'CurrentAxes',ScatP_0105)
    set(Worm_0105,'XData',runmean(log(Data(Restrict(smooth_ghi_new,intervalSet((CentreValue-4)*1e4,(CentreValue+4)*1e4)))),3),...
        'YData',runmean(log(Data(Restrict(Selected_smooth,intervalSet((CentreValue-4)*1e4,(CentreValue+4)*1e4)))),3));
    
    LitEpoch = intervalSet((CentreValue-4)*1e4,(CentreValue+4)*1e4);
    S1_overlap = sum(Stop(and(LitEpoch,Selected_S1))-Start(and(LitEpoch,Selected_S1)));
    if isempty(S1_overlap), S1_overlap = 0; end
    S2_overlap = sum(Stop(and(LitEpoch,Selected_S2))-Start(and(LitEpoch,Selected_S2)));
    if isempty(S2_overlap), S2_overlap = 0; end
    Wake_overlap = sum(Stop(and(LitEpoch,Wake))-Start(and(LitEpoch,Wake)));
    if isempty(Wake_overlap), Wake_overlap = 0; end
    [val,ind] = max([S1_overlap,S2_overlap,Wake_overlap]);
    
    %% Gamma Spectrogram
    set(gcf,'CurrentAxes',SpecP_g)
    xlim([CentreValue-300 CentreValue+300])
    set(Gamma_line,'XData',[CentreValue CentreValue])
    title(State{ind})
    
    %% 0105 Spectrogram
    set(gcf,'CurrentAxes',SpecP_0105)
    xlim([CentreValue-300 CentreValue+300])
    set(Line_0105,'XData',[CentreValue CentreValue])
    
    %% Screw Spectrogram
    set(gcf,'CurrentAxes',SpecP_screw)
    xlim([CentreValue-300 CentreValue+300])
    set(ScrewLine,'XData',[CentreValue CentreValue])
    
    %% LFPs
    set(gcf,'CurrentAxes',ax_lfp)
    xlim([CentreValue-2 CentreValue+2])
    set(LFP_lines,'XData',[CentreValue CentreValue])
    
    %% DLCs
    set(gcf,'CurrentAxes',ax_dlc)
    xlim([CentreValue-45 CentreValue+45])
    %     xlim([CentreValue-5 CentreValue+5])
    
    set(LFP_lines,'XData',[CentreValue CentreValue])
    
    %% Video
    set(gcf, 'CurrentAxes', plot_DLC_video)
    imshow(frame(:, :, :, video_time_line(j)));
    drawnow;
    
    disp(['video frame ' num2str(arb_begin+video_time_line(j)-1)])
    disp(['dlc frame ' num2str(k)])
    disp(['video time ' num2str(video.CurrentTime)])
    disp(['dlc time ' num2str(time(k))])
    j = j + 1;
    
    %     disp(time(k)-time_1st_trig)
    %     disp(['mismatch between the video and the timer ' num2str(video.CurrentTime - (time(k)-time_1st_trig))])
    
    writeVideo(writerObj,getframe(gcf));
    
end
close(writerObj);

end

