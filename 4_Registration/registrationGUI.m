function varargout = registrationGUI(varargin)
%registrationGUI M-file for registrationGUI.fig
%      registrationGUI, by itself, creates a new registrationGUI or raises the existing
%      singleton*.
%
%      H = registrationGUI returns the handle to a new registrationGUI or the handle to
%      the existing singleton*.
%
%      registrationGUI('Property','Value',...) creates a new registrationGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to registrationGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      registrationGUI('CALLBACK') and registrationGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in registrationGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help registrationGUI

% Last Modified by GUIDE v2.5 08-Aug-2016 10:33:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @registrationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @registrationGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


function setGlobaly(y)
global yOffset
yOffset = y;
function setGlobalx(x)
global xOffset
xOffset = x;
function y = getGlobaly
global yOffset
y = yOffset;
function x = getGlobalx
global xOffset
x = xOffset;
function setGlobal_fuses(fusion_cell)
global fuses
fuses = fusion_cell;
function fusion_cell = getGlobal_fuses
global fuses
fusion_cell = fuses;


% --- Executes just before registrationGUI is made visible.
function registrationGUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for registrationGUI
handles.output = hObject;

global rect;  %#ok<NUSED>

setGlobaly(0);
setGlobalx(0);

user_data = get(handles.playtoggle1,'UserData');
user_data.stop = 0;
set(handles.playtoggle1,'UserData',user_data);

% base/register --> overlay [R G B]
% green/blue --> cyan       [0 1 2]
% blue/green --> cyan       [0 2 1]
% red/blue --> magenta      [1 0 2]
% blue/red --> magenta      [2 0 1]
% red/green --> yellow      [1 2 0]
% green/red --> yellow      [2 1 0]
% yellow/blue --> gray      [1 1 2]
% blue/yellow --> gray      [2 2 1]
% magenta/green --> gray    [1 2 1]
% green/magenta --> gray    [2 1 2]
% cyan/red --> gray         [2 1 1]
% red/cyan --> gray         [1 2 2]
f_cell = {[0 1 2],[0 2 1],[1 0 2],[2 0 1],[1 2 0],[2 1 0],[1 1 2],[2 2 1],[1 2 1],[2 1 2],[2 1 1],[1 2 2]};
setGlobal_fuses(f_cell);

% Update handles structure
guidata(hObject, handles);

function varargout = registrationGUI_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Helper Functions
function auto_reg(bcell,rcell,frames)
offsetval = zeros(frames,2);
for i=1:frames
    b = double(bcell{i});
    r = double(rcell{i});
    
    SS = size(b);
    picc_b = reshape(b,1,(SS(1)*SS(2)));
    picc_r = reshape(r,1,(SS(1)*SS(2)));

    picc_b = reshape(picc_b, SS(1),SS(2));
    picc_r = reshape(picc_r, SS(1),SS(2));        

    %% Registration by Cross Correlation
    % r in relation to b

    correlation = normxcorr2(picc_b, picc_r); % offset by correlation

    clear picc_b picc_r post*;
    
    [xoffsetsub,yoffsetsub] = subpixShift(correlation);
    
    offsetval(i,2)= yoffsetsub;
    offsetval(i,1)= xoffsetsub;
end
yOffsets = offsetval(:,2);
xOffsets = offsetval(:,1);

setGlobaly(median(yOffsets))
setGlobalx(median(xOffsets))

function update_images(hObject,frame)
handles = guidata(hObject);
handles.curImage_b = handles.frames_b{frame};
handles.curImage_r = handles.frames_r{frame};
b = handles.curImage_b;
r = handles.curImage_r;
yoff = getGlobaly;
xoff = getGlobalx;
if get(handles.radiobutton1,'Value') == 1
    % if automatic registration is selected
    yoff_int = floor(yoff);
    xoff_int = floor(xoff);

    % whole pixel shift
    se = translate(strel(1),[yoff_int xoff_int]);
    r = imdilate(uint16(r),se);
    % sub-pixel shift
    r = subalign(r,xoff-xoff_int,yoff-yoff_int);
    r = uint16(r);
else
    % if manual registration is selected
    se = translate(strel(1),[floor(yoff) floor(xoff)]);
    r = uint16(imdilate(uint16(r),se));
end
fuse_cell = getGlobal_fuses;
fuse = fuse_cell{get(handles.popupmenu1,'Value')};
handles.overlay_im = imfuse(b,r,'falsecolor','Scaling','independent','ColorChannels',fuse);

