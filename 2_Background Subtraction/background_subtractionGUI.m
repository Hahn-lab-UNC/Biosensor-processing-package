 function varargout = background_subtractionGUI(varargin)
% BACKGROUND_SUBTRACTIONGUI MATLAB code for background_subtractionGUI.fig
%      BACKGROUND_SUBTRACTIONGUI, by itself, creates a new BACKGROUND_SUBTRACTIONGUI or raises the existing
%      singleton*.
%
%      H = BACKGROUND_SUBTRACTIONGUI returns the handle to a new BACKGROUND_SUBTRACTIONGUI or the handle to
%      the existing singleton*.
%
%      BACKGROUND_SUBTRACTIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BACKGROUND_SUBTRACTIONGUI.M with the given input arguments.
%
%      BACKGROUND_SUBTRACTIONGUI('Property','Value',...) creates a new BACKGROUND_SUBTRACTIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before background_subtractionGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to background_subtractionGUI_OpeningFcn via varargin.
%
%      This is designed to be a simple gui interface for viewing multipage
%      .tif files.  There are features to adjust colormap limits
%      dynamically, zoom into a box on the image, dynamically step through
%      frames, and visit a pixel's intensity value
%      author: Michael Guarino
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help background_subtractionGUI

% Last Modified by GUIDE v2.5 08-Aug-2016 17:50:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @background_subtractionGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @background_subtractionGUI_OutputFcn, ...
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

% --- Executes just before background_subtractionGUI is made visible.
function background_subtractionGUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to background_subtractionGUI (see VARARGIN)

% Choose default command line output for background_subtractionGUI
handles.output = hObject;

user_data = get(handles.playtoggle1,'UserData');
user_data.stop = 0;
set(handles.playtoggle1,'UserData',user_data);

handles.zoombox = 0;

% Load additional colormaps
load('maps.mat')
handles.map1 = map1;
handles.map2 = map2;

guidata(hObject, handles);  % Update handles structure

function varargout = background_subtractionGUI_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Helper Functions
function update_images(hObject,frame)
handles = guidata(hObject);
handles.curImage = handles.frames{frame};
if isempty(get(handles.axes1,'Children')) % is the axes empty (i.e. have any 'Children')
    set(handles.figure1,'CurrentAxes',handles.axes1);
    imagesc(handles.curImage,'Parent',handles.axes1); % image the current frame in 'handles.axes1'
    set(handles.axes1,'CLim',[handles.CLim_Min, handles.CLim_Max],'XTick',[],'YTick',[],'Box','on'); % set 'handles.axes1' properties
    set(handles.CLim_Max_Tag, 'String', num2str(handles.CLim_Max)); % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
    set(handles.CLim_Min_Tag, 'String', num2str(handles.CLim_Min)); % set the edit box 'CLim_Min_Tag' to the current CLim_val 'minimum'
    colorbar;
    colormap('Hot');
    axis image % sets the aspect ratio so that the data units are the same in every direction and the plot box fits tightly around the data
else
    imHandle = findobj(handles.axes1,'Type','image');
    set(imHandle,'CData',handles.curImage); % update the image to the current frame
    
    if handles.zoombox == 1;
        update_region(handles.position, hObject, handles)
    end
end
guidata(hObject,handles);

function update_region(position, hObject, handles)
handles.position = position; % define the current position of 'imrect' in the structure 'handles'
frame = round(get(handles.slider1,'Value'));
handles.curImage = handles.frames{frame};
region = handles.curImage(round(position(2):position(2)+position(4)),...
    round(position(1):position(1)+position(3)));  % define the region

if isempty(get(handles.axes2,'Children')) % is the axes empty (i.e. have any 'Children')
    imagesc(region,'Parent',handles.axes2); % image the region of the current frame 'handles.axes2'
else
    imHandle = get(handles.axes2,'Children');
    set(imHandle, 'CData', region); % update the region size
end

