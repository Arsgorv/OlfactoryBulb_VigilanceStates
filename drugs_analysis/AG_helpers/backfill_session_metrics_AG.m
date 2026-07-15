function [Mout, did_backfill, Grow_add] = backfill_session_metrics_AG(D, S_or_ana, M_in, Bands, params, cacheFile)
%BACKFILL_SESSION_METRICS_AG  Cache-preserving backfill of v7.1+ fields.
% Returns Grow_add ALWAYS (loaded from cache if present, else computed) so
% the caller can always append time courses to Group, regardless of whether
% the scalar metrics needed recomputation.

Mout = M_in;
did_backfill = false;
Grow_add = struct();
Arow_add_bp = struct();

datapath = D.path;
Ana_s = S_or_ana;

Tref_s = Ana_s.Tref;
ib     = Ana_s.idx_before;
ia     = Ana_s.idx_after;
t_inj  = Ana_s.t_inj;
hasFUS_s = isfield(Ana_s,'hpc') && any(isfinite(Ana_s.hpc));
if hasFUS_s
    log_hpc_long_s = Ana_s.log_hpc_long;
    log_aeg_long_s = Ana_s.log_aeg_long;
end

PostTimeGridSec = params.PostTimeGridSec;
tcFields = {'lowgamma_after_real','gamma_brainpower_after_real','highgamma_after_real', ...
            'beta_after_real','theta_after_real','delta_brainpower_after_real'};

% --- 1) Try to load time courses (and breath rate) from cache file ---
%     This is the cheap path — applies even when scalar metrics are already cached.
if nargin >= 6 && ~isempty(cacheFile) && exist(cacheFile, 'file')
    try
        Lc = load(cacheFile, 'Grow');
        if isfield(Lc, 'Grow') && isstruct(Lc.Grow)
            for k = 1:numel(tcFields)
                if isfield(Lc.Grow, tcFields{k}) && ~isempty(Lc.Grow.(tcFields{k}))
                    Grow_add.(tcFields{k}) = Lc.Grow.(tcFields{k});
                end
            end
        end
    catch
        % silent: missing/partial cache is acceptable
    end
end

% --- 2) Need scalar backfill? ---
keyNewFields = {'gamma_brainpower_logratio','breath_rate_after_hz','beta_brainpower_logratio'};
needsBackfill = false;
for k = 1:numel(keyNewFields)
    if ~isfield(M_in, keyNewFields{k}) || ~isfinite(M_in.(keyNewFields{k}))
        needsBackfill = true; break
    end
end

% --- 3) If we already have full Grow_add AND no scalar backfill needed, exit ---
% (fast path on subsequent runs once cache is fully populated)
if ~needsBackfill && numel(fieldnames(Grow_add)) >= 4
    return
end

% --- 4) OB channel ---
chans = get_lfp_channels_AG(datapath);
ob_ch = NaN;
if isfield(chans, 'OB') && isfinite(chans.OB), ob_ch = chans.OB; end
if ~isfinite(ob_ch)
    candidates = {'Bulb_deep','Bulb','OB','B'};
    for c = 1:numel(candidates)
        f1 = fullfile(datapath,'ephys','ChannelsToAnalyse',[candidates{c} '.mat']);
        f2 = fullfile(datapath,'ChannelsToAnalyse',[candidates{c} '.mat']);
        if exist(f1,'file'), L = load(f1,'channel'); if isfield(L,'channel') && isfinite(L.channel(1)), ob_ch = L.channel(1); break, end, end
        if exist(f2,'file'), L = load(f2,'channel'); if isfield(L,'channel') && isfinite(L.channel(1)), ob_ch = L.channel(1); break, end, end
    end
end

bandsBP = struct('delta', Bands.delta, 'theta', Bands.theta, ...
                 'beta',  Bands.beta,  'lowGamma', Bands.lowGamma, ...
                 'gamma', Bands.gamma, 'highGamma', Bands.highGamma);
BP = struct();
if isfinite(ob_ch)
    try, BP = compute_brainpower_subbands_AG(datapath, ob_ch, params.TraceSmoothSec, bandsBP);
    catch ME, warning('Backfill BP failed for %s: %s', D.path, ME.message); end
end

bp_fld_map = {'delta','delta_brainpower'; 'theta','theta_brainpower'; ...
              'beta','beta_brainpower';   'lowGamma','lowgamma_brainpower'; ...
              'gamma','gamma_brainpower'; 'highGamma','highgamma_brainpower'};
bp_to_group = {'lowGamma','lowgamma_after_real'; ...
               'gamma','gamma_brainpower_after_real'; ...
               'highGamma','highgamma_after_real'; ...
               'beta','beta_after_real'; ...
               'theta','theta_after_real'; ...
               'delta','delta_brainpower_after_real'};

binEdgesMin = [-Inf -5 5 15 30 60 Inf];
binNames    = {'pre','peri','b0_15','b15_30','b30_60','b60plus'};
tRel = (Tref_s - t_inj)/60;

