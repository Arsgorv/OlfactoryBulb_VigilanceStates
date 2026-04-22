

cd('/media/nas7/React_Passive_AG/OBG/Arsenii_OB_anesth_2022-04-30_12-33-19_domitor-1/Record_Node_101/')


%% Analyzing ferret data
% generate data as tsd
load('StateEpochSB.mat','Epoch','TotalNoiseEpoch','smooth_ghi','sleepper','gamma_thresh')
load('B_Low_Spectrum.mat')
OB_Low_Spectro = Spectro;
OB_Low_Spectro_tsd = tsd(OB_Low_Spectro{2}*1e4 , OB_Low_Spectro{1});
load('B_Middle_Spectrum.mat')
OB_Middle_Spectro = Spectro;
OB_Middle_Spectro_tsd = tsd(OB_Middle_Spectro{2}*1e4 , OB_Middle_Spectro{1});
load('B_High_Spectrum.mat')
OB_High_Spectro = Spectro;
OB_High_Spectro_tsd = tsd(OB_High_Spectro{2}*1e4 , OB_High_Spectro{1});

% study data only on non-noise epoch
Epoch = Epoch-TotalNoiseEpoch;
CleanEpoch=thresholdIntervals(smooth_ghi,130,'Direction','Below'); % removing 50Hz noise

Epoch=and(Epoch , CleanEpoch);
            
smootime = 3; % smooth time from sleep scoring algo
smooth_ghi = Restrict(smooth_ghi , Epoch);
New_smooth_ghi=tsd(Range(smooth_ghi),runmean(Data(smooth_ghi),ceil(smootime/median(diff(Range(smooth_ghi,'s'))))));
OB_Low_Spectro_tsd = Restrict(OB_Low_Spectro_tsd , Epoch);
OB_Middle_Spectro_tsd = Restrict(OB_Middle_Spectro_tsd , Epoch);
OB_High_Spectro_tsd = Restrict(OB_High_Spectro_tsd , Epoch);

% defining epoch with injection time
Before_drugs_Epoch = intervalSet(0 , 23*60e4);
Under_drugs_Epoch = intervalSet(23*60e4 , 74*60e4);
After_drugs_Epoch = intervalSet(74*60e4 , 120*60e4);

OB_Low_Spectro_Before_Drugs = Restrict(OB_Low_Spectro_tsd , Before_drugs_Epoch);
OB_Low_Spectro_Under_Drugs = Restrict(OB_Low_Spectro_tsd , Under_drugs_Epoch);
OB_Low_Spectro_After_Drugs = Restrict(OB_Low_Spectro_tsd , After_drugs_Epoch);

OB_Middle_Spectro_Before_Drugs = Restrict(OB_Middle_Spectro_tsd , Before_drugs_Epoch);
OB_Middle_Spectro_Under_Drugs = Restrict(OB_Middle_Spectro_tsd , Under_drugs_Epoch);
OB_Middle_Spectro_After_Drugs = Restrict(OB_Middle_Spectro_tsd , After_drugs_Epoch);

OB_High_Spectro_Before_Drugs = Restrict(OB_High_Spectro_tsd , Before_drugs_Epoch);
OB_High_Spectro_Under_Drugs = Restrict(OB_High_Spectro_tsd , Under_drugs_Epoch);
OB_High_Spectro_After_Drugs = Restrict(OB_High_Spectro_tsd , After_drugs_Epoch);


