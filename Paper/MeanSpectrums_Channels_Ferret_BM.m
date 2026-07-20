
function MeanSpectrums_Channels_Ferret_BM


load('SleepScoring_OBGamma.mat', 'Wake', 'SWSEpoch', 'REMEpoch', 'Epoch')
cd('Spectrograms')

i=1;
for channel=8:11
    
    load(['B_UltraLow_Spectrum_' num2str(channel) '.mat'])
    OB_ULow_Sp_tsd{i} = tsd(Spectro{2}*1e4 , Spectro{1});
    range_ULow = Spectro{3};
    load(['B_Low_Spectrum_' num2str(channel) '.mat'])
    OB_Low_Sp_tsd{i} = tsd(Spectro{2}*1e4 , Spectro{1});
    range_Low = Spectro{3};
    load(['B_Middle_Spectrum_' num2str(channel) '.mat'])
    OB_Middle_Sp_tsd{i} = tsd(Spectro{2}*1e4 , Spectro{1});
    range_Middle = Spectro{3};
    
    OB.ULow.Wake{i} = Restrict(OB_ULow_Sp_tsd{i} , and(Wake , Epoch));
    OB.Low.Wake{i} = Restrict(OB_Low_Sp_tsd{i} , and(Wake , Epoch));
    OB.Middle.Wake{i} = Restrict(OB_Middle_Sp_tsd{i} , and(Wake , Epoch));
    
    OB.ULow.SWS{i} = Restrict(OB_ULow_Sp_tsd{i} , and(SWSEpoch , Epoch));
    OB.Low.SWS{i} = Restrict(OB_Low_Sp_tsd{i} , and(SWSEpoch , Epoch));
    OB.Middle.SWS{i} = Restrict(OB_Middle_Sp_tsd{i} , and(SWSEpoch , Epoch));
    
    OB.ULow.REM{i} = Restrict(OB_ULow_Sp_tsd{i} , and(REMEpoch , Epoch));
    OB.Low.REM{i} = Restrict(OB_Low_Sp_tsd{i} , and(REMEpoch , Epoch));
    OB.Middle.REM{i} = Restrict(OB_Middle_Sp_tsd{i} , and(REMEpoch , Epoch));
    
    i=i+1;
end


Freq={'ULow','Low','Middle'};
States={'Wake','SWS','REM'};

figure
for freq=1:3
    if freq==1
        RANGE = range_ULow;
    elseif freq==2
        RANGE = range_Low;
    elseif freq==3
        RANGE = range_Middle;
    end
    
    for states=1:3
        
        subplot(3,3,states+(freq-1)*3)
        for chan=1:4
            if states==1
                COL = [0+chan*0.2 0+chan*0.2 1];
            elseif states==2
                COL = [1 0+chan*0.2 0+chan*0.2];
            elseif states==3
                COL = [0+chan*0.2 1 0+chan*0.2];
            end
            
            plot(RANGE , nanmean(Data(OB.(Freq{freq}).(States{states}){chan})) , 'Color' , COL); hold on
        end
        makepretty
%         set(gca,'YScale','log')
        if freq==1, title(States{states}), elseif freq==3, xlim([20 100]), end
        if states==1, ylabel(['OB ' Freq{freq}]), end
        if and(freq==1 , states==1), legend('Depth1','Depth2','Depth3','Depth4'), end
    end
end  

a=sgtitle('Mean spectrums for all LFP wires in OB, sleep session, Labneh'); a.FontSize=20;

