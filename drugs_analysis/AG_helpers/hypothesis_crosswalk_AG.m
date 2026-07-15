function hypothesis_crosswalk_AG(SaveFigures, SaveFolder)
%HYPOTHESIS_CROSSWALK_AG  Print and save a small CSV mapping each hypothesis
% to the v7 figure(s) that test it.

T = cell2table({
    'H1','OB gamma uniformly suppressed by atropine','Fig 1 time courses; Fig 2 mean spectra; Fig 2 sub-band log ratios; Supp 1 within-Wake'
    'H2','Differential effect across gamma sub-bands','Fig 2 sub-band log ratios; Fig 2 sub-band peak shifts; Supp 1 within-Wake'
    'H3','OB delta increases under atropine','Fig 2 mean Low spectrum; Fig 2 delta log ratio; Fig 5 breath rate; Supp low-freq outside breath'
    'H4','OB theta or low-frequency reorganization','Fig 2 mean Low spectrum; theta log ratio; Supp 1 within-Wake'
    'H5','CBV decreases after injection in atropine more than saline','Fig 3 dCBV time courses; Fig 3 dCBV percent; Fig 3 log ratios'
    'H6','HPC and AEG/ACx CBV are highly correlated (global component)','Fig 3 HPC-AEG correlation pre/post'
    'H7','Long-timescale OB gamma anti-correlated with CBV','Fig 4 gamma-HPC and gamma-AEG r before; Fig 4 lag curves'
    'H8','Atropine alters OB-CBV coupling','Fig 4 paired Delta-r per session; Fig 4 lag pre vs post; Supp 2 LongSmooth sweep'
    'H9','Bodily variables (HR, breath, EMG, accelero) shift with drug','Fig 5; per-session QC; Supp 1 within-Wake'
}, 'VariableNames', {'id','hypothesis','where_in_v7'});

disp(' ')
disp('Hypothesis -> figure cross-walk (v7):')

% disp(T) hits an internal "looseline" fprintf bug in some MATLAB configs
% (R2018b interaction with format settings). Print row-by-row instead so the
% script never aborts here; the CSV save below is the actual deliverable.
try
    disp(T)
catch ME_disp
    warning('disp(T) failed (%s) - printing rows manually.', ME_disp.message)
    for r = 1:height(T)
        fprintf('  %s : %s\n     -> %s\n', T.id{r}, T.hypothesis{r}, T.where_in_v7{r});
    end
end

if SaveFigures
    try
        writetable(T, fullfile(SaveFolder, 'AtropineSaline_hypothesis_crosswalk_v7.csv'));
    catch ME_w
        warning('writetable failed: %s', ME_w.message)
    end
end
end
