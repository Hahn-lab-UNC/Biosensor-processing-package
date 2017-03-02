function [alpha,beta] = bleedthrough_correction()
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

%%
% Call initial gui to select options
q = bleedthroughGUI;


%% Gather Images
% check if return is empty
if ~isstruct(q)
    alpha = 0;
    beta = 0;
    return
end


% predefine structures
pre_images = struct;
pre_images.a = cell(1,q.alpha_pairs*2);
pre_images.b = cell(1,q.beta_pairs*2);
post_images = struct;
post_images.a = cell(1,q.alpha_pairs*2);
post_images.b = cell(1,q.beta_pairs*2);
pause(.2)

% read in raw images
count = 1;
for i = 1:q.alpha_pairs*2
    if mod(i,2)
        fprintf('Select donor %d\n',count)
        [file,path] = uigetfile('*.tif','Select donor');
        pre_images.a{i} = imread(fullfile(path,file));
        pause(.2)
    else
        fprintf('Select FRET %d\n',count)
        [file,path] = uigetfile('*.tif','Select FRET');
        pre_images.a{i} = imread(fullfile(path,file));
        pause(.2)
        count = count + 1;
    end
end
count = 1;
for i = 1:q.beta_pairs*2
    if mod(i,2)
        fprintf('Select acceptor %d\n',count)
        [file,path] = uigetfile('*.tif','Select acceptor');
        pre_images.b{i} = imread(fullfile(path,file));
        pause(.2)
    else
        fprintf('Select FRET %d\n',count)
        [file,path] = uigetfile('*.tif','Select FRET');
        pre_images.b{i} = imread(fullfile(path,file));
        pause(.2)
        count = count + 1;
    end
end


disp('Processing Images - Please Wait')
% read in shade correction and dark current correction images
if q.alpha_shade == 1
    sd = imread(fullfile(q.shade_donor{1,2},q.shade_donor{1,1}));
end
if q.beta_shade == 1
    sa = imread(fullfile(q.shade_acceptor{1,2},q.shade_acceptor{1,1}));
end
if q.alpha_shade == 1 || q.beta_shade == 1
    sf = imread(fullfile(q.shade_fret{1,2},q.shade_fret{1,1}));
end

if q.alpha_dark == 1 || q.beta_dark == 1
    da = imread(fullfile(q.dark_acceptor{1,2},q.dark_acceptor{1,1}));
end
if q.alpha_dark == 1
    dd = imread(fullfile(q.dark_donor{1,2},q.dark_donor{1,1}));
    if q.alpha_shade == 1
        sd = sd - dd;
        sf = sf - da;
    end
end
if q.beta_dark == 1 && q.beta_shade == 1
    sa = sa - da;
end


% normalize shade images
if q.alpha_shade == 1 || q.beta_shade == 1
    [n,m] = size(sf);
    sf_avg = mean(reshape(sf, n*m, 1));  % average fret shade intensity
    sf_norm = double(sf) / sf_avg;  % normalized fret shade image
end
if q.alpha_shade == 1
    [n,m] = size(sd);
    sd_avg = mean(reshape(sd, n*m, 1));  % average donor shade intensity
    sd_norm = double(sd) / sd_avg;  % normalized donor shade image
end
if q.beta_shade == 1
    [n,m] = size(sa);
    sa_avg = mean(reshape(sa, n*m, 1));  % average acceptor shade intensity
    sa_norm = double(sa) / sa_avg;  % normalized acceptor shade image
end


