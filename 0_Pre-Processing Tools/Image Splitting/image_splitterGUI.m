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

% Last Modified by GUIDE v2.5 05-May-2017 16:22:57

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

handles.name_tl = get(handles.edit_tl,'String');
handles.name_tr = get(handles.edit_tr,'String');
handles.name_bl = get(handles.edit_bl,'String');
handles.name_br = get(handles.edit_br,'String');
handles.keep_tl = 1;
handles.keep_tr = 1;
handles.keep_bl = 0;
handles.keep_br = 0;

handles.num_im = 0;
handles.selected_path = 'Select image...';

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = image_splitterGUI_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;


%% Helper Functions
function split_images(handles,hObject)
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
set(handles.button_h,'Enable','off');
set(handles.button_v,'Enable','off');
set(handles.button_hv,'Enable','off');
set(handles.checkbox1,'Enable','off');
set(handles.checkbox2,'Enable','off');
set(handles.checkbox3,'Enable','off');
set(handles.checkbox4,'Enable','off');
set(handles.pushbutton1,'Enable','off');
set(handles.pushbutton2,'Enable','off');
set(handles.edit1,'Enable','off');
set(handles.edit2,'Enable','off');
set(handles.edit_tl,'Enable','off');
set(handles.edit_tr,'Enable','off');
set(handles.edit_bl,'Enable','off');
set(handles.edit_br,'Enable','off');
set(handles.text16,'Visible','on');

% call specific splitting function based on orientation selection
if get(handles.button_h,'Value') == 1
    split_h(handles);
elseif get(handles.button_v,'Value') == 1
    split_v(handles);
elseif get(handles.button_hv,'Value') == 1
    split_hv(handles);
end

% enable functionalities
set(handles.radiobutton1,'Enable','on');
set(handles.radiobutton2,'Enable','on');
set(handles.button_h,'Enable','on');
set(handles.button_v,'Enable','on');
set(handles.button_hv,'Enable','on');
set(handles.checkbox1,'Enable','on');
set(handles.checkbox2,'Enable','on');
set(handles.checkbox3,'Enable','on');
set(handles.checkbox4,'Enable','on');
set(handles.pushbutton1,'Enable','on');
set(handles.pushbutton2,'Enable','on');
set(handles.edit1,'Enable','on');
set(handles.edit2,'Enable','on');
set(handles.edit_tl,'Enable','on');
set(handles.edit_tr,'Enable','on');
set(handles.edit_bl,'Enable','on');
set(handles.edit_br,'Enable','on');
set(handles.text16,'Visible','off');
guidata(hObject,handles);
cd(old_dir);
rmpath(handles.working_dir);

% helper functions for horizontal splitting
function split_h(handles)
if handles.num_im > 1
    % construct a questdlg about names of saved files
    task = questdlg(sprintf(['Please select a formatting option for saved file names:\n\n', ...
                     'Option1:    left_filename.type    right_filename.type\n', ...
                     'Option2:    left_001.type         right_001.type\n', ...
                     'Option3:    left_.type            right_.type\n']), ...
        'WARNING!', ...
        'Option1','Option2','Option3','Option1');
    if strcmp(task,'Option1')
        buildnameopt = 1;
    elseif strcmp(task,'Option2')
        buildnameopt = 2;
    else
        buildnameopt = 3;
    end
