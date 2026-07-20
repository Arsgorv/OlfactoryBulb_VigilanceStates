

clear all

Dir2 = PathForExperimentsOB({'Labneh'}, 'head-fixed','none');
Dir{1} = Dir2;

Dir2 = PathForExperimentsOB({'Brynza'}, 'head-fixed','none');
Dir{2} = Dir2;

Dir1 = PathForExperimentsOB({'Shropshire'}, 'head-fixed','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'head-fixed','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);


%% collect data
for ferret = 1:3
    for sess = 1:length(Dir{ferret}.path)
        clear Wake Sleep RespRate_tsd RespRateVar_tsd
        cd(Dir{ferret}.path{sess})
        try
            load('SleepScoring_OBGamma.mat', 'RespRate_tsd', 'RespRateVar_tsd')
            RespRate_tsd;
        catch
            MakeRespi_ForSession_Ferret
            load('SleepScoring_OBGamma.mat', 'RespRate_tsd', 'RespRateVar_tsd')
        end
        load('SleepScoring_OBGamma.mat', 'Wake','Sleep','Epoch')
        
        if (sum(DurationEpoch(Epoch))/1e4)>1e4
            RespRate_tsd = Restrict(RespRate_tsd , Epoch);
            RespRateVar_tsd = Restrict(RespRateVar_tsd , Epoch);
            
            MeanRespi{ferret}{1}(sess)    = nanmean(Data(Restrict(RespRate_tsd    , Wake)));
            MeanRespi{ferret}{2}(sess)    = nanmean(Data(Restrict(RespRate_tsd    , Sleep)));
            MeanRespiVar{ferret}{1}(sess) = nanmean(Data(Restrict(RespRateVar_tsd , Wake)));
            MeanRespiVar{ferret}{2}(sess) = nanmean(Data(Restrict(RespRateVar_tsd , Sleep)));
            
            % histograms normalized per session
            h = histogram(Data(Restrict(RespRate_tsd , Wake)),  'BinLimits',[.3 2],'NumBins',100);  Hw = h.Values;  delete(h);
            h = histogram(Data(Restrict(RespRate_tsd , Sleep)), 'BinLimits',[.3 2],'NumBins',100);  Hs = h.Values;  delete(h);
            
            if sum(Hw)>0, Hw = Hw./sum(Hw); end
            if sum(Hs)>0, Hs = Hs./sum(Hs); end
            
            HistData_wake{ferret}(sess,:)  = Hw;
            HistData_sleep{ferret}(sess,:) = Hs;
        else
            HistData_wake{ferret}(sess,1:100)  = NaN;
            HistData_sleep{ferret}(sess,1:100) = NaN;
        end
        disp(Dir{ferret}.path{sess})
    end
    MeanRespi{ferret}{1}(MeanRespi{ferret}{1}==0) = NaN;
    MeanRespi{ferret}{2}(MeanRespi{ferret}{2}==0) = NaN;
    MeanRespiVar{ferret}{1}(MeanRespiVar{ferret}{1}==0) = NaN;
    MeanRespiVar{ferret}{2}(MeanRespiVar{ferret}{2}==0) = NaN;
end


%% plotting with side distributions (vertical)
Cols    = {[0 0 1],[.3 .3 .3]};   % Wake, Sleep
X       = 1:2;
Legends = {'Wake','Sleep'};

ferret = 1;   % choose the ferret you want to display

% Build average histograms for this ferret (use only sessions that have data)
edges   = linspace(0.3, 2, 101);
centers = (edges(1:end-1) + edges(2:end))/2;

Hw_all = [];
Hs_all = [];
if ~isempty(HistData_wake) && length(HistData_wake)>=ferret && ~isempty(HistData_wake{ferret})
    M = HistData_wake{ferret};
    if ~isempty(M)
        idx = sum(M,2)>0;
        Hw_all = nanmean(M(idx,:),1);
    end
end
if ~isempty(HistData_sleep) && length(HistData_sleep)>=ferret && ~isempty(HistData_sleep{ferret})
    M = HistData_sleep{ferret};
    if ~isempty(M)
        idx = sum(M,2)>0;
        Hs_all = nanmean(M(idx,:),1);
    end
end

% Normalize densities (per condition) to max=1, for width scaling
if ~isempty(Hw_all) && max(Hw_all)>0, Hw_plot = Hw_all./max(Hw_all); else, Hw_plot = []; end
if ~isempty(Hs_all) && max(Hs_all)>0, Hs_plot = Hs_all./max(Hs_all); else, Hs_plot = []; end

