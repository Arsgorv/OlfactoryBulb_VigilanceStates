function Ferret_Eye_Movement_BM()
% This is a master script to process the DLC behavioural ferret data
% Steps:
%   - Synchronization with LFP signal (sync_video_ob). It creates a correct timeline taking into account the delay between the video and ephys
%   - Generation of the basic figures (OB_face_analysis_DLC)
% Under construction  - Study the correlation between OB/Cortical/Hippocampal gamma and pupil area (gamma_pupil_corr)
% Under construction  - Producing the composition video with all variables synced (composition_video_OB_DLC_ferret)

%% Select sessions
Dir{1} = PathForExperimentsOB({'Labneh'}, 'head-fixed', 'none');
Dir{2} = PathForExperimentsOB({'Brynza'}, 'head-fixed', 'none');
Dir{3} = PathForExperimentsOB({'Shropshire'}, 'head-fixed', 'none');
Dir{4} = PathForExperimentsOB({'Shropshire', 'Labneh', 'Brynza'}, 'head-fixed', 'none');
% Dir{4} = PathForExperimentsOB({'Labneh', 'Brynza'}, 'head-fixed', 'none');

Dir{5} = MergePathForExperiment(Dir{1},Dir{2});

Dirs_names = {'Labneh', 'Brynza', 'Shropshire', 'All animals', 'Arbitrary_Mix'};

% Form the list of sessions
selection = 4;

sessions = Dir{selection}.path';

k = 1;
session_dlc = {};

% Remove sessions with no DLC
for c = 1:length(sessions)
    dlc_path = fullfile(sessions{c}, 'DLC'); 
    files = dir(fullfile(dlc_path, '*_filtered.csv')); % Search for files ending with "_filtered.csv"
    
    if ~isempty(files) % Check if there are any matching files
        session_dlc{k} = sessions{c}; % Store the session path
        k = k + 1;
    else
        disp([Dir{selection}.path{c} ' - No DLC found']);
    end
end

session_dlc = session_dlc';

% Remove these sessions if you need good sleep scoring with both NREM and REM. These are sessions with either no REM or low-quality SleepScoring 
% Do not use for: fig 4a
% Do     use for: fig 4c, 4d, 4e

%% some list I don't remember
% Labneh = {...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230225',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230227',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230303',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230307',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230308',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230315',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230321',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230323',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230407',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230418',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230419',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230504_1',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230504_2',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230505_1',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230505_2' ,...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230508_1',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230508_2',...
%     '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230508_3',...
};

%%
remove_states = {...
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230208',... % 2 ep of REM, not trustworthy SS. HPC is bad
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230225', ... % 1 ep of REM, not trustworthy SS. HPC is bad
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230307',... % not trustworthy SS.
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230308', ... % 2-3 ep of REM, but bad SS. NICE OB, bad HPC
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230315', ... % 1-3 ep of REM, but bad SS
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230323',... % at least 1 ep of REM, but bad SS: many pre-REM episodes
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230407',... % no REM or bad SS
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230418',... % no clear REM or bad SS
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230419',... % 1 ep of REM, but bad SS. WEIRD HPC
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230504_1',... % no clear REM, but several pre-REM episodes, so bad SS
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230504_2',... % 1-3 ep of REM, but bad SS. WEIRD HPC
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230505_1',... % no clear REM, but several pre-REM episodes, so bad SS. WEIRD HPC
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230505_2',... % no clear REM, but several pre-REM episodes, so bad SS. WEIRD HPC
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230508_1',... % no clear REM, but several pre-REM episodes, so bad SS  
    '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240125',... % no REM
    '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240129',... % no REM
    '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240204',... % low quality SS, no REM
    '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240308',... % 1 ep of REM, but bad SS
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241120_yves_train',... % too short for a proper SS
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241125_yves_train',... % too short for a proper SS
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241126_yves_train',... % too short for a proper SS
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241128_yves_train',... % too short for a proper SS
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241129_yves_test' ,... % too short for a proper SS
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241130_yves_test' ,... % too short for a proper SS
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241203_yves_test',... % too short for a proper SS
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241204_TORCs',... % no REM
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241205_TORCs',... % no REM
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241206_TORCs',... % no REM
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241209_TORCs',... % no REM
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241210_TORCs',... % no REM
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241214_TORCs',... % no REM
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241224_TORCs_saline',... % no REM & unreliable tracking
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241226_TORCs_saline',... % no REM & unreliable tracking
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241228_TORCs_saline',... % no REM & unreliable tracking
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250101_TORCs_saline',... % no REM & unreliable tracking
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250103_TORCs_saline',... % no REM & unreliable tracking
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250104_TORCs_saline',... % no REM & unreliable tracking
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250108_TORCs_saline',...  % 1-3 ep of REM, but bad SS
    };
