
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                          %  MICE PART   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sleep scoring based on OB
cd('/media/nas7/ProjetEmbReact/Mouse1379/20221020/')
load('SleepScoring_OBGamma.mat', 'Epoch', 'Wake', 'Sleep' ,'SWSEpoch', 'REMEpoch', 'SmoothGamma', 'SmoothTheta')
smootime = 3;
SmoothThetam = SmoothTheta;
SmoothGammam = SmoothGamma;
Wakem = Wake;
Sleepm = Sleep;
SWSEpochm = SWSEpoch;
REMEpochm = REMEpoch;
Epochm = Epoch;


% Raw signals
for l=[6 12 21 31 18] % EMG, EKG, OBm, PFCm, HPCm
    load(['LFPData/LFP' num2str(l) '.mat'])
    LFP_mouse{l} = LFP;
end

figure
subplot(121)
i=0;
for l=[6 12 21 31 18]
    plot(Range(LFP_mouse{l},'s') , Data(LFP_mouse{l})-i*1e4 , 'k')
%     plot(Range(LFP_mouse{l},'s') , abs(hilbert(Data(FilterLFP(LFP_mouse{l},[1 500],1024))))-i*1e4 , 'k')
    hold on
    i=i+1;
end
xlim([286 288]), axis off


% EMG / OB gamma --> Wake-Sleep
load('ChannelsToAnalyse/EMG.mat', 'channel')
load(['LFPData/LFP' num2str(channel) '.mat'])

LFP = Restrict(LFP, Epoch);
FilLFP=FilterLFP(LFP,[50 300],1024);
EMGDatam=tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));

SmoothGammam = Restrict(SmoothGamma,Epoch);
SmoothGamma_intm = Restrict(SmoothGamma,EMGDatam);
SmoothGamma_int2m = Restrict(SmoothGamma,SmoothThetam);

figure
subplot(6,6,32:36)
[Y,X] = hist(log10(Data(SmoothGammam)),1000);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
box off
v1=vline(2.4,'-r'); v1.LineWidth=5;
xlabel('OB gamma power (log scale)'); xlim([2 3.1])

subplot(6,6,[25 19 13 7 1])
[Y,X] = hist(log10(Data(EMGDatam)),1000);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
set(gca,'XDir','reverse'), camroll(270), box off
v2=vline(4.5,'-r'); v2.LineWidth=5;
xlabel('EMG power (log scale)');
 
subplot(6,6,[2:6 8:12 14:18 20:24 26:30])
X = log10(Data(SmoothGamma_intm)); Y = log10(Data(EMGDatam)); 
plot(X(1:2000:end) , Y(1:2000:end) , '.k')
axis square
v1=vline(2.4,'-r'); v1.LineWidth=5;
v2=hline(4.5,'-r'); v2.LineWidth=5;
xlim([2 3.1])


% REM
figure
subplot(6,6,32:36)
[Y,X] = hist(log10(Data(SmoothGammam)),1000);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
box off
v1=vline(2.4,'-r'); v1.LineWidth=5;
xlabel('OB gamma power (log scale)');

subplot(6,6,[25 19 13 7 1])
[Y,X] = hist(log10(Data(Restrict(SmoothThetam , Sleepm))),1000);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
set(gca,'XDir','reverse'), camroll(270), box off
v2=vline(.45,'-r'); v2.LineWidth=5;
xlabel('theta / delta power (a.u.)'); 
 
subplot(6,6,[2:6 8:12 14:18 20:24 26:30])
X = log10(Data(Restrict(SmoothGamma_int2m , Wakem))); Y = log10(Data(Restrict(SmoothThetam , Wakem))); 
plot(X(1:1000:end) , Y(1:1000:end) , '.b'), hold on
X = log10(Data(Restrict(SmoothGamma_int2m , SWSEpochm))); Y = log10(Data(Restrict(SmoothThetam , SWSEpochm))); 
plot(X(1:1000:end) , Y(1:1000:end) , '.r')
X = log10(Data(Restrict(SmoothGamma_int2m , REMEpochm))); Y = log10(Data(Restrict(SmoothThetam , REMEpochm))); 
plot(X(1:1000:end) , Y(1:1000:end) , '.g')
axis square
f=get(gca,'Children'); l=legend([f([3 2 1])],'Wake','NREM','REM'); l.FontSize=20;