if isempty(get(handles.axes1,'Children'))  % is the axis empty (i.e. have any 'Children')
    % sets base image
    set(handles.figure1,'CurrentAxes',handles.axes1);
    imagesc(handles.curImage_b,'Parent',handles.axes1);  % image the current frame in 'handles.axes1'
    set(handles.axes1,'CLim',[handles.CLim_Min_b, handles.CLim_Max_b],'XTick',[],'YTick',[],'Box','on');  % set 'handles.axes1' properties
    set(handles.CLim_Max_Tag1, 'String', num2str(handles.CLim_Max_b));  % set the edit box 'CLim_Max_Tag1' to the current CLim_val 'maximum'
    set(handles.CLim_Min_Tag1, 'String', num2str(handles.CLim_Min_b));  % set the edit box 'CLim_Min_Tag1' to the current CLim_val 'minimum'
    colormap(gray);
    colorbar;
    axis image  % sets the aspect ratio so that the data units are the same in every direction and the plot box fits tightly around the data
    
    % sets image to be registered
    set(handles.figure1,'CurrentAxes',handles.axes2);
    imagesc(handles.curImage_r,'Parent',handles.axes2);  % image the current frame in 'handles.axes2'
    set(handles.axes2,'CLim',[handles.CLim_Min_r, handles.CLim_Max_r],'XTick',[],'YTick',[],'Box','on');  % set 'handles.axes2' properties
    set(handles.CLim_Max_Tag2, 'String', num2str(handles.CLim_Max_r));  % set the edit box 'CLim_Max_Tag2' to the current CLim_val 'maximum'
    set(handles.CLim_Min_Tag2, 'String', num2str(handles.CLim_Min_r));  % set the edit box 'CLim_Min_Tag2' to the current CLim_val 'minimum'
    colormap(gray);
    colorbar;
    axis image  % sets the aspect ratio so that the data units are the same in every direction and the plot box fits tightly around the data

    % sets overlay image
    set(handles.figure1,'CurrentAxes',handles.axes3); % image the current frame in 'handles.axes3'
    imagesc(handles.overlay_im,'Parent',handles.axes3);
    set(handles.axes3,'XTick',[],'YTick',[],'Box','on'); % set 'handles.axes3' properties
    
    axis image
else
    imHandle = findobj(handles.axes1,'Type','image'); % find the 'image' handle in handles.axes1
    set(imHandle,'CData',handles.curImage_b); % update the image to the current frame
    
    imHandle = findobj(handles.axes2,'Type','image'); % find the 'image' handle in handles.axes2
    set(imHandle,'CData',handles.curImage_r); % update the image to the current frame
    
    imHandle = findobj(handles.axes3,'Type','image'); % find the 'image' handle in handles.axes3
    set(imHandle,'CData',handles.overlay_im); % update the image to the current frame
end
guidata(hObject,handles);


%% Listner Functions
function slider1(hObject, ~, ~)
handles = guidata(hObject);
set(handles.slider2,'Max',get(handles.slider1,'Value')-1.0);
set(handles.figure1,'CurrentAxes',handles.axes1);
set(handles.axes1,'CLim',[get(handles.slider2,'Value'),get(handles.slider1,'Value')]);
handles.CLim_Max_b = get(handles.slider1,'Value');
set(handles.CLim_Max_Tag1,'String',num2str(get(handles.slider1,'Value'))); % set the edit box 'CLim_Max_Tag1' to the current CLim_val 'maximum'
guidata(hObject, handles);
function slider2(hObject, ~, ~)
handles = guidata(hObject);
set(handles.slider1,'Min',get(handles.slider2,'Value')+1.0);
set(handles.figure1,'CurrentAxes',handles.axes1);
set(handles.axes1,'CLim',[get(handles.slider2,'Value'),get(handles.slider1,'Value')]);
handles.CLim_Min_b = get(handles.slider2,'Value');
set(handles.CLim_Min_Tag1,'String',num2str(get(handles.slider2,'Value'))); % set the edit box 'CLim_Min_Tag1' to the current CLim_val 'minimum'
guidata(hObject, handles);
function slider3(hObject, ~, ~)
handles = guidata(hObject);
set(handles.slider4,'Max',get(handles.slider3,'Value')-1.0);
set(handles.figure1,'CurrentAxes',handles.axes2);
set(handles.axes2,'CLim',[get(handles.slider4,'Value'),get(handles.slider3,'Value')]);
handles.CLim_Max_r = get(handles.slider3,'Value');
set(handles.CLim_Max_Tag2,'String',num2str(get(handles.slider3,'Value'))); % set the edit box 'CLim_Max_Tag2' to the current CLim_val 'maximum'
guidata(hObject, handles);
function slider4(hObject, ~, ~)
handles = guidata(hObject);
set(handles.slider3,'Min',get(handles.slider4,'Value')+1.0);
set(handles.figure1,'CurrentAxes',handles.axes2);
set(handles.axes2,'CLim',[get(handles.slider4,'Value'),get(handles.slider3,'Value')]);
handles.CLim_Min_r = get(handles.slider4,'Value');
set(handles.CLim_Min_Tag2,'String',num2str(get(handles.slider4,'Value'))); % set the edit box 'CLim_Min_Tag2' to the current CLim_val 'minimum'
guidata(hObject, handles);
function slider5(hObject, ~, ~)
handles = guidata(hObject);
yo = -1*get(handles.slider5,'Value');
set(handles.edit1,'String',num2str(round(yo)));
if get(handles.radiobutton1,'Value') ~= 1
    setGlobaly(yo);
    update_images(hObject,round(get(handles.slider7,'Value')));
