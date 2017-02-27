function varargout = freehand_thresh(varargin)
% Copyright (c) 2017 Paul LaFosse
%
% Created for use by the Klaus Hahn Lab at the University of
% North Carolina at Chapel Hill
%
% Email Contacts:
% Klaus Hahn: khahn@med.unc.edu
% Paul LaFosse: lafosse@ad.unc.edu
%
% This file is part of a comprehensive package, 2dfretimgproc.
% 2dfretimgproc is a free software package that can be modified/
% distributed under the terms described by the GNU General Public 
% License version 3.0. A copy of this license should have been 
% present within the 2dfretimgproc package. If not, please visit 
% the following link to learn more: <http://www.gnu.org/licenses/>.
%
% FREEHAND_THRESH MATLAB code for freehand_thresh.fig
%      FREEHAND_THRESH, by itself, creates a new FREEHAND_THRESH or raises the existing
%      singleton*.
%
%      H = FREEHAND_THRESH returns the handle to a new FREEHAND_THRESH or the handle to
%      the existing singleton*.
%
%      FREEHAND_THRESH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FREEHAND_THRESH.M with the given input arguments.
%
%      FREEHAND_THRESH('Property','Value',...) creates a new FREEHAND_THRESH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before freehand_thresh_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to freehand_thresh_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help freehand_thresh

% Last Modified by GUIDE v2.5 27-Feb-2017 17:33:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @freehand_thresh_OpeningFcn, ...
                   'gui_OutputFcn',  @freehand_thresh_OutputFcn, ...
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

% --- Executes just before freehand_thresh is made visible.
function freehand_thresh_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to freehand_thresh (see VARARGIN)
set(handles.figure1,'Visible','on');

% Choose default command line output for freehand_thresh
handles.output = 0;

% Load additional colormaps
load('maps.mat')
handles.map1 = map1;
handles.map2 = map2;

handles.saved_masks = 0;

handles.current_drawing = 0;

% Update handles structure
guidata(hObject, handles);

% wait for figure 1 to lose visibility
waitfor(handles.figure1,'Visible','off');

function varargout = freehand_thresh_OutputFcn(~, ~, handles)
varargout{1} = handles.output;
delete(handles.figure1);


 %#ok<*DEFNU>
%% Helper Functions
function update_images(hObject,frame)
handles = guidata(hObject);
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
frameidx = round(get(handles.slider3,'Value'));
update_images(hObject,frameidx);
set(handles.edit3,'String',num2str(handles.frames_of_interest(frameidx),'%d')); % set the edit box to indicate the current frame number
guidata(hObject, handles);


