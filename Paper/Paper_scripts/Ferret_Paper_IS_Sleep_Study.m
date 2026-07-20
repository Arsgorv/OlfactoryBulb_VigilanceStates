
load('/media/nas8/OB_ferret_AG_BM/DataFerret')

%% all ferrets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Labneh: 24 OB, 1 AuCx
% Brynza: 26 PFC, 10 OB
% Shropshire: 12 PFC, 21 OB, 34 AuCx

%% parametrization
clear all
Frequency = [.5 4];
Frequency2 = [.1 1];
smootime = 10;

%% get sessions
Dir1 = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);


%% get data
for ferret=1:3
    for sess=1:length(Dir{ferret}.path)
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SWSEpoch','Epoch','TotalNoiseEpoch','Sleep', 'REMEpoch')
        if sum(DurationEpoch(SWSEpoch))/3600e4>1
            
            DurTot{ferret}(sess) = sum(DurationEpoch(or(Epoch,TotalNoiseEpoch)))/3600e4;
            DurSleep{ferret}(sess) = sum(DurationEpoch(Sleep))/3600e4;
            DurNREM{ferret}(sess) = sum(DurationEpoch(SWSEpoch))/3600e4;
            DurREM{ferret}(sess) = sum(DurationEpoch(REMEpoch))/3600e4;

            try
                % OB
                load([Dir{ferret}.path{sess} filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
                load([Dir{ferret}.path{sess} filesep 'LFPData/LFP' num2str(channel)])
                LFP = tsd(Range(LFP) , Data(LFP));%-Data(LFP6));
                Fil_Delta = FilterLFP(Restrict(LFP , SWSEpoch),Frequency,1024);
                tEnveloppe = tsd(Range(Fil_Delta), abs(hilbert(Data(Fil_Delta))) );
                SmoothDelta_OB{ferret}{sess}  = tsd(Range(tEnveloppe), runmean(Data(tEnveloppe), ...
                    ceil(smootime/median(diff(Range(tEnveloppe,'s'))))));
            end

            disp(sess)
        end
    end
    DurTot{ferret}(DurTot{ferret}==0) = NaN;
    DurSleep{ferret}(DurSleep{ferret}==0) = NaN;
    DurNREM{ferret}(DurNREM{ferret}==0) = NaN;
    DurREM{ferret}(DurREM{ferret}==0) = NaN;
end

figure
for ferret=1:3
    for sess=1:length(Dir{ferret}.path)
        try

            [DeltaOB_tresh(ferret,sess),~,~,~,~,AshD_OB(ferret,sess)] = GetGaussianThresh_BM(Data(SmoothDelta_OB{ferret}{sess}),0,1); makepretty

            clf
            disp(sess)
        end
    end
end
AshD_OB(AshD_OB==0) = NaN;
DeltaOB_tresh(DeltaOB_tresh==0) = NaN;

for ferret=1:3
    for sess=1:length(Dir{ferret}.path)
        try
            N1_OB{ferret}{sess} = thresholdIntervals(SmoothDelta_OB{ferret}{sess} ,  DeltaOB_tresh(ferret,sess) , 'Direction' , 'Below');
            N2_OB{ferret}{sess} = thresholdIntervals(SmoothDelta_OB{ferret}{sess} ,  DeltaOB_tresh(ferret,sess) , 'Direction' , 'Above');
            
            N1_prop_OB{ferret}(sess) = sum(DurationEpoch(N1_OB{ferret}{sess}))./(sum(DurationEpoch(N1_OB{ferret}{sess}))+sum(DurationEpoch(N2_OB{ferret}{sess})));
            REM_prop{ferret}(sess) = DurREM{ferret}(sess)/DurSleep{ferret}(sess);
            
            disp(sess)
        end
    end
end


%% figures
Cols = {[.2 .5 .8],[.8 .5 .2],[.5 .2 .8]};
X = 1:3;
Legends = {'Labneh','Brynza','Shropshire'};

figure
subplot(151)
MakeSpreadAndBoxPlot3_SB(DurTot,Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('total duration (hour)')
makepretty_BM2

subplot(152)
MakeSpreadAndBoxPlot3_SB(DurSleep,Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('Sleep duration (hour)')
makepretty_BM2

subplot(153)
MakeSpreadAndBoxPlot3_SB(DurNREM,Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('NREM duration (hour)')
makepretty_BM2

subplot(154)
MakeSpreadAndBoxPlot3_SB({DurSleep{1}./DurTot{1} DurSleep{2}./DurTot{2} DurSleep{3}./DurTot{3}},Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('Sleep proportion')
makepretty_BM2

subplot(155)
MakeSpreadAndBoxPlot3_SB({DurNREM{1}./DurTot{1} DurNREM{2}./DurTot{2} DurNREM{3}./DurTot{3}},Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('NREM proportion')
makepretty_BM2


LIM = {[2.2 3.2],[1.7 2.6],[2.3 3.2]};
figure, 
for ferret=1:3
    for sess=1:length(Dir{ferret}.path)
        try
            D = log10(Data(SmoothDelta_OB{ferret}{sess}));
            h=histogram(D,'BinLimits',LIM{ferret},'NumBins',100);
            HistData{ferret}(sess,:) = h.Values;
        end
    end
    HistData{ferret}(HistData{ferret}==0) = NaN;
end
close
HistData{2}(1,:) = NaN;

THR = [2.72 2.1 2.655];
figure
for ferret=1:3
    subplot(1,3,ferret)
    Data_to_use = HistData{ferret};
    Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
    h=shadedErrorBar(linspace(LIM{ferret}(1),LIM{ferret}(2),100) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
    xlabel('delta power OB (log)'), xlim(LIM{ferret}), if ferret==1, ylabel('PDF'), end
    title(Legends{ferret})
    makepretty
    v=vline(THR(ferret),'-r'); v.LineWidth=5;
end




DurSleep_tot = []; N1_prop_OB_tot = [];  REM_prop_OB_tot = [];
for ferret=1:3
    DurSleep_tot = [DurSleep_tot DurSleep{ferret}];
    N1_prop_OB_tot = [N1_prop_OB_tot N1_prop_OB{ferret}];
    REM_prop_OB_tot = [REM_prop_OB_tot REM_prop{ferret}];
end
N1_prop_OB_tot(N1_prop_OB_tot>.6) = NaN;
N1_prop_OB_tot(N1_prop_OB_tot==0) = NaN;

figure
subplot(131)
PlotCorrelations_BM(DurSleep_tot , N1_prop_OB_tot);
xlabel('sleep duration (hour)'), ylabel('N1 proportion'), axis square
makepretty_BM2

subplot(132)
PlotCorrelations_BM(DurSleep_tot , REM_prop_OB_tot);
xlabel('sleep duration (hour)'), ylabel('REM proportion'), axis square
makepretty_BM2

subplot(133)
PlotCorrelations_BM(N1_prop_OB_tot , REM_prop_OB_tot);
xlabel('N1 proportion'), ylabel('REM proportion'), axis square
makepretty_BM2




