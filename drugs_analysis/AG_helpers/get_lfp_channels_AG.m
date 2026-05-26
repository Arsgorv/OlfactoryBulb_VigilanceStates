function chans = get_lfp_channels_AG(datapath)
%GET_LFP_CHANNELS_AG  Return a struct of named LFP channels for a session.
% Wraps get_trigger_config(datapath) when available; otherwise tries
% ChannelsToAnalyse/<name>.mat. Returns struct with possible fields:
%   respi, EMG, EKG, OB, HPC, PFC, ACx, AuCx, H, PFCx
% Each is the integer LFP channel number, or NaN.

chans = struct('respi',NaN,'EMG',NaN,'EKG',NaN, ...
               'OB',NaN,'HPC',NaN,'PFC',NaN,'ACx',NaN, ...
               'AuCx',NaN,'H',NaN,'PFCx',NaN);

% Preferred: get_trigger_config
if exist('get_trigger_config','file') == 2
    try
        cfg = get_trigger_config(datapath);
        flds = fieldnames(chans);
        for k = 1:length(flds)
            f = flds{k};
            if isfield(cfg, f)
                v = cfg.(f);
                if isnumeric(v) && ~isempty(v) && isfinite(v(1))
                    chans.(f) = double(v(1));
                end
            end
        end
    catch
        % fall through to ChannelsToAnalyse fallback
    end
end

% Fallback: ChannelsToAnalyse/<name>.mat
chTemplate = fullfile(datapath, 'ephys', 'ChannelsToAnalyse');
if ~exist(chTemplate, 'dir')
    chTemplate = fullfile(datapath, 'ChannelsToAnalyse');
end
if exist(chTemplate, 'dir')
    flds = fieldnames(chans);
    for k = 1:length(flds)
        f = flds{k};
        if isfinite(chans.(f)), continue, end
        candidate = fullfile(chTemplate, [lower(f) '.mat']);
        if ~exist(candidate, 'file')
            candidate = fullfile(chTemplate, [f '.mat']);
        end
        if exist(candidate, 'file')
            try
                S = load(candidate, 'channel');
                if isfield(S,'channel') && ~isempty(S.channel) && isfinite(S.channel(1))
                    chans.(f) = double(S.channel(1));
                end
            catch
            end
        end
    end
end
end
