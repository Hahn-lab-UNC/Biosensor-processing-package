 function varargout = MoviePlayer(varargin)
% MOVIEPLAYER MATLAB code for MoviePlayer.fig
%      MOVIEPLAYER, by itself, creates a new MOVIEPLAYER or raises the existing
%      singleton*.
%
%      H = MOVIEPLAYER returns the handle to a new MOVIEPLAYER or the handle to
%      the existing singleton*.
%
%      MOVIEPLAYER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVIEPLAYER.M with the given input arguments.
%
%      MOVIEPLAYER('Property','Value',...) creates a new MOVIEPLAYER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MoviePlayer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MoviePlayer_OpeningFcn via varargin.
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

% Edit the above text to modify the response to help MoviePlayer

% Last Modified by GUIDE v2.5 18-Jun-2015 15:16:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MoviePlayer_OpeningFcn, ...
                   'gui_OutputFcn',  @MoviePlayer_OutputFcn, ...
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

% --- Executes just before MoviePlayer is made visible.
function MoviePlayer_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MoviePlayer (see VARARGIN)

handles.output = hObject;  % choose default command line output for MoviePlayer
handles.zoomed =0;
set(handles.figure1,'WindowKeyPressFcn',@(src,evnt)deletebox(handles.figure1,src,evnt));
%%
% Initially Disable Callbacks
set(handles.Play_Toggle,'Enable','off');
set(handles.Tools_Tag,'Enable','off');
set(handles.pause_time,'Enable','off');
set(handles.text8,'ForegroundColor',[.3,.3,.3]);

uD = get(handles.Play_Toggle,'UserData');
uD.stop = 0;
set(handles.Play_Toggle,'UserData',uD);

handles.ax_pos = get(handles.axes1,'Position');
%% Load additional colormaps.
load('maps.mat')
handles.map1 = map1;
handles.map2 = map2;

guidata(hObject, handles);  % Update handles structure

%%  Outputs from this function are returned to the command line.
function varargout = MoviePlayer_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Listeners (Slider 1,3,4)
function slider1(hObject,~,~)
handles = guidata(hObject);  % retrieve handles
frame = round(get(handles.slider1,'Value'));  % get frame number
handles.curImage = handles.frames{frame};  % define current frame in handle structure
if isempty(get(handles.axes1,'Children'))  % is the axis empty (i.e. have any 'Children')
    set(handles.figure1,'CurrentAxes',handles.axes1);  % set the current axes to 'handles.axes1'
    imagesc(handles.curImage,'Parent',handles.axes1);  % image the current frame in 'handles.axes1
    set(handles.axes1,'CLim',[handles.CLim_Min, handles.CLim_Max],'XTick',[],'YTick',[],'Box','on');  % set 'handles.axes1' properties
    set(handles.CLim_Max_Tag, 'String', num2str(handles.CLim_Max));  % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
    set(handles.CLim_Min_Tag, 'String', num2str(handles.CLim_Min));  % set the edit box 'CLim_Min_Tag' to the current CLim_val 'minimum'
    colorbar;
    axis image  % sets the aspect ratio so that the data units are the same in every direction and the plot box fits tightly around the data.
else  %  the handles.axes1 already contains an image
    imHandle = findobj(handles.axes1,'Type','image');  % find the 'image' handle in handles.axes1
    set(imHandle, 'CData', handles.curImage);  % update the image to the current frame
    %****update 'thumbnail'****
    if handles.zoomed == 1;
        Callback1(handles.position, hObject, handles)
    end
    %**************************
end
set(handles.text4,'String',['Frame = ' num2str(frame,'%d')]);  % set the text box to indicate the current frame number

function slider3(hObject,~,~)
handles = guidata(hObject);  % retrieve GUI data 'handles'
v = caxis;  % define coloraxis scaling
set(handles.figure1,'CurrentAxes',handles.axes1);  % define 'full image' as current axis
caxis([get(handles.slider3,'Value'),v(2)]);  % define the colorbar limits to specified minimum and maximum values
handles.CLim_Min = get(handles.slider3,'Value');
set(handles.CLim_Min_Tag,'String',num2str(get(handles.slider3,'Value')));  % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
guidata(hObject, handles);
if handles.zoomed ==1
    Callback1(handles.position, hObject, handles)
