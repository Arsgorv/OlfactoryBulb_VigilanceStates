function fig = plot_transition_matrix_AG(T_all, sessionNames, colors)
% plot_transition_matrix_AG  Heatmaps of transition probabilities + (if
% available) observed-vs-shuffle differences.
%
% Top row : observed transition probability matrix per session
% Bottom  : observed - median(shuffle)  (only drawn when shuffle was computed)
%
% INPUT
%   T_all          1xN cell of compute_transition_matrix_AG outputs
%   sessionNames   1xN cellstr
%   colors         state_colors_AG output
%
% OUTPUT
%   fig            figure handle

if nargin < 3 || isempty(colors), colors = state_colors_AG(); end
nSess = numel(T_all);
names = colors.names;
nS    = 4;

hasShuffle = false;
for s = 1:nSess
    if ~isempty(T_all{s}.shuffleProbs), hasShuffle = true; break, end
end

nRow = 1 + double(hasShuffle);
fig  = figure('Color','w','Units','normalized', ...
              'Position',[.1 .1 .35*nSess .4*nRow + .1]);

for s = 1:nSess
    % --- row 1: probabilities ------------------------------------------------
    subplot(nRow, nSess, s)
    imagesc(T_all{s}.probs)
    axis square xy
    caxis([0 1])
    colormap(gca, viridis)
    cb = colorbar; ylabel(cb,'P(to | from)')
    set(gca, 'XTick', 1:nS, 'XTickLabel', names, ...
             'YTick', 1:nS, 'YTickLabel', names, 'FontSize',9)
    xlabel('To state'), ylabel('From state')
    title(sessionNames{s}, 'Interpreter','none')
    for i = 1:nS
        for j = 1:nS
            v = T_all{s}.probs(i,j);
            txtCol = 'w'; if v < 0.4, txtCol = 'k'; end
            text(j, i, num2str(round(v,2)), ...
                 'HorizontalAlignment','center','Color', txtCol, 'FontWeight','bold')
        end
    end

    % --- row 2: observed - median(shuffle) ----------------------------------
    if hasShuffle && ~isempty(T_all{s}.shuffleProbs)
        subplot(nRow, nSess, nSess + s)
        diffMat = T_all{s}.probs - nanmedian(T_all{s}.shuffleProbs, 3);
        imagesc(diffMat)
        axis square xy
        caxis([-0.5 0.5])
        colormap(gca, redblue_AG())
        cb = colorbar; ylabel(cb,'P_o_b_s - P_s_h_u_f_f')
        set(gca, 'XTick', 1:nS, 'XTickLabel', names, ...
                 'YTick', 1:nS, 'YTickLabel', names, 'FontSize',9)
        xlabel('To state'), ylabel('From state')
        title('Observed - shuffle median')
        for i = 1:nS
            for j = 1:nS
                v = diffMat(i,j);
                if abs(v) < 0.01, continue, end
                text(j, i, num2str(round(v,2)), ...
                     'HorizontalAlignment','center','Color','k','FontWeight','bold')
            end
        end
    end
end

end


function cmap = redblue_AG()
% Compact diverging blue-white-red colormap, 256 entries
n = 128;
b = [linspace(0.0,1.0,n)' linspace(0.2,1.0,n)' linspace(0.6,1.0,n)'];
r = [linspace(1.0,0.6,n)' linspace(1.0,0.0,n)' linspace(1.0,0.0,n)'];
cmap = [b; r];
end
