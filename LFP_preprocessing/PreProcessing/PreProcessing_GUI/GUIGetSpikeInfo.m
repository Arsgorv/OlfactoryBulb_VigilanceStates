function varargout = GUIGetSpikeInfo(varargin)
% GUIGETSPIKEINFO MATLAB code for GUIGetSpikeInfo.fig % 
%      GUIGETSPIKEINFO, by itself, creates a new GUIGETSPIKEINFO or raises the existing
%      singleton*.
%
%      H = GUIGETSPIKEINFO returns the handle to a new GUIGETSPIKEINFO or the handle to
%      the existing singleton*.
%
%      GUIGETSPIKEINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIGETSPIKEINFO.M with the given input arguments.
%
%      GUIGETSPIKEINFO('Property','Value',...) creates a new GUIGETSPIKEINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIGetSpikeInfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIGetSpikeInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIGetSpikeInfo

% Last Modified by GUIDE v2.5 25-Mar-2019 12:24:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUIGetSpikeInfo_OpeningFcn, ...
    'gui_OutputFcn',  @GUIGetSpikeInfo_OutputFcn, ...
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


% --- Executes just before GUIGetSpikeInfo is made visible.
function GUIGetSpikeInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIGetSpikeInfo (see VARARGIN)

% Choose default command line output for GUIGetSpikeInfo
handles.output = hObject;

load('ExpeInfo.mat')

SpikeGroupNum = inputdlg('Number of spike groups');
SpikeGroupNum = eval(SpikeGroupNum{1});


ExpeInfo.SpikeGroupInfo.SpikeGroupNum = SpikeGroupNum;
if isfield(ExpeInfo.SpikeGroupInfo,'ChanNames') && (not(length(ExpeInfo.SpikeGroupInfo.ChanNames)==SpikeGroupNum) | not(length(ExpeInfo.SpikeGroupInfo.ElecsToSub)==SpikeGroupNum))
    ExpeInfo.SpikeGroupInfo = rmfield(ExpeInfo.SpikeGroupInfo,'ChanNames');
    ExpeInfo.SpikeGroupInfo = rmfield(ExpeInfo.SpikeGroupInfo,'ElecsToSub');
    ExpeInfo.SpikeGroupInfo.ElecsToSub = cell(1,SpikeGroupNum);
end

if not(isfield(ExpeInfo.SpikeGroupInfo,'ElecsToSub'))
    ExpeInfo.SpikeGroupInfo.ElecsToSub = cell(1,SpikeGroupNum);
end

if not(isfield(ExpeInfo.SpikeGroupInfo,'ChanNames'))
    ExpeInfo.SpikeGroupInfo.UseForElecSub =zeros(1,SpikeGroupNum);
end
if not(isfield(ExpeInfo.SpikeGroupInfo,'BeginThresholdCalc'))
ExpeInfo.SpikeGroupInfo.BeginThresholdCalc = 0;
end
if not(isfield(ExpeInfo.SpikeGroupInfo,'EndThresholdCalc'))
ExpeInfo.SpikeGroupInfo.EndThresholdCalc = 60;
end

handles.ExpeInfo = ExpeInfo;

handles.textSpikeGroupNum = uicontrol(handles.figure1,'style','text',...
        'units','normalized','position',[0.15 0.9-(0.9/(SpikeGroupNum+1))+0.04 0.4 0.04],...
        'string','Channels in spike group. Ex : [0:5,9,10]');
    
    handles.textRefNumber = uicontrol(handles.figure1,'style','text',...
        'units','normalized','position',[0.6 0.9-(0.9/(SpikeGroupNum+1))+0.04 0.3 0.04],...
        'string','Channels to average and subtract as reference. Ex : [0:5,9,10]');

for k = 1 : SpikeGroupNum
    
    handles.(['SpikeGroupNum',num2str(k)])= uicontrol(handles.figure1,'style','text',...
        'units','normalized','position',[0.05 0.9-(0.9/(SpikeGroupNum+1))*k 0.04 0.04],...
        'string',num2str(k));
    
    handles.(['ListOfChannels',num2str(k)])= uicontrol(handles.figure1,'style','edit',...
        'units','normalized','position',[0.15 0.9-(0.9/(SpikeGroupNum+1))*k 0.4 0.04],'String','[]',...
        'callback', {@ChannelList,k});
    
    handles.(['ChannelsToSub',num2str(k)])= uicontrol(handles.figure1,'style','edit',...
        'units','normalized','position',[0.6 0.9-(0.9/(SpikeGroupNum+1))*k 0.3 0.04],'String','[]',...
        'callback', {@ChannelRefList,k});
    
    if isfield(ExpeInfo.SpikeGroupInfo,'ChanNames')
        formatchan = ['[' ExpeInfo.SpikeGroupInfo.ChanNames{k}(2:end-1) ']'];
        set(handles.(['ListOfChannels',num2str(k)]),'String',formatchan);
        formatchan = ['[' ExpeInfo.SpikeGroupInfo.ElecsToSub{k}(2:end-1) ']'];
        set(handles.(['ChannelsToSub',num2str(k)]),'String',formatchan);
        set(handles.(['SpikeGroupNum',num2str(k)]),'BackGroundColor',[0.8 0.4 0.2])
    end
    
