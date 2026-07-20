
%% beautiful example
clear all

% sessions
Dir1 = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);

ferret=3; sess=5;
load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'Epoch','TotalNoiseEpoch', 'SmoothGamma')
SmoothGamma = Restrict(SmoothGamma , or(intervalSet(0 , 2e7) , intervalSet(10e7 , 15e7)));
% SmoothGamma = Restrict(SmoothGamma , intervalSet(0 , 1.5e7));
Smooth_Gamma{ferret}{sess} = SmoothGamma;


D = log10(Data(Smooth_Gamma{ferret}{sess}));
[gamma_thresh,~,~,~,~,AshD] = GetGaussianThresh_BM(D, 0, 1), %close

figure
D = log10(Data(Smooth_Gamma{ferret}{sess}));
h=histogram(D,'BinLimits',[1.9 3.1],'NumBins',100); hold on
h.FaceColor=[.3 .3 .3];
xlabel('OB gamma power (log)'), ylabel('PDF'), xlim([1.9 3.1]), ylim([0 1e6])
yticks([0:3e5:18e5]), yticklabels({'0','.02','.04','.06','.08','.10','.12'})
v=vline(gamma_thresh,'--r'); v.LineWidth=3;
text(2,18e5,'Sleep','FontSize',15), text(2.7,18e5,'Wake','FontSize',15)
makepretty, axis square

% MATLAB script: Plot 5 bimodal distributions with Ashman's D = 0 to 4
x = linspace(-15, 30, 1000);
sigma = 2;
mu1 = 0;
D_vals = 0:4;
delta_mu = D_vals * sqrt(2*(sigma^2 + sigma^2));  % Δμ = D * sqrt(4σ²) = D * 2σ

figure;
for i = 1:length(D_vals)
    mu2 = mu1 + delta_mu(i);
    dist = 0.5 * normpdf(x, mu1, sigma) + 0.5 * normpdf(x, mu2, sigma);

    subplot(5, 1, i)
    plot(x, dist, 'k', 'LineWidth', 2);
    title(['Ashman''s D = ', num2str(D_vals(i))]);
    xlabel('Value');
    ylabel('Density');
    ylim([0, max(dist)*1.1]);
    box off;
end


%% intra-variability across sessions
clear all
Dir{1} = PathForExperimentsOB({'Shropshire'}, 'freely-moving', 'none');
drug=1;

