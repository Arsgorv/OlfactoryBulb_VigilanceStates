function [REMEpoch, SWS, IS, Wake , Sleep] = cleanSleepStates_BM(REMEpoch, SWS, IS, Wake, TotEpoch)
% Clean sleep states with the rules:
% 1) Process REM then SWS:
%    - merge close bouts (<60 s)
%    - remove overlap with Wake
%    - drop short bouts (<20 s)
%    - leave no overlap with already-processed states
% 2) Fill any leftover time into IS.
% 3) If Sleep (REM/SWS/IS) is between two Wakes and <5 s, reclassify that Sleep as Wake.
% 4) Final cleanup + exclusivity (Wake > REM > SWS > IS) and full coverage of TotEpoch.

%% Parameters (times are in 1e-4 s units as per your convention)
thr_bridge   = 60 * 1e4;   % merge <60 s gaps
thr_short    = 20 * 1e4;   % drop bouts <20 s
thr_betweenW =  5 * 1e4;   % reclassify Sleep <5 s between two Wakes

%% -------- Step 1: REM --------
% Merge close REM
REMEpoch = mergeCloseIntervals(REMEpoch, thr_bridge);

% Remove overlap with Wake (Wake dominates)
REMEpoch = REMEpoch - Wake;

% Drop short REM
REMEpoch = dropShortIntervals(REMEpoch, thr_short);

% Ensure no overlap of IS/SWS with REM
IS = IS - REMEpoch;
SWS = SWS - REMEpoch;

%% -------- Step 2: SWS --------
% Merge close SWS
SWS = mergeCloseIntervals(SWS, thr_bridge);

% Remove overlap with Wake and with REM
SWS = SWS - Wake;
SWS = SWS - REMEpoch;

% Drop short SWS
SWS = dropShortIntervals(SWS, thr_short);

% Make sure IS doesn't overlap with REM/SWS/Wake before filling
IS = IS - Wake;
IS = IS - REMEpoch;
IS = IS - SWS;

% Fill leftover time into IS (so the session is covered by some state)
covered = or(Wake, or(REMEpoch, SWS));
Epoch_left = TotEpoch - or(covered, IS);
IS = or(IS, Epoch_left);

%% -------- Step 3: Reclassify short Sleep between two Wakes (<5 s) --------
Sleep = or(REMEpoch, or(SWS, IS));

% Transitions between Wake and Sleep
[aft_cell, bef_cell] = transEpoch(Wake, Sleep);
sleepAfterWake  = aft_cell{1,2};  % Sleep right after Wake
sleepBeforeWake = bef_cell{1,2};  % Sleep right before Wake

% Sleep framed by Wake on both sides
sleepBetween = intersect(sleepAfterWake, sleepBeforeWake);

% Keep short ones only
shortSleepBetween = subset(sleepBetween, DurationEpoch(sleepBetween) < thr_betweenW);

% Reclassify these short sleep bouts as Wake
Wake     = or(Wake, shortSleepBetween);
REMEpoch = REMEpoch - shortSleepBetween;
SWS       = SWS       - shortSleepBetween;
IS       = IS       - shortSleepBetween;

%% -------- Step 4: Final cleanup, exclusivity, full coverage --------
% Enforce exclusivity with priority: Wake > REM > SWS > IS
REMEpoch = REMEpoch - Wake;
SWS       = SWS       - or(Wake, REMEpoch);
IS       = IS       - or(Wake, or(REMEpoch, SWS));

% Ensure the entire TotEpoch is covered (assign any remaining to IS)
covered = or(Wake, or(REMEpoch, or(SWS, IS)));
Epoch_left = TotEpoch - covered;
IS = or(IS, Epoch_left);

% Clean small junction artifacts
REMEpoch = CleanUpEpoch(REMEpoch);
SWS       = CleanUpEpoch(SWS);
IS       = CleanUpEpoch(IS);
Wake     = CleanUpEpoch(Wake);
Sleep = or(REMEpoch, or(SWS, IS));

end
