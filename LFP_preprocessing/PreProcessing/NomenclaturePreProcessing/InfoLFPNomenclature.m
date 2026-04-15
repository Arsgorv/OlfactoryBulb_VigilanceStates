% This is the list of 
%   - names for brain regions and types of recordings we make in which we impant electrodes
%   - hemispheres in which we record (so only 2 )
%   - depths at which we record
% If you start recording in a new area add it here
% InfoLFP should only include elements from this nomenclature


%Brain regions
RegionName = ...
    {'Nthg',...
    'dHPC','vHPC',... % this means CA1 by default
    'CA2','CA3','DenG',...
    'PFCx','PaCx','MoCx','AuCx',...    
    'SomCx',...
    'Bulb','PiCx',... % the olfactory bulb
    'VLPO',...
    'NRT',...
    'AuTh',... % auditory thalamus
    'TT',... % Taenia tecta
    'Amyg',...
    'EKG','EMG','EOG',... % Electrocardiogram, Electromyogram (nuchal), Electroocculogram
    'Ref',...
    'Accelero',...
    'Stimulator',...
    'Respi',...
    'LaserInput',...
    'Digin',...
    'AnalogInput',...
    };


% Hemispheres
HemisphereName = ...
    {'R','L','NaN'};

% Recording depths
% DepthsExpl lets the user know what is what
% Depths will be actually used to just stock numerical values
DepthsExpl = ...
    {'-1 : EEG','0 : ECOG','1 : Sup','2 : Mid','3 : Deep','NaN'};
Depths = ...
    {'-1','0','1','2','3','NaN'};

%Brain region colors
RegionColors = ...
    {'#a3a3a3 ',... % empty channels
    '#05ffee','#05ffee',... % this means CA1 by default
    '#05ffee','#05ffee','#05ffee',...
    '#ff0000','#ffb200','#109e09','#ed9a3b',...
    '#ed9a3b',... % somatosensory ctx (same as auditory thalamus)
    '#0F2AC4', '#1166f9',... % the olfactory bulb
    '#e162ea',... % VLPO
    '#964bc1',... % NRT
    '#ed9a3b',... % auditory thalamus
    '#0080ff',... % Taenia tecta
    '#55ff00',...
    '#fff345','#fff345','#fff345',... % Electrocardiogram, Electromyogram (nuchal), Electroocculogram
    '#ffffff',... % ref
    '#8a8a8a',... % accelero
    '#ff00ff',... % stimulator
    '#ff00ff',... % respi
    '#ff00ff',... % laser input
    '#ff00ff',... % digin
    '#ff00ff',... % undefined analog input
    };

% 
% % if you want to have a look at the colors
% clf
% for k =1:length(RegionColors)
%    plot([0:100],[0:100],'linewidth',5,'color',hex2rgb(RegionColors{k})), hold on
% end
% 
% legend(RegionName)