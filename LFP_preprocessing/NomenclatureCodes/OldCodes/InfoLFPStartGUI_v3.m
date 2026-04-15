function varargout = InfoLFPStartGUI_v3(varargin)
% INFOLFPSTARTGUI_V3 MATLAB code for InfoLFPStartGUI_v3.fig
%      INFOLFPSTARTGUI_V3, by itself, creates a new INFOLFPSTARTGUI_V3 or raises the existing
%      singleton*.
%
%      H = INFOLFPSTARTGUI_V3 returns the handle to a new INFOLFPSTARTGUI_V3 or the handle to
%      the existing singleton*.
%
%      INFOLFPSTARTGUI_V3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INFOLFPSTARTGUI_V3.M with the given input arguments.
%
%      INFOLFPSTARTGUI_V3('Property','Value',...) creates a new INFOLFPSTARTGUI_V3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before InfoLFPStartGUI_v3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to InfoLFPStartGUI_v3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help InfoLFPStartGUI_v3

% Last Modified by GUIDE v2.5 14-Dec-2018 13:19:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @InfoLFPStartGUI_v3_OpeningFcn, ...
    'gui_OutputFcn',  @InfoLFPStartGUI_v3_OutputFcn, ...
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


% --- Executes just before InfoLFPStartGUI_v3 is made visible.
function InfoLFPStartGUI_v3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to InfoLFPStartGUI_v3 (see VARARGIN)

% Choose default command line output for InfoLFPStartGUI_v3
handles.output = hObject;
load('ExpeInfo.mat')
handles.ExpeInfo = ExpeInfo;
if isfield(ExpeInfo,'PreProcessingInfo')
    if isfield(ExpeInfo.PreProcessingInfo,'NumWideband')
    set(handles.NumWideband,'String',num2str(ExpeInfo.PreProcessingInfo.NumWideband))
    set(handles.NumWideband,'BackgroundColor',[0.8 0.4 0.2])
    else
        handles.ExpeInfo.PreProcessingInfo.NumWideband = 0;
    end
    
    if isfield(ExpeInfo.PreProcessingInfo,'NumAccelero')
    set(handles.NumAccelero,'String',num2str(ExpeInfo.PreProcessingInfo.NumAccelero))
    set(handles.NumAccelero,'BackgroundColor',[0.8 0.4 0.2])
    else
            handles.ExpeInfo.PreProcessingInfo.NumAccelero = 0;
    end
    
    if isfield(ExpeInfo.PreProcessingInfo,'NumDigChan')
    set(handles.NumDigChan,'String',num2str(ExpeInfo.PreProcessingInfo.NumDigChan))
    set(handles.NumDigChan,'BackgroundColor',[0.8 0.4 0.2])
    else
        handles.ExpeInfo.PreProcessingInfo.NumDigChan = 0;
    end
    
    if isfield(ExpeInfo.PreProcessingInfo,'NumAnalog')
    set(handles.NumAnalog,'String',num2str(ExpeInfo.PreProcessingInfo.NumAnalog))
    set(handles.NumAnalog,'BackgroundColor',[0.8 0.4 0.2])
    else
          handles.ExpeInfo.PreProcessingInfo.NumAnalog = 0;  
    end 
    
    if isfield(ExpeInfo.PreProcessingInfo,'NumDigInput')
        set(handles.NumDigInput,'String',num2str(ExpeInfo.PreProcessingInfo.NumDigInput))
        set(handles.NumDigInput,'BackgroundColor',[0.8 0.4 0.2])
    else
        handles.ExpeInfo.PreProcessingInfo.NumDigInput = 0;
    end

    if isfield(ExpeInfo.PreProcessingInfo,'DoSpikes')
        set(handles.SpikeBox,'value',ExpeInfo.PreProcessingInfo.DoSpikes)
    else
        handles.ExpeInfo.PreProcessingInfo.DoSpikes = 0; 
    end

   
