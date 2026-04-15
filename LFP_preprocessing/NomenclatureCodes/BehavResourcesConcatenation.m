function BehavResourcesConcatenation (FilesList, FolderSessionName, tpsCatEvt, pathtosave, varargin)

%%%% TestBehavResourcesConcatenation
% Concatenate behavResources for any number of sessions
% Written for PreProcessingConcatenation pipeline (author - Sophie Bagur)
% By Dima Bryzgalov december 2018
%
% This code concatenates all possible behavResources.mat into one structure
% with the length that is equal to number of concatenated sessions (behavResources)
% !!! Time is unified and united in this structure !!!
%
% Also, it creates concatenated variables were the whole day of experiment
% is concatenated. You can restrict your data to specifically created
% epochs with the name <'SessionEpoch.SessionName'>
%
% Please find description of all variables inside the code
%
%  USAGE
%
%    BehavResourcesConcatenation (FilesList, FolderSessionName, pathtosave, tpsCatEvt, nameCatEvt)
%
%    FilesList              a cell with paths to behavResources file
%    FolderSessionName      a cell with names of sessions (same order as in FilesList)
%    tpsCatEvt              time of beginning and end of each session
%    pathtosave             Path to save behavioral resources
%
%
%%
%%%%%%%%%%%%%%%%%%%%%%%% -----------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Optional arguments
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property (type ''help <a href="matlab:help FindRipples">FindRipples</a>'' for details).']);
    end
    switch(lower(varargin{i}))
        case 'startinfo'
            TTLInfo_sess = varargin{i+1};
            if ~iscell(TTLInfo_sess) && length(FilesList)~=length(TTLInfo_sess)
                error('Incorrect value for property ''StartInfo'' - should be a cell with TTLInfo for each session');
            end
        case 'intanrecorded'
            IntanRecorded = varargin{i+1};
            if ~iscell(IntanRecorded) && length(FilesList)~=length(TTLInfo_sess)
                error('Incorrect value for property ''IntanRecorded'' - should be a cell with info for each session');
            end
    end
end

%% Load data
for i = 1:length(FilesList)
    a{i} = load(FilesList{i});
end

%% check forma
if pathtosave(end)~=filesep
    pathtosave(end+1) = filesep;
end


%% Start creating the structure - names of sessions
for i=1:length(FilesList)
    behavResources(i).SessionName = FolderSessionName{i};
end

%% Correct back the time for Open Ephys
% Timestamps in matlab-generated behavioral files come shifted 1 sec in the future.
% This was done to account for the peculiarity of Intan software -
% It records in the file data that start 1 sec before launching TTL came and
% 1 sec after the stopping TTL arrived. To correct 1 sec mismatch between ephy
% and behavioral data we simply add 1 sec to all times recorded in Matlab.
% However, in OpenEphys this buffer does not exist. So we had to take this 1 sec back.
%
% We take it only from the first file because the rest is corrected by actual
% length of ephy files

if exist('TTLInfo_sess', 'var') && exist('IntanRecorded', 'var')
    for isess = 1:length(FilesList)
        if ~IntanRecorded{isess}
            a{isess} = CorrectTimeBackToEphys(a{isess}, TTLInfo_sess{isess});
        end
    end
else
    warning('Intan only concatentenation. If you''ve recorded OpenEphys - stop and redo');
end

%% Add constants in the structure - note that they could be different for different sessions

for i=1:length(FilesList)
    
    % Set of things you must have in each file
    behavResources(i).ref = a{i}.ref; % reference image
    behavResources(i).mask = a{i}.mask; % mask polygon
    behavResources(i).Ratio_IMAonREAL = a{i}.Ratio_IMAonREAL; % pixel/cm ratio
    behavResources(i).BW_threshold = a{i}.BW_threshold; % threshold of mouse detection in tracking
    behavResources(i).smaller_object_size = a{i}.smaller_object_size; % threshold of mouse size during tracking
    behavResources(i).sm_fact = a{i}.sm_fact; % smoothing factor for tracking
    behavResources(i).strsz = a{i}.strsz; % factor to smooth edges
    behavResources(i).SrdZone = a{i}.SrdZone; % Size of the zone where tracking looks for freezing
    
    % Set of non-obligatory variables
    if isfield(a{i}, 'th_immob')
        behavResources(i).th_immob = a{i}.th_immob; % Tracking threshold of immobility
    else
        behavResources(i).th_immob = []; % Tracking threshold of immobility
    end
    
    if isfield(a{i}, 'thtps_immob')
        behavResources(i).thtps_immob = a{i}.thtps_immob; % Tracking threshold of immobility on time
    else
        behavResources(i).thtps_immob = []; % Tracking threshold of immobility on time
    end
    
    if isfield(a{i}, 'frame_limits')
        behavResources(i).frame_limits = a{i}.frame_limits; % ColorAxis limits
    else
        behavResources(i).frame_limits = []; % ColorAxis limits
    end
    
    if isfield(a{i}, 'Zone')
        behavResources(i).Zone = a{i}.Zone; % Shapes of Zones
    else
        behavResources(i).Zone = [];
    end
    
    if isfield(a{i}, 'ZoneLabels')
        behavResources(i).ZoneLabels = a{i}.ZoneLabels; % Names of Zones
    else
        behavResources(i).ZoneLabels = [];
    end
    
    if isfield(a{i}, 'delStim')
        behavResources(i).delStim = a{i}.delStim; % InterStimulus interval
    else
        behavResources(i).delStim = [];
    end
    
    if isfield(a{i}, 'delStimreturn')
        behavResources(i).delStimreturn = a{i}.delStimreturn; % First entry stimulation latency
    else
        behavResources(i).delStimreturn = [];
    end
    
    if isfield(a{i}, 'DiodMask')
        behavResources(i).DiodMask = a{i}.DiodMask; % NosePoke Tracking: mask for the synchronizing diod
    else
        behavResources(i).DiodMask = [];
    end
    
    if isfield(a{i}, 'DiodThresh')
        behavResources(i).DiodThresh = a{i}.DiodThresh; % NosePoke Tracking: threshold for the synchronizing diod flashing
    else
        behavResources(i).DiodThresh = [];
    end
    
    if isfield(a{i}, 'CleanMaskBounary')
        behavResources(i).CleanMaskBounary = a{i}.CleanMaskBounary;
    else
        behavResources(i).CleanMaskBounary = [];
    end
    
    if isfield(a{i}, 'ZoneEpochAligned')
        behavResources(i).ZoneEpochAligned = a{i}.ZoneEpochAligned;
    else
        behavResources(i).ZoneEpochAligned = [];
    end
    
    if isfield(a{i}, 'LinearDist')
        behavResources(i).LinearDist = a{i}.LinearDist;
    else
        behavResources(i).LinearDist = [];
    end
end

%% Calculate duration, find the first timestamp ('offset') and number of indices for each test
% find also last timestaps for each session ('lasttime')

for i = 1:length(FilesList)
    TimeTemp{i} = Range(a{i}.Xtsd);
    offset(i) = TimeTemp{i}(1);
    lind(i) = length(TimeTemp{i});
    lasttimeBeh(i) = TimeTemp{i}(end);
    ThousandFrames{i} = ts(TimeTemp{i}(1:1000:end));
end
clear TimeTemp

beg_end = cell2mat(tpsCatEvt);
st = beg_end(1:2:end);
en = beg_end(2:2:end);

duration = nan(length(st),1);
lasttime = nan(length(st),1);
for i=1:length(st)
    duration(i) = en(i)-st(i);
    lasttime(i) = en(i);
end

%% Check for time inconsistencies
for i=1:length(FilesList)
    ImdifftsdTimeTemp{i} = Range(a{i}.Imdifftsd);
end
for i=1:(length(FilesList)-1)
    ImdifftsdTimeTemp{i+1} = ImdifftsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
end
ImdifftsdTime = ImdifftsdTimeTemp{1};
for i = 2:length(FilesList)
    ImdifftsdTime = [ImdifftsdTime; ImdifftsdTimeTemp{i}];
end

if ~isempty(find(diff(ImdifftsdTime)<0, 1))
    disp('MANUAL MODE !!! - Time problem')
    keyboard;  % to resume process type dbcont
end

clear ImdifftsdTimeTemp ImdifftsdTime

%% Concatenate time-dependent variables

% Concatenate PosMat (type - array)
for i=1:length(FilesList)
    PosMatTemp{i} = a{i}.PosMat; % First column - time in sec, second column - X, third column - Y, fourth column - events
end
for i=1:(length(FilesList)-1)
    PosMatTemp{i+1}(:,1) = PosMatTemp{i+1}(:,1) + (sum(duration(1:i)));
end
for i = 1:length(FilesList)
    behavResources(i).PosMat = PosMatTemp{i};
end
clear PosMatTemp

% Concatenate PosMatInit (type - array)
for i=1:length(FilesList)
    PosMatInitTemp{i} = a{i}.PosMatInit; % Raw PosMat, it is interpolated to PosMat (where periods where mouse was lost are interpolated)
end
for i=1:(length(FilesList)-1)
    PosMatInitTemp{i+1}(:,1) = PosMatInitTemp{i+1}(:,1) + (sum(duration(1:i)));
