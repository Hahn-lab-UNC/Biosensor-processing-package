function varargout = filterGUI(varargin)
% FILTERGUI MATLAB code for filterGUI.fig
%      FILTERGUI, by itself, creates a new FILTERGUI or raises the existing
%      singleton*.
%
%      H = FILTERGUI returns the handle to a new FILTERGUI or the handle to
%      the existing singleton*.
%
%      FILTERGUI('CALLBACK',hObject,~,handles,...) calls the local
%      function named CALLBACK in FILTERGUI.M with the given input arguments.
%
%      FILTERGUI('Property','Value',...) creates a new FILTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before filterGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to filterGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help filterGUI

% Last Modified by GUIDE v2.5 10-Aug-2016 16:03:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @filterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @filterGUI_OutputFcn, ...
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


% --- Executes just before filterGUI is made visible.
function filterGUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to filterGUI (see VARARGIN)

% Choose default command line output for filterGUI
handles.output = hObject;

user_data = get(handles.playtoggle1,'UserData');
user_data.stop = 0;
set(handles.playtoggle1,'UserData',user_data);

% Load additional colormaps
load('maps.mat')
handles.map1 = map1;
handles.map2 = map2;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = filterGUI_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Helper Function
function update_images(hObject,frame)
handles = guidata(hObject);
handles.cur_unfil = handles.frames_unfil{frame};
handles.cur_fil = handles.frames_fil{frame};
filt = get(handles.popupmenu2,'Value');
if isempty(get(handles.axes1,'Children')) % is the axes empty (i.e. have any 'Children')
    % sets unfiltered image
    set(handles.figure1,'CurrentAxes',handles.axes1);
    imagesc(handles.cur_unfil,'Parent',handles.axes1); % image the current frame in 'handles.axes1'
    set(handles.axes1,'CLim',[handles.CLim_Min, handles.CLim_Max],'XTick',[],'YTick',[],'Box','on'); % set 'handles.axes1' properties
    set(handles.CLim_Max_Tag, 'String', num2str(handles.CLim_Max)); % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
    set(handles.CLim_Min_Tag, 'String', num2str(handles.CLim_Min)); % set the edit box 'CLim_Min_Tag' to the current CLim_val 'minimum'
    colorbar;
    axis image % sets the aspect ratio so that the data units are the same in every direction and the plot box fits tightly around the data
else
    imHandle = findobj(handles.axes1,'Type','image');
    set(imHandle,'CData',handles.cur_unfil); % update the unfiltered image to the current frame
end
if filt ~= 1
    if isempty(get(handles.axes2,'Children'))
        % sets filtered image
        set(handles.figure1,'CurrentAxes',handles.axes2);
        imagesc(handles.cur_fil,'Parent',handles.axes2); % image the current frame in 'handles.axes1'
        set(handles.axes2,'CLim',[handles.CLim_Min, handles.CLim_Max],'XTick',[],'YTick',[],'Box','on'); % set 'handles.axes1' properties
        colorbar;
        axis image % sets the aspect ratio so that the data units are the same in every direction and the plot box fits tightly around the data
    else
        imHandle = findobj(handles.axes2,'Type','image');
        set(imHandle,'CData',handles.cur_fil); % update the filtered image to the current frame
    end
end
guidata(hObject,handles);


%% Listener Functions
function slider1(hObject,~,~)
handles = guidata(hObject);
frame = round(get(handles.slider1,'Value'));
update_images(hObject,frame);
set(handles.edit3,'String',num2str(frame,'%d')); % set the edit box to indicate the current frame number
guidata(hObject, handles);
function slider2(hObject,~,~)
handles = guidata(hObject);
set(handles.slider3,'Max',get(handles.slider2,'Value')-1.0);
set(handles.figure1,'CurrentAxes',handles.axes1);
set(handles.axes1,'CLim',[get(handles.slider3,'Value'),get(handles.slider2,'Value')]);
set(handles.axes2,'CLim',[get(handles.slider3,'Value'),get(handles.slider2,'Value')]);
handles.CLim_Max = get(handles.slider2,'Value');
set(handles.CLim_Max_Tag,'String',num2str(round(get(handles.slider2,'Value')))); % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
guidata(hObject, handles);
function slider3(hObject,~,~)
handles = guidata(hObject);
set(handles.slider2,'Min',get(handles.slider3,'Value')+1.0);
set(handles.figure1,'CurrentAxes',handles.axes1);
set(handles.axes1,'CLim',[get(handles.slider3,'Value'),get(handles.slider2,'Value')]);
set(handles.axes2,'CLim',[get(handles.slider3,'Value'),get(handles.slider2,'Value')]);
handles.CLim_Min = get(handles.slider3,'Value');
set(handles.CLim_Min_Tag,'String',num2str(round(get(handles.slider3,'Value')))); % set the edit box 'CLim_Min_Tag1' to the current CLim_val 'minimum'
guidata(hObject, handles);

