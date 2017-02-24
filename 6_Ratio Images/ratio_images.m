function ratio_images(svd, registered, photobleach, ratio_type, alpha, beta)

%% --- Ratioing Images

%% Find and Delete Previous Versions of '.tif' Images
%  In order to write mulitple pages (frames) to a '.tif' requires appending
%  them during the writing process.  Therefore, it is imperative to delete
%  previous versions of the '.tif' in order to write a newly processed
%  '.tif' file.

% * Tries to find the specific '.tif' files and delete them.
try  %#ok<*TRYNC>
    delete('fret_corrected.tif'); % bleedthrough corrected fret image
end

if ratio_type(1) == 1
    try  
        delete('ratio_fret_donor.tif'); % ratio image fret/donor
    end
    try
        delete('ratio_fret_donor.mat'); % matrix of ratio values
    end
end
if ratio_type(2) == 1
    try  
        delete('ratio_donor_fret.tif'); % ratio image donor/fret
    end
    try
        delete('ratio_donor_fret.mat'); % matrix of ratio values
    end
end
if svd == 2
    if ratio_type(3) == 1
        try  
            delete('ratio_fret_acceptor.tif'); % ratio image fret/acceptor
        end
        try
            delete('ratio_fret_acceptor.mat'); % matrix of ratio values
        end
    end
    if ratio_type(4) == 1
        try  
            delete('ratio_acceptor_fret.tif'); % ratio image acceptor/fret
        end
        try
            delete('ratio_acceptor_fret.mat'); % matrix of ratio values
        end
    end
end

%%
% Import necessary data
donor_path = cd;
if photobleach == 1
    donor_file = 'donor_pbc.tif';
else
    if registered ~= 2
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

if ratio_type(1) == 1
    ratio_cell_fd = cell(1,frames);
end
if ratio_type(2) == 1
    ratio_cell_df = cell(1,frames);
end
if svd == 2
    if ratio_type(3) == 1
        ratio_cell_fa = cell(1,frames);
    end
    if ratio_type(4) == 1
        ratio_cell_af = cell(1,frames);
    end
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
        fret = corrected_fret;
        corrected_fret_int = uint16(corrected_fret);
        try 
            imwrite(corrected_fret_int,'fret_corrected.tif','tif','Compression','none','WriteMode','append');
        catch
            pause(1)
            fprintf('FRET_CORRECTED Iteration value: %i\n', x);
            imwrite(corrected_fret_int,'fret_corrected.tif','tif','Compression','none','WriteMode','append');
        end
    end
    
    if ratio_type(1) == 1
        % Calculate ratio images
        ratio_fd = fret./donor;

        % format and save data for '.mat' file
        ratio_mat_fd = ratio_fd;
        ratio_mat_fd(isnan(ratio_mat_fd)) = 0;
        ratio_cell_fd{x} = ratio_mat_fd;

        ratio_fd = ratio_fd*1000;
        ratio_fd(ratio_fd==Inf) = 0;
        ratio_int_fd = uint16(ratio_fd);

        % Write ratio image
        try 
            imwrite(ratio_int_fd,'ratio_fret_donor.tif','tif','Compression','none','WriteMode','append');
        catch
            pause(1)
            fprintf('FRETDONORratio Iteration value: %i\n', x);
            imwrite(ratio_int_fd,'ratio_fret_donor.tif','tif','Compression','none','WriteMode','append');
        end

    end
    if ratio_type(2) == 1
        % Calculate ratio images
        ratio_df = donor./fret;

        % format and save data for '.mat' file
        ratio_mat_df = ratio_df;
        ratio_mat_df(isnan(ratio_mat_df)) = 0;
        ratio_cell_df{x} = ratio_mat_df;

        ratio_df = ratio_df*1000;
        ratio_df(ratio_df==Inf) = 0;
        ratio_int_df = uint16(ratio_df);
        
        % Write ratio image        
        try 
            imwrite(ratio_int_df,'ratio_donor_fret.tif','tif','Compression','none','WriteMode','append');
        catch
            pause(1)
            fprintf('DONORFRETratio Iteration value: %i\n', x);
            imwrite(ratio_int_df,'ratio_donor_fret.tif','tif','Compression','none','WriteMode','append');
        end
        
    end
    if svd == 2
        if ratio_type(3) == 1
            % Calculate ratio images
            ratio_fa = fret./acceptor;

            % format and save data for '.mat' file
            ratio_mat_fa = ratio_fa;
            ratio_mat_fa(isnan(ratio_mat_fa)) = 0;
            ratio_cell_fa{x} = ratio_mat_fa;

            ratio_fa = ratio_fa*1000;
            ratio_fa(ratio_fa==Inf) = 0;
            ratio_int_fa = uint16(ratio_fa);

            % Write ratio image     
            try 
                imwrite(ratio_int_fa,'ratio_fret_acceptor.tif','tif','Compression','none','WriteMode','append');
            catch
                pause(1)
                fprintf('FRETACCEPTORratio Iteration value: %i\n', x);
                imwrite(ratio_int_fa,'ratio_fret_acceptor.tif','tif','Compression','none','WriteMode','append');
            end
            
        end
        if ratio_type(4) == 1
            % Calculate ratio images
            ratio_af = acceptor./fret;

            % format and save data for '.mat' file
            ratio_mat_af = ratio_af;
            ratio_mat_af(isnan(ratio_mat_af)) = 0;
            ratio_cell_af{x} = ratio_mat_af;

            ratio_af = ratio_af*1000;
            ratio_af(ratio_af==Inf) = 0;
            ratio_int_af = uint16(ratio_af);

            % Write ratio image
            try 
                imwrite(ratio_int_af,'ratio_acceptor_fret.tif','tif','Compression','none','WriteMode','append');
            catch
                pause(1)
                fprintf('ACCEPTORFRETratio Iteration value: %i\n', x);
                imwrite(ratio_int_af,'ratio_acceptor_fret.tif','tif','Compression','none','WriteMode','append');
            end     
     
        end
    end
end

disp('Ratio Images are saved with values multiplied by 1000 so as to sign integer values to a 16 bit image while still containing decimal place information. The corresponding ratio values are stored in the respective ".mat" files inside the working directory.');
if ratio_type(1) == 1
    save('ratio_fret_donor.mat','ratio_cell_fd');
end
if ratio_type(2) == 1
    save('ratio_donor_fret.mat','ratio_cell_df');
end
if svd == 2
    if ratio_type(3) == 1
        save('ratio_fret_acceptor.mat','ratio_cell_fa');
    end
    if ratio_type(4) == 1
        save('ratio_acceptor_fret.mat','ratio_cell_af');
    end
end
