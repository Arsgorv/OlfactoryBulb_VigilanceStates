function FindThetaEpoch(Epoch,ThetaI,chH,filename)

smootime=3;
load(strcat('LFPData/LFP',num2str(chH),'.mat'));

LFP = Restrict(LFP,Epoch); % added by BM on 01/09/2022

load('StateEpochSB.mat','sleepper')

% find theta epochs

disp(' ');
disp('... Creating Theta Epochs ');
FilTheta=FilterLFP(LFP,[5 10],1024);

FilDelta=FilterLFP(LFP,[2 5],1024);

HilTheta=hilbert(Data(FilTheta));
HilDelta=hilbert(Data(FilDelta));
H=abs(HilDelta);
H(H<100)=100;
ThetaRatio=abs(HilTheta)./H;
ThetaRatioTSD=tsd(Range(FilTheta),ThetaRatio);
smooth_Theta=tsd(Range(ThetaRatioTSD),runmean(Data(ThetaRatioTSD),ceil(smootime/median(diff(Range(ThetaRatioTSD,'s'))))));

rat_theta=log(Data(Restrict((smooth_Theta),sleepper)));

theta_thresh=GetThetaThresh(rat_theta);
theta_thresh=exp(theta_thresh);
ThetaEpoch=thresholdIntervals(smooth_Theta,theta_thresh,'Direction','Above');
ThetaEpoch=mergeCloseIntervals(ThetaEpoch,ThetaI(1)*1E4);
ThetaEpoch=dropShortIntervals(ThetaEpoch,ThetaI(2)*1E4);


save(strcat(filename,'StateEpochSB'),'ThetaEpoch','chH', 'smooth_Theta','ThetaRatioTSD','ThetaI','theta_thresh','-v7.3','-append');


end