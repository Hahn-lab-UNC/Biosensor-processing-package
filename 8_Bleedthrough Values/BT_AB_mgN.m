%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program BT_AB.m
% Program to determine alpha and beta parameters 
% from CFP-CFP-CFP and CFP-CFP-FRET for Alpha
% and  YFP-YFP-YFP and CFP-YFP-FRET for Beta
% Also need CFPShade, FRETShade and YFPShade
% Incorporating Feimo's k-means clusters to process segmentation
%
% author: Louis Hodgson  12/2006


close all
clear all; clc;
% getting the ratio image file names and intensities file names
% I=input('Enter number of ratio images:   ');     % This sets the number of corrections to loop
CCCname=input('Enter file name for CFP-C-CFP:  ','s');  % CFP excited, CFP emission of CFP only cell
CCFname=input('Enter file name for CFP-C-FRET:   ','s');  % CFP excited, FRET emission of CFP only cell
YYYname=input('Enter file name for YFP-Y-YFP:   ','s');  % YFP excited, YFP emission of YFP only cell
CYFname=input('Enter file name for CFP-Y-FRET:   ','s');  % CFP excited, FRET emission of YFP only cell


%%%%I am calling in the shade image so you can use either the original
%%%%CFPshade or the transformed version for the multiplexing scopes

C_shade = input('Enter CFP shade filename:   ','s');   %sets name of CFP shade image


% process alpha factor first

CCCNAMEIN=sprintf('%s.tif', CCCname);
CCFNAMEIN=sprintf('%s.tif', CCFname);
    CCCImage = imread(CCCNAMEIN, 'tif');
    CCFImage = imread(CCFNAMEIN, 'tif');
    CCCShade = imread(C_shade);  %calls in CFP shade image
    CCFShade = imread('FRETshade.tif','tif');
    YYYShade = imread('YFPshade.tif', 'tif');
    CYFShade = imread('FRETshade.tif','tif');
%     CFPshade_raw = imread('CFPshade.tif','tif');  %%%I read this in for the normalization
    
    
    [m,n] = size(CCCShade);
    CC = reshape(CCCShade, n*m, 1);
    CCCShade_avg = mean(CC);
    CCCShade_N = double(CCCShade) / CCCShade_avg;

    [m,n] = size(CCFShade);
    CF = reshape(CCFShade, n*m, 1);
    CCFShade_avg = mean(CF);
    CCFShade_N = double(CCFShade) / CCFShade_avg;
    
    [m,n] = size(YYYShade);
    YY = reshape(YYYShade, n*m, 1);
    YYYShade_avg = mean(YY);
    YYYShade_N = double(YYYShade) / YYYShade_avg;
    
    CYFShade_N = CCFShade_N;
    
%     figure;
%     subplot(3,2,1); imagesc(CCCShade); axis image; title('CFP'); colorbar;
%     subplot(3,2,2); imagesc(CCCShade_N); axis image; title('CFPn'); colorbar;
%     subplot(3,2,3); imagesc(CCFShade); axis image; title('FRET'); colorbar;
%     subplot(3,2,4); imagesc(CCFShade_N); axis image; title('FRETn'); colorbar;
%     subplot(3,2,5); imagesc(YYYShade); axis image; title('YFP'); colorbar;
%     subplot(3,2,6); imagesc(YYYShade_N); axis image; title('YFPn'); colorbar;
%     
    
    
        D=1; %input('Enter duration:	');
        lead0=ceil(log10(D+1));

        % input initial condition:
        c=[2000;20000;34500;59748]; %input('Enter centers, e.g. [2;30]:	');
        c=double(c);

        CCCShade_N(CCCShade_N<=0.5)=1;
        CCFShade_N(CCFShade_N==0)=1;
        
        last_slim1=[0.0157;0.0196];
        last_slim2=last_slim1;
        
        aa1=CCCImage;
        aa2=CCFImage;
        
            if size(aa1)~=size(aa2)
                error('Image sizes don''t match.')
            end
            
        % shade correct:
   
        
        aa1=uint16(double(aa1)./double(CCCShade_N));
        aa2=uint16(double(aa2)./double(CCFShade_N));
   
                
        % thresholding based on clustering:
        % contrast enhancing:
        slim1=round(stretchlim(aa1)*100000)/100000; % round to patch another
        slim2=round(stretchlim(aa2)*100000)/100000; % glitch in MATLAB
        if (slim1==[0;1] | slim2==[0;1])% patching a glitch in MATLAB 
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
      
        
        options=zeros(1,15);
        options(2)=5;
        options(3)=1;
        options(14)=120;
        [centers1,op1,post1,error1]=kmeanst(c,fv1(:),options);
        [centers2,op2,post2,error2]=kmeanst(c,fv2(:),options);
        centers1
        centers2
        
  
        [id,jd]=size(aa1);
    
        % assign correct brightness
        [gs, ind]=sort(centers1);
        picc1=zeros(id,jd);
        for i=1:length(c)
            pic1{i}=reshape(post1(:,ind(i)), id,jd);
            picc1(pic1{i}==1)=i-1;
        end
        backgnd1=reshape(post1(:,ind(1)), id,jd);
        
        [gs, ind]=sort(centers2);
        picc2=zeros(id,jd);
        for i=1:length(c)
            pic2{i}=reshape(post2(:,ind(i)), id,jd);
            picc2(pic2{i}==1)=i-1;
        end
        backgnd2=reshape(post2(:,ind(1)), id,jd);
        
  
      
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
    
    

   
        CCCsize = size(aa1);
        CCFsize = size(aa2);
        arraySize = CCCsize(1)*CCCsize(2);
        CCCarray = reshape(aa1,arraySize,1);
        CCFarray = reshape(aa2,arraySize,1);
        
