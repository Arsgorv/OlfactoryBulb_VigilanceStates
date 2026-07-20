

edit Ferret_ProcessData_BM.m
SleepScoring_Ferret_FV_BAMG('recompute', 1)


%% color settings
% for ferrets
Cols = {[.2 .5 .8],[.8 .5 .2],[.5 .2 .8]};
X = 1:3;
Legends = {'F1','F2','F3'};

% Wake/Sleep
Cols={[0 0 1],[.3 .3 .3]};
X = 1:2;
Legends = {'Wake','Sleep'};

% sleep states
Cols={[0 0 1],[.8 .5 .2],[1 0 0],[0 1 0]};
X = 1:4;
Legends = {'Wake','IS','NREM','REM'};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 1 : OB gamma tracks Wake/sleep
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Raw traces
edit Ferret_Paper_RawTraces_SleepStates.m


%% Mean spectrum
edit Ferret_Paper_MeanSpectrums_Gamma.m


%% Gamma values distribution
edit Ferret_Paper_PowerDistributions_Gamma.m


%% corr plot
edit CorrPlot_EMG_Gamma_Ferret_Example_BM.m


%% Overlap
edit Overlap_EMG_Gamma_Ferret_BM.m


%% Transitions
edit Transition_Wake_Sleep_Ferret_BM.m


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 2 : REM/NREM/IS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Raw traces
edit Ferret_Paper_RawTraces_SleepStates.m


%% Spectrograms
edit Ferret_Paper_Spectrograms_SleepStates.m


%% Corr plot
edit Ferret_Paper_CorrPlot_SleepStates.m


%% Sleep cycles
edit SLeepCycles_Ferret_BM.m.m


%% transitions
edit SleepMeanValuesOverview_Ferret_BM.m


%% schematic & splitted spectro
edit Ferret_Paper_SleeScoring_Illustration.m


%% transitions matrix
edit TransitionsMatrices_SleepStates_BM.m


%% mean spectrums
edit MeanSpectrums_AllFerret_Sleep_BM.m


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure 3: OB/pupil correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% display
edit Display_CorrPupilGamma_Ferret.m


%% plot and cross-corr
edit Ferret_Paper_CrossCorr_GammaPupil.m


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure X: HR sleep
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

edit Comparing_HeadRestraint_FreelyMoving_Ferret.m


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure X: Comparing Mice and Ferrets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

edit Ferret_Paper_Comparison_Mice_Ferrets_BM.m





%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Old idea: comparing FM and HR sleep in ferrets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% edit Ferret_states_proportion.m
% edit Ferret_StatesProportion_HR_BM.m

edit 



