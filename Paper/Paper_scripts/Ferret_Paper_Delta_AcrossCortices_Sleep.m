
smootime = 10;

%% correlation between delta in cortices
% example
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20250103_LSP_saline')
load('SleepScoring_OBGamma.mat', 'Wake', 'REMEpoch', 'SWSEpoch', 'SmoothTheta', 'SmoothGamma', 'Sleep', 'Info')
REMEpoch = mergeCloseIntervals(REMEpoch,25e4);
REMEpoch = dropShortIntervals(REMEpoch,25e4);


load('ChannelsToAnalyse/Bulb_deep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
LFP = tsd(Range(LFP) , Data(LFP));
Fil_Delta = FilterLFP(Restrict(LFP , Sleep),[.5 4],1024);
tEnveloppe = tsd(Range(Fil_Delta), abs(hilbert(Data(Fil_Delta))) );
SmoothDelta_OB  = tsd(Range(tEnveloppe), runmean(Data(tEnveloppe), ...
    ceil(smootime/median(diff(Range(tEnveloppe,'s'))))));

load('ChannelsToAnalyse/PFCx_deep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
LFP = tsd(Range(LFP) , Data(LFP));
Fil_Delta = FilterLFP(Restrict(LFP , Sleep),[.5 4],1024);
tEnveloppe = tsd(Range(Fil_Delta), abs(hilbert(Data(Fil_Delta))) );
SmoothDeltaPFC  = tsd(Range(tEnveloppe), runmean(Data(tEnveloppe), ...
    ceil(smootime/median(diff(Range(tEnveloppe,'s'))))));

load('ChannelsToAnalyse/AuCx.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
LFP = tsd(Range(LFP) , Data(LFP));
Fil_Delta = FilterLFP(Restrict(LFP , Sleep),[.5 4],1024);
tEnveloppe = tsd(Range(Fil_Delta), abs(hilbert(Data(Fil_Delta))) );
SmoothDeltaAuC  = tsd(Range(tEnveloppe), runmean(Data(tEnveloppe), ...
    ceil(smootime/median(diff(Range(tEnveloppe,'s'))))));



bin = 1e4;
figure
X = log10(Data(Restrict(SmoothDelta_OB , SWSEpoch)));
Y = log10(Data(Restrict(SmoothDeltaPFC , SWSEpoch)));
[R1,P1]=PlotCorrelations_BM(X(1:bin:end) , Y(1:bin:end) , 'color' , 'k' , 'marker_size' , 5);
axis square
xlabel('OB delta power'), ylabel('PFC delta power'), xlim([2.3 3]), ylim([2.1 3.2])
makepretty_BM2


%% all ferrets
clear all

smootime = 10;

Dir1 = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);


for ferret=2:3
    for sess=1:length(Dir{ferret}.path)
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SWSEpoch')
        if sum(DurationEpoch(SWSEpoch))/3600e4>1
            
            load([Dir{ferret}.path{sess} filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
            load([Dir{ferret}.path{sess} filesep 'LFPData/LFP' num2str(channel) '.mat'])
            LFP = tsd(Range(LFP) , Data(LFP));
            Fil_Delta = FilterLFP(Restrict(LFP , SWSEpoch),[.5 4],1024);
            tEnveloppe = tsd(Range(Fil_Delta), abs(hilbert(Data(Fil_Delta))) );
            SmoothDelta_OB  = tsd(Range(tEnveloppe), runmean(Data(tEnveloppe), ...
                ceil(smootime/median(diff(Range(tEnveloppe,'s'))))));
            
            load([Dir{ferret}.path{sess} filesep 'ChannelsToAnalyse/PFCx_deep.mat'])
            load([Dir{ferret}.path{sess} filesep 'LFPData/LFP' num2str(channel) '.mat'])
            LFP = tsd(Range(LFP) , Data(LFP));
            Fil_Delta = FilterLFP(Restrict(LFP , SWSEpoch),[.5 4],1024);
            tEnveloppe = tsd(Range(Fil_Delta), abs(hilbert(Data(Fil_Delta))) );
            SmoothDeltaPFC  = tsd(Range(tEnveloppe), runmean(Data(tEnveloppe), ...
                ceil(smootime/median(diff(Range(tEnveloppe,'s'))))));
            
            load([Dir{ferret}.path{sess} filesep 'ChannelsToAnalyse/AuCx.mat'])
            load([Dir{ferret}.path{sess} filesep 'LFPData/LFP' num2str(channel) '.mat'])
            LFP = tsd(Range(LFP) , Data(LFP));
            Fil_Delta = FilterLFP(Restrict(LFP , SWSEpoch),[.5 4],1024);
            tEnveloppe = tsd(Range(Fil_Delta), abs(hilbert(Data(Fil_Delta))) );
            SmoothDeltaAuC  = tsd(Range(tEnveloppe), runmean(Data(tEnveloppe), ...
                ceil(smootime/median(diff(Range(tEnveloppe,'s'))))));
            
            
            X = log10(Data(Restrict(SmoothDelta_OB , SWSEpoch)));
            Y = log10(Data(Restrict(SmoothDeltaPFC , SWSEpoch)));
            [r1{ferret}(sess), p1{ferret}(sess)] = corr(X,Y);
            X = log10(Data(Restrict(SmoothDelta_OB , SWSEpoch)));
            Y = log10(Data(Restrict(SmoothDeltaAuC , SWSEpoch)));
            [r2{ferret}(sess), p2{ferret}(sess)] = corr(X,Y);
            X = log10(Data(Restrict(SmoothDeltaPFC , SWSEpoch)));
            Y = log10(Data(Restrict(SmoothDeltaAuC , SWSEpoch)));
            [r3{ferret}(sess), p3{ferret}(sess)] = corr(X,Y);
            
            disp(sess)
        end
    end
    r1{ferret}(r1{ferret}==0) = NaN;
    r2{ferret}(r2{ferret}==0) = NaN;
    r3{ferret}(r3{ferret}==0) = NaN;
end

r1 = r1(2:3);
r2 = r2(2:3);
r3 = r3(2:3);

Cols = {[.8 .5 .2],[.5 .2 .8]};
X = 1:2;
Legends = {'F2','F3'};


figure
subplot(131)
MakeSpreadAndBoxPlot3_SB(r1,Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('R val, OB-PFCx'), ylim([-1 1])
makepretty_BM2

subplot(132)
MakeSpreadAndBoxPlot3_SB(r2,Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('R val, OB-AuCx'), ylim([-1 1])
makepretty_BM2

subplot(133)
MakeSpreadAndBoxPlot3_SB(r3,Cols,X,Legends,'showpoints',1,'paired',0);
ylabel('R val, PFCx-AuCx'), ylim([-1 1])
makepretty_BM2

