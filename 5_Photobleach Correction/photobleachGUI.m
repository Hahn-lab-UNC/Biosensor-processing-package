function varargout = photobleachGUI(varargin)
% PHOTOBLEACHGUI MATLAB code for photobleachGUI.fig
%      PHOTOBLEACHGUI, by itself, creates a new PHOTOBLEACHGUI or raises the existing
%      singleton*.
%
%      H = PHOTOBLEACHGUI returns the handle to a new PHOTOBLEACHGUI or the handle to
%      the existing singleton*.
%
%      PHOTOBLEACHGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHOTOBLEACHGUI.M with the given input arguments.
%
%      PHOTOBLEACHGUI('Property','Value',...) creates a new PHOTOBLEACHGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before photobleachGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to photobleachGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help photobleachGUI

% Last Modified by GUIDE v2.5 16-Aug-2016 14:48:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @photobleachGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @photobleachGUI_OutputFcn, ...
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


% --- Executes just before photobleachGUI is made visible.
function photobleachGUI_OpeningFcn(hObject, ~, handles, varargin)

% Choose default command line output for photobleachGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = photobleachGUI_OutputFcn(~, ~, handles)
varargout{1} = handles.output;


%#ok<*DEFNU>
%% Helper Functions
function update_plot(hObject)
handles = guidata(hObject);
frames = handles.numframe;
x = (1:frames);
y = handles.norms;
exclude = handles.exclusions;
handles.fit_exclude = exclude;

if ~isempty(exclude)
    x(exclude) = [];
    y(exclude) = []; 
end

y = y.';
x = x.';
[fitobject,gof] = fit(x, y, 'exp2'); % double exponential fit
fit_curve = fitobject(x); % produce fitted curve using the plane numbers

handles.correction_factors = 1./fit_curve; % correction factors (inverse of decay function)
guidata(hObject,handles);

% grab coefficient values from fit
a = fitobject.a;
b = fitobject.b;
c = fitobject.c;
d = fitobject.d;
rsquare = gof.rsquare;
set(handles.text1,'String',sprintf('Equation:\ny = a*exp(b*x) + c*exp(d*x)\nr^2 = %.3f\n\nCoefficients:\na = %.3f,  b = %.3f,\nc = %.3f,  d = %.3f',...
    rsquare,a,b,c,d...
    ));

% plot photobleach correction curve
axes(handles.axes1);
hold on
plot((1:frames),handles.norms,'g.'); % plot all data points
if handles.fit_plot ~= 0
    set(handles.fit_plot,'XData',x,'YData',fitobject(0:length(x)-1));
else
    handles.fit_plot = plot(x,fitobject(0:length(x)-1),'k-'); % plot current fit to data
end
plot(exclude,handles.norms(exclude),'r.'); % plot excluded points from current fit
title('Double exponential fit of normalized average intensity values');
xlabel('Time Frame');
ylabel('Normalized Intensity Decay');
axis([0, frames, 0, 1.4]);

guidata(hObject,handles);

function update_region(position, hObject)
handles = guidata(hObject);
handles.position = position; % define the current position of imrect
left_ex = round(position(1));
right_ex = round(position(1)+position(3));
bottom_ex = position(2);
top_ex = position(2)+position(4);

% points to highlight
x_ex = (left_ex:right_ex);
y_ex = handles.norms(left_ex:right_ex);
j = 0;
for i = 1:length(x_ex)
    index = i;
    if j ~= 0
        index = index + j;
    end
    if y_ex(index) < bottom_ex || y_ex(index) > top_ex
        j = j - 1;
        y_ex(index) = [];
        x_ex(index) = [];
    end
end

% all points
frames = handles.numframe;
x = (1:frames);
y = handles.norms;

% make highlighted points inside of imrect appear red
plot(x,y,'g.'); % plot all points
plot(handles.fit_exclude,handles.norms(handles.fit_exclude),'b.'); % plot excluded points of current fit
plot(handles.exclusions,y(handles.exclusions),'r.'); % plot selected exclusion points for future fit
plot(x_ex,y_ex,'m.'); % plot points in imrect

guidata(hObject,handles);

function norm_matrix = norm_avg_intensities(hObject)
handles = guidata(hObject);
avg_matrix = zeros(1,handles.numframe);
norm_matrix = zeros(1,handles.numframe);
for i = 1:handles.numframe
    im = handles.frames{i};
    im_area = im;
    im_area(im_area>0) = 1;
    cell_area = sum(im_area(:));
    avg_matrix(i) = double(sum(im(:)))./cell_area;
    norm_matrix(i) = avg_matrix(i)/avg_matrix(1);
end
guidata(hObject,handles);

