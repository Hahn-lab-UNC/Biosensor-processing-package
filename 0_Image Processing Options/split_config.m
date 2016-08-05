function varargout = split_config(varargin)
% SPLIT_CONFIG MATLAB code for split_config.fig
%      SPLIT_CONFIG, by itself, creates a new SPLIT_CONFIG or raises the existing
%      singleton*.
%
%      H = SPLIT_CONFIG returns the handle to a new SPLIT_CONFIG or the handle to
%      the existing singleton*.
%
%      SPLIT_CONFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPLIT_CONFIG.M with the given input arguments.
%
%      SPLIT_CONFIG('Property','Value',...) creates a new SPLIT_CONFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before split_config_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to split_config_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help split_config

% Last Modified by GUIDE v2.5 05-Jul-2016 10:44:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @split_config_OpeningFcn, ...
                   'gui_OutputFcn',  @split_config_OutputFcn, ...
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

% --- Helper Functions --- %
function setGlobaltoggle(value)
global var
var= value;

function value = getGlobaltoggle
global var
value = var;

% --- Executes just before split_config is made visible.
function split_config_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to split_config (see VARARGIN)

% Choose default command line output for split_config
handles.output = hObject;

setGlobaltoggle(1.0);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes split_config wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = split_config_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

out = getGlobaltoggle;

% Get default command line output from handles structure
varargout{1} = out;


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

temp = get(hObject,'Tag');

if strcmp(temp,'radiobutton1')
	setGlobaltoggle(1.0);
else
	setGlobaltoggle(2.0);
end

guidata(hObject, handles);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);


function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
setGlobaltoggle(0);
delete(hObject);
