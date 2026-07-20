

clear all

Dir{1} = PathForExperimentsOB({'Labneh'}, 'head-fixed','none');
Dir{2} = PathForExperimentsOB({'Brynza'}, 'head-fixed','none');

Dir1 = PathForExperimentsOB({'Shropshire'}, 'head-fixed','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'head-fixed','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);

%%
smootime = 10;
load([Dir{1}.path{1} filesep '/DLC/DLC_data.mat'], 'areas_pupil')
bin = median(diff(Range(areas_pupil,'s')));

for ferret=1:3
    for sess=1:length(Dir{ferret}.path)
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SWSEpoch')
        if sum(DurationEpoch(SWSEpoch))/3600e4>1
            
            load([Dir{ferret}.path{sess} filesep '/DLC/DLC_data.mat'], 'areas_pupil')
            load([Dir{ferret}.path{sess} filesep '/SleepScoring_OBGamma.mat'], 'SmoothGamma')
            
            clear D1 D2
            D1 = zscore(Data(areas_pupil));
            D1(movstd(zscore(Data(areas_pupil)),10)>.5) = NaN;
            D1 = movmean(D1,ceil(smootime/median(diff(Range(areas_pupil,'s')))),'omitnan');
            TSD1 = tsd(Range(areas_pupil) , D1);
            
            D2 = zscore(log10(Data(Restrict(SmoothGamma,areas_pupil))));
            D2(movstd(D2,10)>.2) = NaN;
            D2 = movmean(D2,ceil(smootime/median(diff(Range(areas_pupil,'s')))),'omitnan');
            TSD2 = tsd(Range(areas_pupil) , D2);
            
            [r{ferret}(sess,:) , lags] = xcorr(Data(TSD1) , Data(TSD2) , round(3000/bin) , 'coeff');
            
            disp([ferret sess])
        end
    end
    r{ferret}(r{ferret}==0) = NaN;
end



figure
for ferret=1:3
    subplot(1,3,ferret)
    Data_to_use = r{ferret};
    Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
    h=shadedErrorBar((lags/10)/60 , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
    xlim([-50 50]), ylim([-.2 .7]); xlabel('time (min)'), vline(0,'--k')
    if ferret==1, ylabel('R values'), end
    makepretty
end


figure, ferret=1;
subplot(211)
Data_to_use = r{ferret};
Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
h=shadedErrorBar((lags/10)/60 , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
xlim([-50 50]), ylim([-.2 .7]); xlabel('time (min)'), vline(0,'--k')
ylabel('R values')
makepretty

subplot(212)
imagesc((lags/10)/60 , [1:size(r{ferret},1)] ,r{ferret}), colormap viridis
xlabel('time (min)'), ylabel('# sess')
makepretty



