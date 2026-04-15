function varargout = GUI_StepOne_ExperimentInfo(varargin)
% GUI_STEPONE_EXPERIMENTINFO MATLAB code for GUI_StepOne_ExperimentInfo.fig
%      GUI_STEPONE_EXPERIMENTINFO, by itself, creates a new GUI_STEPONE_EXPERIMENTINFO or raises the existing
%      singleton*.
%
%      H = GUI_STEPONE_EXPERIMENTINFO returns the handle to a new GUI_STEPONE_EXPERIMENTINFO or the handle to
%      the existing singleton*.
%
%      GUI_STEPONE_EXPERIMENTINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_STEPONE_EXPERIMENTINFO.M with the given input arguments.
%
%      GUI_STEPONE_EXPERIMENTINFO('Property','Value',...) creates a new GUI_STEPONE_EXPERIMENTINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_StepOne_ExperimentInfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_StepOne_ExperimentInfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_StepOne_ExperimentInfo

% Last Modified by GUIDE v2.5 18-Dec-2018 10:51:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_StepOne_ExperimentInfo_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_StepOne_ExperimentInfo_OutputFcn, ...
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


% --- Executes just before GUI_StepOne_ExperimentInfo is made visible.
function GUI_StepOne_ExperimentInfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_StepOne_ExperimentInfo (see VARARGIN)

% Choose default command line output for GUI_StepOne_ExperimentInfo
handles.output = hObject;
handles.figure1.WindowStyle = 'normal';
handles.figure1.DockControls = 'off';

% set buttons to on and off
set(handles.Mouse_Strain_List,'Enable','Off')
set(handles.Epxerimenter_List,'Enable','Off')
set(handles.Date_Year,'Enable','Off')
set(handles.Date_Month,'Enable','Off')
set(handles.Date_Day,'Enable','Off')
set(handles.SessionName_Edit,'Enable','Off')
set(handles.RecordingRoomMenu,'Enable','Off')
set(handles.EnvironmentType,'Enable','Off')
set(handles.CameraType,'Enable','Off')
set(handles.NextStepButton,'enable','Off')

set(findall(handles.Optogenetics_Panel,'-property','enable'),'enable','off')
set(findall(handles.ElectricStim_Panel,'-property','enable'),'enable','off')
set(findall(handles.DrugInjection_Panel,'-property','enable'),'enable','off')

set(handles.ImDoneButton,'Enable','Off')

handles.yearSession = [];
handles.monthSession = [];
handles.daySession = [];
handles.yearDrug1 = [];
handles.monthDrug1 = [];
handles.dayDrug1 = [];
handles.hourDrug1 = [];
handles.minuteDrug1 = [];
handles.yearDrug2 = [];
handles.monthDrug2 = [];
handles.dayDrug2 = [];
handles.hourDrug2 = [];
handles.minuteDrug2 = [];
handles.TrackStimSession = [];

% initialize ExpeInfo if it does not already exist
if isfile('ExpeInfo.mat')==1
    load('ExpeInfo.mat')
    handles.ExpeInfo = ExpeInfo;
    handles = FillInSlotsWithExpeInfo(handles);
else
    handles.ExpeInfo = struct;
    handles.ExpeInfo.nmouse = [];
    handles.ExpeInfo.Experimenter = [];
    handles.ExpeInfo.date = [];
    handles.ExpeInfo.SessionType = [];
    
    handles.ExpeInfo.SleepSession = 0;
    handles.ExpeInfo.OptoSession = 0;
    handles.ExpeInfo.StimSession = 0;
end



% Update handles structure
guidata(hObject, handles);


% UIWAIT makes GUI_StepOne_ExperimentInfo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_StepOne_ExperimentInfo_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%% General information about the experiment
% Mouse Number
function MouseNum_Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MouseNum_Edit_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.nmouse = eval(get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Mouse_Strain_List,'Enable','On')
set(handles.MouseNum_Edit,'BackgroundColor',[0.8 0.4 0.2])

function DataHardDrive_Edit_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.harddrive = eval(get(hObject,'String'));
guidata(hObject,TempData)


