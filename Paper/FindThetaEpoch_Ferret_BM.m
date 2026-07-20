function FindThetaEpoch_Ferret_BM(Epoch,ThetaI,chH,filename)

smootime=3;
load(strcat('LFPData/LFP',num2str(chH),'.mat'));

LFP = Restrict(LFP,Epoch); % added by BM on 01/09/2022

load('StateEpochSB.mat','Sleep')

% find theta epochs

disp(' ')
disp('... Creating Theta Epochs ')

FilDelta=FilterLFP(LFP,[.1 2],1024);
FilTheta=FilterLFP(LFP,[3 6],1024);
% FilSupTheta=FilterLFP(LFP,[6 12],1024);

HilDelta=hilbert(Data(FilDelta));
HilTheta=hilbert(Data(FilTheta));
% HilSupTheta=hilbert(Data(FilSupTheta));

H1=abs(HilDelta); %H1(H1>200)=200;
H2=abs(HilTheta); %H2(H2>200)=200;
% H3=abs(HilSupTheta); %H2(H2>200)=200;

ThetaRatio=H2./H1;
% ThetaRatio=H2./(H1+H3);
ThetaRatioTSD=tsd(Range(FilTheta),ThetaRatio);
smooth_Theta=tsd(Range(ThetaRatioTSD),runmean(Data(ThetaRatioTSD),ceil(smootime/median(diff(Range(ThetaRatioTSD,'s'))))));

rat_theta= Data(Restrict((smooth_Theta),Sleep));

theta_thresh=GetThetaThresh(rat_theta);
% theta_thresh=exp(theta_thresh); BM on 22/01/2024
ThetaEpoch=thresholdIntervals(smooth_Theta,theta_thresh,'Direction','Above');
ThetaEpoch=mergeCloseIntervals(ThetaEpoch,ThetaI(1)*1E4);
ThetaEpoch=dropShortIntervals(ThetaEpoch,ThetaI(2)*1E4);


save(strcat(filename,'StateEpochBM'),'ThetaEpoch','chH', 'smooth_Theta','ThetaRatioTSD','ThetaI','theta_thresh','-v7.3','-append');


end