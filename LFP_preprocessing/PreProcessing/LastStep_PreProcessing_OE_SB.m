
%% File by file preparation for concatenation
clear all
load('ExpeInfo.mat')

%% Add the correct sampling rate
out_ind = regexp(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{1}, 'continuous');
oebin = fileread([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{1}(1:out_ind-1) '/structure.oebin']);
[~, sr_id] = regexp(oebin,'"sample_rate": ');
ExpeInfo.PreProcessingInfo.SR = str2double(oebin(sr_id(1)+1:sr_id(1)+5));
save('ExpeInfo.mat')


BaseFileName = ['M' num2str(ExpeInfo.nmouse) '_' ExpeInfo.date '_' ExpeInfo.SessionType];
FinalFolder = cd;

% Change one informational field of ExpeInfo
if sum(cell2mat(ExpeInfo.PreProcessingInfo.IntanRecorded)) > 0
    ExpeInfo.PreProcessingInfo.TypeOfSystem = 'OpenEphys';
end

%% Preallocate arrays
TimeBeginRec_Allfiles = nan(length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys), 3);
TimeEndRec_Allfiles = nan(length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys), 3);
TTLInfo_sess = cell(length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys), 1);

switch ExpeInfo.PreProcessingInfo.IsThereEphys
    case 'Yes'
        
        %% ephys
        for f = 1:length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys)
            if ExpeInfo.PreProcessingInfo.IntanRecorded{f} == 0
                %% go to folder
                cd(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f})
                disp(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f})
                
                %% Get the true time of the beginning and the end of the folders
                
                %Sanity check :  the foldername should finish with the time int TimeBeginRec
                out_ind = regexp(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}, 'continuous');
                StartFile = dir([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}(1:out_ind-1) '*.oebin']);
                if isempty(StartFile)
                    error('structure.oebin was not found. It should be present at the same level as "continuous" folder');
                end
                ind_start=strfind(StartFile.date,':');
                TimeBeginRec_Allfiles(f,1:3)=[str2num(StartFile.date(ind_start(1)-2:ind_start(1)-1)),...
                    str2num(StartFile.date(ind_start(1)+1:ind_start(2)-1)),str2num(StartFile.date(ind_start(2)+1:end))];
                
                StopFile=dir('*.dat');
                ind_stop=strfind(StopFile.date,':');
                TimeEndRec_Allfiles(f,1:3)=[str2num(StopFile.date(ind_stop(1)-2:ind_stop(1)-1)),...
                    str2num(StopFile.date(ind_stop(1)+1:ind_stop(2)-1)),str2num(StopFile.date(ind_stop(2)+1:end))];
                
                disp(['File starts at ' num2str(TimeBeginRec_Allfiles(f,1:3)) ' and ends at ' num2str(TimeEndRec_Allfiles(f,1:3))])
                
                %% Make TTLInfo - modification SB 12/02/2024