else
    % construct a questdlg about names of saved files
    task = questdlg(sprintf(['Please select a formatting option for saved file names:\n\n', ...
                     'Option1:    left_filename.type    right_filename.type\n', ...
                     'Option2:    left_001.type         right_001.type\n']), ...
        'WARNING!', ...
        'Option1','Option2','Option1');
    if strcmp(task,'Option1')
        buildnameopt = 1;
    elseif strcmp(task,'Option2')
        buildnameopt = 2;
    end
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
            [left_name,right_name] = build_filename_h(file,handles.name_tl,handles.name_tr,filename,...
                                                     buildnameopt,handles);
            % save left image data
            if handles.keep_tl == 1
                save_left_name = fullfile(handles.save_dir,[left_name,'.',format]);
                try 
                    imwrite(left(:,:,frame),save_left_name,'Compression','none','WriteMode','append')
                catch
                    pause(.5)
                    imwrite(left(:,:,frame),save_left_name,'Compression','none','WriteMode','append')
                end
            end
            % save right image data
            if handles.keep_tr == 1
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
disp('Horizontal Splitting Complete')
toc
function [built_left,built_right] = build_filename_h(idx,left_name,right_name,original,option,handles)
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

% helper functions for vertical splitting
function split_v(handles)
if handles.num_im > 1
    % construct a questdlg about names of saved files
    task = questdlg(sprintf(['Please select a formatting option for saved file names:\n\n', ...
                     'Option1:    top_filename.type    bottom_filename.type\n', ...
                     'Option2:    top_001.type         bottom_001.type\n', ...
                     'Option3:    top_.type            bottom_.type\n']), ...
        'WARNING!', ...
        'Option1','Option2','Option3','Option1');
    if strcmp(task,'Option1')
        buildnameopt = 1;
    elseif strcmp(task,'Option2')
        buildnameopt = 2;
    else
        buildnameopt = 3;
    end
else
    % construct a questdlg about names of saved files
    task = questdlg(sprintf(['Please select a formatting option for saved file names:\n\n', ...
                     'Option1:    top_filename.type    bottom_filename.type\n', ...
                     'Option2:    top_001.type         bottom_001.type\n']), ...
        'WARNING!', ...
        'Option1','Option2','Option1');
    if strcmp(task,'Option1')
        buildnameopt = 1;
    elseif strcmp(task,'Option2')
        buildnameopt = 2;
    end
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
    
        % split image in half along vertical axis
        top = raw_image(1:round(height/2),:,:);
        bottom = raw_image(round(height/2)+1:height,:,:);
    
        % save image data into new '.tif' file
        for frame = 1:length(ind)
            [top_name,bottom_name] = build_filename_h(file,handles.name_tl,handles.name_bl,filename,...
                                                     buildnameopt,handles);
            % save left image data
            if handles.keep_tl == 1
                save_top_name = fullfile(handles.save_dir,[top_name,'.',format]);
                try 
                    imwrite(top(:,:,frame),save_top_name,'Compression','none','WriteMode','append')
                catch
                    pause(.5)
                    imwrite(top(:,:,frame),save_top_name,'Compression','none','WriteMode','append')
                end
            end
            % save right image data
            if handles.keep_bl == 1
                save_bottom_name = fullfile(handles.save_dir,[bottom_name,'.',format]);
                try 
                    imwrite(bottom(:,:,frame),save_bottom_name,'Compression','none','WriteMode','append')
                catch
                    pause(.5)
                    imwrite(bottom(:,:,frame),save_bottom_name,'Compression','none','WriteMode','append')
                end
            end
        end
        
        % clear memory
        clear('top', 'bottom');
    end
end
disp('Vertical Splitting Complete')
toc
function [built_top,built_bottom] = build_filename_v(idx,top_name,bottom_name,original,option,handles)
order = length(num2str(handles.num_im));
lead_zeros = order - length(num2str(idx));
if option == 1
    original = original(1:length(original)-4);
    built_top = [top_name,original];
    built_bottom = [bottom_name,original];
elseif option == 2
    built_name = '';
    for i = 1:lead_zeros
        built_name = [built_name,'0']; %#ok<AGROW>
    end
    built_top = [top_name,built_name,num2str(idx)];
    built_bottom = [bottom_name,built_name,num2str(idx)];
else
    built_top = top_name;
    built_bottom = bottom_name;
end

