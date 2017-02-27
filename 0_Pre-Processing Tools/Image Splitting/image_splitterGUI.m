function varargout = image_splitterGUI(varargin)
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
% IMAGE_SPLITTERGUI MATLAB code for image_splitterGUI.fig
%      IMAGE_SPLITTERGUI, by itself, creates a new IMAGE_SPLITTERGUI or raises the existing
%      singleton*.
%
%      H = IMAGE_SPLITTERGUI returns the handle to a new IMAGE_SPLITTERGUI or the handle to
%      the existing singleton*.
%
%      IMAGE_SPLITTERGUI('CALLBACK',hObject,~,handles,...) calls the local
%      function named CALLBACK in IMAGE_SPLITTERGUI.M with the given input arguments.
%
%      IMAGE_SPLITTERGUI('Property','Value',...) creates a new IMAGE_SPLITTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before image_splitterGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to image_splitterGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help image_splitterGUI

% Last Modified by GUIDE v2.5 20-Feb-2017 15:38:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @image_splitterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @image_splitterGUI_OutputFcn, ...
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


% --- Executes just before image_splitterGUI is made visible.
function image_splitterGUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to image_splitterGUI (see VARARGIN)

% Choose default command line output for image_splitterGUI
handles.output = hObject;

handles.image_list = {};
handles.working_dir = 0;
handles.save_dir = get(handles.edit2,'String');
handles.left_name = get(handles.edit3,'String');
handles.right_name = get(handles.edit4,'String');
handles.keep_left = 1;
handles.keep_right = 1;
handles.num_im = 0;
handles.selected_path = 'Select image...';

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = image_splitterGUI_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;


%% Helper Functions
function split_images(handles)
% switch to working directory
addpath(handles.working_dir);
old_dir = cd(handles.working_dir);

% check if save directory already exists
if ~exist(handles.save_dir, 'dir')
    mkdir(handles.save_dir);
else
    % construct a questdlg about save directory name
    task = questdlg('The directory name you provided already exists. Would you like to save inside this directory or create a new directory? Saving into this directory WILL overwrite files of the same name.', ...
        'WARNING!', ...
        'Save Into Specified Directory','Specify New Directory Name','Specify New Directory Name');
    if strcmp(task,'Specify New Directory Name')
        return
    end
end

% disable functionalities until splitting is done
set(handles.radiobutton1,'Enable','off');
set(handles.radiobutton2,'Enable','off');
set(handles.checkbox1,'Enable','off');
set(handles.checkbox2,'Enable','off');
set(handles.pushbutton1,'Enable','off');
set(handles.pushbutton2,'Enable','off');
set(handles.edit1,'Enable','off');
set(handles.edit2,'Enable','off');
set(handles.edit3,'Enable','off');
set(handles.edit4,'Enable','off');
set(handles.text14,'Visible','On');

% construct a questdlg about names of saved files
task = questdlg(sprintf(['Please select a formatting option for saved file names:\n\n', ...
                 'Option1:    left_filename.type    right_filename.type\n', ...
                 'Option2:    left_001.type         right_001.type\n', ...
                 'Option3:    left_.type            right_.type\n']), ...
    'WARNING!', ...
    'Option1','Option2','Option3','Option3');
if strcmp(task,'Option1')
    buildnameopt = 1;
elseif strcmp(task,'Option2')
    buildnameopt = 2;
else
    buildnameopt = 3;
end

