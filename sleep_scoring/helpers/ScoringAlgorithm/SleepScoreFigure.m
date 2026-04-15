function SleepScoreFigure(directory,PlotEp)

try
    directory;
catch
    directory=[pwd,'/'];
end

try 
    PlotEp;
catch
    filelist = dir(strcat(directory,'ChannelsToAnalyse'));
    channel_name = filelist(3).name;
    eval(['load ChannelsToAnalyse/' channel_name])
    eval(['load LFPData/LFP',num2str(channel)])
    PlotEp = intervalSet(0,max(Range(LFP)));
end

try
    load(strcat(directory,'StateEpochSB'))
catch
    load(strcat(directory,'SleepScoring_OBGamma'))
end

try
load(strcat(directory,'B_High_Spectrum.mat'));
sptsdB=tsd(Spectro{2}*1e4,Spectro{1});sptsdB=Restrict(sptsdB,PlotEp);
fB=Spectro{3};
end
clear Spectro
load(strcat(directory,'H_Low_Spectrum.mat'))
sptsdH=tsd(Spectro{2}*1e4,Spectro{1});sptsdH=Restrict(sptsdH,PlotEp);
fH=Spectro{3};
clear Spectro

try
    ghi_new=Restrict(smooth_ghi,PlotEp);
    theta_new=Restrict(smooth_Theta,PlotEp);
catch
    ghi_new=smooth_ghi;
    theta_new=smooth_Theta;   
end


%need to think about this
t=Range(theta_new);
ti=t(5:1200:end);
ghi_new=(Restrict(ghi_new,ts(ti)));
theta_new=(Restrict(theta_new,ts(ti)));

try
begin=Start(PlotEp)/1e4;
begin=begin(1);
endin=Stop(PlotEp)/1e4;
endin=endin(end);
catch
    begin=t(1)/1e4;
    endin=t(end)/1e4;
end



h=figure;

% HPC spectrum
set(h,'color',[1 1 1],'Position',[1 1 1600 600])
subplot(6,3,[1:2,4:5])
imagesc(Range(sptsdH,'s'),fH,10*log10(Data(sptsdH))'), axis xy, %caxis([20 65]);
hold on
line([begin endin],[19 19],'linewidth',10,'color','w')
sleepstart=Start(REMEpoch);
sleepstop=Stop(REMEpoch);
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],[19 19],'color',[1 0.2 0.2],'linewidth',5);
end
sleepstart=Start(SWSEpoch);
sleepstop=Stop(SWSEpoch);
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],[19 19],'color',[0.4 0.5 1],'linewidth',5);
end
sleepstart=Start(Wake);
sleepstop=Stop(Wake);
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],[19 19],'color',[0.6 0.6 0.6],'linewidth',5);
end


 % modif KB----------------------------------------------------------------------------
 % ------------------------------------------------------------------------------------
     
try
sleepstart=Start(TotalNoiseEpoch);
sleepstop=Stop(TotalNoiseEpoch);
catch
sleepstart=Start(GndNoiseEpoch);
sleepstop=Stop(GndNoiseEpoch);
end

 % modif KB----------------------------------------------------------------------------
 % ------------------------------------------------------------------------------------
     
 
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],[19 19],'color','w','linewidth',5);
end
xlim([begin endin])
set(gca,'XTick',[])
subplot(6,3,[7:8])
try
plot(Range(Restrict(theta_new,PlotEp),'s'),Data(Restrict(theta_new,PlotEp)),'linewidth',1,'color','k')
catch
plot(Range(theta_new,'s'),Data(theta_new),'linewidth',1,'color','k')    
end
xlim([begin endin])

% OB spectrum
subplot(6,3,[10:11,13:14])
try
datb=Data(sptsdB);
for k=1:size(datb,2)
    datbnew(:,k)=runmean(datb(:,k),100);
end
imagesc(Range(sptsdB,'s'),fB,10*log10(datbnew')), axis xy, %caxis([25 50]);
hold on
line([begin endin],[90 90],'linewidth',10,'color','w')
sleepstart=Start(REMEpoch);
sleepstop=Stop(REMEpoch);
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],[90 90],'color',[1 0.2 0.2],'linewidth',5);
end
sleepstart=Start(SWSEpoch);
sleepstop=Stop(SWSEpoch);
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],[90 90],'color',[0.4 0.5 1],'linewidth',5);
end
sleepstart=Start(Wake);
sleepstop=Stop(Wake);
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],[90 90],'color',[0.6 0.6 0.6],'linewidth',5);
end
catch
   title('No High OB spectrum') 
