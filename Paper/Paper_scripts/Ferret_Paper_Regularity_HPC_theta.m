

%% beautiful example
clear all

cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs/')
load('SleepScoring_OBGamma.mat', 'SmoothTheta','Sleep')

% SmoothTheta = Restrict(SmoothTheta , Sleep);
SmoothTheta = SmoothTheta;

% cross-corr
fs = 1.250;
D = Data(Restrict(SmoothTheta , intervalSet(1e7 , 14e7)))';
D = D(1:1e3:end);
D = zscore_sliding(D , round(2500*fs));

[r , lags] = xcorr(D , round(25000*fs) , 'coeff');

% PSD
target_period = 17; % seconds
D = D(:) - mean(D); % remove DC
N = length(D);
nfft = 2^nextpow2(N); % big FFT
win = N; % full length window
[pxx, f] = pwelch(D, win, 0, nfft, fs);
period = 1 ./ f;
period = period/60;
period(f == 0) = NaN;


%%
figure
subplot(121)
plot(lags/(fs*60) , r , 'r' ,  'LineWidth', 1.2)
xlabel('Period (min)'), xlim([-100 100]), ylabel('Autocorr.'), ylim([-.5 1.1]), hline(0,'-k')
makepretty

subplot(122)
plot(period, pxx, 'k', 'LineWidth', 1.2);
set(gca, 'XScale', 'log');
xlabel('Period (min)'); ylabel('Power (a.u.)'); ylim([0 2700])
grid on;
[~, idx] = min(abs(period - target_period)); % Highlight 17 min
hold on;
plot(period(idx), pxx(idx), 'ro', 'LineWidth', 1.5);
xlim([target_period/10, target_period*10]);
box off



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% all ferrets
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


%% concatenate
for ferret=1:3
    for sess=1:length(Dir{ferret}.path)
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SmoothTheta','Sleep','SWSEpoch')
        
        if sum(DurationEpoch(SWSEpoch))/3600e4>1 % session with enough sleep
            
            % cross-corr
            fs = 1.250;
            if ferret==3
                D = Data(Restrict(SmoothTheta , and(Sleep , or(intervalSet(1.5e7 , 6e7) , intervalSet(9e7 , 13e7)))))';
            else
                D = Data(Restrict(SmoothTheta , Sleep));
            end
            D = D(1:1e3:end);
            D = zscore_sliding(D , round(2500*fs));
            
            if length(D)>10000
                [r{ferret}(sess,:) , lags] = xcorr(D , round(6000*fs) , 'coeff');
                
                % PSD
                target_period = 17; % min
                D = D(:) - mean(D); % remove DC
                N = 10000;
                nfft = 2^nextpow2(N); % big FFT
                win = N; % full length window
                [pxx{ferret}(sess,:), f] = pwelch(D, win, 0, nfft, fs);
                period = 1 ./ f;
                period(f == 0) = NaN;
                period = period/60;
                
                load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'REMEpoch')
                
                REMEpoch = mergeCloseIntervals(REMEpoch , 3*60e4);
                REMEpoch = dropShortIntervals(REMEpoch , 60e4);
                Dur_REM = DurationEpoch(REMEpoch)/60e4;
                Sto = Stop(REMEpoch); % start of sleep cycle
                SleepCycle = intervalSet(Sto(1:end-1) , Sto(2:end));
                Dur_SleepCyc{ferret}{sess} = DurationEpoch(SleepCycle)/60e4;
                
                disp(Dir{ferret}.path{sess})
            end
        end
    end
    r{ferret}(r{ferret}==0) = NaN;
    pxx{ferret}(pxx{ferret}==0) = NaN;
end

for ferret=1:3
    r{ferret}(sum(isnan(r{ferret}'))==length(r{ferret}),:) = [];
    pxx{ferret}(sum(isnan(pxx{ferret}'))==length(pxx{ferret}),:) = [];
end

r{1}(3,:) = NaN;
pxx{1}(3,:) = NaN;

r{2}(4,:) = NaN;
pxx{2}(4,:) = NaN;

%% ferret example
ferret = 2;

figure
subplot(121)
Data_to_use = r{ferret};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(lags/(fs*60) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
xlabel('Time (min)'), xlim([-100 100]), ylabel('Autocorrelation (Sleep)')
box off

subplot(122)
Data_to_use = pxx{ferret};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(period , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
set(gca, 'XScale', 'log');
xlabel('Period (min)'); ylabel('Power (a.u.)'); xlim([.1 300])
grid on; box off



%% all ferrets
Cols = {[.2 .5 .8],[.8 .5 .2],[.5 .2 .8]};
X = 1:3;
Legends = {'F1','F2','F3'};

for ferret=1:3
    P_all(ferret,:) = nanmean(pxx{ferret});
    [~ , idx{ferret}] = max(pxx{ferret}');
    idx{ferret}(idx{ferret}==1) = [];
    Period_max{ferret} = period(idx{ferret});
end

figure
subplot(1,5,1:2)
Data_to_use = P_all;
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar(period , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
set(gca, 'XScale', 'log');
xlabel('Period (min)'); ylabel('Power (a.u.)');
grid on; box off
xlim([.1 300])
axis square

subplot(153)
MakeSpreadAndBoxPlot3_SB(Period_max,Cols,X,Legends,'showpoints',1,'paired',0,'size_points',10);
ylabel('Period (min)'), ylim([0 40])
makepretty_BM2

subplot(1,5,4:5)
PlotCorrelations_BM([1:11] , Period_max{3})
xlabel('Session #'), ylabel('Period (min)')
axis square


%% sleep cycle duration
Dur_Sleep_Cycle_all = [];
for ferret=1:3
    Dur_Sleep_Cycle_perFerret{ferret} = [];
    for sess=1:length(Dur_SleepCyc{ferret})
        
        Dur_Sleep_Cycle_all = [Dur_Sleep_Cycle_all ; Dur_SleepCyc{ferret}{sess}];
        Dur_Sleep_Cycle_perFerret{ferret} = [Dur_Sleep_Cycle_perFerret{ferret} ; Dur_SleepCyc{ferret}{sess}];
        
    end
end

figure
histogram(Dur_Sleep_Cycle_all,'BinLimits',[0 45],'NumBins',20,'FaceColor','k')
xlabel('Time (min)'), ylabel('nb of cycles')
box off

figure
for ferret=1:3
    subplot(1,3,ferret)
    histogram(Dur_Sleep_Cycle_perFerret{ferret},'BinLimits',[0 45],'NumBins',15)
end


%% tools
% [~, idx] = min(abs(period - target_period)); % Highlight 17 min
% hold on;
% plot(period(idx), pxx(idx), 'ro', 'LineWidth', 1.5);
% xlim([target_period/10, target_period*10]);
% box off



% figure
% subplot(121)
% plot(r{ferret}')
% subplot(122)
% plot(period , pxx{ferret}'), set(gca, 'XScale', 'log');
% 
% [~, idx] = max(pxx{ferret}'); figure, plot(period(idx));
% 
% [peakVal, peakIdx] = max(r{ferret}(:,8199:end)');
% figure, subplot(121), plot(peakVal), subplot(122), plot(peakIdx)

