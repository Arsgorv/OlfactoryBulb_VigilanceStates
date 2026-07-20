

% if you want to generate check  edit MeanSpectrums_AllFerret_Sleep_BM.m


load('/media/nas8/OB_ferret_AG_BM/DataFerret/MeanSpectrums_FM.mat')

Cols={[.2 .2 .8],[1 .5 0],[.8 .2 .2],[.2 .8 .2],[.8 .2 .2]};
ferret=3;


figure
n=1;
for m=[3 2]
    subplot(1,2,n)
    for states=[1 5 4]
        
        Data_to_use = Mean_Spec_all{ferret}{m}{states};
        Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
        h=shadedErrorBar(Range_Low , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
        color= Cols{states}; h.mainLine.Color=color; h.patch.FaceColor=color; h.edge(1).Color=color; h.edge(2).Color=color;
        
    end
    xlabel('Frequency (Hz)')
    if n==1; ylabel('Power (a.u.)'), f=get(gca,'Children'); legend([f(5),f(3),f(1)],'Wake','NREM','REM'); elseif m==5, ylabel('power (log scale)'), end
    if n==1, title('HPC'), end
    if n==2, title('PFC'), end
    xlim([0 10])
    makepretty
    
    n=n+1;
end




%% Spectrograms HPC/PFC
clear all

path = '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs/';
smootime = 10;
LineHeight = 9.5;
Colors.IS = [1 .5 0];
Colors.SWS = [.8 .2 .2];
Colors.REM = [.2 .8 .2];
Colors.Wake = [.2 .2 .8];
Colors.Noise = 'k';


% spectro
H = load([path filesep 'H_Low_Spectrum.mat']);
H_Sptsd = tsd(H.Spectro{2}*1e4 , H.Spectro{1});

P = load([path filesep 'PFCx_Low_Spectrum.mat']);
P_Sptsd = tsd(P.Spectro{2}*1e4 , P.Spectro{1});

load([path filesep 'SleepScoring_OBGamma.mat'])

load('ChannelsToAnalyse/PFCx_deltadeep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
Fil_Delta = FilterLFP(LFP,[.5 4],1024);
tEnveloppe = tsd(Range(Fil_Delta), abs(hilbert(Data(Fil_Delta))) );
SmoothDelta  = tsd(Range(tEnveloppe), runmean(Data(tEnveloppe), ...
    ceil(smootime/median(diff(Range(tEnveloppe,'s'))))));


figure
subplot(411) % HPC
R = Range(H_Sptsd); D = Data(H_Sptsd);
imagesc(R(1:10:end)/3.6e7 , H.Spectro{3} , runmean(runmean(log10(D(1:10:end,:)'),5)',5)'), axis xy
ylabel('Frequency (Hz)'), ylim([0 10]), caxis([3.5 5]), xticklabels({''}), %xlim([0 3.3])
makepretty

PlotPerAsLine(Wake,9.5,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,9.5,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(or(SWSEpoch , ISEpoch),9.5,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(412)
clear R D, D = movmean(Data(SmoothTheta),1e4,'omitnan'); D(D>14.5) = NaN; D = D(1:100:end); R = Range(SmoothTheta); R = R(1:100:end);
plot(R(1:100:end)/3.6e7 , D(1:100:end) , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)]), ylim([0 15]),%xlim([0 3.3])
ylabel('Theta power (a.u.)'), xticklabels({''})
makepretty

subplot(413) % OB Low 
R = Range(P_Sptsd); D = Data(P_Sptsd);
imagesc(R(1:10:end)/3.6e7 , H.Spectro{3} , runmean(runmean(log10(D(1:10:end,:)'),5)',5)'), axis xy
ylabel('Frequency (Hz)'), ylim([0 10]), xticklabels({''}), %xlim([0 3.3])
caxis([3.5 4.8])
makepretty

PlotPerAsLine(Wake,LineHeight,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,LineHeight,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(or(SWSEpoch , ISEpoch),LineHeight,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(414)
CleanSleep = Sleep-intervalSet([1.485 3.3 3.985]*3.6e7,[1.495 3.345 4.3]*3.6e7);
clear R D, D = movmean(Data(Restrict(SmoothDelta , CleanSleep)),1e4,'omitnan'); D = D(1:100:end); R = Range(Restrict(SmoothDelta , CleanSleep)); R = R(1:100:end);
plot(R(1:100:end)/3.6e7 , D(1:100:end) , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)])
xlabel('Time (hours)'), ylabel('Delta power (a.u.)'), ylim([0 1100]), %xlim([0 3.3])
makepretty

colormap viridis



%% OB only
Cols={[.2 .2 .8],[1 .5 0],[.8 .2 .2],[.2 .8 .2],[.8 .2 .2]};
ferret=3;


figure, m=5;
subplot(121)
for states=[1 5 4]
    Data_to_use = Mean_Spec_all{ferret}{m}{states};
    Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
    h=shadedErrorBar(Range_Middle , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
    color= Cols{states}; h.mainLine.Color=color; h.patch.FaceColor=color; h.edge(1).Color=color; h.edge(2).Color=color;
end
xlabel('Frequency (Hz)'), ylabel('Power (a.u.)'), xlim([20 100]), ylim([1.7 3.5])
f=get(gca,'Children'); legend([f(5),f(3),f(1)],'Wake','NREM','REM');
makepretty
vline([40 60],'--r'), vline([50 75],'-k')

% subplot(122)
% for states=[5 4]
%     Data_to_use = Mean_Spec_all{ferret}{m}{states};
%     Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
%     h=shadedErrorBar(Range_Middle , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
%     color= Cols{states}; h.mainLine.Color=color; h.patch.FaceColor=color; h.edge(1).Color=color; h.edge(2).Color=color;
% end
% xlabel('Frequency (Hz)'), ylabel('Power (a.u.)'), xlim([30 90]), ylim([2 2.8])
% makepretty
% 

%% Spectro OB only
clear all

path = '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs/';
smootime = 30;
LineHeight = 9.5;
Colors.SWS = [.8 .2 .2];
Colors.REM = [.2 .8 .2];
Colors.Wake = [.2 .2 .8];
Colors.Noise = 'k';


% spectro
B = load([path filesep 'B_Middle_Spectrum.mat']);
B_Sptsd = tsd(B.Spectro{2}*1e4 , B.Spectro{1});

load([path filesep 'SleepScoring_OBGamma.mat'])


figure
subplot(411) % OB 40-60
R = Range(B_Sptsd); D = Data(B_Sptsd);
imagesc(R(1:10:end)/3.6e7 , B.Spectro{3} , runmean(runmean(log10(D(1:10:end,:)'),5)',5)'), axis xy
ylabel('Frequency (Hz)'), ylim([20 100]), caxis([2.5 4]), xticklabels({''}), %xlim([0 3.3])
makepretty

PlotPerAsLine(Wake,97,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,97,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(or(SWSEpoch , ISEpoch),97,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(412)
clear R D, D = movmean(log10(Data(SmoothGamma)),1e4,'omitnan'); D(D>14.5) = NaN; D = D(1:100:end); R = Range(SmoothGamma); R = R(1:100:end);
plot(R(1:100:end)/3.6e7 , D(1:100:end) , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothGamma,'s')/3.6e3)]), ylim([2 3]), %xlim([0 3.3])
ylabel('40-60Hz power (log)'), xticklabels({''})
makepretty

subplot(413) % OB Low 
clear D R, D = Data(B_Sptsd); D = D(1:100:end,:); R = Range(B_Sptsd); R = R(1:100:end);
imagesc(R/3.6e7 , B.Spectro{3} , runmean(runmean(log10(D'),2)',50)'), axis xy
ylabel('Frequency (Hz)'), ylim([40 90]), xticklabels({''}), %xlim([0 3.3])
caxis([2.45 2.6])
makepretty

PlotPerAsLine(Wake,87,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,87,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(or(SWSEpoch , ISEpoch),87,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(414)
CleanSleep = Sleep-intervalSet([1.485 3.3 3.985]*3.6e7,[1.495 3.345 4.3]*3.6e7);
clear R D, D = movmean(Data(Restrict(SmoothGamma_wide , CleanSleep)),1e4,'omitnan'); D = D(1:100:end); R = Range(Restrict(SmoothGamma_wide , CleanSleep)); R = R(1:100:end);
plot(R(1:100:end)/3.6e7 , D(1:100:end) , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothGamma_wide,'s')/3.6e3)])
xlabel('Time (hours)'), ylabel('50-75Hz power (log)'), ylim([130 210]), %xlim([0 3.3])
makepretty

colormap viridis