end
 % modif KB----------------------------------------------------------------------------
 % ------------------------------------------------------------------------------------
     
try
sleepstart=Start(TotalNoiseEpoch);
sleepstop=Stop(TotalNoiseEpoch);
catch
sleepstart=Start(GndNoiseEpoch);
sleepstop=Stop(GndNoiseEpoch);
end

 % modif KB----------------------------------------------------------------------------
 % ------------------------------------------------------------------------------------
 
for k=1:length(sleepstart)
    line([sleepstart(k)/1e4 sleepstop(k)/1e4],[90 90],'color','w','linewidth',5);
end
xlim([begin endin])
set(gca,'XTick',[])
subplot(6,3,[16:17])
try
plot(Range(Restrict(ghi_new,PlotEp),'s'),Data(Restrict(ghi_new,PlotEp)),'linewidth',1,'color','k')
catch
 plot(Range(ghi_new,'s'),Data(ghi_new),'linewidth',1,'color','k')   
end
xlim([begin endin])
clear sptsdH sptsdH datB

% phase space
subplot(6,12,[22:24,34:36,46:48])
try
remtheta=(Restrict(theta_new,And(PlotEp,REMEpoch)));
catch
    remtheta=(Restrict(theta_new,REMEpoch));
end
ghi_new_r=Restrict(ghi_new,ts(Range(remtheta)));
plot(log(Data(ghi_new_r)),log(Data(remtheta)),'.','color',[1 0.2 0.2],'MarkerSize',1);
hold on
try
sleeptheta=(Restrict(theta_new,And(PlotEp,SWSEpoch)));
catch
    sleeptheta=(Restrict(theta_new,SWSEpoch));
end
ghi_new_s=Restrict(ghi_new,ts(Range(sleeptheta)));
plot(log(Data(ghi_new_s)),log(Data(sleeptheta)),'.','color',[0.4 0.5 1],'MarkerSize',1);
waketheta=(Restrict(theta_new,Wake));
ghi_new_w=Restrict(ghi_new,ts(Range(waketheta)));
plot(log(Data(ghi_new_w)),log(Data(waketheta)),'.','color',[0.6 0.6 0.6],'MarkerSize',1);
% had to change the code to accomodate new functions in Matlab 2016 - SB
% 09/2016

try
    legend('REM','SWS','Wake')
    l=findobj(gcf,'tag','legend');
    a=get(l,'children');
    try
        set(a(1),'markersize',20); % This line changes the legend marker size
        set(a(4),'markersize',20); % This line changes the legend marker size
        set(a(7),'markersize',20); % This line changes the legend marker size
    catch
        set(a(5),'markersize',20); % This line changes the legend marker size
        set(a(8),'markersize',20); % This line changes the legend marker size
        set(a(11),'markersize',20); % This line changes the legend marker size
    end
catch
    [a,icons,plots,legend_text]=legend('REM','SWS','Wake');
    set(icons(5),'MarkerSize',20)
    set(icons(7),'MarkerSize',20)
    set(icons(9),'MarkerSize',20)
end
axphase=gca;
ys=get(axphase,'Ylim');
xs=get(axphase,'Xlim');
box on
set(gca,'XTick',[],'YTick',[])
subplot(6,12,[21,33,45])
[theText, rawN, x] =nhist(log(Data(Restrict(smooth_Theta,sleepper))),'maxx',max(log(Data(Restrict(smooth_Theta,sleepper)))),'noerror','xlabel','Theta power','ylabel',[]); axis xy
view(90,-90)
line([log(theta_thresh) log(theta_thresh)],[0 max(rawN)],'linewidth',4,'color','r')
set(gca,'YTick',[],'Xlim',ys)

subplot(6,12,[58:60])
[theText, rawN, x] =nhist(log(Data(smooth_ghi)),'maxx',max(log(Data(smooth_ghi))),'noerror','xlabel','Gamma power','ylabel',[]);
line([log(gamma_thresh) log(gamma_thresh)],[0 max(rawN)],'linewidth',4,'color','r')
set(gca,'YTick',[],'Xlim',xs)
try
saveFigure(h,'SleepScoring',directory)
catch
saveFigure(h.Number,'SleepScoring',directory)
end

[aft_cell,bef_cell]=transEpoch(wakeper,REMEpoch);

disp( ' ')
disp(strcat('wake to REM transitions :',num2str(size(Start(aft_cell{1,2}),1))))
disp( ' ')

end