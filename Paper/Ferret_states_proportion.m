
%%
SleepInfo_mouse = GetSleepSessions_Drugs_BM;
SleepInfo_ferret = GetSleepSessions_Ferret_BM;

Species={'Mouse','Ferret'};
States={'Wake','Sleep','NREM','REM'};

for sp=1:2
    if sp==1
        Sleep_Path = SleepInfo_mouse.path{1};
    else
        Sleep_Path = SleepInfo_ferret.path{3};
    end
    for f=1:length(Sleep_Path)
        load([Sleep_Path{f} '/SleepScoring_OBGamma.mat'],'Epoch','Sleep','Wake','SWSEpoch','REMEpoch')
        for states=1:4
            if states==1
                State = Wake;
            elseif states==2
                State = Sleep;
            elseif states==3
                State = SWSEpoch;
            elseif states==4
                State = REMEpoch;
            end
            if states<3
                State_Prop(sp,f,states) = sum(DurationEpoch(and(State , Epoch)))./sum(DurationEpoch(Epoch));
                State_Number(sp,f,states) = length(Start(and(State , Epoch)))./(sum(DurationEpoch(Epoch))/3600e4);
            else
                State_Prop(sp,f,states) = sum(DurationEpoch(and(State , Epoch)))./sum(DurationEpoch(Sleep));
                State_Number(sp,f,states) = length(Start(and(State , Epoch)))./(sum(DurationEpoch(Sleep))/3600e4);
            end
            State_MeanDur(sp,f,states) = nanmedian(DurationEpoch(and(State , Epoch)))/1e4;
            
            try
                if states<4
                    State = dropShortIntervals(State , 60e4);
                else
                    State = dropShortIntervals(State , 10e4);
                end
                clear St, St = Start(and(State , Epoch))/1e4;
                State_FirstOnset(sp,f,states) = St(1);
            end
        end
        disp(Sleep_Path{f})
    end
end
State_Prop(State_Prop==0)=NaN;
State_MeanDur(State_MeanDur==0)=NaN;
State_Number(State_Number==0)=NaN;
State_FirstOnset(State_FirstOnset==0)=NaN;

%%
Cols = {[.1 .5 .9],[.9 .5 .1]};
X = 1:2;
Legends = {'Mice','Ferret'};
NoLegends = {'',''};

figure
for states=1:4
    subplot(4,4,states)
    MakeSpreadAndBoxPlot3_SB({squeeze(State_Prop(1,:,states)) squeeze(State_Prop(2,:,states))},Cols,X,NoLegends,'showpoints',1,'paired',0)
    if states==1, ylabel('proportion'), end
    ylim([0 1.1])
    title(States(states))
    
    subplot(4,4,states+4)
    MakeSpreadAndBoxPlot3_SB({squeeze(State_MeanDur(1,:,states)) squeeze(State_MeanDur(2,:,states))},Cols,X,NoLegends,'showpoints',1,'paired',0)
    if states==1, ylabel('mean dur (s)'), end
    ylim([0 80])
    
    subplot(4,4,states+8)
    MakeSpreadAndBoxPlot3_SB({squeeze(State_Number(1,:,states)) squeeze(State_Number(2,:,states))},Cols,X,NoLegends,'showpoints',1,'paired',0)
    if states==1, ylabel('ep # occurence / recording hours)'), elseif states==3, ylabel('ep # occurence / sleep hours)'), end
    ylim([0 80])
    
    if states>1
        subplot(4,4,states+12)
        MakeSpreadAndBoxPlot3_SB({squeeze(State_FirstOnset(1,:,states)) squeeze(State_FirstOnset(2,:,states))},Cols,X,Legends,'showpoints',1,'paired',0)
        if states==2, ylabel('first onset (s)'), end
    end
end








