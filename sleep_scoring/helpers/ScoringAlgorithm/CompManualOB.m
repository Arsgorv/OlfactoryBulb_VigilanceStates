%% Compare Manual and OB Sleep Scoring
clear all
Filename{1}='/media/DataMOBSSlSc/SleepScoringMice/M147/';
Filename{2}='/media/DataMOBSSlSc/SleepScoringMice/M177178/M177178-Sleep-22102014/M177/';
Filename{3}='/media/DataMOBSSlSc/SleepScoringMice/M148/20140828/';
Filename{4}='/media/DataMOBSSlSc/SleepScoringMice/M177178/M177178-Sleep-22102014/M178/';
WindowSizes=[5,10];
for mm=1:4
    mm
    cd(Filename{mm})
    load('StateEpochSB.mat','REMEpoch','SWSEpoch','Wake','sleepper','smooth_ghi','Epoch')
    REMEpoch1= REMEpoch;
    SWSEpoch1=SWSEpoch;
    Wake1= Wake;
    load('SleepScoringManualSB.mat','REMEpoch','SWSEpoch','Wake')
    sleepper1= sleepper;
    REMEpoch=And(REMEpoch,Epoch);
    SWSEpoch=And(SWSEpoch,Epoch);
    Wake=And(Wake,Epoch);
    
    channel=load('ChannelsToAnalyse/EMG.mat'); channel=channel.channel;
    load(strcat('LFPData/LFP',num2str(channel),'.mat'));
    for Win=1:2
        Winsize=WindowSizes(Win); % seconds
        Totlong=length(Data(Restrict(LFP,intervalset(((1-1)*Winsize)*1e4,1*Winsize*1e4))));
        clear SZSWS SZREM SZWK SZNois SZSWS1 SZREM1 SZWK1
        for ww=1:max(Range(LFP,'s'))/Winsize
            SZSWS(ww)=length(Data(Restrict(LFP,And(SWSEpoch,intervalset(((ww-1)*Winsize)*1e4,ww*Winsize*1e4)))));
            SZREM(ww)=length(Data(Restrict(LFP,And(REMEpoch,intervalset(((ww-1)*Winsize)*1e4,ww*Winsize*1e4)))));
            SZWK(ww)=length(Data(Restrict(LFP,And(Wake,intervalset(((ww-1)*Winsize)*1e4,ww*Winsize*1e4)))));
            SZNois(ww)=length(Data(Restrict(LFP,And(Epoch,intervalset(((ww-1)*Winsize)*1e4,ww*Winsize*1e4)))));
            SZSWS1(ww)=length(Data(Restrict(LFP,And(SWSEpoch1,intervalset(((ww-1)*Winsize)*1e4,ww*Winsize*1e4)))));
            SZREM1(ww)=length(Data(Restrict(LFP,And(REMEpoch1,intervalset(((ww-1)*Winsize)*1e4,ww*Winsize*1e4)))));
            SZWK1(ww)=length(Data(Restrict(LFP,And(Wake1,intervalset(((ww-1)*Winsize)*1e4,ww*Winsize*1e4)))));
        end
        SZSWS(SZNois<3*Totlong/4)=[];
        SZREM(SZNois<3*Totlong/4)=[];
        SZWK(SZNois<3*Totlong/4)=[];
        SZSWS1(SZNois<3*Totlong/4)=[];
        SZREM1(SZNois<3*Totlong/4)=[];
        SZWK1(SZNois<3*Totlong/4)=[];
        
        [C,I]=max([SZSWS;SZREM;SZWK]);
        [C,I1]=max([SZSWS1;SZREM1;SZWK1]);
        Comp{mm,Win}(1)=sum(I(find(I1==1))==1)/length(find(I1==1)); %SWS,SWS
        Comp{mm,Win}(2)=sum(I(find(I1==1))==2)/length(find(I1==1)); %SWS,REM
        Comp{mm,Win}(3)=sum(I(find(I1==1))==3)/length(find(I1==1)); %SWS,Wake
        Comp{mm,Win}(4)=sum(I(find(I1==2))==1)/length(find(I1==2)); % Rem, SWS
        Comp{mm,Win}(5)=sum(I(find(I1==2))==2)/length(find(I1==2)); %Rem, Rem
        Comp{mm,Win}(6)=sum(I(find(I1==2))==3)/length(find(I1==2)); %rem,Wake
        Comp{mm,Win}(7)=sum(I(find(I1==3))==1)/length(find(I1==3)); % wake, SWS
        Comp{mm,Win}(8)=sum(I(find(I1==3))==2)/length(find(I1==3)); %wake, Rem
        Comp{mm,Win}(9)=sum(I(find(I1==3))==3)/length(find(I1==3)); %wake,Wake

        Comp{mm,Win}(1+9)=sum(I1(find(I==1))==1)/length(find(I==1)); %SWS,SWS
        Comp{mm,Win}(2+9)=sum(I1(find(I==1))==2)/length(find(I==1)); %SWS,REM
        Comp{mm,Win}(3+9)=sum(I1(find(I==1))==3)/length(find(I==1)); %SWS,Wake
        Comp{mm,Win}(4+9)=sum(I1(find(I==2))==1)/length(find(I==2)); % Rem, SWS
        Comp{mm,Win}(5+9)=sum(I1(find(I==2))==2)/length(find(I==2)); %Rem, Rem
        Comp{mm,Win}(6+9)=sum(I1(find(I==2))==3)/length(find(I==2)); %rem,Wake
        Comp{mm,Win}(7+9)=sum(I1(find(I==3))==1)/length(find(I==3)); % wake, SWS
        Comp{mm,Win}(8+9)=sum(I1(find(I==3))==2)/length(find(I==3)); %wake, Rem
        Comp{mm,Win}(9+9)=sum(I1(find(I==3))==3)/length(find(I==3)); %wake,Wake
        
    end
    