function deletebox(hObject,~,event)
handles = guidata(hObject);
if (strcmp(event.Key,'delete') ~= 1 && strcmp(event.Key,'backspace') ~= 1)
    return;
end
try %#ok<TRYNC>
    delete(handles.rect);
end
handles.select = 0;
set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
handles.exclusions = [];
if ~isempty(handles.exclusions) && ~isempty(handles.fit_exclude) && length(handles.exclusions) == length(handles.fit_exclude)
    if handles.exclusions == handles.fit_exclude
        set(handles.pushbutton3,'Enable','off');
    else
        set(handles.pushbutton3,'Enable','on');
    end
elseif isempty(handles.exclusions) && isempty(handles.fit_exclude)
    set(handles.pushbutton3,'Enable','off');
else
    set(handles.pushbutton3,'Enable','on');
end
plot((1:handles.numframe),handles.norms,'g.',handles.fit_exclude,handles.norms(handles.fit_exclude),'b.');
guidata(hObject,handles);


%% Push Buttons
function pushbutton1_Callback(hObject, ~, handles) 
position = handles.position; % define the current position of imrect
left_ex = round(position(1));
right_ex = round(position(1)+position(3));
bottom_ex = position(2);
top_ex = position(2)+position(4);

% points to exclude
x_ex = (left_ex:right_ex);
y_ex = handles.norms(left_ex:right_ex);
j = 0;
for i = 1:length(x_ex)
    index = i;
    if j ~= 0
        index = index + j;
    end
    if y_ex(index) < bottom_ex || y_ex(index) > top_ex
        j = j - 1;
        y_ex(index) = [];
        x_ex(index) = [];
    end
end
handles.exclusions = sort(union(x_ex,handles.exclusions));

if ~isempty(handles.exclusions)
    set(handles.pushbutton2,'Enable','on');
end
if ~isempty(handles.exclusions) && ~isempty(handles.fit_exclude) &&  length(handles.exclusions) == length(handles.fit_exclude)
    if handles.exclusions == handles.fit_exclude
        set(handles.pushbutton3,'Enable','off');
    else
        set(handles.pushbutton3,'Enable','on');
    end
elseif isempty(handles.exclusions) && isempty(handles.fit_exclude)
    set(handles.pushbutton3,'Enable','off');
else
    set(handles.pushbutton3,'Enable','on');
end

guidata(hObject,handles);
function pushbutton2_Callback(hObject, ~, handles)
position = handles.position; % define the current position of imrect
left_in = round(position(1));
right_in = round(position(1)+position(3));
bottom_in = position(2);
top_in = position(2)+position(4);

% points to include
x_in = (left_in:right_in);
y_in = handles.norms(left_in:right_in);
j = 0;
for i = 1:length(x_in)
    index = i;
    if j ~= 0
        index = index + j;
    end
    if y_in(index) < bottom_in || y_in(index) > top_in
        j = j - 1;
        y_in(index) = [];
        x_in(index) = [];
    end
end

for i = 1:length(x_in)
    if any(handles.exclusions==x_in(i))
        handles.exclusions(handles.exclusions==x_in(i)) = [];
    end
end

if isempty(handles.exclusions)
    set(handles.pushbutton2,'Enable','off');
end
if ~isempty(handles.exclusions) && ~isempty(handles.fit_exclude) && length(handles.exclusions) == length(handles.fit_exclude)
    if handles.exclusions == handles.fit_exclude
        set(handles.pushbutton3,'Enable','off');
    else
        set(handles.pushbutton3,'Enable','on');
    end
elseif isempty(handles.exclusions) && isempty(handles.fit_exclude)
    set(handles.pushbutton3,'Enable','off');
else
    set(handles.pushbutton3,'Enable','on');
end

guidata(hObject,handles);
function pushbutton3_Callback(hObject, ~, handles)
set(handles.pushbutton3,'Enable','off');
update_plot(hObject);
handles.fit_exclude = handles.exclusions;
guidata(hObject,handles);


%% Menu Option Tags
function file_tag_Callback(~, ~, ~)
function tools_tag_Callback(~, ~, ~)

function import_tag_Callback(hObject, ~, handles)

if ~isempty(get(handles.axes1,'Children'))
    set(handles.pushbutton1,'Enable','off');
    set(handles.pushbutton2,'Enable','off');
    set(handles.pushbutton3,'Enable','off');
    set(handles.import_tag,'Enable','off');
    set(handles.select_tag,'Enable','off');
    set(handles.save_tag,'Enable','off');
    set(handles.uitoggletool1,'Enable','off');
    set(handles.uitoggletool2,'Enable','off');
    set(handles.uitoggletool3,'Enable','off');
end

disp('Select a ".tif" file to open')
[file, path] = uigetfile('*.tif','Select a ".tif" file to open');
if file == 0
    return;
