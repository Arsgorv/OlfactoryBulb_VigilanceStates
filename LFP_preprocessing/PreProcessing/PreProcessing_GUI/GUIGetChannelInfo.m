function varargout = GUIGetChannelInfo(varargin)
% GUIGETCHANNELINFO MATLAB code for GUIGetChannelInfo.fig %
%      GUIGETCHANNELINFO, by itself, creates a new GUIGETCHANNELINFO or raises the existing
%      singleton*.
%
%      H = GUIGETCHANNELINFO returns the handle to a new GUIGETCHANNELINFO or the handle to
%      the existing singleton*.
%
%      GUIGETCHANNELINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIGETCHANNELINFO.M with the given input arguments.
%
%      GUIGETCHANNELINFO('Property','Value',...) creates a new GUIGETCHANNELINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIGetChannelInfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIGetChannelInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIGetChannelInfo

% Last Modified by GUIDE v2.5 18-Dec-2018 11:36:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUIGetChannelInfo_OpeningFcn, ...
    'gui_OutputFcn',  @GUIGetChannelInfo_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUIGetChannelInfo is made visible.
function GUIGetChannelInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIGetChannelInfo (see VARARGIN)
load('ExpeInfo.mat')

ExpeInfo.PreProcessingInfo.TotalChannels = ExpeInfo.PreProcessingInfo.NumAccelero + ExpeInfo.PreProcessingInfo.NumAnalog + ExpeInfo.PreProcessingInfo.NumDigChan + ExpeInfo.PreProcessingInfo.NumWideband;

if not(isfield(ExpeInfo,'InfoLFP')) || length(ExpeInfo.InfoLFP.channel)~=ExpeInfo.PreProcessingInfo.TotalChannels
    
    ExpeInfo.InfoLFP = struct;
    ExpeInfo.InfoLFP.channel = [0:ExpeInfo.PreProcessingInfo.TotalChannels-1];
    ExpeInfo.InfoLFP.structure = cell(1,ExpeInfo.PreProcessingInfo.TotalChannels);
    for k = 1 : ExpeInfo.PreProcessingInfo.TotalChannels
        ExpeInfo.InfoLFP.depth(k) = -1;
        ExpeInfo.InfoLFP.hemisphere{k} = 'R';
    end
    
end

%% we can already fill in the accelerometer, digital and analog channels
if ExpeInfo.PreProcessingInfo.NumAccelero>0
ExpeInfo.InfoLFP.structure{ExpeInfo.PreProcessingInfo.NumWideband+1}  = 'Accelero';
ExpeInfo.InfoLFP.structure{ExpeInfo.PreProcessingInfo.NumWideband+2}  = 'Accelero';
ExpeInfo.InfoLFP.structure{ExpeInfo.PreProcessingInfo.NumWideband+3}  = 'Accelero';
end
if ExpeInfo.PreProcessingInfo.NumDigChan>0
ExpeInfo.InfoLFP.structure{ExpeInfo.PreProcessingInfo.NumWideband+ExpeInfo.PreProcessingInfo.NumAccelero+1}  = 'Digin';
end
if ExpeInfo.PreProcessingInfo.NumAnalog>0
    for nn = 1:ExpeInfo.PreProcessingInfo.NumAnalog
ExpeInfo.InfoLFP.structure{ExpeInfo.PreProcessingInfo.NumWideband+ExpeInfo.PreProcessingInfo.NumAccelero+ExpeInfo.PreProcessingInfo.NumDigChan+nn}  = 'AnalogInput';
    end
end

handles.ExpeInfo = ExpeInfo;
guidata(hObject, handles);