% Spectrograms
figure
subplot(211)
imagesc(Range(OB_Low_Spectro_tsd)/60e4 , OB_Low_Spectro{3} , 10*log10(Data(OB_Low_Spectro_tsd)')); axis xy
caxis([15 40]); makepretty; ylabel('Frequency (Hz)'); title('OB Low Spectrum')
vline(23,'-r','Medetomidine')
vline(74,'-r','Atipamezole')
subplot(212)
imagesc(Range(OB_High_Spectro_tsd)/60e4 , OB_High_Spectro{3} , runmean(10*log10(Data(OB_High_Spectro_tsd)),500)'); axis xy
ylim([20 100]); caxis([13 21]); makepretty; ylabel('Frequency (Hz)'); title('OB High Spectrum'); xlabel('time (min)')
hline([40 60],'--r')
vline(23,'-r','Medetomidine')
vline(74,'-r','Atipamezole')

a=suptitle('Olfactory Bulb spectrograms'); a.FontSize=20;


% Mean spectrum
figure
subplot(131)
plot(OB_Low_Spectro{3} , OB_Low_Spectro{3}.*nanmean(Data(OB_Low_Spectro_Before_Drugs)) , 'b')
hold on
plot(OB_Low_Spectro{3} , OB_Low_Spectro{3}.*nanmean(Data(OB_Low_Spectro_Under_Drugs)) , 'r')
plot(OB_Low_Spectro{3} , OB_Low_Spectro{3}.*nanmean(Data(OB_Low_Spectro_After_Drugs)) , 'k')
makepretty; ylim([2e3 7e4])
legend('Baseline','+ Medetomodine','+ Atipamezole')
xlabel('Frequency (Hz)')
ylabel('Power (a.u.)')
vline(2,'--r'); vline(10,'--r'); vline(15.2,'--r')
title('OB Low Spectrum')

subplot(132)
plot(OB_Middle_Spectro{3} , OB_Middle_Spectro{3}.*nanmean(Data(OB_Middle_Spectro_Before_Drugs)) , 'b')
hold on
plot(OB_Middle_Spectro{3} , OB_Middle_Spectro{3}.*nanmean(Data(OB_Middle_Spectro_Under_Drugs)) , 'r')
plot(OB_Middle_Spectro{3} , OB_Middle_Spectro{3}.*nanmean(Data(OB_Middle_Spectro_After_Drugs)) , 'k')
makepretty; ylim([2e3 8e3])
xlabel('Frequency (Hz)')
vline(52,'--r'); vline(45,'--r'); 
title('OB Middle Spectrum')

a=suptitle('OB mean spectrum, drugs epochs'); a.FontSize=20;

subplot(133)
plot(OB_High_Spectro{3} , OB_High_Spectro{3}.*nanmean(Data(OB_High_Spectro_Before_Drugs)) , 'b')
hold on
plot(OB_High_Spectro{3} , OB_High_Spectro{3}.*nanmean(Data(OB_High_Spectro_Under_Drugs)) , 'r')
plot(OB_High_Spectro{3} , OB_High_Spectro{3}.*nanmean(Data(OB_High_Spectro_After_Drugs)) , 'k')
makepretty; ylim([2e3 8e3])
xlabel('Frequency (Hz)')
vline(52,'--r'); vline(45,'--r'); 
title('OB High Spectrum')

a=suptitle('OB mean spectrum, drugs epochs'); a.FontSize=20;


% Gamma power evolution along recording
GammaPower_Before_Drugs = Restrict(smooth_ghi , Before_drugs_Epoch);
GammaPower_Under_Drugs = Restrict(smooth_ghi , Under_drugs_Epoch);
GammaPower_After_Drugs = Restrict(smooth_ghi , After_drugs_Epoch);


figure
plot(Range(GammaPower_Before_Drugs)/60e4 , runmean(Data(GammaPower_Before_Drugs),50000),'color', [0.3010, 0.7450, 0.9330], 'LineWidth', 2.5)
hold on
plot(Range(GammaPower_Under_Drugs)/60e4 , runmean(Data(GammaPower_Under_Drugs),50000), 'color', [0.9290, 0.6940, 0.1250], 'LineWidth', 2.5)
plot(Range(GammaPower_After_Drugs)/60e4 , runmean(Data(GammaPower_After_Drugs),50000),'color', [0.4660, 0.6740, 0.1880], 'LineWidth', 2.5)
makepretty
xlim([0 100])
vline(23,'--r','Medetomidine')
vline(74,'--r','Atipamezole')
legend('Baseline Wake','+ Medetomodine','+ Atipamezole')
xlabel('time (min)')
ylabel('Gamma Power')
title('Olfactory Gamma Power evolution along the recording')


% Gamma distribution
figure
[Y_tot,X_tot]=hist(log(Data(New_smooth_ghi)),1000); Y_tot=Y_tot/sum(Y_tot);
% plot(X_tot , Y_tot , 'Color' , [0.4660, 0.6740, 0.1880])
plot(X_tot , Y_tot , 'Color' , [0.9290, 0.6940, 0.1250])
hold on
plot(X_tot(X_tot>log(gamma_thresh)) , Y_tot((X_tot>log(gamma_thresh))) , 'Color' , [0.3010, 0.7450, 0.9330])

[cf2,goodness2]=createFit2gauss(X_tot,Y_tot,[]);
a= coeffvalues(cf2);
b=intersect_gaussians(a(2), a(5), a(3), a(6));
h_ = plot(cf2,'fit',0.95);
u=vline(log(gamma_thresh),'--r','Threshold'); u.LineWidth=2;

makepretty
set(h_(1),'LineWidth',2);
xlabel('Gamma power (log scale)'); xlim([3.8 4.8])
ylabel('#')
legend('Low gamma power values','High gamma power values','BiGaussian fit')
title('Gamma power distribution')


% Gamma distribution for these epochs
[Y_bef_D,X_bef_D]=hist(log(Data(GammaPower_Before_Drugs)),1000);
Y_bef_D=Y_bef_D/sum(Y_bef_D);
[Y_und_D,X_und_D]=hist(log(Data(GammaPower_Under_Drugs)),1000);
Y_und_D=Y_und_D/sum(Y_und_D);
[Y_aft_D,X_aft_D]=hist(log(Data(GammaPower_After_Drugs)),1000);
Y_aft_D=Y_aft_D/sum(Y_aft_D);

figure
plot(X_bef_D,Y_bef_D, 'color', [0.3010, 0.7450, 0.9330])
hold on
plot(X_und_D,Y_und_D, 'color', [0.9290, 0.6940, 0.1250])
plot(X_aft_D,Y_aft_D, 'color', [0.4660, 0.6740, 0.1880])

xlim([3.8 4.8])
makepretty
legend('Baseline','+ Medetomodine','+ Atipamezole')
xlabel('Gamma power (log scale)'); xlim([3.8 4.8])
ylabel('#')
title('Gamma power distribution')
vline(log(gamma_thresh),'--r')

% Evolution 
figure
plot(Range(Restrict(New_smooth_ghi , sleepper))/60e4 , Data(Restrict(New_smooth_ghi , sleepper)) , 'Color' , [0.4660, 0.6740, 0.1880])
hold on
plot(Range(Restrict(New_smooth_ghi , Epoch-sleepper))/60e4 , Data(Restrict(New_smooth_ghi , Epoch-sleepper)) , 'Color' , [0.9290, 0.6940, 0.1250])
makepretty
xlim([0 100])
vline(23,'--r','Medetomidine')
vline(74,'--r','Atipamezole')
legend('Low gamma power Epoch','High gamma power epoch')
xlabel('time (min)')
ylabel('Gamma Power')
title('Sedation protocol, ferret')




%% Physiology
% defining variables
load('behavResources.mat', 'MovAcctsd')
NewMovAcctsd=tsd(Range(MovAcctsd),runmean(Data(MovAcctsd),1000));

load('HeartBeatInfo.mat', 'EKG')
EKG.HBRate = Restrict(EKG.HBRate , Epoch);

% D=Data(OB_Low_Spectro_tsd);
% [Power,Spectrum_Peak] = max(zscore_nan_BM(OB_Low_Spectro{3}(13:104)'.*D(:,13:104)'));
% Frequencies_withNoise = OB_Low_Spectro{3}(Spectrum_Peak+12);
% Frequencies_withNoise_tsd = tsd(Range(OB_Low_Spectro_tsd) , Frequencies_withNoise')
load('InstFreqAndPhase_B.mat', 'LocalFreq')
Breathing_tsd = LocalFreq.PT;

MovAcctsd_Before_Drugs = Restrict(MovAcctsd , Before_drugs_Epoch);
MovAcctsd_Under_Drugs = Restrict(MovAcctsd , Under_drugs_Epoch);
MovAcctsd_After_Drugs = Restrict(MovAcctsd , After_drugs_Epoch);

HR_Before_Drugs = Restrict(EKG.HBRate , Before_drugs_Epoch);
HR_Under_Drugs = Restrict(EKG.HBRate , Under_drugs_Epoch);
HR_After_Drugs = Restrict(EKG.HBRate , After_drugs_Epoch);

Breathing_Before_Drugs = Restrict(LocalFreq.PT , Before_drugs_Epoch);
Breathing_Under_Drugs = Restrict(LocalFreq.PT , Under_drugs_Epoch);
Breathing_After_Drugs = Restrict(LocalFreq.PT , After_drugs_Epoch);


% evolution along session
figure
subplot(311)
plot(Range(MovAcctsd_Before_Drugs)/60e4 , log(runmean(Data(MovAcctsd_Before_Drugs),1000)), 'color', [0.3010, 0.7450, 0.9330])
hold on
plot(Range(MovAcctsd_Under_Drugs)/60e4 , log(runmean(Data(MovAcctsd_Under_Drugs),1000)), 'color', [0.9290, 0.6940, 0.1250])
plot(Range(MovAcctsd_After_Drugs)/60e4 , log(runmean(Data(MovAcctsd_After_Drugs),1000)), 'color', [0.4660, 0.6740, 0.1880])
makepretty; xlim([0 100]); ylim([13.5 14.6])
vline(23,'--r','Medetomidine')
vline(74,'--r','Atipamezole')
ylabel('Movement quantity (log scale)')
legend('Baseline','+ Medetomodine','+ Atipamezole')
title('Head movement (accelerometer)')

subplot(312)
plot(Range(HR_Before_Drugs)/60e4 , runmean(Data(HR_Before_Drugs),20), 'color', [0.3010, 0.7450, 0.9330])
hold on
plot(Range(HR_Under_Drugs)/60e4 , runmean(Data(HR_Under_Drugs),20), 'color', [0.9290, 0.6940, 0.1250])
D=Data(HR_After_Drugs); D=D(D<6); R=Range(HR_After_Drugs);
plot(R(D<6)/60e4 , runmean(D(D<6),20), 'color', [0.4660, 0.6740, 0.1880])
ylim([1 8]); xlim([0 100])
makepretty
vline(23,'--r')
vline(74,'--r')
ylabel('Frequency (Hz)')
title('Electrocardiogram')

subplot(313)
plot(Range(Breathing_Before_Drugs)/60e4 , runmean(Data(Breathing_Before_Drugs),20), 'color', [0.3010, 0.7450, 0.9330])
hold on
plot(Range(Breathing_Under_Drugs)/60e4 , runmean(Data(Breathing_Under_Drugs),20), 'color', [0.9290, 0.6940, 0.1250])
plot(Range(Breathing_After_Drugs)/60e4 , runmean(Data(Breathing_After_Drugs),20), 'color', [0.4660, 0.6740, 0.1880])
xlim([0 100])
makepretty
vline(23,'--r')
vline(74,'--r')
ylabel('Frequency (Hz)')
title('Breathing')

a=suptitle('Physiology'); a.FontSize=20;


%% distribution, drugs epochs
[Y_bef_D,X_bef_D]=hist(log(runmean(Data(MovAcctsd_Before_Drugs),1000)),1000);
Y_bef_D=Y_bef_D/sum(Y_bef_D);
[Y_und_D,X_und_D]=hist(log(runmean(Data(MovAcctsd_Under_Drugs),1000)),1000);
Y_und_D=Y_und_D/sum(Y_und_D);
[Y_aft_D,X_aft_D]=hist(log(runmean(Data(MovAcctsd_After_Drugs),1000)),1000);
Y_aft_D=Y_aft_D/sum(Y_aft_D);

figure
subplot(221)
plot(X_bef_D,runmean(Y_bef_D,5), 'color', [0.3010, 0.7450, 0.9330])
hold on
plot(X_und_D,runmean(Y_und_D,5), 'color', [0.9290, 0.6940, 0.1250])
plot(X_aft_D,runmean(Y_aft_D,5), 'color', [0.4660, 0.6740, 0.1880])

xlim([13.5 14.7])
makepretty
legend('Baseline','+ Medetomodine','+ Atipamezole')
xlabel('Movement quantity (log scale)'); 
ylabel('#')
title('Head movement (accelerometer)')
vline(13.8,'--r')


[Y_bef_D,X_bef_D]=hist(Data(HR_Before_Drugs),1000);
Y_bef_D=Y_bef_D/sum(Y_bef_D);
[Y_und_D,X_und_D]=hist(Data(HR_Under_Drugs),1000);
Y_und_D=Y_und_D/sum(Y_und_D);
[Y_aft_D,X_aft_D]=hist(Data(HR_After_Drugs),1000);
Y_aft_D=Y_aft_D/sum(Y_aft_D);

subplot(222)
plot(X_bef_D,runmean(Y_bef_D,5), 'color', [0.3010, 0.7450, 0.9330])
hold on
plot(X_und_D,runmean(Y_und_D,5), 'color', [0.9290, 0.6940, 0.1250])
plot(X_aft_D,runmean(Y_aft_D,5), 'color', [0.4660, 0.6740, 0.1880])

xlim([1 6.5])
makepretty
xlabel('Frequency (Hz)'); 
title('Electrocardiogram')
vline(3,'--r')


[Y_bef_D,X_bef_D]=hist(Data(Breathing_Before_Drugs),1000);
Y_bef_D=Y_bef_D/sum(Y_bef_D);
[Y_und_D,X_und_D]=hist(Data(Breathing_Under_Drugs),1000);
Y_und_D=Y_und_D/sum(Y_und_D);
[Y_aft_D,X_aft_D]=hist(Data(Breathing_After_Drugs),1000);
Y_aft_D=Y_aft_D/sum(Y_aft_D);

subplot(223)
plot(X_bef_D,runmean(Y_bef_D,5), 'color', [0.3010, 0.7450, 0.9330])
hold on
plot(X_und_D,runmean(Y_und_D,5), 'color', [0.9290, 0.6940, 0.1250])
plot(X_aft_D,runmean(Y_aft_D,5), 'color', [0.4660, 0.6740, 0.1880])

xlim([0 1.2])
makepretty
xlabel('Frequency (Hz)'); 
ylabel('#')
title('Breathing')
vline(0.47,'--r')


a=suptitle('Physiology, sedation protocol'); a.FontSize=20;


%% OB oscillations entrainment by breathing ?

D = Data(OB_Low_Spectro_tsd);
[Power,Spectrum_Peak] = max(D(:,1:64)');
Frequencies_withNoise = OB_Low_Spectro{3}(Spectrum_Peak);
Frequencies_withNoise_tsd = tsd(Range(OB_Low_Spectro_tsd) , Frequencies_withNoise');


Frequencies_withNoise_Before_Drugs = Restrict(Frequencies_withNoise_tsd , Before_drugs_Epoch);
Frequencies_withNoise_Under_Drugs = Restrict(Frequencies_withNoise_tsd , Under_drugs_Epoch);
Frequencies_withNoise_After_Drugs = Restrict(Frequencies_withNoise_tsd , After_drugs_Epoch);


figure
plot(Range(Frequencies_withNoise_tsd)/60e4 , runmean(Data(Frequencies_withNoise_tsd),200))
hold on
plot(Range(EKG.HBRate)/60e4 , runmean(Data(EKG.HBRate),20))
plot(Range(Breathing_tsd)/60e4 , runmean(Data(Breathing_tsd),20))
plot(Range(Breathing_tsd)/60e4 , runmean(Data(Breathing_tsd),20)*16-5)

ylim([0 5])
xlim([0 100])
makepretty
xlabel('time (min)')
ylabel('Frequency (Hz)')
legend('Max OB Low Spectro','EKG','Breathing','Breathing values*16-5')
vline(23,'--r')
vline(74,'--r')
title('Comparing physiological and neurophysiological rhythms, Ferret')


% divide by state
figure
subplot(231)
plot(Range(Frequencies_withNoise_Before_Drugs)/60e4 , runmean(Data(Frequencies_withNoise_Before_Drugs),200))
subplot(234)
plot(Range(Breathing_Before_Drugs)/60e4 , runmean(Data(Breathing_Before_Drugs),20)*4)

subplot(232)
plot(Range(Frequencies_withNoise_Under_Drugs)/60e4 , runmean(Data(Frequencies_withNoise_Under_Drugs),200))
xlim([30 75])
subplot(235)
plot(Range(Breathing_Under_Drugs)/60e4 , runmean(Data(Breathing_Under_Drugs),20)*4)
xlim([30 75])

subplot(233)
plot(Range(Frequencies_withNoise_After_Drugs)/60e4 , runmean(Data(Frequencies_withNoise_After_Drugs),200))
subplot(236)
plot(Range(Breathing_After_Drugs)/60e4 , runmean(Data(Breathing_After_Drugs),20)*4)


figure
plot(Range(Frequencies_withNoise_Under_Drugs)/60e4 , runmean(Data(Frequencies_withNoise_Under_Drugs),200))
hold on
plot(Range(Breathing_Under_Drugs)/60e4 , runmean(Data(Breathing_Under_Drugs),20)*16-5)






%%
% Spectrograms
figure
subplot(211)
imagesc(Range(OB_Low_Spectro_tsd)/60e4 , OB_Low_Spectro{3} , 10*log10(Data(OB_Low_Spectro_tsd)')); axis xy
caxis([15 40]); makepretty; ylabel('Frequency (Hz)'); title('OB Low Spectrum')
vline(23,'-r','Medetomidine')
vline(74,'-r','Atipamezole')

subplot(212)
yyaxis left
imagesc(Range(OB_High_Spectro_tsd)/60e4 , OB_High_Spectro{3} , runmean(10*log10(Data(OB_High_Spectro_tsd)),500)'); axis xy
ylim([20 100]); caxis([13 21]); makepretty; ylabel('Frequency (Hz)'); title('OB High Spectrum and gamma power evolution'); xlabel('time (min)')
hline([40 60],'--r')
vline(23,'-r','Medetomidine')
vline(74,'-r','Atipamezole')

a=suptitle('Olfactory Bulb spectrograms'); a.FontSize=20;

hold on 
yyaxis right

% plot(Range(GammaPower_Before_Drugs)/60e4 , runmean(Data(GammaPower_Before_Drugs),50000),'color', [0.3010, 0.7450, 0.9330], 'LineWidth', 2.5)
% plot(Range(GammaPower_Under_Drugs)/60e4 , runmean(Data(GammaPower_Under_Drugs),50000), 'color', [0.9290, 0.6940, 0.1250], 'LineWidth', 2.5)
% plot(Range(GammaPower_After_Drugs)/60e4 , runmean(Data(GammaPower_After_Drugs),50000),'color', [0.4660, 0.6740, 0.1880], 'LineWidth', 2.5)
plot(Range(GammaPower_Before_Drugs)/60e4 , runmean(Data(GammaPower_Before_Drugs),50000),'color', [0 .53 1], 'LineWidth', 2.5)
plot(Range(GammaPower_Under_Drugs)/60e4 , runmean(Data(GammaPower_Under_Drugs),50000),'color', [0.9290 0.4940 0.1250], 'LineWidth', 2.5)
plot(Range(GammaPower_After_Drugs)/60e4 , runmean(Data(GammaPower_After_Drugs),50000),'color', [0.3, 0.7, 0.2], 'LineWidth', 2.5)

legend('Baseline Wake','+ Medetomodine','+ Atipamezole')
xlabel('time (min)')
ylabel('Gamma Power')

makepretty



