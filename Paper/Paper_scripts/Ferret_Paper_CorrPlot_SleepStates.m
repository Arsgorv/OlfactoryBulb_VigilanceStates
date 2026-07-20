
clear all
% pwd = '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241205_TORCs';
pwd = '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20250103_LSP_saline';
smootime = 10;


%%
load([pwd filesep 'SleepScoring_OBGamma.mat'], 'TotalNoiseEpoch', 'SmoothTheta','Sleep')
SmoothTheta = tsd(Range(SmoothTheta) , runmean(Data(SmoothTheta),ceil(smootime/median(diff(Range(SmoothTheta,'s'))))));
REMEpoch = and(thresholdIntervals(SmoothTheta , 10^.355 , 'Direction' , 'Above') , Sleep);
SWSEpoch = Sleep-REMEpoch;

% define IS & NREM
load([pwd filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
FilDelta = FilterLFP(LFP,[.5 4],1024);
hilbert_delta = abs(hilbert(Data(FilDelta)));
SmoothDelta_OB = tsd(Range(LFP),runmean(hilbert_delta,ceil(smootime/median(diff(Range(LFP,'s'))))));

% figure
% gamma_thresh = GetGaussianThresh_BM(log10(Data(Restrict(SmoothDelta_OB , SWSEpoch))), 0, 1);
gamma_thresh = 2.64;
% makepretty

N1 = and(thresholdIntervals(SmoothDelta_OB , 10^gamma_thresh , 'Direction' , 'Below') , SWSEpoch);
N2 = SWSEpoch-N1;


SmoothDelta_OB = Restrict(SmoothDelta_OB , SmoothTheta);

[sum(DurationEpoch(N1)) sum(DurationEpoch(N2)) sum(DurationEpoch(REMEpoch))]./3.6e7

%% figures
figure
subplot(6,6,32:36)
[Y,X] = hist(log10(Data(Restrict(SmoothTheta,Sleep))),100);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
xlim([-.28 1.1]), box off, ylim([0 6e5])
v1=vline(.355,'-r'); v1.LineWidth=5;
ylabel('PDF'), xlabel('HPC theta power (a.u.)')
% makepretty

subplot(6,6,[25 19 13 7 1])
[Y,X] = hist(log10(Data(Restrict(SmoothDelta_OB,Sleep))),100);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
xlabel('OB delta power (a.u.)'), xlim([2.3 2.9]), ylim([0 1.2e6])
set(gca,'XDir','reverse'), camroll(270), box off
v2=vline(gamma_thresh,'-r'); v2.LineWidth=5;
% makepretty
 
subplot(6,6,[2:6 8:12 14:18 20:24 26:30])
X = log10(Data(Restrict(SmoothTheta , N1))); Y = log10(Data(Restrict(SmoothDelta_OB , N1))); 
plot(X(1:2.5e3:end) , Y(1:2.5e3:end) , '.','MarkerSize',4,'Color',[1 .5 0]), hold on
X = log10(Data(Restrict(SmoothTheta , N2))); Y = log10(Data(Restrict(SmoothDelta_OB , N2))); 
plot(X(1:5e3:end) , Y(1:5e3:end) , '.','MarkerSize',4,'Color',[1 0 0]), hold on
X = log10(Data(Restrict(SmoothTheta , REMEpoch))); Y = log10(Data(Restrict(SmoothDelta_OB , REMEpoch))); 
plot(X(1:5e3:end) , Y(1:5e3:end) , '.g','MarkerSize',4), hold on
axis square, xlim([-.28 1.1]), ylim([2.3 2.9])
set(gca,'Linewidth',2), xticklabels({''}), yticklabels({''})
f=get(gca,'Children'); l=legend([f([3 2 1])],'IS','NREM','REM'); 







