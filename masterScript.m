function masterScript

%% --- Initial processing options --- %%
optionArr = img_proc_opts;

[m,~] = size(optionArr);
if m < 9
    disp('Error Occured in "image_proc_opts" - Image Processing Cancelled...');
    return;
end

single_vs_dual = optionArr(1);      % specification of processing of single chain or dual chain biosensors
split = optionArr(2);               % specify if inputs are "stitched" images of two channels in the same image in order to "split" the image down the middle to separate channels
photobleach = optionArr(3);         % incorporate photobleach correction into processing
register_channels = optionArr(4);   % incorporate registration of channels by translations into processing
filter = optionArr(5);              % apply a hyper-median filter to ratio image to smooth edges
dark_current = optionArr(6);        % incorporate dark current/no light correction into processing
regMask = optionArr(7);             % selection of using masked or unamsked images to regsiter channels 
ratio_type = optionArr(8);          % donor/fret instead of fret/donor
align_cameras = optionArr(9);       % use transformation matrix to align images from two cameras


%% --- Specification of alpha and beta values for dual chain processing --- %%
if single_vs_dual == 2
    alpha = input('Enter alpha (donor) bleedthrough value for dual chain processing (input "0" if no alpha bleedthrough): ');
    beta = input('Enter beta (acceptor) bleedthrough value for dual chain processing (input "0" if no beta bleedthrough): ');
else
    alpha = 0;
    beta = 0;
end


%% --- Specification of channel names --- %%
% nameList = channel_specify;


%% --- Specification of composite image configuration --- %%
if split == 1
    channel_orientation = split_config;
else
    channel_orientation = 0;
end

%% --- Specification of working directory --- %%
% Select working directory where images to be processed are located and where new files will be saved
working_dir = uigetdir;
cd(working_dir);
addpath(genpath(working_dir));


%% --- Transformation matrix configuration --- %%
if align_cameras == 1
     if exist('camera_transform.mat','file') ~= 2
         disp('Starting camera transformation matrix creation GUI...');
         transformCreationGUI;
         input('Enter anything to continue\n','s');
     end
end


%% --- Image splitting and configuration --- %%
disp('Starting Initial Data Configuration');
initialize_data(single_vs_dual, dark_current, channel_orientation, align_cameras, split);


%% --- Region selection & background correction --- %%
disp('Starting region selection GUI...');
% disp('Select the background space and a region of interest.');
MoviePlayer;
disp('Starting Background Subtraction...');
background_subtraction(single_vs_dual);


%% --- Apply threshold masks --- %%
disp('Starting thresholding/masking GUI...');
MovThresh;
input('Enter anything to continue','s');
mask_images(single_vs_dual);


%% --- Registration --- %%
if register_channels == 1
    disp('Starting Registration...');
    if regMask == 1
        registration;
    else
        registrationGUI;
        input('Enter anything to continue','s');
    end
end


%% --- Photobleach correction --- %%
if photobleach == 1
    disp('Starting Photobleach Correction...');
    photobleach_correction(single_vs_dual, register_channels);
end


%% --- Ratioing images --- %%
disp('Ratioing Images...');
ratio_images(single_vs_dual, register_channels, photobleach, ratio_type, alpha, beta);


%% --- Apply filter to ratio image --- %%
if filter == 1
    apply_filter;
end


%% --- End --- %%
input('Enter anything to close all windows and finish','s');
close all;