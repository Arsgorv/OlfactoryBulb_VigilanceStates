%% ---------------- Setup ----------------
clear all

rng(1)
nKeep = 2000;   % total dots for each session in center plots

%% ---------------- Load sessions ----------------
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241211_TORCs')
L1 = load('SleepScoring_OBGamma.mat','SmoothTheta','SmoothGamma','SmoothDelta_OB','Sleep');

cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241211_TORCs')
L2 = load('SleepScoring_OBGamma.mat','SmoothTheta','SmoothGamma','SmoothDelta_OB',...
    'Wake','SWSEpoch','REMEpoch','ISEpoch');

%% ---------------- Log-transform BEFORE restriction (mask non-positive -> NaN) ----------------
% Session 1
x = Data(L1.SmoothGamma);    x(x<=0) = NaN; L1.SmoothGamma    = tsd(Range(L1.SmoothGamma),    log10(x));
x = Data(L1.SmoothTheta);    x(x<=0) = NaN; L1.SmoothTheta    = tsd(Range(L1.SmoothTheta),    log10(x));
x = Data(L1.SmoothDelta_OB); x(x<=0) = NaN; L1.SmoothDelta_OB = tsd(Range(L1.SmoothDelta_OB), log10(x));

% Session 2
x = Data(L2.SmoothGamma);    x(x<=0) = NaN; L2.SmoothGamma    = tsd(Range(L2.SmoothGamma),    log10(x));
x = Data(L2.SmoothTheta);    x(x<=0) = NaN; L2.SmoothTheta    = tsd(Range(L2.SmoothTheta),    log10(x));
x = Data(L2.SmoothDelta_OB); x(x<=0) = NaN; L2.SmoothDelta_OB = tsd(Range(L2.SmoothDelta_OB), log10(x));

%% ---------------- Restrict afterwards ----------------
% range1 = or(intervalSet(0  , 1000e4) , intervalSet(8200e4  , 9000e4));
range1 = intervalSet(0  , 15000e4);
L1.SmoothGamma    = Restrict(L1.SmoothGamma   , range1);
L1.SmoothTheta    = Restrict(L1.SmoothTheta   , L1.SmoothGamma);
L1.SmoothDelta_OB = Restrict(L1.SmoothDelta_OB, L1.SmoothGamma);

% range2 = or(intervalSet(11400e4,11900e4), intervalSet(13500e4,14800e4));
range2 = intervalSet(0  , 15000e4);
L2.SmoothGamma    = Restrict(L2.SmoothGamma   , range2);
L2.SmoothTheta    = Restrict(L2.SmoothTheta   , L2.SmoothGamma);
L2.SmoothDelta_OB = Restrict(L2.SmoothDelta_OB, L2.SmoothGamma);

%% ---------------- Extract arrays (already logged) ----------------
% Session 1
g1 = Data(L1.SmoothGamma);  t1 = Data(L1.SmoothTheta);  d1 = Data(L1.SmoothDelta_OB);
m1 = ~isnan(g1) & ~isnan(t1) & ~isnan(d1); g1 = g1(m1); t1 = t1(m1); d1 = d1(m1);

% Session 2
g2 = Data(L2.SmoothGamma);  t2 = Data(L2.SmoothTheta);  d2 = Data(L2.SmoothDelta_OB);
m2 = ~isnan(g2) & ~isnan(t2) & ~isnan(d2); g2 = g2(m2); t2 = t2(m2); d2 = d2(m2);

%% ---------------- Session 2 state-specific subsets (aligned via Restrict) ----------------
% Wake
g2_wake_tsd = Restrict(L2.SmoothGamma, L2.Wake);
t2_wake_tsd = Restrict(L2.SmoothTheta, g2_wake_tsd);
d2_wake_tsd = Restrict(L2.SmoothDelta_OB, g2_wake_tsd);
g2_wake = Data(g2_wake_tsd); t2_wake = Data(t2_wake_tsd); d2_wake = Data(d2_wake_tsd);
m = ~isnan(g2_wake) & ~isnan(t2_wake) & ~isnan(d2_wake);
g2_wake = g2_wake(m); t2_wake = t2_wake(m); d2_wake = d2_wake(m);

