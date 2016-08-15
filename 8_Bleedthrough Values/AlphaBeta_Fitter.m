function varargout = AlphaBeta_Fitter(varargin)
% ALPHABETA_FITTER MATLAB code for AlphaBeta_Fitter.fig
%      ALPHABETA_FITTER, by itself, creates a new ALPHABETA_FITTER or raises the existing
%      singleton*.
%
%      H = ALPHABETA_FITTER returns the handle to a new ALPHABETA_FITTER or the handle to
%      the existing singleton*.
%
%      ALPHABETA_FITTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALPHABETA_FITTER.M with the given input arguments.
%
%      ALPHABETA_FITTER('Property','Value',...) creates a new ALPHABETA_FITTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AlphaBeta_Fitter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AlphaBeta_Fitter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AlphaBeta_Fitter

% Last Modified by GUIDE v2.5 21-Jul-2015 13:06:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AlphaBeta_Fitter_OpeningFcn, ...
                   'gui_OutputFcn',  @AlphaBeta_Fitter_OutputFcn, ...
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

% --- Executes just before AlphaBeta_Fitter is made visible.
function AlphaBeta_Fitter_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to AlphaBeta_Fitter (see VARARGIN)
    handles.option = 'range';
    javaaddpath('ImageProcessingSrc.jar');
    import i_o.*;
    import data_mining_and_statistics.*;
    handles.cfp_file = 0;
    handles.yfp_file = 0;

    % Choose default command line output for AlphaBeta_Fitter
    handles.output = hObject;
    set(handles.axes3,'XTick',[],'YTick',[]);
    title(handles.axes3,'CFP in CFP channel');
    set(handles.axes4,'XTick',[],'YTick',[]);
    title(handles.axes4,'FRET in CFP  channel');
    set(handles.axes5,'XTick',[],'YTick',[]);
    title(handles.axes5,'YFP in YFP channel');
    set(handles.axes6,'XTick',[],'YTick',[]);
    title(handles.axes6,'FRET in YFP  channel');
    setForegroundColor([handles.text10],[.3,.3,.3]);
    colormap('jet');
    % Global variables
    handles.lnsx1=0;
    handles.lnsy1=0;
    handles.linex1=0;
    handles.liney1=0;
    handles.Ccount=1;
    handles.Ycount=1;
    toggleEnabled([handles.add1,handles.add2,handles.file],'off');
    handles.CFPdata=[];
    handles.YFPdata=[];
    % Update handles structure
    guidata(hObject, handles);
    % UIWAIT makes AlphaBeta_Fitter wait for user response (see UIRESUME)
    uiwait(handles.figure1);

function varargout = AlphaBeta_Fitter_OutputFcn(hObject, eventdata, handles) 
    % Get default command line output from handles structure
    varargout{1} = getGlobalALPHA;

%---------------listener functions---------
function changex(hObject, src, event,handleV)
    handles = guidata(hObject);
    sliderNumber = round(event.AffectedObject.Value);
    y=round(get(handleV(1),'Value'));
    a=['[0, ' num2str(sliderNumber) ', 0, ' num2str(y) ']'];
    set(handleV(2),'String',a);
    b=get(handleV(3),'YLim');
    set(handleV(4),'Xdata',[sliderNumber,sliderNumber],'Ydata',b);
    axes(handleV(3));
    hold on;
    plot(handleV(4));
    guidata(hObject, handles);

function changey(hObject, src, event,handleV)
    handles = guidata(hObject);
    sliderNumber = round(event.AffectedObject.Value);
    x=round(get(handleV(1),'Value'));
    a=['[0, ' num2str(x) ', 0, ' num2str(sliderNumber) ']'];
    set(handleV(2),'String',a);
    a=get(handleV(3),'XLim');
    set(handleV(4),'Xdata',a,'Ydata',[sliderNumber,sliderNumber]);
    axes(handleV(3));
    hold on;
    plot(handleV(4));
    guidata(hObject, handles);

