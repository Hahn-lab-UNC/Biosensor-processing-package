function varargout = coefficient_calculator(varargin)
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
% COEFFICIENT_CALCULATOR MATLAB code for coefficient_calculator.fig
%      COEFFICIENT_CALCULATOR, by itself, creates a new COEFFICIENT_CALCULATOR or raises the existing
%      singleton*.
%
%      H = COEFFICIENT_CALCULATOR returns the handle to a new COEFFICIENT_CALCULATOR or the handle to
%      the existing singleton*.
%
%      COEFFICIENT_CALCULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COEFFICIENT_CALCULATOR.M with the given input arguments.
%
%      COEFFICIENT_CALCULATOR('Property','Value',...) creates a new COEFFICIENT_CALCULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before coefficient_calculator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to coefficient_calculator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help coefficient_calculator

% Last Modified by GUIDE v2.5 22-Aug-2016 16:49:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @coefficient_calculator_OpeningFcn, ...
                   'gui_OutputFcn',  @coefficient_calculator_OutputFcn, ...
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


% --- Executes just before coefficient_calculator is made visible.
function coefficient_calculator_OpeningFcn(hObject, ~, handles, varargin)
set(handles.figure1,'Visible','on');
handles.output = 0;

handles.coeffs = struct;
handles.coeffs.alpha = zeros(1,varargin{1}.alpha_pairs);
handles.coeffs.beta = zeros(1,varargin{1}.beta_pairs);

uitable_init(hObject,handles);
guidata(hObject,handles);

handles.aimages = varargin{2};
handles.bimages = varargin{3};
handles.counter_alpha = 1;
handles.counter_beta = 1;

handles.CLim_Max_1 = 1;
handles.CLim_Max_2 = 1;

handles.left_ex = 0;
handles.bottom_ex = 0;
handles.neg_slope_ex = 0;

handles.cur_slope = 0;
handles.cur_rsquare = 0;

handles.fit_toggle = 0;
handles.fit_v = 0;
handles.fit_h = 0;
handles.fit_s = 0;
handles.fit = 0;

guidata(hObject,handles);

update_axes(hObject,handles);

handles = guidata(hObject);
guidata(hObject,handles);

% wait for figure 1 to lose visibility (in pushbutton2 callback)
waitfor(handles.figure1,'Visible','off');


% --- Outputs from this function are returned to the command line.
function varargout = coefficient_calculator_OutputFcn(~, ~, handles)
varargout{1} = handles.coeffs;
delete(handles.figure1);