% SWS
g2_sws_tsd = Restrict(L2.SmoothGamma, L2.SWSEpoch);
t2_sws_tsd = Restrict(L2.SmoothTheta, g2_sws_tsd);
d2_sws_tsd = Restrict(L2.SmoothDelta_OB, g2_sws_tsd);
g2_sws = Data(g2_sws_tsd); t2_sws = Data(t2_sws_tsd); d2_sws = Data(d2_sws_tsd);
m = ~isnan(g2_sws) & ~isnan(t2_sws) & ~isnan(d2_sws);
g2_sws = g2_sws(m); t2_sws = t2_sws(m); d2_sws = d2_sws(m);

% IS
g2_is_tsd = Restrict(L2.SmoothGamma, L2.ISEpoch);
t2_is_tsd = Restrict(L2.SmoothTheta, g2_is_tsd);
d2_is_tsd = Restrict(L2.SmoothDelta_OB, g2_is_tsd);
g2_is = Data(g2_is_tsd); t2_is = Data(t2_is_tsd); d2_is = Data(d2_is_tsd);
m = ~isnan(g2_is) & ~isnan(t2_is) & ~isnan(d2_is);
g2_is = g2_is(m); t2_is = t2_is(m); d2_is = d2_is(m);

% REM
g2_rem_tsd = Restrict(L2.SmoothGamma, L2.REMEpoch);
t2_rem_tsd = Restrict(L2.SmoothTheta, g2_rem_tsd);
d2_rem_tsd = Restrict(L2.SmoothDelta_OB, g2_rem_tsd);
g2_rem = Data(g2_rem_tsd); t2_rem = Data(t2_rem_tsd); d2_rem = Data(d2_rem_tsd);
m = ~isnan(g2_rem) & ~isnan(t2_rem) & ~isnan(d2_rem);
g2_rem = g2_rem(m); t2_rem = t2_rem(m); d2_rem = d2_rem(m);

% Sleep
g1_sleep_tsd = Restrict(L1.SmoothGamma, L1.Sleep);
t1_sleep_tsd = Restrict(L1.SmoothTheta, g1_sleep_tsd);
d1_sleep_tsd = Restrict(L2.SmoothDelta_OB, g1_sleep_tsd);
g1_sleep = Data(g1_sleep_tsd); t1_sleep = Data(t1_sleep_tsd); d1_sleep = Data(d1_sleep_tsd);
m = ~isnan(g1_sleep) & ~isnan(t1_sleep) & ~isnan(d1_sleep);
g1_sleep = g1_sleep(m); t1_sleep = t1_sleep(m); d1_sleep = d1_sleep(m);


%% ---------------- Sleep unions for distributions ----------------
Sleep2_all = union(union(L2.SWSEpoch, L2.ISEpoch), L2.REMEpoch);  % all sleep
Sleep2_NR  = union(L2.SWSEpoch, L2.ISEpoch);                      % non-REM (SWS∪IS)

% Session 2 distributions (already logged signals)
T2_sleep     = Data(Restrict(L2.SmoothTheta,    Sleep2_all));   T2_sleep   = T2_sleep(~isnan(T2_sleep));
D2_sleepNR   = Data(Restrict(L2.SmoothDelta_OB, Sleep2_NR));    D2_sleepNR = D2_sleepNR(~isnan(D2_sleepNR));

% Session 1 
Sleep1_all = L1.Sleep;
Sleep1_NR = L1.Sleep;

T1_sleep     = Data(Restrict(L1.SmoothTheta,    Sleep1_all));   T1_sleep   = T1_sleep(~isnan(T1_sleep));
D1_sleepNR   = Data(Restrict(L1.SmoothDelta_OB, Sleep1_NR));    D1_sleepNR = D1_sleepNR(~isnan(D1_sleepNR));

%% ---------------- Subsample for center plots ----------------
% Session 1 (all epochs)
if numel(g1) > nKeep, idx = randperm(numel(g1), nKeep); else, idx = 1:numel(g1); end
g1s = g1(idx); t1s = t1(idx); d1s = d1(idx);