% helper functions for 4-way splitting
function split_hv(handles)
if handles.num_im > 1
    % construct a questdlg about names of saved files
    task = questdlg(sprintf(['Please select a formatting option for saved file names:\n\n', ...
                     'Option1:    topleft_filename.type    topright_filename.type\n', ...
                     'Option2:    topleft_001.type         topright_001.type\n', ...
                     'Option3:    topleft_.type            topright_.type\n']), ...
        'WARNING!', ...
        'Option1','Option2','Option3','Option1');
    if strcmp(task,'Option1')
        buildnameopt = 1;
    elseif strcmp(task,'Option2')
        buildnameopt = 2;
    else
        buildnameopt = 3;
    end
else
    % construct a questdlg about names of saved files
    task = questdlg(sprintf(['Please select a formatting option for saved file names:\n\n', ...
                     'Option1:    topleft_filename.type    topright_filename.type\n', ...
                     'Option2:    topleft_001.type         topright_001.type\n']), ...
        'WARNING!', ...
        'Option1','Option2','Option1');
    if strcmp(task,'Option1')
        buildnameopt = 1;
    elseif strcmp(task,'Option2')
        buildnameopt = 2;
    end
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
        tl = raw_image(1:round(height/2),1:round(width/2),:);
        tr = raw_image(1:round(height/2),round(width/2)+1:width,:);
        bl = raw_image(round(height/2)+1:height,1:round(width/2),:);
        br = raw_image(round(height/2)+1:height,round(width/2)+1:width,:);
    
        % save image data into new '.tif' file
        for frame = 1:length(ind)
            [tl_name,tr_name,bl_name,br_name] = build_filename_hv(file,handles.name_tl,handles.name_tr,...
                                                                       handles.name_bl,handles.name_br,...
                                                                       filename,buildnameopt,handles);
            % save top left image data
            if handles.keep_tl == 1
                save_tl_name = fullfile(handles.save_dir,[tl_name,'.',format]);
                try 
                    imwrite(tl(:,:,frame),save_tl_name,'Compression','none','WriteMode','append')
                catch
                    pause(.5)
                    imwrite(tl(:,:,frame),save_tl_name,'Compression','none','WriteMode','append')
                end
            end
            % save top right image data
            if handles.keep_tr == 1
                save_tr_name = fullfile(handles.save_dir,[tr_name,'.',format]);
                try 
                    imwrite(tr(:,:,frame),save_tr_name,'Compression','none','WriteMode','append')
                catch
                    pause(.5)
                    imwrite(tr(:,:,frame),save_tr_name,'Compression','none','WriteMode','append')
                end
            end
            % save bottom left image data
            if handles.keep_bl == 1
                save_bl_name = fullfile(handles.save_dir,[bl_name,'.',format]);
                try 
                    imwrite(bl(:,:,frame),save_bl_name,'Compression','none','WriteMode','append')
                catch
                    pause(.5)
                    imwrite(bl(:,:,frame),save_bl_name,'Compression','none','WriteMode','append')
                end
            end
            % save bottom right image data
            if handles.keep_br == 1
                save_br_name = fullfile(handles.save_dir,[br_name,'.',format]);
                try 
                    imwrite(br(:,:,frame),save_br_name,'Compression','none','WriteMode','append')
                catch
                    pause(.5)
                    imwrite(br(:,:,frame),save_br_name,'Compression','none','WriteMode','append')
                end
            end
        end
        % clear memory
        clear('tl', 'tr', 'bl', 'br');
    end
end
disp('4-Way Splitting Complete')
toc
function [built_tl,built_tr,built_bl,built_br] = build_filename_hv(idx,tl_name,tr_name,...
                                                                       bl_name,br_name,...
                                                                       original,option,handles)
order = length(num2str(handles.num_im));
lead_zeros = order - length(num2str(idx));
if option == 1
    original = original(1:length(original)-4);
    built_tl = [tl_name,original];
    built_tr = [tr_name,original];
    built_bl = [bl_name,original];
    built_br = [br_name,original];
