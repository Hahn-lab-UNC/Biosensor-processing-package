function varargout = ratio_mask(varargin)
% RATIO_MASK MATLAB code for ratio_mask.fig
%      RATIO_MASK, by itself, creates a new RATIO_MASK or raises the existing
%      singleton*.
%
%      H = RATIO_MASK returns the handle to a new RATIO_MASK or the handle to
%      the existing singleton*.
%
%      RATIO_MASK('CALLBACK',hObject,~,handles,...) calls the local
%      function named CALLBACK in RATIO_MASK.M with the given input arguments.
%
%      RATIO_MASK('Property','Value',...) creates a new RATIO_MASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ratio_mask_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ratio_mask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ratio_mask

% Last Modified by GUIDE v2.5 18-Jan-2017 15:21:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ratio_mask_OpeningFcn, ...
                   'gui_OutputFcn',  @ratio_mask_OutputFcn, ...
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


% --- Executes just before ratio_mask is made visible.
function ratio_mask_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ratio_mask (see VARARGIN)

% Choose default command line output for ratio_mask
handles.output = hObject;
handles.border1 = cell(1,1);
handles.border1{1} = 0;
handles.border2 = 0;
% handles.border2{1} = 0;

user_data = get(handles.playtoggle1,'UserData');
user_data.stop = 0;
set(handles.playtoggle1,'UserData',user_data);

% Load additional colormaps
load('maps.mat')
handles.map1 = map1;
handles.map2 = map2;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes ratio_mask wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ratio_mask_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Helper Functions
function update_images(hObject,frame)
handles = guidata(hObject);
% update first axes
handles.cur1 = handles.frames1{frame};
if isempty(get(handles.axes1,'Children')) % is the axes empty (i.e. have any 'Children')
    % sets initial image
    set(handles.figure1,'CurrentAxes',handles.axes1);
    imagesc(handles.cur1,'Parent',handles.axes1); % image the current frame in 'handles.axes1'
    set(handles.axes1,'CLim',[handles.CLim_Min1, handles.CLim_Max1],'XTick',[],'YTick',[],'Box','on'); % set 'handles.axes1' properties
    set(handles.edit1, 'String', num2str(handles.CLim_Max1)); % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
    set(handles.edit2, 'String', num2str(handles.CLim_Min1)); % set the edit box 'CLim_Min_Tag' to the current CLim_val 'minimum'
    colorbar;
    axis image % sets the aspect ratio so that the data units are the same in every direction and the plot box fits tightly around the data
else
    imHandle = findobj(handles.axes1,'Type','image');
    set(imHandle,'CData',handles.cur1); % update the first image to the current frame
end

% update second axes
if handles.mask_toggle == 0 % mask toggle off - no mask applied to image
    handles.cur2 = handles.frames2{frame};
else % mask toggle on - mask applied to image
    handles.cur2 = double(handles.frames2{frame}).*double(handles.mask{frame});
end
if isempty(get(handles.axes2,'Children')) % is the axes empty (i.e. have any 'Children')
    % sets initial image
    set(handles.figure1,'CurrentAxes',handles.axes2);
    imagesc(handles.cur2,'Parent',handles.axes2); % image the current frame in 'handles.axes1'
    set(handles.axes2,'CLim',[handles.CLim_Min2, handles.CLim_Max2],'XTick',[],'YTick',[],'Box','on'); % set 'handles.axes1' properties
    set(handles.edit3, 'String', num2str(handles.CLim_Max2)); % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
    set(handles.edit4, 'String', num2str(handles.CLim_Min2)); % set the edit box 'CLim_Min_Tag' to the current CLim_val 'minimum'
    colorbar;
    axis image % sets the aspect ratio so that the data units are the same in every direction and the plot box fits tightly around the data
else
    imHandle = findobj(handles.axes2,'Type','image');
    set(imHandle,'CData',handles.cur2); % update the first image to the current frame
end
guidata(hObject,handles);