% Session 2 (Figure 1 center: Wake, SWS∪IS, REM) — proportional split
nW = numel(g2_wake);
nSIS = numel(g2_sws) + numel(g2_is);
nR = numel(g2_rem);
tot = nW + nSIS + nR; kW = 0; kS = 0; kR = 0;
if tot > 0
    kW = floor(nKeep * nW   / tot);
    kS = floor(nKeep * nSIS / tot);
    kR = floor(nKeep * nR   / tot);
    remk = nKeep - (kW + kS + kR);
    counts = [nW nSIS nR];
    [~,ord] = sort(counts,'descend');
    for ii = 1:remk
        if ord(ii)==1, kW = kW+1;
        elseif ord(ii)==2, kS = kS+1;
        else, kR = kR+1;
        end
    end
end
% Draw sub-samples
if nW>0,   if nW>kW,   idx = randperm(nW,kW);   else, idx = 1:nW;   end; g2_wake_s = g2_wake(idx); t2_wake_s = t2_wake(idx); else, g2_wake_s = []; t2_wake_s = []; end
g2_sis = [g2_sws; g2_is]; t2_sis = [t2_sws; t2_is];
nSI = numel(g2_sis);
if nSI>0,  if nSI>kS,  idx = randperm(nSI,kS); else, idx = 1:nSI;  end; g2_sis_s = g2_sis(idx); t2_sis_s = t2_sis(idx); else, g2_sis_s = []; t2_sis_s = []; end
if nR>0,   if nR>kR,   idx = randperm(nR,kR);   else, idx = 1:nR;   end; g2_rem_s  = g2_rem(idx);  t2_rem_s  = t2_rem(idx);  else, g2_rem_s  = []; t2_rem_s  = []; end

%% ---------------- Figure 1: logGamma vs logTheta ----------------
allG = [g1; g2]; allT = [t1; t2];
xL = [prctile(allG,1) prctile(allG,99)];
yL = [prctile(allT,1) prctile(allT,99)];
xPad = 0.2*range(xL); yPad = 0.2*range(yL);
xL = [xL(1)-xPad, xL(2)+xPad]; yL = [yL(1)-yPad, yL(2)+yPad];

figure('Color','w');

% Center scatter
subplot(6,6,[2:6 8:12 14:18 20:24 26:30]); hold on
plot(g1s, t1s, '.', 'Color',[0.5 0.5 0.5])      % Session 1 gray
plot(g2_wake_s, t2_wake_s, '.', 'Color','b')    % Wake blue
plot(g2_sis_s,  t2_sis_s,  '.', 'Color','r')    % SWS∪IS red
plot(g2_rem_s,  t2_rem_s,  '.', 'Color','g')    % REM green

% Convex hulls (whole epochs)
if numel(g1)>=3
    K1 = convhull(g1,t1); A1_theta = polyarea(g1(K1),t1(K1));
    plot(g1(K1),t1(K1),'Color',[0.5 0.5 0.5],'LineWidth',2)
else
    A1_theta = NaN;
end
if numel(g2)>=3
    K2 = convhull(g2,t2); A2_theta = polyarea(g2(K2),t2(K2));
    plot(g2(K2),t2(K2),'k-','LineWidth',2)
else
    A2_theta = NaN;
end

xlim(xL); ylim(yL); axis square; box on; grid on
xticklabels({''}), yticklabels({''})
title('Gamma/Theta space')
legend({'Head-fixed','Wake','SWS ∪ IS','REM','Hull S1','Hull S2'},'Location','best')

% Left distribution: Theta (sleep all; S2 black, S1 gray)
subplot(6,6,[25 19 13 7 1]); hold on
[f_t1, yi_t1] = ksdensity(T1_sleep);
[f_ts, yi_ts] = ksdensity(T2_sleep);
plot(f_t1, yi_t1, 'Color',[0.5 0.5 0.5], 'LineWidth',1.5)
plot(f_ts, yi_ts, 'k-', 'LineWidth',1.5)
ylim(yL); xlabel('PDF'); ylabel('log_{10}(SmoothTheta)')
box on; grid on;

