
%% beautiful example on Labneh
clear all

cd('/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230227/')
load('SleepScoring_OBGamma.mat', 'Wake' , 'Sleep' , 'TotalNoiseEpoch')
Wake = Wake-TotalNoiseEpoch;

load('B_Middle_Spectrum.mat')
Stsd = tsd(Spectro{2}*1e4 , log10(Spectro{1}));
f = Spectro{3};

load('LFPData/LFP35.mat')
Fil_LFP = FilterLFP(LFP,[.3 2],1024);
Phase=tsd(Range(Fil_LFP) , angle(hilbert(zscore(Data(Fil_LFP))))*180/pi+180);
Phase_Above_350=thresholdIntervals(Phase,350,'Direction','Above');
Sniff=ts((Stop(Phase_Above_350)+Start(Phase_Above_350))/2);
Sniff_Wake = Restrict(Sniff,Wake);
Sniff_Sleep = Restrict(Sniff,Sleep);


figure
subplot(3,2,[1 3])
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Wake,50,250,0,.7,1);
imagesc(t/1E3,f,SmoothDec(M,2)), axis xy
xlim([-5 5]), ylim([30 100]), caxis([3.5 6.2]), ylabel('Frequency (Hz)'), vline(0,'--r')
title('Wake')

subplot(325)
plot(t/1E3, nanmean(M) , 'k' , 'LineWidth' , 2), xlim([-5 5])
xlabel('Time (s)'), ylabel('Power (log)')
ylim([4.1 4.9]), vline(0,'--r')

subplot(3,2,[2 4])
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Sleep,50,250,0,5,1);
imagesc(t/1E3,f,SmoothDec(M,.7)), axis xy
xlim([-5 5]), ylim([30 100]), caxis([3.5 6.2]), vline(0,'--r')
title('Sleep')

subplot(3,2,6)
plot(t/1E3, nanmean(M) , 'k' , 'LineWidth' , 2), xlim([-5 5])
xlabel('Time (s)')
ylim([4.1 4.9]), vline(0,'--r')

colormap jet



%% same ferret, different wire
load('B_Middle_Spectrum_26.mat')
Stsd = tsd(Spectro{2}*1e4 , log10(Spectro{1}));


figure
subplot(3,2,[1 3])
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Wake,50,250,0,.7,1);
imagesc(t/1E3,f,SmoothDec(M,2)), axis xy
xlim([-5 5]), ylim([30 100]), caxis([2.5 5]), ylabel('Frequency (Hz)')
title('Wake'), vline(0,'--r')
makepretty

subplot(325)
plot(t/1E3, nanmean(M) , 'k' , 'LineWidth' , 2), xlim([-5 5])
xlabel('Time (s)'), ylabel('Power (log)')
makepretty, ylim([1.9 3.5]), vline(0,'--r')

subplot(3,2,[2 4])
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Sleep,50,250,0,5,1);
imagesc(t/1E3,f,SmoothDec(M,.7)), axis xy
xlim([-5 5]), ylim([30 100]), caxis([2.5 5]), vline(0,'--r')
makepretty
title('Sleep')

subplot(3,2,6)
plot(t/1E3, nanmean(M) , 'k' , 'LineWidth' , 2), xlim([-5 5])
xlabel('Time (s)')
makepretty, ylim([1.9 3.5]), vline(0,'--r')

colormap jet



%% different ferret
clear all
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241211_TORCs/')

load('LFPData/LFP105.mat')
load('SleepScoring_OBGamma.mat', 'Wake', 'Sleep' , 'TotalNoiseEpoch')
Wake = Wake-TotalNoiseEpoch;

load('B_Middle_Spectrum.mat')

Fil_LFP = FilterLFP(LFP,[.3 2],1024);
Phase=tsd(Range(Fil_LFP) , angle(hilbert(zscore(Data(Fil_LFP))))*180/pi+180);
Phase_Above_350=thresholdIntervals(Phase,350,'Direction','Above');
Sniff=ts((Stop(Phase_Above_350)+Start(Phase_Above_350))/2);
Sniff_Wake = Restrict(Sniff,Wake);
Sniff_Sleep = Restrict(Sniff,Sleep);