%---------------button functions----------
function load_cfp_tag_Callback(hObject, eventdata, handles)
    toggleEnabled([handles.load_yfp_tag,handles.edit9],'off');
    setForegroundColor([handles.text10],[.3,.3,.3]);
    NumCentroids = 4;
    if handles.cfp_file 
        CCCNAMEIN = handles.cfp_file;
        [path,name,ext] = fileparts(handles.cfp_file);
        name = strrep(name,'CFP','CFPFRET');
        CCFNAMEIN = [path filesep name ext];
        path = [path filesep];
    else
        [file,path,findex] = uigetfile('*.tif','Select the CFP emission image');
        if findex==0
            return;
        end
        CCCNAMEIN = [path file];
        [file,path,findex] = uigetfile('*.tif','Select the FRET emission of CFP image');
        if findex==0
            return;
        end
        CCFNAMEIN = [path file];
    end
    CCCImage = imread(CCCNAMEIN, 'tif');
    CCFImage = imread(CCFNAMEIN, 'tif');
    try
        CCCShade = imread([path 'CFPshade.tif'], 'tif');
    catch
        warndlg({'Shade image ''CFPshade.tif'' is not found.';'No shade correction of the CFP channel.'},'Shade correction','modal');
        uiwait;
        CCCShade = 1000+0*CCCImage;
    end    
    try
        CCFShade = imread([path 'FRETshade.tif'],'tif');
    catch
        warndlg({'Shade image ''FRETshade.tif'' is not found.';'No shade correction of the FRET channel.'},'Shade correction','modal');
        uiwait;
        CCFShade = 1000+0*CCFImage;
    end    
    guidata(hObject,handles);
    handles.ctpData={CCCImage,CCFImage,CCCShade,CCFShade,4};
    [CCCarray,CCFarray,fresult,gof] = processImages(CCCImage,CCFImage,CCCShade,CCFShade,NumCentroids,handles,1);
    handles.CCCarr=CCCarray;
    handles.CCFarr=CCFarray;
    
    if CCCarray == -1
        return;
    end
    aaa=num2str(fresult.a,'%.3f'); rsq=num2str(gof.rsquare,'%.3f');
    
    % Extracting alpha value to return on closure of GUI
    setGlobalALPHA(aaa);
    
    coef=sprintf('a = %s', aaa);
    coef3=sprintf('r^2 = %s', rsq);
    handles.CFPa=fresult.a;
    handles.CFPr=gof.rsquare;
    handles.exclusion=get(handles.edit8,'String');
    set(handles.alpha_text,'String',[coef ', ' coef3]);
    axes(handles.axes1);
    cla;
    hold on;
    plot(CCCarray, CCFarray,'r.', CCCarray, fresult(CCCarray),'b-');   % Plots results
    %title('Linear fit to get Alpha factor');
    %xlabel('CFP-C-CFP Intensity');
    %ylabel('CFP-C-FRET Bleedthrough Intensity');
    hold off;
    toggleEnabled([handles.edit8],'off');
    toggleEnabled([handles.load_yfp_tag,handles.x1,handles.y1,handles.pushbutton4],'on');
    setForegroundColor([handles.text10],[0,0,0]);
    handles.cfp_file = 0;
    ylim=get(handles.axes1,'YLim');
    xlim=get(handles.axes1,'XLim');
    set(handles.x1,'Max',xlim(2));
    set(handles.y1,'Max',ylim(2));
    set(handles.y1,'Value',ylim(2));
    set(handles.x1,'Value',xlim(2));
    handles.linex1=line('Xdata',[xlim(2),xlim(2)],'Ydata',[0,1]);
    handles.liney1=line('Xdata',[0,1],'Ydata',[ylim(2),ylim(2)]);
    set(handles.linex1,'HandleVisibility','off');
    set(handles.liney1,'HandleVisibility','off');
    guidata(hObject,handles);
    handles.lnsx1=addlistener(handles.x1, 'Value', 'PostSet', @(src, event)changex(hObject, src, event,[handles.y1,handles.edit8,handles.axes1,handles.linex1]));
    handles.lnsy1=addlistener(handles.y1, 'Value', 'PostSet', @(src, event)changey(hObject, src, event,[handles.x1,handles.edit8,handles.axes1,handles.liney1]));
    set(handles.add1,'Enable','on');
    guidata(hObject,handles);