end
guidata(hObject,handles);
function slider6(hObject, ~, ~)
handles = guidata(hObject);
xo = get(handles.slider6,'Value');
set(handles.edit2,'String',num2str(round(xo)));
if get(handles.radiobutton1,'Value') ~= 1
    setGlobalx(xo);
    update_images(hObject,round(get(handles.slider7,'Value')));
end
guidata(hObject,handles);
function slider7(hObject, ~, ~)
handles = guidata(hObject);
frame = round(get(handles.slider7,'Value'));
update_images(hObject,frame);
set(handles.edit3,'String',num2str(frame,'%d')); % set the edit box to indicate the current frame number
guidata(hObject, handles);

function mousehover(hObject, varargin)
handles = guidata(hObject);
global rect;
delete(rect);
point = get(handles.figure1,'CurrentPoint');
ax1pos = get(handles.axes1,'Position');
ax2pos = get(handles.axes2,'Position');
ax3pos = get(handles.axes3,'Position');
xLim = handles.width_b;
yLim = handles.height_b;
frame = round(get(handles.slider7,'Value'));
im_b = handles.frames_b{frame};
im_r = handles.frames_r{frame};
inaxes1 = point(1) >= ax1pos(1) && point(1) <= ax1pos(1) + ax1pos(3) && point(2) >= ax1pos(2) && point(2) <= ax1pos(2) + ax1pos(4);
inaxes2 = point(1) >= ax2pos(1) && point(1) <= ax2pos(1) + ax2pos(3) && point(2) >= ax2pos(2) && point(2) <= ax2pos(2) + ax2pos(4);
inaxes3 = point(1) >= ax3pos(1) && point(1) <= ax3pos(1) + ax3pos(3) && point(2) >= ax3pos(2) && point(2) <= ax3pos(2) + ax3pos(4);
if inaxes1
    pt = get(handles.axes1,'CurrentPoint');
    if (ceil(pt(1,1)) <= 0 || ceil(pt(1,1)) > size(im_b,2))
        return;
    elseif (ceil(pt(1,2)) <= 0 || ceil(pt(1,2)) > size(im_b,1))
        return;
    end
    set(handles.text14,'String',sprintf('Base:      (%d,%d) = %.2f\nRegister: (%d,%d) = %.2f',...
        ceil(pt(1,2)),ceil(pt(1,1)),im_b(ceil(pt(1,2)),ceil(pt(1,1))),...
        ceil(pt(1,2)),ceil(pt(1,1)),im_r(ceil(pt(1,2)),ceil(pt(1,1)))...
        ));
    
    if floor(pt(1,1)) + 10 >= xLim
        rec_width = xLim - floor(pt(1,1));
    else
        rec_width = 10;
    end
    if floor(pt(1,2)) + 10 >= yLim
        rec_height = yLim - floor(pt(1,2));
    else
        rec_height = 10;
    end
    set(handles.figure1,'CurrentAxes',handles.axes2);
    rect = rectangle('Position',[ceil(pt(1,1)) ceil(pt(1,2)) rec_width rec_height],'EdgeColor','c','FaceColor','c');
    return;