%% Listener Functions
function slider1(hObject,~,~)
handles = guidata(hObject);
set(handles.slider2,'Max',get(handles.slider1,'Value')-1.0);
set(handles.figure1,'CurrentAxes',handles.axes1);
set(handles.axes1,'CLim',[get(handles.slider2,'Value'),get(handles.slider1,'Value')]);
handles.CLim_Max1 = get(handles.slider1,'Value');
set(handles.edit1,'String',num2str(round(get(handles.slider1,'Value'))));
guidata(hObject, handles);
function slider2(hObject,~,~)
handles = guidata(hObject);
set(handles.slider1,'Min',get(handles.slider2,'Value')+1.0);
set(handles.figure1,'CurrentAxes',handles.axes1);
set(handles.axes1,'CLim',[get(handles.slider2,'Value'),get(handles.slider1,'Value')]);
handles.CLim_Min1 = get(handles.slider2,'Value');
set(handles.edit2,'String',num2str(round(get(handles.slider2,'Value')))); % set the edit box 'CLim_Min_Tag1' to the current CLim_val 'minimum'
guidata(hObject, handles);
function slider3(hObject,~,~)
handles = guidata(hObject);
set(handles.slider4,'Max',get(handles.slider3,'Value')-1.0);
set(handles.figure1,'CurrentAxes',handles.axes2);
set(handles.axes2,'CLim',[get(handles.slider4,'Value'),get(handles.slider3,'Value')]);
handles.CLim_Max2 = get(handles.slider3,'Value');
set(handles.edit4,'String',num2str(round(get(handles.slider3,'Value'))));
guidata(hObject, handles);
function slider4(hObject,~,~)
handles = guidata(hObject);
set(handles.slider3,'Min',get(handles.slider4,'Value')+1.0);
set(handles.figure1,'CurrentAxes',handles.axes2);
set(handles.axes2,'CLim',[get(handles.slider4,'Value'),get(handles.slider3,'Value')]);
handles.CLim_Min2 = get(handles.slider4,'Value');
set(handles.edit4,'String',num2str(round(get(handles.slider4,'Value')))); % set the edit box 'CLim_Min_Tag1' to the current CLim_val 'minimum'
guidata(hObject, handles);

function slider5(hObject,~,~)
handles = guidata(hObject);
frame = round(get(handles.slider5,'Value'));
update_images(hObject,frame);
set(handles.edit5,'String',num2str(frame,'%d')); % set the edit box to indicate the current frame number
guidata(hObject, handles);

function slider6(hObject,~,~)
handles = guidata(hObject);
frame = round(get(handles.slider5,'Value'));
handles.thresh_val = round(get(handles.slider6,'Value'));

% calculate boundary of frame based on threshold value
if handles.thresh_val > 0
    boundary_im = handles.frames1{frame} - handles.thresh_val;
    boundary_im(boundary_im<0) = 0;
    binary_im = imfill(logical(boundary_im),'holes');
    if max(binary_im(:)) == min(binary_im(:))
        binary_im = ones(size(handles.frames1{frame}));
    end
else
    binary_im = ones(size(handles.frames1{frame}));
end
bounds = bwboundaries(binary_im);

% plot the boundary on the axis
set(handles.figure1,'CurrentAxes',handles.axes1);
guidata(hObject,handles);
hold(handles.axes1,'on');
if handles.border1{1} ~= 0
    for i = 1:length(handles.border1)
        delete(handles.border1{i});
    end    
end
handles.border1 = cell(1,length(bounds));
for k =1:length(bounds)
    bx = bounds{k}(:,2);
    by = bounds{k}(:,1);
    handles.border1{k} = plot(handles.axes1,bx,by,handles.line_color,'LineWidth',1);
end

% update handles
set(handles.edit6,'String',num2str(handles.thresh_val,'%d')); % set the edit box to indicate the current frame number
guidata(hObject, handles);

function ratio_boundary(hObject,~,~)
handles = guidata(hObject);
frame = round(get(handles.slider5,'Value'));

