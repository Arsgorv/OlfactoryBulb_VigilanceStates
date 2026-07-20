
load('/media/nas8/OB_ferret_AG_BM/DataFerret/MeanSpectrums_FM.mat')

%%
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
            
            for m=1:8
                try
                    if m==1
                        load([Dir{ferret}.path{sess} filesep 'B_Low_Spectrum.mat'])
                        RANGE = Spectro{3};
                        Range_Low = Spectro{3};
                    elseif m==2
                        load([Dir{ferret}.path{sess} filesep 'PFCx_Low_Spectrum.mat'])
                    elseif m==3
                        load([Dir{ferret}.path{sess} filesep 'H_Low_Spectrum.mat'])
                    elseif m==4
                        load([Dir{ferret}.path{sess} filesep 'AuCx_Low_Spectrum.mat'])
                    elseif m==5
                        load([Dir{ferret}.path{sess} filesep 'B_Middle_Spectrum.mat'])
                        RANGE = Spectro{3};
                        Range_Middle = Spectro{3};
                    elseif m==6
                        load([Dir{ferret}.path{sess} filesep 'PFCx_Middle_Spectrum.mat'])
                    elseif m==7
                        load([Dir{ferret}.path{sess} filesep 'H_Middle_Spectrum.mat'])
                    elseif m==8
                        load([Dir{ferret}.path{sess} filesep 'AuCx_Middle_Spectrum.mat'])
                    end
                    
                    Sptsd = tsd(Spectro{2}*1e4 , Spectro{1});
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
                        
                        Sp_ByState = Restrict(Sptsd , and(State,Epoch)-TotalNoiseEpoch);
                        if m<5
                            if states==1
                                Sp_ByState_clean = CleanSpectro(Sp_ByState , RANGE , 8);
                                Mean_Spec{ferret}{sess}{m}(states,:) = nanmean(Data(Sp_ByState_clean));
                            else
                                Mean_Spec{ferret}{sess}{m}(states,:) = nanmean(Data(Sp_ByState));
                            end
                        else
                            Mean_Spec{ferret}{sess}{m}(states,:) = nanmean(log10(Data(Sp_ByState)));
                        end
                    end
                end
            end
            clear Sptsd Sp_ByState Sp_ByState_clean
            
            disp(sess)
        end
    end
end

for ferret=1:3
    for m=1:8
        for states=1:5
            for sess=1:length(Dir{ferret}.path)
                try
                    Mean_Spec_all{ferret}{m}{states}(sess,:) = Mean_Spec{ferret}{sess}{m}(states,:);
                end
            end
            try, Mean_Spec_all{ferret}{m}{states}(Mean_Spec_all{ferret}{m}{states}==0) = NaN; end
        end
    end
end

Mean_Spec_all{ferret}{4}{1}(8,:) = NaN;
ferret=2; states=1; sess=5;
for m=1:4
    Mean_Spec_all{ferret}{m}{states}(sess,:) = NaN;
end

%% figures
Cols={[0 0 1],[1 .5 0],[1 0 0],[0 1 0]};
ferret=3;

figure
for m=1:3
    subplot(1,3,m)
    for states=1:4
        
        Data_to_use = Mean_Spec_all{ferret}{m}{states};
        Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
        h=shadedErrorBar(Range_Low , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
        color= Cols{states}; h.mainLine.Color=color; h.patch.FaceColor=color; h.edge(1).Color=color; h.edge(2).Color=color;
        
    end
    xlabel('Frequency (Hz)')
    if m==1; ylabel('Power (a.u.)'), f=get(gca,'Children'); legend([f(7),f(5),f(3),f(1)],'Wake','IS','NREM','REM'); elseif m==5, ylabel('power (log scale)'), end
    if m==1, title('OB'), end
    if m==2, title('PFC'), end
    if m==3, title('HPC'), end
    xlim([0 10])
    makepretty
end

figure, m = 5;
for states=1:4
    Data_to_use = log10(Mean_Spec_all{ferret}{m}{states});
    Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
    h=shadedErrorBar(Range_Middle , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
    color= Cols{states}; h.mainLine.Color=color; h.patch.FaceColor=color; h.edge(1).Color=color; h.edge(2).Color=color;
end
xlabel('Frequency (Hz)'), ylabel('Power (a.u.)'), xlim([20 100])
makepretty

figure
for m=5:7
    subplot(1,3,m-4)
    for states=1:4
        
        Data_to_use = log10(Mean_Spec_all{ferret}{m}{states});
        Conf_Inter=nanstd(Data_to_use)/sqrt(size(Data_to_use,1));
        h=shadedErrorBar(Range_Middle , nanmean(Data_to_use) , Conf_Inter ,'-k',1); hold on;
        color= Cols{states}; h.mainLine.Color=color; h.patch.FaceColor=color; h.edge(1).Color=color; h.edge(2).Color=color;
        
    end
    xlabel('Frequency (Hz)')
    if m==5; ylabel('Power (a.u.)'), f=get(gca,'Children'); legend([f(7),f(5),f(3),f(1)],'Wake','IS','NREM','REM'); elseif m==5, ylabel('power (log scale)'), end
    if m==5, title('OB'), end
    if m==6, title('PFC'), end
    if m==7, title('HPC'), end
    xlim([20 100])
    makepretty
end