for bk = 1:size(bp_fld_map,1)
    bnm = bp_fld_map{bk,1};
    pre = bp_fld_map{bk,2};
    if isfield(BP, bnm) && ~isempty(BP.(bnm))
        t_bp = Range(BP.(bnm),'s'); d_bp = Data(BP.(bnm));
        x_bp = interp1(t_bp, d_bp, Tref_s, 'linear', NaN);

        if needsBackfill
            Mout.([pre '_logratio'])    = log_ratio_median(x_bp, ib, ia);
            Mout.(['pre_half_' pre '_log']) = pre_half_noise_AG(x_bp, ib);
            if hasFUS_s
                xlong = smooth_by_time(safe_log(x_bp), Tref_s, params.LongSmoothSec);
                Mout.([pre '_hpc_r_before']) = corr_nan(xlong(ib), log_hpc_long_s(ib));
                Mout.([pre '_hpc_r_after'])  = corr_nan(xlong(ia), log_hpc_long_s(ia));
                Mout.([pre '_aeg_r_before']) = corr_nan(xlong(ib), log_aeg_long_s(ib));
                Mout.([pre '_aeg_r_after'])  = corr_nan(xlong(ia), log_aeg_long_s(ia));
            end
        end

        base_pre = nanmedian(x_bp(ib));
        if isnan(base_pre) || base_pre <= 0, base_pre = 1; end
        x_norm = x_bp ./ base_pre;

        if needsBackfill
            for bb = 1:length(binNames)
                lo = binEdgesMin(bb); hi = binEdgesMin(bb+1);
                idx_bin = tRel >= lo & tRel < hi & isfinite(x_norm);
                fldNm = [pre '_' binNames{bb} '_med'];
                if sum(idx_bin) >= 5, Mout.(fldNm) = nanmedian(x_norm(idx_bin));
                else, Mout.(fldNm) = NaN; end
            end
        end

        % Save the Tref-aligned BP envelope into Arow for distributions
        Arow_add_bp.(['bp_' lower(strrep(bnm,'Gamma','gamma'))]) = x_bp;
        % Time course on PostTimeGridSec (always computed when LFP loaded)
        for tg = 1:size(bp_to_group,1)
            if strcmp(bp_to_group{tg,1}, bnm)
                Grow_add.(bp_to_group{tg,2}) = interp_relative_time(Tref_s, x_norm, t_inj, PostTimeGridSec);
                break
            end
        end
    end
end

% --- Breath rate via Hilbert IF ---
if needsBackfill
    respiCTA = fullfile(datapath, 'ephys', 'ChannelsToAnalyse', 'respi.mat');
    if ~exist(respiCTA, 'file'), respiCTA = fullfile(datapath, 'ChannelsToAnalyse', 'respi.mat'); end
    RespLFP = [];
    if exist(respiCTA, 'file')
        chS = load(respiCTA, 'channel');
        if isfield(chS,'channel') && ~isempty(chS.channel) && isfinite(chS.channel(1))
            respi_ch = chS.channel(1);
            lfpFile = fullfile(datapath, 'ephys', 'LFPData', ['LFP' num2str(respi_ch) '.mat']);
            if ~exist(lfpFile,'file'), lfpFile = fullfile(datapath, 'LFPData', ['LFP' num2str(respi_ch) '.mat']); end
            if exist(lfpFile, 'file')
                lS = load(lfpFile, 'LFP');
                if isfield(lS,'LFP'), RespLFP = lS.LFP; end
            end
        end
    end
    if ~isempty(RespLFP)
        try
            brate = compute_breath_rate_AG(RespLFP, Tref_s, 5);
            Mout.breath_rate_before_hz = nanmedian(brate(ib));
            Mout.breath_rate_after_hz  = nanmedian(brate(ia));
        catch ME, warning('Backfill breath failed for %s: %s', D.path, ME.message); end
    end
end

did_backfill = needsBackfill;

% --- Update cache file in place (with time courses too) ---
if nargin >= 6 && ~isempty(cacheFile) && exist(cacheFile, 'file')
    try
        Lc = load(cacheFile);
        Mrow = Lc.Mrow;
        newF = setdiff(fieldnames(Mout), fieldnames(Mrow));
        for k = 1:numel(newF), Mrow.(newF{k}) = Mout.(newF{k}); end
        if needsBackfill
            updateAlways = {'breath_rate_before_hz','breath_rate_after_hz'};
            for bk = 1:size(bp_fld_map,1)
                pre = bp_fld_map{bk,2};
                updateAlways{end+1} = [pre '_logratio']; %#ok<*AGROW>
                updateAlways{end+1} = ['pre_half_' pre '_log'];
                updateAlways{end+1} = [pre '_hpc_r_before'];
                updateAlways{end+1} = [pre '_hpc_r_after'];
                updateAlways{end+1} = [pre '_aeg_r_before'];
                updateAlways{end+1} = [pre '_aeg_r_after'];
                for bb = 1:length(binNames), updateAlways{end+1} = [pre '_' binNames{bb} '_med']; end
            end
            for k = 1:numel(updateAlways)
                f = updateAlways{k};
                if isfield(Mout, f), Mrow.(f) = Mout.(f); end
            end
        end
        Lc.Mrow = Mrow;
        if isfield(Lc, 'Grow') && ~isempty(fieldnames(Grow_add))
            gnames = fieldnames(Grow_add);
            for k = 1:numel(gnames), Lc.Grow.(gnames{k}) = Grow_add.(gnames{k}); end
        end
        % Also persist sub-band BP envelopes into Arow for distribution plots
        if isfield(Lc, 'Arow') && ~isempty(fieldnames(Arow_add_bp))
            anames = fieldnames(Arow_add_bp);
            for k = 1:numel(anames), Lc.Arow.(anames{k}) = Arow_add_bp.(anames{k}); end
        end
        save(cacheFile, '-struct', 'Lc', '-v7.3');
    catch ME, warning('Backfill cache-update failed for %s: %s', cacheFile, ME.message); end
end
end