remove_states = remove_states';

% For all DLC-related analysis: Remove sessions with bad DLC 
remove_wierd_HPC = {...
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230419',... % 1 ep of REM, but bad SS. WEIRD HPC
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230504_2',... % 1-3 ep of REM, but bad SS. WEIRD HPC
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230505_1',... % no clear REM, but several pre-REM episodes, so bad SS. WEIRD HPC
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230505_2',... % no clear REM, but several pre-REM episodes, so bad SS. WEIRD HPC
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230508_3',... % something wrong about HPC signal
    '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240205',... % low quality SS, no REM    
    '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240305',... % low quality SS, no REM        
    };
remove_wierd_HPC = remove_wierd_HPC';

% careful with this one: '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241212_TORCs',... % miss-tracking during REM (~2h35m)
remove_DLC = {...
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230427',... % no full-session DLC
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230505_3',... % no full-session DLC
    '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240307',... % light shuts down in the middle of the session
    '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240305',... % miss-tracking during REM (~2h). 1 ep of REM. CORRECT IT
    '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240313_upd',... % 2 ep of REM, but bad SS
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241123_yves_train', ... % low quality DLC
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241224_TORCs_saline',...   % unreliable tracking
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241226_TORCs_saline',...   % unreliable tracking
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241228_TORCs_saline',...   % unreliable tracking
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250101_TORCs_saline',...   % unreliable tracking
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250103_TORCs_saline',... % unreliable tracking
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20250104_TORCs_saline',... % unreliable tracking
    };

remove_DLC = remove_DLC';

% Sessions with good examples of gamma-pupil correlation (without necessarily good state classification)
example_corr = {
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230227',... % very good!
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230303',... % very good!
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230321',... % 1 out of 2 REM ep was scored, but nice overall    
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230208',... % very good, although REM is unclear!
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230225',... % bad REM scoring, but nice overall
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230307',... % bad REM scoring, but nice overall
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230308',... % bad REM scoring, but nice overall (nice OB, bad HPC)
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230315',... % bad REM scoring, but nice overall
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230323',... % bad REM scoring, but nice overall: many pre-REM episodes
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230407',... % bad REM scoring, but nice overall
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230418',... % bad REM scoring, but nice overall
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230419',... % 1 ep of REM, but bad SS
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230504_1',... % no clear REM, but several pre-REM episodes, so bad SS
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230504_2',... % 1-3 ep of REM, but bad SS. Don't use for HPC though
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230508_1',... % no clear REM, but several pre-REM episodes, so bad SS
    '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230508_3',... % Good!
    '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240126',... % 1 clear ep of REM. Good
    '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240204',... % Good!
    '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241204_TORCs',... % No REM, but ok!    
    };
%     '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240129' ,...
%     '/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240308' ,...

example_corr = example_corr';

% atropine = {
%     '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241220_TORCs_atropine',...
%     '/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241231_TORCs_atropine',...
%     };
% atropine = atropine';
% 


% Select sessions
% remove sessions with DLC problems
keepIdx_r_d = ~ismember(session_dlc, remove_DLC);
session_dlc = session_dlc(keepIdx_r_d);

% remove sessions with sketchy HPC signal
keepIdx_r_h = ~ismember(session_dlc, remove_wierd_HPC);
session_dlc = session_dlc(keepIdx_r_h);

