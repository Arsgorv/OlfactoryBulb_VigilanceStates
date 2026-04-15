function WriteExpeInfoToXml(ExpeInfo)

%% read the model file to be completed
% dr = dropbox;
dr = GitHubLocation;

copyfile(fullfile(dr, 'PrgGithub', 'PreProcessing', 'NomenclatureCodes', 'ModelXmlPreProcessing.xml'),'amplifier.xml')

XmlStructure = xml2struct_SB('amplifier.xml');

%% General Information
XmlStructure.parameters.generalInfo.date.Text = [ExpeInfo.date(1:4) '-' ExpeInfo.date(5:6) '-' ExpeInfo.date(7:8)];
XmlStructure.parameters.generalInfo.experimenters.Text = ExpeInfo.Experimenter;

%% Added by SB to account for not everyone using 20kHz anymore - 21/02/2025
if isfield(ExpeInfo.PreProcessingInfo,'SR')
XmlStructure.parameters.acquisitionSystem.samplingRate = ['' num2str(ExpeInfo.PreProcessingInfo.SR) ''];
end
% Generate description of this mouse
TextForDescription = ['MouseNum: ' num2str(ExpeInfo.nmouse) newline,...
    'MouseStrain: ' num2str(ExpeInfo.MouseStrain) newline,...
    'SessionType: ' num2str(ExpeInfo.SessionType)];

if isfield(ExpeInfo,'OptoInfo')
    TextForDescription = [TextForDescription,newline];
    TextForDescription = [TextForDescription,newline,'Is opto session: ', num2str(ExpeInfo.OptoSession)];
    AllFields = fieldnames(ExpeInfo.OptoInfo);
    for ff = 1:length(AllFields)
        if not(isstring(ExpeInfo.OptoInfo.(AllFields{ff})))
            temp = num2str(ExpeInfo.OptoInfo.(AllFields{ff}));
        else
            temp = (ExpeInfo.OptoInfo.(AllFields{ff}));
        end
        TextForDescription = [TextForDescription,newline,AllFields{ff},': ',temp];
    end
end

if isfield(ExpeInfo,'ElecStimInfo')
    TextForDescription = [TextForDescription,newline];
    AllFields = fieldnames(ExpeInfo.ElecStimInfo);
    TextForDescription = [TextForDescription,newline,'Is stim session: ', num2str(ExpeInfo.StimSession)];
    
    for ff = 1:length(AllFields)
        if not(isstring(ExpeInfo.ElecStimInfo.(AllFields{ff})))
            temp = num2str(ExpeInfo.ElecStimInfo.(AllFields{ff}));
        else
            temp = (ExpeInfo.ElecStimInfo.(AllFields{ff}));
        end
        TextForDescription = [TextForDescription,newline,AllFields{ff},': ',temp];
    end
end

if isfield(ExpeInfo,'DrugInfo')
    TextForDescription = [TextForDescription,newline];
    AllFields = fieldnames(ExpeInfo.DrugInfo);
    for ff = 1:length(AllFields)
        if not(isstring(ExpeInfo.DrugInfo.(AllFields{ff})))
            temp = num2str(ExpeInfo.DrugInfo.(AllFields{ff}));
        else
            temp = (ExpeInfo.DrugInfo.(AllFields{ff}));
        end
        TextForDescription = [TextForDescription,newline,AllFields{ff},': ',temp];
    end
end

%% Added 20/01/2025 - list all channels
TextForDescription = [TextForDescription,newline];
for ii = 1 : length(ExpeInfo.InfoLFP.structure)
    if strcmp(ExpeInfo.InfoLFP.structure{ii},'Nthg') ==0
        TextForDescription = [TextForDescription,num2str(ExpeInfo.InfoLFP.channel(ii)), ' : ', ExpeInfo.InfoLFP.structure{ii},newline];
    end
end

XmlStructure.parameters.generalInfo.description.Text = TextForDescription;
if isfield(ExpeInfo,'Comments')
    XmlStructure.parameters.generalInfo.notes.Text = ExpeInfo.Comments;
else
    XmlStructure.parameters.generalInfo.notes.Text = 'No comments';
end

%% Acquisition system
XmlStructure.parameters.acquisitionSystem.nChannels.Text = ExpeInfo.PreProcessingInfo.TotalChannels;
% save the new file
struct2xml_SB(XmlStructure,'amplifier.xml');
XmlStructure = xml2struct_SB('amplifier.xml');

%% Order the LFP channels
InfoLFPNomenclature
CountChanGroups = 1;
for rr = 1:length(RegionName)
    RegionChannels = find(strcmp(RegionName{rr},ExpeInfo.InfoLFP.structure))-1;
    if not(isempty(RegionChannels))
        for ch = 1:length(RegionChannels)
            XmlStructure.parameters.anatomicalDescription.channelGroups.group{CountChanGroups}.channel{ch}.Text = num2str(RegionChannels(ch));
            XmlStructure.parameters.anatomicalDescription.channelGroups.group{CountChanGroups}.channel{ch}.Attributes.skip = '0';
        end
        CountChanGroups = CountChanGroups+1;
    end
    
end

