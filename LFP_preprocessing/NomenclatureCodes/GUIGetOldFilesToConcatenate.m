function varargout = GUIGetOldFilesToConcatenate(varargin)
% GUIGETOLDFILESTOCONCATENATE MATLAB code for GUIGetOldFilesToConcatenate.fig
%      GUIGETOLDFILESTOCONCATENATE, by itself, creates a new GUIGETOLDFILESTOCONCATENATE or raises the existing
%      singleton*.
%
%      H = GUIGETOLDFILESTOCONCATENATE returns the handle to a new GUIGETOLDFILESTOCONCATENATE or the handle to
%      the existing singleton*.
%
%      GUIGETOLDFILESTOCONCATENATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIGETOLDFILESTOCONCATENATE.M with the given input arguments.
%
%      GUIGETOLDFILESTOCONCATENATE('Property','Value',...) creates a new GUIGETOLDFILESTOCONCATENATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIGetOldFilesToConcatenate_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIGetOldFilesToConcatenate_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIGetOldFilesToConcatenate

% Last Modified by GUIDE v2.5 17-Jun-2019 18:08:56



%global var init
global useold; useold=0;   %use of old folders for concatenation


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUIGetOldFilesToConcatenate_OpeningFcn, ...
                   'gui_OutputFcn',  @GUIGetOldFilesToConcatenate_OutputFcn, ...
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


% --- Executes just before GUIGetOldFilesToConcatenate is made visible.
function GUIGetOldFilesToConcatenate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIGetOldFilesToConcatenate (see VARARGIN)

% Choose default command line output for GUIGetOldFilesToConcatenate
handles.output = hObject;

load('ExpeInfo.mat')

NumFilesToConcatenate = ExpeInfo.PreProcessingInfo.NumFilesToConcatenate;
    for k = 1:ExpeInfo.PreProcessingInfo.NumFilesToConcatenate 
        %Initialize the figure
        handles.(['FileNum',num2str(k)])= uicontrol(handles.figure1,...
                                                    'style','text',...
                                                    'units','normalized',...
                                                    'position',[0.01 0.9-(0.9/(NumFilesToConcatenate+1))*k 0.02 0.02],...
                                                    'string',num2str(k));

%         handles.(['GetFileLocation',num2str(k)])= uicontrol(handles.figure1,...
%                                                     'style','PushButton',...
%                                                     'units','normalized',...
%                                                     'position',[0.04 0.9-(0.9/(NumFilesToConcatenate+1))*k 0.05 0.04],...
%                                                     'String','GetFile',...
%                                                     'callback', {@GetFolder,k});

        handles.(['FileLocation_Ephys',num2str(k)])= uicontrol(handles.figure1,...
                                                    'style','text',...
                                                    'units','normalized',...
                                                    'position',[0.12 0.9-(0.9/(NumFilesToConcatenate+1))*k 0.3 0.04],...
                                                    'String',ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{1,k});

        handles.(['FileLocation_Behav',num2str(k)])= uicontrol(handles.figure1,...
                                                    'style','text',...
                                                    'units','normalized',...
                                                    'position',[0.45 0.9-(0.9/(NumFilesToConcatenate+1))*k 0.3 0.04],...
                                                    'String',ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{1,k});

        handles.(['FolderSessionName',num2str(k)])= uicontrol(handles.figure1,...
                                                    'style','text',...
                                                    'units','normalized',...
                                                    'position',[0.8 0.9-(0.9/(NumFilesToConcatenate+1))*k 0.08 0.04],...
                                                    'String',ExpeInfo.PreProcessingInfo.FolderSessionName{1,k},...
                                                    'callback', {@FolderSession,k});

        handles.(['RefDone',num2str(k)])= uicontrol(handles.figure1,...
                                                    'style','radiobutton',...
                                                    'units','normalized',...
                                                    'position',[0.92 0.9-(0.9/(NumFilesToConcatenate+1))*k 0.08 0.02],...
                                                    'String','Ref done',...
                                                    'Value',1,...
                                                    'Enable','off');

        handles.(['MergeDone',num2str(k)])= uicontrol(handles.figure1,...
                                                    'style','radiobutton',...
                                                    'units','normalized',...
                                                    'position',[0.92 0.9-(0.9/(NumFilesToConcatenate+1))*k+0.02 0.08 0.02],...
                                                    'String','Merge done',...
                                                    'Value',1,...
                                                    'Enable','off');

        ExpeInfo.PreProcessingInfo.MergeDone{k} = 1;
        ExpeInfo.PreProcessingInfo.RefDone{k} = 1;

    end
    handles.ExpeInfo = ExpeInfo;
    set(handles.DoneButton,'enable','on')
    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes GUIGetOldFilesToConcatenate wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUIGetOldFilesToConcatenate_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% % Marks whether or not the channels should be used for subtraction
