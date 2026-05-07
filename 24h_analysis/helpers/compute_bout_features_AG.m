function BF = compute_bout_features_AG(SD, thresholds_min)
% compute_bout_features_AG  For each bout in each state, compute mean values
% of EMG, accelerometer, OB gamma, OB delta and HPC theta/delta inside the
% bout. Bouts are then split into "short" and "long" using per-state
% duration thresholds (in minutes). Wake is kept as a single group.
%
% INPUT
%   SD                output of load_session_AG
%   thresholds_min    struct with optional fields .N1 .N2 .REM giving the
%                     bout-duration cutoff (in minutes) separating short
%                     from long bouts. Defaults: N1=0.5, N2=2, REM=2.5.
%                     These reflect the typical trough between the two
%                     modes seen in your bout-duration histograms.
%
% OUTPUT struct BF:
%   groupNames        cellstr of subgroup labels {'Wake','N1 short','N1 long',
%                     'N2 short','N2 long','REM short','REM long'}
%   groupColors       cell of RGB triplets matching groupNames (parent state
%                     color; short bouts slightly darker, long slightly lighter)
%   featNames         {'EMG','Accelero','OB gamma','OB delta','HPC theta/delta',
%                     'Bout duration (min)'}
%   X                 cell {nFeats x nGroups} of feature-value vectors
%                     (one per bout)
%   thresholds_min    the thresholds actually used
%
% Notes
%   - Means are taken on raw values for accelero / EMG / power signals; for
%     plotting on log axes use semilogy in the plotter.
%   - "Wake" is not split because Wake bout-duration distributions in this
%     dataset are essentially unimodal in log-time. If you want to split it,
%     pass thresholds_min.Wake explicitly.
%   - HPC theta/delta is the SmoothTheta tsd (already a ratio).

if nargin < 2 || ~isstruct(thresholds_min)
    thresholds_min = struct();
end
if ~isfield(thresholds_min,'N1'),  thresholds_min.N1  = 0.5; end   % 30 s
if ~isfield(thresholds_min,'N2'),  thresholds_min.N2  = 2.0; end   % 120 s
if ~isfield(thresholds_min,'REM'), thresholds_min.REM = 2.5; end   % 150 s
if ~isfield(thresholds_min,'Wake'), thresholds_min.Wake = []; end  % no split

% --- Build group definitions -------------------------------------------------
states = {SD.states.Wake, SD.states.N1, SD.states.N2, SD.states.REM};
stateNames = {'Wake','N1','N2','REM'};
% Use a cell array so empty thresholds remain in place (numeric concat would
% drop them silently and shift the indices).
stateThr   = {thresholds_min.Wake, thresholds_min.N1, thresholds_min.N2, thresholds_min.REM};

cBase = state_colors_AG();
groupNames  = {};
groupEpochs = {};
groupCols   = {};
for i = 1:4
    if isempty(states{i}) || isempty(stateThr{i})
        groupNames{end+1}  = stateNames{i}; %#ok<AGROW>
        groupEpochs{end+1} = states{i}; %#ok<AGROW>
        groupCols{end+1}   = cBase.colors{i}; %#ok<AGROW>
    else
        thr_ts = stateThr{i} * 60 * 1e4;
        st = Start(states{i});
        en = Stop(states{i});
        durTs = en - st;
        idxShort = durTs <  thr_ts;
        idxLong  = durTs >= thr_ts;
        if any(idxShort)
            groupNames{end+1}  = sprintf('%s short', stateNames{i}); %#ok<AGROW>
            groupEpochs{end+1} = intervalSet(st(idxShort), en(idxShort)); %#ok<AGROW>
            groupCols{end+1}   = darken(cBase.colors{i}, 0.7); %#ok<AGROW>
        end
        if any(idxLong)
            groupNames{end+1}  = sprintf('%s long', stateNames{i}); %#ok<AGROW>
            groupEpochs{end+1} = intervalSet(st(idxLong), en(idxLong)); %#ok<AGROW>
            groupCols{end+1}   = lighten(cBase.colors{i}, 0.4); %#ok<AGROW>
        end
    end
end
nG = numel(groupEpochs);

% --- Feature signals --------------------------------------------------------
sigList = struct();
sigList.EMG               = SD.sig.EMG_tsd;
sigList.Accelero          = SD.sig.MovAcctsd;
sigList.OBgamma           = SD.sig.SmoothGamma;
sigList.OBdelta           = SD.sig.SmoothDelta_OB;
sigList.HPCthetadelta     = SD.sig.SmoothTheta;

featNames = {'EMG','Accelero','OB gamma','OB delta','HPC theta/delta', ...
             'Bout duration (min)'};
nF = numel(featNames);

X = cell(nF, nG);
sigKeys = {'EMG','Accelero','OBgamma','OBdelta','HPCthetadelta'};

for g = 1:nG
    ep = groupEpochs{g};
    if isempty(Start(ep)), continue, end
    nBouts = length(Start(ep));

    % first 5 features: per-bout mean signal value
    for f = 1:5
        sig = sigList.(sigKeys{f});
        v = nan(nBouts, 1);
        if ~isempty(sig)
            for k = 1:nBouts
                small = subset(ep, k);
                d = Data(Restrict(sig, small));
                if ~isempty(d), v(k) = nanmean(d); end
            end
        end
        X{f, g} = v;
    end

    % feature 6: bout duration in minutes
    durMin = (Stop(ep) - Start(ep)) / (60*1e4);
    X{6, g} = durMin;
end

BF.groupNames     = groupNames;
BF.groupColors    = groupCols;
BF.featNames      = featNames;
BF.X              = X;
BF.thresholds_min = thresholds_min;

end


function c = darken(c, frac)
c = max(0, c * (1 - frac));
end

function c = lighten(c, frac)
c = c + (1 - c) * frac;
end