%% Put the spike groups
if isfield(ExpeInfo,'SpikeGroupInfo')
    
    % timing of periods for spike threshold
    % find the right ndm code in the xml structure
    for j = 1:length(XmlStructure.parameters.programs.program)
        if strcmp(XmlStructure.parameters.programs.program{j}.name.Text,'ndm_extractspikes')
            ProgramNum = j;
        end
    end
    % find the right parameters within the code
    for k = 1:length(XmlStructure.parameters.programs.program{ProgramNum}.parameters.parameter)
        if strcmp(XmlStructure.parameters.programs.program{ProgramNum}.parameters.parameter{k}.name.Text,'start')
            XmlStructure.parameters.programs.program{ProgramNum}.parameters.parameter{k}.value.Text = ExpeInfo.SpikeGroupInfo.BeginThresholdCalc;
        end
    end
    for k = 1:length(XmlStructure.parameters.programs.program{ProgramNum}.parameters.parameter)
        if strcmp(XmlStructure.parameters.programs.program{ProgramNum}.parameters.parameter{k}.name.Text,'duration')
            XmlStructure.parameters.programs.program{ProgramNum}.parameters.parameter{k}.value.Text = ExpeInfo.SpikeGroupInfo.EndThresholdCalc-ExpeInfo.SpikeGroupInfo.BeginThresholdCalc;
        end
    end
    
    for ch = 1:length(ExpeInfo.SpikeGroupInfo.ChanNames)
        RegionChannels = strsplit(ExpeInfo.SpikeGroupInfo.ChanNames{ch},' ');
        for r = 1:length(RegionChannels)
            XmlStructure.parameters.spikeDetection.channelGroups.group{ch}.channels.channel{r}.Text = RegionChannels{r};
            XmlStructure.parameters.spikeDetection.channelGroups.group{ch}.nSamples.Text  = '32';
            XmlStructure.parameters.spikeDetection.channelGroups.group{ch}.peakSampleIndex.Text  = '14';
            XmlStructure.parameters.spikeDetection.channelGroups.group{ch}.nFeatures.Text = '4';
        end
    end
end

struct2xml_SB(XmlStructure,'amplifier.xml');
XmlStructure = xml2struct_SB('amplifier.xml');

%% Put the colors
InfoLFPNomenclature
for ch = 1:length(ExpeInfo.InfoLFP.structure)
    XmlStructure.parameters.neuroscope.channels.channelColors{ch}.color.Text = RegionColors{find(strcmp(RegionName,ExpeInfo.InfoLFP.structure{ch}))};
    XmlStructure.parameters.neuroscope.channels.channelColors{ch}.anatomyColor.Text = RegionColors{find(strcmp(RegionName,ExpeInfo.InfoLFP.structure{ch}))};
end

struct2xml_SB(XmlStructure,'amplifier.xml');
XmlStructure = xml2struct_SB('amplifier.xml');

%% Fix the plugins
% ndm_mergedat
% find the right ndm code in the xml structure
for j = 1:length(XmlStructure.parameters.programs.program)
    if strcmp(XmlStructure.parameters.programs.program{j}.name.Text,'ndm_mergedat')
        ProgramNum = j;
    end
end

% find the right parameters within the code
for k = 1:length(XmlStructure.parameters.programs.program{ProgramNum}.parameters.parameter)
    if strcmp(XmlStructure.parameters.programs.program{ProgramNum}.parameters.parameter{k}.name.Text,'nChannels')
        %w wideband - accelero - analog - digital
        MergeString = num2str(ExpeInfo.PreProcessingInfo.NumWideband);
        if ExpeInfo.PreProcessingInfo.NumAccelero>0
            MergeString = [MergeString ' ' num2str(ExpeInfo.PreProcessingInfo.NumAccelero)];
        end
        if ExpeInfo.PreProcessingInfo.NumAnalog>0
            MergeString = [MergeString ' ' num2str(ExpeInfo.PreProcessingInfo.NumAnalog)];
        end
        if ExpeInfo.PreProcessingInfo.NumDigChan>0
            if strcmp(ExpeInfo.PreProcessingInfo.TypeOfSystem, 'Intan')
                MergeString = [MergeString ' ' num2str(ExpeInfo.PreProcessingInfo.NumDigChan)];
            end
        end
        
        XmlStructure.parameters.programs.program{ProgramNum}.parameters.parameter{k}.value.Text = MergeString;
    elseif strcmp(XmlStructure.parameters.programs.program{ProgramNum}.parameters.parameter{k}.name.Text,'suffixes')
        %w wideband - accelero - analog - digital
        MergeStringSuff = 'wideband';
        if ExpeInfo.PreProcessingInfo.NumAccelero>0
            MergeStringSuff = [MergeStringSuff ' accelero'];
        end
        if ExpeInfo.PreProcessingInfo.NumAnalog>0
            MergeStringSuff = [MergeStringSuff ' analogin'];
        end
        if ExpeInfo.PreProcessingInfo.NumDigChan>0
            if strcmp(ExpeInfo.PreProcessingInfo.TypeOfSystem, 'Intan')
                MergeStringSuff = [MergeStringSuff ' digin'];
            end
        end
        
        XmlStructure.parameters.programs.program{ProgramNum}.parameters.parameter{k}.value.Text = MergeStringSuff;
 
    end
end

struct2xml_SB(XmlStructure,'amplifier.xml');
XmlStructure = xml2struct_SB('amplifier.xml');