end
Win1Vals=[Comp{:,1}];Win1Vals=reshape(Win1Vals,18,4);
Win2Vals=[Comp{:,2}];Win2Vals=reshape(Win2Vals,18,4);

figure,
SWSprop=[mean(mean(Win1Vals(1,:))),mean([mean(Win1Vals(2,:))]),...
    mean([mean(Win1Vals(3,:))])];
REMprop=[mean([mean(Win1Vals(4,:))]),mean([mean(Win1Vals(5,:))]),...
    mean([mean(Win1Vals(6,:))])];
Wakeprop=[mean([mean(Win1Vals(7,:))]),mean([mean(Win1Vals(8,:))]),...
    mean([mean(Win1Vals(9,:))])];
g=bar([1:3],[SWSprop;REMprop;Wakeprop],'Stack'); hold on
colormap([[0.4 0.5 1];[1 0.2 0.2];[0.6 0.6 0.6]])
set(gca,'XTick',[1:3],'XTickLabel',{'SWS','REM','Wake'},'FontSize',18,'FontWeight','B')
xlim([0.5 3.5])
ylim([0 1.1])
box off
% 
% figure,
% subplot(121)
% SWSprop=[mean([mean(Win1Vals(1,:)),mean(Win1Vals(1+9,:))]),mean([mean(Win1Vals(2,:)),mean(Win1Vals(2+9,:))]),...
%     mean([mean(Win1Vals(3,:)),mean(Win1Vals(3+9,:))])];
% REMprop=[mean([mean(Win1Vals(4,:)),mean(Win1Vals(4+9,:))]),mean([mean(Win1Vals(5,:)),mean(Win1Vals(5+9,:))]),...
%     mean([mean(Win1Vals(6,:)),mean(Win1Vals(6+9,:))])];
% Wakeprop=[mean([mean(Win1Vals(7,:)),mean(Win1Vals(7+9,:))]),mean([mean(Win1Vals(8,:)),mean(Win1Vals(8+9,:))]),...
%     mean([mean(Win1Vals(9,:)),mean(Win1Vals(9+9,:))])];
% g=bar([1:3],[SWSprop;REMprop;Wakeprop],'Stack'); hold on
% colormap([[0.4 0.5 1];[1 0.2 0.2];[0.6 0.6 0.6]])
% set(gca,'XTick',[1:3],'XTickLabel',{'SWS','REM','Wake'},'FontSize',18,'FontWeight','B')
% xlim([0.5 3.5])
% ylim([0 1.1])
% box off
% subplot(122)
% SWSprop=[mean([mean(Win2Vals(1,:)),mean(Win2Vals(1+9,:))]),mean([mean(Win2Vals(2,:)),mean(Win2Vals(2+9,:))]),...
%     mean([mean(Win2Vals(3,:)),mean(Win2Vals(3+9,:))])];
% REMprop=[mean([mean(Win2Vals(4,:)),mean(Win2Vals(4+9,:))]),mean([mean(Win2Vals(5,:)),mean(Win2Vals(5+9,:))]),...
%     mean([mean(Win2Vals(6,:)),mean(Win2Vals(6+9,:))])];
% Wakeprop=[mean([mean(Win2Vals(7,:)),mean(Win2Vals(7+9,:))]),mean([mean(Win2Vals(8,:)),mean(Win2Vals(8+9,:))]),...
%     mean([mean(Win2Vals(9,:)),mean(Win2Vals(9+9,:))])];
% g=bar([1:3],[SWSprop;REMprop;Wakeprop],'Stack'); hold on
% colormap([[0.4 0.5 1];[1 0.2 0.2];[0.6 0.6 0.6]])
% set(gca,'XTick',[1:3],'XTickLabel',{'SWS','REM','Wake'},'FontSize',18,'FontWeight','B')
% xlim([0.5 3.5])
% ylim([0 1.1])
% box off
% 
% 
% % MaxEMG=20;
% % line([0 max(Range(LFP,'s'))],[MaxEMG*0.8 MaxEMG*0.8],'linewidth',10,'color','w')
% % sleepstart=Start(REMEpoch);
% % sleepstop=Stop(REMEpoch);
% % for k=1:length(sleepstart)
% %     line([sleepstart(k)/1e4 sleepstop(k)/1e4],[MaxEMG*0.8 MaxEMG*0.8],'color',[1 0.2 0.2],'linewidth',5);
% % end
% % sleepstart=Start(SWSEpoch);
% % sleepstop=Stop(SWSEpoch);
% % for k=1:length(sleepstart)
% %     line([sleepstart(k)/1e4 sleepstop(k)/1e4],[MaxEMG*0.8 MaxEMG*0.8],'color',[0.4 0.5 1],'linewidth',5);
% % end
% % sleepstart=Start(Wake);
% % sleepstop=Stop(Wake);
% % for k=1:length(sleepstart)
% %     line([sleepstart(k)/1e4 sleepstop(k)/1e4],[MaxEMG*0.8 MaxEMG*0.8],'color',[0.6 0.6 0.6],'linewidth',5);
% % end
% % MaxEMG=22;
% % line([0 max(Range(LFP,'s'))],[MaxEMG*0.8 MaxEMG*0.8],'linewidth',10,'color','w')
% % sleepstart=Start(REMEpoch1);
% % sleepstop=Stop(REMEpoch1);
% % for k=1:length(sleepstart)
% %     line([sleepstart(k)/1e4 sleepstop(k)/1e4],[MaxEMG*0.8 MaxEMG*0.8],'color',[1 0.2 0.2],'linewidth',5);
% % end
% % sleepstart=Start(SWSEpoch1);
% % sleepstop=Stop(SWSEpoch1);
% % for k=1:length(sleepstart)
% %     line([sleepstart(k)/1e4 sleepstop(k)/1e4],[MaxEMG*0.8 MaxEMG*0.8],'color',[0.4 0.5 1],'linewidth',5);
% % end
% % sleepstart=Start(Wake1);
% % sleepstop=Stop(Wake1);
% % for k=1:length(sleepstart)
% %     line([sleepstart(k)/1e4 sleepstop(k)/1e4],[MaxEMG*0.8 MaxEMG*0.8],'color',[0.6 0.6 0.6],'linewidth',5);
% % end
% % ylim([12 20])