% grab mask information
bx = handles.maskx{frame};
by = handles.masky{frame};

% plot the boundary on the axis
set(handles.figure1,'CurrentAxes',handles.axes2);
guidata(hObject,handles);
hold(handles.axes2,'on');
if handles.border2 ~= 0
    delete(handles.border2);
end
handles.border2 = plot(handles.axes2,bx,by,handles.line_color,'LineWidth',1);

%update handles
guidata(hObject, handles);


%#ok<*DEFNU>
%% CLim Sliders
function slider1_CreateFcn(hObject, ~, ~) 
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider2_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider3_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider4_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider1_Callback(~, ~, ~)
function slider2_Callback(~, ~, ~)
function slider3_Callback(~, ~, ~)
function slider4_Callback(~, ~, ~)


%% CLim Boxes
function edit1_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit2_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit3_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit4_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, ~, handles)
handles.CLim_Max1 = str2double(get(hObject,'String'));  % define in the structure 'handles' the maximum CLim value
set(handles.axes1,'CLim',[handles.CLim_Min1, handles.CLim_Max1]);  % set the CLim of the current frame
guidata(hObject,handles); % update handles structure
function edit2_Callback(hObject, ~, handles)
handles.CLim_Min1 = str2double(get(hObject,'String'));  % define in the structure 'handles' the minimum CLim value
set(handles.axes1,'CLim',[handles.CLim_Min1, handles.CLim_Max1]);  % set the CLim of the current frame
guidata(hObject,handles);  % update handles structure
function edit3_Callback(hObject, ~, handles)
handles.CLim_Max2 = str2double(get(hObject,'String'));  % define in the structure 'handles' the maximum CLim value
set(handles.axes2,'CLim',[handles.CLim_Min2, handles.CLim_Max2]);  % set the CLim of the current frame
guidata(hObject,handles); % update handles structure
function edit4_Callback(hObject, ~, handles)
handles.CLim_Min2 = str2double(get(hObject,'String'));  % define in the structure 'handles' the minimum CLim value
set(handles.axes2,'CLim',[handles.CLim_Min2, handles.CLim_Max2]);  % set the CLim of the current frame
guidata(hObject,handles);  % update handles structure


%% Sliders
function slider5_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider6_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider5_Callback(~, ~, ~)
function slider6_Callback(~, ~, ~)


%% Edit Boxes
function edit5_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit6_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit7_CreateFcn(hObject, ~, handles)
handles.pausetime = str2double(get(hObject,'String'));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

function edit5_Callback(hObject, ~, handles)
frame = str2double(get(hObject,'String'));
frame_max = get(handles.slider5,'Max');
if floor(frame) < 1
    set(handles.slider5,'Value',1);
elseif floor(frame) > frame_max
    set(handles.slider5,'Value',frame_max);
elseif isnan(frame)
    set(handles.slider5,'Value',1);
else
    set(handles.slider5,'Value',frame);
end
guidata(hObject,handles);
function edit6_Callback(hObject, ~, handles)
thresh = str2double(get(hObject,'String'));
thresh_max = get(handles.slider6,'Max');
if floor(thresh) < 0
    set(handles.slider6,'Value',0);
elseif floor(thresh) > thresh_max
    set(handles.slider6,'Value',thresh_max);
elseif isnan(thresh)
    set(handles.slider6,'Value',0);
else
    set(handles.slider6,'Value',thresh);
end
guidata(hObject,handles);
function edit7_Callback(hObject, ~, handles)
handles.pausetime = str2double(get(hObject,'String'));
guidata(hObject,handles);


%% Push Button
function pushbutton1_Callback(hObject, ~, handles)

set(handles.text12,'Visible','On');

