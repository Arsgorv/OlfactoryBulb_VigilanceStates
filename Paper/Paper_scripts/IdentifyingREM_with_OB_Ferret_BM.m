


%% nice example
clear all

cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241228_LSP_saline')
load('SleepScoring_OBGamma.mat', 'SmoothGamma_wide', 'SmoothTheta', 'REM_OB', 'REMEpoch', 'Wake', 'SWSEpoch', 'ISEpoch')


B1 = load([pwd filesep 'B_Middle_Spectrum.mat']);
B_High_Sptsd = tsd(B1.Spectro{2}*1e4 , B1.Spectro{1});
Range_Mid = B1.Spectro{3};

H = load([pwd filesep 'H_Low_Spectrum.mat']);
H_Sptsd = tsd(H.Spectro{2}*1e4 , H.Spectro{1});

Colors.SWS = [.8 .2 .2];
Colors.REM = [.2 .8 .2];
Colors.Wake = [.2 .2 .8];


figure
subplot(411) % OB High
clear D R, D = Data(B_High_Sptsd); D = D(1:100:end,:); R = Range(B_High_Sptsd); R = R(1:100:end);
imagesc(R/3.6e7 , B1.Spectro{3} , runmean(runmean(log10(D'),2)',50)'), axis xy
ylabel('Frequency (Hz)')
colormap viridis, ylim([30 100]), caxis([2.45 2.6]), xticklabels({''}), box off
xlim([3.1 4.6])
makepretty

PlotPerAsLine(Wake,97,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,97,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(or(SWSEpoch , ISEpoch),97,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(412)
% clear D R, D = movmean(Data(SmoothGamma_wide),10e4,'omitnan'); D(D>800) = NaN; D = D(1:100:end); R = Range(SmoothGamma_wide); R = R(1:100:end);
clear D R, D = Data(SmoothGamma_wide); D(D>800) = NaN; D = D(1:100:end); R = Range(SmoothGamma_wide); R = R(1:100:end);
plot(R/3.6e7 , D , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothGamma_wide,'s')/3.6e3)]),  ylim([0 900]), xticklabels({''})
box off
ylabel('50-70Hz power (a.u.)')
xlim([3.1 4.6]), ylim([140 200])
makepretty

subplot(413) % HPC 
imagesc(Range(H_Sptsd)/3.6e7 , H.Spectro{3} , runmean(runmean(log10(Data(H_Sptsd)'),5)',50)'), axis xy
ylabel('Frequency (Hz)'), ylim([0 10]), caxis([3.5 5]), xticklabels({''}), box off
xlim([3.1 4.6])
makepretty

PlotPerAsLine(Wake,9.5,Colors.Wake,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(REMEpoch,9.5,Colors.REM,'timescaling',3.6e7,'linewidth',10);
PlotPerAsLine(or(SWSEpoch , ISEpoch),9.5,Colors.SWS,'timescaling',3.6e7,'linewidth',10);

subplot(414)
clear R D, D = Data(SmoothTheta); D(D>14.5) = NaN; D = D(1:100:end); R = Range(SmoothTheta); R = R(1:100:end);
% clear R D, D = movmean(Data(SmoothTheta),1e4,'omitnan'); D(D>14.5) = NaN; D = D(1:100:end); R = Range(SmoothTheta); R = R(1:100:end);
plot(R/3.6e7 , D , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothTheta,'s')/3.6e3)]), ylim([0 12]), xlim([3.1 4.6])
box off
ylabel('Theta power (a.u.)'), xlabel('Time (hours)')
makepretty


%% all together
clear all

Dir1 = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);


% concatenate
for ferret=1:3
    i=1;
    for sess=1:length(Dir{ferret}.path)
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SmoothTheta','Sleep','SWSEpoch','REMEpoch')
        
        if sum(DurationEpoch(SWSEpoch))/3600e4>1 % session with enough sleep
            clear REM_OB
            try % load if already done
                load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'REM_OB')
                REM_OB;
            catch % compute if not done
                smootime = 30;
                load([Dir{ferret}.path{sess} filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
                load([Dir{ferret}.path{sess} filesep 'LFPData/LFP' num2str(channel) '.mat'])
                LFP = Restrict(LFP , Sleep);
                FilGamma = FilterLFP(LFP,[50 75],1024);
                hilbert_gamma = abs(hilbert(Data(FilGamma)));
                SmoothGamma_wide = tsd(Range(LFP),runmean(hilbert_gamma,ceil(smootime/median(diff(Range(LFP,'s'))))));
                theta_thresh = GetGammaThresh(Data(SmoothGamma_wide), 1, 1); close
                REM_OB = thresholdIntervals(SmoothGamma_wide, exp(theta_thresh), 'Direction','Above');
                REM_OB = mergeCloseIntervals(REM_OB , 10e4);
                REM_OB = dropShortIntervals(REM_OB , 60e4);
                
                save([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SmoothGamma_wide','REM_OB','-append')
            end
            Recall{ferret}(i) = sum(DurationEpoch(and(REM_OB , REMEpoch)))./sum(DurationEpoch(REMEpoch));
            Precision{ferret}(i) = sum(DurationEpoch(and(REM_OB , REMEpoch)))./sum(DurationEpoch(REM_OB));
            
            i=i+1;
            disp(Dir{ferret}.path{sess})
        end
    end
end
% bad REM detection with HPC
Recall{3}([2 5 7]) = NaN;
Precision{3}([2 5 7]) = NaN;

% figures
Cols    = {[.5 .5 .5],[.3 .3 .3]};
X       = 1:2;
Legends = {'Overlap / REM_H_P_C','Overlap / REM_O_B'};

figure
for ferret=1:3
    subplot(1,3,ferret)
    MakeSpreadAndBoxPlot3_SB({Recall{ferret} Precision{ferret}}, Cols, X, Legends,'showpoints',1,'paired',0)
    ylim([0 1])
end

ferret = 3;
figure
MakeSpreadAndBoxPlot3_SB({Recall{ferret} Precision{ferret}}, Cols, X, Legends,'showpoints',1,'paired',0)
ylabel('Proportion'), ylim([0 1])
makepretty_BM2







%% old
% distributions figures
figure, hold on

[Y,X] = hist(log10(Data(Restrict(SmoothGamma_wide , Sleep))),200);
Y = Y/sum(Y);
subplot(121)
plot(X,Y,'k')
xlim([2.12 2.32]), ylim([0 .035])
box off
xlabel('OB gamma power, sleep (a.u.)'), ylabel('PDF')
v=vline(2.24,'--r');

[Y,X] = hist(log10(Data(Restrict(SmoothTheta , Sleep))),200);
Y = Y/sum(Y);
subplot(122)
plot(X,Y,'k')
xlim([-.5 1.3]), ylim([0 .015])
box off
xlabel('HPC theta power, sleep (a.u.)')
v=vline(.566,'--r');