tic
% read in image data
for file = 1:handles.num_im
    filename = fullfile(handles.image_list{file});
    
    imgInfo = imfinfo(filename);
    format = imgInfo(1).Format;
    width = imgInfo(1).Width;
    height = imgInfo(1).Height; 
    num_frames = length(imgInfo);
    
    % split each multiframe tif file into subsections for memory management
    % ---------------------------------------------------------------------
    loop = 3; % number of subsection of frames per iteration

    % set number of sub-sections to process sub-total number of frames
    if num_frames <= loop
        num_frames_sub = num_frames;
        loop = 1;
    else
        num_frames_sub = round(num_frames/loop);
    end
    % ---------------------------------------------------------------------
    for i = 1:loop
        % find current sub-section of frame indices
        if i == loop
            % indices of "remaining" subsection of frames in last remianing loop
            ind = (i-1)*(num_frames_sub) + 1:num_frames;
        else
            % indices of subsection of frames for current loop
            ind = (i-1)*(num_frames_sub) + 1:num_frames_sub*i;
        end

        % empty matrix preallocated
        raw_image = zeros(height, width, length(ind), 'uint16');

        % write data to memory
        for frame = ind
            raw_image(:,:,find(ind==frame,1,'first')) = imread(fullfile(handles.working_dir,filename), 'Index', frame, 'Info', imgInfo);
        end
    
        % split image in half along horizontal axis
        left = raw_image(:,1:round(width/2),:);
        right = raw_image(:,round(width/2)+1:width,:);
    
        % save image data into new '.tif' file
        for frame = 1:length(ind)
            [left_name,right_name] = build_file_name(file,handles.left_name,handles.right_name,filename,...
                                                     buildnameopt,handles);
            % save left image data
            if handles.keep_left == 1
                save_left_name = fullfile(handles.save_dir,[left_name,'.',format]);
                try 
                    imwrite(left(:,:,frame),save_left_name,'Compression','none','WriteMode','append')
                catch
                    pause(.5)
                    imwrite(left(:,:,frame),save_left_name,'Compression','none','WriteMode','append')
                end
            end
            % save right image data
            if handles.keep_right == 1
                save_right_name = fullfile(handles.save_dir,[right_name,'.',format]);
                try 
                    imwrite(right(:,:,frame),save_right_name,'Compression','none','WriteMode','append')
                catch
                    pause(.5)
                    imwrite(right(:,:,frame),save_right_name,'Compression','none','WriteMode','append')
                end
            end
        end
        
        % clear memory
        clear('left', 'right');
    end
end
% enable functionalities
set(handles.radiobutton1,'Enable','on');
set(handles.radiobutton2,'Enable','on');
set(handles.checkbox1,'Enable','on');
set(handles.checkbox2,'Enable','on');
set(handles.pushbutton1,'Enable','on');
set(handles.pushbutton2,'Enable','on');
set(handles.edit1,'Enable','on');
set(handles.edit2,'Enable','on');
set(handles.edit3,'Enable','on');
set(handles.edit4,'Enable','on');
set(handles.text14,'Visible','Off');
disp('Splitting Complete')
toc
cd(old_dir);
rmpath(handles.working_dir);

function [built_left,built_right] = build_file_name(idx,left_name,right_name,original,option,handles)
order = length(num2str(handles.num_im));
lead_zeros = order - length(num2str(idx));
if option == 1
    original = original(1:length(original)-4);
    built_left = [left_name,original];
    built_right = [right_name,original];
elseif option == 2
    built_name = '';
    for i = 1:lead_zeros
        built_name = [built_name,'0']; %#ok<AGROW>
    end
    built_left = [left_name,built_name,num2str(idx)];
    built_right = [right_name,built_name,num2str(idx)];
else
    built_left = left_name;
    built_right = right_name;
end


%#ok<*DEFNU>
%% Push Buttons
function pushbutton1_Callback(hObject, ~, handles)
split_images(handles);
guidata(hObject,handles);
function pushbutton2_Callback(hObject, ~, handles)
if get(handles.radiobutton1,'Value') == 1 % a single image
%     disp('Select image to split')
    [filename,pathname,filter] = uigetfile('*.tif','Select image to split');
    if filter ~= 0
        set(handles.edit1,'String',[pathname,filename]);
        handles.selected_path = [pathname,filename];
        set(handles.edit1,'FontAngle','normal');
        set(handles.pushbutton1,'Enable','on');
        handles.num_im = 1;
        handles.working_dir = pathname;
        handles.image_list = {filename};
        set(handles.text8,'String','Number of Images to Split:    1');
    else
        return
    end