n=1;
while n<11
    for sess=1:20
        clear SmoothGamma
        load([Dir{drug}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'Epoch','TotalNoiseEpoch')
        tot_dur = sum(DurationEpoch(or(Epoch , TotalNoiseEpoch)))./3600e4;
        if tot_dur>4
            load([Dir{drug}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SmoothGamma', 'Info')
            Smooth_Gamma{n} = SmoothGamma;
%             Gamma_Tresh(n) = Info.gamma_thresh;
            n=n+1;
            disp(n)
        end
    end
end

figure
for i=1:10
    D = log10(Data(Smooth_Gamma{i}));
    h=histogram(D,'BinLimits',[1.8 3.1],'NumBins',200); hold on
    HistData(i,:) = h.Values./sum(h.Values);
end
close

figure
for i=1:10
    clf
    D = log10(Data(Smooth_Gamma{i}));
    [gamma_thresh(i) , mu(i)] = GetGaussianThresh_BM(D, 0, 1);
end

l = linspace(.01,.05,10);
figure
for i=1:10
    plot(linspace(1.8,3.1,200)-mu(i) , HistData(i,:)' , 'k')
    hold on
    plot(gamma_thresh(i)-mu(i) , l(i) , '*r')
end
xlabel('OB gamma power (log)'), ylabel('PDF'), xlim([-.25 .85])
makepretty, axis square


%% inter-variability
clear all

% sessions
Dir1 = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);

% data
for ferret=1:3
    n=1;
    while n<11
        for sess=1:length(Dir{ferret}.path)
            clear SmoothGamma
            load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'Epoch','TotalNoiseEpoch')
            tot_dur = sum(DurationEpoch(or(Epoch , TotalNoiseEpoch)))./3600e4;
            if tot_dur>2
                load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SmoothGamma', 'Info')
                Smooth_Gamma{ferret}{n} = SmoothGamma;
                n=n+1;
                disp(n)
            end
        end
    end
end


figure
for ferret=2%1:3
    for i=1:length(Smooth_Gamma{ferret})
        clf
        D = log10(Data(Smooth_Gamma{ferret}{i}));
        [gamma_thresh{ferret}(i),~,~,~,~,AshD{ferret}(i)] = GetGaussianThresh_BM(D, 1, 1);
    end
end
AshD{3}([2 6 8 9 10 12:17]) = NaN;
AshD{2}([1 2 6:9]) = NaN;
AshD{1}([2 9]) = NaN;
    
% figures
Cols = {[.2 .5 .8],[.8 .5 .2],[.5 .2 .8]};
X = 1:3;
Legends = {'F1','F2','F3'};

figure
PlotErrorBarN_KJ(AshD,'barcolors',Cols,'x_data',X,'showPoints',1,'newfig',0,'paired',0,'size_points',20);
ylabel('Bimodality index')
set(gca,'XTick',X,'XtickLabel',Legends)
makepretty_BM2, axis square





%% different smoothing
clear all

% sessions
Dir1 = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);

ferret=3; n=5; sess=5;
cd(Dir{ferret}.path{sess})

n=1; Frequency = [40 60];
load('ChannelsToAnalyse/Bulb_deep.mat')
load(strcat(['LFPData/LFP',num2str(channel),'.mat']));
for w = [.03 .3 3]
    FilGamma = FilterLFP(LFP,Frequency,1024); % filtering
    tEnveloppeGamma = tsd(Range(LFP), abs(hilbert(Data(FilGamma))) ); %tsd: hilbert transform then enveloppe
    SmoothGamma = tsd(Range(tEnveloppeGamma), runmean(Data(tEnveloppeGamma), ...
        ceil(w/median(diff(Range(tEnveloppeGamma,'s'))))));
    Smooth_Gamma{n} = SmoothGamma;
    n = n+1;
end

figure
for i=1:3
    h=histogram(log10(Data(Smooth_Gamma{i})),'BinLimits',[1.7 3.2],'NumBins',100);
    HistData(i,:) = h.Values;
end
clf


plot(linspace(1.7,3.2,100) , runmean(HistData(1,:),1) , 'Color' , [.3 .3 .3] , 'LineWidth' , 4)
hold on
plot(linspace(1.7,3.2,100) , runmean(HistData(2,:),1) , 'Color' , [.8 .5 .5] , 'LineWidth' , 4)
plot(linspace(1.7,3.2,100) , runmean(HistData(3,:),1) , 'Color' , [.8 .2 .2] , 'LineWidth' , 4)
xlim([1.7 3.2]), legend('0.03s','0.3s','3s'), xlabel('Gamma power (a.u.)'), ylabel('PDF')
makepretty, axis square




%% intra-variability accross electrodes
clear all
smootime = 3;
Frequency = [40 60];
Cols = {[0.1, 0.4, 0.9],[0.95, 0.45, 0.1],[0.2, 0.7, 0.3],[0.6, 0.3, 0.75]};
ind = 20:23;

cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20250107_LSP_saline')
for l=ind
    load([pwd '/LFPData/LFP' num2str(l) '.mat'])
    FilGamma = FilterLFP(LFP,Frequency,1024); % filtering
    tEnveloppeGamma = tsd(Range(LFP), abs(hilbert(Data(FilGamma))) ); %tsd: hilbert transform then enveloppe
    SmoothGamma{l} = tsd(Range(tEnveloppeGamma), runmean(Data(tEnveloppeGamma), ...
        ceil(smootime/median(diff(Range(tEnveloppeGamma,'s'))))));
    h=histogram(log10(Data(SmoothGamma{l})),'BinLimits',[1.7 3.2],'NumBins',200);
    HistData(l,:) = h.Values;
end


figure
for i=1:length(ind)
    clf
    D = log10(Data(SmoothGamma{ind(i)}));
    [gamma_thresh(i) , mu(i), mu2(i)] = GetGaussianThresh_BM(D, 0, 1); close
end
close

figure
for i=1:length(ind)
    plot(linspace(1.8,3.1,200)-mu(i) , runmean(HistData(ind(i),:)',5) , 'Color' , Cols{i} , 'LineWidth' , 2)
    hold on
end
xlabel('OB gamma power (log)'), ylabel('PDF'), xlim([-.25 .85])
legend('depth 1','depth 2','depth 3','depth 4')
makepretty_BM2, axis square


figure
for i=1:length(ind)
   v=vline(mu(i) , '-'); set(v, 'Color' , Cols{i}); v.LineWidth=2; hold on
   v2=vline(mu2(i) , '--'); set(v2, 'Color' , Cols{i}); v2.LineWidth=2;
end
xlabel('OB gamma power (log)')
makepretty_BM2, axis square