% Mouse strain
function Mouse_Strain_List_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
MouseStrainNomenclature
set(hObject,'string',strjoin(StrainName,'|'))

function Mouse_Strain_List_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.MouseStrain = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
set(handles.Epxerimenter_List,'Enable','On')
set(handles.Mouse_Strain_List,'BackgroundColor',[0.8 0.4 0.2])

% Experimenter doing the preprocessing
function Epxerimenter_List_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
LabMemberNomenclature
set(hObject,'string',strjoin(LabMemberName,'|'))

function Epxerimenter_List_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.Experimenter = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
set(handles.Epxerimenter_List,'BackgroundColor',[0.8 0.4 0.2])
set(handles.Date_Year,'Enable','On')
set(handles.Date_Month,'Enable','On')
set(handles.Date_Day,'Enable','On')


% Date of experiment
function Date_Year_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Date_Year_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.yearSession = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Date_Year,'BackgroundColor',[0.8 0.4 0.2])


function Date_Month_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Date_Month_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.monthSession = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Date_Month,'BackgroundColor',[0.8 0.4 0.2])


function Date_Day_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Date_Day_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.daySession = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Date_Day,'BackgroundColor',[0.8 0.4 0.2])
set(handles.SessionName_Edit,'Enable','On')



% SessionName
function SessionName_Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SessionName_Edit_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.SessionType = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.SessionName_Edit,'BackgroundColor',[0.8 0.4 0.2])
set(handles.RecordingRoomMenu,'Enable','On')


% Is it a sleep session
function SleepSessionCheckBox_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.SleepSession = hObject.Value;
guidata(hObject,TempData)


function RecordingRoomMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
RecordingRoomNomenclature
set(hObject,'string',strjoin(RecordingRoom,'|'))

function RecordingRoomMenu_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.RecordingRoom = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
set(handles.EnvironmentType,'Enable','On')
set(handles.RecordingRoomMenu,'BackgroundColor',[0.8 0.4 0.2])


function EnvironmentType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
RecordingBoxNomenclature
set(hObject,'string',strjoin(RecordingBoxType,'|'))

function EnvironmentType_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.RecordingBox = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
set(handles.CameraType,'Enable','On')
set(handles.EnvironmentType,'BackgroundColor',[0.8 0.4 0.2])



function CameraType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
CameraTypesNomenclature
set(hObject,'string',strjoin(CameraType,'|'))

function CameraType_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.CameraType = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
set(handles.ImDoneButton,'Enable','On')
set(handles.CameraType,'BackgroundColor',[0.8 0.4 0.2])


%% Information for optogenetics experiment

% --- Executes on button press in Optogenetics_ToggleButton.
function Optogenetics_ToggleButton_Callback(hObject, eventdata, handles)
switch handles.Virus_identity_List.Enable
    case 'off'
        set(findall(handles.Optogenetics_Panel,'-property','enable'),'enable','on')
    case 'on'
        % if user switches the panel off everything gets reset
        set(findall(handles.Optogenetics_Panel,'-property','enable'),'enable','off')
        TempData = guidata(hObject);
        TempData.ExpeInfo.OptoSession = 0;
        if isfield(TempData.ExpeInfo,'OptoInfo')
            TempData.ExpeInfo = rmfield(TempData.ExpeInfo,'OptoInfo');
        end

        AllButtons = findall(handles.Optogenetics_Panel,'Type','UIControl');
        for b = 1:length(AllButtons)
            AllButtons(b).BackgroundColor = get(0,'defaultUicontrolBackgroundColor');
        end
        guidata(hObject,TempData)
        
end


% Identify session as opto session
function IsOptoSession_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.OptoSession = hObject.Value;
guidata(hObject,TempData)

% Virus that was injected
function Virus_identity_List_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
VirusNomenclature
set(hObject,'string',strjoin(VirusName,'|'))

function Virus_identity_List_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.OptoInfo.VirusInjected = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
set(handles.Virus_identity_List,'BackgroundColor',[0.8 0.4 0.2])


% Virus injection site
function Virus_Location_List_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
InfoLFPNomenclature
set(hObject,'string',strjoin(RegionName,'|'))