Stsd = tsd(Spectro{2}*1e4 , log10(Spectro{1}));
f = Spectro{3};

figure
subplot(3,2,[1 3])
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Wake,50,250,0,.7,1);
imagesc(t/1E3,f,SmoothDec(M,2)), axis xy
xlim([-5 5]), ylim([20 100]), caxis([4.2 4.8]), ylabel('Frequency (Hz)'), vline(0,'--r')
title('Wake')
makepretty

subplot(325)
plot(t/1E3, movmean(nanmean(M([1:65],:)),5) , 'k' , 'LineWidth' , 2), xlim([-5 5])
xlabel('Time (s)'), ylabel('Mod. (a.u.)')
makepretty, ylim([4.25 4.55]), vline(0,'--r')

subplot(3,2,[2 4])
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Sleep,50,250,0,5,1);
imagesc(t/1E3,f,SmoothDec(M,.7)), axis xy
xlim([-5 5]), ylim([30 100]), caxis([4 5.2]), vline(0,'--r')
makepretty
title('Sleep')

subplot(326)
plot(t/1E3, movmean(nanmean(M([1:65],:)),5) , 'k' , 'LineWidth' , 2), xlim([-5 5])
xlabel('Time (s)')
makepretty, ylim([3.85 4.25]), vline(0,'--r')

colormap jet




%% for delta frequencies
clear all
cd('/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230227/')
load('SleepScoring_OBGamma.mat', 'Wake','Sleep' , 'TotalNoiseEpoch')

load('LFPData/LFP35.mat')
Fil_LFP = FilterLFP(LFP,[.3 2],1024);
Phase=tsd(Range(Fil_LFP) , angle(hilbert(zscore(Data(Fil_LFP))))*180/pi+180);
Phase_Above_350=thresholdIntervals(Phase,350,'Direction','Above');
Sniff=ts((Stop(Phase_Above_350)+Start(Phase_Above_350))/2);
Sniff_Wake = Restrict(Sniff,Wake);
Sniff_Sleep = Restrict(Sniff,Sleep);

load('B_Low_Spectrum_26.mat')
Stsd = tsd(Spectro{2}*1e4 , log10(Spectro{1}));
Stsd = CleanSpectro(Stsd , Spectro{3} , 3);
f = Spectro{3};

figure
subplot(3,2,[1 3])
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Wake,50,250,0,.7,1);
imagesc(t/1E3,f,SmoothDec(M,2)), axis xy
xlim([-5 5]), ylim([.5 10]), caxis([5 7]), ylabel('Frequency (Hz)')
title('Wake'), vline(0,'--r')

subplot(325)
plot(t/1E3, nanmean(M) , 'k' , 'LineWidth' , 2), xlim([-5 5])
xlabel('Time (s)'), ylabel('Power (log)')
ylim([4.3 4.45]), vline(0,'--r')

subplot(3,2,[2 4])
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Sleep,50,250,0,5,1);
imagesc(t/1E3,f,smooth2a(M,5,5)), axis xy
xlim([-5 5]), ylim([0 10]), caxis([5 7]), vline(0,'--r')
title('Sleep')

subplot(326)
plot(t/1E3, nanmean(M) , 'k' , 'LineWidth' , 2), xlim([-5 5])
xlabel('Time (s)')
ylim([4 4.2]), vline(0,'--r')

colormap jet


%% different wire
load('B_Low_Spectrum_26.mat')
Stsd = tsd(Spectro{2}*1e4 , log10(Spectro{1}));


figure
subplot(3,2,[1 3])
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Wake,50,250,0,.7,1);
imagesc(t/1E3,f,SmoothDec(M,2)), axis xy
xlim([-5 5]), ylim([.5 10]), caxis([4.5 7]), ylabel('Frequency (Hz)')
title('Wake')
makepretty

subplot(325)
plot(t/1E3, nanmean(M) , 'k' , 'LineWidth' , 2), xlim([-5 5])
xlabel('Time (s)'), ylabel('Power (log)')
makepretty, ylim([3.8 4.5])

