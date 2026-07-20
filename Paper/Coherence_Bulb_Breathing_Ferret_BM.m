

load([pwd filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
LFP_bulb = LFP;

load('LFPData/LFP105.mat')
D_zsc = zscore_sliding(Data(LFP) , 1250*5);
D_zsc_tsd = tsd(Range(LFP) , D_zsc);
LFP_piezzo = FilterLFP(D_zsc_tsd , [.3 2]);

params.Fs=1/median(diff(Range(LFP_bulb,'s')));
params.tapers=[3 5];
params.fpass=[0.1 20];
params.err=[2,0.05];
params.pad=0;
movingwin=[3 0.2];

[Ctemp,phi,S12,S1temp,S2temp,t,f,confC,phitemp,Cerr] = cohgramc(Data(LFP_bulb) , Data(LFP_piezzo) , movingwin , params);



figure
subplot(211)
imagesc(t/60 , f , Ctemp'), axis xy
colormap viridis, colorbar
xlabel('Time (min)'), ylabel('Frequency (Hz)'), ylim([0 10])
freezeColors

subplot(212)
imagesc(t/60 , f , phi'), axis xy
colormap redblue, colorbar
xlabel('Time (min)'), ylabel('Frequency (Hz)')


load('SleepScoring_OBGamma.mat', 'SmoothGamma')

figure
plot(t , runmean(nanmean(Ctemp(:,1:16) , 2) , 40))
ylabel('Coherence Piezzo-Bulb')
yyaxis right
plot(Range(SmoothGamma , 's') , runmean(Data(SmoothGamma) , 1e4))
ylim([100 450])
xlabel('Time (s)'), ylabel('Smooth Gamma')


load('SleepScoring_OBGamma.mat', 'Wake' , 'Sleep' , 'REMEpoch')
Coh_tsd = tsd(t*1e4 , nanmean(Ctemp(:,1:13) , 2));
Coh_Wake = Restrict(Coh_tsd , Wake);
Coh_Sleep = Restrict(Coh_tsd , Sleep);
Coh_REM = Restrict(Coh_tsd , REMEpoch);

figure
b{1}=bar(1,nanmean(Data(Coh_Wake)),'FaceColor','b','FaceAlpha',.7); hold on
b{2}=bar(2,nanmean(Data(Coh_Sleep)),'FaceColor','k','FaceAlpha',.7);
b{3}=bar(3,nanmean(Data(Coh_REM)),'FaceColor','g','FaceAlpha',.7);
xticks([1:3]), xticklabels({'Wake','Sleep','REM'}), ylabel('Coherence (a.u.)')
ylim([.4 .6])
box off