function Virus_Location_List_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.OptoInfo.VirusLocation = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
set(handles.Virus_Location_List,'BackgroundColor',[0.8 0.4 0.2])


% Optic fiber site
function Fiber_Location_List_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
InfoLFPNomenclature
set(hObject,'string',strjoin(RegionName,'|'))

function Fiber_Location_List_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.OptoInfo.FiberLocation = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
set(handles.Fiber_Location_List,'BackgroundColor',[0.8 0.4 0.2])


% Laser light intensity
function Laser_Intensity_Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Laser_Intensity_Edit_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.OptoInfo.LaserStimIntenstiy = eval((get(hObject,'String')));
guidata(hObject,TempData)
set(handles.Laser_Intensity_Edit,'BackgroundColor',[0.8 0.4 0.2])


%% Information about potential drug injection

% --- Executes on button press in DrugInjection_ToggleButton.
function DrugInjection_ToggleButton_Callback(hObject, eventdata, handles)
switch handles.Drug1_List.Enable
    case 'off'
        set(findall(handles.DrugInjection_Panel,'-property','enable'),'enable','on')
    case 'on'
        set(findall(handles.DrugInjection_Panel,'-property','enable'),'enable','off')
        
        % if user switches the panel off everything gets reset
        TempData = guidata(hObject);
        
        if isfield(TempData.ExpeInfo,'DrugInfo')
            TempData.ExpeInfo = rmfield(TempData.ExpeInfo,'DrugInfo');
        end
        TempData.handles.yearDrug1 = [];
        TempData.handles.monthDrug1 = [];
        TempData.handles.dayDrug1 = [];
        TempData.handles.hourDrug1 = [];
        TempData.handles.minuteDrug1 = [];
        TempData.handles.yearDrug2 = [];
        TempData.handles.monthDrug2 = [];
        TempData.handles.dayDrug2 = [];
        TempData.handles.hourDrug2 = [];
        TempData.handles.minuteDrug2 = [];
        AllButtons = findall(handles.DrugInjection_Panel,'Type','UIControl');
        for b = 1:length(AllButtons)
            AllButtons(b).BackgroundColor = get(0,'defaultUicontrolBackgroundColor');
        end
        guidata(hObject,TempData)
        
end


% Drug number 1

% Drug 1 identity
function Drug1_List_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
DrugNameNomenclature
set(hObject,'string',strjoin(DrugName,'|'))

function Drug1_List_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.DrugInfo.DrugInjected = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
set(handles.Drug1_List,'BackgroundColor',[0.8 0.4 0.2])

% Drug1 dose
function Drug1_Dose_Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug1_Dose_Edit_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.DrugInfo.DrugDose = eval((get(hObject,'String')));
guidata(hObject,TempData)
set(handles.Drug1_Dose_Edit,'BackgroundColor',[0.8 0.4 0.2])

% Drug1 date
function Drug1Year_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug1Year_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.yearDrug1 = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Drug1Year,'BackgroundColor',[0.8 0.4 0.2])

function Drug1Month_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug1Month_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.monthDrug1 = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Drug1Month,'BackgroundColor',[0.8 0.4 0.2])

function Drug1Day_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug1Day_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.dayDrug1 = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Drug1Day,'BackgroundColor',[0.8 0.4 0.2])


function Drug1Hour_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug1Hour_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.hourDrug1 =  (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Drug1Hour,'BackgroundColor',[0.8 0.4 0.2])

function Drug1Min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug1Min_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.minDrug1 =  (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Drug1Min,'BackgroundColor',[0.8 0.4 0.2])

% Drug 2

% Drug2 identity
function Drug2_List_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
DrugNameNomenclature
set(hObject,'string',strjoin(DrugName,'|'))

function Drug2_List_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.DrugInfo.DrugInjected2 = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
set(handles.Drug2_List,'BackgroundColor',[0.8 0.4 0.2])


% Drug 2 dose
function Drug2_Dose_Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug2_Dose_Edit_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.DrugInfo.DrugDose2 = eval((get(hObject,'String')));
guidata(hObject,TempData)
set(handles.Drug2_Dose_Edit,'BackgroundColor',[0.8 0.4 0.2])