% OPTIONAL: remove sessions without clear sleep scoring
keepIdx_r_s = ~ismember(session_dlc, remove_states);
session_dlc = session_dlc(keepIdx_r_s);


%% -------------------------------------- PREPROCESSING -------------------------------------- 

% SESS: Synchronize LFP and DLC
% Produces synced timeline in DLC_data.mat
for sess = 1:numel(session_dlc)
    % cd(session_dlc{1})
    disp(['Running session: ' session_dlc{sess}])
    disp('Syncing DLC and Ephys...')
    sync_video_ob(session_dlc{sess})
end

% SESS: Do the basic DLC pre-processing
% TS: B20240410_domitor (sort); S20241206 (sort, nans); L20230727 (nans); L20230505_3 (nans)
for sess = 1:numel(session_dlc)
    disp('Analysing DLC data...')
    disp(['Running session: ' session_dlc{sess}])
    OB_face_analysis_DLC(session_dlc{sess})
end

% SESS: Calculate gamma powers for various brain signals
for sess = 1:numel(session_dlc)
    disp('Analysing DLC data...')
    disp(['Running session: ' session_dlc{sess}])    
    calc_brain_gamma_powers(session_dlc{sess})
end

%% --------------------------------------    ANALYSIS   -------------------------------------- 
sprintf('Note that for this analysis I am using brain signals from BrainPower variable.\nThe difference between them and other SmoothGamma/SmoothTheta etc is in smoothing.\nWe usually use smootime = 3 ; here I use smootime = 0.1 to keep the high freq fluctuations.')

% SESS: Pupil physiology
for sess = 1:length(session_dlc)
    disp('Running physiology analysis...')    
    disp(['Running session: ' session_dlc{sess}])
    pupil_physio(session_dlc{sess})
    close all
end
% 4b, 4c, sup4a, sup4b: DATASET: Pupil physiology
fig_pupil_physio_dataset(session_dlc);

% SESS: Study correlation between pupil and brain signal as a function of frequency band passed
for sess = 1:length(session_dlc)
    disp('Running pupil-brain correlation vs f.band analysis...')
    disp(['Running session: ' session_dlc{sess}])
    brain_pupil_smoofun(session_dlc{sess});
    close all
end
% 4d, 4e, sup4c: DATASET: Correlate brain signals with pupil size
fig_brain_pupil_fband_dataset(session_dlc)

% 4f, 4g, SESS: Correlate brain signals with pupil size
for sess = 1:length(session_dlc)
    disp('Running pupil-brain correlation analysis...')
    disp(['Running session: ' session_dlc{sess}])    
    brain_pupil_corr(session_dlc{sess})
    close all
end
% 4h, 4i, sup4d, sup4e: DATASET: Correlate brain signals with pupil size
fig_brain_pupil_corr_dataset(session_dlc)
%     edit Ferret_Paper_CrossCorr_GammaPupil.m

% sup4f: pair-wise brain signal correlation
fig_brain_paircorr_dataset(session_dlc)

%% Under construction: Generate composition video
% composition_video_OB_DLC_ferret

%% Under construction: Manual correction of outlier DLC scoring frames
% it could work but I was lazy and decided to smooth data instead AG 05/11/24
% Ferret_DLC_correct_outlier_coordinates(Session_params, datapath)

%% LEGACY: Manual initialization of sessions 
% User input parameters
% Session_params.session_selection = '20241212_TORCs';
% Session_params.fps = 15;
% 
% % Flags
% Session_params.animal_selection = 3;
% Session_params.experiment_type_selection = 1;
% Session_params.pharma_selection = 1;
% Session_params.plt = [0 1]; 
% Session_params.fig_visibility = 'on';
% 
% % Parameters       
% Session_params.animal_name = {'Labneh','Brynza', 'Shropshire'};
% Session_params.experiment_type = {'head-fixed', 'freely_moving'};
% Session_params.pharma = {'No pharmacology','Domitor', 'Atropine'};
% datapath = ['/media/nas7/React_Passive_AG/OBG/' Session_params.animal_name{Session_params.animal_selection} '/' Session_params.experiment_type{Session_params.experiment_type_selection} '/' Session_params.session_selection];

end