%Sleep Scoring Using Olfactory Bulb and Hippocampal LFP over multiple
%session files

% filename should contain list of files, B channel, Hpc channel in cell
% format
filename=cell(5,3);
% filename{1,1}='/media/DataMOBs14/ProjetAversion/Mouse117/05032014/Sleep_140305_1/Mouse_117_140305_Sleep_1/';
% filename{2,1}='/media/DataMOBs14/ProjetAversion/Mouse117/05032014/Sleep_140305_2/Mouse_117_140305_Sleep_2/';
% filename{3,1}='/media/DataMOBs14/ProjetAversion/Mouse117/05032014/Sleep_140305_3/Mouse_117_140305_Sleep_3/';
% filename{4,1}='/media/DataMOBs14/ProjetAversion/Mouse117/05032014/Sleep_140305_4/Mouse_117_140305_Sleep_4/';
% filename{5,1}='/media/DataMOBs14/ProjetAversion/Mouse117/05032014/Sleep_140305_5/Mouse_117_140305_Sleep_5/';


filename{1,1}='/media/DataMOBs14/ProjetAversion/Mouse117/06032014/Sleep_Mouse_117_140306_1/Mouse_117_140306_Sleep_1/';
filename{2,1}='/media/DataMOBs14/ProjetAversion/Mouse117/06032014/Sleep_Mouse_117_140306_2/Mouse_117_140306_Sleep_2/';
filename{3,1}='/media/DataMOBs14/ProjetAversion/Mouse117/06032014/Sleep_Mouse_117_140306_3/Mouse_117_140306_Sleep_3/';
filename{4,1}='/media/DataMOBs14/ProjetAversion/Mouse117/06032014/Sleep_Mouse_117_140306_5/Mouse_117_140306_Sleep_5/';
filename{5,1}='/media/DataMOBs14/ProjetAversion/Mouse117/06032014/Sleep_Mouse_117_140306_6/Mouse_117_140306_Sleep_6/';
    chH=5;
    chB=7;
    for file=1:size(filename,1)
if filename{file,1}(end)~='/'
    filename{file,1}(end+1)='/';
end
    end
    
mindur=3; %abs cut off for events;

%% Step 1 - get overall data
close all
% Calculate the spectra 
for file=1: size(filename,1)
        cd(filename{file,1})
    HighSpectrum(filename{file,1},chB,'B');
    disp('Bulb Spectrum done')
    LowSpectrumSB(filename{file,1},chH,'H');
    disp('Hpc spectrum done')
end

sm_ghi=[];
sm_time=[];
rat_theta=[];
rat_time=[];
smootime=3;

for file=1: size(filename,1)
    disp(strcat('file no',num2str(file)))
    cd(filename{file,1})
    load(strcat('LFPData/LFP',num2str(chH)));
    close all
    scrsz = get(0,'ScreenSize');
    r=Range(LFP);
    TotalEpoch=intervalSet(0*1e4,r(end));
    
    ThreshEpoch=TotalEpoch;

    try
        load('StateEpochSB.mat','NoiseEpoch','Epoch','GndNoiseEpoch')
        NoiseEpoch;
        Epoch;
    catch
        Epoch=FindNoiseEpoch(filename{file,1},chH)
    end
    
    try
        load('behavResources.mat','stimEpoch')
        Epoch=Epoch-stimEpoch;
        Epoch=CleanUpEpoch(Epoch);
    end
    
    try
    load('behavResources.mat','PreEpoch')
    Epoch=And(Epoch,PreEpoch);
    Epoch=CleanUpEpoch(Epoch);
    end
    
    TotalEpoch=And(TotalEpoch,Epoch);
    TotalEpoch=CleanUpEpoch(TotalEpoch);
    ThreshEpoch=And(ThreshEpoch,Epoch);
    ThreshEpoch=CleanUpEpoch(ThreshEpoch);
    smootime=3;
    load(strcat('LFPData/LFP',num2str(chB),'.mat'));
    
    
    % make gamma vector
    disp(' ');
    disp('... Creating Gamma Epochs ');
    FilGamma=FilterLFP(LFP,[50 70],1024);
    HilGamma=hilbert(Data(FilGamma));
    H=abs(HilGamma);
    tot_ghi=Restrict(tsd(Range(LFP),H),Epoch);
    smooth_ghi=tsd(Range(tot_ghi),runmean(Data(tot_ghi),smootime/median(diff(Range(tot_ghi,'s')))));
    sm_ghi=[sm_ghi;Data(Restrict(smooth_ghi,Epoch))];
    if file ==1
        sm_time=[sm_time;Range(Restrict(smooth_ghi,Epoch))];
    else
        sm_time=[sm_time;Range(Restrict(smooth_ghi,Epoch))+sm_time(end)];
    end
    
    % make theta vector
    disp(' ');
    disp('... Creating Theta Epochs ');
    load(strcat('LFPData/LFP',num2str(chH),'.mat'));
    FilTheta=FilterLFP(LFP,[5 10],1024);
    FilDelta=FilterLFP(LFP,[3 6],1024);
    HilTheta=hilbert(Data(FilTheta));
    HilDelta=hilbert(Data(FilDelta));
    H=abs(HilDelta);
    H(H<100)=100;
    ThetaRatio=abs(HilTheta)./H;
    ThetaRatioTSD=tsd(Range(FilTheta),ThetaRatio);
    smooth_Theta=tsd(Range(ThetaRatioTSD),runmean(Data(ThetaRatioTSD),smootime/median(diff(Range(ThetaRatioTSD,'s')))));
    rat_theta=[rat_theta;Data(Restrict(smooth_Theta,Epoch))];
    if file ==1
        rat_time=[rat_time;Range(Restrict(smooth_Theta,Epoch))];
    else
        rat_time=[rat_time;Range(Restrict(smooth_Theta,Epoch))+rat_time(end)];
    end
    save('StateEpochSB.mat','smooth_Theta','smooth_ghi','-append','-v7.3');
