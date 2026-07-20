

%% check for spindle
cd('/media/nas7/React_Passive_AG/OBG/Brynza/freely-moving/20240202_saline')
smootime = 2;
load('LFPData/LFP15.mat')
FilSpindles = FilterLFP(LFP,[10 16],1024);
tEnveloppeSpindles = tsd(Range(LFP), abs(hilbert(Data(FilSpindles))) ); 
SmoothSpindles = tsd(Range(tEnveloppeSpindles), runmean(Data(tEnveloppeSpindles), ...
    ceil(smootime/median(diff(Range(tEnveloppeSpindles,'s'))))));


figure
[Y,X]=hist(log10(Data(Restrict(SmoothSpindles , CleanStates.N1))),1e3);
Y=Y/sum(Y);
plot(X,runmean(Y,5),'Color',[1 .5 0],'LineWidth',1)
hold on
[Y,X]=hist(log10(Data(Restrict(SmoothSpindles , CleanStates.N2))),1e3);
Y=Y/sum(Y);
plot(X,runmean(Y,5),'r','LineWidth',1)
[Y,X]=hist(log10(Data(Restrict(SmoothSpindles , CleanStates.REM))),1e3);
Y=Y/sum(Y);
plot(X,runmean(Y,5),'g','LineWidth',1)


xlabel('Breathing variability (a.u.)'), ylabel('PDF')
box off,% xlim([1.5 6])
legend('Wake','NREM','REM')



%% check for spindle
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs')
smootime = 2;
load('LFPData/LFP12.mat')
FilSpindles = FilterLFP(LFP,[10 16],1024);
tEnveloppeSpindles = tsd(Range(LFP), abs(hilbert(Data(FilSpindles))) ); 
SmoothSpindles = tsd(Range(tEnveloppeSpindles), runmean(Data(tEnveloppeSpindles), ...
    ceil(smootime/median(diff(Range(tEnveloppeSpindles,'s'))))));


figure
[Y,X]=hist(log10(Data(Restrict(SmoothSpindles , CleanStates.N1))),1e3);
Y=Y/sum(Y);
plot(X,runmean(Y,5),'Color',[1 .5 0],'LineWidth',2)
hold on
[Y,X]=hist(log10(Data(Restrict(SmoothSpindles , CleanStates.N2))),1e3);
Y=Y/sum(Y);
plot(X,runmean(Y,5),'r','LineWidth',2)
[Y,X]=hist(log10(Data(Restrict(SmoothSpindles , CleanStates.REM))),1e3);
Y=Y/sum(Y);
plot(X,runmean(Y,5),'g','LineWidth',2)
[Y,X]=hist(log10(Data(Restrict(SmoothSpindles , CleanStates.Wake))),1e3);
Y=Y/sum(Y);
plot(X,runmean(Y,5),'b','LineWidth',2)
xlabel('10-16Hz power (log)'), ylabel('PDF'), xlim([1.65 2.4])
makepretty_BM2
legend('IS','NREM','REM')



