

clear all


cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241211_TORCs')
% cd('/media/nas7/React_Passive_AG/OBG/Brynza/freely-moving/20240123_long/')
% cd('/media/nas7/React_Passive_AG/OBG/Labneh/freely-moving/20221221_long/')
load('SleepScoring_OBGamma.mat', 'SWSEpoch', 'Sleep')
load('H_Low_Spectrum.mat')
H_tsd = tsd(Spectro{2}*1e4 , Spectro{1});
H_Sleep = Restrict(H_tsd , Sleep);
H_SWS = Restrict(H_tsd , SWSEpoch);
D_H = Data(H_Sleep);

load('B_Low_Spectrum.mat')
B_tsd = tsd(Spectro{2}*1e4 , Spectro{1});
B_Sleep = Restrict(B_tsd , Sleep);
B_SWS = Restrict(B_tsd , SWSEpoch);
D_B = Data(B_Sleep);

R = Range(B_Sleep);

c = [-3 3];

%% 1st step
D = zscore(runmean(runmean(log10([D_H(:,1:78) D_B(:,1:78)]),100)',2)');

figure
imagesc([1:length(D)] , linspace(0,12,156) , D'), axis xy
hline(6), caxis(c)


figure
subplot(121)
[~, ~, ~, eigen_vector] = pca(D');
subplot(122)
imagesc([1:size(eigen_vector,2)] , linspace(0,12,156) , eigen_vector), axis xy


for pc=1:size(eigen_vector,2)
    for i=1:length(B_Sleep)
        PC_values{pc}(i) = eigen_vector(:,pc)'*D(i,:)';
    end
    sd = std(PC_values{pc});
    PC_values{pc}(abs(PC_values{pc})>nanmean(abs(PC_values{pc}))+4*sd) = NaN;
end

% NREM-REM
figure
gamma_thresh = GetGaussianThresh_BM(PC_values{1}, 0, 1);
makepretty

ind1 = PC_values{1}<gamma_thresh;

figure
imagesc(D(~ind1,:)'), axis xy, caxis(c)

PC1_tsd = tsd(R , PC_values{1}');
PC1_epoch = thresholdIntervals(PC1_tsd , gamma_thresh , 'Direction' , 'Above');
PC1 = eigen_vector(:,1);

%% 2nd step, N1-N2
D2 = zscore(D(ind1,:)')'; 

figure
imagesc(D2'), axis xy, caxis(c)
close

figure
gamma_thresh = GetGaussianThresh_BM(PC_values{2}(ind1), 0, 1);
makepretty

ind2 = PC_values{2}(ind1)>gamma_thresh;


PC2_tsd = tsd(R(ind1) , PC_values{2}(ind1)');
PC2_epoch = thresholdIntervals(PC2_tsd , gamma_thresh , 'Direction' , 'Above');

PC2_tsd = tsd(R , PC_values{2}');

%% sum up
figure
subplot(311)
imagesc(D(~ind1,:)'), axis xy, caxis(c)
subplot(312)
imagesc(D2(ind2,:)'), axis xy, caxis(c)
subplot(313)
imagesc(D2(~ind2,:)'), axis xy, caxis(c)

[sum(DurationEpoch(PC1_epoch)) sum(DurationEpoch(PC2_epoch)) sum(DurationEpoch((Sleep-PC2_epoch)-PC1_epoch))]./3.6e7



figure
subplot(131)
[~, ~, ~, eigen_vector] = pca(D2'); xlim([0 2.55]), makepretty
ylabel('% var explained'), xticklabels({'λ1','λ2','λ3'}), ylim([0 65]), title('')
subplot(222)
imagesc([1:2] , linspace(0,6,156) , [eigen_vector(1:78,1) -eigen_vector(1:78,2)]), axis xy
ylabel('HPC frequency'), xticks([1:2]), xticklabels({'λ1','λ2'})
makepretty
subplot(224)
imagesc([1:2] , linspace(0,6,156) , [eigen_vector(79:156,1) -eigen_vector(79:156,2)]), axis xy
ylabel('OB frequency'), xticks([1:2]), xticklabels({'λ1','λ2'})
makepretty


%%
load('SleepScoring_OBGamma.mat', 'SmoothTheta','Sleep')
smootime = 10;
SmoothTheta = tsd(Range(SmoothTheta) , runmean(Data(SmoothTheta),ceil(smootime/median(diff(Range(SmoothTheta,'s'))))));

load([pwd filesep 'ChannelsToAnalyse/Bulb_deep.mat'])
load([pwd filesep 'LFPData/LFP' num2str(channel) '.mat'])
FilDelta = FilterLFP(LFP,[.5 4],1024);
hilbert_delta = abs(hilbert(Data(FilDelta)));
SmoothDelta_OB = tsd(Range(LFP),runmean(hilbert_delta,ceil(smootime/median(diff(Range(LFP,'s'))))));

SmoothDelta_OB = Restrict(SmoothDelta_OB , SmoothTheta);

%
figure
subplot(6,6,32:36)
[Y,X] = hist(PC_values{1},100);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
xlim([-3e4 4.2e4]), box off, ylim([0 2100])
v1=vline(.54,'-r'); v1.LineWidth=5;
ylabel('PDF'), xlabel('PC1 values')
makepretty

subplot(6,6,[25 19 13 7 1])
[Y,X] = hist(PC_values{2},100);
a = area(X , runmean(Y,3)); a.FaceColor=[.8 .8 .8]; a.LineWidth=3; a.EdgeColor=[0 0 0];
camroll(270), box off
xlabel('OB delta power (a.u.)'), ylabel('PDF'), xlim([-1.7e4 3e4])
v2=vline(1.5e3,'-r'); v2.LineWidth=5;
makepretty

subplot(6,6,[2:6 8:12 14:18 20:24 26:30])
X = Data(Restrict(PC1_tsd , PC1_epoch)); Y = Data(Restrict(PC2_tsd , PC1_epoch)); Y = (Y/2)-6587;
plot(X(1:10:end) , Y(1:10:end) , '.g','MarkerSize',10), hold on
X = Data(Restrict(PC1_tsd , PC2_epoch)); Y = -Data(Restrict(PC2_tsd , PC2_epoch)); 
plot(X(1:10:end) , Y(1:10:end) , '.','MarkerSize',10,'Color',[.8 .5 .2]), hold on
X = Data(Restrict(PC1_tsd , (Sleep-PC2_epoch)-PC1_epoch)); Y = Data(Restrict(PC2_tsd , (Sleep-PC2_epoch)-PC1_epoch)); 
plot(X(1:10:end) , Y(1:10:end) , '.','MarkerSize',10,'Color',[1 0 0]), hold on
axis square, xlim([-3e4 4.2e4]), ylim([-2e4 1.7e3])
set(gca,'Linewidth',2), xticklabels({''}), yticklabels({''})
f=get(gca,'Children'); l=legend([f([1 3 2])],'NREM1','NREM2','REM'); 








%% trash ?
D2 = zscore(D(ind1,:)')'; 

figure
imagesc(D2'), axis xy, caxis(c)
close

figure
subplot(121)
[~, ~, ~, eigen_vector] = pca(D2');
subplot(122)
imagesc([1:size(eigen_vector,2)] , linspace(0,12,156) , eigen_vector), axis xy


clear PC_values
for pc=1:2
    for i=1:length(D2)
        PC_values{pc}(i) = eigen_vector(:,pc)'*D2(i,:)';
    end
    sd = std(PC_values{pc});
    PC_values{pc}(abs(PC_values{pc})>nanmean(abs(PC_values{pc}))+4*sd) = NaN;
end


% IS
figure
gamma_thresh = GetGaussianThresh_BM(PC_values{1}, 0, 1);
makepretty

ind2 = PC_values{1}>gamma_thresh;

figure
subplot(311)
imagesc(D(~ind1,:)'), axis xy, caxis(c)
subplot(312)
imagesc(D2(ind2,:)'), axis xy, caxis(c)
subplot(313)
imagesc(D2(~ind2,:)'), axis xy, caxis(c)

[sum(DurationEpoch(PC1_epoch)) sum(DurationEpoch(PC2_epoch)) sum(DurationEpoch((Sleep-PC2_epoch)-PC1_epoch))]./3.6e7

PC2_tsd = tsd(R(ind1) , PC_values{1}');
PC2_epoch = thresholdIntervals(PC2_tsd , gamma_thresh , 'Direction' , 'Above');
PC1(:,2) = eigen_vector(:,1);


%% 3rd step
figure
subplot(221)
imagesc(PC1(1:78,1)), axis xy
xticks([1]), xticklabels({''}), ylabel('HPC frequency')

subplot(223)
imagesc(PC1(79:78*2,1)), axis xy
xticks([1]), xticklabels({'PC1'}), ylabel('OB frequency')

subplot(222)
imagesc(PC1(1:78,2)), axis xy
xticks([1]), xticklabels({''}), 

subplot(224)
imagesc(PC1(79:78*2,2)), axis xy
xticks([1]), xticklabels({'PC2'}), 

colormap viridis


