
%{

This is a master script for OB ferret project 
developed by B.Maheo and A.Goriachenkov
MOBS team, ESPCI, Paris
2024

%}

%%                           ------------- PreProcessing Sleep Scoring -------------

% 1. Upload the data to /media/nas7/React_Passive_AG/OBG/
% cd(Session_params.datapath)

% 2. Copy the ExpeInfo.mat to the |date| folder

% 3. Convert continuous/events matlab/python with prompt command below
% ~/Dropbox/Kteam/PrgMatlab/OnlinePlaceDecoding/matlab/convertEvents2Mat -p /path/to/your/recording/experimentN/recordingN/continuous/
% ~/Dropbox/Kteam/PrgMatlab/OnlinePlaceDecoding/matlab/convertEvents2Mat -p /path/to/your/recording/experimentN/recordingN/events/

% Example
% for MOBS rick computer
~/Dropbox/Kteam/PrgMatlab/OnlinePlaceDecoding/matlab/convertEvents2Mat -p /media/nas7/React_Passive_AG/OBG/Tvorozhok/20250716/continuous

% for LSP win LB1 computer
conda activate sleepscoring
python D:\Arsenii\GitHub\PrgGithub\Arsenii\React_Active_AG\convertEvents2Mat.py -p Z:\Arsenii\React_Passive\Processed_data\Kosichka\20251114_1_n_p05\ephys\Kosichka_2025-11-14_12-21-22_PostExp\recording1\continuous
python D:\Arsenii\GitHub\OlfactoryBulb_VigilanceStates\ob_preproc\convertEvents2Mat.py -p Z:\Arsenii\OBG\Tvorozhok\Tvorosov_2025-12-01_17-59-49_test\ephys\recording1\continuous
% You can make sure it's properly done if you find .dat file in the folder
Z:\Arsenii\React_Passive\Processed_data\Kosichka\20251114_1_n_p05\ephys
% 4. Go to the right folder (data, where you have ExpeInfo)

% 5. run GUI
GUI_StepOne_ExperimentInfo

% 1.
% MouseNum - number of the ferret
% Mouse strain - ferret
% Experimenter - AG
% Date
% SessionName (sleep Session checked)
% Recording Room - LSP lab
% Recording environment - MB2 booth
% Camera type - none
% Uncheck Optogenetics, Drug injection, Electrical stimulation
% Click "I'm done" and then "Next step"

% 2.
% Num Wideband Channels - 32
% Num Accelero Channels - 3
% Num Dig Channels - 0
% Num Analog Channels - 8
% Num Digital inputs - 4
% Click "I'm done"
% Check 'Channels to analyse'
% Here we don't care much about Ref and Bulb Up, but we do care
% about Bulb Deep. Now we stick to 24, where the gamma is not too high
% Click "I'm done"

% 3.
% Click "Get files"
% Is there ephys? - yes
% Which hardware did we use? - OpenEphys or Mix
% Number of folders to concatenate - 1
% Is there behaviour? - no
% Do you want to clean spikes? - no
% Click "GetFile" and choose up to the Rhythm folder where you have continuous.dat
% Put the Session name
% Check the "Ref done"
% Click "I'm done"
% Select the path again
% Click "I'm done"
% Grab a coffee and enjoy your free time while it creates event files


% directory = '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed';
directory = 'Z:\Arsenii\React_Active\training\Brayon';
% sessions = {'20250103_TORCs_saline', '20250104_TORCs_saline', '20250105_TORCs_atropine', '20250108_TORCs_saline'};
sessions = {'20251103_fm'};
% Calculate various spectrograms. Just do it beforehands to save some time
Ferret_spectrograms_calculation(directory, sessions)

