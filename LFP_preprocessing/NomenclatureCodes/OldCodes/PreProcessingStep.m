function varargout = PreProcessingStep(varargin)
% PREPROCESSINGSTEP MATLAB code for PreProcessingStep.fig
%      PREPROCESSINGSTEP, by itself, creates a new PREPROCESSINGSTEP or raises the existing
%      singleton*.
%
%      H = PREPROCESSINGSTEP returns the handle to a new PREPROCESSINGSTEP or the handle to
%      the existing singleton*.
%
%      PREPROCESSINGSTEP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREPROCESSINGSTEP.M with the given input arguments.
%
%      PREPROCESSINGSTEP('Property','Value',...) creates a new PREPROCESSINGSTEP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PreProcessingStep_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PreProcessingStep_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PreProcessingStep

% Last Modified by GUIDE v2.5 18-Dec-2018 18:36:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PreProcessingStep_OpeningFcn, ...
                   'gui_OutputFcn',  @PreProcessingStep_OutputFcn, ...
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


% --- Executes just before PreProcessingStep is made visible.
function PreProcessingStep_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PreProcessingStep (see VARARGIN)

% Choose default command line output for PreProcessingStep
handles.output = hObject;
load('ExpeInfo')
handles.ExpeInfo = ExpeInfo;
handles.ExpeInfo.PreProcessingInfo.MergeDone{1} = 0;
handles.ExpeInfo.PreProcessingInfo.RefDone{1} = 0;

set(handles.DataRecap,'String',...
    [newline,...
    num2str(ExpeInfo.PreProcessingInfo.NumWideband) ' electrodes recorded',...
    newline,...
    num2str(ExpeInfo.PreProcessingInfo.NumAccelero) ' accelerometer channels',...
    newline,...
    num2str(ExpeInfo.PreProcessingInfo.NumDigChan) ' digital channels',...
    ' with ' num2str(ExpeInfo.PreProcessingInfo.NumDigInput) ' digital inputs',...
    newline,...
    num2str(ExpeInfo.PreProcessingInfo.NumAnalog) ' analog channels'])
set(handles.FixIt1,'String',['If this is wrong fix it NOW'],'ForegroundColor','r')


set(handles.WideBandCheckText,'String',['amplifier.dat with ' num2str(ExpeInfo.PreProcessingInfo.NumWideband) ' channels'])
set(handles.AcceleroCheckText,'String',['auxiliary.dat with ' num2str(ExpeInfo.PreProcessingInfo.NumAccelero) ' channels'])
set(handles.DigInCheckText,'String',['digitalin.dat with ' num2str(ExpeInfo.PreProcessingInfo.NumDigChan) ' channels'])
set(handles.AnalogCheckText,'String',['analogin.dat with ' num2str(ExpeInfo.PreProcessingInfo.NumAnalog) ' channels'])
set(handles.FixIt2,'String',['If this is wrong fix it NOW'],'ForegroundColor','r')

set(handles.FixIt2,'String',['If this is wrong fix it NOW'],'ForegroundColor','r')


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PreProcessingStep wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PreProcessingStep_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in MergeCheckbox.
function MergeCheckbox_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.PreProcessingInfo.MergeDone{1} = hObject.Value;
guidata(hObject,TempData)
if hObject.Value
    set(TempData.ArrowBox,'String',['----->'])
    set(TempData.mergedfileCheck,'String',['amplifier.dat with ',...
        num2str(TempData.ExpeInfo.PreProcessingInfo.NumAnalog + TempData.ExpeInfo.PreProcessingInfo.NumDigChan + TempData.ExpeInfo.PreProcessingInfo.NumAccelero +  TempData.ExpeInfo.PreProcessingInfo.NumWideband) 'channels'])
else
    set(TempData.ArrowBox,'String',[''])
    set(TempData.mergedfileCheck,'String',[''])
    
end

function DonePreProcessing_Callback(hObject, eventdata, handles)




function GetDataFolders_Callback(hObject, eventdata, handles)    
    FigureID = guidata(GUIGetFilesToConcatenate);
    waitfor(FigureID.figure1)
    load('ExpeInfo.mat')
    TempData = guidata(hObject);
    TempData.ExpeInfo = ExpeInfo;
    guidata(hObject,TempData)
    set(handles.ChooseFolderOfInterest,'string',strjoin(ExpeInfo.PreProcessingInfo.FolderForConcatenation,'|'))
    

    
    
  
function ChooseFolderOfInterest_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String')
TempData.ActiveFolder = strtrim(items(get(hObject,'Value'),:));

set(handles.WideBandCheckText,'String',['amplifier.dat with ' num2str(TempData.ExpeInfo.PreProcessingInfo.NumWideband) ' channels'])

        
if TempData.ExpeInfo.PreProcessingInfo.MergeDone{hObject.Value}
    set(TempData.ArrowBox,'String',['----->'])
    set(TempData.mergedfileCheck,'String',['amplifier.dat with ',...
        num2str(TempData.ExpeInfo.PreProcessingInfo.NumAnalog + TempData.ExpeInfo.PreProcessingInfo.NumDigChan + TempData.ExpeInfo.PreProcessingInfo.NumAccelero +  TempData.ExpeInfo.PreProcessingInfo.NumWideband) ' channels'])
    if TempData.ExpeInfo.PreProcessingInfo.RefDone{hObject.Value}
        set(TempData.mergedfileCheck,'String',[TempData.mergedfileCheck.String ' ref sub']);
    end
else
    set(TempData.ArrowBox,'String',[''])
    set(TempData.mergedfileCheck,'String',[''])
        if TempData.ExpeInfo.PreProcessingInfo.RefDone{hObject.Value}
        set(TempData.WideBandCheckText,'String',[TempData.WideBandCheckText.String ' ref sub']);
    end
end

set(handles.DonePreProcessing,'enable','on')




% 


% --- Executes during object creation, after setting all properties.
function ChooseFolderOfInterest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChooseFolderOfInterest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