end

function slider4(hObject,~,~)
handles = guidata(hObject);  % retrieve GUI data 'handles'
v = caxis;  % define coloraxis scaling
set(handles.figure1,'CurrentAxes',handles.axes1);  % define 'full image' as current axis
caxis([v(1) get(handles.slider4,'Value')]);   % define the colorbar limits to specified minimum and maximum values
handles.CLim_Max = get(handles.slider4,'Value');
set(handles.CLim_Max_Tag,'String',num2str(get(handles.slider4,'Value')));  % set the edit box 'CLim_Max_Tag' to the current CLim_val 'minimum'
guidata(hObject, handles);
if handles.zoomed ==1
    Callback1(handles.position, hObject, handles)
end

function mousehover(hObject, varargin)
handles = guidata(hObject);  % retrieve GUI data 'handles'
point = get(handles.figure1,'CurrentPoint');
ax1pos = get(handles.axes1,'Position');
ax2pos = get(handles.axes2,'Position');
inaxes1 = point(1) >= ax1pos(1) && point(1) <= ax1pos(1) + ax1pos(3) &&...
    point(2) >= ax1pos(2) && point(2) <= ax1pos(2) + ax1pos(4);
if inaxes1
    pt = get(handles.axes1,'CurrentPoint');
    im = handles.curImage;
    if (ceil(pt(1,1)) <= 0 || ceil(pt(1,1)) > size(im,2))
        return;
    elseif (ceil(pt(1,2)) <= 0 || ceil(pt(1,2)) > size(im,1))
        return;
    end
    set(handles.text7,'String',sprintf('Pixel(%d,%d) = %.3f',ceil(pt(1,2)),ceil(pt(1,1)),im(ceil(pt(1,2)),ceil(pt(1,1)))));
    return;
end
inaxes2 = point(1) >= ax2pos(1) && point(1) <= ax2pos(1) + ax2pos(3) &&...
    point(2) >= ax2pos(2) && point(2) <= ax2pos(2) + ax2pos(4);
if inaxes2
   pt = get(handles.axes2,'CurrentPoint');
   im = handles.curImage;
   if (ceil(pt(1,1)) <= 0 || ceil(pt(1,1)) >= size(im,2))
        return;
   elseif (ceil(pt(1,2)) <= 0 || ceil(pt(1,2)) > size(im,1))
        return;
   end
   set(handles.text5,'String',sprintf('Pixel(%d,%d) = %.3f',ceil(pt(1,2)),ceil(pt(1,1)),im(ceil(pt(1,2)),ceil(pt(1,1)))));
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
handles.zoomed = 0;
guidata(hObject,handles);

%% Slider Callbacks
function slider1_Callback(~, ~, ~) %#ok<DEFNU>
function slider3_Callback(hObject, ~, handles) %#ok<DEFNU>
set(handles.slider4,'Min',get(hObject,'Value')+1);

function slider4_Callback(hObject, ~, handles) %#ok<DEFNU>
set(handles.slider3,'Max',get(hObject,'Value')-2.0);

%% Pop-up menu callbacks
function popupmenu1_Callback(hObject, ~, handles) %#ok<DEFNU>

contents = cellstr(get(hObject,'String'));
if (get(hObject,'Value') == 1)
    return;
end
a = contents{get(hObject,'Value')};
if strcmp(a,'map1') 
    colormap(handles.map1)
elseif strcmp(a,'map2')
    colormap(handles.map2)
else
colormap(contents{get(hObject,'Value')});
end

%% Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider3_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider4_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function popupmenu1_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function CLim_Min_Tag_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function CLim_Max_Tag_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function pause_time_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
handles.ptime = str2double(get(hObject,'String'));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles); 

%% Menu callbacks
function File_Tag_Callback(~, ~, ~)  %#ok<DEFNU> % currently does nothing

function Import_Tag_Callback(hObject, ~, handles) %#ok<DEFNU>
%****select file****
[file, path] = uigetfile('*.tif','Select a movie .tif file');
if file == 0
    return;
