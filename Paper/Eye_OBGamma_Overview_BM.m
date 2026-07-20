
clear all
session_list = GetHeadRestraintSessions_Ferret_BM;
smootime = 3;

for i=1:length(session_list)
    load([session_list{i} '/DLC/DLC_data.mat'], 'areas_pupil_tsd')
    load([session_list{i} '/SleepScoring_OBGamma.mat'], 'SmoothGamma')
    load([session_list{i} '/SleepScoring_OBGamma.mat'], 'Wake','SWSEpoch','REMEpoch')
    
    clear D1 D2
    D1 = zscore(Data(areas_pupil_tsd));
    D1(movstd(zscore(Data(areas_pupil_tsd)),10)>.5) = NaN;
    D1 = movmean(D1,ceil(smootime/median(diff(Range(areas_pupil_tsd,'s')))),'omitnan');
    TSD1 = tsd(Range(areas_pupil_tsd) , D1);

    D2 = zscore(log10(Data(Restrict(SmoothGamma,areas_pupil_tsd))));
    D2(movstd(D2,10)>.2) = NaN;
    D2 = movmean(D2,ceil(smootime/median(diff(Range(areas_pupil_tsd,'s')))),'omitnan');
    TSD2 = tsd(Range(areas_pupil_tsd) , D2);
    
    OccupMap_All(i,:,:) = hist2d([Data(TSD1) ;-2; -2; 2; 2] , [Data(TSD2) ;-2; 2; -2; 2] , 100 , 100);
    OccupMap_Wake(i,:,:) = hist2d([Data(Restrict(TSD1 , Wake)) ;-2; -2; 2; 2] , [Data(Restrict(TSD2 , Wake)) ;-2; 2;-2; 2] , 100 , 100);
    OccupMap_NREM(i,:,:) = hist2d([Data(Restrict(TSD1 , SWSEpoch)) ;-2; -2; 2; 2] , [Data(Restrict(TSD2 , SWSEpoch)) ;-2; 2;-2; 2] , 100 , 100);
    OccupMap_REM(i,:,:) = hist2d([Data(Restrict(TSD1 , REMEpoch)) ;-2; -2; 2; 2] , [Data(Restrict(TSD2 , REMEpoch)) ;-2; 2;-2; 2] , 100 , 100);
        
    [r_All(i), p_All(i)] = corr(Data(TSD1) , Data(TSD2));
    [r_Wake(i), p_Wake(i)] = corr(Data(Restrict(TSD1 , Wake)) , Data(Restrict(TSD2 , Wake)));
    [r_NREM(i), p_NREM(i)] = corr(Data(Restrict(TSD1 , SWSEpoch)) , Data(Restrict(TSD2 , SWSEpoch)));
    [r_REM(i), p_REM(i)] = corr(Data(Restrict(TSD1 , REMEpoch)) , Data(Restrict(TSD2 , REMEpoch)));
    
    disp(i)
end
OccupMap_All = OccupMap_All./sum(sum(OccupMap_All,3),2);
OccupMap_Wake = OccupMap_Wake./sum(sum(OccupMap_Wake,3),2);
OccupMap_NREM = OccupMap_NREM./sum(sum(OccupMap_NREM,3),2);
OccupMap_REM = OccupMap_REM./sum(sum(OccupMap_REM,3),2);


%% figures
figure
subplot(141)
imagesc(linspace(-2,3,100) , linspace(-2,2,100) , runmean(runmean(squeeze(nanmean(OccupMap_All))',2)',2)'), axis xy
axis square, xlabel('pupil size (zscore)'), ylabel('OB gamma (zscore)')
title('All')

subplot(142)
imagesc(linspace(-2,3,100) , linspace(-2,2,100) , runmean(runmean(squeeze(nanmean(OccupMap_Wake))',2)',2)'), axis xy
axis square, xlabel('pupil size (zscore)')
title('Wake')

subplot(143)
imagesc(linspace(-2,3,100) , linspace(-2,2,100) , runmean(runmean(squeeze(nanmean(OccupMap_NREM))',2)',2)'), axis xy
axis square, xlabel('pupil size (zscore)')
title('NREM')

subplot(144)
imagesc(linspace(-2,3,100) , linspace(-2,2,100) , runmean(runmean(squeeze(nanmean(OccupMap_REM))',2)',2)'), axis xy
axis square, xlabel('pupil size (zscore)')
title('REM')

colormap viridis




figure
for i=1:24
   subplot(4,6,i)
   imagesc(linspace(-2,2,100) , linspace(-2,2,100) , squeeze(OccupMap_All(i,:,:))'), axis xy
%    vline(2.5), hline(2.5)
end
figure
for i=1:24
   subplot(4,6,i)
   imagesc(linspace(-2,2,100) , linspace(-2,2,100) , squeeze(OccupMap_Wake(i,:,:))'), axis xy
%    vline(2.5), hline(2.5)
end


Cols = {[.3 .3 .3],[0 0 1],[1 0 0],[0 1 0]};
X = 1:4;
Legends = {'All','Wake','NREM','REM'};

     
    [r_All(i), p_All(i)] = corr(Data(TSD1) , Data(TSD2));
    [r_Wake(i), p_Wake(i)] = corr(Data(Restrict(TSD1 , Wake)) , Data(Restrict(TSD1 , Wake)));
    [r_NREM(i), p_NREM(i)] = corr(Data(Restrict(TSD1 , SWSEpoch)) , Data(Restrict(TSD1 , SWSEpoch)));
    [r_REM(i), p_REM(i)] = corr(Data(Restrict(TSD1 , REMEpoch)) , Data(Restrict(TSD1 , REMEpoch)));
 
figure
subplot(121)
   MakeSpreadAndBoxPlot3_SB({r_All r_Wake r_NREM r_REM},Cols,X,Legends,'showpoints',1,'paired',0);

%% tools

figure
D = zscore(Data(areas_pupil_tsd));
D(movstd(D,10)>.5) = NaN;
plot(Range(areas_pupil_tsd,'s') , movmean(D,ceil(smootime/median(diff(Range(areas_pupil_tsd,'s')))),'omitnan'))
hold on
clear D, D = zscore(Data(Restrict(SmoothGamma,areas_pupil_tsd)));
D(movstd(D,10)>.2) = NaN;
plot(Range(areas_pupil_tsd,'s') , movmean(D,ceil(smootime/median(diff(Range(areas_pupil_tsd,'s')))),'omitnan'))




figure
plot(movstd(zscore(Data(areas_pupil_tsd)),10))

figure
plot(Range(areas_pupil_tsd,'s') , zscore(Data(areas_pupil_tsd)))
hold on
plot(Range(areas_pupil_tsd,'s') , D)