else % all images in a specified directory
%     disp('Select directory with images to split')
    handles.working_dir = uigetdir;
    if ~(handles.working_dir==0)
        set(handles.edit1,'String',handles.working_dir);
        handles.selected_path = handles.working_dir;
        set(handles.edit1,'FontAngle','normal');
        set(handles.pushbutton1,'Enable','on');
    else
        return
    end
    % count number of images in directory and store in cell array
    if ~(handles.working_dir==0)
        srcFiles = dir(fullfile(handles.working_dir,'*.*'));
        handles.image_list = {};
        for Index = 1:length(srcFiles)
            filename = srcFiles(Index).name;
            [~, ~, extension] = fileparts(filename);
            extension = upper(extension);
            switch lower(extension)
                case {'.png','.bmp','.jpg','.tif','.avi'}
                    handles.image_list = [handles.image_list filename];
                otherwise
            end
        end
        handles.num_im = length(handles.image_list);
        str = sprintf('Number of Images to Split:    %d',handles.num_im);
        set(handles.text8,'String',str);
    end
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
function edit3_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit4_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_Callback(hObject, ~, handles)
set(hObject,'String',handles.selected_path);
guidata(hObject,handles);
function edit2_Callback(hObject, ~, handles)
if isempty(get(hObject,'String'))
    set(hObject,'String','split_images');
    handles.save_dir = 'split_images';
else
    handles.save_dir = get(hObject,'String');
end
guidata(hObject,handles);
function edit3_Callback(hObject, ~, handles)
if isempty(get(hObject,'String'))
    set(hObject,'String','left_');
    handles.left_name = 'left_';
else
    handles.left_name = get(hObject,'String');
end
guidata(hObject,handles);
function edit4_Callback(hObject, ~, handles)
if isempty(get(hObject,'String'))
    set(hObject,'String','right_');
    handles.right_name = 'right_';
else
    handles.right_name = get(hObject,'String');
end
guidata(hObject,handles);


%% Checkboxes
function checkbox1_Callback(hObject, ~, handles)
if get(hObject,'Value') == 1
    handles.keep_left = 1;
else
    handles.keep_left = 0;
end
if handles.num_im>0
    if get(hObject,'Value') == 0 && get(handles.checkbox2,'Value') == 0
        set(handles.pushbutton1,'Enable','off');
    else
        set(handles.pushbutton1,'Enable','on');
    end
end
guidata(hObject,handles);
function checkbox2_Callback(hObject, ~, handles)
if get(hObject,'Value') == 1
    handles.keep_right = 1;
else
    handles.keep_right = 0;
end
if handles.num_im>0
    if get(hObject,'Value') == 0 && get(handles.checkbox1,'Value') == 0
        set(handles.pushbutton1,'Enable','off');
    else
        set(handles.pushbutton1,'Enable','on');
    end
end
guidata(hObject,handles);


%% Radio Buttons
function radiobutton1_Callback(hObject, ~, handles)
set(handles.edit1,'String','Select Image...');
handles.selected_path = 'Select Image...';
set(handles.edit1,'FontAngle','italic');
set(handles.pushbutton2,'String','Search for Image')
set(handles.text8,'String','Number of Images to Split:    0');
handles.image_list = {};
handles.working_dir = 0;
handles.num_im = 0;
guidata(hObject,handles);
function radiobutton2_Callback(hObject, ~, handles)
set(handles.edit1,'String','Select Working Directory...');
handles.selected_path = 'Select Working Directory...';
set(handles.edit1,'FontAngle','italic');
set(handles.pushbutton2,'String','Search for Directory')
set(handles.text8,'String','Number of Images to Split:    0');
handles.image_list = {};
handles.working_dir = 0;
handles.num_im = 0;
guidata(hObject,handles);