end
%****get image information****
set(handles.image_file,'String',fullfile('.',file));
info = imfinfo(fullfile(path,file));  % image information
handles.width = info(1).Width;  % define width of 'full image'
handles.height = info(1).Height;  % define height of 'full image'
num_frames = length(info);  % define number of frames
handles.frames = cell(1,num_frames);  % empty cells preallocated for speed
maxs = zeros(1,num_frames);  % empty matrix preallocated for speed
for i = 1:num_frames
   handles.frames{i} = imread(fullfile(path,file),i);
   maxs(i) = max(max(handles.frames{i}));
end

handles.CLim_Max = max(max(maxs));  % define the maximum CLim
handles.CLim_Min = 0;               % define the minimum CLim

set(handles.slider4,'Max',handles.CLim_Max);    % define slider's max value found in all frames
set(handles.slider4,'Value',handles.CLim_Max);  % set the slider's location to the maximum value

set(handles.slider1,'Min',1);
set(handles.slider1,'Max',num_frames);
set(handles.slider1,'Value',1);
set(handles.slider1,'SliderStep',[1/num_frames,1/num_frames]);
guidata(hObject,handles);

slider1(hObject);

set(handles.CLim_Max_Tag, 'String', num2str(handles.CLim_Max));
set(handles.CLim_Min_Tag, 'String', num2str(handles.CLim_Min));

handles.sl1 = addlistener(handles.slider1,'Value','PostSet',@(src,evnt)slider1(handles.figure1,src,evnt));
handles.sl2 = addlistener(handles.slider3,'Value','PostSet',@(src,evnt)slider3(handles.figure1,src,evnt));
handles.sl3 = addlistener(handles.slider4,'Value','PostSet',@(src,evnt)slider4(handles.figure1,src,evnt));

set(handles.figure1,'WindowButtonMotionFcn',@(varargin) mousehover(handles.figure1,varargin));

handles.curImage = handles.frames{1};

set(handles.Play_Toggle,'Enable','on');
set(handles.Tools_Tag,'Enable','on');
set(handles.pause_time,'Enable','on');
set(handles.text8,'ForegroundColor',[0,0,0]);
guidata(hObject,handles);

function Tools_Tag_Callback(~, ~, ~) %#ok<DEFNU>

function Zoom_Tag_Callback(hObject, ~, handles) %#ok<DEFNU>
if handles.zoomed == 1
    return;
end
handles.zoomed = 1;
initialPosition = [10 10 100 100];
handles.rect = imrect(handles.axes1,initialPosition);
fcn = makeConstrainToRectFcn('imrect',[1,handles.width],[1,handles.height]);
setPositionConstraintFcn(handles.rect,fcn); 
handles.rect.addNewPositionCallback( @(pos)Callback1(pos, hObject, handles));
guidata(hObject,handles);

function Transform_Tag_Callback(~, ~, handles) %#ok<DEFNU>
answer = inputdlg('Specify the matrix in matlab format','Transform matrix');
if isempty(answer)
    return;
end
matrix = eval(answer{1});
T = maketform('affine',matrix);
frame = handles.frames{round(get(handles.slider1,'Value'))};
image = imtransform(frame,T);
set(handles.figure1,'CurrentAxes',handles.axes1);
XL = get(handles.axes1,'XLim');
YL = get(handles.axes1,'YLim');
imagesc(image);
set(handles.axes1,'XLim',XL,'YLim',YL,'XTick',[],'YTick',[],'Box','on');
colorbar;
if ~handles.zoomed
    return;
end
set(handles.figure1,'CurrentAxes',handles.axes2);
XL = get(handles.axes2,'XLim');
YL = get(handles.axes2,'YLim');
imagesc(image);
handles.curImage = image;
set(handles.axes2,'XLim',XL,'YLim',YL,'XTick',[],'YTick',[],'Box','on');

function Export_Tag_Callback(~, ~, ~) %#ok<DEFNU> % currently does nothing

function Export_AVI_Tag_Callback(~, ~, handles) %#ok<DEFNU>
write_movie(handles,'.avi');

