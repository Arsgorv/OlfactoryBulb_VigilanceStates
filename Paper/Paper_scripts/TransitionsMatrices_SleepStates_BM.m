
%% one good example on Shropshire
cd('/media/nas8/OB_ferret_AG_BM/Shropshire/freely-moving/20241206_TORCs')
load('SleepScoring_OBGamma.mat', 'CleanStates')

cleanSleepStates_BM(REMEpoch, SWS, IS, Wake, TotEpoch)

% 1. Define states
stateNames = {'Wake', 'N1', 'N2', 'REM'};
states = {CleanStates.Wake, CleanStates.N1, CleanStates.N2, CleanStates.REM};

% 2. Compute transition intervals
[aft_cell, ~] = transEpoch(states{:});

% 3. Initialize transition count matrix
nStates = length(states);
transMatrix = zeros(nStates, nStates);

for i = 1:nStates
    for j = 1:nStates
        try
            transMatrix(i,j) = length(Start(aft_cell{i,j}));
        end
    end
end

% 4. Normalize rows (row sums = 1, or 0 if no transitions)
rowSums = sum(transMatrix,2);
rowSums(rowSums==0) = NaN;
transProb = bsxfun(@rdivide, transMatrix, rowSums);
transProb(isnan(transProb)) = 0;

% 5. Display
disp('Raw Transition Counts:')
disp(array2table(transMatrix, 'VariableNames', stateNames, 'RowNames', stateNames))

disp('Transition Probabilities (row-normalized):')
disp(array2table(transProb, 'VariableNames', stateNames, 'RowNames', stateNames))

% 6. Display with imagesc
figure;
imagesc(transProb);
colormap(parula);
colorbar;
axis equal tight; axis xy; axis square
colormap viridis

% 7. Set axis labels and ticks
xticks(1:nStates);
yticks(1:nStates);
xticklabels(stateNames);
yticklabels(stateNames);
xlabel('To State');
ylabel('From State');
title('Sleep State Transition Probabilities');

% 8. Show numeric labels
for i = 1:nStates
    for j = 1:nStates
        text(j, i, num2str(round(transProb(i,j) , 2)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'Color', 'w', 'FontWeight', 'bold');
    end
end


%% All ferrets
clear all
stateNames = {'Wake', 'N1', 'N2', 'REM'};
nStates    = length(stateNames);

Dir{1} = PathForExperimentsOB({'Labneh'},     'freely-moving','none');
Dir{2} = PathForExperimentsOB({'Brynza'},     'freely-moving','none');
Dir{3} = PathForExperimentsOB({'Shropshire'}, 'freely-moving','none','TORCs');



for ferret = 1:3
    % Store per-session raw transition counts
    transMatrix{ferret} = zeros(4,nStates,nStates);
    
    for sess = 1:length(Dir{ferret}.path)
        clear states Wake ISEpoch SWSEpoch REMEpoch Sleep
        load([Dir{ferret}.path{sess} filesep 'SleepScoring_OBGamma.mat'],'Wake' , 'ISEpoch','SWSEpoch','REMEpoch','Sleep')
        
        
        try
            if sum(DurationEpoch(Sleep))>3600e4
                
%                 Wake = and(Wake , intervalSet(0 , 3600e4));
%                 ISEpoch = and(ISEpoch , intervalSet(0 , 3600e4));
%                 SWSEpoch = and(SWSEpoch , intervalSet(0 , 3600e4));
%                 REMEpoch = and(REMEpoch , intervalSet(0 , 3600e4));
                
                states = {Wake, ISEpoch , SWSEpoch , REMEpoch};
                [aft_cell, ~] = transEpoch(states{:});
                
                M = zeros(nStates,nStates);
                for i = 1:nStates
                    for j = 1:nStates
                        try
                            M(i,j) = length(Start(aft_cell{i,j}));
                        end
                    end
                end
                
                transMatrix{ferret}(sess,:,:) = M;
                disp(Dir{ferret}.path{sess})
            else
                transMatrix{ferret}(sess,:,:) = NaN(nStates,nStates);
            end
        catch
            transMatrix{ferret}(sess,:,:) = NaN(nStates,nStates);
        end
    end
    
    % --- Average raw counts across sessions ---
    Mmean = squeeze(nanmean(transMatrix{ferret},1));   % mean count matrix
    
    % --- Normalize rows of the mean matrix ---
    rowSums = sum(Mmean,2);
    rowSums(rowSums==0) = NaN;                        % avoid /0
    Pmean   = bsxfun(@rdivide, Mmean, rowSums);       % row-wise division
    Pmean(isnan(Pmean)) = 0;                          % restore zeros
    
    % Store
    transMatrix_mean{ferret} = Mmean;
    transProb_mean{ferret}   = Pmean;
end

%% --- Plot for each ferret ---
figure
for ferret=1:3
    subplot(1,3,ferret)
    imagesc(transProb_mean{ferret});
    colormap(parula);
    cb = colorbar;
    ylabel(cb,'Transition probability','FontSize',10);
    axis square; axis xy
    colormap viridis
    caxis([0 1])
    
    % Labels
    xticks(1:nStates);
    yticks(1:nStates);
    xticklabels(stateNames);
    yticklabels(stateNames);
    xlabel('To State');
    ylabel('From State');
    title(sprintf('Ferret %d',ferret))
    
    % Numeric values in cells
    for i = 1:nStates
        for j = 1:nStates
            text(j, i, num2str(round(transProb_mean{ferret}(i,j),2)), ...
                'HorizontalAlignment','center', ...
                'VerticalAlignment','middle', ...
                'Color','w','FontWeight','bold');
        end
    end
end


%% comparing transitions matrices

figure
subplot(131)
imagesc(transProb_mean{1}-transProb_mean{3})
for i = 1:nStates
    for j = 1:nStates
        text(j, i, num2str(round(transProb_mean{1}(i,j)-transProb_mean{3}(i,j),2)), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'Color','k','FontWeight','bold');
    end
end
caxis([-1 1])
xticks(1:nStates);
yticks(1:nStates);
xticklabels(stateNames);
yticklabels(stateNames);


subplot(132)
imagesc(transProb_mean{1}-transProb_mean{2})
for i = 1:nStates
    for j = 1:nStates
        text(j, i, num2str(round(transProb_mean{1}(i,j)-transProb_mean{2}(i,j),2)), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'Color','k','FontWeight','bold');
    end
end
caxis([-1 1])
xticks(1:nStates);
yticks(1:nStates);
xticklabels(stateNames);
yticklabels(stateNames);


subplot(133)
imagesc(transProb_mean{3}-transProb_mean{2})
for i = 1:nStates
    for j = 1:nStates
        text(j, i, num2str(round(transProb_mean{3}(i,j)-transProb_mean{2}(i,j),2)), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'Color','k','FontWeight','bold');
    end
end
caxis([-1 1])
xticks(1:nStates);
yticks(1:nStates);
xticklabels(stateNames);
yticklabels(stateNames);

colormap redblue
