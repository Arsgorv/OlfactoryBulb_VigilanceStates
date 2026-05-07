function SD = load_session_AG(sessionPath, sessionName)
% load_session_AG  Load sleep scoring, smoothed scoring signals, accelero/EMG,
% and pre-computed spectrograms for a single ferret 24-h session.
%
% INPUT
%   sessionPath  absolute path to a session folder containing
%                  SleepScoring_OBGamma.mat, *_Spectrum.mat, behavResources.mat,
%                  ChannelsToAnalyse/, LFPData/
%   sessionName  short label for the session (used for plot titles)
%
% OUTPUT struct SD with fields:
%   path, name
%   states.{Wake, N1, N2, REM, Sleep, NoiseEpoch, TotalEpoch}  (intervalSet, 1e-4 s)
%   states.scheme  'CleanStates' | 'Legacy'
%   totDur_h       recording duration in hours
%   sig.SmoothGamma, sig.SmoothTheta, sig.SmoothDelta_OB  (tsd)
%   sig.MovAcctsd                              (tsd, may be empty)
%   sig.EMG_tsd                                (tsd, may be empty)
%   spec.OBlow, spec.OBgamma, spec.HPClow      each {Sp_tsd, freqs}, may be empty
%
% Behavior on missing optional pieces: the corresponding field is left empty
% and a warning is printed; the function never errors on a missing optional file.

SD = struct();
SD.path = sessionPath;
SD.name = sessionName;

% --- 1. Sleep scoring ---------------------------------------------------------
sleepFile = fullfile(sessionPath, 'SleepScoring_OBGamma.mat');
if ~exist(sleepFile, 'file')
    error('load_session_AG: SleepScoring_OBGamma.mat not found in %s', sessionPath);
end
S = load(sleepFile);

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
if exist(behFile, 'file')
    B = load(behFile, 'MovAcctsd');
    if isfield(B, 'MovAcctsd')
        SD.sig.MovAcctsd = B.MovAcctsd;
    end
else
    warning('load_session_AG:%s: behavResources.mat not found, accelero unavailable.', sessionName);
end

% --- 5. EMG (optional) -------------------------------------------------------
SD.sig.EMG_tsd = [];
emgChanFile = fullfile(sessionPath, 'ChannelsToAnalyse', 'EMG.mat');
if exist(emgChanFile, 'file')
    C = load(emgChanFile, 'channel');
    lfpFile = fullfile(sessionPath, 'LFPData', sprintf('LFP%d.mat', C.channel));
    if exist(lfpFile, 'file')
        L = load(lfpFile, 'LFP');
        % Smoothed band-limited power (50-300 Hz) as EMG proxy
        FilLFP = FilterLFP(L.LFP, [50 300], 1024);
        smootime = 1; % s
        SD.sig.EMG_tsd = tsd(Range(FilLFP), ...
            runmean(Data(FilLFP).^2, ceil(smootime/median(diff(Range(FilLFP,'s'))))));
    end
end

% --- 6. Spectrograms ---------------------------------------------------------
SD.spec.OBlow   = load_spectro_AG(sessionPath, 'B_Low_Spectrum.mat');
SD.spec.OBgamma = load_spectro_AG(sessionPath, 'B_Middle_Spectrum.mat');
SD.spec.HPClow  = load_spectro_AG(sessionPath, 'H_Low_Spectrum.mat');

end
