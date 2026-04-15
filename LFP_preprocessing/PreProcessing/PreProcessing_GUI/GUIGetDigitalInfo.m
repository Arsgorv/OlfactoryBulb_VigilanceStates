function varargout = GUIGetDigitalInfo(varargin)
% GUIGETDIGITALINFO MATLAB code for GUIGetDigitalInfo.fig %
%      GUIGETDIGITALINFO, by itself, creates a new GUIGETDIGITALINFO or raises the existing
%      singleton*.
%
%      H = GUIGETDIGITALINFO returns the handle to a new GUIGETDIGITALINFO or the handle to
%      the existing singleton*.
%
%      GUIGETDIGITALINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIGETDIGITALINFO.M with the given input arguments.
%
%      GUIGETDIGITALINFO('Property','Value',...) creates a new GUIGETDIGITALINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIGetDigitalInfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIGetDigitalInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIGetDigitalInfo

% Last Modified by GUIDE v2.5 13-Dec-2018 19:41:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUIGetDigitalInfo_OpeningFcn, ...
    'gui_OutputFcn',  @GUIGetDigitalInfo_OutputFcn, ...
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
function GUIGetDigitalInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIGetChannelInfo (see VARARGIN)
load('ExpeInfo.mat')

NumDigIn = ExpeInfo.PreProcessingInfo.NumDigInput;
  
if isfield(ExpeInfo,'DigID') && length(ExpeInfo.DigID) ~= NumDigIn
    ExpeInfo = rmfield(ExpeInfo,'DigID');
end
    
for k = 1 : NumDigIn
    
    handles.(['ChanNum',num2str(k)])= uicontrol(handles.figure1,'style','text',...
        'units','normalized','position',[0.05 0.95-(0.95/(NumDigIn+1))*k 0.02 0.1],...
        'string',num2str(k));
    
    handles.(['DigInput',num2str(k)])= uicontrol(handles.figure1,'style','popupmenu',...
        'units','normalized','position',[0.1 0.95-(0.95/(NumDigIn+1))*k 0.35 0.1],...
        'callback', {@GetDigInputName,k});
    DigitalChannelNomenclature
    set( handles.(['DigInput',num2str(k)]),'string',strjoin(DigInputName,'|'))
    
    if isfield(ExpeInfo,'DigID')
    set(handles.(['DigInput',num2str(k)]),'Value',find(strcmp(DigInputName,ExpeInfo.DigID{k})))
    set(handles.(['DigInput',num2str(k)]),'BackGroundColor',[0.8 0.4 0.2])
    end
    
end

if isfield(ExpeInfo,'DigID')
    if sum(~cellfun(@isempty,ExpeInfo.DigID),2) == NumDigIn
        set(handles.ImDoneButton,'enable','on')
    end
end

    
% Choose default command line output for GUIGetChannelInfo
handles.output = hObject;
handles.ExpeInfo = ExpeInfo;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUIGetChannelInfo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIGetDigitalInfo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% Puts the structurename in to InfoLFP
function GetDigInputName(hObject, eventdata, Num)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.DigID{Num} = strtrim(items(get(hObject,'Value'),:));
set(TempData.(['DigInput',num2str(Num)]),'BackGroundColor',[0.8 0.4 0.2])
guidata(hObject,TempData)
if sum(~cellfun(@isempty,TempData.ExpeInfo.DigID),2) == TempData.ExpeInfo.PreProcessingInfo.NumDigInput
    set(TempData.ImDoneButton,'enable','on')
end

% --- Executes on button press in FinishedNamingChannels.
function FinishedNamingChannels_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo  = TempData.ExpeInfo;
ExpeInfo
keyboard
save(['ExpeInfo.mat'],'ExpeInfo')
delete(TempData.figure1)


% --- Executes on button press in ImDoneButton.
function ImDoneButton_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo = TempData.ExpeInfo;
ExpeInfo.DigID
save('ExpeInfo.mat','ExpeInfo')
delete(TempData.figure1)


% --- Executes during object creation, after setting all properties.
function ImDoneButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImDoneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