% Mean spectrum
for m=1:6
    if m==1
        load('B_Low_Spectrum.mat')
        RANGE = Spectro{3};
        Range_Low = Spectro{3};
    elseif m==2
        load('PFCx_Low_Spectrum.mat')
    elseif m==3
        load('H_Low_Spectrum.mat')
    elseif m==4
        load('B_Middle_Spectrum.mat')
        RANGE = Spectro{3};
        Range_Middle = Spectro{3};
    elseif m==5
        load('PFCx_Middle_Spectrum.mat')
    elseif m==6
        load('H_Middle_Spectrum.mat')
    end
    
    Sptsd_m{m} = tsd(Spectro{2}*1e4 , Spectro{1});
    for states=1:3
        if states==1
            State = Wakem;
        elseif states==2
            State = SWSEpochm;
        elseif states==3
            State = REMEpochm;
        end
        
        Sp_ByState_m{m}{states} = Restrict(Sptsd_m{m} , State);
        if m<4
%             Sp_ByState_m{m}{states} = CleanSpectro(Sp_ByState_m{m}{states} , RANGE , 8);
            Mean_Spec_m{m}(states,:) = nanmean(Data(Sp_ByState_m{m}{states}));
        else
            Mean_Spec_m{m}(states,:) = nanmean(log10(Data(Sp_ByState_m{m}{states})));
        end
    end
end
clear Sp_ByState_m Sptsd_m

Cols={'b','r','g'};
figure
for m=1:6
    subplot(2,6,m)
    for states=1:3
        if m<4
            plot(Range_Low , Mean_Spec_m{m}(states,:) , Cols{states} , 'LineWidth' , 2), hold on
        else
            plot(Range_Middle , Mean_Spec_m{m}(states,:) , Cols{states} , 'LineWidth' , 2), hold on
        end
        if m==1; legend('Wake','NREM','REM'), end
    end
end


% State analysis
edit Ferret_states_proportion.m






%% Head restraint sleep



load('H_Low_Spectrum.mat')
load('B_Middle_Spectrum.mat')




        
save('/media/nas7/React_Passive_AG/Data_Paper/Fig1.mat')











%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                          %  FERRET PART   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sleep scoring based on OB
% Raw signals
cd('/media/nas7/React_Passive_AG/OBG/Brynza/head-fixed/20240205/')
for l=[4 36 8 13 16] % EMG, EKG, OBm, PFCm, HPCm
    load(['LFPData/LFP' num2str(l) '.mat'])
    LFP_ferret{l} = LFP;
end

subplot(122)
i=0;
for l=[4 36 8 13 16]
    if l==36
        plot(Range(LFP_ferret{l},'s') , (Data(LFP_ferret{l})/3-i*4.5e3-4.5e3) , 'k')
    else
        plot(Range(LFP_ferret{l},'s') , Data(LFP_ferret{l})-i*4.5e3 , 'k')
    end
    %     plot(Range(LFP_mouse{l},'s') , abs(hilbert(Data(FilterLFP(LFP_mouse{l},[1 500],1024))))-i*1e4 , 'k')
    hold on
    i=i+1;
end
xlim([2528 2538]), axis off



% EMG / OB gamma --> Wake-Sleep
cd('/media/nas7/React_Passive_AG/OBG/Labneh/freely-moving/20230309_3')
load('SleepScoring_OBGamma.mat', 'Epoch', 'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch', 'SmoothGamma', 'SmoothTheta', 'Epoch_S1', 'Epoch_S2')
smootime = 3;

SmoothGammaf = SmoothGamma;
SmoothThetaf = SmoothTheta;
Wakef = Wake;
Sleepf = Sleep;
SWSEpochf = SWSEpoch;
REMEpochf = REMEpoch;
Epochf = Epoch;

NREM_S1 = and(SWSEpoch,Epoch_S1);
NREM_S2 = and(SWSEpoch,Epoch_S2);


load('ChannelsToAnalyse/EMG.mat', 'channel')
load(['LFPData/LFP' num2str(channel) '.mat'])

Epoch = intervalSet(0,11e7);
LFP = Restrict(LFP , Epoch);
FilLFP=FilterLFP(LFP,[50 300],1024);
EMGDataf=tsd(Range(FilLFP),runmean(Data((FilLFP)).^2,ceil(smootime/median(diff(Range(FilLFP,'s'))))));

SmoothGammaf = Restrict(SmoothGammaf , Epoch);
SmoothGamma_intf = Restrict(SmoothGammaf,EMGDataf);
SmoothGamma_int2f = Restrict(SmoothGammaf,SmoothThetaf);


figure
subplot(6,6,32:36)
[Y,X] = hist(log10(Data(SmoothGammaf)),1000);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
box off
v1=vline(2.7,'-r'); v1.LineWidth=5;
xlabel('OB gamma power (log scale)');

