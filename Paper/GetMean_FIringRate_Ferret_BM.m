


clear all

%%
[spikes, metadata] = load_wave_clus(pwd);
cd('..')

% targetVals = [34 52 55 57 61 62 85 92 93];
% idx = ismember(metadata(:,1), targetVals);
% idx = [1 5 17 18 19 31 44 45];

% Define the list of pairs you want to find
pairs = [
    33 1
    35 1
    35 2
    36 1
    39 1
    54 1
    55 1
    56 1
    58 1
    94 1
    ];


 
% Find indices in metadata matching any of these pairs
idx = ismember(metadata, pairs, 'rows');


spikes = spikes(:,idx);
spikes = spikes';

nUnits = size(spikes,1);
S_pre = cell(nUnits,1);
for iU = 1:nUnits
    st = spikes(iU, :);
    st = st(~isnan(st) & st > 0);  
    S_pre{iU} = ts(st(:));  
end
S = tsdArray(S_pre);

binsize = 100;
Q=MakeQfromS(S,binsize);
D = full(Data(Q));
Mean_FR = tsd(Range(Q)*10 , nanmean(D,2)); 

figure
subplot(211)
plot(nanmean(movmean(D,100)'))
subplot(212)
plot(movmean(D,100))


save('SleepScoring_OBGamma.mat','Mean_FR','-append')