figure

% --- Mean respiration (Hz) with side distributions ---
subplot(1,2,1)
MakeSpreadAndBoxPlot3_SB(MeanRespi{ferret}, Cols, X, Legends, ...
    'showpoints',0,'paired',1,'size_points',10)
hold on
ylabel('Breathing (Hz)')
ylim([.3 1.8]), y_l = ylim;
makepretty_BM2

% Side “violins” (vertical shaded histograms) next to categories
width = 0.35;  % half-width of the shaded distribution

subplot(122)
% Wake at x=1
if ~isempty(Hw_plot)
    x_left  = 1 - width*Hw_plot;
    x_right = 1 + width*Hw_plot;
    xp = [x_left, fliplr(x_right)];
    yp = [centers, fliplr(centers)];
    p1 = patch(xp, yp, Cols{1}, 'EdgeColor','k','LineWidth',1); set(p1,'FaceAlpha',0.25);
end
% Sleep at x=2
if ~isempty(Hs_plot)
    x_left  = 1 - width*Hs_plot;
    x_right = 1 + width*Hs_plot;
    xp = [x_left, fliplr(x_right)];
    yp = [centers, fliplr(centers)];
    p2 = patch(xp, yp, Cols{2}, 'EdgeColor','k','LineWidth',1); set(p2,'FaceAlpha',0.25);
end
xlim([1 1.5]), ylim(y_l)
xticklabels({''}), yticklabels({''}), axis off

set(gca,'Layer','top')  % keep box/axes above patches




figure
for f=1:3
    subplot(1,3,f)
    MakeSpreadAndBoxPlot3_SB(MeanRespi{f}, Cols, X, Legends,'showpoints',0,'paired',1,'size_points',10)
    ylim([.5 1.4])
    if f==1, ylabel('Breathing (Hz)'), end
    makepretty_BM2
    title(['Ferret ' num2str(f)])
end












%% need to improve heart rate
Dir = PathForExperimentsOB({'Labneh'}, 'head-fixed','none');
ferret = 1;

for sess=3%1:length(Dir{ferret}.path)
    try
        load([Dir.path{sess} filesep 'SleepScoring_OBGamma.mat'],  'Wake', 'Sleep')
        load([Dir.path{sess} filesep 'HeartBeatInfo.mat'])
    end
end

HRVar = tsd(Range(EKG.HBRate),movstd(Data(EKG.HBRate),5));
                
HR_Wake  = Restrict(EKG.HBRate , Wake);
HR_Sleep  = Restrict(EKG.HBRate , Sleep);

HRVar_Wake  = Restrict(HRVar , Wake);
HRVar_Sleep  = Restrict(HRVar , Sleep);

% figures
Cols={[0 0 1],[.3 .3 .3]};
X = 1:2;
Legends = {'Wake','Sleep'};

figure
subplot(121)
D{1} = Data(HR_Wake)*60;
D{2} = Data(HR_Sleep)*60;
MakeSpreadAndBoxPlot3_SB(D,Cols,X,Legends,'showpoints',0,'paired',0)
ylabel('Heart beat / min'),% ylim([25 50])
makepretty_BM2

subplot(122)
D{1} = Data(HRVar_Wake)*60;
D{2} = Data(HRVar_Sleep)*60;
MakeSpreadAndBoxPlot3_SB(D,Cols,X,Legends,'showpoints',0,'paired',0)
ylabel('Heart rate variability'),% ylim([25 50])
makepretty_BM2


%% old
Cols={[0 0 1],[1 .5 0],[1 0 0],[0 1 0]};
X = 1:4;
Legends = {'Wake','IS','NREM','REM'};
NoLegends = {'','','',''};

figure
D{1} = Data(HR_Wake)*60;
D{2} = Data(HR_N1)*60;
D{3} = Data(HR_N2)*60;
D{4} = Data(HR_REM)*60;
MakeSpreadAndBoxPlot3_SB(D,Cols,X,Legends,'showpoints',0,'paired',0)
ylabel('Heart beat / min')
makepretty_BM2

figure
D{1} = Data(HRVar_Wake);
D{2} = Data(HRVar_N1);
D{3} = Data(HRVar_N2);
D{4} = Data(HRVar_REM);
MakeSpreadAndBoxPlot3_SB(D,Cols,X,Legends,'showpoints',0,'paired',0)
ylabel('Heart rate variability')
makepretty_BM2


