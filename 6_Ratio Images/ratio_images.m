function ratio_images(svd, registered, photobleach, ratio_type, alpha, beta)

%% --- Ratioing Images

%% Find and Delete Previous Versions of '.tif' Images
%  In order to write mulitple pages (frames) to a '.tif' requires appending
%  them during the writing process.  Therefore, it is imperative to delete
%  previous versions of the '.tif' in order to write a newly processed
%  '.tif' file.

% * Tries to find the specific '.tif' files and delete them.
try  %#ok<*TRYNC>
    delete('ratio_image.tif');   % donor image
end

%%
% Import necessary data
donor_path = cd;
if photobleach == 1
    donor_file = 'donor_pbc.tif';
else
    if registered == 1
        donor_file = 'donor_reg.tif';
    else    
        donor_file = 'donor_masked.tif';
    end
end
donor_info = imfinfo(fullfile(donor_path, donor_file));
frames = numel(donor_info);

fret_path = cd;
if photobleach == 1
    fret_file = 'fret_pbc.tif';
else
    fret_file = 'fret_masked.tif';
end
fret_info = imfinfo(fullfile(fret_path ,fret_file));

% Pre-allocated matrices
donor_cell = cell(1,frames);
fret_cell = cell(1,frames);

if svd == 2
    acceptor_path = cd;
    if photobleach == 1
        acceptor_file = 'acceptor_pbc.tif';
    else
        acceptor_file = 'acceptor_masked.tif';
    end
    acceptor_info = imfinfo(fullfile(acceptor_path ,acceptor_file));
    
    acceptor_cell = cell(1,frames);
end

%% Read data into matrices
for x=1:frames
    a = imread(fullfile(donor_path,donor_file),'tif',x,'Info',donor_info);
    donor_cell{x} = a;
    
    a = imread(fullfile(fret_path,fret_file),'tif',x,'Info',fret_info);
    fret_cell{x} = a;
    
    if svd == 2
        a = imread(fullfile(acceptor_path,acceptor_file),'tif',x,'Info',acceptor_info);
        acceptor_cell{x} = a;   
    end
end

%% Perform ratio calculations
for x=1:frames
    % Load frame
    donor = double(donor_cell{x});
    fret = double(fret_cell{x});
    
    if svd == 2
        acceptor = double(acceptor_cell{x});
        % Bleedthrough correction for fret channel with dual chain biosensor analysis
        corrected_fret = fret - (donor*alpha)-(acceptor*beta);
        corrected_fret_int = uint16(corrected_fret);
        imwrite(corrected_fret_int,'fret_corrected.tif','tif','Compression','none','WriteMode','append');
        fret = corrected_fret;
    end
    
    % Calculate ratio image
    if ratio_type == 1
        ratio = 1000*donor./fret; %inverse ratio
    else
        ratio = 1000*fret./donor;
    end
    
    % Write ratio image
    ratio(ratio==Inf) = 0;
    ratio_int = uint16(ratio);
    imwrite(ratio_int,'ratio_image.tif', 'tif','Compression','none','WriteMode','append');
end
