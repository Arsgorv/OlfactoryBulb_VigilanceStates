function varargout = MultiChannelRefDefine(varargin)
% MultiChannelRefDefine MATLAB code for MultiChannelRefDefine.fig %
%      MultiChannelRefDefine, by itself, creates a new MultiChannelRefDefine or raises the existing
%      singleton*.
%
%      H = MultiChannelRefDefine returns the handle to a new MultiChannelRefDefine or the handle to
%      the existing singleton*.
%
%      MultiChannelRefDefine('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MultiChannelRefDefine.M with the given input arguments.
%
%      MultiChannelRefDefine('Property','Value',...) creates a new MultiChannelRefDefine or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiChannelRefDefine_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiChannelRefDefine_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiChannelRefDefine

% Last Modified by GUIDE v2.5 25-Mar-2019 12:50:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiChannelRefDefine_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiChannelRefDefine_OutputFcn, ...
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


% --- Executes just before MultiChannelRefDefine is made visible.
function MultiChannelRefDefine_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiChannelRefDefine (see VARARGIN)

% Choose default command line output for MultiChannelRefDefine
handles.output = struct;

% Update handles structure
guidata(hObject, handles);

uiwait

% UIWAIT makes MultiChannelRefDefine wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MultiChannelRefDefine_OutputFcn(hObject, eventdata, handles) 

TempData = guidata(hObject);
varargout{1} = TempData.output;
delete(TempData.figure1)



function ListOfChansToEdit_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.output.ChanList = strsplit(get(hObject,'String'),' ');
set(hObject,'BackGroundColor',[0.8 0.4 0.2])
guidata(hObject,TempData)

if isfield(TempData.output,'ChanList') & isfield(TempData.output,'TetList')
   uiresume 
end



function ListOfChansToEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TetrodeNumSub_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.output.TetList = strsplit(get(hObject,'String'),' ');
set(hObject,'BackGroundColor',[0.8 0.4 0.2])
guidata(hObject,TempData)

if isfield(TempData.output,'ChanList') & isfield(TempData.output,'TetList')
   uiresume 
end

% --- Executes during object creation, after setting all properties.
function TetrodeNumSub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TetrodeNumSub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
