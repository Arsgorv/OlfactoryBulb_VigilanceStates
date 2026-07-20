
clear all

% cond = 'freely-moving';
cond = 'head-fixed';

% freely moving
Dir1 = PathForExperimentsOB({'Labneh'}, cond,'saline');
Dir2 = PathForExperimentsOB({'Labneh'}, cond,'none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, cond,'saline');
Dir2 = PathForExperimentsOB({'Brynza'}, cond,'none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, cond,'saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, cond,'none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);


% head fixed
Dir{1} = PathForExperimentsOB({'Labneh'}, cond,'none');
Dir{2} = PathForExperimentsOB({'Brynza'}, cond,'none');
Dir{3} = PathForExperimentsOB({'Shropshire'}, cond,'none');


%% initialization
max_lag = 1e4; % in s
% max_lag = 1e3; % in s
sm_win = 100; % in s
smootime = 5; % in s
max_dur = [10 10 5];

%%
state=1;
for ferret=1:3
    n{ferret}(state) = 1;
    for sess=1:length(Dir{ferret}.path)
        clear SmoothGamma TotalNoiseEpoch Wake REMEpoch SWSEpoch
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'],...
            'TotalNoiseEpoch', 'Wake', 'REMEpoch', 'SWSEpoch', 'Epoch_01_05')
        
        if sum(DurationEpoch(SWSEpoch))/3600e4>1
            load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'],'SmoothGamma')
            Var{1} = tsd(Range(SmoothGamma) , runmean(Data(SmoothGamma),ceil(smootime/median(diff(Range(SmoothGamma,'s'))))));
            
            bin = median(diff(Range(Var{1},'s')))*100;
            if round(bin,2)==.05
                load([Dir{ferret}.path{sess} filesep 'LFPData/LFP6.mat'])
                Var{1} = Restrict(Var{1} , LFP);
                bin = .08;
            end
            
            Wake = or(Wake , TotalNoiseEpoch);
            Wake = mergeCloseIntervals(Wake , 5e4);
            SWSEpoch = mergeCloseIntervals(SWSEpoch , 10e4);
            REMEpoch = mergeCloseIntervals(REMEpoch , 10e4);
            
            for states=1:3
                if states==1
                    State = Wake;
                elseif states==2
                    State = SWSEpoch;
                elseif states==3
                    State = REMEpoch;
                end
                
                for ep=1:length(Start(State))
                    if DurationEpoch(subset(State,ep))>max_dur(states)*60e4
                        
                        try
                            for var=1:length(Var)
                                TSD = Restrict(Var{var} , subset(State,ep));
                                D = log10(Data(TSD)); D = D(1:100:end); D = D(abs(zscore(D))<6);
                                D = moving_zscore(D , round(sm_win/bin));
                                R = Range(TSD,'s');
                                [r{ferret}{states}{var}(n{ferret}(state),:) , lag] = xcorr(D(~isnan(D)) , round(max_lag/bin) , 'coeff');
                            end
                            n{ferret}(state)=n{ferret}(state)+1;
                        end
                    end
                end
                try, r{ferret}{states}{var}(r{ferret}{states}{var}==0)=NaN; end
            end
        end
        disp(sess)
    end
end
r{ferret}{1}{3}([30 36],:) = NaN;
r{ferret}{1}{2}([6 7 9 10],:) = NaN;

for var=1:length(Var)
    for ferret=1:3
        for states=1:3
            r{ferret}{states}{var}(sum(isnan(r{ferret}{states}{var}'))==size(r{ferret}{states}{var},2),:) = [];
        end
    end
end




% head fixed
state=1;
for ferret=1:3
    n{ferret}(state) = 1;
    for sess=1:length(Dir{ferret}.path)
        clear SmoothGamma TotalNoiseEpoch Epoch areas_pupil_tsd
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'],...
            'Epoch' , 'TotalNoiseEpoch')
        
        if sum(DurationEpoch(Epoch))/600e4>1
            load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'],'SmoothGamma')
            Var{1} = tsd(Range(SmoothGamma) , runmean(Data(SmoothGamma),ceil(smootime/median(diff(Range(SmoothGamma,'s'))))));
            load([Dir{ferret}.path{sess} filesep 'HeartBeatInfo.mat'], 'EKG')
            Var{2} = Restrict(tsd(Range(EKG.HBRate) , runmean(Data(EKG.HBRate),ceil(smootime/median(diff(Range(EKG.HBRate,'s')))))) , SmoothGamma);
            try
                load([Dir{ferret}.path{sess} filesep 'DLC/DLC_data.mat'], 'areas_pupil_tsd')
                Var{3} = Restrict(tsd(Range(areas_pupil_tsd) , runmean(Data(areas_pupil_tsd),ceil(smootime/median(diff(Range(areas_pupil_tsd,'s')))))) , SmoothGamma);
            end
            try, Var{1} = Restrict(Var{1} , Var{3}); end
            try, Var{1} = Restrict(Var{2} , Var{3}); end
            
            bin = median(diff(Range(Var{1},'s')))*100;
            if round(bin,2)==.05
                load([Dir{ferret}.path{sess} filesep 'LFPData/LFP6.mat'])
                Var{1} = Restrict(Var{1} , LFP);
                bin = .08;
            end
            
            for states=1
                State = or(Epoch , TotalNoiseEpoch);
                State = mergeCloseIntervals(State , 2e4);
                
                for ep=1:length(Start(State))
                    if DurationEpoch(subset(State,ep))>max_dur(states)*60e4
                        clear D
                        try
                            for var=1:length(Var)
                                try
                                    TSD = Restrict(Var{var} , subset(State,ep));
                                    D{var} = log10(Data(TSD)); D{var} = D{var}(1:100:end); D{var} = D{var}(abs(zscore(D{var}))<6);
                                    D{var} = moving_zscore(D{var} , round(sm_win/bin));
                                    R = Range(TSD,'s');
                                    [r{ferret}{states}{var}(n{ferret}(state),:) , lag] = xcorr(D{var}(~isnan(D{var})) , round(max_lag/bin) , 'coeff');
                                end
                            end
                            try, [r_inter{ferret}{states}{1}(n{ferret}(state),:) , lag] = xcorr(D{1}(~isnan(D{1})) , D{2}(~isnan(D{2})) , 'coeff'); end
                            try, [r_inter{ferret}{states}{2}(n{ferret}(state),:) , lag] = xcorr(D{1}(~isnan(D{1})) , D{3}(~isnan(D{3})) , 'coeff'); end
                            try, [r_inter{ferret}{states}{3}(n{ferret}(state),:) , lag] = xcorr(D{1}(~isnan(D{2})) , D{3}(~isnan(D{3})) , 'coeff'); end
                            
                            n{ferret}(state)=n{ferret}(state)+1;
                        end
                    end
                end
                try, r{ferret}{states}{var}(r{ferret}{states}{var}==0)=NaN; end
            end
        end
        disp(sess)
    end
end

for var=1:length(Var)
    for ferret=1:3
        for states=1
            r{ferret}{states}{var}(sum(isnan(r{ferret}{states}{var}'))==size(r{ferret}{states}{var},2),:) = [];
        end
    end
end



%% figures
figure, ferret=3; var=1;
subplot(231)
Data_to_use = r{ferret}{1}{1};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar((lag*bin) , nanmean(Data_to_use) , Conf_Inter ,'-b',1); hold on;
xlabel('time (s)'), xlim([-250 250]), ylim([-.35 1]), ylabel('corr values'), title('Wake'), grid on
makepretty

subplot(232)
Data_to_use = r{ferret}{2}{1};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar((lag*bin) , nanmean(Data_to_use) , Conf_Inter ,'-r',1); hold on;
xlabel('time (s)'), xlim([-250 250]), ylim([-.35 1]), title('NREM'), grid on
makepretty

subplot(233)
Data_to_use = r{ferret}{3}{1};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar((lag*bin) , nanmean(Data_to_use) , Conf_Inter ,'-g',1); hold on;
xlabel('time (s)'), xlim([-250 250]), ylim([-.35 1]), title('REM'), grid on
makepretty


subplot(234)
imagesc((lag*bin) , [1:size(r{ferret}{1}{1},1)] , r{ferret}{1}{1}), xlim([-250 250])
xlabel('time (s)'), ylabel('trial #')
makepretty

subplot(235)
imagesc((lag*bin) , [1:size(r{ferret}{2}{1},1)] , r{ferret}{2}{1}), xlim([-250 250])
xlabel('time (s)')
makepretty

subplot(236)
imagesc((lag*bin) , [1:size(r{ferret}{3}{1},1)] , r{ferret}{3}{1}), xlim([-250 250])
xlabel('time (s)')
makepretty
colormap viridis




figure, ferret=3; var=1;
subplot(231)
Data_to_use = r{ferret}{1}{var};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar((lag*bin) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
xlabel('time (s)'), xlim([-250 250]), ylim([-.35 1]), ylabel('corr values'), title('OB gamma'), grid on
makepretty

subplot(234)
imagesc((lag*bin) , [1:size(r{ferret}{1}{var},1)] , r{ferret}{1}{var}), xlim([-250 250])
xlabel('time (s)'), ylabel('trial #')
makepretty


subplot(232), var=2;
Data_to_use = r{ferret}{1}{var};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar((lag*bin) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
xlabel('time (s)'), xlim([-250 250]), ylim([-.35 1]), title('Heart rate'), grid on
makepretty

subplot(235)
imagesc((lag*bin) , [1:size(r{ferret}{1}{var},1)] , r{ferret}{1}{var}), xlim([-250 250])
xlabel('time (s)')
makepretty


subplot(233), var=3;
Data_to_use = r{ferret}{1}{var};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar((lag*bin) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
xlabel('time (s)'), xlim([-250 250]), ylim([-.35 1]), title('Pupil size'), grid on
makepretty

subplot(236)
imagesc((lag*bin) , [1:size(r{ferret}{1}{var},1)] , r{ferret}{1}{var}), xlim([-250 250])
xlabel('time (s)')
makepretty




figure, ferret=3; var=1;
subplot(231)
Data_to_use = r_inter{ferret}{1}{var};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar((lag*bin) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
xlabel('time (s)'), xlim([-250 250]), ylim([-.35 1]), ylabel('corr values'), title('OB_g_a_m_m_a-HR'), grid on
makepretty

subplot(234)
imagesc((lag*bin) , [1:size(r_inter{ferret}{1}{var},1)] , r_inter{ferret}{1}{var}), xlim([-250 250])
xlabel('time (s)'), ylabel('trial #')
makepretty


subplot(232), var=2;
Data_to_use = r_inter{ferret}{1}{var};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar((lag*bin) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
xlabel('time (s)'), xlim([-250 250]), ylim([-.35 1]), title('OB_g_a_m_m_a-Pupil size'), grid on
makepretty

subplot(235)
imagesc((lag*bin) , [1:size(r_inter{ferret}{1}{var},1)] , r_inter{ferret}{1}{var}), xlim([-250 250])
xlabel('time (s)')
makepretty


subplot(233), var=3;
Data_to_use = r_inter{ferret}{1}{var};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar((lag*bin) , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
xlabel('time (s)'), xlim([-250 250]), ylim([-.35 1]), title('HR-Pupil size'), grid on
makepretty

subplot(236)
imagesc((lag*bin) , [1:size(r_inter{ferret}{1}{var},1)] , r_inter{ferret}{1}{var}), xlim([-250 250])
xlabel('time (s)')
makepretty





%% tools
figure
plot(Range(Restrict(SmoothGamma , Wake),'s')/60 , Data(Restrict(SmoothGamma , Wake)), '.b','MarkerSize',3)
hold on
plot(Range(Restrict(SmoothGamma , SWSEpoch),'s')/60 , Data(Restrict(SmoothGamma , SWSEpoch)), '.r','MarkerSize',3)
plot(Range(Restrict(SmoothGamma , REMEpoch),'s')/60 , Data(Restrict(SmoothGamma , REMEpoch)), '.g','MarkerSize',3)
vline(st)



figure
for i=1:10
    subplot(2,5,i)
    plot((lag*bin)/60 , r(i,:) , 'k')
    title(num2str(dur(i)))
end