function load_yfp_tag_Callback(hObject, eventdata, handles)
    NumCentroids = 4;
    if handles.yfp_file
        YYYNAMEIN = handles.yfp_file;
        [path,name,ext] = fileparts(handles.yfp_file);
        name = strrep(name,'YFP','YFPFRET');
        CYFNAMEIN = [path filesep name ext];
        path = [path filesep];
    else
        [file,path,findex] = uigetfile('*.tif','Select the YFP emission image');
        if findex==0
            return;
        end
        YYYNAMEIN = [path file];
        [file,path,findex] = uigetfile('*.tif','Select the FRET emission image for YFP cell');
        if findex==0
            return;
        end
        CYFNAMEIN = [path file];
    end
    YYYImage = imread(YYYNAMEIN,'tif');
    CYFImage = imread(CYFNAMEIN,'tif');
    try
        YYYshade = imread([path 'YFPshade.tif'],'tif');
    catch
        warndlg({'Shade image ''YFPshade.tif'' is not found.';'No shade correction of the YFP channel.'},'Shade correction','modal');
        uiwait;
        YYYshade = 1000+0*YYYImage;
    end
    try    
        CYFshade = imread([path 'FRETshade.tif'],'tif');
    catch
        warndlg({'Shade image ''FRETshade.tif'' is not found.';'No shade correction of the FRET channel.'},'Shade correction','modal');
        uiwait;
        CYFshade = 1000+0*CYFImage;
    end    
        
    handles.exclusion = get(handles.edit9,'String');
    guidata(hObject,handles);
    handles.yfpData={YYYImage,CYFImage,YYYshade,CYFshade,4};
    [YYYarray,CYFarray,fresult,gof] = processImages(YYYImage,CYFImage,YYYshade,CYFshade,NumCentroids,handles,0);
    handles.YYYarr=YYYarray;
    handles.CYFarr=CYFarray;
    
    if YYYarray == -1
        return;
    end
    handles.YFPa=num2str(fresult.a,'%.3f'); rsq=num2str(gof.rsquare,'%.3f');
    coef=sprintf('b = %s', handles.YFPa);
    coef3=sprintf('r^2 = %s', rsq);
    handles.YFPa=fresult.a;
    handles.YFPr=gof.rsquare;
    handles.exclusion=get(handles.edit9,'String');
    set(handles.beta_text,'String',[coef ', ' coef3]);
    axes(handles.axes2);
    cla;
    hold on;
    plot(YYYarray, CYFarray,'r.', YYYarray, fresult(YYYarray),'b-');   % Plots results
    %title('Linear fit to get Beta factor');
    %xlabel('YFP-Y-YFP Intensity');
    %ylabel('CFP-Y-FRET Bleedthrough Intensity');
    hold off;
    set(handles.text10,'ForegroundColor',[.3,.3,.3]);
    toggleEnabled([handles.load_cfp_tag,handles.x2,handles.y2,handles.pushbutton5],'on');
    toggleEnabled([handles.edit9],'off');
    a=get(handles.axes2,'XLim');
    b=get(handles.axes2,'YLim');
    set(handles.x2,'Max',a(2));
    set(handles.y2,'Max',b(2));
    handles.linex2=line('Xdata',[a(2),a(2)],'Ydata',[0,1]);
    handles.liney2=line('Xdata',[0,1],'Ydata',[b(2),b(2)]);
    set(handles.linex2,'HandleVisibility','off');
    set(handles.liney2,'HandleVisibility','off');
    set(handles.x2,'Value',a(2));
    set(handles.y2,'Value',b(2));
    guidata(hObject,handles);
    handles.lnsx1=addlistener(handles.x2, 'Value', 'PostSet', @(src, event)changex(hObject, src, event,[handles.y2,handles.edit9,handles.axes2,handles.linex2]));
    handles.lnsy1=addlistener(handles.y2, 'Value', 'PostSet', @(src, event)changey(hObject, src, event,[handles.x2,handles.edit9,handles.axes2,handles.liney2]));
    set(handles.add2,'Enable','on');
    guidata(hObject,handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)    
    handles = guidata(hObject);
    %[CCCarray,CCFarray,fresult,gof] = processImages(handles.ctpData{1},handles.ctpData{2},handles.ctpData{3},handles.ctpData{4},handles.ctpData{5},handles,1);
    CCCarray=handles.CCCarr;
    CCFarray=handles.CCFarr;
    handles.exclusion=get(handles.edit8,'String');
    
    outliers = excludedata(CCCarray, CCFarray, 'Box', eval(handles.exclusion));  % sets fit exclusion range in Y values
    opts = fitoptions('method','NonlinearLeastSquares','Robust','off','StartPoint',0.4);
    ftype = fittype('a*x','coefficients','a','options',opts);

    [fresult,gof] = fit(CCCarray, CCFarray, ftype, 'exclude', outliers);        % double exponential fit, Plane numbers as X and normalized Ratio as Y
    display (fresult);                  % displays fitted parameters and coefficients
    display (gof);                      % displays goodness of fit parameters
        
    if CCCarray == -1
        return;
    end
    aaa=num2str(fresult.a,'%.3f'); rsq=num2str(gof.rsquare,'%.3f');
    
    % Extracting alpha value to return on closure of GUI
    setGlobalALPHA(aaa);    
    
    handles.CFPa=fresult.a;
    handles.CFPr=gof.rsquare;
    
    coef=sprintf('a = %s', aaa);
    coef3=sprintf('r^2 = %s', rsq);
    set(handles.alpha_text,'String',[coef ', ' coef3]);
    x=get(handles.x1,'Value');
    y=get(handles.y1,'Value');
    axes(handles.axes1);
    cla;
    hold on;
    %handles.linex2=line('Xdata',[x, x],'Ydata',[0,1]);
    %handles.liney2=line('Xdata',[0,1],'Ydata',[y,y]);
    plot(CCCarray, CCFarray,'r.', CCCarray, fresult(CCCarray),'b-');   % Plots results
    %title('Linear fit to get Alpha factor');
    %xlabel('CFP-C-CFP Intensity');
    %ylabel('CFP-C-FRET Bleedthrough Intensity');
    hold off;
    toggleEnabled([handles.load_cfp_tag,handles.edit8],'off');
    toggleEnabled([handles.load_yfp_tag],'on');
    setForegroundColor([handles.text10],[0,0,0]);
    handles.cfp_file = 0;
    set(handles.add1,'Enable','on');
    guidata(hObject,handles);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)    
    handles = guidata(hObject);
    %[YYYarray,CYFarray,fresult,gof] = processImages(handles.yfpData{1},handles.yfpData{2},handles.yfpData{3},handles.yfpData{4},handles.yfpData{5},handles,0);
    YYYarray=handles.YYYarr;
    CYFarray=handles.CYFarr;
    handles.exclusion=get(handles.edit9,'String');
    
    outliers = excludedata(YYYarray, CYFarray, 'Box', eval(handles.exclusion));  % sets fit exclusion range in Y values
    opts = fitoptions('method','NonlinearLeastSquares','Robust','off','StartPoint',0.4);
    ftype = fittype('a*x','coefficients','a','options',opts);

    [fresult,gof] = fit(YYYarray, CYFarray, ftype, 'exclude', outliers);        % double exponential fit, Plane numbers as X and normalized Ratio as Y
    display (fresult);                  % displays fitted parameters and coefficients
    display (gof);                      % displays goodness of fit parameters
    
    if YYYarray == -1
        return;
    end

    handles.YFPa=num2str(fresult.a,'%.3f'); rsq=num2str(gof.rsquare,'%.3f');
    coef=sprintf('b = %s', handles.YFPa);
    coef3=sprintf('r^2 = %s', rsq);
    handles.YFPa=fresult.a;
    handles.YFPr=gof.rsquare;
    
    set(handles.beta_text,'String',[coef ', ' coef3]);
    axes(handles.axes2);
    cla;
    hold on;
    plot(YYYarray, CYFarray,'r.', YYYarray, fresult(YYYarray),'b-');   % Plots results
    %title('Linear fit to get Beta factor');
    %xlabel('YFP-Y-YFP Intensity');
    %ylabel('CFP-Y-FRET Bleedthrough Intensity');
    hold off;
    set(handles.text10,'ForegroundColor',[.3,.3,.3]);
    toggleEnabled([handles.load_cfp_tag,handles.add2],'on');
    guidata(hObject,handles);

