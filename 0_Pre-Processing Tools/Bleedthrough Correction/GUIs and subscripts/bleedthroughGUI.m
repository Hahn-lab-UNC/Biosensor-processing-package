function varargout = bleedthroughGUI(varargin)
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
% BLEEDTHROUGHGUI MATLAB code for bleedthroughGUI.fig
%      BLEEDTHROUGHGUI, by itself, creates a new BLEEDTHROUGHGUI or raises the existing
%      singleton*.
%
%      H = BLEEDTHROUGHGUI returns the handle to a new BLEEDTHROUGHGUI or the handle to
%      the existing singleton*.
%
%      BLEEDTHROUGHGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BLEEDTHROUGHGUI.M with the given input arguments.
%
%      BLEEDTHROUGHGUI('Property','Value',...) creates a new BLEEDTHROUGHGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bleedthroughGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bleedthroughGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bleedthroughGUI

% Last Modified by GUIDE v2.5 24-Aug-2016 09:08:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bleedthroughGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @bleedthroughGUI_OutputFcn, ...
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


% --- Executes just before bleedthroughGUI is made visible.
function bleedthroughGUI_OpeningFcn(hObject, ~, handles, varargin)
set(handles.figure1,'Visible','on');
handles.output = 0;

% Choose command line output for bleedthroughGUI
handles.btopts = struct;

handles.btopts.alpha_pairs = 1;
handles.btopts.alpha_shade = 0;
handles.btopts.alpha_dark = 0;
handles.btopts.beta_pairs = 1;
handles.btopts.beta_shade = 0;
handles.btopts.beta_dark = 0;
handles.btopts.shade_donor = '';
handles.btopts.shade_fret = '';
handles.btopts.shade_acceptor = '';
handles.btopts.dark_donor = '';
handles.btopts.dark_acceptor = '';

set(handles.slider1,'Min',1);
set(handles.slider1,'Max',15);
set(handles.slider1,'Value',1);
set(handles.slider1,'SliderStep',[1/15,1/15]);
guidata(hObject,handles);
set(handles.slider2,'Min',1);
set(handles.slider2,'Max',15);
set(handles.slider2,'Value',1);
set(handles.slider2,'SliderStep',[1/15,1/15]);
guidata(hObject,handles);

handles.sl1 = addlistener(handles.slider1,'Value','PostSet',@(src,evnt)slider1(handles.figure1,src,evnt));
handles.sl2 = addlistener(handles.slider2,'Value','PostSet',@(src,evnt)slider2(handles.figure1,src,evnt));

% Update handles structure
guidata(hObject, handles);

% wait for figure 1 to lose visibility (in pushbutton5 callback)
waitfor(handles.figure1,'Visible','off');


% --- Outputs from this function are returned to the command line.
function varargout = bleedthroughGUI_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;
delete(handles.figure1);


%#ok<*DEFNU>
%% Alpha Config
function slider1_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider1_Callback(~, ~, ~)
function slider1(hObject,~,~)
handles = guidata(hObject);
handles.btopts.alpha_pairs = round(get(handles.slider1,'Value'));
set(handles.edit1,'String',num2str(handles.btopts.alpha_pairs));
guidata(hObject, handles);


function edit1_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit1_Callback(hObject, ~, handles)
ap = str2double(get(hObject,'String'));
ap_max = get(handles.slider1,'Max');
if floor(ap) < 1
    set(handles.slider1,'Value',1);
    set(hObject,'String','1');
elseif ap > ap_max
    set(handles.slider1,'Value',ap_max);
    set(hObject,'String','15');
elseif isnan(ap)
    set(handles.slider1,'Value',1);
    set(hObject,'String','1');
else
    set(handles.slider1,'Value',round(ap));
    set(hObject,'String',num2str(round(ap)));
end
handles.btopts.alpha_pairs = round(str2double(get(hObject,'String')));
guidata(hObject,handles);


function checkbox1_Callback(hObject, ~, handles)
if get(hObject,'Value') == 1
    set(handles.pushbutton1,'Enable','on');
    handles.btopts.alpha_shade = 1;
    set(handles.pushbutton5,'Enable','off');