% Drug 2 date
function Drug2Year_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug2Year_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.yearDrug2 = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Drug2Month,'enable','on')
set(handles.Drug2Year,'BackgroundColor',[0.8 0.4 0.2])


function Drug2Month_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug2Month_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.monthDrug2 = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Drug2Day,'enable','on')
set(handles.Drug2Month,'BackgroundColor',[0.8 0.4 0.2])


function Drug2Day_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug2Day_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.dayDrug2 = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Drug2Day,'BackgroundColor',[0.8 0.4 0.2])


function Drug2Hour_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug2Hour_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.hourDrug2 = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Drug2Day,'BackgroundColor',[0.8 0.4 0.2])
set(handles.Drug2Hour,'BackgroundColor',[0.8 0.4 0.2])


function Drug2Min_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Drug2Min_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.minDrug2 = (get(hObject,'String'));
guidata(hObject,TempData)
set(handles.Drug2Min,'BackgroundColor',[0.8 0.4 0.2])

%% Electrical stimulation information

% --- Executes on button press in ElectricalStim_ToggleButton.
function ElectricalStim_ToggleButton_Callback(hObject, eventdata, handles)
switch handles.Stim1_Location_List.Enable
    case 'off'
        set(findall(handles.ElectricStim_Panel,'-property','enable'),'enable','on')
    case 'on'
        set(findall(handles.ElectricStim_Panel,'-property','enable'),'enable','off')
        
        % if user switches the panel off everything gets reset
        TempData = guidata(hObject);
        if isfield(TempData.ExpeInfo,'ElecStimInfo')
            TempData.ExpeInfo = rmfield(TempData.ExpeInfo,'ElecStimInfo');
        end
        TempData.ExpeInfo.StimSession = 0;
        handles.TrackStimSession = [0 0];
        AllButtons = findall(handles.ElectricStim_Panel,'Type','UIControl');
        for b = 1:length(AllButtons)
            AllButtons(b).BackgroundColor = get(0,'defaultUicontrolBackgroundColor');
        end
        guidata(hObject,TempData)
        
end

% First stimulation electrode
% Was it a stimulation session?
function Stim1_Session_Checkbox_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.ElecStimInfo.StimSession = hObject.Value;
handles.TrackStimSession(1) = TempData.ExpeInfo.ElecStimInfo.StimSession;
guidata(hObject,TempData)


% Location of stimulation electrode 1
function Stim1_Location_List_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
StimElectrodeNomenclature
set(hObject,'string',strjoin(StimRegionName,'|'))

function Stim1_Location_List_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.ElecStimInfo.ElecStimulationLocation = strtrim(items(get(hObject,'Value'),:));
guidata(hObject,TempData)
set(handles.Stim1_Location_List,'BackgroundColor',[0.8 0.4 0.2])

% Intensity of stimulation 1
function Stim1_Intensity_Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Stim1_Intensity_Edit_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.ElecStimInfo.ElecStimIntensity = eval((get(hObject,'String')));
guidata(hObject,TempData)
set(handles.Stim1_Intensity_Edit,'BackgroundColor',[0.8 0.4 0.2])


% Was stim 2 being used?
function Stim2_Session_Checkbox_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.ElecStimInfo.StimSession2 = hObject.Value;
handles.TrackStimSession(2) = TempData.ExpeInfo.ElecStimInfo.StimSession;
guidata(hObject,TempData)


% Stimulation electrode 2 location
function Stim2_Location_List_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
StimElectrodeNomenclature
set(hObject,'string',strjoin(StimRegionName,'|'))

function Stim2_Location_List_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.ElecStimInfo.ElecStimulationLocation2 = items(get(hObject,'Value'),:);
guidata(hObject,TempData)
set(handles.Stim2_Location_List,'BackgroundColor',[0.8 0.4 0.2])


% Stimulation electrode 2 intensity
function Stim2_Intensity_Edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Stim2_Intensity_Edit_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
items = get(hObject,'String');
TempData.ExpeInfo.ElecStimInfo.ElecStimIntensity2 = eval((get(hObject,'String')));
guidata(hObject,TempData)
set(handles.Stim2_Intensity_Edit,'BackgroundColor',[0.8 0.4 0.2])


