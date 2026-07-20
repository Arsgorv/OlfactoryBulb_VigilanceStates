


clear all

%% gather data
Dir{1} = PathForExperimentsOB({'Labneh'}, 'freely-moving','none');
Dir{2} = PathForExperimentsOB({'Brynza'}, 'freely-moving','none');
Dir{3} = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none');

for ferret=1:length(Dir)
    for sess=1:4%length(Dir_sal{ferret}.path)
        
        clear inj_time Sleep REMEpoch smooth_01_05 SWSEpoch
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'CleanStates','Epoch')
        
        for states=1:3
            if states==1
                State = CleanStates.N1;
            elseif states==2
                State = CleanStates.N2;
            elseif states==3
                State = CleanStates.REM;
            end
            try
                State = dropShortIntervals(State , 250e4);
                clear St, St = Start(and(State , Epoch))/1e4;
                State_FirstOnset{ferret}{states}(sess) = St(1);
            end
        end
        disp(Dir{ferret}.path{sess})
    end
end
for ferret=1:length(Dir)
    for states=1:3
        
        State_FirstOnset{ferret}{states}(State_FirstOnset{ferret}{states}==0)=NaN;
        
    end
end


%%
Cols={[.8 .5 .2],[1 0 0],[0 1 0]};
X = 1:3;
Legends = {'IS','NREM','REM'};

figure
for f=1:3
    subplot(1,3,f)
    MakeSpreadAndBoxPlot3_SB(State_FirstOnset{f},Cols,X,Legends,'showpoints',1,'paired',0)
    if f==1, ylabel('First onset (s)'), end
    title(['Ferret ' num2str(f)])
end









%% tool
for ferret=1:length(Dir)
    for sess=1:4%length(Dir_sal{ferret}.path)
        
        cd(Dir{ferret}.path{sess})
        
        MakeCleanStates_Ferret_BM
        clearvars -except ferret sess Dir
        
    end
end