%% Helper Functions
function update_axes(hObject,handles)
acount = handles.counter_alpha;
bcount = handles.counter_beta;
handles.fit_toggle = 0;
if acount <= length(handles.coeffs.alpha)
    im_donor = handles.aimages{1,2*acount-1};
    im_fret = handles.aimages{1,2*acount};
    
    handles.CLim_Max_1 = max(max(im_donor));
    set(handles.slider1,'Max',handles.CLim_Max_1);
    set(handles.slider1,'Min',1);
    set(handles.slider1,'Value',handles.CLim_Max_1);
    set(handles.CLim_Max_Tag1, 'String', num2str(handles.CLim_Max_1));
    guidata(hObject,handles);
    
    handles.CLim_Max_2 = max(max(im_fret));
    set(handles.slider2,'Max',handles.CLim_Max_2);
    set(handles.slider2,'Min',1);
    set(handles.slider2,'Value',handles.CLim_Max_2);
    set(handles.CLim_Max_Tag2, 'String', num2str(handles.CLim_Max_2));
    guidata(hObject,handles);
    
    set(handles.slider3,'Max',handles.CLim_Max_1);
    set(handles.slider3,'Min',0);
    set(handles.slider3,'Value',0);
    set(handles.slider4,'Max',handles.CLim_Max_2);
    set(handles.slider4,'Min',0);
    set(handles.slider4,'Value',0);
    set(handles.slider5,'Max',handles.CLim_Max_2);
    set(handles.slider5,'Min',0);
    set(handles.slider5,'Value',0);
    guidata(hObject,handles);
    
    set(handles.figure1,'CurrentAxes',handles.axes1);
    handles.fit_v = line('Xdata',[handles.CLim_Max_1 handles.CLim_Max_1],'Ydata',[0 1],'Color','b');
    handles.fit_h = line('Xdata',[0 1],'Ydata',[handles.CLim_Max_2 handles.CLim_Max_2],'Color','b');
    handles.fit_s = line('Xdata',[0 1],'Ydata',[0 -1],'Color','b');
    set(handles.fit_v,'HandleVisibility','off');
    set(handles.fit_h,'HandleVisibility','off');
    set(handles.fit_s,'HandleVisibility','off');
    guidata(hObject,handles);
    
    handles.sl1 = addlistener(handles.slider1,'Value','PostSet',@(src,evnt)slider1(handles.figure1,src,evnt));
    handles.sl2 = addlistener(handles.slider2,'Value','PostSet',@(src,evnt)slider2(handles.figure1,src,evnt));
    handles.sl3 = addlistener(handles.slider3,'Value','PostSet',@(src,evnt)slider3(handles.figure1,src,evnt));
    handles.sl4 = addlistener(handles.slider4,'Value','PostSet',@(src,evnt)slider4(handles.figure1,src,evnt));
    handles.sl5 = addlistener(handles.slider5,'Value','PostSet',@(src,evnt)slider5(handles.figure1,src,evnt));
    guidata(hObject,handles);
    
    if isempty(get(handles.axes2,'Children'))
        set(handles.figure1,'CurrentAxes',handles.axes2);
        imagesc(im_donor,'Parent',handles.axes2);
        set(handles.axes2,'CLim',[0, handles.CLim_Max_1],'XTick',[],'YTick',[],'Box','on'); % set 'handles.axes3' properties
        set(handles.CLim_Max_Tag1, 'String', num2str(handles.CLim_Max_1)); % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
        colormap(gray);
        axis image
        
        set(handles.figure1,'CurrentAxes',handles.axes3);
        imagesc(im_fret,'Parent',handles.axes3);
        set(handles.axes3,'CLim',[0, handles.CLim_Max_2],'XTick',[],'YTick',[],'Box','on'); % set 'handles.axes3' properties
        set(handles.CLim_Max_Tag2, 'String', num2str(handles.CLim_Max_2)); % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
        colormap(gray);
        axis image
    else
        imHandle = findobj(handles.axes2,'Type','image'); % find the 'image' handle in handles.axes3
        set(imHandle,'CData',im_donor);

        imHandle = findobj(handles.axes3,'Type','image'); % find the 'image' handle in handles.axes3
        set(imHandle,'CData',im_fret);
    end
    
    update_plot(hObject,handles,im_donor,im_fret);
    handles = guidata(hObject);
    guidata(hObject,handles);
    clear im_donor im_fret 
    
