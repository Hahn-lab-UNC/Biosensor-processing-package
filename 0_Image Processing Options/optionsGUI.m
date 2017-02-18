function varargout = optionsGUI(varargin)
%OPTIONSGUI M-file for optionsGUI.fig
%      OPTIONSGUI, by itself, creates a new OPTIONSGUI or raises the existing
%      singleton*.
%
%      H = OPTIONSGUI returns the handle to a new OPTIONSGUI or the handle to
%      the existing singleton*.
%
%      OPTIONSGUI('Property','Value',...) creates a new OPTIONSGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to optionsGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      OPTIONSGUI('CALLBACK') and OPTIONSGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in OPTIONSGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help optionsGUI

% Last Modified by GUIDE v2.5 23-Aug-2016 14:52:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @optionsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @optionsGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before optionsGUI is made visible.
function optionsGUI_OpeningFcn(hObject, ~, handles, varargin)
set(handles.figure1,'Visible','on');
handles.output = 0;

% handle for user option selections
handles.opts = struct;

handles.opts.ratios = [1,0,0,0];
handles.opts.one_mask = 0;
handles.opts.dark = 0;
handles.opts.photobleach = 0;
handles.opts.align_cams = 0;
handles.opts.split = 0;
handles.opts.filter = 0;

handles.opts.reg_option = 1;
handles.opts.svd = 1;
handles.opts.orientation = 1;

handles.opts.alpha = 0.00;
handles.opts.beta = 0.00;

% update handles
guidata(hObject, handles);

% wait for figure 1 to lose visibility (in pushbutton2 callback)
waitfor(handles.figure1,'Visible','off');


% --- Outputs from this function are returned to the command line.
function varargout = optionsGUI_OutputFcn(~, ~, handles)
varargout{1} = handles.output;
delete(handles.figure1);


%#ok<*DEFNU>
%% Check Boxes
function checkbox1_Callback(hObject, ~, handles)
state = get(hObject,'Value');
handles.opts.ratios(1) = state;
guidata(hObject,handles);
function checkbox2_Callback(hObject, ~, handles)
state = get(hObject,'Value');
handles.opts.ratios(2) = state;
guidata(hObject,handles);
function checkbox3_Callback(hObject, ~, handles)
state = get(hObject,'Value');
handles.opts.ratios(3) = state;
guidata(hObject,handles);
function checkbox4_Callback(hObject, ~, handles)
state = get(hObject,'Value');
handles.opts.ratios(4) = state;
guidata(hObject,handles);
function checkbox5_Callback(hObject, ~, handles)
state = get(hObject,'Value');
handles.opts.one_mask = state;
if state == 1
    set(handles.radiobutton3,'Enable','off');
    set(handles.radiobutton3,'Value',0.0);
    set(handles.radiobutton1,'Value',1.0);
    handles.opts.reg_option = 1;
    set(handles.radiobutton2,'Value',0.0);
else
    set(handles.radiobutton3,'Enable','on');
end
guidata(hObject,handles);
function checkbox6_Callback(hObject, ~, handles)
state = get(hObject,'Value');
handles.opts.dark = state;
guidata(hObject,handles);
function checkbox7_Callback(hObject, ~, handles)
state = get(hObject,'Value');
handles.opts.photobleach = state;
guidata(hObject,handles);
function checkbox8_Callback(hObject, ~, handles)
state = get(hObject,'Value');
handles.opts.align_cams = state;
guidata(hObject,handles);
function checkbox9_Callback(hObject, ~, handles)
state = get(hObject,'Value');
handles.opts.split = state;
if state == 1
    set(handles.pushbutton1,'Visible','on');
    set(handles.text12,'Visible','on');
    set(handles.uipanel5,'Visible','on');
else
    set(handles.pushbutton1,'Visible','off');
    set(handles.text12,'Visible','off');
    set(handles.uipanel5,'Visible','off');
end
guidata(hObject,handles);
function checkbox10_Callback(hObject, ~, handles)
state = get(hObject,'Value');
handles.opts.filter = state;
guidata(hObject,handles);


%% Push Buttons
function pushbutton1_Callback(hObject, ~, handles)
if handles.opts.orientation == 1 
    handles.opts.orientation = 2;
    set(handles.text14,'String','Donor');
    set(handles.text15,'String','FRET');
    set(handles.text16,'String','----------');
    set(handles.text17,'String','Acceptor');
else
    handles.opts.orientation = 1;
    set(handles.text14,'String','FRET');
    set(handles.text15,'String','Donor');
    set(handles.text16,'String','Acceptor');
    set(handles.text17,'String','----------');  