%--- helper functions
function [CCCarray,CCFarray,fresult,gof] = processImages(CCCImage,CCFImage,CCCShade,CCFShade,NumCentroids,handles,no)
    %%%D=1; %input('Enter duration:	');
    %%%lead0=ceil(log10(D+1));

    % input initial condition:
    % c=[2000;20000;34500;59748]; %input('Enter centers, e.g. [2;30]:	');
    % c=double(c);

    CCCShade(CCCShade==0)=1;
    CCFShade(CCFShade==0)=1;

    last_slim1=[0.0157;0.0196];
    last_slim2=last_slim1;

    aa1=CCCImage;
    aa2=CCFImage;
    if size(aa1)~=size(aa2)
        error('Image sizes don''t match.')
    end
    % shade correct:
    sh1=double(aa1)*1000./double(CCCShade);
    sh2=double(aa2)*1000./double(CCFShade);
    aa1=uint16(sh1);
    aa2=uint16(sh2);
    if no==1
        axes(handles.axes3)
        %imagesc(aa1);
        imagesc(CCCImage);
        axis image;
        axes(handles.axes4)
        %imagesc(aa2);
        imagesc(CCFImage);
        axis image;
        set(handles.axes3,'XTick',[],'YTick',[]);
        title(handles.axes3,'CFP in CFP channel');
        set(handles.axes4,'XTick',[],'YTick',[]);
        title(handles.axes4,'FRET in CFP  channel');
        handles.exclusion=get(handles.edit8,'String');    

    else
        axes(handles.axes5)
        %imagesc(aa1);
        imagesc(CCCImage);
        axis image;
        axes(handles.axes6)
        %imagesc(aa2);
        imagesc(CCFImage);
        axis image;
        set(handles.axes5,'XTick',[],'YTick',[]);
        title(handles.axes5,'YFP in YFP channel');
        set(handles.axes6,'XTick',[],'YTick',[]);
        title(handles.axes6,'FRET in YFP  channel');
        handles.exclusion=get(handles.edit9,'String');
    end
    pause(.4);
    % thresholding based on clustering:
    % contrast enhancing:
    slim1=round(stretchlim(aa1)*100000)/100000; % round to patch another
    slim2=round(stretchlim(aa2)*100000)/100000; % glitch in MATLAB
    if ((slim1(1)==0 && slim1(2)==1) || (slim2(1)==0 && slim2(2)==1))% patching a glitch in MATLAB
        lhin1=last_slim1;
        lhin2=last_slim2;
    else
        lhin1=slim1;
        lhin2=slim2;
        last_slim1=slim1;
        last_slim2=slim2;
    end

    fv1=imadjust(aa1,lhin1,[0 1]);
    fv2=imadjust(aa2,lhin2,[0 1]);
    fv1=double(fv1);
    fv2=double(fv2);

    %options=zeros(1,15);
    %options(2)=5;
    %options(3)=1;
    %options(14)=120;
    try
        [idx,centers1]=kmeans(fv1(:),NumCentroids,'emptyaction','singleton');
        [idx2,centers2]=kmeans(fv2(:),NumCentroids,'emptyaction','singleton');
    catch
        warndlg({'kmeans clustering failed, try again'});
        CCCarray = -1;
        CCFarray = -1;
        fresult = -1;
        gof = -1;
        return;
    end
    % kmeans = data_mining_and_statistics.KMeansContainer(fv1(:),NumCentroids);
    % idx = kmeans.getClusterMap;
    % temp = kmeans.getCentroids;
    % centers1 = zeros(1,length(temp));
    % for i = 1:length(temp)
    %     centers1(i) = temp(i).getVector;
    % end
    % kmeans.resetPointSet(fv2(:));
    % idx2 = kmeans.getClusterMap;
    % temp = kmeans.getCentroids;
    % centers2 = zeros(1,length(temp));
    % for i = 1:length(temp)
    %     centers2(i) = temp(i).getVector;
    % end
    centers1;
    centers2;
    [id,jd]=size(aa1);
    % assign correct brightness
    [~, ind]=sort(centers1);
    picc1=zeros(id,jd);
    temp = reshape(idx,id,jd);
    for i=1:NumCentroids
        picc1(temp==ind(i))=i-1;
    end
    backgnd1=reshape(idx==ind(1), id,jd);
    if no==1
        axes(handles.axes3);
    else
        axes(handles.axes5);
    end
    imagesc(temp);
    axis image;
    axis off;

    [~, ind]=sort(centers2);
    picc2=zeros(id,jd);
    temp2=reshape(idx2,id,jd);
    for i=1:NumCentroids
        picc2(temp2==ind(i))=i-1;
    end
    backgnd2=reshape(idx2==ind(1), id,jd);
    if no==1
        axes(handles.axes4);
    else
        axes(handles.axes6);
    end
    imagesc(temp2);
    axis image;

    pause(1)
    set(handles.axes3,'XTick',[],'YTick',[]);
    title(handles.axes3,'CFP in CFP channel');
    set(handles.axes4,'XTick',[],'YTick',[]);
    title(handles.axes4,'FRET in CFP  channel');
    set(handles.axes5,'XTick',[],'YTick',[]);
    title(handles.axes5,'YFP in YFP channel');
    set(handles.axes6,'XTick',[],'YTick',[]);
    title(handles.axes6,'FRET in YFP  channel');

    picc1(picc1>0)=255;
    picc2(picc2>0)=255;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % background subtraction
    aa1=double(aa1);
    back1=aa1.*backgnd1;
    backavg1=sum(sum(back1)) / sum(sum(backgnd1));
    aa1=aa1-backavg1;
    aa1(aa1<=0)=0;
    aa2=double(aa2);
    back2=aa2.*backgnd2;
    backavg2=sum(sum(back2)) / sum(sum(backgnd2));
    aa2=aa2-backavg2;
    aa2(aa2<=0)=0;
    %%%%%%%%%%%%%%%%%%%%%%%%%
    combbnd=(1-backgnd1).*(1-backgnd2);
    
    %lims = eval(handles.exclusion);
    %xLim = lims(1:2);
    %yLim = lims(3:4);
    if no==1
        axes(handles.axes3);
    else
        axes(handles.axes5);
    end
    %im1 = aa1;
    %im1(im1 < xLim(1)) = xLim(1);
    %im1(im1 > xLim(2)) = xLim(2);
    im1=double(CCCImage).*combbnd;
    im1=im1-min(im1(im1>0));
    im1(im1<0)=0;
    imagesc(im1);
    axis image;
    if no==1
        axes(handles.axes4);
    else
        axes(handles.axes6);
    end
    %im2 = aa2;
    %im2(im2 < yLim(1)) = yLim(1);
    %im2(im2 > yLim(2)) = yLim(2);
    im2=double(CCFImage).*combbnd;
    im2=im2-min(im2(im2>0));
    im2(im2<0)=0;
    imagesc(im2);
    axis image;
    set(handles.axes3,'XTick',[],'YTick',[]);
    title(handles.axes3,'CFP in CFP channel');
    set(handles.axes4,'XTick',[],'YTick',[]);
    title(handles.axes4,'FRET in CFP  channel');
    set(handles.axes5,'XTick',[],'YTick',[]);
    title(handles.axes5,'YFP in YFP channel');
    set(handles.axes6,'XTick',[],'YTick',[]);
    title(handles.axes6,'FRET in YFP  channel');
    pause(.4);
    
    CCCarray = reshape(aa1,numel(aa1),1);
    CCFarray = reshape(aa2,numel(aa2),1);
    
    outliers = excludedata(CCCarray, CCFarray, 'Box', eval(handles.exclusion));  % sets fit exclusion range in Y values
    opts = fitoptions('method','NonlinearLeastSquares','Robust','off','StartPoint',0.4);
    ftype = fittype('a*x','coefficients','a','options',opts);

    [fresult,gof] = fit(CCCarray, CCFarray, ftype, 'exclude', outliers);        % double exponential fit, Plane numbers as X and normalized Ratio as Y
    display (fresult);                  % displays fitted parameters and coefficients
    display (gof);                      % displays goodness of fit parameters

