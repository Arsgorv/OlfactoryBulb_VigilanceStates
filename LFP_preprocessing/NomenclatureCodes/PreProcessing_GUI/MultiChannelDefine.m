function varargout = MultiChannelDefine(varargin)
% MULTICHANNELDEFINE MATLAB code for MultiChannelDefine.fig %
%      MULTICHANNELDEFINE, by itself, creates a new MULTICHANNELDEFINE or raises the existing
%      singleton*.
%
%      H = MULTICHANNELDEFINE returns the handle to a new MULTICHANNELDEFINE or the handle to
%      the existing singleton*.
%
%      MULTICHANNELDEFINE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTICHANNELDEFINE.M with the given input arguments.
%
%      MULTICHANNELDEFINE('Property','Value',...) creates a new MULTICHANNELDEFINE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiChannelDefine_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiChannelDefine_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultiChannelDefine

% Last Modified by GUIDE v2.5 29-Apr-2019 18:13:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultiChannelDefine_OpeningFcn, ...
                   'gui_OutputFcn',  @MultiChannelDefine_OutputFcn, ...
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


% --- Executes just before MultiChannelDefine is made visible.
function MultiChannelDefine_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultiChannelDefine (see VARARGIN)

% Choose default command line output for MultiChannelDefine
handles.output = struct;

% Update handles structure
guidata(hObject, handles);

uiwait

% UIWAIT makes MultiChannelDefine wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MultiChannelDefine_OutputFcn(hObject, eventdata, handles) 

TempData = guidata(hObject);
varargout{1} = TempData.output;
delete(TempData.figure1)



function ListOfChansToEdit_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.output.ChanList = strsplit(get(hObject,'String'),' ');
set(hObject,'BackGroundColor',[0.8 0.4 0.2])
guidata(hObject,TempData)

if isfield(TempData.output,'ChanList') & isfield(TempData.output,'ChanHemisphere') & isfield(TempData.output,'ChanDepth') & isfield(TempData.output,'ChanRegion')
   uiresume 
end



function ListOfChansToEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function StructureID_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
InfoLFPNomenclature
items = RegionName;
TempData.output.ChanRegion = (items{get(hObject,'Value')});
set(hObject,'BackGroundColor',[0.8 0.4 0.2])
guidata(hObject,TempData)

if isfield(TempData.output,'ChanList') & isfield(TempData.output,'ChanHemisphere') & isfield(TempData.output,'ChanDepth') & isfield(TempData.output,'ChanRegion')
   uiresume 
end

function StructureID_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
InfoLFPNomenclature
set( hObject,'string',strjoin(RegionName,'|'))


function ChannelHemisphere_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
InfoLFPNomenclature
items = HemisphereName;
TempData.output.ChanHemisphere = (items{get(hObject,'Value')});
set(hObject,'BackGroundColor',[0.8 0.4 0.2])
guidata(hObject,TempData)

if isfield(TempData.output,'ChanList') & isfield(TempData.output,'ChanHemisphere') & isfield(TempData.output,'ChanDepth') & isfield(TempData.output,'ChanRegion')
   uiresume 
end

function ChannelHemisphere_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
InfoLFPNomenclature
set( hObject,'string',strjoin(HemisphereName,'|'))



function ChannelDepth_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
InfoLFPNomenclature
items = Depths;
TempData.output.ChanDepth = (eval(items{get(hObject,'Value')}));
set(hObject,'BackGroundColor',[0.8 0.4 0.2])
guidata(hObject,TempData)

if isfield(TempData.output,'ChanList') & isfield(TempData.output,'ChanHemisphere') & isfield(TempData.output,'ChanDepth') & isfield(TempData.output,'ChanRegion')
   uiresume 
end

function ChannelDepth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
InfoLFPNomenclature
set( hObject,'string',strjoin(DepthsExpl,'|'))