function mousehover(hObject, varargin)
handles = guidata(hObject);
point = get(handles.figure1,'CurrentPoint');
ax1pos = get(handles.axes1,'Position');
ax2pos = get(handles.axes2,'Position');
frame = round(get(handles.slider1,'Value'));
filt = get(handles.popupmenu2,'Value');
im_unfil = handles.frames_unfil{frame};
im_fil = handles.frames_fil{frame};
inaxes1 = point(1) >= ax1pos(1) && point(1) <= ax1pos(1) + ax1pos(3) && point(2) >= ax1pos(2) && point(2) <= ax1pos(2) + ax1pos(4);
inaxes2 = point(1) >= ax2pos(1) && point(1) <= ax2pos(1) + ax2pos(3) && point(2) >= ax2pos(2) && point(2) <= ax2pos(2) + ax2pos(4);
if inaxes1 && filt == 1
    pt = get(handles.axes1,'CurrentPoint');
    if (ceil(pt(1,1)) <= 0 || ceil(pt(1,1)) > size(im_unfil,2))
        return;
    elseif (ceil(pt(1,2)) <= 0 || ceil(pt(1,2)) > size(im_unfil,1))
        return;
    end
    set(handles.text13,'String',sprintf('Coordinate: (%d,%d) =\nUnfiltered: %.2f\nFiltered:   %.2f',...
        ceil(pt(1,2)),ceil(pt(1,1)),...
        im_unfil(ceil(pt(1,2)),ceil(pt(1,1))),...
        0 ...
        ));
    return;
elseif inaxes1 && filt ~= 1
    pt = get(handles.axes1,'CurrentPoint');
    if (ceil(pt(1,1)) <= 0 || ceil(pt(1,1)) > size(im_unfil,2))
        return;
    elseif (ceil(pt(1,2)) <= 0 || ceil(pt(1,2)) > size(im_unfil,1))
        return;
    end
    set(handles.text13,'String',sprintf('Coordinate: (%d,%d) =\nUnfiltered: %.2f\nFiltered:   %.2f',...
        ceil(pt(1,2)),ceil(pt(1,1)),...
        im_unfil(ceil(pt(1,2)),ceil(pt(1,1))),...
        im_fil(ceil(pt(1,2)),ceil(pt(1,1)))...
        ));
    return;
elseif inaxes2 && filt ~= 1 && ~isempty(get(handles.axes2,'Children'))
    pt = get(handles.axes2,'CurrentPoint');
    if (ceil(pt(1,1)) <= 0 || ceil(pt(1,1)) > size(im_unfil,2))
        return;
    elseif (ceil(pt(1,2)) <= 0 || ceil(pt(1,2)) > size(im_unfil,1))
        return;
    end
    set(handles.text13,'String',sprintf('Coordinate: (%d,%d) =\nUnfiltered: %.2f\nFiltered:   %.2f',...
        ceil(pt(1,2)),ceil(pt(1,1)),...
        im_unfil(ceil(pt(1,2)),ceil(pt(1,1))),...
        im_fil(ceil(pt(1,2)),ceil(pt(1,1)))...
        ));
    return;
else
    set(handles.text13,'String',sprintf('Coordinate: (%d,%d) =\nUnfiltered: %.2f\nFiltered:   %.2f',...
        0,0,0,0));
    return;
end


