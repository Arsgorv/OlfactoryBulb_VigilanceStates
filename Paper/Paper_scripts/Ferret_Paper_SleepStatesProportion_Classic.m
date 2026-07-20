
clear all

Dir1 = PathForExperimentsOB({'Labneh'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{1} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Brynza'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{2} = MergePathForExperiment(Dir1,Dir2);

Dir1 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);

%%
for ferret=1:3
    for sess=1:length(Dir{ferret}.path)
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'],'Epoch','TotalNoiseEpoch','Sleep',...
            'Wake', 'SWSEpoch', 'REMEpoch', 'ISEpoch')
        if sum(DurationEpoch(SWSEpoch))/3600e4>1 % session with enough sleep
            
            Wake = or(Wake , TotalNoiseEpoch);
            
            for states=1:5
                if states==1
                    State = Wake;
                elseif states==2
                    State = ISEpoch;
                elseif states==3
                    State = SWSEpoch;
                elseif states==4
                    State = REMEpoch;
                elseif states==5
                    State = or(ISEpoch,SWSEpoch);
                end
                
                State_prop{ferret}(states,sess) = sum(DurationEpoch(State))./sum(DurationEpoch(or(Epoch , TotalNoiseEpoch)));
                
            end
            
            clear Sptsd Sp_ByState Sp_ByState_clean
            
            disp(sess)
        end
    end
    State_prop{ferret}(State_prop{ferret}==0) = NaN;
end


ferret=3;

figure
MakeSpreadAndBoxPlot3_SB({State_prop{ferret}(1,:) State_prop{ferret}(5,:) State_prop{ferret}(4,:)},...
    {[.2 .2 .8],[.8 .2 .2],[.2 .8 .2]},[1:3],{'Wake','NREM','REM'},'showpoints',1,'paired',0,'size_points',15)
ylabel('Proportion')
makepretty_BM2


% a= pie([nanmean(State_prop{ferret}(1,:)) ; nanmean(State_prop{ferret}(5,:)) ; nanmean(State_prop{ferret}(4,:))]);
% set(a(1), 'FaceColor', [.2 .2 .8]); set(a(3), 'FaceColor', [.8 .2 .2]); set(a(5), 'FaceColor', [.2 .8 .2]);







