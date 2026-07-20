


pwd = '/media/nas7/React_Passive_AG/OBG/Brynza/freely-moving/20240202_saline/';

%% EMG - OB
for l=[4 11 20 2] % EMG, OB, HPC, AuCx
    load([pwd 'LFPData/LFP' num2str(l) '.mat'])
    LFP_ferret{l} = LFP;
end
l = 11; LFP_ferret_Fil{l} = FilterLFP(LFP_ferret{l},[20 100],1024);
l = 4; LFP_ferret_Fil2{l} = FilterLFP(LFP_ferret{l},[50 300],1024);
l = 11; LFP_ferret_Fil4{l} = FilterLFP(LFP_ferret{l},[.1 100],1024);
l = 20; LFP_ferret_Fil5{l} = FilterLFP(LFP_ferret{l},[.1 100],1024);

figure
% Wake
subplot(221)
i=0;
plot(Range(LFP_ferret_Fil2{4},'s') , Data(LFP_ferret_Fil2{4})-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil5{20},'s') , Data(LFP_ferret_Fil5{20})*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil4{11},'s') , (Data(LFP_ferret_Fil4{11}))-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil{11},'s') , Data(LFP_ferret_Fil{11})-i*4.5e3 , 'k')
xlim([12586 12590]), ylim([-16e3 4e3]), axis off % xlim([12840 12844])
text(12585,0,'EMG','FontSize',15)
text(12585,-4200,'HPC','FontSize',15)
text(12585,-9000,'OB','FontSize',15)
text(12585,-13000,'OB gamma','FontSize',15)

% NREM
subplot(222)
i=0;
plot(Range(LFP_ferret_Fil2{4},'s') , Data(LFP_ferret_Fil2{4})-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil5{20},'s') , Data(LFP_ferret_Fil5{20})*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil4{11},'s') , (Data(LFP_ferret_Fil4{11}))-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil{11},'s') , Data(LFP_ferret_Fil{11})-i*4.5e3 , 'k')
xlim([9621 9625]), ylim([-16e3 4e3]), axis off 

% REM
subplot(223)
i=0;
plot(Range(LFP_ferret_Fil2{4},'s') , Data(LFP_ferret_Fil2{4})-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil5{20},'s') , Data(LFP_ferret_Fil5{20})*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil4{11},'s') , (Data(LFP_ferret_Fil4{11}))-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil{11},'s') , Data(LFP_ferret_Fil{11})-i*4.5e3 , 'k')
xlim([10003 10007]), ylim([-16e3 4e3]), axis off

% IS
subplot(224)
i=0;
plot(Range(LFP_ferret_Fil2{4},'s') , Data(LFP_ferret_Fil2{4})-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil5{20},'s') , Data(LFP_ferret_Fil5{20})*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil4{11},'s') , (Data(LFP_ferret_Fil4{11}))-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_ferret_Fil{11},'s') , Data(LFP_ferret_Fil{11})-i*4.5e3 , 'k')
xlim([8147 8151]), ylim([-16e3 4e3]), axis off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% with accelero
pwd = '/media/nas7/React_Passive_AG/OBG/Brynza/freely-moving/20240202_saline/';

l=11;
load([pwd 'LFPData/LFP' num2str(l) '.mat'])
LFP_ferret{l} = LFP;
LFP_ferret_Fil{l} = FilterLFP(LFP_ferret{l},[20 100],1024);

load([pwd 'behavResources.mat'])
Smooth_Acc = tsd(Range(MovAcctsd) , movmean(Data(MovAcctsd),10,'omitnan'));


figure
subplot(121)
bar(Range(Smooth_Acc,'s') , Data(Smooth_Acc)/1e5+200 , 'k' , 'LineWidth',1)
hold on
plot(Range(LFP_ferret_Fil{11},'s') , Data(LFP_ferret_Fil{11})+5e3 , 'k')
xlim([191.5 195.5]), axis off
text(191,1e3,'Motion','FontSize',15)
text(191,5e3,'OB','FontSize',15)
text(192.5,8e3,'Wake','FontSize',20)

subplot(122)
bar(Range(Smooth_Acc,'s') , Data(Smooth_Acc)/1e5+200 , 'k' , 'LineWidth',1)
hold on
plot(Range(LFP_ferret_Fil{11},'s') , Data(LFP_ferret_Fil{11})+5e3 , 'k')
xlim([6886 6890]), ylim([0 8e3]), axis off
text(6886+1.5,8e3,'Sleep','FontSize',20)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% all states

cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs/')


load('ChannelsToAnalyse/EMG.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
LFP_EMG = LFP;
load('ChannelsToAnalyse/Bulb_deep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
LFP_OB = LFP;
load('ChannelsToAnalyse/dHPC_deep.mat')
load(['LFPData/LFP' num2str(channel) '.mat'])
LFP_HPC = LFP;


LFP_EMG_Fil = FilterLFP(LFP_EMG,[50 300],1024);
LFP_HPC_Fil = FilterLFP(LFP_HPC,[.3 100],1024);
LFP_OB_Fil = FilterLFP(LFP_OB,[.3 100],1024);
LFP_OB_Fil2 = FilterLFP(LFP_OB,[20 100],1024);
LFP_OB_Fil3 = FilterLFP(LFP_OB,[.5 4],1024);

figure
subplot(221)
i=0;
plot(Range(LFP_EMG_Fil,'s') , Data(LFP_EMG_Fil)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_HPC_Fil,'s') , Data(LFP_HPC_Fil)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_OB_Fil,'s') , (Data(LFP_OB_Fil))-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_OB_Fil3,'s') , Data(LFP_OB_Fil3)*2-i*4.5e3 , 'k' , 'LineWidth' , 1)
i=i+1;
plot(Range(LFP_OB_Fil2,'s') , Data(LFP_OB_Fil2)*1.5-i*4.5e3-1e3 , 'k')
xlim([2.55*3600 2.55*3600+4]), ylim([-22e3 4e3]), axis off 
text(2.55*3600-1,0,'EMG','FontSize',15)
text(2.55*3600-1,-4200,'HPC','FontSize',15)
text(2.55*3600-1,-9000,'OB','FontSize',15)
text(2.55*3600-1,-13000,'OB delta','FontSize',15)
text(2.55*3600-1,-17000,'OB gamma','FontSize',15)

subplot(222)
i=0;
plot(Range(LFP_EMG_Fil,'s') , Data(LFP_EMG_Fil)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_HPC_Fil,'s') , Data(LFP_HPC_Fil)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_OB_Fil,'s') , (Data(LFP_OB_Fil))-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_OB_Fil3,'s') , Data(LFP_OB_Fil3)*2-i*4.5e3 , 'k' , 'LineWidth' , 1)
i=i+1;
plot(Range(LFP_OB_Fil2,'s') , Data(LFP_OB_Fil2)*1.5-i*4.5e3-1e3 , 'k')
xlim([2.621*3600 2.621*3600+4]), ylim([-22e3 4e3]), axis off 

subplot(223)
i=0;
plot(Range(LFP_EMG_Fil,'s') , Data(LFP_EMG_Fil)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_HPC_Fil,'s') , Data(LFP_HPC_Fil)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_OB_Fil,'s') , (Data(LFP_OB_Fil))-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_OB_Fil3,'s') , Data(LFP_OB_Fil3)*2-i*4.5e3 , 'k' , 'LineWidth' , 1)
i=i+1;
plot(Range(LFP_OB_Fil2,'s') , Data(LFP_OB_Fil2)*1.5-i*4.5e3-1e3 , 'k')
xlim([2.732*3600 2.732*3600+4]), ylim([-22e3 4e3]), axis off 

subplot(224)
i=0;
plot(Range(LFP_EMG_Fil,'s') , Data(LFP_EMG_Fil)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_HPC_Fil,'s') , Data(LFP_HPC_Fil)*2-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_OB_Fil,'s') , (Data(LFP_OB_Fil))-i*4.5e3 , 'k'), hold on
i=i+1;
plot(Range(LFP_OB_Fil3,'s') , Data(LFP_OB_Fil3)*2-i*4.5e3 , 'k' , 'LineWidth' , 1)
i=i+1;
plot(Range(LFP_OB_Fil2,'s') , Data(LFP_OB_Fil2)*1.5-i*4.5e3-1e3 , 'k')
% xlim([251*60+8 251*60+12]), ylim([-21e3 4e3]), axis off
xlim([250*60+40.5 250*60+44.5]), ylim([-22e3 4e3]), axis off


