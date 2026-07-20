

clear all

LineHeight = 9.5;
Colors.N1 = [1 .5 0];
Colors.N2 = 'r';
Colors.REM = 'g';
Colors.Wake = 'b';
Colors.Noise = 'k';

smootime = 10;

%%
cd('/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240410_domitor')
load('SleepScoring_OBGamma.mat', 'SmoothGamma','SmoothTheta')

Bh = load('B_Middle_Spectrum.mat');
Bh_Sptsd = tsd(Bh.Spectro{2}*1e4 , Bh.Spectro{1});

Hl = load('H_Low_Spectrum.mat');
Hl_Sptsd = tsd(Hl.Spectro{2}*1e4 , Hl.Spectro{1});


% figures
figure
subplot(6,1,1:2)
R = Range(Bh_Sptsd); D = Data(Bh_Sptsd);
imagesc(R(1:200:end)/3.6e7 , Bh.Spectro{3} , runmean(runmean(log10(D(1:200:end,:)'),5)',5)'), axis xy
ylabel('Frequency (Hz)'), xlim([0 1]), ylim([20 100]), caxis([1.5 2.5]), xticklabels({''}), c=caxis;
u=colorbar; u.Ticks=[c(1) c(2)]; u.TickLabels={'0','1'}; u.FontSize=15; u.Label.String = 'Power (a.u.)'; u.Label.FontSize=12; set(u.Label,'Rotation',270)
v=vline(.5,'--r'); v.LineWidth = 2;
makepretty

% PlotPerAsLine(CleanStates.Wake,LineHeight,Colors.Wake,'timescaling',3.6e7);
% PlotPerAsLine(CleanStates.REM,LineHeight,Colors.REM,'timescaling',3.6e7);
% PlotPerAsLine(CleanStates.N1,LineHeight,Colors.N1,'timescaling',3.6e7);
% PlotPerAsLine(CleanStates.N2,LineHeight,Colors.N2,'timescaling',3.6e7);

subplot(613)
plot(Range(SmoothGamma,'s')/3.6e3 , runmean(Data(SmoothGamma),1e4) , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothGamma,'s')/3.6e3)]), xlim([0 1]), %ylim([0 12])
xlabel('Time (h)'), ylabel('OB gamma power (a.u.)')
v=vline(.5,'--r'); v.LineWidth = 2;
makepretty


