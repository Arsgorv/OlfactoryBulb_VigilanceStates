function SD = load_session_AG(sessionPath, sessionName, opts)
% load_session_AG  Load sleep scoring, smoothed scoring signals, accelero/EMG,
% and pre-computed spectrograms for a single ferret 24-h session.
%
% INPUT
%   sessionPath  absolute path to a session folder
%   sessionName  short label
%   opts         optional struct controlling what gets loaded:
%     .skipEMG               default false. Skip the EMG FilterLFP step
%                            (which is the heaviest memory user -- loads the
%                            full 24-h raw LFP into RAM).
%     .skipAccelero          default false. Skip behavResources.MovAcctsd.
%     .skipOptionalSpectra   default false. Skip PFC/AuCx/HPCmid spectra.
%     .downsampleSmooth      default 1. If >1, decimate SmoothGamma/Theta/
%                            Delta_OB by this factor after loading. 10 cuts
%                            their RAM footprint by 10x with no visible
%                            effect on 24-h plots.
%     .skipCoreSpectra       default false. Skip OB/HPC low + OB mid spectro.
%                            For computes that only need states + smooth sigs.
%
% OUTPUT struct SD (see field list below).

if nargin < 3, opts = struct(); end
def = struct('skipEMG',false,'skipAccelero',false, ...
             'skipOptionalSpectra',false,'downsampleSmooth',1, ...
             'skipCoreSpectra',false);
fn = fieldnames(def);
for k = 1:numel(fn)
    if ~isfield(opts, fn{k}), opts.(fn{k}) = def.(fn{k}); end
end

SD = struct();
SD.path = sessionPath;
SD.name = sessionName;

% --- 1. Sleep scoring ---------------------------------------------------------
sleepFile = fullfile(sessionPath, 'SleepScoring_OBGamma.mat');
if ~exist(sleepFile, 'file')
    error('load_session_AG: SleepScoring_OBGamma.mat not found in %s', sessionPath);
end
% Load only what we need from the (potentially large) scoring file
needVars = {'Wake','REMEpoch','SWSEpoch','ISEpoch','Sleep','Epoch', ...
            'TotalNoiseEpoch','Info','CleanStates', ...
            'SmoothGamma','SmoothTheta','SmoothDelta_OB', 'Info'};
who_in_file = who('-file', sleepFile);
needVars = intersect(needVars, who_in_file);
S = load(sleepFile, needVars{:});

% Prefer 4-state CleanStates (Wake/N1/N2/REM); fall back to legacy split.
if isfield(S, 'CleanStates') && isfield(S.CleanStates, 'N1')
    SD.states.Wake  = S.CleanStates.Wake;
    SD.states.N1    = S.CleanStates.N1;
    SD.states.N2    = S.CleanStates.N2;
    SD.states.REM   = S.CleanStates.REM;
    if isfield(S.CleanStates, 'Sleep')
        SD.states.Sleep = S.CleanStates.Sleep;
    else
        SD.states.Sleep = or(or(SD.states.N1, SD.states.N2), SD.states.REM);
    end
    SD.states.scheme = 'CleanStates';
else
    warning('load_session_AG:%s: CleanStates not found, falling back to Wake/IS/SWS/REM.', sessionName);
    SD.states.Wake  = S.Wake;
    if isfield(S, 'ISEpoch') && ~isempty(S.ISEpoch)
        SD.states.N1 = S.ISEpoch;
        SD.states.N2 = S.SWSEpoch - S.ISEpoch;
    else
        SD.states.N1 = intervalSet([],[]);
        SD.states.N2 = S.SWSEpoch;
    end
    SD.states.REM   = S.REMEpoch;
    if isfield(S, 'Sleep')
        SD.states.Sleep = S.Sleep;
    else
        SD.states.Sleep = or(or(SD.states.N1, SD.states.N2), SD.states.REM);
    end
    SD.states.scheme = 'Legacy';
end

if isfield(S, 'TotalNoiseEpoch'),  SD.states.NoiseEpoch = S.TotalNoiseEpoch;
else,                              SD.states.NoiseEpoch = intervalSet([],[]); end
if isfield(S, 'Epoch'),            SD.states.TotalEpoch = or(S.Epoch, SD.states.NoiseEpoch);
else,                              SD.states.TotalEpoch = []; end

% --- 2. Smoothed scoring signals ---------------------------------------------
if isfield(S, 'SmoothGamma'),     SD.sig.SmoothGamma     = S.SmoothGamma;     else, SD.sig.SmoothGamma = []; end
if isfield(S, 'SmoothTheta'),     SD.sig.SmoothTheta     = S.SmoothTheta;     else, SD.sig.SmoothTheta = []; end
if isfield(S, 'SmoothDelta_OB'),  SD.sig.SmoothDelta_OB  = S.SmoothDelta_OB;  else, SD.sig.SmoothDelta_OB = []; end