elseif inaxes2
    pt = get(handles.axes2,'CurrentPoint');
    if (ceil(pt(1,1)) <= 0 || ceil(pt(1,1)) > size(im_b,2))
        return;
    elseif (ceil(pt(1,2)) <= 0 || ceil(pt(1,2)) > size(im_b,1))
        return;
    end
    set(handles.text14,'String',sprintf('Base:      (%d,%d) = %.2f\nRegister: (%d,%d) = %.2f',...
        ceil(pt(1,2)),ceil(pt(1,1)),im_b(ceil(pt(1,2)),ceil(pt(1,1))),...
        ceil(pt(1,2)),ceil(pt(1,1)),im_r(ceil(pt(1,2)),ceil(pt(1,1))) ...
        ));
    
    if floor(pt(1,1)) + 10 >= xLim
        rec_width = xLim - floor(pt(1,1));
    else
        rec_width = 10;
    end
    if floor(pt(1,2)) + 10 >= yLim
        rec_height = yLim - floor(pt(1,2));
    else
        rec_height = 10;
    end
    
    set(handles.figure1,'CurrentAxes',handles.axes1);    
    rect = rectangle('Position',[ceil(pt(1,1)) ceil(pt(1,2)) rec_width rec_height],'EdgeColor','c','FaceColor','c');
    return;
elseif inaxes3
    pt = get(handles.axes3,'CurrentPoint');
    if (ceil(pt(1,1)) <= 0 || ceil(pt(1,1)) > size(im_b,2))
        return;
    elseif (ceil(pt(1,2)) <= 0 || ceil(pt(1,2)) > size(im_b,1))
        return;
    end
    set(handles.text14,'String',sprintf('Base:      (%d,%d) = %.2f\nRegister: (%d,%d) = %.2f',...
        ceil(pt(1,2)),ceil(pt(1,1)),im_b(ceil(pt(1,2)),ceil(pt(1,1))),...
        ceil(pt(1,2)),ceil(pt(1,1)),im_r(ceil(pt(1,2)),ceil(pt(1,1))) ...
        ));
    return;
else
    set(handles.text14,'String',sprintf('Base:      (%d,%d) = %.2f\nRegister: (%d,%d) = %.2f',...
        0.0,0.0,0.0,...
        0.0,0.0,0.0 ...
        ));
    return;
end
%     im_f = handles.overlay_im;
%     var = im_f(110,190)
%     whos var
%     disp(im_f(ceil(pt(1,2)),ceil(pt(1,1))))
%     disp(type(im_f(ceil(pt(1,2)),ceil(pt(1,1)))))
%         ceil(pt(1,2)),ceil(pt(1,1)),im_f(ceil(pt(1,2)),ceil(pt(1,1)))


%% CLim Edit Boxes
function CLim_Min_Tag1_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function CLim_Max_Tag1_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function CLim_Min_Tag2_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function CLim_Max_Tag2_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CLim_Max_Tag1_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.CLim_Max_b = str2double(get(hObject,'String'));  % define in the structure 'handles' the maximum CLim value
set(handles.axes1,'CLim',[handles.CLim_Min_b, handles.CLim_Max_b]);  % set the CLim of the current frame
guidata(hObject,handles); % update handles structure
function CLim_Min_Tag1_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.CLim_Min_b = str2double(get(hObject,'String'));  % define in the structure 'handles' the minimum CLim value
set(handles.axes1,'CLim',[handles.CLim_Min_b, handles.CLim_Max_b]);  % set the CLim of the current frame
guidata(hObject,handles);  % update handles structure
function CLim_Max_Tag2_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.CLim_Max_r = str2double(get(hObject,'String'));  % define in the structure 'handles' the maximum CLim value
set(handles.axes2,'CLim',[handles.CLim_Min_r, handles.CLim_Max_r]);  % set the CLim of the current frame
guidata(hObject,handles); % update handles structure
function CLim_Min_Tag2_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.CLim_Min_r = str2double(get(hObject,'String'));  % define in the structure 'handles' the minimum CLim value
set(handles.axes2,'CLim',[handles.CLim_Min_r, handles.CLim_Max_r]);  % set the CLim of the current frame
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
function slider4_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider5_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider6_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider7_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider1_Callback(hObject, ~, handles) %#ok<DEFNU>
if get(handles.slider1,'Value') == get(handles.slider2,'Value')+1
    set(handles.slider2,'Enable','Off');
