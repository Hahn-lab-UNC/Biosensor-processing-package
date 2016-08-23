function varargout = coefficient_selector(varargin)
% COEFFICIENT_SELECTOR MATLAB code for coefficient_selector.fig
%      COEFFICIENT_SELECTOR, by itself, creates a new COEFFICIENT_SELECTOR or raises the existing
%      singleton*.
%
%      H = COEFFICIENT_SELECTOR returns the handle to a new COEFFICIENT_SELECTOR or the handle to
%      the existing singleton*.
%
%      COEFFICIENT_SELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COEFFICIENT_SELECTOR.M with the given input arguments.
%
%      COEFFICIENT_SELECTOR('Property','Value',...) creates a new COEFFICIENT_SELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before coefficient_selector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to coefficient_selector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help coefficient_selector

% Last Modified by GUIDE v2.5 23-Aug-2016 15:07:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @coefficient_selector_OpeningFcn, ...
                   'gui_OutputFcn',  @coefficient_selector_OutputFcn, ...
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


% --- Executes just before coefficient_selector is made visible.
function coefficient_selector_OpeningFcn(hObject, ~, handles, varargin)
set(handles.figure1,'Visible','on');
handles.output = hObject;

handles.coeffs = varargin{1};
handles.alpha_avg = 0;
handles.beta_avg = 0;
handles.exclude = 0;

init_tables(hObject,handles);
handles = guidata(hObject);
guidata(hObject, handles);

% wait for figure 1 to lose visibility (in pushbutton1 or 3 callbacks)
waitfor(handles.figure1,'Visible','off');

function varargout = coefficient_selector_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;
delete(handles.figure1);


%% Helper Function
function init_tables(hObject,handles)
a = handles.coeffs.alpha;
b = handles.coeffs.beta;
if length(a) < length(b)
    diff = length(b)-length(a);
    var = nan(1,diff);
    a = [a var];
elseif length(b) < length(a)
    diff = length(a)-length(b);
    var = nan(1,diff);
    b = [b var];
end
data = [a',b'];
set(handles.uitable1,'Data',data);
set(handles.uitable2,'Data',data);
handles.alpha_avg = nanmean(data(:,1));
str_a = sprintf('Final Alpha Coefficient:\n\n         %.3f',handles.alpha_avg);
set(handles.text3,'String',str_a);
handles.beta_avg = nanmean(data(:,2));
str_b = sprintf('Final Beta Coefficient:\n\n         %.3f',handles.beta_avg);
set(handles.text4,'String',str_b);
guidata(hObject,handles);


%#ok<*DEFNU>
%% Push Buttons
function pushbutton1_Callback(hObject, ~, handles)
alpha = handles.alpha_avg;
beta = handles.beta_avg;
handles.output = [alpha,beta];
guidata(hObject,handles);
set(handles.figure1,'Visible','off');
function pushbutton2_Callback(hObject, ~, handles)
excludes = handles.exclude;
data = get(handles.uitable1,'Data');
[rows,~] = size(excludes);
for i = 1:rows
    data(excludes(i,1),excludes(i,2)) = NaN;
end
set(handles.uitable2,'Data',data);
handles.alpha_avg = nanmean(data(:,1));
str_a = sprintf('Final Alpha Coefficient:\n\n         %.3f',handles.alpha_avg);
set(handles.text3,'String',str_a);
handles.beta_avg = nanmean(data(:,2));
str_b = sprintf('Final Beta Coefficient:\n\n         %.3f',handles.beta_avg);
set(handles.text4,'String',str_b);
guidata(hObject,handles);
function pushbutton3_Callback(hObject, ~, handles)
choice = questdlg('Starting over will erase all progress and bring the user back to the initial bleedthrough GUI. Are you sure you wish to start over?', ...
	'Start Over Warning',...
    'Start Over','Continue Calculations','Continue Calculations');
switch choice
    case 'Start Over'
        redo = 1;
    case 'Continue Calculations'
        redo = 0;
end
if redo == 0
    return
else
    handles.output = 1;
    guidata(hObject,handles);
    set(handles.figure1,'Visible','off');
end
function pushbutton4_Callback(~, ~, handles)
alpha = handles.alpha_avg;
beta = handles.beta_avg;
dlg_title = 'Save the Bleedthrough Coefficients to a ".txt" file';
[file_name,path_name,filter] = uiputfile('*.txt',dlg_title,'bleedthrough_coeffs');
if filter
    % store old directory path and change to path of save file specified
    old_dir = cd(path_name);
    
    fileID = fopen(file_name,'w');
    
    fprintf(fileID,'alpha = %.3f\nbeta = %.3f',alpha,beta);
    
    fclose(fileID);
    
    % switch background_subtractionGUI to old directory
    cd(old_dir);
end


%% UI Table
function uitable2_CellSelectionCallback(hObject, eventdata, handles)
handles.exclude = eventdata.Indices;
guidata(hObject,handles);


%% Close Request Function
function figure1_CloseRequestFcn(hObject, ~, handles)
choice = questdlg('Exiting will discontinue bleedthrough correction calculations and all progress will be lost. Are you sure you wish to exit?', ...
	'Exit Warning',...
    'Exit','Continue Calculations','Continue Calculations');
switch choice
    case 'Exit'
        close = 1;
    case 'Continue Calculations'
        close = 0;
end

if close == 0
    return
else
    handles.output = 0;
    guidata(hObject,handles);
    set(handles.figure1,'Visible','off');
end