elseif option == 2
    built_name = '';
    for i = 1:lead_zeros
        built_name = [built_name,'0']; %#ok<AGROW>
    end
    built_tl = [tl_name,built_name,num2str(idx)];
    built_tr = [tr_name,built_name,num2str(idx)];
    built_bl = [bl_name,built_name,num2str(idx)];
    built_br = [br_name,built_name,num2str(idx)];
else
    built_tl = tl_name;
    built_tr = tr_name;
    built_bl = bl_name;
    built_br = br_name;
end



%#ok<*DEFNU>
%% Push Buttons
function pushbutton1_Callback(hObject, ~, handles)
split_images(handles,hObject);
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
function edit_tl_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_tr_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_bl_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_br_CreateFcn(hObject, ~, ~)
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
function edit_tl_Callback(hObject, ~, handles)
if isempty(get(hObject,'String'))
    if get(handles.button_h,'Value') == 1
        set(hObject,'String','left_');
        handles.name_tl = 'left_';
    elseif get(handles.button_v,'Value') == 1
        set(hObject,'String','top_');
        handles.name_tl = 'top_';
    elseif get(handles.button_hv,'Value') == 1
        set(hObject,'String','topleft_');
        handles.name_tl = 'topleft_';
    end
else
    handles.name_tl = get(hObject,'String');
end
guidata(hObject,handles);
function edit_tr_Callback(hObject, ~, handles)
if isempty(get(hObject,'String'))
    if get(handles.button_h,'Value') == 1
        set(hObject,'String','right_');
        handles.name_tr = 'right_';
    elseif get(handles.button_hv,'Value') == 1
        set(hObject,'String','topright_');
        handles.name_tr = 'topright_';
    end
else
    handles.name_tr = get(hObject,'String');
end
guidata(hObject,handles);
function edit_bl_Callback(hObject, ~, handles)
if isempty(get(hObject,'String'))
    if get(handles.button_v,'Value') == 1
        set(hObject,'String','bottom_');
        handles.name_bl = 'bottom_';
    elseif get(handles.button_hv,'Value') == 1
        set(hObject,'String','bottomleft_');
        handles.name_bl = 'bottomleft_';
    end
else
    handles.name_bl = get(hObject,'String');
end
guidata(hObject,handles);
function edit_br_Callback(hObject, ~, handles)
if isempty(get(hObject,'String'))
    set(hObject,'String','bottomright_');
    handles.name_br = 'bottomright_';
else
    handles.name_br = get(hObject,'String');
end
guidata(hObject,handles);


%% Checkboxes
function checkbox1_Callback(hObject, ~, handles)
if get(hObject,'Value') == 1
    handles.keep_tl = 1;
else
    handles.keep_tl = 0;
end
if handles.num_im>0
    if get(handles.button_h,'Value') == 1
        if get(hObject,'Value') == 0 && get(handles.checkbox2,'Value') == 0
            set(handles.pushbutton1,'Enable','off');
        else
            set(handles.pushbutton1,'Enable','on');
        end
    elseif get(handles.button_v,'Value') == 1
        if get(hObject,'Value') == 0 && get(handles.checkbox3,'Value') == 0
            set(handles.pushbutton1,'Enable','off');
        else
            set(handles.pushbutton1,'Enable','on');
        end
    elseif get(handles.button_hv,'Value') == 1
        if get(hObject,'Value') == 0 && get(handles.checkbox2,'Value') == 0 ...
                && get(handles.checkbox3,'Value') == 0 && get(handles.checkbox4,'Value') == 0
            set(handles.pushbutton1,'Enable','off');
        else
            set(handles.pushbutton1,'Enable','on');
        end
    end
end
guidata(hObject,handles);
function checkbox2_Callback(hObject, ~, handles)
if get(hObject,'Value') == 1
    handles.keep_tr = 1;
else
    handles.keep_tr = 0;