end

if ~isempty(get(handles.axes1,'Children'))
    cla;
end

% get image information
info = imfinfo(fullfile(path,file));
handles.width = info(1).Width;
handles.height = info(1).Height;
handles.numframe = length(info);

handles.frames = cell(1,handles.numframe);
for i = 1:handles.numframe
   handles.frames{i} = imread(fullfile(path,file),i);
end

guidata(hObject,handles);

% get array of normalized average intensities of time frames
if handles.numframe < 4
    choice = questdlg('Photobleach correction requires the image series to have at least 4 time frames. Would you like to continue processing without photobleach correction?', ...
            'Insufficient Number of Frames', ...
            'Skip Photobleach Correction','Select New Image','Select New Image');
    switch choice
        case 'Skip Photobleach Correction'
            if exist('run_opts.mat','file') == 2
                load('run_opts.mat');
                opts{1,1}.photobleach = 0;
                save('run_opts.mat');
                clear opts
            end
            delete(handles.figure1)
            disp('Photobleach Correction skipped')
            return
        case 'Select New Image'
            return
    end        
else
    handles.norms = norm_avg_intensities(hObject);
end

handles.exclusions = [];
handles.fit_exclude = [];
handles.select = 0;
handles.fit_plot = 0;

set(handles.import_tag,'Enable','on');
set(handles.select_tag,'Enable','on');
set(handles.save_tag,'Enable','on');
set(handles.uitoggletool1,'Enable','on');
set(handles.uitoggletool2,'Enable','on');
set(handles.uitoggletool3,'Enable','on');

% set delete key functionality
set(handles.figure1,'WindowKeyPressFcn',@(src,evnt)deletebox(handles.figure1,src,evnt));

guidata(hObject,handles);
update_plot(hObject);

function save_tag_Callback(hObject, ~, handles)

set(handles.pushbutton1,'Enable','off');
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton3,'Enable','off');
set(handles.import_tag,'Enable','off');
set(handles.select_tag,'Enable','off');
set(handles.save_tag,'Enable','off');
set(handles.uitoggletool1,'Enable','off');
set(handles.uitoggletool2,'Enable','off');
set(handles.uitoggletool3,'Enable','off');

% prompt user with save box
dlg_title = 'Save the Photobleach Corrected Images to ".tif" file';
[file_name,path_name,filter] = uiputfile('*.tif',dlg_title,'_pbc');

if filter
    % store old directory path and change to path of save file specified
    old_dir = cd(path_name);
    
    for i = 1:handles.numframe
        im = double(handles.frames{i});
        im_pbc = im.*handles.correction_factors(i);
        im_pbc = uint16(im_pbc);

        try 
            imwrite(im_pbc,file_name,'tif','Compression','none','WriteMode','append');
        catch
            pause(1)
%             fprintf('PHOTOBLEACH Iteration value: %i\n', i);
            imwrite(im_pbc,file_name,'tif','Compression','none','WriteMode','append');
        end
    end
    
    % switch to old directory
    cd(old_dir);
end

set(handles.pushbutton1,'Enable','on');
if ~isempty(handles.exclusions)
    set(handles.pushbutton2,'Enable','on');
end
set(handles.import_tag,'Enable','on');
set(handles.select_tag,'Enable','on');
set(handles.save_tag,'Enable','on');
set(handles.uitoggletool1,'Enable','on');
set(handles.uitoggletool2,'Enable','on');
set(handles.uitoggletool3,'Enable','on');

guidata(hObject,handles);

function select_tag_Callback(hObject, ~, handles)
if handles.select == 1
    return;
end
set(handles.pushbutton1,'Enable','On');
handles.select = 1;
initial_position = [5 0.5 20 0.5];
handles.position = initial_position;
handles.rect = imrect(handles.axes1,initial_position);
fcn = makeConstrainToRectFcn('imrect',[1,handles.numframe],[0,1.4]);
setPositionConstraintFcn(handles.rect,fcn); 
handles.rect.addNewPositionCallback(@(pos)update_region(pos,hObject));

position = handles.position;
left_ex = round(position(1));
right_ex = round(position(1)+position(3));
bottom_ex = position(2);
top_ex = position(2)+position(4);

% points to highlight
x_ex = (left_ex:right_ex);
y_ex = handles.norms(left_ex:right_ex);
j = 0;
for i = 1:length(x_ex)
    index = i;
    if j ~= 0
        index = index + j;
    end
    if y_ex(index) < bottom_ex || y_ex(index) > top_ex
        j = j - 1;
        y_ex(index) = [];
        x_ex(index) = [];
    end
end

plot(x_ex,y_ex,'m.');

guidata(hObject,handles);
