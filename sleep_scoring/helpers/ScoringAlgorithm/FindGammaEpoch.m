function FindGammaEpoch(Epoch,chB,mindur,filename)

%% Initiation
% load OB LFP
load(strcat('LFPData/LFP',num2str(chB),'.mat'));
% params
smootime=3;

%% find gamma epochs
disp(' ');
disp('... Creating Gamma Epochs ');

% get instantaneous gamma power
FilGamma=FilterLFP(LFP,[50 70],1024);
HilGamma=hilbert(Data(FilGamma));
H=abs(HilGamma);
tot_ghi=Restrict(tsd(Range(LFP),H),Epoch);

% smooth gamma power
smooth_ghi=tsd(Range(tot_ghi),runmean(Data(tot_ghi),ceil(smootime/median(diff(Range(tot_ghi,'s'))))));

% get gamma threshold
gamma_thresh=GetGammaThresh(Data(Restrict(smooth_ghi,Epoch)));
gamma_thresh=exp(gamma_thresh);

% define sleep epoch
sleepper=thresholdIntervals(smooth_ghi,gamma_thresh,'Direction','Below');
sleepper=mergeCloseIntervals(sleepper,mindur*1e4);
sleepper=dropShortIntervals(sleepper,mindur*1e4);

save(strcat(filename,'StateEpochSB'),'sleepper','gamma_thresh','mindur','chB','smooth_ghi','-v7.3','-append');

end