end


set(handles.ExplainElecSub,'visible','off')

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = GUIGetSpikeInfo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in SubElecHelp.
function SubElecHelp_Callback(hObject, eventdata, handles)

uistack(handles.ExplainElecSub,'top')
switch get(handles.ExplainElecSub,'visible')
    case 'on'
        set(handles.ExplainElecSub,'visible','off')
    case 'off'
        set(handles.ExplainElecSub,'visible','on')
end



% Puts the list of channels into ExpeInfo
function ChannelList(hObject, eventdata, Num)

TempData = guidata(hObject);

Channels = eval(get(hObject,'String'));
if length(Channels)==1
    ChannelsString = num2str(Channels);
else
ChannelsString = '';
for ch = 1:length(Channels)-1
    ChannelsString = strcat(ChannelsString,strcat(num2str(Channels(ch)),{' '}))
end
ChannelsString = strcat(ChannelsString,num2str(Channels(end)));
ChannelsString = ChannelsString{1};
end


TempData.ExpeInfo.SpikeGroupInfo.ChanNames{Num} = ChannelsString;
set(TempData.(['SpikeGroupNum',num2str(Num)]),'BackGroundColor',[0.8 0.4 0.2])

guidata(hObject,TempData)

if sum(~cellfun(@isempty,TempData.ExpeInfo.SpikeGroupInfo.ChanNames),2) == TempData.ExpeInfo.SpikeGroupInfo.SpikeGroupNum
    set(TempData.ImDone,'enable','on')
end



% Puts the list of ref channels to average into ExpeInfo
function ChannelRefList(hObject, eventdata, Num)

TempData = guidata(hObject);

Channels = eval(get(hObject,'String'));
if length(Channels)==1
    ChannelsString = num2str(Channels);
else
ChannelsString = '';
for ch = 1:length(Channels)-1
    ChannelsString = strcat(ChannelsString,strcat(num2str(Channels(ch)),{' '}));
end
ChannelsString = strcat(ChannelsString,num2str(Channels(end)));
ChannelsString = ChannelsString{1};
end

TempData.ExpeInfo.SpikeGroupInfo.ElecsToSub{Num} = ChannelsString;
guidata(hObject,TempData)


% --- Executes on button press in ImDone.
function ImDone_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo = TempData.ExpeInfo;

for k = 1:ExpeInfo.SpikeGroupInfo.SpikeGroupNum
    if not(isempty(ExpeInfo.SpikeGroupInfo.ElecsToSub{k}))
        ExpeInfo.SpikeGroupInfo.UseForElecSub(k) = 1;
    end
end

ExpeInfo.SpikeGroupInfo

save('ExpeInfo.mat','ExpeInfo')
delete(TempData.figure1)



function SpikeThresholdTimePer_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
Temp = strsplit(get(hObject,'String'),' ');
TempData.ExpeInfo.SpikeGroupInfo.BeginThresholdCalc = eval(Temp{1});
TempData.ExpeInfo.SpikeGroupInfo.EndThresholdCalc = eval(Temp{2});
guidata(hObject,TempData)



function SpikeThresholdTimePer_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ThresholdHelp_Callback(hObject, eventdata, handles)
uistack(handles.SpikeExtractionHelp,'top')
switch get(handles.SpikeExtractionHelp,'visible')
    case 'on'
        set(handles.SpikeExtractionHelp,'visible','off')
    case 'off'
        set(handles.SpikeExtractionHelp,'visible','on')
end


% --- Executes on button press in RefForTet.
function RefForTet_Callback(hObject, eventdata, handles)
% Get the info about many channels at the same time

TempData = guidata(hObject);


OutputIn = MultiChannelRefDefine;

% for ch = 1:length(OutputIn.ChanList)
% ChanListToUse(ch) = (eval(OutputIn.ChanList{ch}));
% end

ChanListToUse = (eval(OutputIn.ChanList{1}));

txt = sprintf('%s ',OutputIn.ChanList{:});
txt(end) = [];
OutputIn.TetList = eval(OutputIn.TetList{1});
for tet = 1 : length(OutputIn.TetList)
    TempData.ExpeInfo.SpikeGroupInfo.ElecsToSub{(OutputIn.TetList(tet))} = txt;
    set(TempData.(['ChannelsToSub',num2str((OutputIn.TetList(tet)))]),'String',txt);
end

guidata(hObject,TempData)