outliers = excludedata(CCCarray, CCFarray, 'box', [25 20000 25 20000]);  % sets fit exclusion range in Y values
opts = fitoptions('method','NonlinearLeastSquares','Robust','off','StartPoint',0.3);
ftype = fittype('a*x','coefficients','a','options',opts);

[fresult,gof] = fit(CCCarray, CCFarray, ftype, 'exclude', outliers);        % double exponential fit, Plane numbers as X and normalized Ratio as Y 
display (fresult);                  % displays fitted parameters and coefficients
display (gof);                      % displays goodness of fit parameters


    a=num2str(fresult.a); rsq=num2str(gof.rsquare);  
    coef=sprintf('a = %s', a);
    coef3=sprintf('r^2 = %s', rsq);
    
     figure; 
     plot(CCCarray, CCFarray,'rd', CCCarray, fresult(CCCarray),'b-');   % Plots results
     title('Linear fit to get Alpha factor');
     xlabel('CFP-C-CFP Intensity'); 
     ylabel('CFP-C-FRET Bleedthrough Intensity'); 
     legend('Data', 'Fit');
     text (500, 2000, 'y = a * x');
     text (500, 1800, coef);
     text (500, 1600, coef3);
     
     
     
    savefile=sprintf('AlphaF.csv');
    csvwrite(savefile, a);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% process beta factor next
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

YYYNAMEIN=sprintf('%s.tif', YYYname);
CYFNAMEIN=sprintf('%s.tif', CYFname);
    YYYImage = imread(YYYNAMEIN, 'tif');
    CYFImage = imread(CYFNAMEIN, 'tif');
   
    
    
        D=1; %input('Enter duration:	');
        lead0=ceil(log10(D+1));

        % input initial condition:
        c=[2000;20000;34500;59748]; %input('Enter centers, e.g. [2;30]:	');
        c=double(c);

        YYYShade_N(YYYShade_N==0)=1;
        CYFShade_N(CYFShade_N==0)=1;
        
        last_slim1=[0.0157;0.0196];
        last_slim2=last_slim1;
        
        aa1=YYYImage;
        aa2=CYFImage;
        
            if size(aa1)~=size(aa2)
                error('Image sizes don''t match.')
            end
            
            % shade correct:
        aa1=uint16(double(aa1)./double(YYYShade_N));
        aa2=uint16(double(aa2)./double(CYFShade_N));
    
        % thresholding based on clustering:
        % contrast enhancing:
        slim1=round(stretchlim(aa1)*100000)/100000; % round to patch another
        slim2=round(stretchlim(aa2)*100000)/100000; % glitch in MATLAB
        if (slim1==[0;1] | slim2==[0;1])% patching a glitch in MATLAB 
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
        
        options=zeros(1,15);
        options(2)=5;
        options(3)=1;
        options(14)=120;
        [centers1,op1,post1,error1]=kmeanst(c,fv1(:),options);
        [centers2,op2,post2,error2]=kmeanst(c,fv2(:),options);
        centers1
        centers2
        
        [id,jd]=size(aa1);
    
        % assign correct brightness
        [gs, ind]=sort(centers1);
        picc1=zeros(id,jd);
        for i=1:length(c)
            pic1{i}=reshape(post1(:,ind(i)), id,jd);
            picc1(pic1{i}==1)=i-1;
        end
        backgnd1=reshape(post1(:,ind(1)), id,jd);
        
        [gs, ind]=sort(centers2);
        picc2=zeros(id,jd);
        for i=1:length(c)
            pic2{i}=reshape(post2(:,ind(i)), id,jd);
            picc2(pic2{i}==1)=i-1;
        end
        backgnd2=reshape(post2(:,ind(1)), id,jd);
        
  
      
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
    
    
    
    
        YYYsize = size(aa1);
        CYFsize = size(aa2);
        arraySize = YYYsize(1)*YYYsize(2);
        YYYarray = reshape(aa1,arraySize,1);
        CYFarray = reshape(aa2,arraySize,1);
        
outliers = excludedata(YYYarray, CYFarray, 'box', [50 20000 50 20000]);  % sets fit exclusion range in Y values
opts = fitoptions('method','NonlinearLeastSquares','Robust','off','StartPoint',0.1);
ftype = fittype('a*x','coefficients','a','options',opts);

[fresult,gof] = fit(YYYarray, CYFarray, ftype, 'exclude', outliers);        % double exponential fit, Plane numbers as X and normalized Ratio as Y 
display (fresult);                  % displays fitted parameters and coefficients
display (gof);                      % displays goodness of fit parameters


    a=num2str(fresult.a); rsq=num2str(gof.rsquare);  
    coef=sprintf('a = %s', a);
    coef3=sprintf('r^2 = %s', rsq);
    
     figure; 
     plot(YYYarray, CYFarray,'rd', YYYarray, fresult(YYYarray),'b-');   % Plots results
     title('Linear fit to get Beta factor');
     xlabel('YFP-Y-YFP Intensity'); 
     ylabel('CFP-Y-FRET Bleedthrough Intensity'); 
     legend('Data', 'Fit');
     text (500, 1000, 'y = a * x');
     text (500, 900, coef);
     text (500, 800, coef3);
     
    savefile=sprintf('BetaF.csv');
    csvwrite(savefile, a);