else
    set(handles.pushbutton1,'Enable','off');
    handles.btopts.alpha_shade = 0;
    handles.btopts.shade_donor = '';
    handles.btopts.shade_fret = '';
    if ~isempty(handles.btopts.dark_donor) || handles.btopts.alpha_dark == 0
        if ~isempty(handles.btopts.shade_acceptor) || handles.btopts.beta_shade == 0
           if ~isempty(handles.btopts.dark_acceptor) || handles.btopts.beta_dark == 0
               set(handles.pushbutton5,'Enable','on');
           end
        end
    end
end
guidata(hObject,handles);
function checkbox2_Callback(hObject, ~, handles)
if get(hObject,'Value') == 1
    set(handles.pushbutton2,'Enable','on');
    handles.btopts.alpha_dark = 1;
    set(handles.pushbutton5,'Enable','off');
else
    set(handles.pushbutton2,'Enable','off');
    handles.btopts.alpha_dark = 0;
    handles.btopts.dark_donor = '';
    handles.btopts.dark_acceptor = '';
    if ~isempty(handles.btopts.shade_donor) || handles.btopts.alpha_shade == 0
        if ~isempty(handles.btopts.shade_acceptor) || handles.btopts.beta_shade == 0
           if ~isempty(handles.btopts.dark_acceptor) || handles.btopts.beta_dark == 0
               set(handles.pushbutton5,'Enable','on');
           end
        end
    end
end
guidata(hObject,handles);


function pushbutton1_Callback(hObject, ~, handles)
disp('Select the shade image for the donor emission channel to use')
[file_shade_donor, path_shade_donor] = uigetfile('*.tif','Select the shade image for the donor emission channel to use');
if file_shade_donor == 0
    return;
end
disp('Select the shade image for the FRET emission channel to use')
[file_shade_fret, path_shade_fret] = uigetfile('*.tif','Select the shade image for the FRET emission channel to use');
if file_shade_fret == 0
    return;
end
handles.btopts.shade_donor = {file_shade_donor, path_shade_donor};
handles.btopts.shade_fret = {file_shade_fret, path_shade_fret};
if ~isempty(handles.btopts.dark_donor) || handles.btopts.alpha_dark == 0
    if ~isempty(handles.btopts.shade_acceptor) || handles.btopts.beta_shade == 0
       if ~isempty(handles.btopts.dark_acceptor) || handles.btopts.beta_dark == 0
           set(handles.pushbutton5,'Enable','on');
       end
    end
end
guidata(hObject,handles);
function pushbutton2_Callback(hObject, ~, handles)
disp('Select the dark current image for the donor emission channel to use')
[file_dark_donor, path_dark_donor] = uigetfile('*.tif','Select the dark current image for the donor emission channel to use');
if file_dark_donor == 0
    return;
end
disp('Select the dark current image for the FRET emission channel to use')
[file_dark_acceptor, path_dark_acceptor] = uigetfile('*.tif','Select the dark current image for the FRET emission channel to use');
if file_dark_acceptor == 0
    return;
end
handles.btopts.dark_donor = {file_dark_donor, path_dark_donor};
handles.btopts.dark_fret = {file_dark_acceptor, path_dark_acceptor};
if ~isempty(handles.btopts.shade_donor) || handles.btopts.alpha_shade == 0
    if ~isempty(handles.btopts.shade_acceptor) || handles.btopts.beta_shade == 0
       if ~isempty(handles.btopts.dark_acceptor) || handles.btopts.beta_dark == 0
           set(handles.pushbutton5,'Enable','on');
       end
    end
end
guidata(hObject,handles);


%% Beta Config
function slider2_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider2_Callback(~, ~, ~)
function slider2(hObject,~,~)
handles = guidata(hObject);
handles.btopts.beta_pairs = round(get(handles.slider2,'Value'));
set(handles.edit2,'String',num2str(handles.btopts.beta_pairs));
guidata(hObject, handles);


function edit2_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit2_Callback(hObject, ~, handles)
bp = str2double(get(hObject,'String'));
bp_max = get(handles.slider2,'Max');
if floor(bp) < 1
    set(handles.slider2,'Value',1);
    set(hObject,'String','1');