% function GetFolder(hObject, eventdata, Num)
% TempData = guidata(hObject);
% 
% % get the folder with ephys
% directoryname = uigetdir(cd, 'Click on the ephys folder');
% TempData.ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys{Num} = directoryname;
% set(TempData.(['FileLocation_Ephys',num2str(Num)]),'String',directoryname);
% guidata(hObject,TempData)
% set(TempData.(['FileLocation_Ephys',num2str(Num)]),'BackGroundColor',[0.8 0.4 0.2])
% 
% directoryname = uigetdir(cd, 'Click on the behaviour folder');
% TempData.ExpeInfo.PreProcessingInfo.FolderForConcatenation_Behav{Num} = directoryname;
% set(TempData.(['FileLocation_Behav',num2str(Num)]),'String',directoryname);
% guidata(hObject,TempData)
% set(TempData.(['FileLocation_Behav',num2str(Num)]),'BackGroundColor',[0.8 0.4 0.2])
% 
% 
% if sum(~cellfun(@isempty,TempData.ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys),2) == TempData.ExpeInfo.PreProcessingInfo.NumFilesToConcatenate && ...
%       sum(~cellfun(@isempty,TempData.ExpeInfo.PreProcessingInfo.FolderSessionName),2) == TempData.ExpeInfo.PreProcessingInfo.NumFilesToConcatenate  
%     set(TempData.DoneButton,'enable','on')
% end
% 
% 
% % Marks whether or not the channels should be used for subtraction
% function FolderSession(hObject, eventdata, Num)
% TempData = guidata(hObject);
%  get(hObject,'String')
% TempData.ExpeInfo.PreProcessingInfo.FolderSessionName{Num} = get(hObject,'String');
% guidata(hObject,TempData)
% set(TempData.(['FolderSessionName',num2str(Num)]),'BackGroundColor',[0.8 0.4 0.2])
% if sum(~cellfun(@isempty,TempData.ExpeInfo.PreProcessingInfo.FolderForConcatenation_Ephys),2) == TempData.ExpeInfo.PreProcessingInfo.NumFilesToConcatenate && ...
%       sum(~cellfun(@isempty,TempData.ExpeInfo.PreProcessingInfo.FolderSessionName),2) == TempData.ExpeInfo.PreProcessingInfo.NumFilesToConcatenate  
%     set(TempData.DoneButton,'enable','on')
% end
% 
% % Marks whether or not the channels should be used for subtraction
% function RefDone(hObject, eventdata, Num)
% TempData = guidata(hObject);
% TempData.ExpeInfo.PreProcessingInfo.RefDone{Num} = hObject.Value;
% guidata(hObject,TempData)
% 
% % Marks whether or not the channels should be used for subtraction
% function MergeDone(hObject, eventdata, Num)
% TempData = guidata(hObject);
% TempData.ExpeInfo.PreProcessingInfo.MergeDone{Num} = hObject.Value;
% guidata(hObject,TempData)


% --- Executes on button press in DoneButton.
function DoneButton_Callback(hObject, eventdata, handles)
% TempData = guidata(hObject);
% ExpeInfo = TempData.ExpeInfo;
ExpeInfo.PreProcessingInfo
save('ExpeInfo.mat','ExpeInfo')
delete(TempData.figure1)
