function TTLInfo = MakeData_TTLInfo_OpenEphys(sync_folder, ExpeInfo)

% This function creates timestamps of ONOFF and Stim TTL events from OpenEphys
% 
% INPUT
% 
%   File            .mat file with TTL info converted from .npy (usually in
%                   .../recordingN/events/Rhythm_FPGA-100.0_TTL_1.mat
%
%   sync_folder    folder with structure.oebin
%        
%   ExpeInfo        structure that contains information about identities of
%                   all TTL channels
% 
% OUTPUT 
% 
%   TTLINFO         structure with TTL timestamps of stimulation and
%                   start/stop
% 
% By Dima Bryzgalov, MOBS team, Paris, France
% 10/07/2020
% github.com/bryzgalovdm
% github.com/MobsLab

%% Learn sampling rate and start time

% Sampling rate
oebin = fileread(fullfile(sync_folder, 'structure.oebin'));
[~, sr_id] = regexp(oebin,'"sample_rate": ');
samplingrate = str2double(oebin(sr_id(1)+1:sr_id(1)+5));

% cd([sync_folder 'continuous/OE_FPGA_Acquisition_Board-109.Rhythm Data-B/'])

% Modification EC 28/02/25 to match all folder names
oebinData = jsondecode(oebin);  % Convert JSON to MATLAB structure
% Extract the correct folder name from 'continuous' section
if isfield(oebinData, 'continuous') && ~isempty(oebinData.continuous)
    continuous_folder = strtrim(oebinData.continuous(1).folder_name);
else
    error('No valid "continuous" folder found in structure.oebin');
end
% Construct the full directory path
continuous_path = fullfile(sync_folder, 'continuous', continuous_folder);
% Verify that the folder exists before changing directory
if exist(continuous_path, 'dir')
    cd(continuous_path);
    disp(['Changed directory to: ', continuous_path]);
else
    error(['Continuous folder does not exist: ', continuous_path]);
end

% Start time - modification SB 12/02/24
sync = readNPY('timestamps.npy');
starttime = sync(1);

% AG has had issue with loading large files, so below is for him (2025/01/12)
% special_sync_folders = { ...
%     '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20250107_LSP_saline/recording1/', ...
%     '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241228_LSP_saline/recording1/', ...
%     '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241224_LSP_saline/recording1/', ...
%     '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241217_LSP_saline/recording1/', ...
%     '/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241126_LSP/recording1/'};
% 
% % Check if the sync_folder is in the special list
% if ismember(sync_folder, special_sync_folders)
%     sync = h5read([sync_folder '/continuous/continuous_Rhythm_FPGA-100.0.mat'], '/timestamps');
%     starttime = sync(1);
% else
%     sync = load([sync_folder '/continuous/continuous_Rhythm_FPGA-100.0.mat']);
%     starttime = sync.timestamps(1);
% end



%% load file  - modification SB 12/02/2024
% cd([sync_folder 'events/OE_FPGA_Acquisition_Board-109.Rhythm Data-B/TTL'])

% Modification EC 28/02/25 to match all folder names
% if isfield(oebinData, 'events') && ~isempty(oebinData.events) && iscell(oebinData.events)
%     event_folder = strtrim(oebinData.events{1,1}.folder_name);  % Extract from cell array
% else
%     error('No valid "events" folder found in structure.oebin');
% end

% UPD of above by AG on 24/07/25 to fit with OpenEphys case
if isfield(oebinData, 'events') && ~isempty(oebinData.events)
    % If not a cell, convert struct array to cell array for compatibility
    if ~iscell(oebinData.events)
        % Convert struct array to cell array, one struct per cell
        oebinData.events = num2cell(oebinData.events);
    end
    event_folder = strtrim(oebinData.events{1,1}.folder_name); 
else
    error('No valid "events" folder found in structure.oebin');
end

event_path = fullfile(sync_folder, 'events', event_folder);
if exist(event_path, 'dir')
    cd(event_path);
    disp(['Changed directory to: ', event_path]);
else
    error(['Event folder does not exist: ', event_path]);
end

% UPD of above by AG on 24/07/25 to fit with OpenEphys case
if exist('channel_states.npy','file')
    channel_states = readNPY('channel_states.npy');
elseif exist('states.npy','file')
    channel_states = readNPY('states.npy');
else
    error('No suitable states file found: expected channel_states.npy or states.npy in %s', event_path);
end

full_words = readNPY('full_words.npy');
timestamps = readNPY('timestamps.npy');

% Check if the sync_folder is in the special list
% if ismember(sync_folder, special_sync_folders)
%    channel_states = h5read(File, '/channel_states');
%    channels = h5read(File, '/channels');
%    full_words = h5read(File, '/full_words');
%    timestamps = h5read(File, '/timestamps');
% else
%     load(File);
% end

%% Loop over all possible dig inputs
for dig = 1:length(ExpeInfo.DigID)
    % ONOFF
    if strcmp(ExpeInfo.DigID{dig},'ONOFF')
        id_on = find(channel_states == dig);
        id_off = find(channel_states == -dig);
        
        if length(id_on) == 1
            TTLInfo.StartSession = double((timestamps(id_on) - starttime)*1e4);
        else
            TTLInfo.StartSession = 0;
            warning('You syncroniztion will not be precise!!! You had to start recording before start of tracking!!!')
        end
        TTLInfo.StopSession = double((timestamps(id_off) - starttime))*1e4;
        
    else
       
        DigName = (ExpeInfo.DigID{dig});
        DigName = strrep(DigName,'+','pl');
        DigName = strrep(DigName,'-','mn');
        
        id_stimon = find(channel_states == dig);
        
        TTLInfo.(DigName) = intervalSet(double((timestamps(id_stimon) - starttime))*1e4, ...
            double((timestamps(id_stimon)) - starttime)*1e4);
        
    end
end

end