set(handles.slider1,'Enable','Off');
set(handles.slider2,'Enable','Off');
set(handles.slider3,'Enable','Off');
set(handles.slider4,'Enable','Off');
set(handles.slider5,'Enable','Off');
set(handles.slider6,'Enable','Off');
set(handles.edit1,'Enable','Off');
set(handles.edit2,'Enable','Off');
set(handles.edit4,'Enable','Off');
set(handles.edit4,'Enable','Off');
set(handles.edit5,'Enable','Off');
set(handles.edit6,'Enable','Off');
set(handles.edit7,'Enable','Off');
set(handles.popupmenu1,'Enable','Off');
set(handles.popupmenu2,'Enable','Off');
set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
set(handles.save_tag,'Enable','Off');
set(handles.uitoggletool1,'Enable','Off');
set(handles.uitoggletool2,'Enable','Off');
set(handles.uitoggletool3,'Enable','Off');
set(handles.playtoggle1,'Enable','Off');
guidata(hObject,handles);
pause(0.0001);

handles.mask_toggle = 1.0;
if handles.mask_toggle == 1
    handles.mask = cell(1,handles.num_frames);
    for i=1:handles.num_frames
        % calculate specified binary mask for ratio image
        boundary_im = handles.frames1{i} - handles.thresh_val;
        boundary_im(boundary_im<0) = 0;
        
        binary_im = imfill(logical(boundary_im),'holes');
        if max(binary_im(:)) == min(binary_im(:))
            binary_im = ones(size(handles.frames1{frame}));
        end
        
        handles.mask{i} = binary_im;
    end
end
guidata(hObject,handles);
% display set threshold
set(handles.text8,'String',['Current Masking Threshold: ',num2str(handles.thresh_val,'%d')]);
% update image to generate mask on ratio
update_images(hObject,round(get(handles.slider5,'Value')));

set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
set(handles.slider3,'Enable','On');
set(handles.slider4,'Enable','On');
set(handles.slider5,'Enable','On');
set(handles.slider6,'Enable','On');
set(handles.edit1,'Enable','On');
set(handles.edit2,'Enable','On');
set(handles.edit4,'Enable','On');
set(handles.edit4,'Enable','On');
set(handles.edit5,'Enable','On');
set(handles.edit6,'Enable','On');
set(handles.edit7,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.popupmenu2,'Enable','On');
set(handles.pushbutton1,'Enable','On');
set(handles.pushbutton2,'Enable','On');
set(handles.save_tag,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.playtoggle1,'Enable','On');

set(handles.text12,'Visible','Off');

guidata(hObject,handles);
function pushbutton2_Callback(hObject, ~, handles)
handles.mask_toggle = 0.0;
guidata(hObject,handles);
% display threshold of 0
set(handles.text8,'String','Current Masking Threshold: 0');
% update image to remove mask on ratio
update_images(hObject,round(get(handles.slider5,'Value')));
guidata(hObject,handles);


%% Popup Menus
function popupmenu1_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupmenu2_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu1_Callback(hObject, ~, handles)
contents = cellstr(get(hObject,'String'));
cm = contents{get(hObject,'Value')};
if strcmp(cm,'Blue-Red') 
    colormap(handles.map1)
elseif strcmp(cm,'Rainbow+Mask')
    colormap(handles.map2)
else
    colormap(cm);
end
function popupmenu2_Callback(hObject, ~, handles)
contents = {'y','k','w','r','g','b','c','m'};
handles.line_color = contents{get(hObject,'Value')};
guidata(hObject,handles);

% update axes 1
frame = round(get(handles.slider5,'Value'));
handles.thresh_val = round(get(handles.slider6,'Value'));
% calculate boundary of frame based on threshold value
if handles.thresh_val > 0
    boundary_im = handles.frames1{frame} - handles.thresh_val;
    boundary_im(boundary_im<0) = 0;
    binary_im = imfill(logical(boundary_im),'holes');
    if max(binary_im(:)) == min(binary_im(:))
        binary_im = ones(size(handles.frames1{frame}));
    end
else
    binary_im = ones(size(handles.frames1{frame}));
