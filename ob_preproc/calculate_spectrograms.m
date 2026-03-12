function calculate_spectrograms(datapath, animalName, channels)
% calculate_spectrograms(datapath, animalName, channels)
%
% Now: tries to read channel numbers from:
%   <ephys>\ChannelsToAnalyse\*.mat  (expects variable "channel")
% Fallback: your existing AnimalChannels / guessing logic.
%
% INPUTS
%   datapath   : session folder OR ephys folder
%   animalName : optional string
%   channels   : optional [AuCx OB HPC PFC] (1000 = skip)
%
% EXAMPLES
%   calculate_spectrograms('Z:\...\Kosichka\20251114_1_n_p05', 'Kosichka');
%   calculate_spectrograms('Z:\...\Kosichka\20251114_1_n_p05\ephys', 'Kosichka');
%   calculate_spectrograms(datapath, '', [65 21 18 12]);

if nargin < 1 || isempty(datapath)
    error('calculate_spectrograms: you must provide datapath');
end
if nargin < 2, animalName = ''; end
if nargin < 3, channels = []; end

if ~exist(datapath,'dir')
    error('calculate_spectrograms: datapath does not exist: %s', datapath);
end

fprintf('\n--- calculate_spectrograms ---\n');
fprintf('datapath: %s\n', datapath);

%% 1) Default channels per animal
% Resolve session/ephys path robustly
[ephysPath, ~] = resolve_ephys_path(datapath);

% fallback
AnimalChannels = struct();
AnimalChannels.Shropshire = [65   21   18   12];    % [AuCx OB HPC PFC]
AnimalChannels.Edel       = [1000 26   24   1000];
AnimalChannels.Brynza     = [1    11   21   13];
% AnimalChannels.Tvorozhok  = [1000 12   21   13];
AnimalChannels.Tvorozhok  = [1000 76   1000   1000];
AnimalChannels.Kosichka   = [1000  4 1000 1000]; 
AnimalChannels.Ficello   = [1000  10 1000 1000]; 
AnimalChannels.Brayon     = [1000  6 1000 1000];
% AnimalChannels.Mochi      = [1000  15 1000 1000];
AnimalChannels.Mochi      = [1000  13 1000 1000];

%% 2) Determine fallback channels first (your existing logic)
if isempty(channels)
    if ~isempty(animalName) && isfield(AnimalChannels, animalName)
        channels = AnimalChannels.(animalName);
        fprintf('Fallback channels for "%s": [AuCx OB HPC PFC] = [%d %d %d %d]\n', ...
            animalName, channels(1), channels(2), channels(3), channels(4));
    else
        fn = fieldnames(AnimalChannels);
        guessed = '';
        for k = 1:length(fn)
            if contains(datapath, fn{k}, 'IgnoreCase', true)
                guessed = fn{k};
                channels = AnimalChannels.(fn{k});
                fprintf('Guessed animal "%s" from path. Fallback channels = [%d %d %d %d]\n', ...
                    guessed, channels(1), channels(2), channels(3), channels(4));
                break
            end
        end
        if isempty(channels)
            disp('Could not determine channels automatically.');
            disp('Enter channels as [AuCx OB HPC PFC], use 1000 to skip.');
            channels = input('channels = ');
        end
    end
else
    fprintf('Using user-provided channels [AuCx OB HPC PFC] = [%d %d %d %d]\n', ...
        channels(1), channels(2), channels(3), channels(4));
end

if numel(channels) ~= 4
    error('channels must be a 1x4 vector: [AuCx OB HPC PFC]');
end

AuCx_ch = channels(1);
OB_ch   = channels(2);
HPC_ch  = channels(3);
PFC_ch  = channels(4);

%% 2b) Override from ChannelsToAnalyse (primary), fallback is what you already had
ctaDir = fullfile(ephysPath, 'ChannelsToAnalyse');
if exist(ctaDir, 'dir')
    [AuCx_ch, srcA] = load_channel_from_cta(ctaDir, ...
        {'AuCx.mat','ACx.mat','AuditoryCx.mat','AuCx_deep.mat'}, AuCx_ch);
    [OB_ch,   srcB] = load_channel_from_cta(ctaDir, ...
        {'Bulb_deep.mat','Bulb.mat','OB.mat','B.mat'}, OB_ch);
    [HPC_ch,  srcH] = load_channel_from_cta(ctaDir, ...
        {'ThetaREM.mat','ThetaREM_ch.mat','HPC.mat','Hippocampus.mat'}, HPC_ch);
    [PFC_ch,  srcP] = load_channel_from_cta(ctaDir, ...
        {'PFC.mat','PFC_deep.mat','PFCx.mat'}, PFC_ch);

    fprintf('ChannelsToAnalyse override:\n');
    fprintf('  AuCx: %d (%s)\n', AuCx_ch, srcA);
    fprintf('  OB  : %d (%s)\n', OB_ch,   srcB);
    fprintf('  HPC : %d (%s)\n', HPC_ch,  srcH);
    fprintf('  PFC : %d (%s)\n', PFC_ch,  srcP);