elseif bp > bp_max
    set(handles.slider2,'Value',bp_max);
    set(hObject,'String','15');
elseif isnan(bp)
    set(handles.slider2,'Value',1);
    set(hObject,'String','1');
else
    set(handles.slider2,'Value',round(bp));
    set(hObject,'String',num2str(round(bp)));
end
handles.btopts.beta_pairs = round(str2double(get(hObject,'String')));
guidata(hObject,handles);


function checkbox3_Callback(hObject, ~, handles)
if get(hObject,'Value') == 1
    set(handles.pushbutton3,'Enable','on');
    handles.btopts.beta_shade = 1;
    set(handles.pushbutton5,'Enable','off');
else
    set(handles.pushbutton3,'Enable','off');
    handles.btopts.beta_shade = 0;
    handles.btopts.shade_acceptor = '';
    if ~isempty(handles.btopts.dark_acceptor) || handles.btopts.beta_dark == 0
        if ~isempty(handles.btopts.shade_donor) || handles.btopts.alpha_shade == 0
           if ~isempty(handles.btopts.dark_donor) || handles.btopts.alpha_dark == 0
               set(handles.pushbutton5,'Enable','on');
           end
        end
    end
end
guidata(hObject,handles);
function checkbox4_Callback(hObject, ~, handles)
if get(hObject,'Value') == 1
    set(handles.pushbutton4,'Enable','on');
    handles.btopts.beta_dark = 1;
    set(handles.pushbutton5,'Enable','off');
else
    set(handles.pushbutton4,'Enable','off');
    handles.btopts.beta_dark = 0;
    handles.btopts.dark_acceptor = '';
    if ~isempty(handles.btopts.shade_acceptor) || handles.btopts.beta_shade == 0
        if ~isempty(handles.btopts.shade_donor) || handles.btopts.alpha_shade == 0
           if ~isempty(handles.btopts.dark_donor) || handles.btopts.alpha_dark == 0
               set(handles.pushbutton5,'Enable','on');
           end
        end
    end
end
guidata(hObject,handles);


function pushbutton3_Callback(hObject, ~, handles)
disp('Select the shade image for the acceptor emission channel to use')
[file_shade_acceptor, path_shade_acceptor] = uigetfile('*.tif','Select the shade image for the acceptor emission channel to use');
if file_shade_acceptor == 0
    return;
end
disp('Select the shade image for the FRET emission channel to use')
[file_shade_fret, path_shade_fret] = uigetfile('*.tif','Select the shade image for the FRET emission channel to use');
if file_shade_fret == 0
    return;
end
handles.btopts.shade_acceptor = {file_shade_acceptor, path_shade_acceptor};
handles.btopts.shade_fret = {file_shade_fret, path_shade_fret};
if ~isempty(handles.btopts.dark_acceptor) || handles.btopts.beta_dark == 0
    if ~isempty(handles.btopts.shade_donor) || handles.btopts.alpha_shade == 0
       if ~isempty(handles.btopts.dark_donor) || handles.btopts.alpha_dark == 0
           set(handles.pushbutton5,'Enable','on');
       end
    end
end
guidata(hObject,handles);
function pushbutton4_Callback(hObject, ~, handles)
disp('Select the dark current image for the acceptor emission channel to use')
[file_dark_acceptor, path_dark_acceptor] = uigetfile('*.tif','Select the dark current image for the acceptor emission channel to use');
if file_dark_acceptor == 0
    return;
end
handles.btopts.dark_acceptor = {file_dark_acceptor, path_dark_acceptor};
if ~isempty(handles.btopts.shade_acceptor) || handles.btopts.beta_shade == 0
    if ~isempty(handles.btopts.shade_donor) || handles.btopts.alpha_shade == 0
       if ~isempty(handles.btopts.dark_donor) || handles.btopts.alpha_dark == 0
           set(handles.pushbutton5,'Enable','on');
       end
    end
end
guidata(hObject,handles);


%% Continue Button & Close Function
function pushbutton5_Callback(hObject, ~, handles)
handles.output = handles.btopts;
guidata(hObject,handles);
set(handles.figure1,'Visible','off');

function figure1_CloseRequestFcn(~, ~, handles)
set(handles.figure1,'Visible','off');