else
    set(handles.slider2,'Enable','On');
end
guidata(hObject,handles);
function slider2_Callback(hObject, ~, handles) %#ok<DEFNU>
if get(handles.slider2,'Value') == get(handles.slider1,'Value')-1
    set(handles.slider1,'Enable','Off');
else
    set(handles.slider1,'Enable','On');
end
guidata(hObject,handles);
function slider3_Callback(hObject, ~, handles) %#ok<DEFNU>
if get(handles.slider3,'Value') == get(handles.slider4,'Value')+1
    set(handles.slider4,'Enable','Off');
else
    set(handles.slider4,'Enable','On');
end
guidata(hObject,handles);
function slider4_Callback(hObject, ~, handles) %#ok<DEFNU>
if get(handles.slider4,'Value') == get(handles.slider3,'Value')-1
    set(handles.slider3,'Enable','Off');
else
    set(handles.slider3,'Enable','On');
end
guidata(hObject,handles);
function slider7_Callback(~, ~, ~) %#ok<DEFNU>


%% Radio Button Group
function uibuttongroup1_SelectionChangedFcn(hObject, ~, handles) %#ok<DEFNU>
toggle = get(handles.radiobutton1,'Value');
if toggle == 1
    setGlobaly(str2double(get(handles.text3,'String')));
    setGlobalx(str2double(get(handles.text4,'String')));
    set(handles.slider5,'Enable','Off');
    set(handles.slider6,'Enable','Off');
    guidata(hObject,handles);
else
    setGlobaly(str2double(get(handles.edit1,'String')));
    setGlobalx(str2double(get(handles.edit2,'String')));
    set(handles.slider5,'Enable','On');
    set(handles.slider6,'Enable','On');
    guidata(hObject,handles);
end
update_images(hObject,round(get(handles.slider7,'Value')));
guidata(hObject,handles);

    
%% Pop-up Menu
function popupmenu1_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu1_Callback(hObject, ~, handles) %#ok<DEFNU>
% base/register --> overlay [R G B]
% green/blue --> cyan       [0 1 2] index = 1
% blue/green --> cyan       [0 2 1] index = 2
% red/blue --> magenta      [1 0 2] index = 3
% blue/red --> magenta      [2 0 1] index = 4
% red/green --> yellow      [1 2 0] index = 5
% green/red --> yellow      [2 1 0] index = 6
% yellow/blue --> gray      [1 1 2] index = 7
% blue/yellow --> gray      [2 2 1] index = 8
% magenta/green --> gray    [1 2 1] index = 9
% green/magenta --> gray    [2 1 2] index = 10
% cyan/red --> gray         [2 1 1] index = 11
% red/cyan --> gray         [1 2 2] index = 12
update_images(hObject,round(get(handles.slider7,'Value')));


%% Edit Boxes
function edit1_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit2_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit3_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit8_CreateFcn(hObject, ~, handles) %#ok<DEFNU>
handles.pausetime = str2double(get(hObject,'String'));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

function edit1_Callback(hObject, ~, handles) %#ok<DEFNU>
var = round(str2double(get(handles.edit1,'String')));
set(handles.edit1,'String',num2str(var));
if abs(var) <= 10
    set(handles.slider5,'Value',var);
elseif var > 10
    set(handles.slider5,'Value',10);
elseif var < 10
    set(handles.slider5,'Value',-10);
else
    set(handles.slider5,'Value',0);
end
if get(handles.radiobutton1,'Value') ~= 1
    setGlobaly(var);
end
guidata(hObject,handles);
function edit2_Callback(hObject, ~, handles) %#ok<DEFNU>
var = round(str2double(get(handles.edit2,'String')));
set(handles.edit2,'String',num2str(var));
if abs(var) <= 10
    set(handles.slider6,'Value',var);
elseif var > 10
    set(handles.slider6,'Value',10);
elseif var < 10
    set(handles.slider6,'Value',-10);
else
    set(handles.slider6,'Value',0);
end
if get(handles.radiobutton1,'Value') ~= 1
    setGlobalx(var);
end
guidata(hObject,handles);
function edit3_Callback(hObject, ~, handles) %#ok<DEFNU>
frame = str2double(get(hObject,'String'));
frame_max = get(handles.slider7,'Max');
if floor(frame) < 1
    set(handles.slider7,'Value',1);
elseif floor(frame) > frame_max
    set(handles.slider7,'Value',frame_max);
elseif isnan(frame)
    set(handles.slider7,'Value',1);