function toggleEnabled(handleV,enable)
    for i = 1:length(handleV)
        set(handleV(i),'Enable',enable);
    end

function setForegroundColor(handleV,color)
    for i=1:length(handleV)
        set(handleV(i),'ForegroundColor',color);
    end

function setGlobalALPHA(val)
global alpha
alpha = val;

function r = getGlobalALPHA
global alpha
r = alpha;
    
%--- editbox callbacks
function edit1_Callback(hObject, eventdata, handles)

function edit2_Callback(hObject, eventdata, handles)

function edit6_Callback(hObject, eventdata, handles)
    s = get(hObject,'String');
    out = regexp(s,'^\s*\[\s*(\d+|-?inf)\s*(,|\s)\s*(\d+|-?inf)\s*\]\s*$','ONCE');
    if ~isempty(out)
        set(handles.axes2,'XLim',eval(s))
    end
    
function edit7_Callback(hObject, eventdata, handles)
    s = get(hObject,'String');
    out = regexp(s,'^\s*\[\s*(\d+|-?inf)\s*(,|\s)\s*(\d+|-?inf)\s*\]\s*$','ONCE');
    if ~isempty(out)
        set(handles.axes2,'YLim',eval(s))
    end
    
function edit4_Callback(hObject, eventdata, handles)
    s = get(hObject,'String');
    out = regexp(s,'^\s*\[\s*(\d+|-?inf)\s*(,|\s)\s*(\d+|-?inf)\s*\]\s*$','ONCE');
    if ~isempty(out)
        set(handles.axes1,'XLim',eval(s))
    end
    