end
bounds = bwboundaries(binary_im);
a = regionprops(logical(binary_im),'Area');
area = [a.Area];
[~,ind] = max(area);
bound = bounds{ind};
bx = bound(:,2);
by = bound(:,1);
% plot the boundary on the axis
set(handles.figure1,'CurrentAxes',handles.axes1);
guidata(hObject,handles);
hold(handles.axes1,'on');
if handles.border1 ~= 0
    delete(handles.border1)
end
handles.border1 = plot(handles.axes1,bx,by,handles.line_color,'LineWidth',1);

% update axes 2
% grab mask information
bx = handles.maskx{frame};
by = handles.masky{frame};
% plot the boundary on the axis
set(handles.figure1,'CurrentAxes',handles.axes2);
guidata(hObject,handles);
hold(handles.axes2,'on');
if handles.border2 ~= 0
    delete(handles.border2);
end
handles.border2 = plot(handles.axes2,bx,by,handles.line_color,'LineWidth',1);

% update handles
guidata(hObject,handles);


%% Menu Tag Callbacks
function file_tag_Callback(~,~,~)
function import_tag_Callback(hObject, ~, handles)
%toggle off all options until import is complete
if ~isempty(get(handles.axes1,'Children'))
    set(handles.slider1,'Enable','Off');
    set(handles.slider2,'Enable','Off');
    set(handles.slider3,'Enable','Off');
    set(handles.slider4,'Enable','Off');
    set(handles.slider5,'Enable','Off');
    set(handles.slider6,'Enable','Off');
    set(handles.edit1,'Enable','Off');
    set(handles.edit2,'Enable','Off');
    set(handles.edit3,'Enable','Off');
    set(handles.edit4,'Enable','Off');
    set(handles.edit5,'Enable','Off');
    set(handles.edit6,'Enable','Off');
    set(handles.edit7,'Enable','Off');
    set(handles.popupmenu1,'Enable','Off');
    set(handles.popupmenu2,'Enable','Off');
    set(handles.pushbutton1,'Enable','Off');
    set(handles.pushbutton2,'Enable','Off');
    set(handles.save_tag,'Enable','Off');
    set(handles.uitoggletool1,'Enable','Off');
    set(handles.uitoggletool2,'Enable','Off');
    set(handles.uitoggletool3,'Enable','Off');
    set(handles.playtoggle1,'Enable','Off');
end

% user selection of files and check if file exists
go = 1;
disp('Select a ".tif" file to open for selecting mask')
[file1, path1] = uigetfile('*.tif','Select a ".tif" file to open for selecting mask');
if file1 ~= 0
    disp('Select a ".tif" file of the ratio image')
    [file2, path2] = uigetfile('*.tif','Select a ".tif" file of the ratio image');
    if file2 == 0
        go = 0;
    end
else
    go = 0;
end
if go == 0 && ~isempty(get(handles.axes1,'Children'))
    set(handles.slider1,'Enable','On');
    set(handles.slider2,'Enable','On');
    set(handles.slider3,'Enable','On');
    set(handles.slider4,'Enable','On');
    set(handles.slider5,'Enable','On');
    set(handles.slider6,'Enable','On');
    set(handles.edit1,'Enable','On');
    set(handles.edit2,'Enable','On');
    set(handles.edit3,'Enable','On');
    set(handles.edit4,'Enable','On');
    set(handles.edit5,'Enable','On');
    set(handles.edit6,'Enable','On');
    set(handles.edit7,'Enable','On');
    set(handles.popupmenu1,'Enable','On');
    set(handles.popupmenu2,'Enable','On');
    set(handles.pushbutton1,'Enable','On');
    set(handles.pushbutton2,'Enable','On');
    set(handles.save_tag,'Enable','On');
    set(handles.uitoggletool1,'Enable','On');
    set(handles.uitoggletool2,'Enable','On');
    set(handles.uitoggletool3,'Enable','On');
    set(handles.playtoggle1,'Enable','On');
    return;