% This is adapted for max 150 channels
for col = 1 : 5
    
    for k = 30*(col-1) : min(ExpeInfo.PreProcessingInfo.TotalChannels-1,30*col-1)
        handles.(['ChanNum',num2str(k)])= uicontrol(handles.figure1,'style','text',...
            'units','normalized','position',[0.0+((col-1)*0.2) 0.95-(0.95/32)*(k-30*(col-1)+1) 0.02 0.02],...
            'string',num2str(k));
        
        handles.(['Structure',num2str(k)])= uicontrol(handles.figure1,'style','popupmenu',...
            'units','normalized','position',[0.03+((col-1)*0.2) 0.95-(0.95/32)*(k-30*(col-1)+1) 0.05 0.02],...
            'callback', {@GetStructureName,k});
        
        InfoLFPNomenclature
        set( handles.(['Structure',num2str(k)]),'string',strjoin(RegionName,'|'))
        
        handles.(['Hemisphere',num2str(k)])= uicontrol(handles.figure1,'style','popupmenu',...
            'units','normalized','position',[0.09+((col-1)*0.2) 0.95-(0.95/32)*(k-30*(col-1)+1) 0.03 0.02],...
            'callback', {@GetHemisphere,k});
        set( handles.(['Hemisphere',num2str(k)]),'string',strjoin(HemisphereName,'|'))
        
        handles.(['Depth',num2str(k)])= uicontrol(handles.figure1,'style','popupmenu',...
            'units','normalized','position',[0.13+((col-1)*0.2) 0.95-(0.95/32)*(k-30*(col-1)+1) 0.05 0.02],...
            'callback', {@GetDepth,k});
        set( handles.(['Depth',num2str(k)]),'string',strjoin(DepthsExpl,'|'))
        
        if isfield(ExpeInfo,'InfoLFP')
            try
            if not(isempty(ExpeInfo.InfoLFP.structure{k+1}))
                set(handles.(['Structure',num2str(k)]),'Value',find(strcmp(RegionName,ExpeInfo.InfoLFP.structure{k+1})))
                set(handles.(['Structure',num2str(k)]),'BackGroundColor',hex2rgb(RegionColors{find(strcmp(RegionName,ExpeInfo.InfoLFP.structure{k+1}))}))
            
            set(handles.(['Depth',num2str(k)]),'Value',find(strcmp(Depths,num2str(ExpeInfo.InfoLFP.depth(k+1)))))
            set(handles.(['Depth',num2str(k)]),'BackGroundColor',hex2rgb(RegionColors{find(strcmp(RegionName,ExpeInfo.InfoLFP.structure{k+1}))}))
            set(handles.(['Hemisphere',num2str(k)]),'Value',find(strcmp(HemisphereName,ExpeInfo.InfoLFP.hemisphere{k+1})))
            set(handles.(['Hemisphere',num2str(k)]),'BackGroundColor',hex2rgb(RegionColors{find(strcmp(RegionName,ExpeInfo.InfoLFP.structure{k+1}))}))
            end
            end
        end
        
    end
    
end

if sum(~cellfun(@isempty,ExpeInfo.InfoLFP.structure),2) == ExpeInfo.PreProcessingInfo.TotalChannels
    set(handles.FinishedNamingChannels,'enable','on')
end

set(handles.RecapChannels,'string',['LFP: ' num2str(ExpeInfo.PreProcessingInfo.NumWideband) ' Dig: ' num2str(ExpeInfo.PreProcessingInfo.NumDigChan),...
    ' Accelero: ' num2str(ExpeInfo.PreProcessingInfo.NumAccelero) ' Analog: ' num2str(ExpeInfo.PreProcessingInfo.NumAnalog)]);
% Choose default command line output for GUIGetChannelInfo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


function varargout = GUIGetChannelInfo_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;



% Puts the structurename in to InfoLFP
function GetStructureName(hObject, eventdata, Num)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.InfoLFP.structure{Num+1} = strtrim(items(get(hObject,'Value'),:));
InfoLFPNomenclature
set(TempData.(['Structure',num2str(Num)]),'BackGroundColor',hex2rgb(RegionColors{find(strcmp(RegionName,TempData.ExpeInfo.InfoLFP.structure{Num+1}))}))
guidata(hObject,TempData)
if sum(~cellfun(@isempty,TempData.ExpeInfo.InfoLFP.structure),2) == TempData.ExpeInfo.PreProcessingInfo.TotalChannels
    set(TempData.FinishedNamingChannels,'enable','on')