function edit5_Callback(hObject, eventdata, handles)
    s = get(hObject,'String');
    out = regexp(s,'^\s*\[\s*(\d+|-?inf)\s*(,|\s)\s*(\d+|-?inf)\s*\]\s*$','ONCE');
    if ~isempty(out)
        set(handles.axes1,'YLim',eval(s))
    end

%--- Create Functions
function edit2_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit6_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit4_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function edit5_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit7_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function popupmenu1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function popupmenu2_CreateFcn(hObject, eventdata, handles)    
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

%--- radiobutton handlers
function uipanel3_SelectionChangeFcn(hObject, eventdata, handles)    
    if (eventdata.NewValue == handles.range_option)
        handles.option = 'range';
    elseif (eventdata.NewValue == handles.box_option)
        handles.option = 'box';
    else 
        handles.option = 'domain';
    end
    guidata(hObject,handles);

function popupmenu1_Callback(hObject, eventdata, handles)    
    contents = cellstr(get(hObject,'String'));
    if isempty(contents{get(hObject,'Value')})
        return;
    end
    handles.cfp_file = contents{get(hObject,'Value')};
    guidata(hObject,handles);
    
function popupmenu2_Callback(hObject, eventdata, handles)
    contents = cellstr(get(hObject,'String'));
    if isempty(contents{get(hObject,'Value')})
        return;
    end
    handles.yfp_file = contents{get(hObject,'Value')};
    guidata(hObject,handles);