subplot(6,1,4:5)
R = Range(Hl_Sptsd); D = Data(Hl_Sptsd);
imagesc(R(1:3:end)/3.6e7 , Hl.Spectro{3} , runmean(runmean(log10(D(1:3:end,:)'),5)',5)'), axis xy
ylabel('Frequency (Hz)'), xlim([0 1]), ylim([0 10]), xticklabels({''}), %caxis([1.5 2.5]), c=caxis;
u=colorbar; u.Ticks=[c(1) c(2)]; u.TickLabels={'0','1'}; u.FontSize=15; u.Label.String = 'Power (a.u.)'; u.Label.FontSize=12; set(u.Label,'Rotation',270)
vline(.5,'--r')
makepretty

% PlotPerAsLine(CleanStates.Wake,LineHeight,Colors.Wake,'timescaling',3.6e7);
% PlotPerAsLine(CleanStates.REM,LineHeight,Colors.REM,'timescaling',3.6e7);
% PlotPerAsLine(CleanStates.N1,LineHeight,Colors.N1,'timescaling',3.6e7);
% PlotPerAsLine(CleanStates.N2,LineHeight,Colors.N2,'timescaling',3.6e7);

subplot(616)
plot(Range(SmoothTheta,'s')/3.6e3 , runmean(Data(SmoothTheta),1e4) , 'k' , 'LineWidth',1)
xlim([0 max(Range(SmoothGamma,'s')/3.6e3)]), xlim([0 1]), %ylim([0 12])
xlabel('Time (h)'), ylabel('OB gamma power (a.u.)')
vline(.5,'--r')
makepretty



%% many ferrets
% Dir{1} = PathForExperimentsOB({'Edel'}, 'head-fixed','domitor');
Dir_sal{1} = PathForExperimentsOB({'Brynza'}, 'head-fixed','saline');
Dir_sal{2} = PathForExperimentsOB({'Shropshire'}, 'head-fixed','saline');

Dir_dom{1} = PathForExperimentsOB({'Brynza'}, 'head-fixed','domitor');
Dir_dom{2} = PathForExperimentsOB({'Shropshire'}, 'head-fixed','domitor');


for ferret=1:length(Dir_sal)
    for sess=1:length(Dir_sal{ferret}.path)
        
        clear inj_time Sleep REMEpoch smooth_01_05 SWSEpoch
        load([Dir_sal{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'Wake','Sleep', 'inj_time' , 'SmoothGamma')
        
        try
            inj_time;
        catch
            inj_time{1} = max(Range(SmoothGamma))/2;
        end
        
        % epochs
        try
            Before_Injection = intervalSet(inj_time{1}-2.2*3600e4 , -600e4+inj_time{1});
            After_Injection = intervalSet(inj_time{1}+600e4 , inj_time{1}+2.2*3600e4);
        catch
            Before_Injection = intervalSet(inj_time-2.2*3600e4 , -600e4+inj_time);
            After_Injection = intervalSet(inj_time+600e4 , inj_time+2.2*3600e4);
        end
        % states prop
        for states=1:2
            if states==1
                State = Wake;
            elseif states==2
                State = Sleep;
            end
            State_Prop_Pre_sal{states}{ferret}(sess) = sum(DurationEpoch(and(State , Before_Injection)))./sum(DurationEpoch(Before_Injection));
            State_Prop_Post_sal{states}{ferret}(sess) = sum(DurationEpoch(and(State , After_Injection)))./sum(DurationEpoch(After_Injection));
            
        end
        disp([ferret sess])
    end
    
     for sess=1:length(Dir_dom{ferret}.path)
        
        clear inj_time Sleep REMEpoch smooth_01_05 SWSEpoch
        load([Dir_dom{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'], 'Wake','Sleep', 'inj_time' , 'SmoothGamma')
        
        try
            inj_time;
        catch
            inj_time{1} = max(Range(SmoothGamma))/2;
        end
        
        % epochs
        try
            Before_Injection = intervalSet(inj_time{1}-2.2*3600e4 , -600e4+inj_time{1});
            After_Injection = intervalSet(inj_time{1}+600e4 , inj_time{1}+2.2*3600e4);
        catch
            Before_Injection = intervalSet(inj_time-2.2*3600e4 , -600e4+inj_time);
            After_Injection = intervalSet(inj_time+600e4 , inj_time+2.2*3600e4);
        end
        % states prop
        for states=1:2
            if states==1
                State = Wake;
            elseif states==2
                State = Sleep;
            end
            State_Prop_Pre_dom{states}{ferret}(sess) = sum(DurationEpoch(and(State , Before_Injection)))./sum(DurationEpoch(Before_Injection));
            State_Prop_Post_dom{states}{ferret}(sess) = sum(DurationEpoch(and(State , After_Injection)))./sum(DurationEpoch(After_Injection));
            
        end
        disp([ferret sess])
    end
end


Wake_pre_sal_all = []; Wake_post_sal_all = [];
Wake_pre_dom_all = []; Wake_post_dom_all = [];
for ferret=1:length(Dir_sal)
    Wake_pre_sal_all = [Wake_pre_sal_all State_Prop_Pre_sal{1}{ferret}];
    Wake_post_sal_all = [Wake_post_sal_all State_Prop_Post_sal{1}{ferret}];
    
    Wake_pre_dom_all = [Wake_pre_dom_all State_Prop_Pre_dom{1}{ferret}];
    Wake_post_dom_all = [Wake_post_dom_all State_Prop_Post_dom{1}{ferret}];    
end
Wake_post_sal_all(Wake_post_sal_all<.1)=NaN; % waiting to be corrected


% figures
Cols = {[.3 .3 .3],[.2 .4 .8]};
X = 1:2;
Legends = {'Post saline','Post medetomidine'};

figure
MakeSpreadAndBoxPlot3_SB({Wake_post_sal_all Wake_post_dom_all},Cols,X,Legends,'showpoints',1,'paired',0,'size_points',10);
ylabel('Wake prop')