elseif bcount <= length(handles.coeffs.beta)
    im_acceptor = handles.bimages{1,2*bcount-1};
    im_fret = handles.bimages{1,2*bcount};
    
    handles.CLim_Max_1 = max(max(im_acceptor));
    guidata(hObject,handles);
    set(handles.slider1,'Max',handles.CLim_Max_1);
    set(handles.slider1,'Min',1);
    set(handles.slider1,'Value',handles.CLim_Max_1);
    set(handles.CLim_Max_Tag1, 'String', num2str(handles.CLim_Max_1));
    guidata(hObject,handles);
    
    handles.CLim_Max_2 = max(max(im_fret));
    set(handles.slider2,'Max',handles.CLim_Max_2);
    set(handles.slider2,'Min',1);
    set(handles.slider2,'Value',handles.CLim_Max_2);
    set(handles.CLim_Max_Tag2, 'String', num2str(handles.CLim_Max_2));
    guidata(hObject,handles);
    
    set(handles.slider3,'Max',handles.CLim_Max_1);
    set(handles.slider3,'Min',0);
    set(handles.slider3,'Value',0);
    set(handles.slider4,'Max',handles.CLim_Max_2);
    set(handles.slider4,'Min',0);
    set(handles.slider4,'Value',0);
    set(handles.slider5,'Max',handles.CLim_Max_2);
    set(handles.slider5,'Min',0);
    set(handles.slider5,'Value',0);
    guidata(hObject,handles);
    
    set(handles.figure1,'CurrentAxes',handles.axes1);
    handles.fit_v = line('Xdata',[handles.CLim_Max_1 handles.CLim_Max_1],'Ydata',[0 1],'Color','b');
    handles.fit_h = line('Xdata',[0 1],'Ydata',[handles.CLim_Max_2 handles.CLim_Max_2],'Color','b');
    handles.fit_s = line('Xdata',[0 1],'Ydata',[0 -1],'Color','b');
    set(handles.fit_v,'HandleVisibility','off');
    set(handles.fit_h,'HandleVisibility','off');
    set(handles.fit_s,'HandleVisibility','off');
    guidata(hObject,handles);
    
    if isempty(get(handles.axes2,'Children'))
        set(handles.figure1,'CurrentAxes',handles.axes2);
        imagesc(im_acceptor,'Parent',handles.axes2);
        set(handles.axes2,'CLim',[0, handles.CLim_Max_1],'XTick',[],'YTick',[],'Box','on'); % set 'handles.axes3' properties
        set(handles.CLim_Max_Tag1, 'String', num2str(handles.CLim_Max_1)); % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
        colormap(gray);
        axis image
        
        set(handles.figure1,'CurrentAxes',handles.axes3);
        imagesc(im_fret,'Parent',handles.axes3);
        set(handles.axes3,'CLim',[0, handles.CLim_Max_2],'XTick',[],'YTick',[],'Box','on'); % set 'handles.axes3' properties
        set(handles.CLim_Max_Tag2, 'String', num2str(handles.CLim_Max_2)); % set the edit box 'CLim_Max_Tag' to the current CLim_val 'maximum'
        colormap(gray);
        axis image
    else
        imHandle = findobj(handles.axes2,'Type','image'); % find the 'image' handle in handles.axes3
        set(imHandle,'CData',im_acceptor);

        imHandle = findobj(handles.axes3,'Type','image'); % find the 'image' handle in handles.axes3
        set(imHandle,'CData',im_fret);
    end
    
    update_plot(hObject,handles,im_acceptor,im_fret)
    handles = guidata(hObject);
    guidata(hObject,handles);
    clear im_acceptor im_fret 
end
handles.left_ex = 0;
handles.bottom_ex = 0;
handles.neg_slope_ex = 0;

handles.fit_neg_slope = 0;
guidata(hObject,handles);

function update_plot(hObject,handles,im_x,im_fret)
im_size = size(im_x);
array_size = im_size(1)*im_size(2);
x = double(reshape(im_x,array_size,1));
y = double(reshape(im_fret,array_size,1));

if handles.fit_toggle == 0
    outliers = excludedata(x, y, 'box', [1 inf 1 inf]);
    opts = fitoptions('method','NonlinearLeastSquares','StartPoint',0.3);
    ftype = fittype('slope*x','coefficients','slope','options',opts);

    [fitobject,gof] = fit(x,y,ftype,'exclude',outliers);
    handles.cur_slope = fitobject.slope;
    handles.cur_rsquare = gof.rsquare;
    
    set(handles.text8,'String',sprintf('Slope: %.3f   r^2: %.3f',handles.cur_slope,handles.cur_rsquare));
    set(handles.text2,'String',sprintf('Current Value: %.3f',handles.cur_slope));
    
    set(handles.figure1,'CurrentAxes',handles.axes1);
    hold on
    plot(x,y,'r.');
    handles.fit = plot(x,fitobject(x),'k-');
    xlim([0 get(handles.slider1,'Max')+500]);
    ylim([0 get(handles.slider2,'Max')+500]);
    xlabel('Current Channel Intensities');
    ylabel('Current FRET Bleedthrough Intensities'); 
    legend('Fitted Data','Linear Fit of Included Data');
    
    handles.fit_toggle = 1;
    guidata(hObject,handles);
    