subplot(3,2,[2 4])
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Sleep,50,250,0,5,1);
imagesc(t/1E3,f,smooth2a(M,5,5)), axis xy
xlim([-5 5]), ylim([0 10]), caxis([4.5 7])
makepretty
title('Sleep')

subplot(326)
plot(t/1E3, nanmean(M) , 'k' , 'LineWidth' , 2), xlim([-5 5])
xlabel('Time (s)')
makepretty, ylim([3.8 4.5])

colormap jet


%%
load('B_Middle_Spectrum.mat')
Stsd = tsd(Spectro{2}*1e4 , log10(Spectro{1}));
f = Spectro{3};

figure
subplot(221)
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Wake,50,250,0,.7,1);
imagesc(t/1E3,f,SmoothDec(M,2)), axis xy
xlim([-5 5]), ylim([30 100]), caxis([4.5 6]), ylabel('Frequency (Hz)'), vline(0,'--r')
title('Wake')
makepretty
caxis([3.5 6.2])

subplot(222)
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Sleep,50,250,0,.7,1);
imagesc(t/1E3,f,SmoothDec(M,2)), axis xy
xlim([-5 5]), ylim([30 100]), caxis([4.4 4.7]), vline(0,'--r')
title('Sleep')
makepretty
caxis([3.5 6.2])


load('B_Low_Spectrum_26.mat')
Stsd = tsd(Spectro{2}*1e4 , log10(Spectro{1}));
f = Spectro{3};

subplot(223)
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Wake,50,250,0,.7,1);
imagesc(t/1E3,f,SmoothDec(M,2)), axis xy
xlim([-5 5]), ylim([.5 10]), caxis([6.45 6.6]), xlabel('Time (s)'), ylabel('Frequency (Hz)'), vline(0,'--r')
makepretty
caxis([5.5 6.5])

subplot(224)
[M,~,t]=AverageSpectrogram(Stsd,f,Sniff_Sleep,50,250,0,.7,1);
imagesc(t/1E3,f,SmoothDec(M,2)), axis xy
xlim([-5 5]), ylim([.5 10]), caxis([5.8 6]), xlabel('Time (s)'), vline(0,'--r')
makepretty
caxis([5.5 7])

colormap jet



%% spikes
% Sniff = Detect_Sniff_From_Piezzo(LFP);
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241205_TORCs')
load('SleepScoring_OBGamma.mat', 'Sniff', 'spikes_OB' , 'Wake' , 'Sleep' , 'TotalNoiseEpoch')
Wake = Wake-TotalNoiseEpoch;

% Parameters
binSize = 0.1; % seconds
win = 5;      % seconds
edges = -win:binSize:win;
binCenters = edges(1:end-1) + binSize/2;


% Get event times in seconds
ts1 = Range(Restrict(Sniff , Wake)) / 1e4;
ts2 = Range(Restrict(spikes_OB , Wake)) / 1e4;


% -------- Cross-correlation ts1 vs ts2 --------
ccg_counts = zeros(size(edges)-[0 1]);
for i = 1:length(ts1)
    diffs = ts2 - ts1(i);
    diffs = diffs(abs(diffs) <= win);
    ccg_counts = ccg_counts + histcounts(diffs, edges);
end


% -------- Plot results --------
figure
subplot(121)
bar(binCenters, ccg_counts, 1, 'FaceColor',[0 0 1],'FaceAlpha',.7)
xlabel('Time lag (s)'); ylabel('Count')
title('Wake')
xlim([-5 5])


% Get event times in seconds
ts1 = Range(Restrict(Sniff , Sleep)) / 1e4;
ts2 = Range(Restrict(spikes_OB , Sleep)) / 1e4;


% -------- Cross-correlation ts1 vs ts2 --------
ccg_counts = zeros(size(edges)-[0 1]);
for i = 1:length(ts1)
    diffs = ts2 - ts1(i);
    diffs = diffs(abs(diffs) <= win);
    ccg_counts = ccg_counts + histcounts(diffs, edges);
end


subplot(122)
bar(binCenters, ccg_counts, 1, 'FaceColor',[.3 .3 .3],'FaceAlpha',.7)
xlabel('Time lag (s)')
title('Sleep')
xlim([-5 5])

