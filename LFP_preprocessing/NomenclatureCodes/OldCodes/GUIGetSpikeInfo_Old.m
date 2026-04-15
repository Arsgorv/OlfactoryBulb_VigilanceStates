function varargout = GUIGetSpikeInfo(varargin)
% GUIGETSPIKEINFO MATLAB code for GUIGetSpikeInfo.fig
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

% Last Modified by GUIDE v2.5 19-Dec-2018 12:28:16

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
if isfield(ExpeInfo.SpikeGroupInfo,'ChanNames') && not(length(ExpeInfo.SpikeGroupInfo.ChanNames)==SpikeGroupNum)
    ExpeInfo.SpikeGroupInfo = rmfield(ExpeInfo.SpikeGroupInfo,'ChanNames');
    ExpeInfo.SpikeGroupInfo.UseForElecSub =zeros(1,SpikeGroupNum);
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

for k = 1 : SpikeGroupNum
    
    handles.(['SpikeGroupNum',num2str(k)])= uicontrol(handles.figure1,'style','text',...
        'units','normalized','position',[0.05 0.9-(0.9/(SpikeGroupNum+1))*k 0.04 0.04],...
        'string',num2str(k));
    
    handles.(['ListOfChannels',num2str(k)])= uicontrol(handles.figure1,'style','edit',...
        'units','normalized','position',[0.15 0.9-(0.9/(SpikeGroupNum+1))*k 0.4 0.04],'String','ChanNum here',...
        'callback', {@ChannelList,k});
    
    handles.(['UseForElecSub',num2str(k)])= uicontrol(handles.figure1,'style','checkbox',...
        'units','normalized','position',[0.7 0.9-(0.9/(SpikeGroupNum+1))*k 0.3 0.04],'String','Use for elec sub?',...
        'callback', {@UseForElecSub,k});
    
    if isfield(ExpeInfo.SpikeGroupInfo,'ChanNames')
        set(handles.(['ListOfChannels',num2str(k)]),'String',ExpeInfo.SpikeGroupInfo.ChanNames{k});
        set(handles.(['UseForElecSub',num2str(k)]),'Value',ExpeInfo.SpikeGroupInfo.UseForElecSub(k));
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
TempData.ExpeInfo.SpikeGroupInfo.ChanNames{Num} = get(hObject,'String');
set(TempData.(['SpikeGroupNum',num2str(Num)]),'BackGroundColor',[0.8 0.4 0.2])

guidata(hObject,TempData)

if sum(~cellfun(@isempty,TempData.ExpeInfo.SpikeGroupInfo.ChanNames),2) == TempData.ExpeInfo.SpikeGroupInfo.SpikeGroupNum
    set(TempData.ImDone,'enable','on')
end


% Marks whether or not the channels should be used for subtraction
function UseForElecSub(hObject, eventdata, Num)
TempData = guidata(hObject);
TempData.ExpeInfo.SpikeGroupInfo.UseForElecSub(Num) = get(hObject,'Value');
guidata(hObject,TempData)


% --- Executes on button press in ImDone.
function ImDone_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo = TempData.ExpeInfo;
ExpeInfo.SpikeGroupInfo
save('ExpeInfo.mat','ExpeInfo')
delete(TempData.figure1)



function TetrodeRefNumEdit_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.SpikeGroupInfo.ElecsToSub = get(hObject,'String');
guidata(hObject,TempData)


function TetrodeRefNumEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NoRefSubCheckbox_Callback(hObject, eventdata, handles)
if get(hObject,'value')
    TempData = guidata(hObject);
    TempData.ExpeInfo.SpikeGroupInfo.ElecsToSub = {};
    guidata(hObject,TempData)
end



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