% Bottom distribution: logGamma (all epochs; S2 black, S1 gray)
subplot(6,6,32:36); hold on
[f_g1, xi_g1] = ksdensity(g1);
[f_g2, xi_g2] = ksdensity(g2);
plot(xi_g1, f_g1, 'Color',[0.5 0.5 0.5], 'LineWidth',1.5)
plot(xi_g2, f_g2, 'k-', 'LineWidth',1.5)
xlim(xL); xlabel('log_{10}(SmoothGamma)'); ylabel('PDF')
box on; grid on;

%% ---------------- Figure 2: logTheta vs logDelta (sleep-only for S2) ----------------
% Pools for S2 sleep-only (for limits and hull)
d2_sws(d2_sws>3) = NaN; d2_is(d2_is>3) = NaN;
t2_allSleep = [t2_sws; t2_is; t2_rem];
d2_allSleep = [d2_sws; d2_is; d2_rem];

allT2 = [t1; t2_allSleep];
allD2 = [d1; d2_allSleep];
xL = [prctile(allT2,1) prctile(allT2,99)];
yL = [prctile(allD2,1) prctile(allD2,99)];
xPad = 0.2*range(xL); yPad = 0.2*range(yL);
xL = [xL(1)-xPad, xL(2)+xPad]; yL = [yL(1)-yPad, yL(2)+yPad];

figure('Color','w');

% Center scatter (S1 gray; S2 sleep-only: SWS red, IS orange, REM green)
subplot(6,6,[2:6 8:12 14:18 20:24 26:30]); hold on
plot(T1_sleep(1:ceil(length(T1_sleep)/1000):end), D1_sleepNR(1:ceil(length(T1_sleep)/1000):end), '.', 'Color',[0.5 0.5 0.5])

% Subsample S2 sleep-only to ~nKeep across SWS/IS/REM
nS = numel(t2_sws); nI = numel(t2_is); nR = numel(t2_rem);
tot = nS + nI + nR; kS = 0; kI = 0; kR = 0;
if tot > 0
    kS = floor(nKeep * nS / tot);
    kI = floor(nKeep * nI / tot);
    kR = floor(nKeep * nR / tot);
    remk = nKeep - (kS + kI + kR);
    counts = [nS nI nR];
    [~,ord] = sort(counts,'descend');
    for ii = 1:remk
        if ord(ii)==1, kS = kS+1;
        elseif ord(ii)==2, kI = kI+1;
        else, kR = kR+1;
        end
    end
end

if nS>0, if nS>kS, idx = randperm(nS,kS); else, idx = 1:nS; end; t2_sws_s = t2_sws(idx); d2_sws_s = d2_sws(idx); else, t2_sws_s = []; d2_sws_s = []; end
if nI>0, if nI>kI, idx = randperm(nI,kI); else, idx = 1:nI; end; t2_is_s  = t2_is(idx);  d2_is_s  = d2_is(idx);  else, t2_is_s  = []; d2_is_s  = []; end
if nR>0, if nR>kR, idx = randperm(nR,kR); else, idx = 1:nR; end; t2_rem_s = t2_rem(idx); d2_rem_s = d2_rem(idx); else, t2_rem_s = []; d2_rem_s = []; end


plot(t2_sws_s, d2_sws_s, '.', 'Color','r')        % SWS red
plot(t2_is_s,  d2_is_s,  '.', 'Color',[1 0.5 0])  % IS orange
plot(t2_rem_s, d2_rem_s, '.', 'Color','g')        % REM green

% Convex hulls (Theta–Delta)
if numel(T1_sleep)>=3
    K1 = convhull(T1_sleep,D1_sleepNR); A1_td = polyarea(T1_sleep(K1),D1_sleepNR(K1));
    plot(T1_sleep(K1),D1_sleepNR(K1),'Color',[0.5 0.5 0.5],'LineWidth',2)
else
    A1_td = NaN;
end
t2_allSleep(isnan(d2_allSleep)) = []; d2_allSleep(isnan(d2_allSleep)) = [];
t2_allSleep(d2_allSleep>3) = []; d2_allSleep(d2_allSleep>3) = [];
if numel(t2_allSleep)>=3
    K2 = convhull(t2_allSleep,d2_allSleep); A2_td = polyarea(t2_allSleep(K2), d2_allSleep(K2));
    plot(t2_allSleep(K2), d2_allSleep(K2), 'k-', 'LineWidth',2)
