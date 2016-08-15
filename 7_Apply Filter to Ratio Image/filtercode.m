filter = 'hmf';
filter_box = 3;

ratio_path = cd;
ratio_file = 'ratio_image.tif';
ratio_info = imfinfo(fullfile(ratio_path,ratio_file));
frames = numel(ratio_info);

filter_file = strcat('ratio_',filter,'.tif');
try %#ok<TRYNC>
    delete(filter_file); % filtered ratio image
end

for i=1:frames
    % read ratio frame
    ratio_frame = imread(fullfile(ratio_path,ratio_file),'tif',i,'Info',ratio_info);
    
    % apply filter to frame
    filtered_ratio_frame = hmf(ratio_frame,filter_box);
    
    % write filtered frame to file
    imwrite(filtered_ratio_frame, filter_file,'tif','Compression','none','WriteMode','append');
end


%%
%{
- *median filter             medfilt2(A, [m n]); [3 3] neightborhood default
- *hybrid median filter      hmf(A, filter_box_size[3] );
- *gaussian smoothing        imgaussfilt(A, std_dev[0.5] );
- wiener filter             wiener2(A, [m n], noise ); [m n] neighborhood
                            box, noise power estimate, default: [3 3], &
                            [J,noise] = wiener2(A, [m n]) estimates noise
- standard dev filt         stdfilt(A, NHOOD) NHOOD = ones(odd); default=3
- range filter              rangefilt(A, NHOOD) NHOOD = ones(odd); default=3
- entropy filter            entropyfiltA, NHOOD) NHOOD = ones(odd);
                            default=9
- *mean filter               imboxfilt(A, filter_box_size[3] );

N (for NxN neighborhood)
    -median
    -hybrid median
    -mean
sigma
    - gaussian smoothing


%}