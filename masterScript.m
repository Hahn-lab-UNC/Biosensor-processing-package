function masterScript

%% --- Initial processing options --- %%
opt = optionsGUI;

num_fields = length(fieldnames(opt));
if num_fields ~=12
    error('Image Processing Cancelled.');
end

% specification of processing of single chain or dual chain biosensors
single_vs_dual    = opt.svd;
% specify if input images are "stitched" images of two channels in the same
% image in order to "split" the image down the middle to separate channels
split             = opt.split;
% incorporate photobleach correction into processing
photobleach       = opt.photobleach;
% incorporate registration of channels by translations into processing via
% automatic registration or manual registration
register_channels = opt.reg_option;
% apply a filter to ratio image
filter            = opt.filter;
% incorporate dark current/no light correction into processing
dark_current      = opt.dark;
% selection of whether to use a single mask for each channel in the
% processing or separate masks for each channel
one_mask          = opt.one_mask;
% selection of fret/donor, donor/fret, fret/acceptor, and acceptor/fret
ratio_type        = opt.ratios;
% use transformation matrix to align images from two cameras
align_cameras     = opt.align_cams;
% orientation of "stitched" images
orientation       = opt.orientation;
% bleedthrough coefficients for dual chain biosensor processing
alpha             = opt.alpha;
beta              = opt.beta;


%% --- Specification of channel names --- %%
% nameList = channel_specify;


%% --- Specification of working directory --- %%
% Select working directory where images to be processed are located and where new files will be saved
working_dir = uigetdir;
cd(working_dir);
addpath(genpath(working_dir));


%% --- Transformation matrix configuration --- %%
if align_cameras == 1
     if exist('camera_transform.mat','file') ~= 2
         disp('Starting Camera Transformation-Matrix Creation GUI...');
         transformCreationGUI;
         input('Enter anything to continue\n','s');
     end
end


%% --- Image splitting and configuration --- %%
disp('Starting Initial Data Configuration');
initialize_data(single_vs_dual, dark_current, orientation, align_cameras, split);


%% --- Region selection & background correction --- %%
disp('Starting Region Selection and Background Subtraction...');
background_subtraction(single_vs_dual);


%% --- Apply threshold masks --- %%
disp('Starting Thresholding/Masking GUI...');
handle = MovThresh;
waitfor(handle);
mask_images(single_vs_dual,one_mask);


%% --- Registration --- %%
if register_channels == 1
    disp('Starting Registration...');
    handle = registrationGUI;
    waitfor(handle);
elseif register_channels == 3
    disp('Starting Registration...');
    auto_registration;
end


%% --- Photobleach correction --- %%
if photobleach == 1
    disp('Starting Photobleach Correction...');
    photobleach_correction(single_vs_dual, register_channels);
end


%% --- Ratioing images --- %%
if ratio_type == [0,0,0,0]
    disp('No ratio images selected...')
else
    disp('Ratioing Images...');
    ratio_images(single_vs_dual, register_channels, photobleach, ratio_type, alpha, beta);
end


%% --- Apply filter to ratio image --- %%
if filter == 1
    handle = filterGUI;
    waitfor(handle);
end


%% --- End --- %%
input('Enter anything to close all windows and finish','s');
close all;