else
    A2_td = NaN;
end
xlim(xL); ylim(yL); axis square; box on; grid on
xticklabels({''}), yticklabels({''})
title('Theta/Delta space')
legend({'Head-fixed','SWS (S2)','IS (S2)','REM (S2)','Hull S1','Hull S2'},'Location','best')

% Left distribution: logDelta for non-REM (SWS∪IS) — S2 black; S1 gray
subplot(6,6,[25 19 13 7 1]); hold on
[f_d1, yi_d1]   = ksdensity(D1_sleepNR);       % S1 all epochs
[f_dnr, yi_dnr] = ksdensity(D2_sleepNR);   % S2 non-REM (IS∪SWS)
plot(f_d1,  yi_d1,  'Color',[0.5 0.5 0.5], 'LineWidth',1.5)
plot(f_dnr, yi_dnr, 'k-', 'LineWidth',1.5)
ylim(yL); xlabel('PDF'); ylabel('log_{10}(SmoothDelta-OB)')
box on; grid on; 

% Bottom distribution: logTheta for all sleep (IS∪SWS∪REM) — S2 black; S1 gray
subplot(6,6,32:36); hold on
[f_t1b, xi_t1b] = ksdensity(T1_sleep);           % S1 all epochs
[f_tsb, xi_tsb] = ksdensity(t2_allSleep);      % S2 sleep-only
plot(xi_t1b, f_t1b, 'Color',[0.5 0.5 0.5], 'LineWidth',1.5)
plot(xi_tsb, f_tsb, 'k-', 'LineWidth',1.5)
xlim(xL); xlabel('log_{10}(SmoothTheta)'); ylabel('PDF')
box on; grid on; 







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clear all

rng(1)
nKeep = 500;

%% ---------------- Session 1 (head-fixed) ----------------
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241211_TORCs')
load('SleepScoring_OBGamma.mat','SmoothGamma','SmoothTheta','SmoothDelta_OB','Sleep','SWSEpoch','REMEpoch','ISEpoch')

% Align Theta/Delta to Gamma
SmoothTheta    = Restrict(SmoothTheta   , SmoothGamma);
SmoothDelta_OB = Restrict(SmoothDelta_OB, SmoothGamma);

% Arrays (logGamma, Theta linear, logDelta)
g1 = Data(SmoothGamma);
t1 = Data(SmoothTheta);
d1 = Data(SmoothDelta_OB);
ok1 = g1>0 & d1>0 & ~isnan(t1);
g1 = log10(g1(ok1));
t1 = t1(ok1);
d1 = log10(d1(ok1));

% Sleep-only (for Theta–Delta space)
Sleep1 = [];
try
    % Prefer union of SWS/IS/REM if present
    Sleep1 = union(union(SWSEpoch, ISEpoch), REMEpoch);
catch
    if exist('Sleep','var'); Sleep1 = Sleep; end
end
if isempty(Sleep1)
    % If no sleep epochs found, fall back to "all"
    t1_sleep = t1;
    d1_sleep = d1;
else
    t1_sleep = Data(Restrict(SmoothTheta,    Sleep1));  % SmoothTheta already restricted to SmoothGamma
    d1_sleep = Data(Restrict(SmoothDelta_OB, Sleep1));
    ok = ~isnan(t1_sleep) & ~isnan(d1_sleep);
    t1_sleep = t1_sleep(ok);
    d1_sleep = log10(d1_sleep(ok));  % ensure log for delta (if not already)
end

%% ---------------- Session 2 (freely-moving) ----------------
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241211_TORCs')
load('SleepScoring_OBGamma.mat','SmoothGamma','SmoothTheta','SmoothDelta_OB','Sleep','SWSEpoch','REMEpoch','ISEpoch')

% Align Theta/Delta to Gamma
SmoothTheta    = Restrict(SmoothTheta   , SmoothGamma);
SmoothDelta_OB = Restrict(SmoothDelta_OB, SmoothGamma);

