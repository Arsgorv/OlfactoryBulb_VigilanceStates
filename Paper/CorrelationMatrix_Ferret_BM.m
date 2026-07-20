

load('SleepScoring_OBGamma.mat', 'Epoch', 'Wake', 'SWSEpoch', 'REMEpoch')


load('B_UltraLow_Spectrum.mat')
Data_Corrected = resample(Spectro{1}' , 2 , 1); 
OB_ULow_Sptsd = tsd(Spectro{2}*1e4 , Data_Corrected');
OB_ULow_Sptsd = Restrict(OB_ULow_Sptsd , Epoch);
RangeULow = Spectro{3};

load('B_Low_Spectrum.mat')
OB_Low_Sptsd = tsd(Spectro{2}*1e4 , log((Spectro{1}(:,13:end)))); % Low spectrum begin at 1Hz
OB_Low_Sptsd = Restrict(OB_Low_Sptsd , Epoch);
RangeLow = Spectro{3}(13:end);

load('B_Middle_Spectrum.mat')
Data_Corrected = resample((Spectro{1}(:,13:end))' , 4 , 1); Data_Corrected(Data_Corrected<0)=1e-2;
OB_High_Sptsd = tsd(Spectro{2}*1e4 , log(Data_Corrected'));  % High spectrum begin at 20Hz
OB_High_Sptsd = Restrict(OB_High_Sptsd , Epoch);
RangeHigh = resample(Spectro{3}(13:end) , 4 , 1);

OB_Low_Sptsd_corr = Restrict(OB_Low_Sptsd , OB_ULow_Sptsd);
OB_High_Sptsd_corr = Restrict(OB_High_Sptsd , OB_ULow_Sptsd);

OB_ULow_Data = Data(OB_ULow_Sptsd);
OB_Low_Data = Data(OB_Low_Sptsd_corr);
OB_High_Data = Data(OB_High_Sptsd_corr);
OB_AllSpectro_Data = (zscore([OB_ULow_Data' ; OB_Low_Data' ; OB_High_Data']')');
AllRange = [RangeULow' ; RangeLow' ; RangeHigh'];
OB_AllSpectro_tsd = tsd(Range(OB_ULow_Sptsd) , OB_AllSpectro_Data');
OB_AllSpectro_Wake = Restrict(OB_AllSpectro_tsd , Wake);
OB_AllSpectro_NREM = Restrict(OB_AllSpectro_tsd , SWSEpoch);
OB_AllSpectro_REM = Restrict(OB_AllSpectro_tsd , REMEpoch);



%%
figure

clear D
D = Data(OB_AllSpectro_Wake); D = [D(:,1:188)/1.5 D(:,189:454) D(:,454:end)*1.3];
D = D'*D;

subplot(131)
imagesc(D)
% caxis([2.8 3.5])
axis square
xticks([0 94 188 312 437 567 697]), xticklabels({'0','0.5','1','10','20','60','100'})
yticks([0 94 188 312 437 567 697]), yticklabels({'0','0.5','1','10','20','60','100'})
title('Wake')
xlabel('Frequency (Hz)'), ylabel('Frequency (Hz)'),

clear D
D = Data(OB_AllSpectro_NREM); D = [D(:,1:188) D(:,189:454)/1.2 D(:,454:end)];
D = D'*D;

subplot(132)
imagesc(D)
% caxis([2.8 3.5])
axis square
xticks([0 94 188 312 437 567 697]), xticklabels({'0','0.5','1','10','20','60','100'})
yticks([0 94 188 312 437 567 697]), yticklabels({'0','0.5','1','10','20','60','100'})
xlabel('Frequency (Hz)')
title('NREM')


clear D
D = Data(OB_AllSpectro_REM); D = [D(:,1:188)*3 D(:,189:454) D(:,454:end)];
D = D'*D;

subplot(133)
imagesc(D)
% caxis([2.8 3.5])
axis square
xticks([0 94 188 312 437 567 697]), xticklabels({'0','0.5','1','10','20','60','100'})
yticks([0 94 188 312 437 567 697]), yticklabels({'0','0.5','1','10','20','60','100'})
xlabel('Frequency (Hz)')
title('REM')

colormap jet
a=sgtitle('Frequency correlations, Brynza, freely moving session'); a.FontSize=20;


