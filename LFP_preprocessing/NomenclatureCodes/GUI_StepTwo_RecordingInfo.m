function varargout = GUI_StepTwo_RecordingInfo(varargin)
% GUI_STEPTWO_RECORDINGINFO MATLAB code for GUI_StepTwo_RecordingInfo.fig
%      GUI_STEPTWO_RECORDINGINFO, by itself, creates a new GUI_STEPTWO_RECORDINGINFO or raises the existing
%      singleton*.
%
%      H = GUI_STEPTWO_RECORDINGINFO returns the handle to a new GUI_STEPTWO_RECORDINGINFO or the handle to
%      the existing singleton*.
%
%      GUI_STEPTWO_RECORDINGINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_STEPTWO_RECORDINGINFO.M with the given input arguments.
%
%      GUI_STEPTWO_RECORDINGINFO('Property','Value',...) creates a new GUI_STEPTWO_RECORDINGINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_StepTwo_RecordingInfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_StepTwo_RecordingInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_StepTwo_RecordingInfo

% Last Modified by GUIDE v2.5 24-Dec-2018 15:57:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_StepTwo_RecordingInfo_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_StepTwo_RecordingInfo_OutputFcn, ...
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


% --- Executes just before GUI_StepTwo_RecordingInfo is made visible.
function GUI_StepTwo_RecordingInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_StepTwo_RecordingInfo (see VARARGIN)

% Choose default command line output for GUI_StepTwo_RecordingInfo
handles.output = hObject;
handles.figure1.WindowStyle = 'normal';
handles.figure1.DockControls = 'off';

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
    handles.NumAccelero.Value = (ExpeInfo.PreProcessingInfo.NumAccelero/3)+1;
    set(handles.NumAccelero,'BackgroundColor',[0.8 0.4 0.2])
    else
            handles.ExpeInfo.PreProcessingInfo.NumAccelero = 0;
    end
    
    if isfield(ExpeInfo.PreProcessingInfo,'NumDigChan')
        handles.NumDigChan.Value = (ExpeInfo.PreProcessingInfo.NumDigChan)+1;
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
    
    if isfield(ExpeInfo,'ProbeName')
        ProbeNomenclature
        set(handles.SiliconProbeName,'Value',find(strcmp(ProbeName,handles.ExpeInfo.ProbeName)))
        set(handles.SiliconProbeName,'BackgroundColor',[0.8 0.4 0.2])
    else
        handles.ExpeInfo.ProbeName = 'None';
    end

   
else
    handles.ExpeInfo.PreProcessingInfo = struct;
    handles.ExpeInfo.PreProcessingInfo.NumWideband = 0;
    handles.ExpeInfo.PreProcessingInfo.NumAccelero = 0;
    handles.ExpeInfo.PreProcessingInfo.NumDigChan = 0;
    handles.ExpeInfo.PreProcessingInfo.NumDigInput = 0;
    handles.ExpeInfo.PreProcessingInfo.NumAnalog = 0;
    handles.ExpeInfo.PreProcessingInfo.DoSpikes = 0;
    handles.ExpeInfo.ProbeName = 'None';


end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_StepTwo_RecordingInfo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_StepTwo_RecordingInfo_OutputFcn(hObject, eventdata, handles)
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

% Mouse strain
function Probe_List_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
ProbeNomenclature
set(hObject,'string',strjoin(ProbeName,'|'))


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

function ProbeInput_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.ProbeName = strtrim(hObject.String(hObject.Value,:));
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
set(TempData.GetQualChannelButton,'enable','on');
set(TempData.nextstep,'enable','on');
if TempData.ExpeInfo.PreProcessingInfo.DoSpikes ==1
set(TempData.GuiSpikeChannels,'enable','on');
end


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

function GetTopQualitySignalsCheck_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo = TempData.ExpeInfo;
GUITopQualitySignalsCheck
load('ExpeInfo.mat','ExpeInfo')
TempData.ExpeInfo = ExpeInfo;
guidata(hObject,TempData)




function GetChanToAnalayseButton_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in GuiSpikeChannels.
function GuiSpikeChannels_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo = TempData.ExpeInfo;
save('ExpeInfo.mat','ExpeInfo')
FigureID = guidata(GUIGetSpikeInfo);
waitfor(FigureID.figure1)
load('ExpeInfo.mat','ExpeInfo')
TempData.ExpeInfo = ExpeInfo;
guidata(hObject,TempData)


function nextstep_Callback(hObject, eventdata, handles)
close(handles.figure1)
GUI_StepThree_FolderInfo
