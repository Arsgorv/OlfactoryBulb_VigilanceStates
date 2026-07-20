

cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241205_TORCs')
load('SleepScoring_OBGamma.mat', 'Sleep','Wake')

%% display when considering states
SmoothGamma = Restrict(SmoothGamma , Mean_FR); % get data same time stamped
win_sm = 200; % sliding win_zsc for smoothing data = 20s
win_zsc = 10000;  % sliding win_zsc for zscoring = 1000s


figure
subplot(311)
r = movmean(log10(Data(SmoothGamma)) , win_sm , 'omitnan')';
[zscored_all_g] = zscore_sliding(r,win_zsc);
plot(Range(SmoothGamma , 's') , zscored_all_g)
yyaxis right
r = movmean(log10(Data(Mean_FR)) , win_sm , 'omitnan')'; r(r==-Inf) = NaN;
[zscored_all_f] = zscore_sliding(r,win_zsc);
plot(Range(Mean_FR , 's') , zscored_all_f)

subplot(312)
r = movmean(log10(Data(Restrict(SmoothGamma , Wake))) , win_sm , 'omitnan')';
[zscored_wake_g] = zscore_sliding(r,win_zsc);
plot(zscored_wake_g)
yyaxis right
r = movmean(log10(Data(Restrict(Mean_FR , Wake))) , win_sm , 'omitnan')';
[zscored_wake_f] = zscore_sliding(r,win_zsc);
plot(zscored_wake_f)

subplot(313)
r = movmean(log10(Data(Restrict(SmoothGamma , Sleep))) , win_sm , 'omitnan')';
[zscored_sleep_g] = zscore_sliding(r,win_zsc);
plot(zscored_sleep_g)
yyaxis right
r = movmean(log10(Data(Restrict(Mean_FR , Sleep))) , win_sm , 'omitnan')'; r(r==-Inf) = NaN;
[zscored_sleep_f] = zscore_sliding(r,win_zsc);
plot(zscored_sleep_f)