elseif go == 0 && isempty(get(handles.axes1,'Children'))
    return
end

% get image information
info1 = imfinfo(fullfile(path1,file1));
handles.width1 = info1(1).Width;
handles.height1 = info1(1).Height;
num_frames1 = length(info1);

info2 = imfinfo(fullfile(path2,file2));
handles.width2 = info2(1).Width;
handles.height2 = info2(1).Height;
num_frames2 = length(info2);

% check if images are compatible (equal size in three dimensions: x,y,t)
if handles.width1 ~= handles.width2
    errstr = fprintf('Width between images do not match.\nWidth 1 = %d\nWidth 2 = %d',...
        handles.width1,handles.width2);
    errordlg(errstr,'File Incompatibility Error');
    return
elseif handles.height1 ~= handles.height2
    errstr = fprintf('Height between images do not match.\nHeight 1 = %d\nHeight 2 = %d',...
        handles.height1,handles.height2);
    errordlg(errstr,'File Incompatibility Error');
    return
elseif num_frames1 ~= num_frames2
    errstr = fprintf('Number of frames between images do not match.\nNumber of Frames 1 = %d\nNumber of Frames 2 = %d',...
        num_frames1,num_frames2);
    errordlg(errstr,'File Incompatibility Error');
    return
end
handles.num_frames = num_frames1;
% set to display max frames in textbox
set(handles.text7,'String',['of ',num2str(num_frames1,'%d')]);

% initialize image data and load into handles.frames
handles.frames1 = cell(1,num_frames1);
handles.frames2 = cell(1,num_frames1);
handles.maskx = cell(1,num_frames1);
handles.masky = cell(1,num_frames1);
maxs1 = zeros(1,num_frames1);
maxs2 = zeros(1,num_frames1);
for i = 1:num_frames1
    handles.frames1{i} = imread(fullfile(path1,file1),i);
    maxs1(i) = max(max(handles.frames1{i}));
    handles.frames2{i} = imread(fullfile(path2,file2),i);
    maxs2(i) = max(max(handles.frames2{i}));
        
    % calculate boundary of ratio image (single loop as per MovThresh)
    binary_im = imfill(logical(handles.frames2{i}),'holes');
    if max(binary_im(:)) == min(binary_im(:))
        binary_im = ones(size(handles.frames1{frame}));
    end
    bounds = bwboundaries(binary_im);
    a = regionprops(logical(binary_im),'Area');
    area = [a.Area];
    [~,ind] = max(area);
    handles.maskx{i} = bounds{ind}(:,2);
    handles.masky{i} = bounds{ind}(:,1);
end

% set CLim max and min
handles.CLim_Max1 = max(max(maxs1));  % define the maximum value of image1
handles.CLim_Min1 = 0;                % define the minimum value of image1
handles.CLim_Max2 = max(max(maxs2));  % define the maximum value of image2
handles.CLim_Min2 = 0;                % define the minimum value of image2
    
% set max, min, and values of CLim Value sliders for both images
set(handles.slider1,'Max',handles.CLim_Max1);    % define slider's max value found in all frames
set(handles.slider1,'Min',handles.CLim_Min1 + 1.0);
set(handles.slider1,'Value',handles.CLim_Max1);  % set the slider's location to the maximum value
set(handles.slider2,'Max',handles.CLim_Max1 - 1.0);
set(handles.slider2,'Min',handles.CLim_Min1);
set(handles.slider2,'Value',handles.CLim_Min1);
set(handles.slider3,'Max',handles.CLim_Max2);    % define slider's max value found in all frames
set(handles.slider3,'Min',handles.CLim_Min2 + 1.0);
set(handles.slider3,'Value',handles.CLim_Max2);  % set the slider's location to the maximum value
set(handles.slider4,'Max',handles.CLim_Max2 - 1.0);
set(handles.slider4,'Min',handles.CLim_Min2);
set(handles.slider4,'Value',handles.CLim_Min2);

