

%% example
% cd('/media/nas8/OB_ferret_AG_BM/Shropshire/head-fixed/20241211_TORCs')
cd('/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230227')

% load('LFPData/LFP105.mat')
load('LFPData/LFP35.mat')

load('SleepScoring_OBGamma.mat', 'CleanStates')

rayleigh_test(Restrict(LFP , CleanStates.Wake) , 'plot_fig' , 1 , 'colors' , [0 0 1]);
rayleigh_test(Restrict(LFP , CleanStates.Sleep) , 'plot_fig' , 1 , 'colors' , [.3 .3 .3]);


%% all ferrets
clear all

Dir2 = PathForExperimentsOB({'Labneh'}, 'head-fixed','none');
Dir{1} = Dir2;

Dir2 = PathForExperimentsOB({'Brynza'}, 'head-fixed','none');
Dir{2} = Dir2;

Dir1 = PathForExperimentsOB({'Shropshire'}, 'head-fixed','saline');
Dir2 = PathForExperimentsOB({'Shropshire'}, 'head-fixed','none');
Dir{3} = MergePathForExperiment(Dir1,Dir2);


%% collect data
for ferret=1:3
    for sess=1:length(Dir{ferret}.path)
        
        clear Wake Sleep LFP
        
        cd(Dir{ferret}.path{sess})
        
        load('SleepScoring_OBGamma.mat', 'Wake','Sleep')
        try
            load('LFPData/LFP105.mat')
            LFP;
        catch
            load('LFPData/LFP35.mat')
        end
        
        [p_wake{ferret}(sess), ~ , R_wake{ferret}(sess)] = rayleigh_test(Restrict(LFP , Wake));
        [p_sleep{ferret}(sess), ~ , R_sleep{ferret}(sess)] = rayleigh_test(Restrict(LFP , Sleep));
        
    end
    R_wake{ferret}(p_wake{ferret}>.05) = NaN;
    R_sleep{ferret}(p_sleep{ferret}>.05) = NaN;
end


%% 
Cols={[0 0 1],[.3 .3 .3]};
X = 1:2;
Legends = {'Wake','Sleep'};

figure
for ferret=1:3
    subplot(1,3,ferret)
    MakeSpreadAndBoxPlot3_SB({R_wake{ferret} R_sleep{ferret}},Cols,X,Legends,'showpoints',0,'paired',1);
    if ferret==1, ylabel('Rayleigh R'), end
    ylim([0 .35])
    makepretty_BM2
end











