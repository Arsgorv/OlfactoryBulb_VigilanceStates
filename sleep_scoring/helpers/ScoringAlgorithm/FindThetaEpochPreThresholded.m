function FindThetaEpoch(Epoch,ThetaI,chH,filename,theta_thresh)

smootime=3;
load(strcat('LFPData/LFP',num2str(chH),'.mat'));
load('StateEpochSB.mat','sleepper')

% find theta epochs

disp(' ');
% disp('... Creating Theta Epochs ');
FilTheta=FilterLFP(LFP,[5 10],1024);
FilDelta=FilterLFP(LFP,[3 6],1024);
HilTheta=hilbert(Data(FilTheta));
HilDelta=hilbert(Data(FilDelta));
H=abs(HilDelta);
H(H<100)=100;
ThetaRatio=abs(HilTheta)./H;
ThetaRatioTSD=tsd(Range(FilTheta),ThetaRatio);
smooth_Theta=tsd(Range(ThetaRatioTSD),runmean(Data(ThetaRatioTSD),(smootime/8)*1e4));

ThetaEpoch=thresholdIntervals(smooth_Theta,theta_thresh,'Direction','Above');
ThetaEpoch=mergeCloseIntervals(ThetaEpoch,ThetaI(1)*1E4);
ThetaEpoch=dropShortIntervals(ThetaEpoch,ThetaI(2)*1E4);


save(strcat(filename,'StateEpochSB'),'ThetaEpoch','chH', 'smooth_Theta','ThetaRatioTSD','ThetaI','theta_thresh','-v7.3','-append');


end