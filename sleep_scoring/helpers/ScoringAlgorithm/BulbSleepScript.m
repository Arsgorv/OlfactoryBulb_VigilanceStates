%Sleep Scoring Using Olfactory Bulb and Hippocampal LFP

tic
%% Step 1 - channels to use and 2 spectra
close all
clear InfoLFP LFP channel

filename=cd;
if filename(end)~='/'
    filename(end+1)='/';
end
scrsz = get(0,'ScreenSize');
res=pwd;

try
    load([res,'/LFPData/InfoLFP'],'InfoLFP');
    load([res,'/LFPData/LFP',num2str(InfoLFP.channel(1))],'LFP');
catch
    load('ChannelsToAnalyse/Bulb_deep.mat','channel')
    load([res,'/LFPData/LFP',num2str(channel)],'LFP');
end
r=Range(LFP);
TotalEpoch=intervalSet(0*1e4,r(end));
mindur=3; %abs cut off for events;
ThetaI=[3 3]; %merge and drop
mw_dur=5; %max length of microarousal
sl_dur=15; %min duration of sleep around microarousal
ms_dur=10; % max length of microsleep
wa_dur=20; %min duration of wake around microsleep

WantThreshEpoch=0;
%WantThreshEpoch=input('Do you want a special Epoch for threshold finding ? y=1/n=0 ');
if WantThreshEpoch
    beginEp=input('Start time in sec');
    endEp=input('End time in sec');
    ThreshEpoch=intervalSet(beginEp*1e4,endEp*1e4);
else
    ThreshEpoch=TotalEpoch;
end

try
    load('ChannelsToAnalyse/ThetaREM.mat')
    chH=channel;
catch
    try
        load('ChannelsToAnalyse/dHPC_deep.mat')
        chH=channel;
    catch
        try
            try
                load('ChannelsToAnalyse/dHPC_rip.mat')
                chH=channel;
            catch
                load('ChannelsToAnalyse/dHPCsup.mat')
                chH=channel;
                
            end
        catch
            chH=input('please give hippocampus channel for theta ');
        end
    end
end

try
        load('ChannelsToAnalyse/Bulb_deep.mat')
    chB=channel;
catch
    chB=input('please give olfactory bulb channel ');
end

%
if not(exist('B_High_Spectrum.mat'))
    HighSpectrum(filename,chB,'B');
    disp('Bulb Spectrum done')
end
if not(exist('H_Low_Spectrum.mat'))
    LowSpectrumSB(filename,chH,'H');
    disp('Hpc spectrum done')
end

%% Step 2 - Theta and Gamma Epochs from Spectra

clear Epoch PreEpoch stimEpoch
% load('behavRessources.mat');
try
    load StateEpochSB
    Epoch;
catch
   if ~(exist('B_High_Spectrum.mat', 'file') == 2)
        HighSpectrum(filename,chB,'B');
        disp('Bulb Spectrum done')
    end
    if ~(exist('H_Low_Spectrum.mat', 'file') == 2)
        LowSpectrumSB(filename,chH,'H');
        disp('Hpc spectrum done')
    end
    Epoch=FindNoiseEpoch(filename,chH,0);
end


try
    load('behavResources.mat','PreEpoch')
    Epoch=and(Epoch,PreEpoch);
    Epoch=CleanUpEpoch(Epoch);
end
try
    load('behavResources.mat','stimEpoch')
    Epoch=Epoch-stimEpoch;
    Epoch=CleanUpEpoch(Epoch);
end
try
    load('StateEpochSB.mat', 'TotalNoiseEpoch')
    Epoch=Epoch-TotalNoiseEpoch;
end


TotalEpoch=and(TotalEpoch,Epoch);
TotalEpoch=CleanUpEpoch(TotalEpoch);
save(strcat(filename,'StateEpochSB'),'TotalEpoch','-append');
ThreshEpoch=and(ThreshEpoch,Epoch);
ThreshEpoch=CleanUpEpoch(ThreshEpoch);
close all;
FindGammaEpoch(ThreshEpoch,chB,mindur,filename);
close all;
FindThetaEpoch(ThreshEpoch,ThetaI,chH,filename);

close all;

%% Step 3 - Behavioural Epochs
FindBehavEpochs(TotalEpoch,mindur,mw_dur,sl_dur,ms_dur,wa_dur,filename)

%% Step 4 - Sleep scoring figure
%WantPlotEpoch=input('Do you want a special Epoch for plotting ? y=1/n=0 ');
WantPlotEpoch=0;
if WantPlotEpoch
    beginEp=input('Start time in sec ');
    endEp=input('End time in sec ');
    PlotEp=intervalSet(beginEp*1e4,endEp*1e4);
    PlotEp=And(PlotEp,TotalEpoch);
    PlotEp=CleanUpEpoch(PlotEp);
else
    PlotEp=intervalSet(0*1e4,r(end));
end

SleepScoreFigure(filename,PlotEp)
toc