set(handles.figure1,'CurrentAxes',handles.axes2); % set the current axes to 'handles.axes2'
set(handles.axes2,'CLim',get(handles.axes1,'CLim'),'XTick',[],'YTick',[],'Box','on'); % set 'handles.axes2' properties
axis image % sets the aspect ratio so that the data units are the same in every direction and the plot box fits tightly around the data
guidata(hObject,handles);


%% Listener Functions
function slider1(hObject,~,~)
handles = guidata(hObject);
frame = round(get(handles.slider1,'Value'));
update_images(hObject,frame);
set(handles.edit2,'String',num2str(frame,'%d')); % set the edit box to indicate the current frame number
guidata(hObject, handles);
function slider2(hObject,~,~)
handles = guidata(hObject);
set(handles.slider3,'Max',get(handles.slider2,'Value')-1.0);
set(handles.figure1,'CurrentAxes',handles.axes1);
set(handles.axes1,'CLim',[get(handles.slider3,'Value'),get(handles.slider2,'Value')]);
handles.CLim_Max = get(handles.slider2,'Value');
set(handles.CLim_Max_Tag,'String',num2str(get(handles.slider2,'Value'))); % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
guidata(hObject, handles);
if handles.zoombox ==1
    update_region(handles.position, hObject, handles)
end
function slider3(hObject,~,~)
handles = guidata(hObject);
set(handles.slider2,'Min',get(handles.slider3,'Value')+1.0);
set(handles.figure1,'CurrentAxes',handles.axes1);
set(handles.axes1,'CLim',[get(handles.slider3,'Value'),get(handles.slider2,'Value')]);
handles.CLim_Min = get(handles.slider3,'Value');
set(handles.CLim_Min_Tag,'String',num2str(get(handles.slider3,'Value'))); % set the edit box 'CLim_Min_Tag1' to the current CLim_val 'minimum'
guidata(hObject, handles);
if handles.zoombox ==1
    update_region(handles.position, hObject, handles)
end

function mousehover(hObject, varargin)
handles = guidata(hObject);
point = get(handles.figure1,'CurrentPoint');
ax1pos = get(handles.axes1,'Position');
ax2pos = get(handles.axes2,'Position');
frame = round(get(handles.slider1,'Value'));
im = handles.frames{frame};
inaxes1 = point(1) >= ax1pos(1) && point(1) <= ax1pos(1) + ax1pos(3) && point(2) >= ax1pos(2) && point(2) <= ax1pos(2) + ax1pos(4);
inaxes2 = point(1) >= ax2pos(1) && point(1) <= ax2pos(1) + ax2pos(3) && point(2) >= ax2pos(2) && point(2) <= ax2pos(2) + ax2pos(4);
if inaxes1
    pt = get(handles.axes1,'CurrentPoint');
    if (ceil(pt(1,1)) <= 0 || ceil(pt(1,1)) > size(im,2))
        return;
    elseif (ceil(pt(1,2)) <= 0 || ceil(pt(1,2)) > size(im,1))
        return;
    end
    set(handles.text6,'String',sprintf('Coordinate: (%d,%d) = %.2f',...
        ceil(pt(1,2)),ceil(pt(1,1)),im(ceil(pt(1,2)),ceil(pt(1,1)))...
        ));
    return;
elseif inaxes2 && ~isempty(get(handles.axes2,'Children'))
    position = handles.position;
    pt = get(handles.axes2,'CurrentPoint');
    if (ceil(pt(1,1)) <= 0 || ceil(pt(1,1)) > size(im,2))
        return;
    elseif (ceil(pt(1,2)) <= 0 || ceil(pt(1,2)) > size(im,1))
        return;
    end
    set(handles.text6,'String',sprintf('Coordinate: (%d,%d) = %.2f',...
        ceil(pt(1,2)+position(2)),ceil(pt(1,1)+position(1)),...
        im(ceil(pt(1,2)+position(2)),ceil(pt(1,1)+position(1)))...
        ));
    return;