else
    out_indices = find( x < handles.left_ex |...
        y < handles.bottom_ex | y < ((-1*handles.cur_slope*x)+handles.neg_slope_ex));
    
    if length(out_indices) == array_size
        msgbox('Must include at least 1 data point to fit line.', 'Error','error');
        return;
    end
    
    outliers = excludedata(x,y,'indices',out_indices);  % sets fit exclusion data
    opts = fitoptions('method','NonlinearLeastSquares','Robust','off','StartPoint',0.5);
    ftype = fittype('slope*x','coefficients','slope','options',opts);

    [fitobject,gof] = fit(x,y,ftype,'exclude',outliers);
    handles.cur_slope = fitobject.slope;
    handles.cur_rsquare = gof.rsquare;
    
    set(handles.text8,'String',sprintf('Slope: %.3f   r^2: %.3f',handles.cur_slope,handles.cur_rsquare));
    set(handles.text2,'String',sprintf('Current Value: %.3f',handles.cur_slope));

    set(handles.figure1,'CurrentAxes',handles.axes1);
    set(handles.fit,'YData',fitobject(x));
    guidata(hObject,handles);
    
end

function uitable_init(hObject,handles)
a_rows = length(handles.coeffs.alpha);
b_rows = length(handles.coeffs.beta);
max_rows = max([a_rows b_rows]);
data = zeros(max_rows,2);
set(handles.uitable1,'Data',data);
guidata(hObject,handles);


%#ok<*DEFNU>
%% Listener Functions
function slider1(hObject, ~, ~)
handles = guidata(hObject);
set(handles.figure1,'CurrentAxes',handles.axes2);
set(handles.axes2,'CLim',[0,get(handles.slider1,'Value')]);
handles.CLim_Max_1 = get(handles.slider1,'Value');
set(handles.CLim_Max_Tag1,'String',num2str(get(handles.slider1,'Value')));
guidata(hObject, handles);
function slider2(hObject, ~, ~)
handles = guidata(hObject);
set(handles.figure1,'CurrentAxes',handles.axes3);
set(handles.axes3,'CLim',[0,get(handles.slider2,'Value')]);
handles.CLim_Max_2 = get(handles.slider2,'Value');
set(handles.CLim_Max_Tag2,'String',num2str(get(handles.slider2,'Value')));
guidata(hObject, handles);
function slider3(hObject, ~, event)
handles = guidata(hObject);
v = round(event.AffectedObject.Value);
set(handles.figure1,'CurrentAxes',handles.axes1)
lim = get(handles.axes1,'YLim');
set(handles.fit_v,'Xdata',[v v],'Ydata',lim)
handles.left_ex = v;
guidata(hObject,handles);
function slider4(hObject, ~, event)
handles = guidata(hObject);
h = round(event.AffectedObject.Value);
set(handles.figure1,'CurrentAxes',handles.axes1)
lim = get(handles.axes1,'XLim');
set(handles.fit_h,'Xdata',lim,'Ydata',[h h])
handles.bottom_ex = h;
guidata(hObject,handles);
function slider5(hObject, ~, event)
handles = guidata(hObject);
intercept = round(event.AffectedObject.Value);
set(handles.figure1,'CurrentAxes',handles.axes1)
lim = get(handles.axes1,'XLim');
set(handles.fit_s,'Xdata',[0 lim],'Ydata',[intercept (-1*handles.cur_slope*lim)+intercept]);
handles.neg_slope_ex = intercept;
guidata(hObject,handles);


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
function slider4_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function slider5_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider1_Callback(~, ~, ~)
function slider2_Callback(~, ~, ~)
function slider3_Callback(~, ~, ~)
function slider4_Callback(~, ~, ~)
function slider5_Callback(~, ~, ~)