%#ok<*DEFNU>
%% CLim Edit Boxes
function CLim_Max_Tag_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function CLim_Min_Tag_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CLim_Max_Tag_Callback(hObject, ~, handles)
handles.CLim_Max = str2double(get(hObject,'String'));  % define in the structure 'handles' the maximum CLim value
set(handles.axes1,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current frame
set(handles.axes2,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current region frame
guidata(hObject,handles); % update handles structure
function CLim_Min_Tag_Callback(hObject, ~, handles)
handles.CLim_Min = str2double(get(hObject,'String'));  % define in the structure 'handles' the minimum CLim value
set(handles.axes1,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current frame
set(handles.axes2,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current region frame
guidata(hObject,handles);  % update handles structure


%% Sliders
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

function slider1_Callback(~, ~, ~) 
function slider2_Callback(hObject, ~, handles)
if get(handles.slider2,'Value') == get(handles.slider3,'Value')+1
    set(handles.slider3,'Enable','Off');
else
    set(handles.slider3,'Enable','On');
end
guidata(hObject,handles);
function slider3_Callback(hObject, ~, handles)
if get(handles.slider3,'Value') == get(handles.slider2,'Value')-1
    set(handles.slider2,'Enable','Off');
else
    set(handles.slider2,'Enable','On');
end
guidata(hObject,handles);


%% Pop-up Menus
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
val = get(hObject,'Value');
set(handles.save_tag,'Enable','Off');
if val == 1
    set(handles.edit4,'Enable','Off');
    set(handles.edit5,'Enable','Off');
    set(handles.pushbutton1,'Enable','Off');
    cla(handles.axes2);
    set(handles.axes2,'XTick',[],'YTick',[],'Box','on');  % set 'handles.axes2' properties
elseif val == 5
    set(handles.edit4,'Enable','Off');
    set(handles.edit5,'Enable','On');
    set(handles.pushbutton1,'Enable','On');
else
    set(handles.edit4,'Enable','On');
    set(handles.edit5,'Enable','Off');
    set(handles.pushbutton1,'Enable','On');
end
guidata(hObject,handles);


%% Push Button
function pushbutton1_Callback(hObject, ~, handles)
frame = round(get(handles.slider1,'Value'));
frames = get(handles.slider1,'Max');

set(hObject,'Enable','Off');
set(handles.slider1,'Enable','Off');
set(handles.slider2,'Enable','Off');
set(handles.slider3,'Enable','Off');
set(handles.edit3,'Enable','Off');
set(handles.edit4,'Enable','Off');
set(handles.edit5,'Enable','Off');
set(handles.edit6,'Enable','Off');
set(handles.popupmenu1,'Enable','Off');
set(handles.popupmenu2,'Enable','Off');
set(handles.CLim_Max_Tag,'Enable','Off');
set(handles.CLim_Min_Tag,'Enable','Off');
set(handles.save_tag,'Enable','Off');
set(handles.uitoggletool1,'Enable','Off');
set(handles.uitoggletool2,'Enable','Off');
set(handles.uitoggletool3,'Enable','Off');
set(handles.playtoggle1,'Enable','Off');

filt = get(handles.popupmenu2,'Value');
switch filt
    case 2 % hybrid median filter
        for i = 1:frames
            handles.frames_fil{i} = hmf(handles.frames_unfil{i}, str2double(get(handles.edit4,'String')));
        end
        set(handles.edit4,'Enable','On');
    case 3 % median filter
        for i = 1:frames
            handles.frames_fil{i}= medfilt2(handles.frames_unfil{i}, [str2double(get(handles.edit4,'String')) str2double(get(handles.edit4,'String'))]);
        end
        set(handles.edit4,'Enable','On');
    case 4 % mean filter
        for i = 1:frames
            handles.frames_fil{i}= imboxfilt(handles.frames_unfil{i}, str2double(get(handles.edit4,'String')));
        end
        set(handles.edit4,'Enable','On');
    case 5 % gaussian smoothing
        for i = 1:frames
            handles.frames_fil{i} = imgaussfilt(handles.frames_unfil{i}, str2double(get(handles.edit5,'String')));
        end
        set(handles.edit5,'Enable','On');
    otherwise % reset
        for i = 1:frames
            handles.frames_fil{i} = zeros(handles.height,handles.width);
        end
end

guidata(hObject,handles);
update_images(hObject,frame)

set(hObject,'Enable','On');
set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
set(handles.slider3,'Enable','On');
set(handles.edit3,'Enable','On');
set(handles.edit6,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.popupmenu2,'Enable','On');
set(handles.CLim_Max_Tag,'Enable','On');
set(handles.CLim_Min_Tag,'Enable','On');
set(handles.save_tag,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.playtoggle1,'Enable','On');

guidata(hObject,handles);


%% Edit Boxes
function edit3_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit4_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit5_CreateFcn(hObject, ~, ~)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit6_CreateFcn(hObject, ~, ~)
handles.pausetime = str2double(get(hObject,'String'));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

function edit3_Callback(hObject, ~, handles)
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
function edit4_Callback(hObject, ~, handles)
size_n = round(str2double(get(hObject,'String')));
if mod(size_n,2) == 0 || size_n < 3 || isnan(size_n)
    set(handles.edit4,'String','3');
else
    set(handles.edit4,'String',num2str(size_n));
end
guidata(hObject,handles);
function edit5_Callback(hObject, ~, handles)
stdev = str2double(get(hObject,'String'));
if stdev <=0 || isnan(stdev)
    set(handles.edit5,'String','0.5');
else
    set(handles.edit5,'String',num2str(stdev));
end
guidata(hObject,handles);
function edit6_Callback(hObject, ~, handles)
handles.pausetime = str2double(get(hObject,'String'));
guidata(hObject,handles);


%% Menu Tags
function file_tag_Callback(~, ~, ~)

function import_tag_Callback(hObject, ~, handles)

if ~isempty(get(handles.axes1,'Children'))
    set(handles.slider1,'Enable','Off');
    set(handles.slider2,'Enable','Off');
    set(handles.slider3,'Enable','Off');
    set(handles.edit3,'Enable','Off');
    set(handles.edit4,'Enable','Off');
    set(handles.edit5,'Enable','Off');
    set(handles.edit6,'Enable','Off');
    set(handles.popupmenu1,'Enable','Off');
    set(handles.popupmenu2,'Enable','Off');
    set(handles.CLim_Max_Tag,'Enable','Off');
    set(handles.CLim_Min_Tag,'Enable','Off');
    set(handles.save_tag,'Enable','Off');
    set(handles.uitoggletool1,'Enable','Off');
    set(handles.uitoggletool2,'Enable','Off');
    set(handles.uitoggletool3,'Enable','Off');
    set(handles.playtoggle1,'Enable','Off');
end

[file, path] = uigetfile('*.tif','Select a ".tif" file to open');
if file == 0
    set(handles.slider1,'Enable','On');
    set(handles.slider2,'Enable','On');
    set(handles.slider3,'Enable','On');
    set(handles.edit3,'Enable','On');
    set(handles.edit6,'Enable','On');
    set(handles.popupmenu1,'Enable','On');
    set(handles.popupmenu2,'Enable','On');
    set(handles.CLim_Max_Tag,'Enable','On');
    set(handles.CLim_Min_Tag,'Enable','On');
    set(handles.uitoggletool1,'Enable','On');
    set(handles.uitoggletool2,'Enable','On');
    set(handles.uitoggletool3,'Enable','On');
    set(handles.playtoggle1,'Enable','On');
    return;
end

% get image information
info = imfinfo(fullfile(path,file));
handles.width = info(1).Width;
handles.height = info(1).Height;
num_frames = length(info);

% initialize image data and load into handles.frames
handles.frames_unfil = cell(1,num_frames);
handles.frames_fil = cell(1,num_frames);
maxs = zeros(1,num_frames);
for i = 1:num_frames
   handles.frames_unfil{i} = imread(fullfile(path,file),i);
   handles.frames_fil{i} = zeros(handles.height,handles.width);
   maxs(i) = max(max(handles.frames_unfil{i}));
end

% set CLim max and min
handles.CLim_Max = max(max(maxs));  % define the maximum value
handles.CLim_Min = 0;               % define the minimum value

% turn enable 'On' for all necessary components
set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
set(handles.slider3,'Enable','On');
set(handles.edit3,'Enable','On');
set(handles.edit6,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.popupmenu2,'Enable','On');
set(handles.CLim_Max_Tag,'Enable','On');
set(handles.CLim_Min_Tag,'Enable','On');
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
contents = cellstr(get(handles.popupmenu1,'String'));
cm = contents{get(handles.popupmenu1,'Value')};
colormap(cm);

% set initial max and min pixel values
set(handles.CLim_Max_Tag, 'String', num2str(handles.CLim_Max));
set(handles.CLim_Min_Tag, 'String', num2str(handles.CLim_Min));

% set to display max frames in textbox
set(handles.text1,'String',['of ',num2str(num_frames,'%d')]);

% add listener functions
handles.sl1 = addlistener(handles.slider1,'Value','PostSet',@(src,evnt)slider1(handles.figure1,src,evnt));
handles.sl2 = addlistener(handles.slider2,'Value','PostSet',@(src,evnt)slider2(handles.figure1,src,evnt));
handles.sl3 = addlistener(handles.slider3,'Value','PostSet',@(src,evnt)slider3(handles.figure1,src,evnt));

% set mouse hover functionality
set(handles.figure1,'WindowButtonMotionFcn',@(varargin) mousehover(handles.figure1,varargin));

handles.cur_unfil = handles.frames_unfil{1};
handles.cur_fil = handles.frames_fil{1};

guidata(hObject,handles);

function save_tag_Callback(hObject, ~, handles)

set(handles.slider1,'Enable','Off');
set(handles.slider2,'Enable','Off');
set(handles.slider3,'Enable','Off');
set(handles.edit3,'Enable','Off');
set(handles.edit6,'Enable','Off');
set(handles.popupmenu1,'Enable','Off');
set(handles.popupmenu2,'Enable','Off');
set(handles.CLim_Max_Tag,'Enable','Off');
set(handles.CLim_Min_Tag,'Enable','Off');
set(handles.save_tag,'Enable','Off');
set(handles.uitoggletool1,'Enable','Off');
set(handles.uitoggletool2,'Enable','Off');
set(handles.uitoggletool3,'Enable','Off');
set(handles.playtoggle1,'Enable','Off');

filt = get(handles.popupmenu2,'Value');
switch filt
    case 2 % hybrid median filter
        filter_name = 'hmf';
    case 3 % median filter
        filter_name = 'medianf';
    case 4 % mean filter
        filter_name = 'meanf';
    case 5 % gaussian smoothing
        filter_name = 'gauss_smooth';     
end

% prompt user with save box
dlg_title = 'Save the Filtered Image to a ".tif" file';
[file_name,path_name,filter] = uiputfile('*.tif',dlg_title,strcat('_',filter_name));

if filter
    % store old directory path and change to path of save file specified
    old_dir = cd(path_name);
    
    for i=1:frames

        switch filt
            case 1 % hybrid median filter
                im_fil = hmf(handles.cur_unfil, str2double(get(handles.edit4,'String')));
            case 2 % median filter
                im_fil = medfilt2(handles.cur_unfil, [str2double(get(handles.edit4,'String')) str2double(get(handles.edit4,'String'))]);
            case 3 % mean filter
                im_fil = imboxfil(handles.cur_unfil, str2double(get(handles.edit4,'String')));
            case 4 % gaussian smoothing
                im_fil = imgaussfilt(handles.cur_unfil, str2double(get(handles.edit5,'String')));   
        end

        % write the current frame to the save file
        imwrite(im_fil,file_name,'tif','Compression','none','WriteMode','append');

    end
    
    % switch background_subtractionGUI to old directory
    cd(old_dir);
end

set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
set(handles.slider3,'Enable','On');
set(handles.edit3,'Enable','On');
set(handles.edit6,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.popupmenu2,'Enable','On');
set(handles.CLim_Max_Tag,'Enable','On');
set(handles.CLim_Min_Tag,'Enable','On');
set(handles.save_tag,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.playtoggle1,'Enable','On');

guidata(hObject,handles);


%% Play Toggle Callbacks
function playtoggle1_OnCallback(~, ~, handles)
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

function playtoggle1_OffCallback(hObject, ~, handles)
user_data = get(hObject,'UserData');
user_data.stop = 1;
set(hObject,'UserData',user_data);
guidata(hObject,handles);