else
    set(handles.slider7,'Value',frame);
end
guidata(hObject,handles);
function edit8_Callback(hObject, ~, handles) %#ok<DEFNU>
handles.pausetime = str2double(get(hObject,'String'));
guidata(hObject,handles);


%% Menu Option Tags
function file_tag_Callback(~, ~, ~) %#ok<DEFNU>

function import_tag_Callback(hObject, ~, handles) %#ok<DEFNU>

if ~isempty(get(handles.axes1,'Children'))
    set(handles.slider1,'Enable','Off');
    set(handles.slider2,'Enable','Off');
    set(handles.slider3,'Enable','Off');
    set(handles.slider4,'Enable','Off');
    set(handles.slider7,'Enable','Off');
    set(handles.radiobutton1,'Enable','Off');
    set(handles.radiobutton2,'Enable','Off');
    set(handles.edit1,'Enable','Off');
    set(handles.edit2,'Enable','Off');
    set(handles.edit3,'Enable','Off');
    set(handles.edit8,'Enable','Off');
    set(handles.popupmenu1,'Enable','Off');
    set(handles.CLim_Max_Tag1,'Enable','Off');
    set(handles.CLim_Min_Tag1,'Enable','Off');
    set(handles.CLim_Max_Tag2,'Enable','Off');
    set(handles.CLim_Min_Tag2,'Enable','Off');
    set(handles.save_tag,'Enable','Off');
    set(handles.uitoggletool1,'Enable','Off');
    set(handles.uitoggletool2,'Enable','Off');
    set(handles.uitoggletool3,'Enable','Off');
    set(handles.playtoggle1,'Enable','Off');
end
    
% import base (b) and register (r) image
% user selection of files and check if file exists
go = 1;
disp('Select the base image to register to (".tif" format)')
[file1, path1] = uigetfile('*.tif','Select the base image to register to (".tif" format):');
if file1 ~= 0
    disp('Select the image to register to the base image (".tif" format)')
    [file2, path2] = uigetfile('*.tif','Select the image to register to the base image (".tif" format):');
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
    if handles.num_frames > 1
        set(handles.slider1,'Enable','On');
    end
    set(handles.radiobutton1,'Enable','On');
    set(handles.radiobutton2,'Enable','On');
    set(handles.edit1,'Enable','On');
    set(handles.edit2,'Enable','On');
    set(handles.edit3,'Enable','On');
    set(handles.edit8,'Enable','On');
    set(handles.popupmenu1,'Enable','On');
    set(handles.CLim_Max_Tag1,'Enable','On');
    set(handles.CLim_Min_Tag1,'Enable','On');
    set(handles.CLim_Max_Tag2,'Enable','On');
    set(handles.CLim_Min_Tag2,'Enable','On');
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
info_b = imfinfo(fullfile(path1,file1));
handles.width_b = info_b(1).Width;
handles.height_b = info_b(1).Height;
num_frames_b = length(info_b);
handles.num_frames = num_frames_b;

info_r = imfinfo(fullfile(path2,file2));
handles.width_r = info_r(1).Width;
handles.height_r = info_r(1).Height;
num_frames_r = length(info_r);

handles.rect = rectangle('Position',[0 0 0 0]);

% check if image sizes match
if handles.width_r ~= handles.width_b || handles.height_b ~= handles.height_r
    sprintf('Error: dimensions between selected images do not match.');
    return
elseif num_frames_b ~= num_frames_r
    sprintf('Error: number of frames in selected images do not match.');
end

% initialize image data and load into handles.frames_b/r
handles.frames_b = cell(1,num_frames_b);
handles.frames_r = cell(1,num_frames_r);
maxs_b = zeros(1,num_frames_b);
maxs_r = zeros(1,num_frames_r);
for i = 1:num_frames_b
   handles.frames_b{i} = imread(fullfile(path1,file1),i);
   handles.frames_r{i} = imread(fullfile(path2,file2),i);
   maxs_b(i) = max(max(handles.frames_b{i}));
   maxs_r(i) = max(max(handles.frames_r{i}));
end

handles.overlay_im = 0;

% perform automatic registration
auto_reg(handles.frames_b,handles.frames_r,num_frames_b);
set(handles.text3,'String',num2str(getGlobaly));
set(handles.text4,'String',num2str(getGlobalx));