else
    fprintf('ChannelsToAnalyse not found: %s (using fallback channels)\n', ctaDir);
end

%% 3) Go to ephys folder
startDir = pwd;
cd(ephysPath);

fprintf('Running spectrograms in: %s\n', ephysPath);

%% 4) AuCx
if AuCx_ch ~= 1000
    if ~exist('AuCx_Low_Spectrum.mat','file')
        LowSpectrumSB(pwd, AuCx_ch, 'AuCx');
        disp('AuCx_Low done');
    else
        disp('AuCx_Low already exists');
    end

    if ~exist('AuCx_Middle_Spectrum.mat','file')
        MiddleSpectrum_BM(pwd, AuCx_ch, 'AuCx');
        disp('AuCx_Middle done');
    else
        disp('AuCx_Middle already exists');
    end
else
    disp('Skipping AuCx (channel = 1000)');
end

%% 5) OB (B)
if OB_ch ~= 1000
    if ~exist('B_UltraLow_Spectrum.mat','file')
        UltraLowSpectrumBM(pwd, OB_ch, 'B');
        disp('B_UltraLow done');
    else
        disp('B_UltraLow already exists');
    end

    if ~exist('B_Low_Spectrum.mat','file')
        LowSpectrumSB(pwd, OB_ch, 'B');
        disp('B_Low done');
    else
        disp('B_Low already exists');
    end

    if ~exist('B_LowEvent_Spectrum.mat','file')
        LowEventSpectrum_AG(pwd, OB_ch, 'B');
        disp('B_LowEvent_Spectrum done');
    else
        disp('B_LowEvent_Spectrum already exists');
    end

    if ~exist('B_Middle_Spectrum.mat','file')
        MiddleSpectrum_BM(pwd, OB_ch, 'B');
        disp('B_Middle done');
    else
        disp('B_Middle already exists');
    end

    if ~exist('B_High_Spectrum.mat','file')
        HighSpectrum(pwd, OB_ch, 'B');
        disp('B_High done');
    else
        disp('B_High already exists');
    end
else
    disp('Skipping OB (channel = 1000)');
end

%% 6) Hippocampus
if HPC_ch ~= 1000
    if ~exist('H_Low_Spectrum.mat','file')
        LowSpectrumSB(pwd, HPC_ch, 'H');
        disp('H_Low done');
    else
        disp('H_Low already exists');
    end

    if ~exist('H_Middle_Spectrum.mat','file')
        MiddleSpectrum_BM(pwd, HPC_ch, 'H');
        disp('H_Middle done');
    else
        disp('H_Middle already exists');
    end
else
    disp('Skipping HPC (channel = 1000)');
end

%% 7) PFC
if PFC_ch ~= 1000
    if ~exist('PFCx_Low_Spectrum.mat','file')
        LowSpectrumSB(pwd, PFC_ch, 'PFCx');
        disp('PFCx_Low done');
    else
        disp('PFCx_Low already exists');
    end

    if ~exist('PFCx_Middle_Spectrum.mat','file')
        MiddleSpectrum_BM(pwd, PFC_ch, 'PFCx');
        disp('PFCx_Middle done');
    else
        disp('PFCx_Middle already exists');
    end
else
    disp('Skipping PFC (channel = 1000)');
end

cd(startDir);
disp('calculate_spectrograms: done.');

end

function [ephysPath, sessionPath] = resolve_ephys_path(datapath)

% Case 1: datapath already IS ephys folder
if exist(fullfile(datapath, 'LFPData'), 'dir') || exist(fullfile(datapath, 'ChannelsToAnalyse'), 'dir')
    ephysPath = datapath;
    sessionPath = fileparts(datapath);
    return
end

% Case 2: datapath is session folder containing "ephys"
cand = fullfile(datapath, 'ephys');
if exist(cand, 'dir')
    ephysPath = cand;
    sessionPath = datapath;
    return
end

% Fallback
ephysPath = datapath;
sessionPath = fileparts(datapath);

end

function [ch, src] = load_channel_from_cta(ctaDir, fileCandidates, chFallback)

ch = chFallback;
src = 'fallback';

for i = 1:numel(fileCandidates)
    f = fullfile(ctaDir, fileCandidates{i});
    if exist(f, 'file')
        S = load(f);
        if isfield(S, 'channel')
            c = S.channel;
        else
            fn = fieldnames(S);
            if numel(fn) == 1
                c = S.(fn{1});
            else
                warning('CTA file has no "channel" and multiple vars: %s (keeping fallback)', f);
                return
            end
        end

        if isempty(c)
            warning('Empty channel in: %s (keeping fallback)', f);
            return
        end

        if numel(c) > 1
            warning('Channel is not scalar in %s (taking first element)', f);
            c = c(1);
        end

        ch = double(c);
        src = fileCandidates{i};
        return
    end
end

end