end

% Puts the hemisphere in to InfoLFP
function GetHemisphere(hObject, eventdata, Num)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.InfoLFP.hemisphere{Num+1} = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
InfoLFPNomenclature
set(TempData.(['Hemisphere',num2str(Num)]),'BackGroundColor',hex2rgb(RegionColors{find(strcmp(RegionName,TempData.ExpeInfo.InfoLFP.structure{Num+1}))}))


% Puts the structurename in to InfoLFP
function GetDepth(hObject, eventdata, Num)
TempData = guidata(hObject);
InfoLFPNomenclature
items = Depths;
TempData.ExpeInfo.InfoLFP.depth(Num+1) = (eval(items{get(hObject,'Value')}));
set(TempData.(['Depth',num2str(Num)]),'BackGroundColor',[0.8 0.4 0.2])
guidata(hObject,TempData)
InfoLFPNomenclature
try
set(TempData.(['Depth',num2str(Num)]),'BackGroundColor',hex2rgb(RegionColors{find(strcmp(RegionName,TempData.ExpeInfo.InfoLFP.structure{Num+1}))}))
end


% --- Executes during object creation, after setting all properties.
function RecapChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RecapChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in FinishedNamingChannels.
function FinishedNamingChannels_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo  = TempData.ExpeInfo;
ExpeInfo.InfoLFP
save(['ExpeInfo.mat'],'ExpeInfo')
ExpeInfo.InfoLFP
delete(TempData.figure1)


function FinishedNamingChannels_CreateFcn(hObject, eventdata, handles)


function MultiChannelDefine_Callback(hObject, eventdata, handles)
% Get the info about many channels at the same time
OutputIn = MultiChannelDefine;
OutputIn
% Put this into ExpeInfo and update display
InfoLFPNomenclature
TempData = guidata(hObject);

OutputIn.ChanList = eval(OutputIn.ChanList{1});
for k = 1 :length(OutputIn.ChanList)
    if not(isempty((OutputIn.ChanList(k))))
        
        channum = (OutputIn.ChanList(k));
        
        TempData.ExpeInfo.InfoLFP.structure{channum+1} = OutputIn.ChanRegion;
        TempData.ExpeInfo.InfoLFP.hemisphere{channum+1} = OutputIn.ChanHemisphere;
        TempData.ExpeInfo.InfoLFP.depth(channum+1) = OutputIn.ChanDepth;
        
        set(TempData.(['Structure',num2str(channum)]),'BackGroundColor',hex2rgb(RegionColors{find(strcmp(RegionName,TempData.ExpeInfo.InfoLFP.structure{channum+1}))}))
        set(TempData.(['Depth',num2str(channum)]),'BackGroundColor',hex2rgb(RegionColors{find(strcmp(RegionName,TempData.ExpeInfo.InfoLFP.structure{channum+1}))}))
        set(TempData.(['Hemisphere',num2str(channum)]),'BackGroundColor',hex2rgb(RegionColors{find(strcmp(RegionName,TempData.ExpeInfo.InfoLFP.structure{channum+1}))}))

        if not(isempty(TempData.ExpeInfo.InfoLFP.structure{channum+1}))
            set(TempData.(['Structure',num2str(channum)]),'Value',find(strcmp(RegionName,TempData.ExpeInfo.InfoLFP.structure{channum+1})))
        end
        set(TempData.(['Depth',num2str(channum)]),'Value',find(strcmp(Depths,num2str(TempData.ExpeInfo.InfoLFP.depth(channum+1)))))
        set(TempData.(['Hemisphere',num2str(channum)]),'Value',find(strcmp(HemisphereName,TempData.ExpeInfo.InfoLFP.hemisphere{channum+1})))
        
    end
end

if sum(~cellfun(@isempty,TempData.ExpeInfo.InfoLFP.structure),2) == TempData.ExpeInfo.PreProcessingInfo.TotalChannels
    set(TempData.FinishedNamingChannels,'enable','on')
end
guidata(hObject,TempData)

