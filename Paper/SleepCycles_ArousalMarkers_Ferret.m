
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs')
clear all


%% preliminary parameters and variables
smootime = 1;

load([pwd filesep 'SleepScoring_OBGamma.mat'], 'Wake','TotalNoiseEpoch','Epoch','Sleep')

load([pwd filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
LFP = Restrict(LFP , Sleep);
FilGamma = FilterLFP(LFP,[50 75],1024);
hilbert_gamma = abs(hilbert(Data(FilGamma)));
SmoothGamma_wide = tsd(Range(LFP),runmean(log10(hilbert_gamma),ceil(smootime/median(diff(Range(LFP,'s'))))));


load([pwd filesep 'ChannelsToAnalyse/dHPC_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
LFP = Restrict(LFP , Sleep);
Frequency{1}=[3 6];
Frequency{2}=[.2 3];
FilTheta = FilterLFP(LFP,Frequency{1},1024);
FilDelta = FilterLFP(LFP,Frequency{2},1024);
hilbert_theta = abs(hilbert(Data(FilTheta)));
hilbert_delta = abs(hilbert(Data(FilDelta)));
hilbert_delta(hilbert_delta<10) = 10;
theta_ratio = hilbert_theta./hilbert_delta;
ThetaRatioTSD = tsd(Range(FilTheta), theta_ratio);
SmoothTheta = tsd(Range(ThetaRatioTSD),runmean(Data(ThetaRatioTSD),ceil(smootime/median(diff(Range(ThetaRatioTSD,'s'))))));

load([pwd filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
FilDelta = FilterLFP(LFP,[.5 4],1024);
hilbert_delta = abs(hilbert(Data(FilDelta)));
SmoothDelta_OB = tsd(Range(LFP),runmean(hilbert_delta,ceil(smootime/median(diff(Range(LFP,'s'))))));


load('SleepScoring_OBGamma.mat', 'Mean_FR')
SmoothMeanFR = tsd(Range(Mean_FR) , runmean(Data(Mean_FR) , ceil(smootime/median(diff(Range(Mean_FR,'s'))))));

load('SleepScoring_OBGamma.mat', 'EMG_tsd')
x = Data(EMG_tsd);
low  = prctile(x,1);
high = prctile(x,95);
x(x<low)  = low;
x(x>high) = high;
y = log10(x);
SmoothEMG = tsd(Range(EMG_tsd) , runmean(log(log(y + 5) + 5) , ceil(smootime/median(diff(Range(EMG_tsd,'s'))))));


load('behavResources.mat', 'MovAcctsd')
D = Data(MovAcctsd); D(1) = D(2);
D = movmean(log10(D) , ceil(smootime/median(diff(Range(MovAcctsd,'s')))) , 'omitnan'); D(isnan(D)) = median(D);
SmoothAcc = tsd(Range(MovAcctsd) , D);

Var{1} = SmoothAcc;
Var{2} = SmoothGamma_wide;
Var{3} = SmoothMeanFR;
Var{4} = SmoothEMG;
Var{5} = SmoothTheta;
Var{6} = SmoothDelta_OB;

Params = {'Motion','OB gamma power','Mean FR','EMG','HPC theta power','OB delta power'};


%% defining sleep cycles with REM ends
load('SleepScoring_OBGamma.mat', 'REMEpoch')

REMEpoch = mergeCloseIntervals(REMEpoch , 3*60e4);
REMEpoch = dropShortIntervals(REMEpoch , 60e4);
Dur_REM = DurationEpoch(REMEpoch)/60e4;
Sto = Stop(REMEpoch); % start of sleep cycle
SleepCycle = intervalSet(Sto(1:end-1) , Sto(2:end));
Dur_SleepCyc = DurationEpoch(SleepCycle)/60e4;


for s = 1:length(Sto)-1
    SmallEp = subset(SleepCycle , s);
    
    % variables
    for i=1:length(Params)
        clear D
        D = Data(Restrict(Var{i} , subset(SleepCycle , s)));
        
        Var_interp{i}(s,:) = interp1(linspace(0,1,length(D)) , D , linspace(0,1,100));
    end
end


%%
figure
for i=1:6
    subplot(2,3,i)
    Var_interp{i}(10,:) = NaN;
%     Data_to_use = runmean(zscore([Var_interp{i} Var_interp{i}]') , 5)';
    Data_to_use = zscore([Var_interp{i} Var_interp{i}]')';
    Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
    h = shadedErrorBar(linspace(0 , 2 , 200) , nanmean(Data_to_use) , Conf_Inter,'-k',1); hold on;
%     color= Cols{i}; h.mainLine.Color=color; h.patch.FaceColor=color;
    title(Params{i})
    if i>3, xlabel('Time (sleep cycle)'), end
    if or(i==1 , i==4), ylabel('Power (zscore)'), end
    ylim([-1.5 1.5])
    vline(1 , '--r'),% vline([.2 .7 1.2 1.7],'--k')
end
% 
% f=get(gca,'Children'); l=legend([f([6 4 2])],'OB gamma','HPC theta','OB delta');
% xticks([0:.5:1]), xticklabels({'0','.5','1'}), xlabel('Time (sleep cycle)')
% ylabel('Power (zscore)'), ylim([-1.5 2])
% box off



%% Cross-correlations with OB gamma
maxlag = 2500*1250; 
OBgamma = zscore(Data(Restrict(Var{2} , Sleep)));

figure; hold on
for i=[1 3:6]
    X = zscore_nan(Data(Restrict(Var{i},Var{2})));
    Y = OBgamma;
    ind = or(isnan(X) , isnan(Y));
    X(ind) = []; Y(ind) = [];
    
    [xc,lags] = xcorr(X,Y,maxlag,'coeff');
    
    plot(lags/(1250*60),xc) % convert lag index to ms (0.0001s units)
end
xlabel('Lag (min)')
ylabel('Cross-corr (r)')
xlim([-40 40])
vline(0,'--r')
legend(Params([1 3:6]))
grid on