end
for i = 1:length(FilesList)
    behavResources(i).PosMatInit = PosMatInitTemp{i};
end
clear PosMatInitTemp

% Concatenate im_diff (type - array)
for i=1:length(FilesList) % First column - time in sec, second column - difference in pixels between mask and a frame,...
    % third column - number of pixels used for subtraction
    im_diffTemp{i} = a{i}.im_diff;
end
for i=1:(length(FilesList)-1)
    im_diffTemp{i+1}(:,1) = im_diffTemp{i+1}(:,1) + (sum(duration(1:i)));
end
for i = 1:length(FilesList)
    behavResources(i).im_diff = im_diffTemp{i};
end
clear im_diffTemp

% Concatenate im_diffInit (type - array)
for i=1:length(FilesList) % Raw im_Diff, it is interpolated to im_Diff (where periods where mouse was lost are interpolated)
    im_diffInitTemp{i} = a{i}.im_diffInit;
end
for i=1:(length(FilesList)-1)
    im_diffInitTemp{i+1}(:,1) = im_diffInitTemp{i+1}(:,1) + (sum(duration(1:i)));
end
for i = 1:length(FilesList)
    behavResources(i).im_diffInit = im_diffInitTemp{i};
end
clear im_diffInitTemp

% Concatenate Imdifftsd (type single tsd)
for i=1:length(FilesList) % Tsd, with differences in pixels between mask and a frame in Data
    ImdifftsdTimeTemp{i} = Range(a{i}.Imdifftsd);
    ImdifftsdDataTemp{i} = Data(a{i}.Imdifftsd);
end
for i=1:(length(FilesList)-1)
    ImdifftsdTimeTemp{i+1} = ImdifftsdTimeTemp{i+1};
end
for i = 1:length(FilesList)
    behavResources(i).Imdifftsd = tsd(ImdifftsdTimeTemp{i}, ImdifftsdDataTemp{i});
end
clear ImdifftsdTimeTemp ImdifftsdDataTemp

% Concatenate Xtsd (type single tsd)
for i=1:length(FilesList) % tsd of X coordinates
    XtsdTimeTemp{i} = Range(a{i}.Xtsd);
    XtsdDataTemp{i} = Data(a{i}.Xtsd);
end
for i=1:(length(FilesList)-1)
    XtsdTimeTemp{i+1} = XtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
end
for i = 1:length(FilesList)
    behavResources(i).Xtsd = tsd(XtsdTimeTemp{i}, XtsdDataTemp{i});
end
clear XtsdTimeTemp XtsdDataTemp

% Concatenate Ytsd (type single tsd)
for i=1:length(FilesList) % tsd of Y coordinates
    YtsdTimeTemp{i} = Range(a{i}.Ytsd);
    YtsdDataTemp{i} = Data(a{i}.Ytsd);
end
for i=1:(length(FilesList)-1)
    YtsdTimeTemp{i+1} = YtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
end
for i = 1:length(FilesList)
    behavResources(i).Ytsd = tsd(YtsdTimeTemp{i}, YtsdDataTemp{i});
end
clear YtsdTimeTemp YtsdDataTemp

% Concatenate Vtsd (type single tsd) - describe, plz, what's the trick!!!!
for i=1:length(FilesList) % tsd of instantaneous speed
    if i==length(FilesList)
        VtsdTimeTemp{i} = Range(a{i}.Vtsd);
        VtsdDataTemp{i} = Data(a{i}.Vtsd);
    else
        VtsdTimeTemp{i} = [Range(a{i}.Vtsd); lasttimeBeh(i)];
        VtsdDataTemp{i} = [Data(a{i}.Vtsd); -1];
    end
end
for i=1:(length(FilesList)-1)
    VtsdTimeTemp{i+1} = VtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
end
for i = 1:length(FilesList)
    behavResources(i).Vtsd = tsd(VtsdTimeTemp{i}, VtsdDataTemp{i});
end
clear VtsdTimeTemp VtsdDataTemp

%%%%% NON-OBLIGATORY

% Concatenate GotFrame (type - array)
for i=1:length(FilesList) % Array of 0 and 1 - whether this frame is recorded to the video or not
    if isfield(a{i}, 'GotFrame')
        GotFrameTemp{i} = a{i}.GotFrame;
    else
        GotFrameTemp{i} = [];
    end
end
for i = 1:length(FilesList)
    behavResources(i).GotFrame = GotFrameTemp{i};
end
clear GotFrameTemp

% Concatenate ZoneIndices (type array of indices * N - number of Zones)
for i=1:length(FilesList) % Time indices of the occasions when the animal was in the Zone
    if isfield(a{i}, 'ZoneIndices')
        for k = 1:length(a{i}.ZoneIndices)
            ZoneIndicesTemp{i}{k} = a{i}.ZoneIndices{k};
        end
    else
        ZoneIndicesTemp{i} = [];
    end
end
for i=1:length(FilesList)
    if ~isempty(ZoneIndicesTemp{i})
        for k = 1:length(ZoneIndicesTemp{i})
            behavResources(i).ZoneIndices{k} = ZoneIndicesTemp{i}{k};
        end
    else
        behavResources(i).ZoneIndices = ZoneIndicesTemp{i};
    end
end
clear ZoneIndicesTemp