end
if handles.num_im>0
    if get(handles.button_h,'Value') == 1
        if get(hObject,'Value') == 0 && get(handles.checkbox1,'Value') == 0
            set(handles.pushbutton1,'Enable','off');
        else
            set(handles.pushbutton1,'Enable','on');
        end
    elseif get(handles.button_hv,'Value') == 1
        if get(hObject,'Value') == 0 && get(handles.checkbox1,'Value') == 0 ...
                && get(handles.checkbox3,'Value') == 0 && get(handles.checkbox4,'Value') == 0
            set(handles.pushbutton1,'Enable','off');
        else
            set(handles.pushbutton1,'Enable','on');
        end
    end
end
guidata(hObject,handles);
function checkbox3_Callback(hObject, ~, handles)
if get(hObject,'Value') == 1
    handles.keep_bl = 1;
else
    handles.keep_bl = 0;
end
if handles.num_im>0
    if get(handles.button_v,'Value') == 1
        if get(hObject,'Value') == 0 && get(handles.checkbox1,'Value') == 0
            set(handles.pushbutton1,'Enable','off');
        else
            set(handles.pushbutton1,'Enable','on');
        end
    elseif get(handles.button_hv,'Value') == 1
        if get(hObject,'Value') == 0 && get(handles.checkbox1,'Value') == 0 ...
                && get(handles.checkbox2,'Value') == 0 && get(handles.checkbox4,'Value') == 0
            set(handles.pushbutton1,'Enable','off');
        else
            set(handles.pushbutton1,'Enable','on');
        end
    end
end
guidata(hObject,handles);
function checkbox4_Callback(hObject, ~, handles)
if get(hObject,'Value') == 1
    handles.keep_br = 1;
else
    handles.keep_br = 0;
end
if handles.num_im>0
    if get(hObject,'Value') == 0 && get(handles.checkbox1,'Value') == 0 ...
            && get(handles.checkbox2,'Value') == 0 && get(handles.checkbox3,'Value') == 0
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
function button_h_Callback(hObject, ~, handles)
% turn off vertical options
set(handles.text_bl,'Visible','off');
set(handles.text_br,'Visible','off');
set(handles.checkbox3,'Visible','off');
set(handles.checkbox4,'Visible','off');
set(handles.text14,'Visible','off');
set(handles.text15,'Visible','off');
set(handles.edit_bl,'Visible','off');
set(handles.edit_br,'Visible','off');
% turn on horinzontal options
set(handles.text_tl,'Visible','on');
set(handles.text_tr,'Visible','on');
set(handles.checkbox1,'Visible','on');
set(handles.checkbox1,'Value',1);
set(handles.checkbox2,'Visible','on');
set(handles.checkbox2,'Value',1);
set(handles.text12,'Visible','on');
set(handles.text13,'Visible','on');
set(handles.edit_tl,'Visible','on');
set(handles.edit_tr,'Visible','on');
if handles.num_im>0
    set(handles.pushbutton1,'Enable','on');
end
% update horizontal options to reflect horizontal splitting syntax
set(handles.text_tl,'String','Save Left Half of Images');
set(handles.text_tr,'String','Save Right Half of Images');
set(handles.text12,'String','Name of Left Half of Images:');
set(handles.text13,'String','Name of Right Half of Images:');
set(handles.edit_tl,'String','left_');
set(handles.edit_tr,'String','right_');
% update GUI handles for horizontal orientation
handles.name_tl = get(handles.edit_tl,'String');
handles.name_tr = get(handles.edit_tr,'String');
handles.name_bl = get(handles.edit_bl,'String');
handles.name_br = get(handles.edit_br,'String');
handles.keep_tl = 1;
handles.keep_tr = 1;
handles.keep_bl = 0;
handles.keep_br = 0;
guidata(hObject,handles);
function button_v_Callback(hObject, ~, handles)
% turn off horizontal options
set(handles.text_tr,'Visible','off');
set(handles.text_br,'Visible','off');
set(handles.checkbox2,'Visible','off');
set(handles.checkbox4,'Visible','off');
set(handles.text13,'Visible','off');
set(handles.text15,'Visible','off');
set(handles.edit_tr,'Visible','off');
set(handles.edit_br,'Visible','off');
% turn on vertical options
set(handles.text_tl,'Visible','on');
set(handles.text_bl,'Visible','on');
set(handles.checkbox1,'Visible','on');
set(handles.checkbox1,'Value',1);
set(handles.checkbox3,'Visible','on');
set(handles.checkbox3,'Value',1);
set(handles.text12,'Visible','on');
set(handles.text14,'Visible','on');
set(handles.edit_tl,'Visible','on');
set(handles.edit_bl,'Visible','on');
if handles.num_im>0
    set(handles.pushbutton1,'Enable','on');