subplot(6,6,[25 19 13 7 1])
[Y,X] = hist(log10(Data(EMGDataf)),1000);
a = area(X , runmean(Y,10)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
set(gca,'XDir','reverse'), camroll(270), box off
v2=vline(3.5,'-r'); v2.LineWidth=5;
xlabel('EMG power (log scale)');

subplot(6,6,[2:6 8:12 14:18 20:24 26:30])
X = log10(Data(SmoothGamma_intf)); Y = log10(Data(EMGDataf)); 
plot(X(1:500:end) , Y(1:500:end) , '.k')
axis square
xlim([2.2 3.4]),% ylim([])
v1=vline(2.7,'-r'); v1.LineWidth=5;
v2=hline(3.5,'-r'); v2.LineWidth=5;



% REM
figure
subplot(6,6,32:36)
[Y,X] = hist(log10(Data(Restrict(SmoothGammaf, Epoch))),1000);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
ylim([0 2.5e4]), box off
v1=vline(2.7,'-r'); v1.LineWidth=5;
xlabel('OB gamma power (log scale)');

subplot(6,6,[25 19 13 7 1])
[Y,X] = hist(log10(Data(Restrict(SmoothThetaf , and(Sleepf , Epoch)))),1000);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
xlabel('theta / delta power (a.u.)'), xlim([-.5 .85])
set(gca,'XDir','reverse'), camroll(270), box off
v2=vline(.318,'-r'); v2.LineWidth=5;
 
subplot(6,6,[2:6 8:12 14:18 20:24 26:30])
TSD = Restrict(SmoothGamma_int2f , and(Wakef , Epoch));
X = log10(Data(TSD)); Y = log10(Data(Restrict(Restrict(SmoothThetaf,TSD) , and(Wakef , Epoch)))); 
plot(X(1:1000:end) , Y(1:1000:end) , '.b'), hold on
TSD = Restrict(SmoothGamma_int2f , and(SWSEpochf , Epoch));
X = log10(Data(TSD)); Y = log10(Data(Restrict(Restrict(SmoothThetaf,TSD) , and(SWSEpochf , Epoch)))); 
plot(X(1:1000:end) , Y(1:1000:end) , '.r')
TSD = Restrict(SmoothGamma_int2f , and(REMEpochf , Epoch));
X = log10(Data(TSD)); Y = log10(Data(Restrict(Restrict(SmoothThetaf,TSD) , and(REMEpochf , Epoch)))); 
plot(X(1:1000:end) , Y(1:1000:end) , '.g')
axis square
f=get(gca,'Children'); l=legend([f([3 2 1])],'Wake','NREM','REM'); 



% Mean spectrum
cd('/media/nas7/React_Passive_AG/OBG/Brynza/freely-moving/20240202_saline')
load('SleepScoring_OBGamma.mat', 'Epoch', 'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch', 'SmoothGamma',...
    'SmoothTheta', 'Epoch_S1', 'Epoch_S2', 'TotalNoiseEpoch')
smootime = 3;

SmoothGammaf = SmoothGamma;
SmoothThetaf = SmoothTheta;
Wakef = Wake;
Sleepf = Sleep;
SWSEpochf = SWSEpoch;
REMEpochf = REMEpoch;
Epochf = Epoch;

NREM_S1 = and(SWSEpoch,Epoch_S1);
NREM_S2 = and(SWSEpoch,Epoch_S2);

for m=1:6
    if m==1
        load('B_Low_Spectrum.mat')
        RANGE = Spectro{3};
        Range_Low = Spectro{3};
    elseif m==2
        load('PFCx_Low_Spectrum.mat')
    elseif m==3
        load('H_Low_Spectrum.mat')
    elseif m==4
        load('B_Middle_Spectrum.mat')
        RANGE = Spectro{3};
        Range_Middle = Spectro{3};
    elseif m==5
        load('PFCx_Middle_Spectrum.mat')
    elseif m==6
        load('H_Middle_Spectrum.mat')
    end
    
    Sptsd_f{m} = tsd(Spectro{2}*1e4 , Spectro{1});
    for states=1:3
        if states==1
            State = Wakef;
        elseif states==2
            State = SWSEpochf;
        elseif states==3
            State = REMEpochf;
        end
        
        Sp_ByState_f{m}{states} = Restrict(Sptsd_f{m} , and(State,Epoch)-TotalNoiseEpoch);
        if m<4
%             Sp_ByState_f{m}{states} = CleanSpectro(Sp_ByState_f{m}{states} , RANGE , 2);
            Mean_Spec_f{m}(states,:) = nanmean(Data(Sp_ByState_f{m}{states}));
        else
            Mean_Spec_f{m}(states,:) = nanmean(log10(Data(Sp_ByState_f{m}{states})));
        end
    end
end
clear Sp_ByState_f Sptsd_f

Cols={'b','r','g'};
for m=1:6
    subplot(2,6,m+6)
    for states=1:3
        if m<4
            %             plot(Range_Low , Mean_Spec_f{m}(states,:) , Cols{states} , 'LineWidth' , 2), hold on, box off
            plot(Range_Low , runmean(Mean_Spec_f{m}(states,:),5) , Cols{states} , 'LineWidth' , 2), hold on, box off
        else
            plot(Range_Middle , Mean_Spec_f{m}(states,:) , Cols{states} , 'LineWidth' , 2), hold on, box off
        end
        xlabel('Frequency (Hz)')
        if m==1; ylabel('Power (a.u.)'), elseif m==4, ylabel('power (log scale)'), end
    end
end

%% DLC-related processing
Ferret_Eye_Movement_BM

%% Unsorted
load('StateEpochSB.mat', 'Epoch', 'TotalNoiseEpoch', 'ThetaI', 'Wake', 'Sleep', 'smooth_ghi', 'gamma_thresh')
% save('StateEpochBM.mat', 'Epoch', 'TotalNoiseEpoch', 'ThetaI', 'Wake', 'Sleep', 'smooth_ghi', 'gamma_thresh')

FindThetaEpoch_Ferret_BM(Epoch,ThetaI,1,[pwd filesep])

load('StateEpochBM.matWake', 'ThetaEpoch','theta_thresh')
REMEpoch = and(Sleep,ThetaEpoch);
SWSEpoch = and(Sleep,Sleep-ThetaEpoch);

Info.theta_thresh = theta_thresh;
Info.gamma_thresh = gamma_thresh;

save('StateEpochBM.mat', 'REMEpoch' , 'SWSEpoch' , 'Info' , '-append')

%
clear all
Figure_SleepScoring_OB_Ferret_BM


%%
HeadRestraintSess{1} = '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230113_1/';
HeadRestraintSess{2} = '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230118/';
HeadRestraintSess{3} = '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230121/';
HeadRestraintSess{4} = '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230208/';
HeadRestraintSess{5} = '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230303/';
HeadRestraintSess{6} = '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230323/';
HeadRestraintSess{7} = '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230419/';
HeadRestraintSess{8} = '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230508_1/';
HeadRestraintSess{9} = '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230508_2/';
HeadRestraintSess{10} = '/media/nas7/React_Passive_AG/OBG/Labneh/head-fixed/20230508_3/';


FreelyMovingSess{1} = '/media/nas7/React_Passive_AG/OBG/Labneh/freely-moving/20221221_long/';
FreelyMovingSess{2} = '/media/nas7/React_Passive_AG/OBG/Labneh/freely-moving/20230302_saline/';
FreelyMovingSess{3} = '/media/nas7/React_Passive_AG/OBG/Labneh/freely-moving/20230320_atropine/';


figure
for sess=1:10
    cd(HeadRestraintSess{sess})
    clear smooth_ghi smooth_01_05 Sleep
    load('StateEpochSB.mat', 'smooth_ghi', 'smooth_01_05','Sleep')
    
    Gamma{sess}=smooth_ghi;
    Smooth_1_5{sess}=smooth_01_05;
    Sleep_ep{sess}=Sleep;
end


for sess=1:3
    cd(FreelyMovingSess{sess})
    clear smooth_ghi smooth_01_05 Sleep
    load('StateEpochSB.mat', 'smooth_ghi', 'smooth_01_05','Sleep')
    
    Gamma2{sess}=smooth_ghi;
    Smooth_1_52{sess}=smooth_01_05;
    Sleep_ep2{sess}=Sleep;
end

figure
for sess=[2 3]
    subplot(221)
    [Y,X]=hist(log10(Data(Gamma2{sess})),1000);
    Y=Y/sum(Y);
    plot(X,runmean(Y,3))
    hold on
    
    subplot(222)
    [Y,X]=hist(log10(Data(Restrict(Smooth_1_52{sess} , Sleep_ep2{sess}))),1000);
    Y=Y/sum(Y);
    plot(X,runmean(Y,3))
    hold on
end


for sess=[3 6 7 8]
    subplot(223)
    [Y,X]=hist(log10(Data(Gamma{sess})),1000);
    Y=Y/sum(Y);
    plot(X,runmean(Y,3))
    hold on
    
    subplot(224)
    [Y,X]=hist(log10(Data(Restrict(Smooth_1_5{sess} , Sleep_ep{sess}))),1000);
    Y=Y/sum(Y);
    plot(X,runmean(Y,3))
    hold on
end

xlim([2.1 3.3]), xlim([1.3 3])