% set bounds and initialize frame slider
set(handles.slider5,'Min',1);
set(handles.slider5,'Max',num_frames1);
set(handles.slider5,'Value',1);
set(handles.slider5,'SliderStep',[1/num_frames1,1/num_frames1]);
% set bounds and initialize threshold slider
set(handles.slider6,'Min',handles.CLim_Min1);
set(handles.slider6,'Max',handles.CLim_Max1);
set(handles.slider6,'Value',handles.CLim_Min1);
set(handles.slider6,'SliderStep',[1/handles.CLim_Max1,1/handles.CLim_Max1]);

% initialize thresh/mask data
handles.thresh_val = get(handles.slider6,'Value');
handles.mask_toggle = 0;
set(handles.edit6,'String',num2str(handles.thresh_val));
% handles.border1 = 0;
% handles.border2 = 0;
guidata(hObject,handles);

% update image axes
update_images(hObject,round(get(handles.slider5,'Value')));
colormap('Gray');
handles.line_color = 'y';
% contents = cellstr(get(handles.popupmenu1,'String'));
% cm = contents{get(handles.popupmenu1,'Value')};
% colormap(cm);

% initialize ratio boundary plot
% grab mask information
bx = handles.maskx{1};
by = handles.masky{1};

% plot the boundary on the axis
set(handles.figure1,'CurrentAxes',handles.axes2);
guidata(hObject,handles);
hold(handles.axes2,'on');
if handles.border2 ~= 0
    delete(handles.border2);
end
handles.border2 = plot(handles.axes2,bx,by,'y','LineWidth',1);

% set initial max and min pixel values
set(handles.edit1, 'String', num2str(handles.CLim_Max1));
set(handles.edit2, 'String', num2str(handles.CLim_Min1));
set(handles.edit3, 'String', num2str(handles.CLim_Max2));
set(handles.edit4, 'String', num2str(handles.CLim_Min2));

% set to display max frames in textbox
% set(handles.text1,'String',['of ',num2str(num_frames1,'%d')]);

% add listener functions
handles.sl1 = addlistener(handles.slider1,'Value','PostSet',@(src,evnt)slider1(handles.figure1,src,evnt));
handles.sl2 = addlistener(handles.slider2,'Value','PostSet',@(src,evnt)slider2(handles.figure1,src,evnt));
handles.sl3 = addlistener(handles.slider3,'Value','PostSet',@(src,evnt)slider3(handles.figure1,src,evnt));
handles.sl4 = addlistener(handles.slider4,'Value','PostSet',@(src,evnt)slider4(handles.figure1,src,evnt));
handles.sl5 = addlistener(handles.slider5,'Value','PostSet',@(src,evnt)slider5(handles.figure1,src,evnt));
handles.sl6 = addlistener(handles.slider6,'Value','PostSet',@(src,evnt)slider6(handles.figure1,src,evnt));
handles.sl5_6 = addlistener(handles.slider5,'Value','PostSet',@(src,evnt)slider6(handles.figure1,src,evnt));
handles.sl5_mask = addlistener(handles.slider5,'Value','PostSet',@(src,evnt)ratio_boundary(handles.figure1,src,evnt));

% set mouse hover functionality
% set(handles.figure1,'WindowButtonMotionFcn',@(varargin) mousehover(handles.figure1,varargin));

% set current frames for both images to first frames
handles.cur1 = handles.frames1{1};
handles.cur2 = handles.frames2{1};

% enable all options for user - import finished
set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
set(handles.slider3,'Enable','On');
set(handles.slider4,'Enable','On');
set(handles.slider5,'Enable','On');
set(handles.slider6,'Enable','On');
set(handles.edit1,'Enable','On');
set(handles.edit2,'Enable','On');
set(handles.edit3,'Enable','On');
set(handles.edit4,'Enable','On');
set(handles.edit5,'Enable','On');
set(handles.edit6,'Enable','On');
set(handles.edit7,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.popupmenu2,'Enable','On');
set(handles.pushbutton1,'Enable','On');
set(handles.pushbutton2,'Enable','On');
set(handles.save_tag,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.playtoggle1,'Enable','On');