% Arrays (logGamma, Theta linear, logDelta)
g2 = Data(SmoothGamma);
t2 = Data(SmoothTheta);
d2 = Data(SmoothDelta_OB);
ok2 = g2>0 & d2>0 & ~isnan(t2);
g2 = log10(g2(ok2));
t2 = t2(ok2);
d2 = log10(d2(ok2));

% Sleep-only (Theta–Delta space)
Sleep2 = [];
try
    Sleep2 = union(union(SWSEpoch, ISEpoch), REMEpoch);
catch
    if exist('Sleep','var'); Sleep2 = Sleep; end
end
if isempty(Sleep2)
    t2_sleep = t2;
    d2_sleep = d2;
else
    t2_sleep = Data(Restrict(SmoothTheta,    Sleep2));
    d2_sleep = Data(Restrict(Restrict(SmoothDelta_OB, SmoothTheta) , Sleep2));
    ok = ~isnan(t2_sleep) & ~isnan(d2_sleep);
    t2_sleep = t2_sleep(ok);
    d2_sleep = log10(d2_sleep(ok));  % ensure log for delta
end

%% ---------------- Subsample 500 evenly spaced points ----------------
% Space A (logGamma–Theta): all epochs
if numel(g1) > nKeep, idx1 = round(linspace(1, numel(g1), nKeep)); else, idx1 = 1:numel(g1); end
if numel(g2) > nKeep, idx2 = round(linspace(1, numel(g2), nKeep)); else, idx2 = 1:numel(g2); end
g1s = g1(idx1); t1s = t1(idx1);
g2s = g2(idx2); t2s = t2(idx2);

% Space B (Theta–logDelta): sleep-only
if numel(t1_sleep) > nKeep, i1 = round(linspace(1, numel(t1_sleep), nKeep)); else, i1 = 1:numel(t1_sleep); end
if numel(t2_sleep) > nKeep, i2 = round(linspace(1, numel(t2_sleep), nKeep)); else, i2 = 1:numel(t2_sleep); end
t1s_sl = t1_sleep(i1); d1s_sl = d1_sleep(i1);
t2s_sl = t2_sleep(i2); d2s_sl = d2_sleep(i2);

%% ---------------- Pairwise distance distributions ----------------
% Space A: logGamma–Theta
D1_GT = pdist([g1s, t1s]);   % session 1
D2_GT = pdist([g2s, t2s]);   % session 2

figure('Color','w'); hold on
histogram(D1_GT, 100, 'Normalization','pdf', 'FaceColor',[.4 .7 1], 'FaceAlpha',0.5, 'EdgeColor','none', 'BinLimits',[0 8])
histogram(D2_GT, 100, 'Normalization','pdf', 'FaceColor',[1 .7 .4], 'FaceAlpha',0.5, 'EdgeColor','none', 'BinLimits',[0 8])
xlabel('Euclidean distance (Gamma/Theta space)')
ylabel('PDF')
legend({'Head fixed','Freely moving'})
box off; grid on

% Space B: Theta–logDelta (sleep-only)
D1_TD = pdist([t1s_sl, d1s_sl]);   % session 1
D2_TD = pdist([t2s_sl, d2s_sl]);   % session 2

figure('Color','w'); hold on
histogram(D1_TD, 100, 'Normalization','pdf', 'FaceColor',[.4 .7 1], 'FaceAlpha',0.5, 'EdgeColor','none')
histogram(D2_TD, 100, 'Normalization','pdf', 'FaceColor',[1 .7 .4], 'FaceAlpha',0.5, 'EdgeColor','none')
xlabel('Euclidean distance (Theta/Delta space)')
ylabel('PDF')
legend({'Head fixed','Freely moving'})
box off; grid on

%% ---------------- Mean successive-step “change” in Theta–logDelta (sleep-only) ----------------
% Compute consecutive-step distances along the (evenly spaced) sequences
S1_steps = sqrt( diff(t1s_sl).^2 + diff(d1s_sl).^2 );
S2_steps = sqrt( diff(t2s_sl).^2 + diff(d2s_sl).^2 );

m1 = mean(S1_steps, 'omitnan'); s1 = std(S1_steps, 'omitnan');
m2 = mean(S2_steps, 'omitnan'); s2 = std(S2_steps, 'omitnan');