% Put here a brief description of protocol

function GeneralComments_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function GeneralComments_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
TempData.ExpeInfo.Comments = (get(hObject,'String'));
guidata(hObject,TempData)


% This saves ExpeInfo
function ImDone_Callback(hObject, eventdata, handles)
TempData = guidata(hObject);
ExpeInfo  = TempData.ExpeInfo;
guidata(hObject,TempData)
ExpeInfo.date = [TempData.yearSession,TempData.monthSession,TempData.daySession];
if not(isempty(TempData.yearDrug1))
    ExpeInfo.DrugInfo.DrugInjectionDate = [TempData.yearDrug1,TempData.monthDrug1,TempData.dayDrug1];
    ExpeInfo.DrugInfo.DrugInjectionTime = [TempData.hourDrug1,TempData.minDrug1];
end
if not(isempty(TempData.yearDrug2))
    ExpeInfo.DrugInfo.DrugInjectionDate2 = [TempData.yearDrug2,TempData.monthDrug2,TempData.dayDrug2];
    ExpeInfo.DrugInfo.DrugInjectionTime2 = [TempData.hourDrug2,TempData.minDrug2];
end

ExpeInfo.StimSession = min([sum(handles.TrackStimSession),1]);


ExpeInfo.SessionType = strrep(ExpeInfo.SessionType,' ','_');

save('ExpeInfo.mat','ExpeInfo')
set(handles.NextStepButton,'enable','On')


function handles = FillInSlotsWithExpeInfo(handles)
% If expe info is already filled in, put the value sin the right place and
% enable the next button

% mouse number
if isfield(handles.ExpeInfo,'nmouse')
    set(handles.Mouse_Strain_List,'Enable','On')
    set(handles.MouseNum_Edit,'BackgroundColor',[0.8 0.4 0.2])
    set(handles.MouseNum_Edit,'String',handles.ExpeInfo.nmouse)
end

% mouse number
if isfield(handles.ExpeInfo,'MouseStrain')
    set(handles.Epxerimenter_List,'Enable','On')
    set(handles.Mouse_Strain_List,'BackgroundColor',[0.8 0.4 0.2])
    MouseStrainNomenclature
    set(handles.Mouse_Strain_List,'Value',find(strcmp(StrainName,handles.ExpeInfo.MouseStrain)))
end

% experimenter
if isfield(handles.ExpeInfo,'Experimenter')
    set(handles.Epxerimenter_List,'BackgroundColor',[0.8 0.4 0.2])
    set(handles.Date_Year,'Enable','On')
    set(handles.Date_Month,'Enable','On')
    set(handles.Date_Day,'Enable','On')
    LabMemberNomenclature
    set(handles.Epxerimenter_List,'Value',find(strcmp(LabMemberName,handles.ExpeInfo.Experimenter)))
end

% date
if isfield(handles.ExpeInfo,'date')
    
    set(handles.Date_Year,'BackgroundColor',[0.8 0.4 0.2])
    set(handles.Date_Month,'BackgroundColor',[0.8 0.4 0.2])
    set(handles.Date_Day,'BackgroundColor',[0.8 0.4 0.2])
    
    if length(handles.ExpeInfo.date) == 6
        handles.ExpeInfo.date = ['20' handles.ExpeInfo.date];
    end
    set(handles.Date_Year,'String',handles.ExpeInfo.date(1:4))
    set(handles.Date_Month,'String',handles.ExpeInfo.date(5:6))
    set(handles.Date_Day,'String',handles.ExpeInfo.date(7:8))
    
    handles.daySession = handles.ExpeInfo.date(7:8);
    handles.monthSession = handles.ExpeInfo.date(5:6);
    handles.yearSession = handles.ExpeInfo.date(1:4);
    
    set(handles.SessionName_Edit,'enable','on')
    
end


