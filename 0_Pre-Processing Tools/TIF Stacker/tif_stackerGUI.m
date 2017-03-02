function varargout = tif_stackerGUI(varargin)
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
% TIF_STACKERGUI MATLAB code for tif_stackerGUI.fig
%      TIF_STACKERGUI, by itself, creates a new TIF_STACKERGUI or raises the existing
%      singleton*.
%
%      H = TIF_STACKERGUI returns the handle to a new TIF_STACKERGUI or the handle to
%      the existing singleton*.
%
%      TIF_STACKERGUI('CALLBACK',hObject,~,handles,...) calls the local
%      function named CALLBACK in TIF_STACKERGUI.M with the given input arguments.
%
%      TIF_STACKERGUI('Property','Value',...) creates a new TIF_STACKERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tif_stackerGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tif_stackerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tif_stackerGUI

% Last Modified by GUIDE v2.5 20-Feb-2017 18:15:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tif_stackerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @tif_stackerGUI_OutputFcn, ...
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


% --- Executes just before tif_stackerGUI is made visible.
function tif_stackerGUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tif_stackerGUI (see VARARGIN)

% Choose default command line output for tif_stackerGUI
handles.output = hObject;

handles.image_list = {};
handles.image_list_unsorted = {};
handles.query = '';
handles.working_dir = 0;
handles.num_im = 0;
handles.selected_path = 'Select image...';

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = tif_stackerGUI_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;


%% Helper Functions
function create_stack(handles)
% disable functionalities until splitting is done
set(handles.pushbutton1,'Enable','off');
set(handles.pushbutton2,'Enable','off');
set(handles.edit1,'Enable','off');
set(handles.edit2,'Enable','off');
set(handles.text14,'Visible','On');

% prompt user with save box
dlg_title = 'Save the new image stack to a ".tif" file';
[save_filename,save_path,filter] = uiputfile('*.tif',dlg_title,'stack');

if filter
    tic
    % store old directory path and change to path of save path specified
    old_dir = cd(save_path); 
    
    init_height = 0;
    init_width = 0;
    for file = 1:handles.num_im
        % get the file name
        read_filename = fullfile(handles.image_list{file});
        
        % check that file is a single frame image
        imgInfo = imfinfo(read_filename);
        num_frames = length(imgInfo);
        if num_frames > 1
            errordlg('Some images have more than one frame.')
        end
        
        % read the image data
        if file == 1
            init_height = imgInfo(1).Height;
            init_width = imgInfo(1).Width;
            im = zeros(init_height,init_width,'uint16');
        else
            if init_height ~= imgInfo(1).Height || init_width ~= imgInfo(1).Width
                errordlg('Not all images have matching dimensions.')
            end
        end
        im(:,:) = imread(fullfile(handles.working_dir,read_filename));

        % write the current image to the save file
        try 
            imwrite(im,save_filename,'tif','Compression','none','WriteMode','append');
        catch
            pause(.5)
            imwrite(im,save_filename,'tif','Compression','none','WriteMode','append');
        end
        
    end
    % switch background_subtractionGUI to old directory
    clear('im');
    cd(old_dir);
    disp('TIF Stack Saved')
    toc
end

% enable functionalities
set(handles.pushbutton1,'Enable','on');
set(handles.pushbutton2,'Enable','on');
set(handles.edit1,'Enable','on');
set(handles.edit2,'Enable','on');
set(handles.text14,'Visible','Off');


%#ok<*DEFNU>
%% Push Buttons
function pushbutton1_Callback(hObject, ~, handles)
create_stack(handles);
guidata(hObject,handles);

function pushbutton2_Callback(hObject, ~, handles)
handles.working_dir = uigetdir;
if ~(handles.working_dir==0)
    set(handles.edit1,'String',handles.working_dir);
    handles.selected_path = handles.working_dir;
    set(handles.edit1,'FontAngle','normal');
    set(handles.pushbutton1,'Enable','on');
    set(handles.checkbox1,'Enable','on');
else
    return
end
% count number of TIF images in directory and store in cell array
if ~(handles.working_dir==0)
    if ~isempty(handles.query)
        srcFiles = dir(fullfile(handles.working_dir,['*',handles.query,'*.*']));
    else
        srcFiles = dir(fullfile(handles.working_dir,'*.*'));
    end
    handles.image_list = {};
    for Index = 1:length(srcFiles)
        filename = srcFiles(Index).name;
        [~, ~, extension] = fileparts(filename);
        extension = upper(extension);
        switch lower(extension)
            case {'.tif'}
                handles.image_list = [handles.image_list filename];
            otherwise
        end
    end
    if get(handles.checkbox1,'Value') == 1
        handles.image_list_unsorted = handles.image_list;
        handles.image_list = sort_nat(handles.image_list);
    end
    set(handles.listbox1,'String',handles.image_list);
    handles.num_im = length(handles.image_list);
    str = sprintf('Number of Images to Stack:    %d',handles.num_im);
    set(handles.text8,'String',str);
end
if handles.num_im > 0
    set(handles.checkbox1,'Enable','on');
else
    set(handles.checkbox1,'Enable','off');
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
set(hObject,'String',handles.selected_path);
guidata(hObject,handles);
function edit2_Callback(hObject, ~, handles)
set(handles.listbox1,'Value',1);
handles.query = get(hObject,'String');
if ~(handles.working_dir==0)
    if ~isempty(handles.query)
        srcFiles = dir(fullfile(handles.working_dir,['*',handles.query,'*.*']));
    else
        srcFiles = dir(fullfile(handles.working_dir,'*.*'));
    end
    handles.image_list = {};
    for Index = 1:length(srcFiles)
        filename = srcFiles(Index).name;
        [~, ~, extension] = fileparts(filename);
        extension = upper(extension);
        switch lower(extension)
            case {'.tif'}
                handles.image_list = [handles.image_list filename];
            otherwise
        end
    end
    if get(handles.checkbox1,'Value') == 1
        handles.image_list_unsorted = handles.image_list;
        handles.image_list = sort_nat(handles.image_list);
    end
    set(handles.listbox1,'String',handles.image_list);
    handles.num_im = length(handles.image_list);
    str = sprintf('Number of Images to Stack:    %d',handles.num_im);
    set(handles.text8,'String',str);
end
if handles.num_im > 0
    set(handles.checkbox1,'Enable','on');
else
    set(handles.checkbox1,'Enable','off');
end
guidata(hObject,handles);


%% List Boxes
function listbox1_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Check Boxes
function checkbox1_Callback(hObject, ~, handles)
if get(hObject,'Value') == 1
    handles.image_list_unsorted = handles.image_list;
    handles.image_list = sort_nat(handles.image_list);
    set(handles.listbox1,'String',handles.image_list);
else
    handles.image_list = handles.image_list_unsorted;
    set(handles.listbox1,'String',handles.image_list);
    handles.image_list_unsorted = {};
end
guidata(hObject,handles);
