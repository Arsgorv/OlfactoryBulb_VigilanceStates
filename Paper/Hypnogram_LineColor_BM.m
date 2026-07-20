function Hypnogram_LineColor_BM(thr,varargin)

for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'time'
            time = varargin{i+1};
        case 'scoring'
            scoring = varargin{i+1};
    end
end

if ~exist('time','var')
    time='s';
end
if ~exist('scoring','var')
    scoring='sb';
end

           
if time=='s'
    val=1;
elseif time=='min'
    val=60;
elseif time=='h'
    val=3600;
end

load('LFPData/LFP0.mat')
% if convertCharsToStrings(scoring) == 'bm'
try
    load('SleepScoring_OBGamma.mat', 'REMEpoch','SWSEpoch','Epoch','Wake')
catch
    load('StateEpochSB.mat', 'REMEpoch','SWSEpoch','Epoch','Wake')
    
end
% elseif convertCharsToStrings(scoring) == 'sb'
%     load('SleepScoring_OBGamma.mat','Epoch_01_05','Epoch','Wake','Sleep')
%     SWSEpoch = and(Sleep,Epoch_01_05);
%     REMEpoch = Sleep-and(Sleep,Epoch_01_05);
% end

t=Range(LFP);
begin=t(1)/(val*1e4);
endin=t(end)/(val*1e4);

line([begin endin],[thr thr],'linewidth',10,'color','w')

clear sleepstart sleepstop
sleepstart=Start(Wake);
sleepstop=Stop(Wake);
for k=1:length(sleepstart)
    line([sleepstart(k)/(val*1e4) sleepstop(k)/(val*1e4)],[thr thr],'color','b','linewidth',5);
end

clear sleepstart sleepstop
sleepstart=Start(SWSEpoch);
sleepstop=Stop(SWSEpoch);
for k=1:length(sleepstart)
    line([sleepstart(k)/(val*1e4) sleepstop(k)/(val*1e4)],[thr thr],'color','r','linewidth',5);
end

clear sleepstart sleepstop
sleepstart=Start(REMEpoch);
sleepstop=Stop(REMEpoch);
for k=1:length(sleepstart)
    line([sleepstart(k)/(val*1e4) sleepstop(k)/(val*1e4)],[thr thr],'color','g','linewidth',5);
end



