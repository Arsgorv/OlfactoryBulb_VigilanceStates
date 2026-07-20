
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sup 1: accelero
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Raw traces
edit Ferret_Paper_RawTraces_SleepStates.m


%% corr-plot
edit CorrPlot_EMG_Gamma_Ferret_Example_BM.m


%% transitions
edit Transition_Wake_Sleep_Ferret_BM.m


%% Gamma values distribution
edit Ferret_Paper_PowerDistributions_Gamma.m


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sup 2: sleep states
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% PCA say the same
edit Ferret_Paper_PCA_Spectrograms_SleepStates.m


%% where does this OB rhythm comes from ?
edit Ferret_Paper_Delta_AcrossCortices_Sleep.m % delta power across cortices
edit Ferret_Paper_OB_Delta_NREM.m % is there delta in OB ?


%% REM is Ach dependent
edit Ferret_Paper_REMconfirm_EyeMov.m
edit Ferret_Paper_REMconfirm_Pharmaco_Atropine.m


%% Wake is Nad dependent
edit Ferret_Paper_WAKEconfirm_Pharmaco_Medetomidine.m.m.m


%% IS sleep study
edit Ferret_Paper_IS_Sleep_Study.m % correlation with REM and Tot sleep dur


%% physio
% edit Physio_Sleep_Ferret_BM.m
edit MeanPhysio_HeadRestraint_SleepSates_Ferret_BM.m


%% REM from OB
edit IdentifyingREM_with_OB_Ferret_BM.m


%% Regularity HPC
edit Ferret_Paper_Regularity_HPC_theta.m


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sup 3: Breathing influences on brain oscillations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% raw traces
edit Ferret_Paper_RawTraces_Respi.m


%% corr with gamma
edit Ferret_Paper_OB_Gamma_Respi_cor.m


%% mean breathing
edit MeanPhysio_HeadRestraint_SleepSates_Ferret_BM.m


%% Rayleigh to decide if phasic or events 
edit Ferret_Paper_Rayleigh_PiezzoBreathing.m


%% Sniff --> as events
edit Sniff_Triggered_OB_Gamma_Ferret_BM.m


%% Breathing as phase
edit Phasic_Analysis_Breathing_Ferret.m


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Arousal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% pupil and other arousal markers
edit Ferret_Paper_Arousal_Markers_Evolution_BM.m.m


%% along sleep cycles
edit SleepCycles_ArousalMarkers_Ferret.m



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Not used
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% is gamma periodic during NREM?
edit Cyclicity_Gamma_DuringNREM_Ferret.m.m


%% gamma PFC same as OB ?
edit Gamma_OB_OB_PFC_corr_Ferret_BM.m

edit SpikeOB_Analyses_Ferret_BM.m

edit Corr_Pupil_2Gamma_BM.m

edit Comparing_HeadRestraint_FreelyMoving_Ferret.m