% process images
[n,m] = size(pre_images.a{1});
c = double([1;n;n*2;n*m]);
for i = 1:q.alpha_pairs*2
    if mod(i,2) % donor images
        % dark current correction
        im = pre_images.a{i};
        if q.alpha_dark == 1
            im = bsxfun(@minus, im, dd);
        end
        
        % shade correction
        if q.alpha_shade == 1
            im = uint16(bsxfun(@rdivide, double(im), sd_norm));
        end
        
        % enhance image contrast
        lohi = stretchlim(im);
        if (lohi(1)==0 && lohi(2)==1)
            lohi_input = [0.01;0.16];
        else
            lohi_input = lohi;
        end
        enhanced_im = double(imadjust(im,lohi_input));
        
        % threshold with kmeans-clustering
        options=zeros(1,15);
        options(2)=5;
        options(3)=1;
        options(14)=120;
        [centers,~,post,~] = kmeanst(c,enhanced_im(:),options);
        
        [n,m] = size(im);
        [~, ind] = sort(centers);
        background_region = reshape(post(:,ind(1)),n,m);
        
        % background subtraction
        im = double(im);
        background_im = im .* background_region;
        background_avg = sum(sum(background_im)) / sum(sum(background_region));
        im = im - background_avg;
        im(im<=0) = 0;
    
        post_images.a{i} = im;  
        
    else % fret images
        % dark current correction
        im = pre_images.a{i};
        if q.alpha_dark == 1
            im = bsxfun(@minus, im, da);
        end
        
        % shade correction
        if q.alpha_shade == 1
            im = uint16(bsxfun(@rdivide, double(im), sf_norm));
        end
        
        % enhance image contrast
        lohi = stretchlim(im);
        if (lohi(1)==0 && lohi(2)==1)
            lohi_input = [0.01;0.16];
        else
            lohi_input = lohi;
        end
        enhanced_im = double(imadjust(im,lohi_input));
        
        % threshold with kmeans-clustering
        options=zeros(1,15);
        options(2)=5;
        options(3)=1;
        options(14)=120;
        [centers,~,post,~] = kmeanst(c,enhanced_im(:),options);
        
        [n,m] = size(im);
        [~, ind] = sort(centers);
        background_region = reshape(post(:,ind(1)),n,m);
        
        % background subtraction
        im = double(im);
        background_im = im .* background_region;
        background_avg = sum(sum(background_im)) / sum(sum(background_region));
        im = im - background_avg;
        im(im<=0) = 0;
    
        post_images.a{i} = im;  

    end
end
pre_images = rmfield(pre_images,'a');
  
for i = 1:q.beta_pairs*2
    if mod(i,2) % acceptor images
        % dark current correction
        im = pre_images.b{i};
        if q.beta_dark == 1
            im = bsxfun(@minus, im, da);
        end
        
        % shade correction
        if q.beta_shade == 1
            im = uint16(bsxfun(@rdivide, double(im), sa_norm));
        end
        
        % enhance image contrast
        lohi = stretchlim(im);
        if (lohi(1)==0 && lohi(2)==1)
            lohi_input = [0.01;0.16];
        else
            lohi_input = lohi;
        end
        enhanced_im = double(imadjust(im,lohi_input));
        
        % threshold with kmeans-clustering
        options=zeros(1,15);
        options(2)=5;
        options(3)=1;
        options(14)=120;
        [centers,~,post,~] = kmeanst(c,enhanced_im(:),options);
        
        [n,m] = size(im);
        [~, ind] = sort(centers);
        background_region = reshape(post(:,ind(1)),n,m);
        
        % background subtraction
        im = double(im);
        background_im = im .* background_region;
        background_avg = sum(sum(background_im)) / sum(sum(background_region));
        im = im - background_avg;
        im(im<=0) = 0;
    
        post_images.b{i} = im;  
        
    else % fret images
        % dark current correction
        im = pre_images.b{i};
        if q.beta_dark == 1
            im = bsxfun(@minus, im, da);
        end
        
        % shade correction
        if q.beta_shade == 1
            im = uint16(bsxfun(@rdivide, double(im), sf_norm));
        end
        
        % enhance image contrast
        lohi = stretchlim(im);
        if (lohi(1)==0 && lohi(2)==1)
            lohi_input = [0.01;0.16];
        else
            lohi_input = lohi;
        end
        enhanced_im = double(imadjust(im,lohi_input));
        
        % threshold with kmeans-clustering
        options=zeros(1,15);
        options(2)=5;
        options(3)=1;
        options(14)=120;
        [centers,~,post,~] = kmeanst(c,enhanced_im(:),options);
        
        [n,m] = size(im);
        [~, ind] = sort(centers);
        background_region = reshape(post(:,ind(1)),n,m);
        
        % background subtraction
        im = double(im);
        background_im = im .* background_region;
        background_avg = sum(sum(background_im)) / sum(sum(background_region));
        im = im - background_avg;
        im(im<=0) = 0;
    
        post_images.b{i} = im;  
        
    end
end
pre_images = rmfield(pre_images,'b'); %#ok<NASGU>


%%
% plot fits
r = coefficient_calculator(q,post_images.a,post_images.b);
if ~isstruct(r)
    alpha = 0;
    beta = 0;
    return
end


%%
% select alpha and beta
s = coefficient_selector(r);
if s == 0
    alpha = 0;
    beta = 0;
elseif s == 1
    [alpha,beta] = bleedthrough_correction;
else
    alpha = s(1);
    beta = s(2);
end