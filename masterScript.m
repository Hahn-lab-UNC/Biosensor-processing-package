function masterScript

%% --- Initial processing options --- %%
% check if run_opts.config exists
if exist('run_opts.mat','file') == 2
    % Construct a questdlg with three options
    choice = questdlg('A "run options" file was found in the working path. Would you like to use the options from this file, or select new options?', ...
        'Options Configuration', ...
        'Use "run_opts.mat"','Select New Options','Cancel','Cancel');
    % Handle response
    switch choice
        case 'Use "run_opts.mat"'
            disp('Using options from "run_opts.mat".')
            run = load('run_opts.mat');
            opt = run.opts{1,1};
        case 'Select New Options'
            disp('Select new options...')
            opt = optionsGUI;
        case 'Cancel'
            disp('Exiting Processing.')
            return
    end
else
    opt = optionsGUI;
end

if ~isstruct(opt)
    disp('Image Processing Cancelled.')
    return
end

num_fields = length(fieldnames(opt));
if num_fields ~=12
    error('Image Processing Cancelled.');
end

% specification of processing of single chain or dual chain biosensors
single_vs_dual    = opt.svd;
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
% bleedthrough coefficients for dual chain biosensor processing
alpha             = opt.alpha;
beta              = opt.beta;


%% --- Specification of channel names --- %%
% nameList = channel_specify;


%% --- Specification of working directory --- %%
% Select working directory where images to be processed are located and where new files will be saved
disp('Select working directory to save images inside')
working_dir = uigetdir;
cd(working_dir);
addpath(genpath(working_dir));


%% --- Transformation matrix configuration --- %%
if align_cameras == 1
     if exist('camera_transform.mat','file') ~= 2
         disp('Starting Camera Transformation-Matrix Creation GUI...');
         handle = transformCreationGUI;
         waitfor(handle);
     end
end


%% --- Image splitting and configuration --- %%
disp('Starting Initial Data Configuration');
initialize_data(single_vs_dual, dark_current, orientation, align_cameras, split);
initialize_data_new(single_vs_dual, dark_current, align_cameras);


%% --- Region selection & background correction --- %%
disp('Starting Region Selection and Background Subtraction...');
background_subtraction(single_vs_dual);


%% --- Apply threshold masks --- %%
disp('Starting Thresholding/Masking GUI...');
frames_of_interest = MovThresh;
waitfor(frames_of_interest);
mask_images(single_vs_dual,one_mask,frames_of_interest);


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