function fig = plot_cycle_spectrograms_AG(CT_all, sessionNames)
% plot_cycle_spectrograms_AG  Cycle-warped mean spectrograms for OB gamma,
% HPC low and OB low, drawn over TWO concatenated cycles.
%
% INPUT
%   CT_all         1xN cell of compute_cycle_traces_AG outputs (with .spec)
%   sessionNames   1xN cellstr
%
% OUTPUT
%   fig  figure handle

nSess = numel(CT_all);
nRow = 3;
fig = figure('Color','w','Units','normalized','Position',[.05 .03 .85 .9]);

panelDef = { ...
    'OBgamma',  'OB frequency (Hz)',     [20 100], [];   % yLim
    'HPClow',   'HPC frequency (Hz)',    [0 10],   [];
    'OBlow',    'OB frequency (Hz)',     [0 10],   []};

for s = 1:nSess
    CT = CT_all{s};
    for r = 1:nRow
        subplot(nRow, nSess, (r-1)*nSess + s)
        spName = panelDef{r,1};
        if ~isfield(CT.spec, spName) || isempty(CT.spec.(spName).f)
            text(.5,.5,'spectrogram missing','Units','normalized', ...
                 'HorizontalAlignment','center')
            axis off, continue
        end
        S = CT.spec.(spName);
        % Smooth a bit and concatenate twice
        M2 = [S.M S.M];
        x  = linspace(0, 2, size(M2,2));
        imagesc(x, S.f, M2)
        axis xy
        ylim(panelDef{r,3})
        xlabel('Time (sleep cycle)')
        ylabel(panelDef{r,2})
        if r == 1
            title(sessionNames{s}, 'FontWeight','bold','Interpreter','none')
        end
        hold on, plot([1 1], panelDef{r,3}, 'k:', 'LineWidth', 1)
        set(gca,'TickDir','out','Box','off','FontSize',9)
    end
end
colormap(viridis)
end
