%% Get ExpeInfo Location % 
ExpeInfoLocation=uigetdir('','Folder with ExpeInfo');
load([ExpeInfoLocation,'ExpeInfo.mat'],'ExpeInfo');
save('FolderName.mat','ExpeInfoLocation')


%% Ask how many channels
Questions={'Num Wideband Channels','Num Accelero Channels', 'Num DigInChannels',
    'SpikeData (yes/no)', 'INTAN accelero', 'INTAN Digital input', 'INTAN Analog input'};
answer = inputdlg(Questions, 'Inputs for makeData', 1, defaultvalues);



%% create makedataBulbeInputs

%inputdlg input 
defaultvalues={'yes', 'yes', 'yes', 'yes'};
Questions={'SpikeData (yes/no)', 'INTAN accelero', 'INTAN Digital input', 'INTAN Analog input'};

%check if makedataBulbeInputs already exists 
try
    load('makedataBulbeInputs')
    if length(defaultvalues)==length(answer)
        defaultvalues=answer;
    end
    
catch
    disp('error when loading makedataBulbeInputs')
end

%inputdlg
answer = inputdlg(Questions, 'Inputs for makeData', 1, defaultvalues);

spk=strcmp(answer{1},'yes');
doaccelero=strcmp(answer{2},'yes');
dodigitalin=strcmp(answer{3},'yes');
doanalogin=strcmp(answer{4},'yes');
%digital
if dodigitalin==1
    answerdigin = inputdlg({'Digital channel','Number of inputs'},'DigIn Info',1);
else
    answerdigin=[];
end
%analog
if doanalogin==1
    answeranalogin = inputdlg({'Analog channel','Number of inputs'},'AnalogIn Info',1);
else
    answeranalogin=[];
end

%save
save makedataBulbeInputs answer answerdigin Questions spk doaccelero dodigitalin answeranalogin doanalogin

%% Ask how many diginfo channels


%% Generate window with everything to fill in


%% Some help me out buttons
% HPC depths
% PFC depths
% OB depths

%% Do ChannelsToAnalyse


