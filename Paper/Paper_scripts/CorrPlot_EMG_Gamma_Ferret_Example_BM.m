
function CorrPlot_EMG_Gamma_Ferret_Example_BM


cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs')
load('SleepScoring_OBGamma.mat', 'Epoch', 'SmoothGamma', 'SmoothTheta')
smootime = 3;


load('ChannelsToAnalyse/EMG.mat', 'channel')
load(['LFPData/LFP' num2str(channel) '.mat'])

Epoch = and(Epoch , intervalSet([0 14e7]',[1e7 15.3e7]'));
LFP = Restrict(LFP , Epoch);
FilLFP=FilterLFP(LFP,[50 300],1024);
EMGData=tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));
EMGData=Restrict(EMGData,Epoch);

SmoothGamma = Restrict(SmoothGamma , Epoch);
SmoothGamma_intf = Restrict(SmoothGamma,EMGData);


figure
subplot(6,6,32:36)
[Y,X] = hist(log10(Data(SmoothGamma)),300);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
xlabel('OB gamma power (log)'); ylabel('PDF'), xlim([2 3]), ylim([0 4e4])
v1=vline(2.25,'-r'); v1.LineWidth=3;
box off

subplot(6,6,[25 19 13 7 1])
[Y,X] = hist(log10(Data(EMGData)),300);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
set(gca,'XDir','reverse'), camroll(270)
v2=vline(3.5,'-r'); v2.LineWidth=3;
xlabel('EMG power (log)'), ylabel('PDF'), xlim([2.5 6.2]), ylim([0 4e4])
box off

subplot(6,6,[2:6 8:12 14:18 20:24 26:30])
X = log10(Data(SmoothGamma_intf)); Y = log10(Data(EMGData));
plot(X(1:2e3:end) , Y(1:2e3:end) , '.k' , 'MarkerSize' , 3)
axis square
xlim([2 3]), ylim([2.5 6.2]), xticklabels({''}), yticklabels({''})
v1=vline(2.25,'-r'); v1.LineWidth=3;
v2=hline(3.5,'-r'); v2.LineWidth=3;



%% Accelero
load('behavResources.mat', 'MovAcctsd')
AccData=tsd(Range(MovAcctsd),runmean_BM(Data(MovAcctsd),ceil(smootime/median(diff(Range(MovAcctsd,'s'))))));
AccData=Restrict(AccData,Epoch);
SmoothGamma_onAcc = Restrict(SmoothGamma,AccData);


figure
subplot(6,6,32:36)
[Y,X] = hist(log10(Data(SmoothGamma)),1000);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
box off
v1=vline(2.4,'-r'); v1.LineWidth=3;
xlabel('OB gamma power (log scale)');

subplot(6,6,[25 19 13 7 1])
[Y,X] = hist(log10(Data(AccData)),1000);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0]; xlim([5.7 8.5])
set(gca,'XDir','reverse'), camroll(270), box off
v2=vline(7,'-r'); v2.LineWidth=3;
xlabel('Motion (log scale)');

subplot(6,6,[2:6 8:12 14:18 20:24 26:30])
X = log10(Data(SmoothGamma_onAcc)); Y = log10(Data(AccData));
plot(X(1:100:end) , Y(1:100:end) , '.k' , 'MarkerSize' , 3)
axis square
ylim([5.7 8.5])
v1=vline(2.4,'-r'); v1.LineWidth=3;
v2=hline(7,'-r'); v2.LineWidth=3;



%% OB gamma and HPC theta
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs')
load('SleepScoring_OBGamma.mat', 'Epoch', 'Sleep', 'SmoothTheta', 'SmoothGamma_wide')
smootime = 30;

SmoothGamma_wide = Restrict(SmoothGamma_wide , Epoch);
SmoothTheta = Restrict(SmoothTheta,SmoothGamma_wide);


figure
subplot(6,6,32:36)
[Y,X] = hist(log10(Data(SmoothGamma_wide)),300);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
v1=vline(2.241,'-r'); v1.LineWidth=3;
xlabel('OB 50-75Hz power (log)'); ylabel('PDF'), xlim([2.12 2.32]), ylim([0 3.5e5])
box off

subplot(6,6,[25 19 13 7 1])
[Y,X] = hist(log10(Data(SmoothTheta)),300);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=1.5; a.EdgeColor=[0 0 0];
set(gca,'XDir','reverse'), camroll(270)
v2=vline(.55,'-r'); v2.LineWidth=3;
xlabel('HPC theta power (log)'), ylabel('PDF'), xlim([-.3 1.1]), ylim([0 1.5e5])
box off

subplot(6,6,[2:6 8:12 14:18 20:24 26:30])
X = log10(Data(SmoothGamma_wide)); Y = log10(Data(SmoothTheta));
plot(X(1:5e3:end) , Y(1:5e3:end) , '.k' , 'MarkerSize' , 3)
axis square
v1=vline(2.241,'-r'); v1.LineWidth=3;
v2=hline(.55,'-r'); v2.LineWidth=3;
xlim([2.12 2.32]), ylim([-.3 1.1]), xticklabels({''}), yticklabels({''})