% set CLim max and min for b/r
handles.CLim_Max_b = max(max(maxs_b));  % define the maximum value in b
handles.CLim_Min_b = 0;                 % define the minimum value in b
handles.CLim_Max_r = max(max(maxs_r));  % define the maximum value in r
handles.CLim_Min_r = 0;                 % define the minimum value in r

% turn enable 'On' for all necessary components
set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
set(handles.slider3,'Enable','On');
set(handles.slider4,'Enable','On');
if num_frames_b > 1
    set(handles.slider1,'Enable','On');
end
set(handles.radiobutton1,'Enable','On');
set(handles.radiobutton2,'Enable','On');
set(handles.edit1,'Enable','On');
set(handles.edit2,'Enable','On');
set(handles.edit3,'Enable','On');
set(handles.edit8,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.CLim_Max_Tag1,'Enable','On');
set(handles.CLim_Min_Tag1,'Enable','On');
set(handles.CLim_Max_Tag2,'Enable','On');
set(handles.CLim_Min_Tag2,'Enable','On');
set(handles.save_tag,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.playtoggle1,'Enable','On');

% set max, min, and values of CLim Value sliders
set(handles.slider1,'Max',handles.CLim_Max_b);    % define slider's max value found in all frames for b
set(handles.slider1,'Min',handles.CLim_Min_b + 1.0);
set(handles.slider1,'Value',handles.CLim_Max_b);  % set the slider's location to the maximum value for b
set(handles.slider2,'Max',handles.CLim_Max_b - 1.0);
set(handles.slider2,'Min',handles.CLim_Min_b);
set(handles.slider2,'Value',handles.CLim_Min_b);
set(handles.slider3,'Max',handles.CLim_Max_r);    % define slider's max value found in all frames for r
set(handles.slider3,'Min',handles.CLim_Min_r + 1.0);
set(handles.slider3,'Value',handles.CLim_Max_r);  % set the slider's location to the maximum value for r
set(handles.slider4,'Max',handles.CLim_Max_r - 1.0);
set(handles.slider4,'Min',handles.CLim_Min_r);
set(handles.slider4,'Value',handles.CLim_Min_r);

% set bounds and initialize frame slider
set(handles.slider7,'Min',1);
set(handles.slider7,'Max',num_frames_b);
set(handles.slider7,'Value',1);
set(handles.slider7,'SliderStep',[1/num_frames_b,1/num_frames_b]);
guidata(hObject,handles);

update_images(hObject,round(get(handles.slider7,'Value')));

% set initial max and min pixel values
set(handles.CLim_Max_Tag1, 'String', num2str(handles.CLim_Max_b));
set(handles.CLim_Min_Tag1, 'String', num2str(handles.CLim_Min_b));
set(handles.CLim_Max_Tag2, 'String', num2str(handles.CLim_Max_r));
set(handles.CLim_Min_Tag2, 'String', num2str(handles.CLim_Min_r));

% set to display max frames in textbox
set(handles.text6,'String',['of ',num2str(num_frames_b,'%d')]);

% set offset sliders
set(handles.slider5,'Max',10);
set(handles.slider5,'Min',-10);
set(handles.slider5,'Value',0);
set(handles.slider5,'SliderStep',[1/20,1/20]);
set(handles.slider6,'Max',10);
set(handles.slider6,'Min',-10);
set(handles.slider6,'Value',0);
set(handles.slider6,'SliderStep',[1/20,1/20]);

% add listener functions
handles.sl1 = addlistener(handles.slider1,'Value','PostSet',@(src,evnt)slider1(handles.figure1,src,evnt));
handles.sl2 = addlistener(handles.slider2,'Value','PostSet',@(src,evnt)slider2(handles.figure1,src,evnt));
handles.sl3 = addlistener(handles.slider3,'Value','PostSet',@(src,evnt)slider3(handles.figure1,src,evnt));
handles.sl4 = addlistener(handles.slider4,'Value','PostSet',@(src,evnt)slider4(handles.figure1,src,evnt));
handles.sl5 = addlistener(handles.slider5,'Value','PostSet',@(src,evnt)slider5(handles.figure1,src,evnt));
handles.sl6 = addlistener(handles.slider6,'Value','PostSet',@(src,evnt)slider6(handles.figure1,src,evnt));
handles.sl7 = addlistener(handles.slider7,'Value','PostSet',@(src,evnt)slider7(handles.figure1,src,evnt));

% set mouse hover functionality
set(handles.figure1,'WindowButtonMotionFcn',@(varargin) mousehover(handles.figure1,varargin));