% Concatenate MouseTemp (type - array)
for i=1:length(FilesList) % First column - time in sec, Second column - mouse temp in a.u. (could be converted to degrees)
    if isfield(a{i}, 'MouseTemp')
        MouseTempTemp{i} = a{i}.MouseTemp;
    else
        MouseTempTemp{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(MouseTempTemp{i+1})
        MouseTempTemp{i+1}(:,1) = MouseTempTemp{i+1}(:,1) + (sum(duration(1:i)));
    else
        MouseTempTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    behavResources(i).MouseTemp = MouseTempTemp{i};
end
clear MouseTempTemp

% Concatenate Freezeepoch (type single tsa)
for i=1:length(FilesList) % Epochs when the animal was Freezing
    if isfield(a{i}, 'FreezeEpoch')
        FreezeEpochTempStart{i} = Start(a{i}.FreezeEpoch);
        FreezeEpochTempEnd{i} = End(a{i}.FreezeEpoch);
    else
        FreezeEpochTempStart{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty (FreezeEpochTempStart{i+1})
        FreezeEpochTempStart{i+1} = FreezeEpochTempStart{i+1}+sum(duration(1:i))*1e4;
        FreezeEpochTempEnd{i+1} = FreezeEpochTempEnd{i+1} +sum(duration(1:i))*1e4;
    end
end
for i=1:length(FilesList)
    if ~isempty (FreezeEpochTempStart{i})
        behavResources(i).FreezeEpoch = intervalSet(FreezeEpochTempStart{i}, FreezeEpochTempEnd{i});
    else
        behavResources(i).FreezeEpoch = [];
    end
end
clear FreezeEpochTempStart FreezeEpochTempEnd FreezeEpochStart FreezeEpochEnd

% Concatenate ZoneEpoch (type single tsa)
for i=1:length(FilesList) % Epochs when the animals was situated in the Zone
    if isfield(a{i}, 'ZoneEpoch')
        for k = 1:length(a{i}.ZoneEpoch)
            ZoneEpochTempStart{i}{k} = Start(a{i}.ZoneEpoch{k});
            ZoneEpochTempEnd{i}{k} = End(a{i}.ZoneEpoch{k});
        end
    else
        ZoneEpochTempStart{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty (ZoneEpochTempStart{i+1})
        for k = 1:length(ZoneEpochTempStart{i+1})
            ZoneEpochTempStart{i+1}{k} = ZoneEpochTempStart{i+1}{k} +sum(duration(1:i))*1e4;
            ZoneEpochTempEnd{i+1}{k} = ZoneEpochTempEnd{i+1}{k} +sum(duration(1:i))*1e4;
        end
    end
end
for i=1:length(FilesList)
    if ~isempty (ZoneEpochTempStart{i})
        for k = 1:length(a{i}.ZoneEpoch)
            behavResources(i).ZoneEpoch{k} = intervalSet(ZoneEpochTempStart{i}{k}, ZoneEpochTempEnd{i}{k});
        end
    else
        behavResources(i).ZoneEpoch = [];
    end
end
clear ZoneEpochTempStart ZoneEpochTempEnd ZoneEpochStart ZoneEpochEnd

% Concatenate CleanPosMat (type - array)
for i=1:length(FilesList)
    if isfield(a{i},'CleanPosMat')
        CleanPosMatTemp{i} = a{i}.CleanPosMat; % First column - time in sec, second column - X, third column - Y, fourth column - events
    else
        CleanPosMatTemp{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(CleanPosMatTemp{i+1})
        CleanPosMatTemp{i+1}(:,1) = CleanPosMatTemp{i+1}(:,1) + (sum(duration(1:i)));
    else
        CleanPosMatTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    if ~isempty(CleanPosMatTemp{i})
        behavResources(i).CleanPosMat = CleanPosMatTemp{i};
    else
        behavResources(i).CleanPosMat = [];
    end
end
clear CleanPosMatTemp

% Concatenate CleanPosMatInit (type - array)
for i=1:length(FilesList)
    if isfield(a{i},'CleanPosMatInit')
        CleanPosMatInitTemp{i} = a{i}.CleanPosMatInit; % First column - time in sec, second column - X, third column - Y, fourth column - events
    else
        CleanPosMatInitTemp{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(CleanPosMatInitTemp{i+1})
        CleanPosMatInitTemp{i+1}(:,1) = CleanPosMatInitTemp{i+1}(:,1) + (sum(duration(1:i)));
    else
        CleanPosMatInitTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    if ~isempty(CleanPosMatInitTemp{i})
        behavResources(i).CleanPosMatInit = CleanPosMatInitTemp{i};
    else
        behavResources(i).CleanPosMatInit = [];
    end
end
clear CleanPosMatInitTemp

% CleanXtsd
for i=1:length(FilesList) % tsd of X coordinates
    if isfield(a{i},'CleanXtsd')
        XtsdTimeTemp{i} = Range(a{i}.CleanXtsd);
        XtsdDataTemp{i} = Data(a{i}.CleanXtsd);
    else
        XtsdTimeTemp{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(XtsdTimeTemp{i+1})
        XtsdTimeTemp{i+1} = XtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    else
        XtsdTimeTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    if ~isempty(XtsdTimeTemp{i})
        behavResources(i).CleanXtsd = tsd(XtsdTimeTemp{i}, XtsdDataTemp{i});
    else
        behavResources(i).CleanXtsd = [];
    end
end
clear XtsdTimeTemp XtsdDataTemp

% CleanYtsd
for i=1:length(FilesList) % tsd of Y coordinates
    if isfield(a{i},'CleanYtsd')
        YtsdTimeTemp{i} = Range(a{i}.CleanYtsd);
        YtsdDataTemp{i} = Data(a{i}.CleanYtsd);
    else
        YtsdTimeTemp{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(YtsdTimeTemp{i+1})
        YtsdTimeTemp{i+1} = YtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    else
        YtsdTimeTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    if ~isempty(YtsdTimeTemp{i})
        behavResources(i).CleanYtsd = tsd(YtsdTimeTemp{i}, YtsdDataTemp{i});
    else
        behavResources(i).CleanYtsd = [];
    end
end
clear YtsdTimeTemp YtsdDataTemp

% Concatenate CleanVtsd (type single tsd) - describe, plz, what's the trick!!!!
for i=1:length(FilesList) % tsd of instantaneous speed
    if i==length(FilesList)
        if isfield(a{i},'CleanVtsd')
            VtsdTimeTemp{i} = Range(a{i}.CleanVtsd);
            VtsdDataTemp{i} = Data(a{i}.CleanVtsd);
        else
            VtsdDataTemp{i} = [];
        end
    else
        if isfield(a{i},'CleanVtsd')
            VtsdTimeTemp{i} = [Range(a{i}.CleanVtsd); lasttimeBeh(i)];
            VtsdDataTemp{i} = [Data(a{i}.CleanVtsd); -1];
        else
            VtsdDataTemp{i} = [];
        end
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(VtsdDataTemp{i+1})
        VtsdTimeTemp{i+1} = VtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    else
        VtsdTimeTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    if ~isempty(VtsdTimeTemp{i})
        behavResources(i).CleanVtsd = tsd(VtsdTimeTemp{i}, VtsdDataTemp{i});
    else
        behavResources(i).CleanVtsd = [];
    end
end
clear VtsdTimeTemp VtsdDataTemp

% Concatenate CleanZoneIndices (type array of indices * N - number of Zones)
for i=1:length(FilesList) % Time indices of the occasions when the animal was in the Zone
    if isfield(a{i}, 'CleanZoneIndices')
        for k = 1:length(a{i}.CleanZoneIndices)
            ZoneIndicesTemp{i}{k} = a{i}.CleanZoneIndices{k};
        end
    else
        ZoneIndicesTemp{i} = [];
    end
end
for i=1:length(FilesList)
    if ~isempty(ZoneIndicesTemp{i})
        for k = 1:length(ZoneIndicesTemp{i})
            behavResources(i).CleanZoneIndices{k} = ZoneIndicesTemp{i}{k};
        end
    else
        behavResources(i).CleanZoneIndices = ZoneIndicesTemp{i};
    end
end
clear ZoneIndicesTemp

% Concatenate CleanZoneEpoch (type single tsa)
for i=1:length(FilesList) % Epochs when the animals was situated in the Zone
    if isfield(a{i}, 'CleanZoneEpoch')
        for k = 1:length(a{i}.CleanZoneEpoch)
            ZoneEpochTempStart{i}{k} = Start(a{i}.CleanZoneEpoch{k});
            ZoneEpochTempEnd{i}{k} = End(a{i}.CleanZoneEpoch{k});
        end
    else
        ZoneEpochTempStart{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty (ZoneEpochTempStart{i+1})
        for k = 1:length(ZoneEpochTempStart{i+1})
            ZoneEpochTempStart{i+1}{k} = ZoneEpochTempStart{i+1}{k} +sum(duration(1:i))*1e4;
            ZoneEpochTempEnd{i+1}{k} = ZoneEpochTempEnd{i+1}{k} +sum(duration(1:i))*1e4;
        end
    end
end
for i=1:length(FilesList)
    if ~isempty (ZoneEpochTempStart{i})
        for k = 1:length(a{i}.CleanZoneEpoch)
            behavResources(i).CleanZoneEpoch{k} = intervalSet(ZoneEpochTempStart{i}{k}, ZoneEpochTempEnd{i}{k});
        end
    else
        behavResources(i).CleanZoneEpoch = [];
    end
end
clear ZoneEpochTempStart ZoneEpochTempEnd ZoneEpochStart ZoneEpochEnd

% AlignedXtsd
for i=1:length(FilesList) % tsd of X coordinates
    if isfield(a{i},'AlignedXtsd')
        XtsdTimeTemp{i} = Range(a{i}.AlignedXtsd);
        XtsdDataTemp{i} = Data(a{i}.AlignedXtsd);
    else
        XtsdTimeTemp{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(XtsdTimeTemp{i+1})
        XtsdTimeTemp{i+1} = XtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    else
        XtsdTimeTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    if ~isempty(XtsdTimeTemp{i})
        behavResources(i).AlignedXtsd = tsd(XtsdTimeTemp{i}, XtsdDataTemp{i});
    else
        behavResources(i).AlignedXtsd = [];
    end
end
clear XtsdTimeTemp XtsdDataTemp

% AlignedYtsd
for i=1:length(FilesList) % tsd of Y coordinates
    if isfield(a{i},'AlignedYtsd')
        YtsdTimeTemp{i} = Range(a{i}.AlignedYtsd);
        YtsdDataTemp{i} = Data(a{i}.AlignedYtsd);
    else
        YtsdTimeTemp{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(YtsdTimeTemp{i+1})
        YtsdTimeTemp{i+1} = YtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    else
        YtsdTimeTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    if ~isempty(YtsdTimeTemp{i})
        behavResources(i).AlignedYtsd = tsd(YtsdTimeTemp{i}, YtsdDataTemp{i});
    else
        behavResources(i).AlignedYtsd = [];
    end
end
clear YtsdTimeTemp YtsdDataTemp

% ZoneEpochAligned
for i=1:length(FilesList) % Epochs when the animals was situated in the Zone
    if isfield(a{i}, 'ZoneEpochAligned')
        for k = 1:length(a{i}.ZoneEpochAligned)
            ZoneEpochTempStart{i}{k} = Start(a{i}.ZoneEpochAligned{k});
            ZoneEpochTempEnd{i}{k} = End(a{i}.ZoneEpochAligned{k});
        end
    else
        ZoneEpochTempStart{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty (ZoneEpochTempStart{i+1})
        for k = 1:length(ZoneEpochTempStart{i+1})
            ZoneEpochTempStart{i+1}{k} = ZoneEpochTempStart{i+1}{k} +sum(duration(1:i))*1e4;
            ZoneEpochTempEnd{i+1}{k} = ZoneEpochTempEnd{i+1}{k} +sum(duration(1:i))*1e4;
        end
    end
end
for i=1:length(FilesList)
    if ~isempty (ZoneEpochTempStart{i})
        for k = 1:length(a{i}.ZoneEpochAligned)
            behavResources(i).ZoneEpochAligned{k} = intervalSet(ZoneEpochTempStart{i}{k}, ZoneEpochTempEnd{i}{k});
        end
    else
        behavResources(i).ZoneEpochAligned = [];
    end
end
clear ZoneEpochTempStart ZoneEpochTempEnd ZoneEpochStart ZoneEpochEnd

% LinearDist
for i=1:length(FilesList) % tsd of X coordinates
    if isfield(a{i},'LinearDist')
        LinearDistTimeTemp{i} = Range(a{i}.LinearDist);
        LinearDistDataTemp{i} = Data(a{i}.LinearDist);
    else
        LinearDistTimeTemp{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(LinearDistTimeTemp{i+1})
        LinearDistTimeTemp{i+1} = LinearDistTimeTemp{i+1}+sum(duration(1:i))*1e4;
    else
        LinearDistTimeTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    if ~isempty(LinearDistTimeTemp{i})
        behavResources(i).LinearDist = tsd(LinearDistTimeTemp{i}, LinearDistDataTemp{i});
    else
        behavResources(i).LinearDist = [];
    end
end
clear LinearDistTimeTemp LinearDistDataTemp

% CleanAlignedXtsd
for i=1:length(FilesList) % tsd of X coordinates
    if isfield(a{i},'CleanAlignedXtsd')
        XtsdTimeTemp{i} = Range(a{i}.CleanAlignedXtsd);
        XtsdDataTemp{i} = Data(a{i}.CleanAlignedXtsd);
    else
        XtsdTimeTemp{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(XtsdTimeTemp{i+1})
        XtsdTimeTemp{i+1} = XtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    else
        XtsdTimeTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    if ~isempty(XtsdTimeTemp{i})
        behavResources(i).CleanAlignedXtsd = tsd(XtsdTimeTemp{i}, XtsdDataTemp{i});
    else
        behavResources(i).CleanAlignedXtsd = [];
    end
end
clear XtsdTimeTemp XtsdDataTemp

% CleanAlignedYtsd
for i=1:length(FilesList) % tsd of Y coordinates
    if isfield(a{i},'CleanAlignedYtsd')
        YtsdTimeTemp{i} = Range(a{i}.CleanAlignedYtsd);
        YtsdDataTemp{i} = Data(a{i}.CleanAlignedYtsd);
    else
        YtsdTimeTemp{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(YtsdTimeTemp{i+1})
        YtsdTimeTemp{i+1} = YtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    else
        YtsdTimeTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    if ~isempty(YtsdTimeTemp{i})
        behavResources(i).CleanAlignedYtsd = tsd(YtsdTimeTemp{i}, YtsdDataTemp{i});
    else
        behavResources(i).CleanAlignedYtsd = [];
    end
end
clear YtsdTimeTemp YtsdDataTemp

% CleanZoneEpochAligned
for i=1:length(FilesList) % Epochs when the animals was situated in the Zone
    if isfield(a{i}, 'CleanZoneEpochAligned')
        for k = 1:length(a{i}.CleanZoneEpochAligned)
            ZoneEpochTempStart{i}{k} = Start(a{i}.CleanZoneEpochAligned{k});
            ZoneEpochTempEnd{i}{k} = End(a{i}.CleanZoneEpochAligned{k});
        end
    else
        ZoneEpochTempStart{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty (ZoneEpochTempStart{i+1})
        for k = 1:length(ZoneEpochTempStart{i+1})
            ZoneEpochTempStart{i+1}{k} = ZoneEpochTempStart{i+1}{k} +sum(duration(1:i))*1e4;
            ZoneEpochTempEnd{i+1}{k} = ZoneEpochTempEnd{i+1}{k} +sum(duration(1:i))*1e4;
        end
    end
end
for i=1:length(FilesList)
    if ~isempty (ZoneEpochTempStart{i})
        for k = 1:length(a{i}.CleanZoneEpochAligned)
            behavResources(i).CleanZoneEpochAligned{k} = intervalSet(ZoneEpochTempStart{i}{k}, ZoneEpochTempEnd{i}{k});
        end
    else
        behavResources(i).CleanZoneEpochAligned = [];
    end
end
clear ZoneEpochTempStart ZoneEpochTempEnd ZoneEpochStart ZoneEpochEnd

% CleanLinearDist
for i=1:length(FilesList) % tsd of X coordinates
    if isfield(a{i},'CleanLinearDist')
        LinearDistTimeTemp{i} = Range(a{i}.CleanLinearDist);
        LinearDistDataTemp{i} = Data(a{i}.CleanLinearDist);
    else
        LinearDistTimeTemp{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty(LinearDistTimeTemp{i+1})
        LinearDistTimeTemp{i+1} = LinearDistTimeTemp{i+1}+sum(duration(1:i))*1e4;
    else
        LinearDistTimeTemp{i+1} = [];
    end
end
for i = 1:length(FilesList)
    if ~isempty(LinearDistTimeTemp{i})
        behavResources(i).CleanLinearDist = tsd(LinearDistTimeTemp{i}, LinearDistDataTemp{i});
    else
        behavResources(i).CleanLinearDist = [];
    end
end
clear LinearDistTimeTemp LinearDistDataTemp

%% Concatenated tsd and intervalSet variables

%%% OBLIGATORY
% Concatenate PosMat (type - array)
for i=1:length(FilesList)
    PosMatTemp{i} = a{i}.PosMat;
end
for i=1:(length(FilesList)-1)
    PosMatTemp{i+1}(:,1) = PosMatTemp{i+1}(:,1) + (sum(duration(1:i)));
end
PosMat = PosMatTemp{1};
for i = 2:length(FilesList)
    PosMat = [PosMat; PosMatTemp{i}];
end
TimeInSec = PosMat(:,1);
clear PosMatTemp

% Concatenate PosMatInit (type - array)
for i=1:length(FilesList)
    PosMatInitTemp{i} = a{i}.PosMatInit;
end
for i=1:(length(FilesList)-1)
    PosMatInitTemp{i+1}(:,1) = PosMatInitTemp{i+1}(:,1) + (sum(duration(1:i)));
end
PosMatInit = PosMatInitTemp{1};
for i = 2:length(FilesList)
    PosMatInit = [PosMatInit; PosMatInitTemp{i}];
end
clear PosMatInitTemp

% Concatenate im_diff (type - array)
for i=1:length(FilesList)
    im_diffTemp{i} = a{i}.im_diff;
end
for i=1:(length(FilesList)-1)
    im_diffTemp{i+1}(:,1) = im_diffTemp{i+1}(:,1) + (sum(duration(1:i)));
end
im_diff = im_diffTemp{1};
for i = 2:length(FilesList)
    im_diff = [im_diff; im_diffTemp{i}];
end
clear im_diffTemp

% Concatenate im_diffInit (type - array)
for i=1:length(FilesList)
    im_diffInitTemp{i} = a{i}.im_diffInit;
end
for i=1:(length(FilesList)-1)
    im_diffInitTemp{i+1}(:,1) = im_diffInitTemp{i+1}(:,1) + (sum(duration(1:i)));
end
im_diffInit = im_diffInitTemp{1};
for i = 2:length(FilesList)
    im_diffInit = [im_diffInit; im_diffInitTemp{i}];
end
clear im_diffInitTemp

% Concatenate Imdifftsd (type single tsd)
for i=1:length(FilesList)
    ImdifftsdTimeTemp{i} = Range(a{i}.Imdifftsd);
    ImdifftsdDataTemp{i} = Data(a{i}.Imdifftsd);
end
for i=1:(length(FilesList)-1)
    ImdifftsdTimeTemp{i+1} = ImdifftsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
end
ImdifftsdTime = ImdifftsdTimeTemp{1};
ImdifftsdData = ImdifftsdDataTemp{1};
for i = 2:length(FilesList)
    ImdifftsdTime = [ImdifftsdTime; ImdifftsdTimeTemp{i}];
    ImdifftsdData = [ImdifftsdData; ImdifftsdDataTemp{i}];
end

Imdifftsd = tsd(ImdifftsdTime, ImdifftsdData);
TimeInTsd = ImdifftsdTime;
clear ImdifftsdTimeTemp ImdifftsdDataTemp ImdifftsdTime ImdifftsdData

% Concatenate Xtsd (type single tsd)
for i=1:length(FilesList)
    XtsdTimeTemp{i} = Range(a{i}.Xtsd);
    XtsdDataTemp{i} = Data(a{i}.Xtsd);
end
for i=1:(length(FilesList)-1)
    XtsdTimeTemp{i+1} = XtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create epochs for each file
for i = 1:length(FilesList)
    v = genvarname([FolderSessionName{i}]);
    SessionEpoch.(v) = intervalSet(XtsdTimeTemp{i}(1),XtsdTimeTemp{i}(end));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
XtsdTime = XtsdTimeTemp{1};
XtsdData = XtsdDataTemp{1};
for i = 2:length(FilesList)
    XtsdTime = [XtsdTime; XtsdTimeTemp{i}];
    XtsdData = [XtsdData; XtsdDataTemp{i}];
end
Xtsd = tsd(XtsdTime, XtsdData);
clear XtsdTimeTemp XtsdDataTemp XtsdTime XtsdData

% Concatenate Ytsd (type single tsd)
for i=1:length(FilesList)
    YtsdTimeTemp{i} = Range(a{i}.Ytsd);
    YtsdDataTemp{i} = Data(a{i}.Ytsd);
end
for i=1:(length(FilesList)-1)
    YtsdTimeTemp{i+1} = YtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
end
YtsdTime = YtsdTimeTemp{1};
YtsdData = YtsdDataTemp{1};
for i = 2:length(FilesList)
    YtsdTime = [YtsdTime; YtsdTimeTemp{i}];
    YtsdData = [YtsdData; YtsdDataTemp{i}];
end
Ytsd = tsd(YtsdTime, YtsdData);
clear YtsdTimeTemp YtsdDataTemp YtsdTime YtsdData

% Concatenate Vtsd (type single tsd) - describe, plz, what's the trick!!!!
for i=1:length(FilesList)
    if i==length(FilesList)
        VtsdTimeTemp{i} = Range(a{i}.Vtsd);
        VtsdDataTemp{i} = Data(a{i}.Vtsd);
    else
        VtsdTimeTemp{i} = [Range(a{i}.Vtsd); lasttimeBeh(i)];
        VtsdDataTemp{i} = [Data(a{i}.Vtsd); -1];
    end
end
for i=1:(length(FilesList)-1)
    VtsdTimeTemp{i+1} = VtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
end
VtsdTime = VtsdTimeTemp{1};
VtsdData = VtsdDataTemp{1};
for i = 2:length(FilesList)
    VtsdTime = [VtsdTime; VtsdTimeTemp{i}];
    VtsdData = [VtsdData; VtsdDataTemp{i}];
end
Vtsd = tsd(VtsdTime, VtsdData);
clear VtsdTimeTemp VtsdDataTemp VtsdTime VtsdData

%%%%% NON-OBLIGATORY

% Concatenate GotFrame (type - array)
for i=1:length(FilesList)
    if isfield(a{i}, 'GotFrame')
        GotFrameTemp{i} = a{i}.GotFrame;
    else
        GotFrameTemp{i} = zeros(1,lind(i));
    end
end
GotFrame = GotFrameTemp{1};
for i = 2:length(FilesList)
    GotFrame = [GotFrame GotFrameTemp{i}];
end
clear GotFrameTemp

% Concatenate Freezeepoch (type single tsa)
for i=1:length(FilesList)
    if isfield(a{i}, 'FreezeEpoch')
        FreezeEpochTempStart{i} = Start(a{i}.FreezeEpoch);
        FreezeEpochTempEnd{i} = End(a{i}.FreezeEpoch);
    else
        FreezeEpochTempStart{i} = [];
        FreezeEpochTempEnd{i} = [];
    end
end
for i=1:(length(FilesList)-1)
    if ~isempty (FreezeEpochTempStart{i+1})
        FreezeEpochTempStart{i+1} = FreezeEpochTempStart{i+1}+sum(duration(1:i))*1e4;
        FreezeEpochTempEnd{i+1} = FreezeEpochTempEnd{i+1} +sum(duration(1:i))*1e4;
    end
end
FreezeEpochStart = FreezeEpochTempStart{1};
FreezeEpochEnd = FreezeEpochTempEnd{1};
for i=2:length(FilesList)
    FreezeEpochStart = [FreezeEpochStart; FreezeEpochTempStart{i}];
    FreezeEpochEnd = [FreezeEpochEnd; FreezeEpochTempEnd{i}];
end
FreezeEpoch = intervalSet(FreezeEpochStart, FreezeEpochEnd);
clear FreezeEpochTempStart FreezeEpochTempEnd FreezeEpochStart FreezeEpochEnd

% Find all the zones names you have
for i = 1:length(FilesList)
    if isfield(a{i}, 'ZoneLabels')
        DoZones = true;
        break
    end
end

if exist('DoZones','var')
    if DoZones
        for k=1:length(FilesList)
            if isfield(a{k}, 'ZoneLabels')
                ZoneNames = cell(1,1000);
                v=1;
                break
            end
        end
        for i=1:length(FilesList)
            if ~isempty(behavResources(i).ZoneLabels)
                for k = 1:length(behavResources(i).ZoneLabels)
                    ZoneNames{v} = behavResources(i).ZoneLabels{k};
                    v=v+1;
                end
            end
        end
        ZoneNames = ZoneNames(~cellfun('isempty', ZoneNames));
        ZoneNames = unique(ZoneNames);
        clear v
        
        % Concatenate ZoneEpoch (type single tsa)
        for i=1:length(FilesList)
            if isfield(a{i}, 'ZoneEpoch')
                if isfield(a{i}, 'ZoneLabels')
                    ZoneEpochTempStart{i} = cell(1,length(ZoneNames));
                    ZoneEpochTempEnd{i} = cell(1,length(ZoneNames));
                    for k = 1:length(a{i}.ZoneEpoch)
                        idx_Zone = find(strcmp(a{i}.ZoneLabels{k}, ZoneNames));
                        ZoneEpochTempStart{i}{idx_Zone} = Start(a{i}.ZoneEpoch{k});
                        ZoneEpochTempEnd{i}{idx_Zone} = End(a{i}.ZoneEpoch{k});
                    end
                end
            else
                ZoneEpochTempStart{i} = [];
                ZoneEpochTempEnd{i} = [];
            end
        end
        for i=1:(length(FilesList)-1)
            if ~isempty (ZoneEpochTempStart{i+1})
                for k = 1:length(ZoneNames)
                    ZoneEpochTempStart{i+1}{k} = ZoneEpochTempStart{i+1}{k} +sum(duration(1:i))*1e4;
                    ZoneEpochTempEnd{i+1}{k} = ZoneEpochTempEnd{i+1}{k} +sum(duration(1:i))*1e4;
                end
            end
        end
        for k=1:length(ZoneNames)
            if ~isempty(ZoneEpochTempStart{1})
                if ~isempty(ZoneEpochTempStart{1}{k})
                    ZoneEpochStart{k} = ZoneEpochTempStart{1}{k};
                    ZoneEpochEnd{k} = ZoneEpochTempEnd{1}{k};
                else
                    ZoneEpochStart{k} = [];
                    ZoneEpochEnd{k} = [];
                end
            else
                ZoneEpochStart{k} = [];
                ZoneEpochEnd{k} = [];
            end
        end
        for i=2:length(FilesList)
            for k = 1:length(ZoneNames)
                if ~isempty(ZoneEpochTempStart{i})
                    ZoneEpochStart{k} = [ZoneEpochStart{k}; ZoneEpochTempStart{i}{k}];
                    ZoneEpochEnd{k} = [ZoneEpochEnd{k}; ZoneEpochTempEnd{i}{k}];
                end
            end
        end
        for i=1:length(ZoneNames)
            ZoneEpoch.(ZoneNames{i}) = intervalSet(ZoneEpochStart{i}, ZoneEpochEnd{i});
        end
        clear idx_Zone ZoneEpochTempStart ZoneEpochTempEnd ZoneEpochStart ZoneEpochEnd
        
        % Concatenate ZoneIndices (type array of indices * 7 - number of Zones)
        for i=1:length(FilesList)
            if isfield(a{i}, 'ZoneIndices')
                ZoneIndicesTemp{i} = cell(1,length(ZoneNames));
                for k = 1:length(a{i}.ZoneIndices)
                    idx_Zone = find(strcmp(a{i}.ZoneLabels{k}, ZoneNames));
                    ZoneIndicesTemp{i}{idx_Zone} = a{i}.ZoneIndices{k};
                end
            else
                ZoneIndicesTemp{i} = [];
            end
        end
        for i=1:(length(FilesList)-1)
            if ~isempty (ZoneIndicesTemp{i+1})
                for k = 1:length(ZoneNames)
                    ZoneIndicesTemp{i+1}{k} = ZoneIndicesTemp{i+1}{k} + sum(lind(1:i));
                end
            end
        end
        for k=1:length(ZoneNames)
            if ~isempty(ZoneIndicesTemp{1})
                if ~isempty(ZoneIndicesTemp{1}{k})
                    ZoneIndicesNew{k} = ZoneIndicesTemp{1}{k};
                else
                    ZoneIndicesNew{k} = [];
                end
            else
                ZoneIndicesNew{k} = [];
            end
        end
        for i=2:length(FilesList)
            for k = 1:length(ZoneNames)
                if ~isempty(ZoneIndicesTemp{i})
                    ZoneIndicesNew{k} = [ZoneIndicesNew{k}; ZoneIndicesTemp{i}{k}];
                end
            end
        end
        for i=1:length(ZoneNames)
            ZoneIndices.(ZoneNames{i}) = ZoneIndicesNew{i};
        end
        clear idx_Zone ZoneIndicesTemp ZoneIndicesNew
    end
end

% Time in mouse temperature (it could be a bit different than in other arrays - no idea why)
for i = 1:length(FilesList)
    if isfield(a{i}, 'MouseTemp')
        MouseTempTime{i} = a{i}.MouseTemp(:,1);
    else
        MouseTempTime{i} = (Range(a{i}.Xtsd))/1e4;
    end
end
for i = 1:length(FilesList)
    offsetTemp(i) = MouseTempTime{i}(1);
    lindTemp(i) = length(MouseTempTime{i});
    lasttimeTemp(i) = MouseTempTime{i}(end);
end
clear MouseTempTime

%Concatenate MouseTemp (type - array)
for i=1:length(FilesList)
    if isfield(a{i}, 'MouseTemp')
        MouseTempTimeTemp{i} = a{i}.MouseTemp(:,1);
        MouseTempDataTemp{i} = a{i}.MouseTemp(:,2);
    else
        MouseTempTimeTemp{i} = a{i}.PosMat(:,1);
        MouseTempDataTemp{i} = nan(length(MouseTempTimeTemp{i}),1);
    end
end
for i=1:(length(FilesList)-1)
    MouseTempTimeTemp{i+1}(:,1) = MouseTempTimeTemp{i+1}(:,1) + (sum(duration(1:i)));
end
MouseTempTime = MouseTempTimeTemp{1};
MouseTempData = MouseTempDataTemp{1};
for i = 2:length(FilesList)
    MouseTempTime = [MouseTempTime; MouseTempTimeTemp{i}];
    MouseTempData = [MouseTempData; MouseTempDataTemp{i}];
end
MouseTemp = [MouseTempTime MouseTempData];
clear MouseTempTime MouseTempData MouseTempTimeTemp MouseTempDataTemp

% Concatenate CleanPosMat (type - array)
cnt=0;
for i=1:length(FilesList)
    if isfield(a{i},'CleanPosMat')
        PosMatTemp{i} = a{i}.CleanPosMat;
    else
        cnt=cnt+1;
        PosMatTemp{i} = [a{i}.PosMat(:,1) nan(length(Range(a{i}.Xtsd)),3)];
    end
end
if cnt ~= length(FilesList)
    for i=1:(length(FilesList)-1)
        PosMatTemp{i+1}(:,1) = PosMatTemp{i+1}(:,1) + (sum(duration(1:i)));
    end
    CleanPosMat = PosMatTemp{1};
    for i = 2:length(FilesList)
        CleanPosMat = [CleanPosMat; PosMatTemp{i}];
    end
    TimeInSec = CleanPosMat(:,1);
end
clear PosMatTemp

% Concatenate CleanPosMatInit (type - array)
cnt=0;
for i=1:length(FilesList)
    if isfield(a{i},'CleanPosMatInit')
        PosMatTemp{i} = a{i}.CleanPosMatInit;
    else
        cnt=cnt+1;
        PosMatTemp{i} = [a{i}.PosMat(:,1) nan(length(Range(a{i}.Xtsd)),3)];
    end
end
if cnt ~= length(FilesList)
    for i=1:(length(FilesList)-1)
        PosMatTemp{i+1}(:,1) = PosMatTemp{i+1}(:,1) + (sum(duration(1:i)));
    end
    CleanPosMatInit = PosMatTemp{1};
    for i = 2:length(FilesList)
        CleanPosMatInit = [CleanPosMatInit; PosMatTemp{i}];
    end
    TimeInSec = CleanPosMatInit(:,1);
end
clear PosMatTemp

% Concatenate CleanXtsd (type single tsd)
cnt=0;
for i=1:length(FilesList)
    if isfield(a{i},'CleanXtsd')
        XtsdTimeTemp{i} = Range(a{i}.CleanXtsd);
        XtsdDataTemp{i} = Data(a{i}.CleanXtsd);
    else
        cnt=cnt+1;
        XtsdTimeTemp{i} = Range(a{i}.Xtsd);
        XtsdDataTemp{i} = nan(length(XtsdTimeTemp{i}),1);
    end
end
if cnt ~= length(FilesList)
    for i=1:(length(FilesList)-1)
        XtsdTimeTemp{i+1} = XtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    end
    XtsdTime = XtsdTimeTemp{1};
    XtsdData = XtsdDataTemp{1};
    for i = 2:length(FilesList)
        XtsdTime = [XtsdTime; XtsdTimeTemp{i}];
        XtsdData = [XtsdData; XtsdDataTemp{i}];
    end
    CleanXtsd = tsd(XtsdTime, XtsdData);
end
clear XtsdTimeTemp XtsdDataTemp XtsdTime XtsdData

% Concatenate CleanYtsd (type single tsd)
cnt=0;
for i=1:length(FilesList)
    if isfield(a{i},'CleanYtsd')
        YtsdTimeTemp{i} = Range(a{i}.CleanYtsd);
        YtsdDataTemp{i} = Data(a{i}.CleanYtsd);
    else
        cnt=cnt+1;
        YtsdTimeTemp{i} = Range(a{i}.Ytsd);
        YtsdDataTemp{i} = nan(length(YtsdTimeTemp{i}),1);
    end
end
if cnt ~= length(FilesList)
    for i=1:(length(FilesList)-1)
        YtsdTimeTemp{i+1} = YtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    end
    YtsdTime = YtsdTimeTemp{1};
    YtsdData = YtsdDataTemp{1};
    for i = 2:length(FilesList)
        YtsdTime = [YtsdTime; YtsdTimeTemp{i}];
        YtsdData = [YtsdData; YtsdDataTemp{i}];
    end
    CleanYtsd = tsd(YtsdTime, YtsdData);
end
clear YtsdTimeTemp YtsdDataTemp YtsdTime YtsdData

% Concatenate CleanVtsd (type single tsd) - describe, plz, what's the trick!!!!
cnt=0;
for i=1:length(FilesList)
    if i==length(FilesList)
        if isfield(a{i},'CleanVtsd')
            VtsdTimeTemp{i} = Range(a{i}.CleanVtsd);
            VtsdDataTemp{i} = Data(a{i}.CleanVtsd);
        else
            cnt=cnt+1;
            temp = Range(a{i}.Xtsd);
            VtsdTimeTemp{i} = temp(1:end-1);
            VtsdDataTemp{i} = nan(length(VtsdTimeTemp{i}),1);
        end
    else
        if isfield(a{i},'CleanVtsd')
            VtsdTimeTemp{i} = [Range(a{i}.CleanVtsd); lasttimeBeh(i)];
            VtsdDataTemp{i} = [Data(a{i}.CleanVtsd); -1];
        else
            cnt=cnt+1;
            VtsdTimeTemp{i} = Range(a{i}.Xtsd);
            VtsdDataTemp{i} = nan(length(VtsdTimeTemp{i}),1);
        end
    end
end
if cnt ~= length(FilesList)
    for i=1:(length(FilesList)-1)
        VtsdTimeTemp{i+1} = VtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    end
    VtsdTime = VtsdTimeTemp{1};
    VtsdData = VtsdDataTemp{1};
    for i = 2:length(FilesList)
        VtsdTime = [VtsdTime; VtsdTimeTemp{i}];
        VtsdData = [VtsdData; VtsdDataTemp{i}];
    end
    CleanVtsd = tsd(VtsdTime, VtsdData);
end
clear VtsdTimeTemp VtsdDataTemp VtsdTime VtsdData temp

if exist('DoZones','var')
    if DoZones
        % Concatenate CleanZoneEpoch (type single tsa)
        cnt=0;
        for i=1:length(FilesList)
            if isfield(a{i}, 'CleanZoneEpoch')
                if isfield(a{i}, 'ZoneLabels')
                    ZoneEpochTempStart{i} = cell(1,length(ZoneNames));
                    ZoneEpochTempEnd{i} = cell(1,length(ZoneNames));
                    for k = 1:length(a{i}.CleanZoneEpoch)
                        idx_Zone = find(strcmp(a{i}.ZoneLabels{k}, ZoneNames));
                        ZoneEpochTempStart{i}{idx_Zone} = Start(a{i}.CleanZoneEpoch{k});
                        ZoneEpochTempEnd{i}{idx_Zone} = End(a{i}.CleanZoneEpoch{k});
                    end
                end
            else
                cnt=cnt+1;
                ZoneEpochTempStart{i} = [];
                ZoneEpochTempEnd{i} = [];
            end
        end
        if cnt ~= length(FilesList)
            for i=1:(length(FilesList)-1)
                if ~isempty (ZoneEpochTempStart{i+1})
                    for k = 1:length(ZoneNames)
                        ZoneEpochTempStart{i+1}{k} = ZoneEpochTempStart{i+1}{k} +sum(duration(1:i))*1e4;
                        ZoneEpochTempEnd{i+1}{k} = ZoneEpochTempEnd{i+1}{k} +sum(duration(1:i))*1e4;
                    end
                end
            end
            for k=1:length(ZoneNames)
                if ~isempty(ZoneEpochTempStart{1})
                    if ~isempty(ZoneEpochTempStart{1}{k})
                        ZoneEpochStart{k} = ZoneEpochTempStart{1}{k};
                        ZoneEpochEnd{k} = ZoneEpochTempEnd{1}{k};
                    else
                        ZoneEpochStart{k} = [];
                        ZoneEpochEnd{k} = [];
                    end
                else
                    ZoneEpochStart{k} = [];
                    ZoneEpochEnd{k} = [];
                end
            end
            for i=2:length(FilesList)
                for k = 1:length(ZoneNames)
                    if ~isempty(ZoneEpochTempStart{i})
                        ZoneEpochStart{k} = [ZoneEpochStart{k}; ZoneEpochTempStart{i}{k}];
                        ZoneEpochEnd{k} = [ZoneEpochEnd{k}; ZoneEpochTempEnd{i}{k}];
                    end
                end
            end
            for i=1:length(ZoneNames)
                CleanZoneEpoch.(ZoneNames{i}) = intervalSet(ZoneEpochStart{i}, ZoneEpochEnd{i});
            end
        end
        clear idx_Zone ZoneEpochTempStart ZoneEpochTempEnd ZoneEpochStart ZoneEpochEnd
        
        % Concatenate ZoneIndices (type array of indices * 7 - number of Zones)
        cnt=0;
        for i=1:length(FilesList)
            if isfield(a{i}, 'CleanZoneIndices')
                ZoneIndicesTemp{i} = cell(1,length(ZoneNames));
                for k = 1:length(a{i}.CleanZoneIndices)
                    idx_Zone = find(strcmp(a{i}.ZoneLabels{k}, ZoneNames));
                    ZoneIndicesTemp{i}{idx_Zone} = a{i}.CleanZoneIndices{k};
                end
            else
                cnt=cnt+1;
                ZoneIndicesTemp{i} = [];
            end
        end
        if cnt ~= length(FilesList)
            for i=1:(length(FilesList)-1)
                if ~isempty (ZoneIndicesTemp{i+1})
                    for k = 1:length(ZoneNames)
                        ZoneIndicesTemp{i+1}{k} = ZoneIndicesTemp{i+1}{k} + sum(lind(1:i));
                    end
                end
            end
            for k=1:length(ZoneNames)
                if ~isempty(ZoneIndicesTemp{1})
                    if ~isempty(ZoneIndicesTemp{1}{k})
                        ZoneIndicesNew{k} = ZoneIndicesTemp{1}{k};
                    else
                        ZoneIndicesNew{k} = [];
                    end
                else
                    ZoneIndicesNew{k} = [];
                end
            end
            for i=2:length(FilesList)
                for k = 1:length(ZoneNames)
                    if ~isempty(ZoneIndicesTemp{i})
                        ZoneIndicesNew{k} = [ZoneIndicesNew{k}; ZoneIndicesTemp{i}{k}];
                    end
                end
            end
            for i=1:length(ZoneNames)
                CleanZoneIndices.(ZoneNames{i}) = ZoneIndicesNew{i};
            end
        end
        clear idx_Zone ZoneIndicesTemp ZoneIndicesNew
    end
end

% Concatenate AlignedXtsd (type single tsd)
cnt=0;
for i=1:length(FilesList)
    if isfield(a{i},'AlignedXtsd')
        XtsdTimeTemp{i} = Range(a{i}.AlignedXtsd);
        XtsdDataTemp{i} = Data(a{i}.AlignedXtsd);
    else
        cnt=cnt+1;
        XtsdTimeTemp{i} = Range(a{i}.Xtsd);
        XtsdDataTemp{i} = nan(length(XtsdTimeTemp{i}),1);
    end
end
if cnt ~= length(FilesList)
    for i=1:(length(FilesList)-1)
        XtsdTimeTemp{i+1} = XtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    end
    XtsdTime = XtsdTimeTemp{1};
    XtsdData = XtsdDataTemp{1};
    for i = 2:length(FilesList)
        XtsdTime = [XtsdTime; XtsdTimeTemp{i}];
        XtsdData = [XtsdData; XtsdDataTemp{i}];
    end
    AlignedXtsd = tsd(XtsdTime, XtsdData);
end
clear XtsdTimeTemp XtsdDataTemp XtsdTime XtsdData


% Concatenate AlignedYtsd (type single tsd)
cnt=0;
for i=1:length(FilesList)
    if isfield(a{i},'AlignedYtsd')
        YtsdTimeTemp{i} = Range(a{i}.AlignedYtsd);
        YtsdDataTemp{i} = Data(a{i}.AlignedYtsd);
    else
        cnt=cnt+1;
        YtsdTimeTemp{i} = Range(a{i}.Xtsd);
        YtsdDataTemp{i} = nan(length(YtsdTimeTemp{i}),1);
    end
end
if cnt ~= length(FilesList)
    for i=1:(length(FilesList)-1)
        YtsdTimeTemp{i+1} = YtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    end
    YtsdTime = YtsdTimeTemp{1};
    YtsdData = YtsdDataTemp{1};
    for i = 2:length(FilesList)
        YtsdTime = [YtsdTime; YtsdTimeTemp{i}];
        YtsdData = [YtsdData; YtsdDataTemp{i}];
    end
    AlignedYtsd = tsd(YtsdTime, YtsdData);
end
clear YtsdTimeTemp YtsdDataTemp YtsdTime YtsdData

if exist('DoZones','var')
    if DoZones
        % Concatenate ZoneEpochAligned (type single tsa)
        cnt=0;
        for i=1:length(FilesList)
            if isfield(a{i}, 'ZoneEpochAligned')
                if isfield(a{i}, 'ZoneLabels')
                    ZoneEpochTempStart{i} = cell(1,length(ZoneNames));
                    ZoneEpochTempEnd{i} = cell(1,length(ZoneNames));
                    for k = 1:length(a{i}.ZoneEpochAligned)
                        idx_Zone = find(strcmp(a{i}.ZoneLabels{k}, ZoneNames));
                        ZoneEpochTempStart{i}{idx_Zone} = Start(a{i}.ZoneEpochAligned{k});
                        ZoneEpochTempEnd{i}{idx_Zone} = End(a{i}.ZoneEpochAligned{k});
                    end
                end
            else
                cnt=cnt+1;
                ZoneEpochTempStart{i} = [];
                ZoneEpochTempEnd{i} = [];
            end
        end
        if cnt ~= length(FilesList)
            for i=1:(length(FilesList)-1)
                if ~isempty (ZoneEpochTempStart{i+1})
                    for k = 1:length(ZoneEpochTempStart{i+1})
                        ZoneEpochTempStart{i+1}{k} = ZoneEpochTempStart{i+1}{k} +sum(duration(1:i))*1e4;
                        ZoneEpochTempEnd{i+1}{k} = ZoneEpochTempEnd{i+1}{k} +sum(duration(1:i))*1e4;
                    end
                end
            end
            for k=1:length(ZoneNames)
                if ~isempty(ZoneEpochTempStart{1})
                    if ~isempty(ZoneEpochTempStart{1}{k})
                        ZoneEpochStart{k} = ZoneEpochTempStart{1}{k};
                        ZoneEpochEnd{k} = ZoneEpochTempEnd{1}{k};
                    else
                        ZoneEpochStart{k} = [];
                        ZoneEpochEnd{k} = [];
                    end
                else
                    ZoneEpochStart{k} = [];
                    ZoneEpochEnd{k} = [];
                end
            end
            for i=2:length(FilesList)
                for k = 1:length(ZoneNames)
                    if ~isempty(ZoneEpochTempStart{i})
                        ZoneEpochStart{k} = [ZoneEpochStart{k}; ZoneEpochTempStart{i}{k}];
                        ZoneEpochEnd{k} = [ZoneEpochEnd{k}; ZoneEpochTempEnd{i}{k}];
                    end
                end
            end
            for i=1:length(ZoneNames)
                ZoneEpochAligned.(ZoneNames{i}) = intervalSet(ZoneEpochStart{i}, ZoneEpochEnd{i});
            end
        end
        clear idx_Zone ZoneEpochTempStart ZoneEpochTempEnd ZoneEpochStart ZoneEpochEnd
    end
end

% Concatenate LinearDist (type single tsd)
for i=1:length(FilesList)
    if isfield(a{i},'LinearDist')
        LinearDistTimeTemp{i} = Range(a{i}.LinearDist);
        LinearDistDataTemp{i} = Data(a{i}.LinearDist);
    else
        LinearDistTimeTemp{i} = Range(a{i}.Xtsd);
        LinearDistDataTemp{i} = nan(length(LinearDistTimeTemp{i}),1);
    end
end
for i=1:(length(FilesList)-1)
    LinearDistTimeTemp{i+1} = LinearDistTimeTemp{i+1}+sum(duration(1:i))*1e4;
end
LinearDistTime = LinearDistTimeTemp{1};
LinearDistData = LinearDistDataTemp{1};
for i = 2:length(FilesList)
    LinearDistTime = [LinearDistTime; LinearDistTimeTemp{i}];
    LinearDistData = [LinearDistData; LinearDistDataTemp{i}];
end
LinearDist = tsd(LinearDistTime, LinearDistData);
clear LinearDistTimeTemp LinearDistDataTemp LinearDistTime LinearDistData

% Concatenate CleanAlignedXtsd (type single tsd)
cnt=0;
for i=1:length(FilesList)
    if isfield(a{i},'CleanAlignedXtsd')
        XtsdTimeTemp{i} = Range(a{i}.CleanAlignedXtsd);
        XtsdDataTemp{i} = Data(a{i}.CleanAlignedXtsd);
    else
        cnt=cnt+1;
        XtsdTimeTemp{i} = Range(a{i}.Xtsd);
        XtsdDataTemp{i} = nan(length(XtsdTimeTemp{i}),1);
    end
end
if cnt ~= length(FilesList)
    for i=1:(length(FilesList)-1)
        XtsdTimeTemp{i+1} = XtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    end
    XtsdTime = XtsdTimeTemp{1};
    XtsdData = XtsdDataTemp{1};
    for i = 2:length(FilesList)
        XtsdTime = [XtsdTime; XtsdTimeTemp{i}];
        XtsdData = [XtsdData; XtsdDataTemp{i}];
    end
    CleanAlignedXtsd = tsd(XtsdTime, XtsdData);
end
clear XtsdTimeTemp XtsdDataTemp XtsdTime XtsdData


% Concatenate CleanAlignedYtsd (type single tsd)
cnt=0;
for i=1:length(FilesList)
    if isfield(a{i},'CleanAlignedYtsd')
        YtsdTimeTemp{i} = Range(a{i}.CleanAlignedYtsd);
        YtsdDataTemp{i} = Data(a{i}.CleanAlignedYtsd);
    else
        cnt=cnt+1;
        YtsdTimeTemp{i} = Range(a{i}.Xtsd);
        YtsdDataTemp{i} = nan(length(YtsdTimeTemp{i}),1);
    end
end
if cnt ~= length(FilesList)
    for i=1:(length(FilesList)-1)
        YtsdTimeTemp{i+1} = YtsdTimeTemp{i+1}+sum(duration(1:i))*1e4;
    end
    YtsdTime = YtsdTimeTemp{1};
    YtsdData = YtsdDataTemp{1};
    for i = 2:length(FilesList)
        YtsdTime = [YtsdTime; YtsdTimeTemp{i}];
        YtsdData = [YtsdData; YtsdDataTemp{i}];
    end
    CleanAlignedYtsd = tsd(YtsdTime, YtsdData);
end
clear YtsdTimeTemp YtsdDataTemp YtsdTime YtsdData

if exist('DoZones','var')
    if DoZones
        % Concatenate CleanZoneEpochAligned (type single tsa)
        cnt=0;
        for i=1:length(FilesList)
            if isfield(a{i}, 'CleanZoneEpochAligned')
                if isfield(a{i}, 'ZoneLabels')
                    ZoneEpochTempStart{i} = cell(1,length(ZoneNames));
                    ZoneEpochTempEnd{i} = cell(1,length(ZoneNames));
                    for k = 1:length(a{i}.CleanZoneEpochAligned)
                        idx_Zone = find(strcmp(a{i}.ZoneLabels{k}, ZoneNames));
                        ZoneEpochTempStart{i}{idx_Zone} = Start(a{i}.CleanZoneEpochAligned{k});
                        ZoneEpochTempEnd{i}{idx_Zone} = End(a{i}.CleanZoneEpochAligned{k});
                    end
                end
            else
                cnt=cnt+1;
                ZoneEpochTempStart{i} = [];
                ZoneEpochTempEnd{i} = [];
            end
        end
        if cnt ~= length(FilesList)
            for i=1:(length(FilesList)-1)
                if ~isempty (ZoneEpochTempStart{i+1})
                    for k = 1:length(ZoneEpochTempStart{i+1})
                        ZoneEpochTempStart{i+1}{k} = ZoneEpochTempStart{i+1}{k} +sum(duration(1:i))*1e4;
                        ZoneEpochTempEnd{i+1}{k} = ZoneEpochTempEnd{i+1}{k} +sum(duration(1:i))*1e4;
                    end
                end
            end
            for k=1:length(ZoneNames)
                if ~isempty(ZoneEpochTempStart{1})
                    if ~isempty(ZoneEpochTempStart{1}{k})
                        ZoneEpochStart{k} = ZoneEpochTempStart{1}{k};
                        ZoneEpochEnd{k} = ZoneEpochTempEnd{1}{k};
                    else
                        ZoneEpochStart{k} = [];
                        ZoneEpochEnd{k} = [];
                    end
                else
                    ZoneEpochStart{k} = [];
                    ZoneEpochEnd{k} = [];
                end
            end
            for i=2:length(FilesList)
                for k = 1:length(ZoneNames)
                    if ~isempty(ZoneEpochTempStart{i})
                        ZoneEpochStart{k} = [ZoneEpochStart{k}; ZoneEpochTempStart{i}{k}];
                        ZoneEpochEnd{k} = [ZoneEpochEnd{k}; ZoneEpochTempEnd{i}{k}];
                    end
                end
            end
            for i=1:length(ZoneNames)
                CleanZoneEpochAligned.(ZoneNames{i}) = intervalSet(ZoneEpochStart{i}, ZoneEpochEnd{i});
            end
        end
        clear idx_Zone ZoneEpochTempStart ZoneEpochTempEnd ZoneEpochStart ZoneEpochEnd
    end
end

% Concatenate LinearDist (type single tsd)
cnt=0;
for i=1:length(FilesList)
    if isfield(a{i},'CleanLinearDist')
        LinearDistTimeTemp{i} = Range(a{i}.CleanLinearDist);
        LinearDistDataTemp{i} = Data(a{i}.CleanLinearDist);
    else
        cnt=cnt+1;
        LinearDistTimeTemp{i} = Range(a{i}.Xtsd);
        LinearDistDataTemp{i} = nan(length(LinearDistTimeTemp{i}),1);
    end
end
if cnt ~= length(FilesList)
    for i=1:(length(FilesList)-1)
        LinearDistTimeTemp{i+1} = LinearDistTimeTemp{i+1}+sum(duration(1:i))*1e4;
    end
    LinearDistTime = LinearDistTimeTemp{1};
    LinearDistData = LinearDistDataTemp{1};
    for i = 2:length(FilesList)
        LinearDistTime = [LinearDistTime; LinearDistTimeTemp{i}];
        LinearDistData = [LinearDistData; LinearDistDataTemp{i}];
    end
    CleanLinearDist = tsd(LinearDistTime, LinearDistData);
end
clear LinearDistTimeTemp LinearDistDataTemp LinearDistTime LinearDistData


%% Clear temporary variables
clear a duration FilesList i indir k lasttime lasttimeTemp lind lindTemp offset offsetTemp TimeinSec TimeinTsd
clear beg_end DoZones en lasttimebeh varargin

%% Save common variables
if ~exist([pathtosave 'behavResources.mat'], 'file')
    disp('Creating behavResources.mat');
    save([pathtosave 'behavResources.mat']);
else
    save([pathtosave 'behavResources.mat'], 'behavResources', 'SessionEpoch', 'im_diff','im_diffInit', 'Imdifftsd', 'PosMat',...
        'PosMatInit', 'Vtsd', 'Xtsd', 'Ytsd', 'ThousandFrames','-append');
    if exist('GotFrame', 'var')
        save([pathtosave 'behavResources.mat'], 'GotFrame', '-append');
    end
    if exist('MouseTemp', 'var')
        save([pathtosave 'behavResources.mat'], 'MouseTemp', '-append');
    end
    if exist('ZoneNames', 'var')
        save([pathtosave 'behavResources.mat'], 'ZoneNames', '-append');
    end
    if exist('ZoneIndices', 'var')
        save([pathtosave 'behavResources.mat'], 'ZoneIndices', '-append');
    end
    if exist('ZoneEpoch', 'var')
        save([pathtosave 'behavResources.mat'], 'ZoneEpoch', '-append');
    end
    if exist('FreezeEpoch', 'var')
        save([pathtosave 'behavResources.mat'], 'FreezeEpoch', '-append');
    end
    if exist('CleanPosMat', 'var')
        save([pathtosave 'behavResources.mat'], 'CleanPosMat', '-append');
    end
    if exist('CleanPosMatInit', 'var')
        save([pathtosave 'behavResources.mat'], 'CleanPosMatInit', '-append');
    end
    if exist('CleanXtsd', 'var')
        save([pathtosave 'behavResources.mat'], 'CleanXtsd', '-append');
    end
    if exist('CleanYtsd', 'var')
        save([pathtosave 'behavResources.mat'], 'CleanYtsd', '-append');
    end
    if exist('CleanVtsd', 'var')
        save([pathtosave 'behavResources.mat'], 'CleanVtsd', '-append');
    end
    if exist('CleanZoneEpoch', 'var')
        save([pathtosave 'behavResources.mat'], 'CleanZoneEpoch', '-append');
    end
    if exist('CleanZoneIndices', 'var')
        save([pathtosave 'behavResources.mat'], 'CleanZoneIndices', '-append');
    end
    if exist('AlignedXtsd', 'var')
        save([pathtosave 'behavResources.mat'], 'AlignedXtsd', '-append');
    end
    if exist('AlignedYtsd', 'var')
        save([pathtosave 'behavResources.mat'], 'AlignedYtsd', '-append');
    end
    if exist('LinearDist', 'var')
        save([pathtosave 'behavResources.mat'], 'LinearDist', '-append');
    end
    if exist('ZoneEpochAligned', 'var')
        save([pathtosave 'behavResources.mat'], 'ZoneEpochAligned', '-append');
    end
    if exist('CleanAlignedXtsd', 'var')
        save([pathtosave 'behavResources.mat'], 'CleanAlignedXtsd', '-append');
    end
    if exist('CleanAlignedYtsd', 'var')
        save([pathtosave 'behavResources.mat'], 'CleanAlignedYtsd', '-append');
    end
    if exist('CleanLinearDist', 'var')
        save([pathtosave 'behavResources.mat'], 'CleanLinearDist', '-append');
    end
    if exist('CleanZoneEpochAligned', 'var')
        save([pathtosave 'behavResources.mat'], 'CleanZoneEpochAligned', '-append');
    end
end

end