% SessionType
if isfield(handles.ExpeInfo,'SessionType')
    set(handles.SessionName_Edit,'BackgroundColor',[0.8 0.4 0.2])
    set(handles.SessionName_Edit,'String', handles.ExpeInfo.SessionType)
        set(handles.RecordingRoomMenu,'Enable','On')

end

% Sleep Session?
if isfield(handles.ExpeInfo,'SleepSession')
    set(handles.SleepSessionCheckBox,'Value',handles.ExpeInfo.SleepSession)
else
    handles.ExpeInfo.SleepSession = 0;
end

% RecordingRoom
if isfield(handles.ExpeInfo,'RecordingRoom')
    set(handles.EnvironmentType,'Enable','On')
    set(handles.RecordingRoomMenu,'BackgroundColor',[0.8 0.4 0.2])
    RecordingRoomNomenclature
    set(handles.RecordingRoomMenu,'Value',find(strcmp(RecordingRoom,handles.ExpeInfo.RecordingRoom)))
end

% EnvironmentType
if isfield(handles.ExpeInfo,'RecordingBox')
    set(handles.CameraType,'Enable','On')
    set(handles.EnvironmentType,'BackgroundColor',[0.8 0.4 0.2])
    RecordingBoxNomenclature
    set(handles.EnvironmentType,'Value',find(strcmp(RecordingBoxType,handles.ExpeInfo.RecordingBox)))
end

% CameraType
if isfield(handles.ExpeInfo,'CameraType')
    set(handles.CameraType,'BackgroundColor',[0.8 0.4 0.2])
    CameraTypesNomenclature
    set(handles.CameraType,'Value',find(strcmp(CameraType,handles.ExpeInfo.CameraType)))
end

% HardDrive
if isfield(handles.ExpeInfo,'harddrive')
    set(handles.HardDrive_Edit,'BackgroundColor',[0.8 0.4 0.2])
    set(handles.HardDrive_Edit,'String', handles.ExpeInfo.harddrive)
end

%% check if we can activate the I'm done button
if (isfield(handles.ExpeInfo,'CameraType') & isfield(handles.ExpeInfo,'RecordingBox') & isfield(handles.ExpeInfo,'RecordingRoom') ...
         & isfield(handles.ExpeInfo,'SessionType') &  isfield(handles.ExpeInfo,'date') & isfield(handles.ExpeInfo,'Experimenter') & isfield(handles.ExpeInfo,'MouseStrain') & isfield(handles.ExpeInfo,'nmouse'))
    set(handles.ImDoneButton,'Enable','On')
end

% If there was optogenetics info
if isfield(handles.ExpeInfo,'OptoSession')
    set(handles.IsOptoSession,'Value',handles.ExpeInfo.OptoSession)
else
    handles.ExpeInfo.OptoSession = 0;
end

