function varargout = InfoLFPStartGUI_v2(varargin)
% INFOLFPSTARTGUI_V2 MATLAB code for InfoLFPStartGUI_v2.fig
%      INFOLFPSTARTGUI_V2, by itself, creates a new INFOLFPSTARTGUI_V2 or raises the existing
%      singleton*.
%
%      H = INFOLFPSTARTGUI_V2 returns the handle to a new INFOLFPSTARTGUI_V2 or the handle to
%      the existing singleton*.
%
%      INFOLFPSTARTGUI_V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INFOLFPSTARTGUI_V2.M with the given input arguments.
%
%      INFOLFPSTARTGUI_V2('Property','Value',...) creates a new INFOLFPSTARTGUI_V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before InfoLFPStartGUI_v2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to InfoLFPStartGUI_v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help InfoLFPStartGUI_v2

% Last Modified by GUIDE v2.5 13-Dec-2018 12:53:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @InfoLFPStartGUI_v2_OpeningFcn, ...
    'gui_OutputFcn',  @InfoLFPStartGUI_v2_OutputFcn, ...
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


% --- Executes just before InfoLFPStartGUI_v2 is made visible.
function InfoLFPStartGUI_v2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to InfoLFPStartGUI_v2 (see VARARGIN)

% Choose default command line output for InfoLFPStartGUI_v2
handles.output = hObject;
load('ExpeInfo.mat')
handles.ExpeInfo = struct;
handles.ExpeInfo.PreProcessingInfo = struct;
handles.ExpeInfo.PreProcessingInfo.NumWideband = 0;
handles.ExpeInfo.PreProcessingInfo.NumAccelero = 0;
handles.ExpeInfo.PreProcessingInfo.NumDigChan = 0;
handles.ExpeInfo.PreProcessingInfo.NumWideband = 0;
handles.ExpeInfo.PreProcessingInfo.MergeDone = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes InfoLFPStartGUI_v2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = InfoLFPStartGUI_v2_OutputFcn(hObject, eventdata, handles)
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
set(TempData.WideBandCheckText,'String',['amplifier.dat with ' num2str(TempData.ExpeInfo.PreProcessingInfo.NumWideband) ' channels'])
if TempData.ExpeInfo.PreProcessingInfo.MergeDone ==1
    set(TempData.mergedfileCheck,'String',['amplifier.dat with ',...
        num2str(TempData.ExpeInfo.PreProcessingInfo.NumAnalog + TempData.ExpeInfo.PreProcessingInfo.NumDigChan + TempData.ExpeInfo.PreProcessingInfo.NumAccelero +  TempData.ExpeInfo.PreProcessingInfo.NumWideband) 'channels'])
end


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
set(TempData.AcceleroCheckText,'String',['auxiliary.dat with ' num2str(TempData.ExpeInfo.PreProcessingInfo.NumAccelero) ' channels'])
if TempData.ExpeInfo.PreProcessingInfo.MergeDone ==1
    set(TempData.mergedfileCheck,'String',['amplifier.dat with ',...
        num2str(TempData.ExpeInfo.PreProcessingInfo.NumAnalog + TempData.ExpeInfo.PreProcessingInfo.NumDigChan + TempData.ExpeInfo.PreProcessingInfo.NumAccelero +  TempData.ExpeInfo.PreProcessingInfo.NumWideband) 'channels'])
end



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
set(TempData.DigInCheckText,'String',['digitalin.dat with ' num2str(TempData.ExpeInfo.PreProcessingInfo.NumDigChan) ' channels'])
if TempData.ExpeInfo.PreProcessingInfo.MergeDone ==1
    set(TempData.mergedfileCheck,'String',['amplifier.dat with ',...
        num2str(TempData.ExpeInfo.PreProcessingInfo.NumAnalog + TempData.ExpeInfo.PreProcessingInfo.NumDigChan + TempData.ExpeInfo.PreProcessingInfo.NumAccelero +  TempData.ExpeInfo.PreProcessingInfo.NumWideband) 'channels'])
end



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
set(TempData.AnalogCheckText,'String',['analogin.dat with ' num2str(TempData.ExpeInfo.PreProcessingInfo.NumAnalog) ' channels'])
if TempData.ExpeInfo.PreProcessingInfo.MergeDone ==1
    set(TempData.mergedfileCheck,'String',['amplifier.dat with ',...
        num2str(TempData.ExpeInfo.PreProcessingInfo.NumAnalog + TempData.ExpeInfo.PreProcessingInfo.NumDigChan + TempData.ExpeInfo.PreProcessingInfo.NumAccelero +  TempData.ExpeInfo.PreProcessingInfo.NumWideband) 'channels'])
end



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
        set(TempData.HideSingleFiles,'Visible','on')
    case 'off'
        set(TempData.DigInfoExplanation1,'Visible','on')
        set(TempData.DigInfoExplanation2,'Visible','on')
        set(TempData.HideSingleFiles,'Visible','off')

end

% --- Executes on button press in SpikeBox.
function SpikeBox_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.PreProcessingInfo.DoSpikes = hObject.Value;
guidata(hObject,TempData)


% --- Executes on button press in RefSubCheck.
function RefSubCheck_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.PreProcessingInfo.RefDone = hObject.Value;
guidata(hObject,TempData)

% --- Executes on button press in MergeCheckBox.
function MergeCheckBox_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.PreProcessingInfo.MergeDone = hObject.Value;
guidata(hObject,TempData)
if hObject.Value
    set(TempData.ArrowBox,'String',['----->'])
    set(TempData.mergedfileCheck,'String',['amplifier.dat with ',...
        num2str(TempData.ExpeInfo.PreProcessingInfo.NumAnalog + TempData.ExpeInfo.PreProcessingInfo.NumDigChan + TempData.ExpeInfo.PreProcessingInfo.NumAccelero +  TempData.ExpeInfo.PreProcessingInfo.NumWideband) 'channels'])
else
    set(TempData.ArrowBox,'String',[''])
    set(TempData.mergedfileCheck,'String',[''])
    
end


% --- Executes during object creation, after setting all properties.
function WideBandCheckText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WideBandCheckText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function WideBandCheckText_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to WideBandCheckText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function AcceleroCheckText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AcceleroCheckText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function ArrowBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ArrowBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function mergedfileCheck_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mergedfileCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in DoneWithOptions.
function DoneWithOptions_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
MergeDone = TempData.ExpeInfo.PreProcessingInfo.MergeDone;
RefDone = TempData.ExpeInfo.PreProcessingInfo.RefDone;
DoSpikes = TempData.ExpeInfo.PreProcessingInfo.DoSpikes;

if MergeDone == 1 & RefDone == 1
    
    
elseif MergeDone == 0 & RefDone == 1

elseif MergeDone == 1 & RefDone == 0

elseif MergeDone == 0 & RefDone == 0

end

ExpeInfo = TempData.ExpeInfo;
save('ExpeInfo.mat','ExpeInfo')



% --- Executes during object creation, after setting all properties.
function DoneWithOptions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DoneWithOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