function MP4_Tag_Callback(~, ~, handles) %#ok<DEFNU>
write_movie(handles,'.mp4');

%% Text-Edit Callbacks
function pause_time_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.ptime = str2double(get(hObject,'String'));
guidata(hObject,handles);

%% helper functions
function write_movie(handles, extension)
[file,path] = uiputfile(['*' extension],'Make a movie file');
if file == 0
    return;
end
numFrames = length(handles.frames);
format_struct = struct('mp4','MPEG-4','avi','Motion JPEG AVI');
% mov(1:numFrames) = struct('cdata', [],...
%                         'colormap', []);  
% pause_time = eval(get(handles.pause_time,'String'))/5000;
fr = get(handles.slider1,'Value');

writerObj = VideoWriter(fullfile(path,file),format_struct.(extension(2:end)));

open(writerObj);
for i = 1:numFrames
    set(handles.slider1,'Value',i);
    slider1(handles.slider1,[],[]);
    frame = getframe(handles.axes1);
    writeVideo(writerObj,frame);
end
set(handles.slider1,'Value',fr);
close(writerObj);

%% Play Toggle Callbacks
function Play_Toggle_OnCallback(~, ~, handles) %#ok<DEFNU>
pause_time = handles.ptime/1000;
i = get(handles.slider1,'Value');
Mx = get(handles.slider1,'Max');
while 1
    while 1
        uD = get(handles.Play_Toggle,'UserData');
        if uD.stop
            uD.stop = 0;
            set(handles.Play_Toggle,'UserData',uD);
            return;
        end
        set(handles.slider1,'Value',i);
        slider1(handles.slider1,[],[]);
        i = i + 1;
        if i > Mx
            i = 1;
        end
        pause(pause_time);

    end
end

function Play_Toggle_OffCallback(hObject, ~, handles) %#ok<DEFNU>
userData = get(hObject,'UserData');
userData.stop = 1;
set(hObject,'UserData',userData);
guidata(hObject,handles);

%% CLim Callbacks
% CLim is a two-element vector [CLim_Min CLim_Min] specifying the CData
% value to map to the first color in the colormap (CLim_Min) and the CData
% value to map to the last color in the colormap (CLim_Max). Data values in
% between are linearly transformed from the second to the penultimate
% color.
function CLim_Max_Tag_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.CLim_Max = str2double(get(hObject,'String'));  % define in the structure 'handles' the maximum CLim value
set(handles.axes1,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current frame
set(handles.axes2,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current thumbnail
guidata(hObject,handles); % update handles structure

function CLim_Min_Tag_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.CLim_Min = str2double(get(hObject,'String'));  % define in the structure 'handles' the minimum CLim value
set(handles.axes1,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current frame
set(handles.axes2,'CLim',[handles.CLim_Min, handles.CLim_Max]);  % set the CLim of the current thumbnail
guidata(hObject,handles);  % update handles structure

%% Callback Function Everytime 'imrect' Changes
function Callback1(position, hObject, handles)
handles.position = position;  % define the current position of 'imrect' in the structure 'handles'
thumbnail = handles.curImage( round(position(2):position(2) + position(4)),round(position(1):position(1) + position(3)));  % define the thumbnail image
if isempty( get(handles.axes2,'Children'))  % is the axis empty (i.e. have any 'Children')
    imagesc(thumbnail,'Parent',handles.axes2);  % image the 'thumbnail' in 'handles.axes2
else   %  the handles.axes2 already contains 'thumbnail'
    imHandle = get(handles.axes2,'Children');  % define the handle of the 'Children'
    set(imHandle, 'CData', thumbnail);  % update the 'thumbnail' to the correct size
end
set(handles.figure1,'CurrentAxes',handles.axes2);  % set the current axes to 'handles.axes2'
set(handles.axes2,'CLim',get(handles.axes1,'CLim'),'XTick',[],'YTick',[],'Box','on');  % set 'handles.axes2' properties
axis image  % sets the aspect ratio so that the data units are the same in every direction and the plot box fits tightly around the data.
guidata(hObject,handles);   % update handles structure