% update handles
guidata(hObject,handles);
function save_tag_Callback(hObject, ~, handles)
% disable all features while saving images
set(handles.slider1,'Enable','Off');
set(handles.slider2,'Enable','Off');
set(handles.slider3,'Enable','Off');
set(handles.slider4,'Enable','Off');
set(handles.slider5,'Enable','Off');
set(handles.slider6,'Enable','Off');
set(handles.edit1,'Enable','Off');
set(handles.edit2,'Enable','Off');
set(handles.edit3,'Enable','Off');
set(handles.edit4,'Enable','Off');
set(handles.edit5,'Enable','Off');
set(handles.edit6,'Enable','Off');
set(handles.edit7,'Enable','Off');
set(handles.popupmenu1,'Enable','Off');
set(handles.popupmenu2,'Enable','Off');
set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
set(handles.save_tag,'Enable','Off');
set(handles.uitoggletool1,'Enable','Off');
set(handles.uitoggletool2,'Enable','Off');
set(handles.uitoggletool3,'Enable','Off');
set(handles.playtoggle1,'Enable','Off');

% get number of frames
frames = get(handles.slider5,'Max');
% prompt user with save box
dlg_title = 'Save the Masked Ratio Image to a ".tif" file';
[file_name,path_name,filter] = uiputfile('*.tif',dlg_title,'masked_ratio');
if filter
    % store old directory path and change to path of save file specified
    old_dir = cd(path_name);
    for i=1:frames

        % mask the ratio image
        im = uint16(double(handles.frames2{i}).*double(handles.mask{i}));        

        % write the current frame to the save file
        try 
            imwrite(im,file_name,'tif','Compression','none','WriteMode','append');
        catch
            pause(1)
            fprintf('masked_ratio Iteration value: %i\n', i);
            imwrite(im,file_name,'tif','Compression','none','WriteMode','append');
        end
        
    end
    % switch background_subtractionGUI to old directory
    cd(old_dir);
end

% enable all options for user - save finished
set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
set(handles.slider3,'Enable','On');
set(handles.slider4,'Enable','On');
set(handles.slider5,'Enable','On');
set(handles.slider6,'Enable','On');
set(handles.edit1,'Enable','On');
set(handles.edit2,'Enable','On');
set(handles.edit3,'Enable','On');
set(handles.edit4,'Enable','On');
set(handles.edit5,'Enable','On');
set(handles.edit6,'Enable','On');
set(handles.edit7,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.popupmenu2,'Enable','On');
set(handles.pushbutton1,'Enable','On');
set(handles.pushbutton2,'Enable','On');
set(handles.save_tag,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.playtoggle1,'Enable','On');

% update handles
guidata(hObject,handles);

%% Play Toggle Callbacks
function playtoggle1_OnCallback(hObject, ~, handles)
set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
set(handles.edit6,'Enable','Off');
set(handles.slider6,'Enable','Off');
pause(0.0001)
guidata(hObject,handles);

pause_time = handles.pausetime/1000;
i = get(handles.slider5,'Value');
frames = get(handles.slider5,'Max');
while 1
    user_data = get(handles.playtoggle1,'UserData');
    if user_data.stop
        user_data.stop = 0;
        set(handles.playtoggle1,'UserData',user_data);
        return;
    end
    set(handles.slider5,'Value',i);
    i = i + 1;
    if i > frames
        i = 1;
    end
    pause(pause_time);
end

function playtoggle1_OffCallback(hObject, ~, handles)
user_data = get(hObject,'UserData');
user_data.stop = 1;
set(hObject,'UserData',user_data);
set(handles.pushbutton1,'Enable','On');
set(handles.pushbutton2,'Enable','On');
set(handles.edit6,'Enable','On');
set(handles.slider6,'Enable','On');
pause(0.0001)
guidata(hObject,handles);