guidata(hObject,handles);

function save_tag_Callback(hObject, ~, handles) %#ok<DEFNU>
% disable all components to save registered image
set(handles.slider1,'Enable','Off');
set(handles.slider2,'Enable','Off');
set(handles.slider3,'Enable','Off');
set(handles.slider4,'Enable','Off');
set(handles.slider7,'Enable','Off');
set(handles.radiobutton1,'Enable','Off');
set(handles.radiobutton2,'Enable','Off');
set(handles.edit1,'Enable','Off');
set(handles.edit2,'Enable','Off');
set(handles.edit3,'Enable','Off');
set(handles.edit8,'Enable','Off');
set(handles.popupmenu1,'Enable','Off');
set(handles.CLim_Max_Tag1,'Enable','Off');
set(handles.CLim_Min_Tag1,'Enable','Off');
set(handles.CLim_Max_Tag2,'Enable','Off');
set(handles.CLim_Min_Tag2,'Enable','Off');
set(handles.save_tag,'Enable','Off');
set(handles.uitoggletool1,'Enable','Off');
set(handles.uitoggletool2,'Enable','Off');
set(handles.uitoggletool3,'Enable','Off');
set(handles.playtoggle1,'Enable','Off');

% get number of frames
frames = get(handles.slider7,'Max');

% prompt user with save box
dlg_title = 'Save the New Registered Image to a ".tif" file';
[file_name,path_name,filter] = uiputfile('*.tif',dlg_title,'_reg');

if filter
    % store old directory path and change to path of save file specified
    old_dir = cd(path_name);

    % perform registration on each frame with the designated offsets
    for i=1:frames

        handles.curImage_r = handles.frames_r{i};
        r = handles.curImage_r;

        yoff = getGlobaly;
        xoff = getGlobalx;

        if get(handles.radiobutton1,'Value') == 1
            % if automatic registration is selected
            yoff_int = floor(yoff);
            xoff_int = floor(xoff);

            % whole pixel shift
            se = translate(strel(1),[yoff_int xoff_int]);
            r = imdilate(uint16(r),se);
            % sub-pixel shift
            r = subalign(r,xoff-xoff_int,yoff-yoff_int);
            r = uint16(r);
        else
            % if manual registration is selected
            se = translate(strel(1),[floor(yoff) floor(xoff)]);
            r = uint16(imdilate(uint16(r),se));
        end

        % write the current frame to the save file
        try 
            imwrite(r,file_name,'tif','Compression','none','WriteMode','append');
        catch
            pause(1)
            fprintf('DONORreg Iteration value: %i\n', i);
            imwrite(r,file_name,'tif','Compression','none','WriteMode','append');
        end

    end

    % switch back to old directory
    cd(old_dir);
end

% re-enable all components after saving is complete
set(handles.slider1,'Enable','On');
set(handles.slider2,'Enable','On');
set(handles.slider3,'Enable','On');
set(handles.slider4,'Enable','On');
if handles.num_frames > 1
    set(handles.slider1,'Enable','On');
end
set(handles.radiobutton1,'Enable','On');
set(handles.radiobutton2,'Enable','On');
set(handles.edit1,'Enable','On');
set(handles.edit2,'Enable','On');
set(handles.edit3,'Enable','On');
set(handles.edit8,'Enable','On');
set(handles.popupmenu1,'Enable','On');
set(handles.CLim_Max_Tag1,'Enable','On');
set(handles.CLim_Min_Tag1,'Enable','On');
set(handles.CLim_Max_Tag2,'Enable','On');
set(handles.CLim_Min_Tag2,'Enable','On');
set(handles.save_tag,'Enable','On');
set(handles.uitoggletool1,'Enable','On');
set(handles.uitoggletool2,'Enable','On');
set(handles.uitoggletool3,'Enable','On');
set(handles.playtoggle1,'Enable','On');

guidata(hObject,handles);


%% Play Toggle Callbacks
function playtoggle1_OnCallback(~, ~, handles) %#ok<DEFNU>
pause_time = handles.pausetime/1000;
i = get(handles.slider7,'Value');
frames = get(handles.slider7,'Max');
while 1
    user_data = get(handles.playtoggle1,'UserData');
    if user_data.stop
        user_data.stop = 0;
        set(handles.playtoggle1,'UserData',user_data);
        return;
    end
    set(handles.slider7,'Value',i);
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