if isfield(handles.ExpeInfo,'OptoInfo')
    set(findall(handles.Optogenetics_Panel,'-property','enable'),'enable','on')
    set(handles.Optogenetics_ToggleButton,'value',1)
    
    if isfield(handles.ExpeInfo.OptoInfo,'VirusInjected')
        VirusNomenclature
        set(handles.Virus_identity_List,'Value',find(strcmp(VirusName,handles.ExpeInfo.OptoInfo.VirusInjected)))
        set(handles.Virus_identity_List,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    if isfield(handles.ExpeInfo.OptoInfo,'VirusLocation')
        InfoLFPNomenclature
        set(handles.Virus_Location_List,'Value',find(strcmp(RegionName,handles.ExpeInfo.OptoInfo.VirusLocation)))
        set(handles.Virus_Location_List,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    if isfield(handles.ExpeInfo.OptoInfo,'FiberLocation')
        InfoLFPNomenclature
        set(handles.Fiber_Location_List,'Value',find(strcmp(RegionName,handles.ExpeInfo.OptoInfo.FiberLocation)))
        set(handles.Fiber_Location_List,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    if isfield(handles.ExpeInfo.OptoInfo,'LaserStimIntenstiy')
        set(handles.Laser_Intensity_Edit,'String',num2str(handles.ExpeInfo.OptoInfo.LaserStimIntenstiy))
        set(handles.Laser_Intensity_Edit,'BackgroundColor',[0.8 0.4 0.2])
    end
    
end

% if there was drug information

if isfield(handles.ExpeInfo,'DrugInfo')
    set(findall(handles.DrugInjection_Panel,'-property','enable'),'enable','on')
    set(handles.DrugInjection_ToggleButton,'value',1)
    
    if isfield(handles.ExpeInfo.DrugInfo,'DrugInjected')
        DrugNameNomenclature
        set(handles.Drug1_List,'Value',find(strcmp(DrugName,handles.ExpeInfo.DrugInfo.DrugInjected)))
        set(handles.Drug1_List,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    if isfield(handles.ExpeInfo.DrugInfo,'DrugDose')
        DrugNameNomenclature
        set(handles.Drug1_Dose_Edit,'String',num2str(handles.ExpeInfo.DrugInfo.DrugDose))
        set(handles.Drug1_Dose_Edit,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    if isfield(handles.ExpeInfo.DrugInfo,'DrugInjectionDate')
        
        set(handles.Drug1Year,'BackgroundColor',[0.8 0.4 0.2])
        set(handles.Drug1Month,'BackgroundColor',[0.8 0.4 0.2])
        set(handles.Drug1Day,'BackgroundColor',[0.8 0.4 0.2])
        
        set(handles.Drug1Year,'String',handles.ExpeInfo.DrugInfo.DrugInjectionDate(1:4))
        set(handles.Drug1Month,'String',handles.ExpeInfo.DrugInfo.DrugInjectionDate(5:6))
        set(handles.Drug1Day,'String',handles.ExpeInfo.DrugInfo.DrugInjectionDate(7:8))
        
        handles.dayDrug1 = handles.ExpeInfo.DrugInfo.DrugInjectionDate(7:8);
        handles.monthDrug1 = handles.ExpeInfo.DrugInfo.DrugInjectionDate(5:6);
        handles.yearDrug1 = handles.ExpeInfo.DrugInfo.DrugInjectionDate(1:4);
        
    end
    
    if isfield(handles.ExpeInfo.DrugInfo,'DrugInjectionTime')
        
        set(handles.Drug1Hour,'BackgroundColor',[0.8 0.4 0.2])
        set(handles.Drug1Min,'BackgroundColor',[0.8 0.4 0.2])
        
        set(handles.Drug1Hour,'String',handles.ExpeInfo.DrugInfo.DrugInjectionTime(1:2))
        set(handles.Drug1Min,'String',handles.ExpeInfo.DrugInfo.DrugInjectionTime(3:4))
        
        handles.hourDrug1 = handles.ExpeInfo.DrugInfo.DrugInjectionTime(1:2);
        handles.minDrug1 = handles.ExpeInfo.DrugInfo.DrugInjectionTime(3:4);
        
    end
    
    
    
    
    if isfield(handles.ExpeInfo.DrugInfo,'DrugInjected2')
        DrugNameNomenclature
        set(handles.Drug2_List,'Value',find(strcmp(DrugName,handles.ExpeInfo.DrugInfo.DrugInjected2)))
        set(handles.Drug2_List,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    if isfield(handles.ExpeInfo.DrugInfo,'DrugDose2')
        DrugNameNomenclature
        set(handles.Drug2_Dose_Edit,'String',num2str(handles.ExpeInfo.DrugInfo.DrugDose2))
        set(handles.Drug2_Dose_Edit,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    if isfield(handles.ExpeInfo.DrugInfo,'DrugInjectionDate2')
        
        set(handles.Drug2Year,'BackgroundColor',[0.8 0.4 0.2])
        set(handles.Drug2Month,'BackgroundColor',[0.8 0.4 0.2])
        set(handles.Drug2Day,'BackgroundColor',[0.8 0.4 0.2])
        
        set(handles.Drug2Year,'String',handles.ExpeInfo.DrugInfo.DrugInjectionDate2(1:4))
        set(handles.Drug2Month,'String',handles.ExpeInfo.DrugInfo.DrugInjectionDate2(5:6))
        set(handles.Drug2Day,'String',handles.ExpeInfo.DrugInfo.DrugInjectionDate2(7:8))
        
        handles.dayDrug2 = handles.ExpeInfo.DrugInfo.DrugInjectionDate2(7:8);
        handles.monthDrug2 = handles.ExpeInfo.DrugInfo.DrugInjectionDate2(5:6);
        handles.yearDrug2 = handles.ExpeInfo.DrugInfo.DrugInjectionDate2(1:4);
        
    end
    
    if isfield(handles.ExpeInfo.DrugInfo,'DrugInjectionTime2')
        
        set(handles.Drug2Hour,'BackgroundColor',[0.8 0.4 0.2])
        set(handles.Drug2Min,'BackgroundColor',[0.8 0.4 0.2])
        
        set(handles.Drug2Hour,'String',handles.ExpeInfo.DrugInfo.DrugInjectionTime2(1:2))
        set(handles.Drug2Min,'String',handles.ExpeInfo.DrugInfo.DrugInjectionTime2(3:4))
        
        handles.hourDrug2 = handles.ExpeInfo.DrugInfo.DrugInjectionTime2(1:2);
        handles.minDrug2 = handles.ExpeInfo.DrugInfo.DrugInjectionTime2(3:4);
        
    end
    
end

% if there was electrical stimulation information

if isfield(handles.ExpeInfo,'ElecStimInfo')
    set(handles.ElectricalStim_ToggleButton,'value',1)
    
    if isfield(handles.ExpeInfo.ElecStimInfo,'StimSession')
        set(handles.Stim1_Session_Checkbox,'Value',handles.ExpeInfo.ElecStimInfo.StimSession)
        handles.TrackStimSession(1) = handles.ExpeInfo.ElecStimInfo.StimSession;
    end
    
    if isfield(handles.ExpeInfo.ElecStimInfo,'StimSession2')
        set(handles.Stim2_Session_Checkbox,'Value',handles.ExpeInfo.ElecStimInfo.StimSession2)
        handles.TrackStimSession(2) = handles.ExpeInfo.ElecStimInfo.StimSession;
    end
    
end


if isfield(handles.ExpeInfo,'ElecStimInfo')
    set(findall(handles.ElectricStim_Panel,'-property','enable'),'enable','on')
    
    if isfield(handles.ExpeInfo.ElecStimInfo,'ElecStimulationLocation')
        StimElectrodeNomenclature
        set(handles.Stim1_Location_List,'Value',find(strcmp(StimRegionName,handles.ExpeInfo.ElecStimInfo.ElecStimulationLocation)))
        set(handles.Stim1_Location_List,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    if isfield(handles.ExpeInfo.ElecStimInfo,'ElecStimulationLocation2')
        StimElectrodeNomenclature
        set(handles.Stim2_Location_List,'Value',find(strcmp(StimRegionName,handles.ExpeInfo.ElecStimInfo.ElecStimulationLocation2)))
        set(handles.Stim2_Location_List,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    if isfield(handles.ExpeInfo.ElecStimInfo,'ElecStimulationLocation')
        StimElectrodeNomenclature
        set(handles.Stim1_Location_List,'Value',find(strcmp(StimRegionName,handles.ExpeInfo.ElecStimInfo.ElecStimulationLocation)))
        set(handles.Stim1_Location_List,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    if isfield(handles.ExpeInfo.ElecStimInfo,'ElecStimIntensity1')
        set(handles.Stim1_Intensity_Edit,'String',num2str(handles.ExpeInfo.ElecStimInfo.ElecStimIntensity1))
        set(handles.Stim1_Intensity_Edit,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    if isfield(handles.ExpeInfo.ElecStimInfo,'ElecStimIntensity2')
        set(handles.Stim2_Intensity_Edit,'String',num2str(handles.ExpeInfo.ElecStimInfo.ElecStimIntensity2))
        set(handles.Stim2_Intensity_Edit,'BackgroundColor',[0.8 0.4 0.2])
    end
    
    
    
end


% --- Executes during object creation, after setting all properties.
function RecordingRoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RecordingRoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function NextStepButton_Callback(hObject, eventdata, handles)
close(handles.figure1)
GUI_StepTwo_RecordingInfo
