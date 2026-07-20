
%% figures
clear all
load('/media/nas7/React_Passive_AG/OBG/Data_Paper/Overlap_REM.mat')

Cols = {[.2 .5 .8],[.8 .5 .2],[.5 .2 .8]};
X = 1:3;
Legends = {'F1','F2','F3'};

figure
MakeSpreadAndBoxPlot3_SB({Overlap(1,:) Overlap(2,:) Overlap(3,:)},Cols,X,Legends,'showpoints',1,'paired',0,'showsigstar','none','sizepoints');
ylabel('Score agreement'), ylim([0 1])
makepretty_BM2


%% generqte data
clear all

% sessions
Dir1 = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);


%% data
for ferret=1:3
    for sess=1:length(Dir{ferret}.path)
        try
            clear Sleep SWSEpoch REMEpoch ISEpoch REM_OB
            load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'SWSEpoch')
            if sum(DurationEpoch(SWSEpoch))/3600e4>1 % session with enough sleep
                
                load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'REMEpoch', 'Sleep', 'ISEpoch', 'REM_OB')
                
                % Intersection
                Overlap(ferret,sess) = (sum(DurationEpoch(and(or(SWSEpoch , ISEpoch) , Sleep-REM_OB)))+sum(DurationEpoch(and(REMEpoch , REM_OB))))./...
                    sum(DurationEpoch(Sleep));
            end
        end
    end
end
Overlap(1,[18])=NaN;
Overlap(Overlap==0)=NaN;