else
    handles.ExpeInfo.PreProcessingInfo = struct;
    handles.ExpeInfo.PreProcessingInfo.NumWideband = 0;
    handles.ExpeInfo.PreProcessingInfo.NumAccelero = 0;
    handles.ExpeInfo.PreProcessingInfo.NumDigChan = 0;
    handles.ExpeInfo.PreProcessingInfo.NumDigInput = 0;
    handles.ExpeInfo.PreProcessingInfo.NumAnalog = 0;
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes InfoLFPStartGUI_v3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = InfoLFPStartGUI_v3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function NumWideband_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.PreProcessingInfo.NumWideband = eval(get(hObject,'String'));
guidata(hObject,TempData)


% --- Executes during object creation, after setting all properties.
function NumWideband_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumWideband (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in NumAccelero.
function NumAccelero_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.PreProcessingInfo.NumAccelero = eval(items{get(hObject,'Value')});
guidata(hObject,TempData)



% --- Executes during object creation, after setting all properties.
function NumAccelero_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumAccelero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in NumDigChan.
function NumDigChan_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.PreProcessingInfo.NumDigChan = eval(items{get(hObject,'Value')});
guidata(hObject,TempData)


% --- Executes during object creation, after setting all properties.
function NumDigChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumDigChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumAnalog_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.PreProcessingInfo.NumAnalog = eval(get(hObject,'String'));
guidata(hObject,TempData)


% --- Executes during object creation, after setting all properties.
function NumAnalog_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumAnalog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumDigInput_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.PreProcessingInfo.NumDigInput = eval(get(hObject,'String'));
guidata(hObject,TempData)



% --- Executes during object creation, after setting all properties.
function NumDigInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumDigInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HelpDigin.
function HelpDigin_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
switch TempData.DigInfoExplanation1.Visible
    case 'on'
        set(TempData.DigInfoExplanation1,'Visible','off')
        set(TempData.DigInfoExplanation2,'Visible','off')
    case 'off'
        set(TempData.DigInfoExplanation1,'Visible','on')
        set(TempData.DigInfoExplanation2,'Visible','on')
end

% --- Executes on button press in SpikeBox.
function SpikeBox_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.PreProcessingInfo.DoSpikes = hObject.Value;
guidata(hObject,TempData)

% --- Executes on button press in DoneWithOptions.
function DoneWithOptions_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo = TempData.ExpeInfo;
save('ExpeInfo.mat','ExpeInfo')
set(TempData.InfoLFPButton,'enable','on');
set(TempData.DigChanIdButton,'enable','on');
set(TempData.GetChanToAnalayseButton,'enable','on');


% --- Executes during object creation, after setting all properties.
function DoneWithOptions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DoneWithOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in InfoLFPButton.
function InfoLFPButton_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo = TempData.ExpeInfo;
save('ExpeInfo.mat','ExpeInfo')
GUIGetChannelInfo
FigureID = guidata(GUIGetChannelInfo);
waitfor(FigureID.figure1)
load('ExpeInfo.mat','ExpeInfo')
TempData.ExpeInfo = ExpeInfo;
guidata(hObject,TempData)



% --- Executes during object creation, after setting all properties.
function InfoLFPButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InfoLFPButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in DigChanIdButton.
function DigChanIdButton_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo = TempData.ExpeInfo;
save('ExpeInfo.mat','ExpeInfo')
GUIGetDigitalInfo
FigureID = guidata(GUIGetDigitalInfo);
waitfor(FigureID.figure1)
load('ExpeInfo.mat','ExpeInfo')
TempData.ExpeInfo = ExpeInfo;
guidata(hObject,TempData)


% --- Executes during object creation, after setting all properties.
function DigChanIdButton_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DigChanIdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in GetChanToAnalayseButton.
function GetChanToAnalayseButton_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo = TempData.ExpeInfo;
save('ExpeInfo.mat','ExpeInfo')
GUIGetChannelsToAnalyse
load('ExpeInfo.mat','ExpeInfo')
TempData.ExpeInfo = ExpeInfo;
guidata(hObject,TempData)



function GetChanToAnalayseButton_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in GuiSpikeChannels.
function GuiSpikeChannels_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo = TempData.ExpeInfo;
save('ExpeInfo.mat','ExpeInfo')
GUIGetSpikeInfo
FigureID = guidata(GUIGetSpikeInfo);
waitfor(FigureID.figure1)
load('ExpeInfo.mat','ExpeInfo')
TempData.ExpeInfo = ExpeInfo;
guidata(hObject,TempData)