%                 TTLInfo_sess{f} = MakeData_TTLInfo_OpenEphys([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}(1:out_ind-1) ...
%                     'events/Rhythm_FPGA-100.0_TTL_1.mat'],ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}(1:out_ind-1),...
%                     ExpeInfo);
                
                   TTLInfo_sess{f} = MakeData_TTLInfo_OpenEphys(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}(1:out_ind-1),...
                    ExpeInfo);


                cd(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f})


                %% here is the place where we check if the ephys is the right length comapred to the behav resources - to do
                
                %% copy ephys files that are ref subtracted and merged
                if ExpeInfo.PreProcessingInfo.RefDone{f}
                    disp('file is merged and ref subtracted - copying ...')
                    
                    % Create the xml
                    WriteExpeInfoToXml(ExpeInfo)
                    
                    % copy the .dat and the .xml
                    copyfile(fullfile(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}, 'continuous.dat'),...
                        fullfile(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f},...
                        [BaseFileName '-' sprintf('%02d',f) '.dat']));
                    movefile(fullfile(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f},...
                        [BaseFileName '-' sprintf('%02d',f) '.dat']), FinalFolder);
                    copyfile(fullfile(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}, 'amplifier.xml'),...
                        fullfile(FinalFolder, [BaseFileName '-' sprintf('%02d',f) '.xml']));
                    delete([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f} filesep 'amplifier.xml']);
                    
                elseif  ExpeInfo.PreProcessingInfo.RefDone{f}==0
                    disp('file is merged - subtracting ref ...')
                    
                    % Create the xml
                    WriteExpeInfoToXml(ExpeInfo)
                    
                    % subtract the reference
                    RefChannel = ExpeInfo.ChannelToAnalyse.Ref;
                    % do subtraction on all the wideband channels
                    ChanToSub = [0 : ExpeInfo.PreProcessingInfo.NumWideband-1];
                    ChanToSub(ChanToSub==RefChannel) = [];
                    % special case for breathing
                    if isfield(ExpeInfo.ChannelToAnalyse,'Respi')
                        ChanToSub(ChanToSub==ExpeInfo.ChannelToAnalyse.Respi) = [];
                    end
                    ChanToSaveWithoutChange = [0 :ExpeInfo.PreProcessingInfo.TotalChannels-1];
                    ChanToSaveWithoutChange(ChanToSub+1) = [];
                    % Do the subtraction
                    RefSubtraction_multi('continuous.dat',ExpeInfo.PreProcessingInfo.TotalChannels,1,...
                        ['M' num2str(ExpeInfo.nmouse)],ChanToSub,RefChannel,ChanToSaveWithoutChange,'frequency',ExpeInfo.PreProcessingInfo.SR);
                    
                    disp(['file is merged and ref subtracted - copying ...'])
                    % copy the file
                    movefile(fullfile(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f},...
                        ['continuous_M' num2str(ExpeInfo.nmouse) '.dat']),...
                        fullfile(FinalFolder, [BaseFileName '-' sprintf('%02d',f) '.dat']));
                    copyfile([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f} filesep 'amplifier.xml'],...
                        fullfile(FinalFolder, [BaseFileName '-' sprintf('%02d',f) '.xml']));
                    delete([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f} filesep 'amplifier.xml']);
                end
                
                %%
            elseif ExpeInfo.PreProcessingInfo.IntanRecorded{f} == 1
                
                % go to folder
                cd(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f})
                disp(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f})
                
                %% Get the true time of the beginning and the end of the folders
                
                StopFile=dir('*supply.dat');
                ind=strfind(StopFile.date,':');
                TimeEndRec_Allfiles(f,1:3)=[str2num(StopFile.date(ind(1)-2:ind(1)-1)),...
                    str2num(StopFile.date(ind(1)+1:ind(2)-1)),str2num(StopFile.date(ind(2)+1:end))];
                
                %Sanity check :  the foldername should finish with the time int TimeBeginRec
                FolderNameTime = (ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}(end-5:end));
                TimeBeginRec_Allfiles(f,1:3)=[str2num(FolderNameTime(1:2)),...
                    str2num(FolderNameTime(3:4)),str2num(FolderNameTime(5:6))];
                
                
                disp(['File starts at ' num2str(TimeBeginRec_Allfiles(f,1:3)) ' and ends at ' num2str(TimeEndRec_Allfiles(f,1:3))])
                
                %% Make TTLInfo
                TTLInfo_sess{f} = GetTTLTimesInd_Intan(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f},...
                    ExpeInfo);
                
                %% copy ephys files that are ref subtracted and merged
                if  ExpeInfo.PreProcessingInfo.RefDone{f} && ExpeInfo.PreProcessingInfo.MergeDone{f}==0
                    
                    disp(['file is ref subtracted - merging...'])
                    % Create the xml
                    WriteExpeInfoToXml(ExpeInfo)
                    
                    
                    % Merge
                    movefile(['amplifier.dat'], 'amplifier-wideband.dat');
                    if ExpeInfo.PreProcessingInfo.NumAccelero>0
                        movefile('auxiliary.dat', 'amplifier-accelero.dat');
                    end
                    system('ndm_mergedat amplifier')
                    
                    disp('file is merged and ref subtracted - copying ...')
                    % copy the file
                    copyfile(fullfile(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}, 'amplifier.dat'),...
                        fullfile(FinalFolder, [BaseFileName '-' sprintf('%02d',f) '.dat']));
                    copyfile(fullfile(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}, 'amplifier.xml'),...
                        fullfile(FinalFolder, [BaseFileName '-' sprintf('%02d',f) '.xml']));
                    
                    
                elseif  ExpeInfo.PreProcessingInfo.RefDone{f}==0 && ExpeInfo.PreProcessingInfo.MergeDone{f}==0
                    
                    disp('file is unpreprocessed - subtracting ref...')
                    % Create the xml
                    WriteExpeInfoToXml(ExpeInfo)
                    
                    
                    % subtract the reference
                    RefChannel = ExpeInfo.ChannelToAnalyse.Ref;
                    % do subtraction on all the wideband channels
                    ChanToSub = [0 : ExpeInfo.PreProcessingInfo.NumWideband-1];
                    ChanToSub(ChanToSub==RefChannel) = [];
                    % special case for breathing
                    if isfield(ExpeInfo.ChannelToAnalyse,'Respi')
                        ChanToSub(ChanToSub==ExpeInfo.ChannelToAnalyse.Respi) = [];
                    end
                    ChanToSaveWithoutChange = 0 :ExpeInfo.PreProcessingInfo.NumWideband-1;
                    ChanToSaveWithoutChange(ChanToSub+1) = [];
                    % Do the subtraction
                    RefSubtraction_multi('amplifier.dat',ExpeInfo.PreProcessingInfo.NumWideband,1,['M' num2str(ExpeInfo.nmouse)],ChanToSub,RefChannel,ChanToSaveWithoutChange);
                    
                    disp('file is ref subtracted - merging...')
                    % Merge
                    movefile(['amplifier_M' num2str(ExpeInfo.nmouse) '.dat'], 'amplifier-wideband.dat');
                    if ExpeInfo.PreProcessingInfo.NumAccelero>0
                        movefile('auxiliary.dat', 'amplifier-accelero.dat');
                    end
                    system('ndm_mergedat amplifier')
                    
                    disp('file is merged and ref subtracted - copying ...')
                    % copy the file
                    copyfile(fullfile(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}, 'amplifier.dat'),...
                        fullfile(FinalFolder, [BaseFileName '-' sprintf('%02d',f) '.dat']));
                    copyfile(fullfile(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{f}, 'amplifier.xml'),...
                        fullfile(FinalFolder, [BaseFileName '-' sprintf('%02d',f) '.xml']));
                end
                
            end
            cd(FinalFolder)
            
        end
        cd(FinalFolder)
        
        
        %% save the times
        TimeEndRec = TimeEndRec_Allfiles(end,:);
        TimeBeginRec = TimeBeginRec_Allfiles(1,:);
        save([FinalFolder filesep 'TimeRec.mat'],'TimeEndRec','TimeBeginRec','TimeEndRec_Allfiles','TimeBeginRec_Allfiles')
        
        %% Create session-wide .xml
        copyfile([FinalFolder filesep BaseFileName '-' sprintf('%02d',f) '.xml'],...
            [FinalFolder filesep BaseFileName '.xml']);
        
        %% concatenate all the files
        if length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys)>1
            system(['ndm_concatenate ' BaseFileName])
        else
            movefile([FinalFolder filesep BaseFileName '-' sprintf('%02d',f) '.dat'],...
                [FinalFolder filesep BaseFileName '.dat']);
        end
        
        %% make lfp
        system(['ndm_lfp ' BaseFileName])
        
        %% create lfp and channels to analyse folders
        InfoLFP = ExpeInfo.InfoLFP;
        mkdir('LFPData')
        save('LFPData/InfoLFP.mat','InfoLFP')
        
        mkdir('ChannelsToAnalyse');
        if isfield(ExpeInfo,'ChannelToAnalyse')
            AllStructures = fieldnames(ExpeInfo.ChannelToAnalyse);
            for stru=1:length(AllStructures)
                channel = ExpeInfo.ChannelToAnalyse.(AllStructures{stru});
                save(['ChannelsToAnalyse/',AllStructures{stru},'.mat'],'channel');
            end
        end
        
        %% run the makeData scripts
        global DATA
        SetCurrentSession([BaseFileName '.xml'])
        SessLength = MakeData_LFP_PluggedOnly(FinalFolder,ExpeInfo);
        
        % This is SUPER dirty!! DO it again Sophie!!
        if length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys)==1
            %evt
            evt.time(1)=0;
            evt.time(2)=SessLength*1e4;
            
            evt.description{1}='beginning of';
            evt.description{2}='end of';
            
            CreateEvent(evt, [FinalFolder filesep BaseFileName], 'cat')
            movefile( [FinalFolder filesep BaseFileName '.evt.cat'],[FinalFolder filesep BaseFileName '.cat.evt'])
        end
        
        SetCurrentSession('same');
        tpsCatEvt = MakeData_CatEvents(FinalFolder);
        MakeData_RealTime(FinalFolder)
        
        if ExpeInfo.PreProcessingInfo.NumAccelero>0
            MakeData_Accelero(FinalFolder)
        end
        
        %% Make final TTLInfo
        % Duration files
        beg_end = cell2mat(tpsCatEvt);
        st = beg_end(1:2:end);
        en = beg_end(2:2:end);
        
        duration = nan(length(st),1);
        for i=1:length(st)
            duration(i) = en(i)-st(i);
        end
        duration = duration*1e4;
        
        % Concatenation of single session TTLs
        if isempty(TTLInfo_sess{1}.StopSession) % add by BM on 01/05/2022 when we don't have TTL
            if length(TTLInfo_sess) == 1
                TTLInfo = TTLInfo_sess{1};
                StimEpoch = TTLInfo_sess{1}.StimEpoch;
            else
                TTLInfo.StartSession = TTLInfo_sess{1}.StartSession;
                TTLInfo.StopSession = TTLInfo_sess{end}.StopSession;
                % StimEpoch
                Stim = cell(length(TTLInfo_sess),1);
                for ittl = 1:length(TTLInfo_sess)
                    Stim{ittl} = Start(TTLInfo_sess{ittl}.StimEpoch);
                end
                for ittl=1:(length(TTLInfo_sess)-1)
                    Stim{ittl+1} = Stim{ittl+1} + (sum(duration(1:ittl)));
                end
                StimTime = Stim{1};
                for ittl = 2:length(TTLInfo_sess)
                    StimTime = [StimTime; Stim{ittl}];
                end
                TTLInfo.StimEpoch = intervalSet(StimTime, StimTime);
                StimEpoch = TTLInfo.StimEpoch;
                clear Stim Stimtime
            end
            save('behavResources.mat','TTLInfo','-append')
            if exist('StimEpoch')>0
                save('behavResources.mat','StimEpoch','-append')
            end
        end

        %% if there are spikes
        if ExpeInfo.PreProcessingInfo.DoSpikes
            
            % Do subtraction if necessary
            if sum(ExpeInfo.SpikeGroupInfo.UseForElecSub)>0
                
                % get the electrodes to make the subtraction on
                ElecPerformSub = [];
                for sp = 1:length(ExpeInfo.SpikeGroupInfo.UseForElecSub)
                    if ExpeInfo.SpikeGroupInfo.UseForElecSub(sp) ==1
                        ElecPerformSub = [ElecPerformSub,str2num(ExpeInfo.SpikeGroupInfo.ChanNames{sp})];
                    end
                end
                
                
                % Old version
                
                % Get the electrodes which will eb averaged to make the subtraction
                %RefElec = str2num((ExpeInfo.SpikeGroupInfo.ElecsToSub));
                % Preform the subtraction
                %         AllChans = [0:ExpeInfo.PreProcessingInfo.TotalChannels-1];
                %         AllChans(ElecPerformSub+1) = [];
                %         RefSubtraction_multi_AverageChans([BaseFileName '.dat'],ExpeInfo.PreProcessingInfo.TotalChannels,1,'SpikeRef',ElecPerformSub,RefElec,AllChans);
                
                
                % New version with different reference channels
                LeftOverChannels = 0:ExpeInfo.PreProcessingInfo.TotalChannels-1;
                ToDel = [];
                numtet = 1;
                for tet = 1:length(ExpeInfo.SpikeGroupInfo.ChanNames)
                    if ~isempty(ExpeInfo.SpikeGroupInfo.ElecsToSub{tet})
                        ChannelsToPerfSub{numtet} = str2num(ExpeInfo.SpikeGroupInfo.ChanNames{tet});
                        ChannelsToAverageForSub{numtet} = str2num(ExpeInfo.SpikeGroupInfo.ElecsToSub{tet});
                        ToDel = [ToDel, str2num(ExpeInfo.SpikeGroupInfo.ChanNames{tet})];
                        
                        numtet =  numtet +1;
                    end
                end
                LeftOverChannels(ismember(LeftOverChannels,ToDel)) = [];
                
                RefSubtraction_GroupByGroup([BaseFileName '.dat'],ExpeInfo.PreProcessingInfo.TotalChannels,1,'SpikeRef', ...
                    ChannelsToPerfSub, ChannelsToAverageForSub, LeftOverChannels);
                system(['mv ' BaseFileName '_original.dat ' BaseFileName '.dat'])
                copyfile([BaseFileName '.xml'], [BaseFileName '_SpikeRef.xml'])
                
                
                % Do the preprcessing steps
                system(['ndm_hipass ' BaseFileName '_SpikeRef'])
                system(['ndm_extractspikes ' BaseFileName '_SpikeRef'])
                
                if strcmp(ExpeInfo.PreProcessingInfo.CleanSpikes, 'Yes')
                    disp('I will clean bad spikes...');
                    
                    if exist('UnfilteredChans', 'dir') ~= 7 || isempty(dir([FinalFolder filesep 'UnfilteredChans/*.mat']))
                        MakeData_Detection(FinalFolder, ExpeInfo.ChannelToAnalyse.Ref);
                    end
                    
                    % Get spikes without artefacts
                    files = dir([FinalFolder filesep 'UnfilteredChans/*.mat']);
                    CleanEpoch = DefineCleanSpikesEpochs([files(1).folder filesep files(1).name], FinalFolder,...
                        ExpeInfo.PreProcessingInfo.StimDur);
                    
                    % Remove spikes
                    RemoveArtefactualSpikes(FinalFolder, CleanEpoch, [BaseFileName '_SpikeRef']);
                    
                end
                
                system(['ndm_pca ' BaseFileName '_SpikeRef'])
                
            else %% Here we don't need to do re-referencing
                
                system(['ndm_hipass ' BaseFileName])
                system(['ndm_extractspikes ' BaseFileName])
                
                if strcmp(ExpeInfo.PreProcessingInfo.CleanSpikes, 'Yes')
                    disp('I will clean bad spikes...');
                    
                    if exist('UnfilteredChans', 'dir') ~= 7 || isempty(dir([FinalFolder filesep 'UnfilteredChans/*.mat']))
                        MakeData_Detection(FinalFolder, ExpeInfo.ChannelToAnalyse.Ref);
                    end
                    
                    % Get spikes without artefacts
                    files = dir([FinalFolder filesep 'UnfilteredChans/*.mat']);
                    CleanEpoch = DefineCleanSpikesEpochs([files(1).folder filesep files(1).name], FinalFolder,...
                        ExpeInfo.PreProcessingInfo.StimDur);
                    
                    % Remove spikes
                    RemoveArtefactualSpikes(FinalFolder, CleanEpoch, BaseFileName);
                    
                end
                
                system(['ndm_pca ' BaseFileName])
                
            end
            
            
            
            
        end
        
    case 'No'
        disp('No Ephys');