%% CLim Edit Boxes
function CLim_Max_Tag1_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function CLim_Max_Tag2_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CLim_Max_Tag1_Callback(hObject, ~, handles)
handles.CLim_Max_1 = str2double(get(hObject,'String'));
set(handles.axes2,'CLim',[0, handles.CLim_Max_1]);
guidata(hObject,handles);
function CLim_Max_Tag2_Callback(hObject, ~, handles)
handles.CLim_Max_2 = str2double(get(hObject,'String'));
set(handles.axes3,'CLim',[0, handles.CLim_Max_2]);
guidata(hObject,handles);


%% Push Buttons
function pushbutton1_Callback(hObject, ~, handles)
% recalculate fit
im_x_handle = findobj(handles.axes2,'Type','image');
im_x = getimage(im_x_handle);

im_fret_handle = findobj(handles.axes3,'Type','image');
im_fret = getimage(im_fret_handle);

update_plot(hObject,handles,im_x,im_fret);
handles = guidata(hObject);
guidata(hObject,handles);


%% Continue Button & Close Function
function pushbutton2_Callback(hObject, ~, handles)
acount = handles.counter_alpha;
bcount = handles.counter_beta;

if acount <= length(handles.coeffs.alpha)
    handles.coeffs.alpha(acount) = handles.cur_slope;
    handles.counter_alpha = acount + 1;
    
    % add value to table
    data = get(handles.uitable1,'Data');
    data(acount,1) = handles.cur_slope;
    set(handles.uitable1,'Data',data);

    % calculate new alpha average
    alpha_avg = mean(data([1,acount],1));
    str = sprintf('Current Alpha Average: %.3f\n\nCurrent Beta Average:',alpha_avg);
    set(handles.text3,'String',str);
    
    % update string above images if done with alpha calculations
    if handles.counter_alpha > length(handles.coeffs.alpha)
        set(handles.text6,'String','Acceptor Emission:');
    end    
    
    guidata(hObject,handles);
    % upload new data
    set(handles.figure1,'CurrentAxes',handles.axes1);
    hold off
    cla;
    update_axes(hObject,handles);
    
elseif bcount <= length(handles.coeffs.beta)
    handles.coeffs.beta(bcount) = handles.cur_slope;
    handles.counter_beta = bcount + 1;
    
    % add value to table
    data = get(handles.uitable1,'Data');
    data(bcount,2) = handles.cur_slope;
    set(handles.uitable1,'Data',data);

    % calculate new beta average
    alpha_avg = mean(data(:,1));
    beta_avg = mean(data([1,bcount],2));
    str = sprintf('Current Alpha Average: %.3f\n\nCurrent Beta Average: %.3f',alpha_avg,beta_avg);
    set(handles.text3,'String',str);
    
    guidata(hObject,handles);
    % upload new data
    set(handles.figure1,'CurrentAxes',handles.axes1);
    hold off
    cla;
    if bcount < length(handles.coeffs.beta)
        update_axes(hObject,handles);
    else
        set(handles.pushbutton1,'Enable','off');
        set(handles.CLim_Max_Tag1,'Enable','off');
        set(handles.CLim_Max_Tag2,'Enable','off');
        set(handles.slider1,'Enable','off');
        set(handles.slider2,'Enable','off');
        set(handles.slider3,'Enable','off');
        set(handles.slider4,'Enable','off');
        set(handles.slider5,'Enable','off');
        set(handles.pushbutton2,'String','Continue to Next Step');
    end
else
    guidata(hObject,handles);
    set(handles.figure1,'Visible','off');
end

function figure1_CloseRequestFcn(hObject, ~, handles)
choice = questdlg('Exiting will discontinue bleedthrough correction calculations and all progress will be lost. Are you sure you wish to exit?', ...
	'Exit Warning',...
    'Exit','Continue Calculations','Continue Calculations');
switch choice
    case 'Exit'
        close = 1;
    case 'Continue Calculations'
        close = 0;
end

if close == 0
    return
else
    handles.coeffs = 0;
    guidata(hObject,handles);
    set(handles.figure1,'Visible','off');
end