% If you are having issues with sampling rate, use this function (obligatory for Shropshire
Correct_Ferret_Processing(directory, sessions)

%                           ------------- Sleep scoring -------------
%{
    Here we classify wake and sleep based on OB gamma (40-60Hz) 
    and REM/NREM based on Hpc theta/delta ratio (3-6/0.2-3Hz). 

    We have also integrated parts of an old "SleepScoreObOnly_Ferret" script in here to classify 
    S1/S2 substages using 0.1-0.5Hz OB rhythm.
 
    -- "SleepScoring_Ferret_BM" -- an alternative script for OB/HPC scoring based on SB work
%}

SleepScoring_Ferret_FV_BAMG('recompute', 1)
SleepScoring_Ferret_FV_BAMG('recompute', 1, 'full_ob', 1)

%%                           ------------- Spike Sorting Analysis -------------
directory = '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241205_TORCs';

SpikeSorting_Analysis_AG(directory)

%%                           ------------- PreProcessing behaviour (DLC) -------------
Ferret_Eye_Movement_BM

%%
fUS_SS_processing

%%                           ------------- Session parameters -------------
% Select your sessions
Dir = PathForExperimentsOB();

%%                           ------------- Figures -------------
Ferret_Sleep_Paper_VF.m

Ferret_Figures_Sleep_BM
Ferret_Figures_Anaestesia.m
Ferret_HeadRestraintSess_BM.m

% figures for mice
Ferret_Paper_BAMG

% figures for ferrets 
Ferret_Paper_BAMG2

%% -------------------------------------------- Below: not organized -------------------------------------------- 

%% old master script; we should pull out everything necessary from there
PreProcessingData_Ferret_AG

%% studies how variable gamma/theta/0.1-0.5 thresholds are across sessions
thresholds_variability

%% 
Ferret_StatesProportion_HR_BM
Ferret_states_proportion

%%
Ferret_GammaAnalysis_BM

%% Frequency
MeanSpectrums_Channels_Ferret_BM


%% Oscillations correlations
CorrelationMatrix_Ferret_BM


%% PhasePref
PhasePref_OB_Ferret_BM







%%                           ------------- Calculate 0.1-0.5Hz Epoch -------------
% load('SleepScoring_OBGamma.mat', 'Sleep')
% channel=8;
% min_dur=3;
% [Epoch_01_05,smooth_01_05,Info_01_05] = FindGammaEpoch_SleepScoring(Sleep, channel , min_dur, 'frequency' , [.1 .5],'foldername', [pwd filesep]);
% 
% save('SleepScoring_OBGamma.mat', 'Epoch_01_05', 'smooth_01_05', 'Info_01_05','-append')

%%                           ------------- Calculate other spectrograms -------------
% load('ChannelsToAnalyse/Bulb_deep.mat');
% UltraLowSpectrumBM([cd filesep],channel,'B')
% LowSpectrumSB([cd filesep],channel,'B')
% MiddleSpectrum_BM([cd filesep],channel,'B')
% 
% load('ChannelsToAnalyse/AuCx.mat');
% LowSpectrumSB([cd filesep],channel,'AuCx')
% MiddleSpectrum_BM([cd filesep],channel,'AuCx')
% 
% load('ChannelsToAnalyse/ThetaREM.mat');
% MiddleSpectrum_BM([cd filesep],channel,'H')
% 
% load('ChannelsToAnalyse/PFCx_deltadeep.mat');
% LowSpectrumSB([cd filesep],channel,'PFCx')
% MiddleSpectrum_BM([cd filesep],channel,'PFCx')

%%                           ------------- Calculate physiological parameters for head-fixed sessions -------------
load('ExpeInfo.mat')
BaseFileName = ['M' num2str(ExpeInfo.nmouse) '_' ExpeInfo.date '_' ExpeInfo.SessionType];
SetCurrentSession([BaseFileName '.xml'])
load('LFPData/InfoLFP.mat');
for i=36:37
    if ~exist(['LFPData/LFP' num2str(InfoLFP.channel(i)) '.mat'],'file') %only LFP signals
        
        LFP_temp = GetLFP(InfoLFP.channel(i));
        LFP = tsd(LFP_temp(:,1)*1E4, LFP_temp(:,2));
        SessLength = max(LFP_temp(:,1));
        save([pwd '/LFPData/LFP' num2str(InfoLFP.channel(i))], 'LFP');
        clear LFP LFP_temp
    end
end
    
MakeHeartRateForSession_BM
MakeInstFreqForSession_BM

%% Spectrograms
foldername = [pwd filesep];
mkdir('Spectrograms')
cd('./Spectrograms')
mkdir('LFPData')
for channel=8:11 % OB channels of the ferret
    copyfile([foldername filesep 'LFPData/LFP' num2str(channel) '.mat'] , [foldername filesep 'Spectrograms' filesep 'LFPData/LFP' num2str(channel) '.mat'])
    LowSpectrumSB([cd filesep],channel,'B')
    movefile('B_Low_Spectrum.mat',['B_Low_Spectrum_' num2str(channel) '.mat'])
    MiddleSpectrum_BM([cd filesep],channel,'B')
    movefile('B_Middle_Spectrum.mat',['B_Middle_Spectrum_' num2str(channel) '.mat'])
    UltraLowSpectrumBM([cd filesep],channel,'B')
    movefile('B_UltraLow_Spectrum.mat',['B_UltraLow_Spectrum_' num2str(channel) '.mat'])
end




%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ripples
load('SleepScoring_OBGamma.mat','REMEpoch','SWSEpoch','Wake','Sleep')
load('ChannelsToAnalyse/dHPC_rip.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
Ripples = FindRipplesKJ(LFP, SWSEpoch);

%% Sleep event
disp('getting sleep signals')
CreateSleepSignals('recompute',0,'rip',0,'spindle',0);

%% Substages
disp('getting sleep stages')
[featuresNREM, Namesfeatures, EpochSleep, NoiseEpoch, scoring] = FindNREMfeatures;
save('FeaturesScoring', 'featuresNREM', 'Namesfeatures', 'EpochSleep', 'NoiseEpoch')
[Epoch, NameEpoch] = SubstagesScoring(featuresNREM, NoiseEpoch);
save('SleepSubstages', 'Epoch', 'NameEpoch')

%% Id figure 1
close all
disp('making ID fig1')
MakeIDSleepData
PlotIDSleepData
saveas(1,'IDFig1.png')
close all

%% Id figure 2
disp('making ID fig2')
MakeIDSleepData2
PlotIDSleepData2
saveas(1,'IDFig2.png')
close all







%% old
%% Correct noise
% substract Reference low frequencies 
load('ChannelsToAnalyse/Ref.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])

movefile('LFPData','oldLFP')
mkdir('LFPData')
copyfile('oldLFP/InfoLFP.mat','LFPData/InfoLFP.mat')

Ref_fil=FilterLFP(LFP,[.01 50],1024);
for i=0:31
    load(['oldLFP/LFP' num2str(i) '.mat'])
    LFP = tsd(Range(LFP) , Data(LFP)-Data(Ref_fil));
    save(['LFPData/LFP' num2str(i) '.mat'],'LFP')
    disp(i)
end


load('ChannelsToAnalyse/ThetaREM.mat')
LowSpectrumSB([cd filesep],channel,'H')

load('H_Low_Spectrum.mat')

HPC_Sp = tsd(Spectro{2}*1e4 , Spectro{1});

[Epoch,TotalNoiseEpoch,SubNoiseEpoch,Info_temp] = FindNoiseEpoch_SleepScoring(channel, ...
    'foldername', [pwd filesep]);
save('StateEpochSB.mat', 'Epoch', 'TotalNoiseEpoch','Info_temp','SubNoiseEpoch')
HPC_Sp_clean = Restrict(HPC_Sp , Epoch-TotalNoiseEpoch);

[Sc,Th,Epoch]=CleanSpectro(HPC_Sp_clean,Spectro{3},8);


figure
subplot(311)
imagesc(Range(HPC_Sp,'s') , Spectro{3} , log10(Data(HPC_Sp))'), axis xy

subplot(312)
imagesc(Range(HPC_Sp_clean,'s') , Spectro{3} , log10(Data(HPC_Sp_clean))'), axis xy

subplot(313)
imagesc(Range(Sc,'s') , Spectro{3} , log10(Data(Sc))'), axis xy


save('StateEpochSB.mat', 'Epoch', '-append')
