

% path{1} = '/media/nas7/React_Passive_AG/OBG/Edel/head-fixed/20220520_n/';
path{1} = '/media/nas7/React_Passive_AG/OBG/Labneh/freely-moving/20221221_long';
path{2} = '/media/nas7/React_Passive_AG/OBG/Brynza/freely-moving/20240123_long';
path{3} = '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs/';
path{4} = '/media/nas7/React_Passive_AG/OBG/Tvorozhok/20250508';

for i=1:4
    load([path{i} filesep 'SleepScoring_OBGamma.mat'], 'Sleep', 'Wake')
    load([path{i} filesep 'B_Middle_Spectrum.mat'])
    Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
    [Sc,Th,Epoch]=CleanSpectro_BM(Sptsd,Spectro{3},6,20);
    OB_High_Wake = Restrict(Sc,Wake);
    OB_High_Sleep = Restrict(Sc,Sleep);
    Mean_Sp_Wake(i,:) = nanmean(Data(OB_High_Wake));
    Mean_Sp_Sleep(i,:) = nanmean(Data(OB_High_Sleep));
end
RANGE = Spectro{3};
Range_Middle = Spectro{3};

figure
[~,MaxPowerValues,~] = Plot_MeanSpectrumForMice_BM(Mean_Sp_Wake , 'Color' , 'b' , 'smoothing' , 2);
Plot_MeanSpectrumForMice_BM(Mean_Sp_Sleep , 'power_norm_value' , MaxPowerValues , 'Color' , 'k' , 'smoothing' , 2);
xlim([20 100]), ylim([0 1.1])
makepretty
xlabel('Frequency (Hz)'), ylabel('Power (a.u.)'), set(gca,'YScale','log')
f=get(gca,'Children'); legend([f([5 1])],'Wake','Sleep');
axis square


% compare with mice
path_m{1} = '/media/nas6/ProjetEmbReact/Mouse1146/20201216';
path_m{2} = '/media/nas7/ProjetEmbReact/Mouse1379/20221020/';
path_m{3} = '/media/nas7/ProjetEmbReact/Mouse1411/20230208/';
path_m{4} = '/media/nas7/ProjetEmbReact/Mouse1417/20230220/';
for i=1:4
    load([path_m{i} filesep 'SleepScoring_OBGamma.mat'], 'Sleep', 'Wake','TotalNoiseEpoch')
    load([path_m{i} filesep 'B_Middle_Spectrum.mat'])
    Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
    OB_High_Wake = Restrict(Sptsd,Wake); 
    OB_High_Sleep = Restrict(Sptsd,Sleep);
    Mean_Sp_Wake_m(i,:) = nanmean(Data(OB_High_Wake));
    Mean_Sp_Sleep_m(i,:) = nanmean(Data(OB_High_Sleep));
end

figure
[~,MaxPowerValues,~] = Plot_MeanSpectrumForMice_BM(Mean_Sp_Wake_m , 'Color' , 'b' , 'smoothing' , 2);
Plot_MeanSpectrumForMice_BM(Mean_Sp_Sleep_m , 'power_norm_value' , MaxPowerValues , 'Color' , 'k' , 'smoothing' , 2);
xlim([15 100]), ylim([0 1.1])
makepretty
xlabel('Frequency (Hz)'), ylabel('Power (a.u.)')
f=get(gca,'Children'); legend([f([5 1])],'Wake','Sleep');