%--- Menu callbacks
function Tools_Tag_Callback(hObject, eventdata, handles)
    
function Find_Cells_Tag_Callback(hObject, eventdata, handles)
    choice = questdlg('What channel?', ...
        'Channel Select', ...
        'CFP','YFP','Cancel','Cancel');
    % Handle response
    cfp = 0;
    switch choice
        case 'CFP'
            cfp  = 1;
        case 'YFP'
            cfp = 0;
        case 'Cancel'
            return
    end
    folder_name = uigetdir('~','Select the directory for batch processing');
    prompt = {['Enter a regular expression.  For Example file[0-9]*.tif matches any tif file with name "file" followed by ' ...
        'any number.  "." matches any character.  [a-b] matches any character from a to b.'...
        'r* matches the expression r 0 or more times.  r+ matches it 1 or more times.']};
    dlg_title = 'Input filters';
    num_lines = 1;
    def = {'.*.tif'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if (~isempty(answer))
        regexp = ['\A.*' answer{1} '\z'];
    else
        return;
    end
    ffinder = i_o.FileFinder(folder_name,regexp);
    matches = ffinder.find;
    display = cell(size(matches,1),1);
    if size(matches,1) == 0
        warndlg({'No files matched that regular expression.  Try another one.'});
        return;
    end
    for i = 1:size(matches,1)
        display{i} = char(matches(i));
    end
    if cfp
        set(handles.popupmenu1,'String',char(display));
    else
        set(handles.popupmenu2,'String',char(display));
    end
    guidata(hObject,handles);

function Help_Tag_Callback(hObject, eventdata, handles)
        
function RegEx_Help_Tag_Callback(hObject, eventdata, handles)
    open('RegEx_Primer.pdf');

function Image_Split_Tag_Callback(hObject, eventdata, handles)
    choice = questdlg('What channel?', ...
        'Channel Select', ...
        'CFP','YFP','Cancel','Cancel');
    % Handle response
    cfp = 0;
    switch choice
        case 'CFP'
            cfp  = 1;
        case 'YFP'
            cfp = 0;
        case 'Cancel'
            return
    end
    folder_name = uigetdir('~','Select the directory for batch processing');
    prompt = {['Enter the filename prefix with a * to signify where either CFP or YFP is located,' ...
        'for exampe, "cerulean_w1CFP DC 1-_s" would be signified "cerulean_w1* DC 1-_s".  All files with that prefix followed by an integer will be found']};
    dlg_title = 'Input filters';
    num_lines = 1;
    def = {'name*'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    if (isempty(answer))
        return;
    end
    i = 1;
    while 1
        if cfp
            if ~exists(fullfile(folder_name,[strrep(answer{1},'*','CFP') num2str(i) '.tif']))
                return;
            end
            CFP_EX = imread(fullfile(folder_name,[strrep(answer{1},'*','CFP') num2str(i) '.tif']));
            CF = CFP_EX(:,1:696);
            CC = CFP_EX(:,1:697:1392);
            imwrite(CF,fullfile(folder_name,['CFPFRET' num2str(i) '.tif']));
            imwrite(CC,fullfile(folder_name,['CFP' num2str(i) '.tif']));
        else
            if ~exists(fullfile(folder_name,[strrep(answer{1},'*','CFP') num2str(i) '.tif']))
                return;
            end
            C = imread(fullfile(folder_name,[strrep(answer{1},'*','CFP') num2str(i) '.tif']));
            Y = imread(fullfile(folder_name,[strrep(answer{1},'*','YFP') num2str(i) '.tif']));
            YC = Y(:,1:696);
            YF = C(:,1:696);
            imwrite(YC,fullfile(folder_name,['YFP' num2str(i) '.tif']));
            imwrite(YF,fullfile(folder_name,['YFPFRET' num2str(i) '.tif']));
        end
        i = i + 1;
    end

function edit8_Callback(hObject, eventdata, handles)

function edit8_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit9_Callback(hObject, eventdata, handles)

function edit9_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function x2_Callback(hObject, eventdata, handles)    

function x2_CreateFcn(hObject, eventdata, handles)   
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

function x1_Callback(hObject, eventdata, handles)

function x1_CreateFcn(hObject, eventdata, handles)    
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

function y1_Callback(hObject, eventdata, handles)    

function y1_CreateFcn(hObject, eventdata, handles)    
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

function y2_Callback(hObject, eventdata, handles)

function y2_CreateFcn(hObject, eventdata, handles)    
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

function checkbox1_Callback(hObject, eventdata, handles)

function checkbox2_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function save_Callback(hObject, eventdata, handles)

function add1_Callback(hObject, eventdata, handles)    
    handles = guidata(hObject);
    set(handles.file,'Enable','on');
    Data=get(handles.uitable1,'Data');
    str=sprintf('CFP # %i Range= %s, a = %.4f, r^2 = %.4f',handles.Ccount,handles.exclusion,handles.CFPa, handles.CFPr);    
    NData=[cell(1,2); Data];
    NData{1,1}=str;
    set(handles.uitable1,'Data',NData);
    set(handles.add1,'Enable','off');
    handles.Ccount=handles.Ccount+1;
    handles.CFPdata=[handles.CFPdata;handles.CFPa];
    guidata(hObject,handles);

function add2_Callback(hObject, eventdata, handles)    
    handles = guidata(hObject);
    set(handles.file,'Enable','on');
    Data=get(handles.uitable1,'Data');
    str=sprintf('YFP # %i Range= %s, b = %.4f, r^2 = %.4f',handles.Ycount, handles.exclusion,handles.YFPa, handles.YFPr);    
    NData=[cell(1,2); Data];
    NData{1,1}=str;
    set(handles.uitable1,'Data',NData);
    set(handles.add2,'Enable','off');
    handles.Ycount=handles.Ycount+1;
    handles.YFPdata=[handles.YFPdata;handles.YFPa];
    guidata(hObject,handles);

function export_Callback(hObject, eventdata, handles)    
    handles = guidata(hObject);
    [FileName,PathName] = uiputfile('*.txt','Save output');
    name=strcat(PathName,FileName);
    file=fopen(name,'wt');
    fprintf(file,'%s %6s\r\n','CFP','YFP');
    sizea=size(handles.CFPdata);
    sizeb=size(handles.YFPdata);
    datasize=min(sizea(1),sizeb(1));
    for i=1:datasize
        fprintf(file,'%.4f %6.4f\r\n',handles.CFPdata(i),handles.YFPdata(i));
    end
    if sizea(1)>datasize
        for i=(datasize+1):sizea(1)
            fprintf(file,'%.4f\r\n',handles.CFPdata(i));
        end
    end
    if sizeb(1)>datasize
        for i=(datasize+1):sizeb(1)
            fprintf(file,'%13.4f\r\n',handles.YFPdata(i));
        end
    end
    guidata(hObject,handles);

function file_Callback(hObject, eventdata, handles)
   


% --- Executes on button press in continue_button.
function continue_button_Callback(hObject, eventdata, handles)
% hObject    handle to continue_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);
