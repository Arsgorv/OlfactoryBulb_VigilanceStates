function behavResources = CorrectTimeBackToEphys(behavResources, TTLInfo_sess)

% This function performs syncronization of all time-dependent variables
% with OpenEphys ephy recordings
% 
% By Dima Bryzgalov, MOBS team, Paris, France
% 12/06/2020
% github.com/bryzgalovdm
% github.com/MobsLab

behavResources.PosMat(:,1) = behavResources.PosMat(:,1) - 1 + TTLInfo_sess.StartSession/1e4;
behavResources.PosMatInit(:,1) = behavResources.PosMatInit(:,1) - 1 + TTLInfo_sess.StartSession/1e4;
behavResources.im_diff(:,1) = behavResources.im_diff(:,1) - 1 + TTLInfo_sess.StartSession/1e4;
behavResources.im_diffInit(:,1) = behavResources.im_diffInit(:,1) - 1 + TTLInfo_sess.StartSession/1e4;
tt = Range(behavResources.Imdifftsd) - 1e4 + TTLInfo_sess.StartSession;
behavResources.Imdifftsd = tsd(tt, Data(behavResources.Imdifftsd)); clear tt
tt = Range(behavResources.Xtsd) - 1e4 + TTLInfo_sess.StartSession;
behavResources.Xtsd = tsd(tt, Data(behavResources.Xtsd)); clear tt
tt = Range(behavResources.Ytsd) - 1e4 + TTLInfo_sess.StartSession;
behavResources.Ytsd = tsd(tt, Data(behavResources.Ytsd)); clear tt
tt = Range(behavResources.Vtsd) - 1e4 + TTLInfo_sess.StartSession;
behavResources.Vtsd = tsd(tt, Data(behavResources.Vtsd)); clear tt
if isfield(behavResources, 'ZoneEpoch')
    for izone = 1:length(behavResources.ZoneEpoch)
        st = Start(behavResources.ZoneEpoch{izone}) - 1e4 + TTLInfo_sess.StartSession;
        en = End(behavResources.ZoneEpoch{izone}) - 1e4 + TTLInfo_sess.StartSession;
        behavResources.ZoneEpoch{izone} = intervalSet(st,en); clear st en
    end
end

if isfield(behavResources, 'MouseTemp')
    behavResources.MouseTemp(:,1) = behavResources.MouseTemp(:,1) - 1 + TTLInfo_sess.StartSession/1e4;
end
if isfield(behavResources, 'CleanPosMat')
    behavResources.CleanPosMat(:,1) = behavResources.CleanPosMat(:,1) - 1 +TTLInfo_sess.StartSession/1e4;
end
if isfield(behavResources, 'CleanXtsd')
    tt = Range(behavResources.CleanXtsd) - 1e4 + TTLInfo_sess.StartSession;
    behavResources.CleanXtsd = tsd(tt, Data(behavResources.CleanXtsd)); clear tt
end
if isfield(behavResources, 'CleanYtsd')
    tt = Range(behavResources.CleanYtsd) - 1e4 + TTLInfo_sess.StartSession;
    behavResources.CleanYtsd = tsd(tt, Data(behavResources.CleanYtsd)); clear tt
end
if isfield(behavResources, 'CleanVtsd')
    tt = Range(behavResources.CleanVtsd) - 1e4 + TTLInfo_sess.StartSession;
    behavResources.CleanVtsd = tsd(tt, Data(behavResources.CleanVtsd)); clear tt
end
if isfield(behavResources, 'CleanAlignedXtsd')
    tt = Range(behavResources.CleanAlignedXtsd) - 1e4 + TTLInfo_sess.StartSession;
    behavResources.CleanAlignedXtsd = tsd(tt, Data(behavResources.CleanAlignedXtsd)); clear tt
end
if isfield(behavResources, 'CleanAlignedYtsd')
    tt = Range(behavResources.CleanAlignedYtsd) - 1e4 + TTLInfo_sess.StartSession;
    behavResources.CleanAlignedYtsd = tsd(tt, Data(behavResources.CleanAlignedYtsd)); clear tt
end
if isfield(behavResources, 'AlignedXtsd')
    tt = Range(behavResources.AlignedXtsd) - 1e4 + TTLInfo_sess.StartSession;
    behavResources.AlignedXtsd = tsd(tt, Data(behavResources.AlignedXtsd)); clear tt
end
if isfield(behavResources, 'AlignedYtsd')
    tt = Range(behavResources.AlignedYtsd) - 1e4 + TTLInfo_sess.StartSession;
    behavResources.AlignedYtsd = tsd(tt, Data(behavResources.AlignedYtsd)); clear tt
end
if isfield(behavResources, 'LinearDist')
    tt = Range(behavResources.LinearDist) - 1e4 + TTLInfo_sess.StartSession;
    behavResources.LinearDist = tsd(tt, Data(behavResources.LinearDist)); clear tt
end
if isfield(behavResources, 'CleanLinearDist')
    tt = Range(behavResources.CleanLinearDist) - 1e4 + TTLInfo_sess.StartSession;
    behavResources.CleanLinearDist = tsd(tt, Data(behavResources.CleanLinearDist)); clear tt
end
if isfield(behavResources, 'CleanZoneEpoch')
    for izone = 1:length(behavResources.CleanZoneEpoch)
        st = Start(behavResources.CleanZoneEpoch{izone}) - 1e4 + TTLInfo_sess.StartSession;
        en = End(behavResources.CleanZoneEpoch{izone}) - 1e4 + TTLInfo_sess.StartSession;
        behavResources.CleanZoneEpoch{izone} = intervalSet(st,en); clear st en
    end
end
if isfield(behavResources, 'ZoneEpochAligned')
    for izone = 1:length(behavResources.ZoneEpochAligned)
        st = Start(behavResources.ZoneEpochAligned{izone}) - 1e4 + TTLInfo_sess.StartSession;
        en = End(behavResources.ZoneEpochAligned{izone}) - 1e4 + TTLInfo_sess.StartSession;
        behavResources.ZoneEpochAligned{izone} = intervalSet(st,en); clear st en
    end
end

end