end

%% behaviour (Camera)
% First sort out times if they don't yet exist because there is no ephys
switch ExpeInfo.PreProcessingInfo.IsThereBehav
    case 'Yes'
        switch ExpeInfo.PreProcessingInfo.IsThereEphys
            case 'No'
                tps = 0;
                tpsCatEvt = 0;
                for f = 1:length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav)
                    
                    load([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{f} filesep 'behavResources.mat'] ,'PosMat')
                    tps = tps + max(PosMat(:,1));
                    tpsCatEvt = [tpsCatEvt, [tps;tps]']; % in seconds
                    
                end
                tpsCatEvt(end) = [];
                tpsCatEvt = num2cell(tpsCatEvt);
                
                try
                    save([FinalFolder 'behavResources'],'tpsCatEvt','-append')
                catch
                    disp('Creating behavResources.mat')
                    save([FinalFolder 'behavResources'],'tpsCatEvt')
                end
            case 'Yes'
                disp('')
        end
    case 'No'
        disp('')
end


switch ExpeInfo.PreProcessingInfo.IsThereBehav
    case 'Yes'
        
        if ~strcmpi(ExpeInfo.CameraType, 'None')
            if  length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav)==1
                copyfile([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{1} filesep 'behavResources.mat'],...
                    [FinalFolder filesep 'behavResources-temp.mat']);
                TempVar = load([FinalFolder filesep 'behavResources-temp.mat']);
                TempVar = CorrectTimeBackToEphys(TempVar, TTLInfo_sess{1});
                TempVar.SessionEpoch = intervalSet(TempVar.PosMat(1,1)*1e4, TempVar.PosMat(end,1)*1e4);
                save([FinalFolder filesep 'behavResources.mat'],'-struct','TempVar','-append')
                delete([FinalFolder filesep 'behavResources-temp.mat'])
                
            else
                for f = 1:length(ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav)
                    
                    copyfile([ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{f} filesep 'behavResources.mat'],...
                        [FinalFolder filesep 'behavResources-' sprintf('%02d',f) '.mat']);
                    filelist{f} = [FinalFolder filesep 'behavResources-' sprintf('%02d',f) '.mat'];
                    
                end
                IntanRecorded = ExpeInfo.PreProcessingInfo.IntanRecorded;
                BehavResourcesConcatenation(filelist, ExpeInfo.PreProcessingInfo.FolderSessionName, tpsCatEvt, FinalFolder, 'StartInfo', ...
                    TTLInfo_sess, 'IntanRecorded', IntanRecorded)
            end
        end
        
    case 'No'
end


disp('All done, you''re good! Jesus loves you. And your momma too')
disp('All hail the Holy Octopus')