end
guidata(hObject,handles);
function pushbutton2_Callback(hObject, ~, handles)
handles.output = handles.opts;
opts = {handles.opts}; %#ok<NASGU>
save('run_opts.mat', 'opts')
guidata(hObject,handles);
set(handles.figure1,'Visible','off');
function pushbutton3_Callback(hObject, ~, handles)
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton3,'Enable','off');
[alpha,beta] = bleedthrough_correction;
set(handles.edit1,'String',num2str(alpha));
set(handles.edit2,'String',num2str(beta));
set(handles.pushbutton2,'Enable','on');
set(handles.pushbutton3,'Enable','on');
guidata(hObject,handles);


%% Radio Button Groups
function uibuttongroup1_SelectionChangedFcn(hObject, ~, handles)
state = get(hObject,'Tag');
if strcmp(state,'radiobutton1')
    handles.opts.reg_option = 1;
end
if strcmp(state,'radiobutton2')
    handles.opts.reg_option = 2;
end
if strcmp(state,'radiobutton3')
    handles.opts.reg_option = 3;
end
guidata(hObject,handles);
function uibuttongroup2_SelectionChangedFcn(hObject, ~, handles)
state = get(hObject,'Tag');
if strcmp(state,'radiobutton4')
    set(handles.pushbutton3,'Enable','off');
    handles.opts.svd = 1;
    set(handles.edit1,'Enable','off');
    set(handles.edit2,'Enable','off');
    set(handles.edit1,'String','0.00');
    set(handles.edit2,'String','0.00');
    handles.opts.alpha = 0.00;
    handles.opts.beta = 0.00;
    set(handles.checkbox3,'Enable','off');
    set(handles.checkbox4,'Enable','off');
    set(handles.checkbox3,'Value',0.0);
    set(handles.checkbox4,'Value',0.0);
    handles.opts.ratios(3) = 0;
    handles.opts.ratios(4) = 0;
end
if strcmp(state,'radiobutton5')
    set(handles.pushbutton3,'Enable','on');
    handles.opts.svd = 2;
    % Delete 2 lines below when config file is added
    set(handles.edit1,'Enable','on');
    set(handles.edit2,'Enable','on');
    %
    if exist('bleedthrough_coeffs.txt','file') == 2
        fid = fopen('bleedthrough_coeffs.txt','r');
        str = fscanf(fid, '%c');
        expression = 'alpha = (\d*[.]\d*)\nbeta = (\d*[.]\d*)';
        tokens = regexp(str, expression, 'tokens');
        handles.opts.alpha = str2double(tokens{1}{1});
        handles.opts.beta = str2double(tokens{1}{2});
        set(handles.edit1,'String',tokens{1}{1});
        set(handles.edit2,'String',tokens{1}{2});
        fclose(fid);
    else
        handles.opts.alpha = 0.00;
        handles.opts.beta = 0.00;
        set(handles.edit1,'String','0.00');
        set(handles.edit2,'String','0.00');
    end
    set(handles.checkbox3,'Enable','on');
    set(handles.checkbox4,'Enable','on');
end
guidata(hObject,handles);


%% Edit Boxes
function edit1_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit2_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, ~, handles)
alpha_in = str2double(get(hObject,'String'));
max = 1.5;
if alpha_in < 0
    set(handles.edit1,'String','0.00');
    alpha_out = 0.0;
elseif alpha_in > max
    set(handles.edit1,'String','1.50');
    alpha_out = 1.5;
elseif isnan(alpha_in)
    set(handles.edit1,'String','0.00');
    alpha_out = 0.0;
else
    set(handles.edit1,'String',num2str(alpha_in));
    alpha_out = alpha_in;
end
handles.opts.alpha = alpha_out;
guidata(hObject,handles);
function edit2_Callback(hObject, ~, handles)
beta_in = str2double(get(hObject,'String'));
max = 1.5;
if beta_in < 0
    set(handles.edit2,'String','0.00');
    beta_out = 0.0;
elseif beta_in > max
    set(handles.edit2,'String','1.50');
    beta_out = 1.5;
elseif isnan(beta_in)
    set(handles.edit2,'String','0.00');
    beta_out = 0.0;
else
    set(handles.edit2,'String',num2str(beta_in));
    beta_out = beta_in;
end
handles.opts.beta = beta_out;
guidata(hObject,handles);


%% Figure Close w/o Continuing Processing
function figure1_CloseRequestFcn(hObject, ~, handles)
handles.output = 0;
guidata(hObject,handles);
set(handles.figure1,'Visible','off');