% Optional downsampling to save RAM (24-h at native sampling is huge)
if opts.downsampleSmooth > 1
    SD.sig.SmoothGamma    = downsample_tsd_AG(SD.sig.SmoothGamma,    opts.downsampleSmooth);
    SD.sig.SmoothTheta    = downsample_tsd_AG(SD.sig.SmoothTheta,    opts.downsampleSmooth);
    SD.sig.SmoothDelta_OB = downsample_tsd_AG(SD.sig.SmoothDelta_OB, opts.downsampleSmooth);
end
clear S

% --- 3. Recording duration (use the longest available time vector) -----------
durCandidates = [];
if ~isempty(SD.sig.SmoothGamma)
    durCandidates(end+1) = max(Range(SD.sig.SmoothGamma)); %#ok<AGROW>
end
if ~isempty(SD.states.TotalEpoch)
    durCandidates(end+1) = max(Stop(SD.states.TotalEpoch)); %#ok<AGROW>
end
if isempty(durCandidates)
    durCandidates = max(Stop(SD.states.Wake));
end
SD.totDur_ts = max(durCandidates);    % in 1e-4 s
SD.totDur_h  = SD.totDur_ts / 3600e4;

% --- 4. Accelerometer --------------------------------------------------------
behFile = fullfile(sessionPath, 'behavResources.mat');
SD.sig.MovAcctsd = [];
if ~opts.skipAccelero && exist(behFile, 'file')
    B = load(behFile, 'MovAcctsd');
    if isfield(B, 'MovAcctsd')
        SD.sig.MovAcctsd = B.MovAcctsd;
    end
    clear B
elseif ~opts.skipAccelero
    warning('load_session_AG:%s: behavResources.mat not found, accelero unavailable.', sessionName);
end

% --- 5. EMG (optional, HEAVY -- loads full 24-h LFP and FilterLFPs it) ------
SD.sig.EMG_tsd = [];
if ~opts.skipEMG
    emgChanFile = fullfile(sessionPath, 'ChannelsToAnalyse', 'EMG.mat');
    if exist(emgChanFile, 'file')
        C = load(emgChanFile, 'channel');
        lfpFile = fullfile(sessionPath, 'LFPData', sprintf('LFP%d.mat', C.channel));
        if exist(lfpFile, 'file')
            L = load(lfpFile, 'LFP');
            FilLFP = FilterLFP(L.LFP, [50 300], 1024);
            clear L
            smootime = 1; % s
            SD.sig.EMG_tsd = tsd(Range(FilLFP), ...
                runmean(Data(FilLFP).^2, ceil(smootime/median(diff(Range(FilLFP,'s'))))));
            clear FilLFP
        end
    end
end

% --- 6. Spectrograms ---------------------------------------------------------
if opts.skipCoreSpectra
    SD.spec.OBlow   = [];
    SD.spec.OBgamma = [];
    SD.spec.HPClow  = [];
else
    SD.spec.OBlow   = load_spectro_AG(sessionPath, 'B_Low_Spectrum.mat');
    SD.spec.OBgamma = load_spectro_AG(sessionPath, 'B_Middle_Spectrum.mat');
    SD.spec.HPClow  = load_spectro_AG(sessionPath, 'H_Low_Spectrum.mat');
end

% Optional extra regions. Loaded if present; field is left as [] otherwise.
% The lab's spectrum-file naming uses a region prefix followed by a band suffix.
optRegions = { ...
    'HPCmid',  'H_Middle_Spectrum.mat'; ...
    'PFClow',  'P_Low_Spectrum.mat'; ...        % BM's PFC prefix
    'PFClow2', 'PFC_Low_Spectrum.mat'; ...      % alt PFC prefix
    'PFCmid',  'P_Middle_Spectrum.mat'; ...
    'AuCxlow', 'AuCx_Low_Spectrum.mat'; ...
    'AuCxmid', 'AuCx_Middle_Spectrum.mat'};
if ~opts.skipOptionalSpectra
    for k = 1:size(optRegions, 1)
        fp = fullfile(sessionPath, optRegions{k,2});
        if exist(fp, 'file') == 2
            SD.spec.(optRegions{k,1}) = load_spectro_AG(sessionPath, optRegions{k,2});
        else
            SD.spec.(optRegions{k,1}) = [];
        end
    end
    % Collapse PFC alternates (whichever loaded successfully)
    if ~isempty(SD.spec.PFClow2) && isempty(SD.spec.PFClow)
        SD.spec.PFClow = SD.spec.PFClow2;
    end
    SD.spec = rmfield(SD.spec, 'PFClow2');
else
    for k = 1:size(optRegions, 1)
        SD.spec.(optRegions{k,1}) = [];
    end
end

end


function out = downsample_tsd_AG(t, factor)
% Decimate a tsd by an integer factor by simple stride sampling.
% Avoids any FIR filtering -- the smoothed signals are already smoothed.
out = t;
if isempty(t) || factor <= 1, return, end
R = Range(t); D = Data(t);
idx = 1:factor:numel(R);
out = tsd(R(idx), D(idx));
end
