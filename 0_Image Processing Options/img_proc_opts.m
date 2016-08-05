function varargout = img_proc_opts(varargin)
% IMG_PROC_OPTS MATLAB code for img_proc_opts.fig
%      IMG_PROC_OPTS, by itself, creates a new IMG_PROC_OPTS or raises the existing
%      singleton*.
%
%      H = IMG_PROC_OPTS returns the handle to a new IMG_PROC_OPTS or the handle to
%      the existing singleton*.
%
%      IMG_PROC_OPTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMG_PROC_OPTS.M with the given input arguments.
%
%      IMG_PROC_OPTS('Property','Value',...) creates a new IMG_PROC_OPTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before img_proc_opts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to img_proc_opts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help img_proc_opts

% Last Modified by GUIDE v2.5 24-Jul-2015 09:33:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @img_proc_opts_OpeningFcn, ...
                   'gui_OutputFcn',  @img_proc_opts_OutputFcn, ...
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
function setGlobaltoggle(arr)
global toggleArr
toggleArr = arr;

function arr = getGlobaltoggle
global toggleArr
arr = toggleArr;

% --- Executes just before img_proc_opts is made visible.
function img_proc_opts_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to img_proc_opts (see VARARGIN)

% Choose default command line output for img_proc_opts
handles.output = hObject;

A = zeros(9, 1);
A(1) = 1;
A(2) = 1;
A(4) = 1;
A(7) = 1;
setGlobaltoggle(A);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes img_proc_opts wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = img_proc_opts_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

B = getGlobaltoggle;

varargout{1} = B;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
A = getGlobaltoggle;

str = get( hObject, 'String' );

if strcmp( str, 'Single Chain' )
	A(1) = 1;
else
	A(1) = 2;
end

setGlobaltoggle(A);
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup2.
function uibuttongroup2_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup2 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
A = getGlobaltoggle;

str = get( hObject, 'String' );

if strcmp( str, 'Split' )
	A(2) = 1;
else
	A(2) = 2;
end

setGlobaltoggle(A);
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup3.
function uibuttongroup3_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup3 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
A = getGlobaltoggle;

str = get( hObject, 'String' );

if strcmp( str, 'No' )
	A(3) = 0;
else
	A(3) = 1;
end

setGlobaltoggle(A);
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup4.
function uibuttongroup4_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup4 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
A = getGlobaltoggle;

str = get( hObject, 'String' );

if strcmp( str, 'No' )
	A(4) = 0;
else
	A(4) = 1;
end

setGlobaltoggle(A);
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup5.
function uibuttongroup5_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup5 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
A = getGlobaltoggle;

str = get( hObject, 'String' );

if strcmp( str, 'HMF' )
	A(5) = 1;
else
    A(5) = 0;
end

setGlobaltoggle(A);
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup6.
function uibuttongroup6_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup6 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
A = getGlobaltoggle;

str = get( hObject, 'String' );

if strcmp( str, 'No' )
	A(6) = 0;
else
	A(6) = 1;
end

setGlobaltoggle(A);
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup7.
function uibuttongroup7_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup7 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes when user attempts to close figure1.
A = getGlobaltoggle;

str = get( hObject, 'String' );

if strcmp( str, 'Yes' )
	A(7) = 1;
else
	A(7) = 0;
end

setGlobaltoggle(A);
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup8.
function uibuttongroup8_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup7 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes when user attempts to close figure1.
A = getGlobaltoggle;

str = get( hObject, 'String' );

if strcmp( str, 'No' )
	A(8) = 0;
else
	A(8) = 1;
end

setGlobaltoggle(A);
guidata(hObject, handles);

% --- Executes when selected object is changed in uibuttongroup8.
function uibuttongroup9_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup7 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes when user attempts to close figure1.
A = getGlobaltoggle;

str = get( hObject, 'String' );

if strcmp( str, 'No' )
	A(9) = 0;
else
	A(9) = 1;
end

setGlobaltoggle(A);
guidata(hObject, handles);

function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
setGlobaltoggle(0);
delete(hObject);