else
    set(handles.text6,'String',sprintf('Coordinate: (%d,%d) = %.2f',...
        0,0,0));
    return;
end

function deletebox(hObject,~,event)
handles = guidata(hObject);
if (strcmp(event.Key,'delete') ~= 1 && strcmp(event.Key,'backspace') ~= 1)
    return;
end
try %#ok<TRYNC>
    delete(handles.rect);
end
handles.zoombox = 0;
set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
guidata(hObject,handles);


%% CLim Edit Boxes
function CLim_Min_Tag_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function CLim_Max_Tag_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CLim_Max_Tag_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.CLim_Max = str2double(get(hObject,'String'));  % define in the structure 'handles' the maximum CLim value
set(handles.axes1,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current frame
set(handles.axes2,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current region frame
guidata(hObject,handles); % update handles structure
function CLim_Min_Tag_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.CLim_Min = str2double(get(hObject,'String'));  % define in the structure 'handles' the minimum CLim value
set(handles.axes1,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current frame
set(handles.axes2,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current region frame
guidata(hObject,handles);  % update handles structure


%% Sliders
function slider1_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider2_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider3_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider1_Callback(~, ~, ~) %#ok<DEFNU>
function slider2_Callback(hObject, ~, handles) %#ok<DEFNU>
if get(handles.slider2,'Value') == get(handles.slider3,'Value')+1
    set(handles.slider3,'Enable','Off');
else
    set(handles.slider3,'Enable','On');
end
guidata(hObject,handles);
function slider3_Callback(hObject, ~, handles) %#ok<DEFNU>
if get(handles.slider3,'Value') == get(handles.slider2,'Value')-1
    set(handles.slider2,'Enable','Off');
else
    set(handles.slider2,'Enable','On');
end
guidata(hObject,handles);


%% Pop-up Menu
function popupmenu1_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu1_Callback(hObject, ~, handles) %#ok<DEFNU>
contents = cellstr(get(hObject,'String'));
cm = contents{get(hObject,'Value')};
if strcmp(cm,'Blue-Red') 
    colormap(handles.map1)
elseif strcmp(cm,'Rainbow+Mask')
    colormap(handles.map2)
else
colormap(contents{get(hObject,'Value')});
end


%% Edit Boxes
function edit1_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
handles.pausetime = str2double(get(hObject,'String'));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles); 
function edit2_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.pausetime = str2double(get(hObject,'String'));
guidata(hObject,handles);
function edit2_Callback(hObject, ~, handles) %#ok<DEFNU>
frame = str2double(get(hObject,'String'));
frame_max = get(handles.slider1,'Max');
if floor(frame) < 1
    set(handles.slider1,'Value',1);
elseif floor(frame) > frame_max
    set(handles.slider1,'Value',frame_max);
elseif isnan(frame)
    set(handles.slider1,'Value',1);
else
    set(handles.slider1,'Value',frame);
end
guidata(hObject,handles);


%% Push Buttons
function pushbutton1_Callback(hObject, ~, handles) %#ok<DEFNU>
position = handles.position;
set(handles.text12,'String',sprintf('[%d %d %d %d]',...
    round(position(1)),round(position(2)),round(position(3)),round(position(4))));
guidata(hObject,handles);
function pushbutton2_Callback(hObject, ~, handles) %#ok<DEFNU>
position = handles.position;
set(handles.text13,'String',sprintf('[%d %d %d %d]',...
    round(position(1)),round(position(2)),round(position(3)),round(position(4))));
guidata(hObject,handles);


%% Menu Option Tags
function file_tag_Callback(~, ~, ~) %#ok<DEFNU>
function tools_tag_Callback(~, ~, ~) %#ok<DEFNU>

function import_tag_Callback(hObject, ~, handles) %#ok<DEFNU>

if ~isempty(get(handles.axes1,'Children'))
    set(handles.slider1,'Enable','Off');
    set(handles.slider2,'Enable','Off');
    set(handles.slider3,'Enable','Off');
    set(handles.edit1,'Enable','Off');
    set(handles.edit2,'Enable','Off');
    set(handles.popupmenu1,'Enable','Off');
    set(handles.CLim_Max_Tag,'Enable','Off');
    set(handles.CLim_Min_Tag,'Enable','Off');
    set(handles.save_tag,'Enable','Off');
    set(handles.zoom_tag,'Enable','Off');
    set(handles.uitoggletool1,'Enable','Off');
    set(handles.uitoggletool2,'Enable','Off');
    set(handles.uitoggletool3,'Enable','Off');
    set(handles.playtoggle1,'Enable','Off');
    set(handles.pushbutton1,'Enable','Off');
    set(handles.pushbutton2,'Enable','Off');
    handles.zoombox = 0;
end
try %#ok<TRYNC>
    delete(handles.rect);
end

disp('Select a ".tif" file to open')
[file, path] = uigetfile('*.tif','Select a ".tif" file to open');
if file == 0
    return;
end

% get image information
info = imfinfo(fullfile(path,file));
handles.width = info(1).Width;
handles.height = info(1).Height;
num_frames = length(info);

% set initial region of interest and background region
set(handles.text12,'String',sprintf('[1 1 %d %d]',...
    handles.width,handles.height));
set(handles.text13,'String',sprintf('[1 1 %d %d]',...
    handles.width,handles.height));

% initialize image data and load into handles.frames
handles.frames = cell(1,num_frames);
maxs = zeros(1,num_frames);
for i = 1:num_frames
   handles.frames{i} = imread(fullfile(path,file),i);
   maxs(i) = max(max(handles.frames{i}));
end

% set CLim max and min
handles.CLim_Max = max(max(maxs));  % define the maximum value
handles.CLim_Min = 0;               % define the minimum value

% turn enable 'On' for all necessary components
set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
set(handles.slider3,'Enable','On');
set(handles.edit1,'Enable','On');
set(handles.edit2,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.CLim_Max_Tag,'Enable','On');
set(handles.CLim_Min_Tag,'Enable','On');
set(handles.save_tag,'Enable','On');
set(handles.zoom_tag,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.playtoggle1,'Enable','On');
    
% set max, min, and values of CLim Value sliders
set(handles.slider2,'Max',handles.CLim_Max);    % define slider's max value found in all frames
set(handles.slider2,'Min',handles.CLim_Min + 1.0);
set(handles.slider2,'Value',handles.CLim_Max);  % set the slider's location to the maximum value
set(handles.slider3,'Max',handles.CLim_Max - 1.0);
set(handles.slider3,'Min',handles.CLim_Min);
set(handles.slider3,'Value',handles.CLim_Min);

% set bounds and initialize frame slider
set(handles.slider1,'Min',1);
set(handles.slider1,'Max',num_frames);
set(handles.slider1,'Value',1);
set(handles.slider1,'SliderStep',[1/num_frames,1/num_frames]);
guidata(hObject,handles);

update_images(hObject,round(get(handles.slider1,'Value')));

% set initial max and min pixel values
set(handles.CLim_Max_Tag, 'String', num2str(handles.CLim_Max));
set(handles.CLim_Min_Tag, 'String', num2str(handles.CLim_Min));

% set to initially display 'frame 1' in textbox
set(handles.text2,'String',['of ',num2str(num_frames,'%d')]);

% add listener functions
handles.sl1 = addlistener(handles.slider1,'Value','PostSet',@(src,evnt)slider1(handles.figure1,src,evnt));
handles.sl2 = addlistener(handles.slider2,'Value','PostSet',@(src,evnt)slider2(handles.figure1,src,evnt));
handles.sl3 = addlistener(handles.slider3,'Value','PostSet',@(src,evnt)slider3(handles.figure1,src,evnt));

% set mouse hover functionality
set(handles.figure1,'WindowButtonMotionFcn',@(varargin) mousehover(handles.figure1,varargin));

% set delete key functionality
set(handles.figure1,'WindowKeyPressFcn',@(src,evnt)deletebox(handles.figure1,src,evnt));

handles.curImage = handles.frames{1};

guidata(hObject,handles);

function zoom_tag_Callback(hObject, ~, handles) %#ok<DEFNU>
if handles.zoombox == 1
    return;
end
set(handles.pushbutton1,'Enable','On');
set(handles.pushbutton2,'Enable','On');
handles.zoombox = 1;
initial_position = [10 10 100 100];
handles.position = initial_position;
handles.rect = imrect(handles.axes1,initial_position);
fcn = makeConstrainToRectFcn('imrect',[1,handles.width],[1,handles.height]);
setPositionConstraintFcn(handles.rect,fcn); 
handles.rect.addNewPositionCallback(@(pos)update_region(pos,hObject,handles));
guidata(hObject,handles);

function save_tag_Callback(hObject, ~, handles) %#ok<DEFNU>
set(handles.slider1,'Enable','Off');
set(handles.slider2,'Enable','Off');
set(handles.slider3,'Enable','Off');
set(handles.edit1,'Enable','Off');
set(handles.edit2,'Enable','Off');
set(handles.popupmenu1,'Enable','Off');
set(handles.CLim_Max_Tag,'Enable','Off');
set(handles.CLim_Min_Tag,'Enable','Off');
set(handles.save_tag,'Enable','Off');
set(handles.zoom_tag,'Enable','Off');
set(handles.uitoggletool1,'Enable','Off');
set(handles.uitoggletool2,'Enable','Off');
set(handles.uitoggletool3,'Enable','Off');
set(handles.playtoggle1,'Enable','Off');

% get region of interest and background region
roi = str2num(get(handles.text12,'String')); %#ok<*ST2NM>
bgr = str2num(get(handles.text13,'String'));

% prompt user with save box
dlg_title = 'Save the Region Boxes to a ".txt" file';
[file_name,path_name,filter] = uiputfile('*.txt',dlg_title,'region_boxes');

if filter
    % store old directory path and change to path of save file specified
    old_dir = cd(path_name);
    
    fid = fopen(file_name,'wt');
    fprintf(fid,'background_box = [%d,%d,%d,%d]',bgr(1),bgr(2),bgr(3),bgr(4));
    fprintf(fid,'region_box = [%d,%d,%d,%d]',roi(1),roi(2),roi(3),roi(4));
    
    fclose(fid);
    
    % switch background_subtractionGUI to old directory
    cd(old_dir);
end

set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
set(handles.slider3,'Enable','On');
set(handles.edit1,'Enable','On');
set(handles.edit2,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.CLim_Max_Tag,'Enable','On');
set(handles.CLim_Min_Tag,'Enable','On');
set(handles.save_tag,'Enable','On');
set(handles.zoom_tag,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.playtoggle1,'Enable','On');

guidata(hObject,handles);


%% Play Toggle Callbacks
function playtoggle1_OnCallback(~, ~, handles) %#ok<DEFNU>
pause_time = handles.pausetime/1000;
i = get(handles.slider1,'Value');
frames = get(handles.slider1,'Max');
while 1
    user_data = get(handles.playtoggle1,'UserData');
    if user_data.stop
        user_data.stop = 0;
        set(handles.playtoggle1,'UserData',user_data);
        return;
    end
    set(handles.slider1,'Value',i);
    i = i + 1;
    if i > frames
        i = 1;
    end
    pause(pause_time);
end

function playtoggle1_OffCallback(hObject, ~, handles) %#ok<DEFNU>
user_data = get(hObject,'UserData');
user_data.stop = 1;
set(hObject,'UserData',user_data);
guidata(hObject,handles);