end
% update vertical options to reflect vertical splitting syntax
set(handles.text_tl,'String','Save Upper Half of Images');
set(handles.text_bl,'String','Save Lower Half of Images');
set(handles.text12,'String','Name of Upper Half of Images:');
set(handles.text14,'String','Name of Lower Half of Images:');
set(handles.edit_tl,'String','top_');
set(handles.edit_bl,'String','bottom_');
% update GUI handles for vertical orientation
handles.name_tl = get(handles.edit_tl,'String');
handles.name_tr = get(handles.edit_tr,'String');
handles.name_bl = get(handles.edit_bl,'String');
handles.name_br = get(handles.edit_br,'String');
handles.keep_tl = 1;
handles.keep_tr = 0;
handles.keep_bl = 1;
handles.keep_br = 0;
guidata(hObject,handles);
function button_hv_Callback(hObject, ~, handles)
% turn on all options
set(handles.text_tl,'Visible','on');
set(handles.text_tr,'Visible','on');
set(handles.text_bl,'Visible','on');
set(handles.text_br,'Visible','on');
set(handles.checkbox1,'Visible','on');
set(handles.checkbox1,'Value',1);
set(handles.checkbox2,'Visible','on');
set(handles.checkbox2,'Value',1);
set(handles.checkbox3,'Visible','on');
set(handles.checkbox3,'Value',1);
set(handles.checkbox4,'Visible','on');
set(handles.checkbox4,'Value',1);
set(handles.text12,'Visible','on');
set(handles.text13,'Visible','on');
set(handles.text14,'Visible','on');
set(handles.text15,'Visible','on');
set(handles.edit_tl,'Visible','on');
set(handles.edit_tr,'Visible','on');
set(handles.edit_bl,'Visible','on');
set(handles.edit_br,'Visible','on');
if handles.num_im>0
    set(handles.pushbutton1,'Enable','on');
end
% update options to reflect 4-way splitting syntax
set(handles.text_tl,'String','Save Upper Left Half of Images');
set(handles.text_tr,'String','Save Upper Right Half of Images');
set(handles.text_bl,'String','Save Lower Left Half of Images');
set(handles.text_br,'String','Save Lower Right Half of Images');
set(handles.text12,'String','Name of Upper Left Half of Images:');
set(handles.text13,'String','Name of Upper Right Half of Images:');
set(handles.text12,'String','Name of Lower Left Half of Images:');
set(handles.text13,'String','Name of Lower Right Half of Images:');
set(handles.edit_tl,'String','topleft_');
set(handles.edit_tr,'String','topright_');
set(handles.edit_bl,'String','bottomleft_');
set(handles.edit_br,'String','bottomright_');
% update GUI handles for 4-way orientation
handles.name_tl = get(handles.edit_tl,'String');
handles.name_tr = get(handles.edit_tr,'String');
handles.name_bl = get(handles.edit_bl,'String');
handles.name_br = get(handles.edit_br,'String');
handles.keep_tl = 1;
handles.keep_tr = 1;
handles.keep_bl = 1;
handles.keep_br = 1;
guidata(hObject,handles);