end

%% Step 2 - Theta and Gamma thresholds from Spectra
gamma_thresh=GetGammaThresh(sm_ghi);
gamma_thresh=exp(gamma_thresh);
sleepper=thresholdIntervals(tsd(sm_time,sm_ghi),gamma_thresh,'Direction','Below');
sleepper=mergeCloseIntervals(sleepper,mindur*1e4);
sleepper=dropShortIntervals(sleepper,mindur*1e4);
rat_theta1=log(Data(Restrict((tsd(rat_time,rat_theta)),sleepper)));
theta_thresh=GetThetaThresh(rat_theta1);
theta_thresh=exp(theta_thresh);

%% Step 3 - Figure
close all
undersamp=100;
h=figure;
set(h,'color',[1 1 1])
subplot(4,4,[2:4,6:8,10:12])
plot(log(sm_ghi(1:undersamp:end)),log(rat_theta(1:undersamp:end)),'.','color',[0.5 0.5 0.5],'MarkerSize',1);
axphase=gca;
ys=get(axphase,'Ylim');
xs=get(axphase,'Xlim');
box on
set(gca,'XTick',[],'YTick',[])
subplot(4,4,[1 5 9])
[theText, rawN, x] =nhist((rat_theta1),'maxx',max((rat_theta1)),'noerror','xlabel','Theta power','ylabel',[]); axis xy
view(90,-90)
line([log(theta_thresh) log(theta_thresh)],[0 max(rawN)],'linewidth',4,'color','r')
set(gca,'YTick',[],'Xlim',ys)
subplot(4,4,[14:16])
[theText, rawN, x] =nhist(log(sm_ghi),'maxx',max(log(sm_ghi)),'noerror','xlabel','Gamma power','ylabel',[]);
line([log(gamma_thresh) log(gamma_thresh)],[0 max(rawN)],'linewidth',4,'color','r')
set(gca,'YTick',[],'Xlim',xs)


%% Step 4- Theta and Gamma Epochs with threhsold
ThetaI=[3 3]; %merge and drop
mw_dur=5; %max length of microarousal
sl_dur=15; %min duration of sleep around microarousal
ms_dur=10; % max length of microsleep
wa_dur=20; %min duration of wake around microsleep

for file=1:length(filename)
    file
    cd(filename{file,1})
    load(strcat('LFPData/LFP',num2str(filename{file,2})));
    r=Range(LFP);
       TotalEpoch=intervalSet(0*1e4,r(end));
       load('StateEpochSB.mat','Epoch');
    TotalEpoch=And(TotalEpoch,Epoch);
    TotalEpoch=CleanUpEpoch(TotalEpoch);
    FindGammaEpochPreThresholded(TotalEpoch,chB,mindur,filename{file,1},gamma_thresh);
    FindThetaEpochPreThresholded(TotalEpoch,ThetaI,chH,filename{file,1},theta_thresh);
    FindBehavEpochsv2(TotalEpoch,mindur,mw_dur,sl_dur,ms_dur,wa_dur,filename{file,1})
    saveFigure(h,'SleepScoring',filename{file,1})
end


