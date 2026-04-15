function GUIcreate_DirLinear(behavResources)

% simple function adding the direction of the mouse in TSD format within 
% behavResources variable
%
% Written by SL - 2021-04

sessNames = {'Hab','TestPre','Cond','TestPost','Extinct'};

% Get data
for isuj = 1:length(Dir.path)
    disp(['Processing M' num2str(nMice(isuj))]);
    load([Dir.path{isuj}{1} '/behavResources.mat'], 'behavResources');

    % get indexes
    for isess=1:length(sessNames)
        sid = strfind({behavResources.SessionName},sessNames{isess});
        id{isess}=[];
        for iid=1:length(sid)
            if sid{iid}
                id{isess}(end+1)=iid;
            end
        end
        clear sid
    end
    
    % create direction var in behavresources struct
    clean=0;
    for isess=1:length(sessNames)
        skip=0;
        for itrial=1:length(id{isess})
            disp(['Session ' sessNames{isess} ', trial #' num2str(itrial)])
            try
                datlin = Data(behavResources(id{isess}(itrial)).CleanLinearDist);
                clean=1;
            catch
                try
                    datlin = Data(behavResources(id{isess}(itrial)).LinearDist);
                catch
                    warning('NO LINEAR DATA');
                    skip=1;
                end
            end
            if ~skip
                DirLinear_tmp(1)=1;

                for ilin=2:length(datlin)
                    % toward stim zone
                    if datlin(ilin)-datlin(ilin-1)<0
                        DirLinear_tmp(ilin)=3;
                    % away    
                    elseif datlin(ilin)-datlin(ilin-1)>0
                        DirLinear_tmp(ilin)=2;
                    % no movement    
                    elseif datlin(ilin)-datlin(ilin-1)==0
                        DirLinear_tmp(ilin)=1;  
                    else
                        DirLinear_tmp(ilin)=0;  
                    end
                end
                DirLinear = DirLinear_tmp';
                % create data var
                if clean
                    behavResources(id{isess}(itrial)).DirLinear = ...
                        tsd(Range(behavResources(id{isess}(itrial)).CleanLinearDist), ...
                        DirLinear);
                else
                    behavResources(id{isess}(itrial)).DirLinear = ...
                        tsd(Range(behavResources(id{isess}(itrial)).LinearDist), ...
                        DirLinear);
                end
                % set and create epoch var
                DirEpoch{1} = thresholdIntervals(behavResources(id{isess}(itrial)).DirLinear,2.5, ...
                    'Direction','Above');
                DirEpoch{2} = minus(thresholdIntervals(behavResources(id{isess}(itrial)).DirLinear,1.5, ...
                    'Direction','Above'),DirEpoch{1});
                DirEpoch{3} = thresholdIntervals(behavResources(id{isess}(itrial)).DirLinear,1.5, ...
                    'Direction','Below');

                behavResources(id{isess}(itrial)).DirEpoch = DirEpoch;

                clear datlin DirLinear_tmp st_in st_out st_no en_in en_out en_no
            end
        end
    end
    
    save([Dir.path{isuj}{1} '/behavResources.mat'],'behavResources','-append');
    clear behavResources;
end