%% CLim Sliders
function slider1_CreateFcn(hObject,~,~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider2_CreateFcn(hObject,~,~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider1_Callback(~,~,~)
function slider2_Callback(~,~,~)


%% CLim Boxes
function edit1_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit2_CreateFcn(hObject,~,~)
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


%% Sliders
function slider3_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider3_Callback(~,~,~)


%% Edit Boxes
function edit3_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit4_CreateFcn(hObject, ~, handles)
handles.pausetime = str2double(get(hObject,'String'));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

function edit3_Callback(hObject, ~, handles)
frame = str2double(get(hObject,'String'));
frame_max = get(handles.slider3,'Max');
if floor(frame) < 1
    set(handles.slider3,'Value',1);
    set(handles.edit3,'String',num2str(1));
elseif floor(frame) > handles.frames_of_interest(frame_max)
    set(handles.slider3,'Value',frame_max);
    set(handles.edit3,'String',num2str(handles.frames_of_interest(frame_max)));
elseif isnan(frame)
    set(handles.slider3,'Value',1);
    set(handles.edit3,'String',num2str(1));
elseif ~ismember(frame,handles.frames_of_interest)
    set(handles.slider3,'Value',1);
    set(handles.edit3,'String',num2str(1));
else
    set(handles.slider3,'Value',frame);
    set(handles.edit3,'String',num2str(handles.frames_of_interest(frame)));
end
guidata(hObject,handles);
function edit4_Callback(hObject, ~, handles)
handles.pausetime = str2double(get(hObject,'String'));
guidata(hObject,handles);


%% Push Buttons
function pushbutton1_Callback(hObject, ~, handles)
% suspend other non-essential options
if ~isempty(get(handles.axes1,'Children'))
    set(handles.slider3,'Enable','Off');
    set(handles.edit3,'Enable','Off');
    set(handles.pushbutton1,'Enable','Off');
    set(handles.pushbutton2,'Enable','On');
    set(handles.listbox1,'Enable','Off');
    set(handles.uitoggletool1,'Enable','Off');
    set(handles.uitoggletool2,'Enable','Off');
    set(handles.uitoggletool3,'Enable','Off');
    set(handles.moviepush1,'Enable','Off');
end

% collect current frame index
frameidx = round(get(handles.slider3,'Value'));

% default task
task = 'Create New Mask';
% if mask already exists for current frame, prompt user
if handles.drawmask{frameidx} ~= 0
    % construct a questdlg
    task = questdlg('A mask has already been drawn for this frame. Would you like to create a new mask for this frame?', ...
        'WARNING!', ...
        'Create New Mask','Keep Previous Mask','Keep Previous Mask');
end

% handle task
if strcmp(task,'Create New Mask')
    % turn on "Save Mask" button
    set(handles.pushbutton2,'Enable','On');

    % create drawable region
    handles.current_drawing = imfreehand();

    % block draggable item (imfreehand) from moving
    api = iptgetapi(handles.current_drawing);
    fcn = makeConstrainToRectFcn('imfreehand',get(gca,'XLim'),get(gca,'YLim'));
    api.setPositionConstraintFcn(fcn);

    % wait for mask to be drawn
    guidata(hObject,handles);
    uiwait;

    % save mask into memory
    if isvalid(handles.current_drawing)
        handles.drawmask{frameidx} = handles.current_drawing;
        set(handles.current_drawing,'visible','off')
        
        % update reamining time frame list to listbox if needed
        if ismember(frameidx,handles.frameidx_list)
            idx2remove = handles.frameidx_list==frameidx;
            handles.frame_list(:,idx2remove) = [];
            handles.frameidx_list(:,idx2remove) = [];
            set(handles.listbox1,'Value',1);
            set(handles.listbox1,'String',handles.frame_list);
        end

        % clear imfreehand object from current axes
%         delete(handles.current_drawing);
    else
        msgbox('A mask was drawn, then deleted by user. To draw a mask, please re-select the option.');
    end
    handles.current_drawing = 0;
end

% enable all options for user - drawing finished
if handles.num_frames > 1
    set(handles.slider3,'Enable','On');
end
set(handles.edit3,'Enable','On');
set(handles.pushbutton1,'Enable','On');
set(handles.pushbutton2,'Enable','Off');
set(handles.listbox1,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.moviepush1,'Enable','On');

% check if all masks have been drawn
if isempty(handles.frameidx_list)
    set(handles.pushbutton3,'Enable','On');
    set(handles.save_tag,'Enable','On');
end

guidata(hObject,handles);
function pushbutton2_Callback(hObject, ~, handles)
if handles.current_drawing == 0
    msgbox('No mask drawn. Please draw a mask for the current frame.');
else
    uiresume;
end
guidata(hObject,handles);
function pushbutton3_Callback(hObject, eventdata, handles)
save_tag_Callback(hObject, eventdata, handles);
handles.saved_masks = 1;
guidata(hObject,handles);


%% List Boxes
function listbox1_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function listbox1_Callback(hObject, ~, handles)
listidx = get(handles.listbox1,'Value');
frameidx = handles.frameidx_list(listidx);
frame_of_interest = (handles.frames_of_interest(frameidx));
update_images(hObject,frameidx);
set(handles.slider3,'Value',frameidx);
set(handles.edit3,'String',num2str(frame_of_interest,'%d')); % set the edit box to indicate the current frame number
guidata(hObject, handles);


%% Popup Menus
function popupmenu1_CreateFcn(hObject, ~, ~)
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


%% Menu Tag Callbacks
function file_tag_Callback(~,~,~)
function import_tag_Callback(hObject, ~, handles)
%toggle off all options until import is complete
if ~isempty(get(handles.axes1,'Children'))
    set(handles.slider1,'Enable','Off');
    set(handles.slider2,'Enable','Off');
    set(handles.slider3,'Enable','Off');
    set(handles.edit1,'Enable','Off');
    set(handles.edit2,'Enable','Off');
    set(handles.edit3,'Enable','Off');
    set(handles.edit4,'Enable','Off');
    set(handles.pushbutton1,'Enable','Off');
    set(handles.popupmenu1,'Enable','Off');
    set(handles.listbox1,'Enable','Off');
    set(handles.uitoggletool1,'Enable','Off');
    set(handles.uitoggletool2,'Enable','Off');
    set(handles.uitoggletool3,'Enable','Off');
    set(handles.moviepush1,'Enable','Off');
end

% user selection of files and check if file exists
go = 1;
disp('Select a ".tif" file to open for drawing mask')
[file1, path1] = uigetfile('*.tif','Select a ".tif" file to open for drawing mask');
if file1 == 0
    go = 0;
end
if go == 0 && ~isempty(get(handles.axes1,'Children'))
    set(handles.slider1,'Enable','On');
    set(handles.slider2,'Enable','On');
    if handles.num_frames > 1
        set(handles.slider3,'Enable','On');
    end
    set(handles.edit1,'Enable','On');
    set(handles.edit2,'Enable','On');
    set(handles.edit3,'Enable','On');
    set(handles.edit4,'Enable','On');
    set(handles.pushbutton1,'Enable','On');
    set(handles.popupmenu1,'Enable','On');
    set(handles.listbox1,'Enable','On');
    set(handles.uitoggletool1,'Enable','On');
    set(handles.uitoggletool2,'Enable','On');
    set(handles.uitoggletool3,'Enable','On');
    set(handles.moviepush1,'Enable','On');
    return;
elseif go == 0 && isempty(get(handles.axes1,'Children'))
    return
end

% get image information
info1 = imfinfo(fullfile(path1,file1));
handles.width1 = info1(1).Width;
handles.height1 = info1(1).Height;
total_frames = length(info1);

input_str = '';
prompt = sprintf(['Select Time Frames to Draw Masks For:\n\n',...
                      'The selected image has %d time frames\n',...
                      'Enter space-separated numbers indicating specific time frames below (eg: 1 3 5)\n',...
                      '*For a range of numbers, use x:y\n',...
                      '*For a sparsed range of numbers, use x:i:y, where i is the increment value\n\n',...
                      'If you want to draw a mask for every time frame in the file\n'...
                      'leave the text field below empty\n'],total_frames);
while 1
    input_str = inputdlg(prompt,'',1,{input_str});
    if isempty(input_str) && ~isempty(get(handles.axes1,'Children'))
        set(handles.slider1,'Enable','On');
        set(handles.slider2,'Enable','On');
        if handles.num_frames > 1
            set(handles.slider3,'Enable','On');
        end
        set(handles.edit1,'Enable','On');
        set(handles.edit2,'Enable','On');
        set(handles.edit3,'Enable','On');
        set(handles.edit4,'Enable','On');
        set(handles.pushbutton1,'Enable','On');
        set(handles.popupmenu1,'Enable','On');
        set(handles.listbox1,'Enable','On');
        set(handles.uitoggletool1,'Enable','On');
        set(handles.uitoggletool2,'Enable','On');
        set(handles.uitoggletool3,'Enable','On');
        set(handles.moviepush1,'Enable','On');
        return;
    elseif isempty(input_str) && isempty(get(handles.axes1,'Children'))
        return
    else
        if isempty(input_str{1})
            h = msgbox('Please enter at least one frame index');
            waitfor(h)
            input_str = '';
        else
            input_vector = sort(str2num(input_str{:})); %#ok<ST2NM>
            if length(input_vector) > total_frames
                h = msgbox('Length of input exceeds number of frames in image');
                waitfor(h)
            elseif input_vector(length(input_vector)) > total_frames || input_vector(1) < 1
                msg = sprintf('Some input number(s) are outside the range of frames in the image: (1,%d)',total_frames);
                h = msgbox(msg);
                waitfor(h)
            elseif length(unique(input_vector)) < length(input_vector)
                h = msgbox('Some input number(s) are repeated');
                waitfor(h)
            else
                num_frames = length(input_vector);
                break
            end
        end
    end
end

handles.num_frames = num_frames;
handles.frames_of_interest = input_vector;
handles.frame_list = cell(1,num_frames);
handles.frameidx_list = 1:num_frames;

handles.num_frames = num_frames;
% set to display max frames in textbox
set(handles.text6,'String',['of ',num2str(total_frames,'%d')]);

% initialize image data and load into handles.frames
handles.frames1 = cell(1,num_frames);
maxs = zeros(1,num_frames);
handles.drawmask = cell(1,num_frames);


set(handles.text1,'String',['Total Frames to Mask: ',num2str(num_frames)]);
for i = 1:num_frames
    handles.frames1{i} = imread(fullfile(path1,file1),input_vector(i));
    maxs(i) = max(max(handles.frames1{i}));
    
    handles.drawmask{i} = 0;
    
    handles.frame_list{i} = num2str(input_vector(i));
end

% add time frame list to listbox
set(handles.listbox1,'String',handles.frame_list);

% set CLim max and min
handles.CLim_Max1 = max(max(maxs));  % define the maximum value of image1
handles.CLim_Min1 = 0;                % define the minimum value of image1
    
% set max, min, and values of CLim Value sliders for both images
set(handles.slider1,'Max',handles.CLim_Max1);    % define slider's max value found in all frames
set(handles.slider1,'Min',handles.CLim_Min1 + 1.0);
set(handles.slider1,'Value',handles.CLim_Max1);  % set the slider's location to the maximum value
set(handles.slider2,'Max',handles.CLim_Max1 - 1.0);
set(handles.slider2,'Min',handles.CLim_Min1);
set(handles.slider2,'Value',handles.CLim_Min1);

% set bounds and initialize frame slider
set(handles.slider3,'Min',1);
set(handles.slider3,'Max',num_frames);
set(handles.slider3,'Value',1);
set(handles.slider3,'SliderStep',[1/num_frames,1/num_frames]);

% update image axes
guidata(hObject,handles);
update_images(hObject,round(get(handles.slider3,'Value')));
colormap('Gray');

% set initial max and min CLim values
set(handles.edit1,'String',num2str(handles.CLim_Max1));
set(handles.edit2,'String',num2str(handles.CLim_Min1));

% set initial frame number
set(handles.edit3,'String',num2str(input_vector(get(handles.slider3,'Value'))));

% add listener functions
handles.sl1 = addlistener(handles.slider1,'Value','PostSet',@(src,evnt)slider1(handles.figure1,src,evnt));
handles.sl2 = addlistener(handles.slider2,'Value','PostSet',@(src,evnt)slider2(handles.figure1,src,evnt));
handles.sl3 = addlistener(handles.slider3,'Value','PostSet',@(src,evnt)slider3(handles.figure1,src,evnt));

% set mouse hover functionality
% set(handles.figure1,'WindowButtonMotionFcn',@(varargin) mousehover(handles.figure1,varargin));

% set current frame to first frame
handles.cur1 = handles.frames1{1};

% enable all options for user - import finished
set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
if num_frames > 1
    set(handles.slider3,'Enable','On');
end
set(handles.edit1,'Enable','On');
set(handles.edit2,'Enable','On');
set(handles.edit3,'Enable','On');
set(handles.edit4,'Enable','On');
set(handles.pushbutton1,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.listbox1,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.moviepush1,'Enable','On');

% update handles
guidata(hObject,handles);
function save_tag_Callback(hObject, ~, handles)
%toggle off all options until save is complete
if ~isempty(get(handles.axes1,'Children'))
    set(handles.slider1,'Enable','Off');
    set(handles.slider2,'Enable','Off');
    set(handles.slider3,'Enable','Off');
    set(handles.edit1,'Enable','Off');
    set(handles.edit2,'Enable','Off');
    set(handles.edit3,'Enable','Off');
    set(handles.edit4,'Enable','Off');
    set(handles.pushbutton1,'Enable','Off');
    set(handles.popupmenu1,'Enable','Off');
    set(handles.listbox1,'Enable','Off');
    set(handles.uitoggletool1,'Enable','Off');
    set(handles.uitoggletool2,'Enable','Off');
    set(handles.uitoggletool3,'Enable','Off');
    set(handles.moviepush1,'Enable','Off');
end

% save drawn masks into tiff file

% prompt user with save box
dlg_title = 'Save the New Registered Image to a ".tif" file';
[file_name,path_name,filter] = uiputfile('*.tif',dlg_title,'maskfor_');

if filter
    % store old directory path and change to path of save file specified
    old_dir = cd(path_name);
    for i=1:handles.num_frames

        % mask the ratio image
        im = uint16(createMask(handles.drawmask{i}));

        % write the current frame to the save file
        try 
            imwrite(im,file_name,'tif','Compression','none','WriteMode','append');
        catch
            pause(1)
            fprintf('maskfor_ Iteration value: %i\n', i);
            imwrite(im,file_name,'tif','Compression','none','WriteMode','append');
        end
        
    end
    % switch background_subtractionGUI to old directory
    cd(old_dir);
end

handles.saved_masks = 1;
msgbox('Masks saved. Close GUI window to continue.');

% enable all options for user - save finished
set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
if handles.num_frames > 1
    set(handles.slider3,'Enable','On');
end
set(handles.edit1,'Enable','On');
set(handles.edit2,'Enable','On');
set(handles.edit3,'Enable','On');
set(handles.edit4,'Enable','On');
set(handles.pushbutton1,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.listbox1,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.moviepush1,'Enable','On');

% update handles
guidata(hObject,handles);


%% Figure Close w/o Continuing Processing
function figure1_CloseRequestFcn(hObject, ~, handles)
if handles.saved_masks == 0
    % construct a questdlg
    task = questdlg('The masks have not been saved. Closing now will delete currently drawn masks and quit processing. Are you sure you want to close?', ...
        'WARNING!', ...
        'Close','Continue Drawing Masks','Continue Drawing Masks');
    if strcmp(task,'Close')
        handles.output = 0;
        guidata(hObject,handles);
        set(handles.figure1,'Visible','off');
    end
else
    handles.output = handles.frames_of_interest;
    guidata(hObject,handles);
    set(handles.figure1,'Visible','off');
end


%% Movie Button Callback
function moviepush1_ClickedCallback(~, ~, handles)
set(handles.moviepush1,'Enable','Off')
pause_time = handles.pausetime/1000;
frames = get(handles.slider3,'Max');
for f = 1:frames
    set(handles.slider3,'Value',f);
    pause(pause_time);
end
set(handles.slider3,'Value',1);
set(handles.moviepush1,'Enable','On')
