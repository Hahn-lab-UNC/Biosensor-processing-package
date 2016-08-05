function initialize_data(svd, dark_current, orientation, transform, split)

%% Find and Delete Previous Versions of '.tif' Images
%  In order to write mulitple pages (frames) to a '.tif' requires appending
%  them during the writing process.  Therefore, it is imperative to delete
%  previous versions of the '.tif' in order to write a newly processed
%  '.tif' file.

% * Tries to find the specific '.tif' files and delete them.
try  %#ok<*TRYNC>
    delete('donor.tif');   % donor image
end
try
    delete('fret.tif');  % FRET image
end
try
    delete('acceptor.tif');  % acceptor image
end
try
    delete('donor_sc.tif');   % shade corrected donor image
end
try
    delete('fret_sc.tif');  % shade corrected FRET image
end
try
    delete('acceptor_sc.tif');  % shade corrected acceptor image
end
try
    delete('donor_transformed.tif');   % transformed donor image
end

%%
if split == 1
    %% --- Split Initialization
    %% - Select Data to Import

    file_tif_donorfret = uigetfile('*.tif','Select the donor/FRET movie');
    file_donorfret_shade = uigetfile('*.tif','Selectthe donor/FRET shade image');

    imgInfoA = imfinfo(file_tif_donorfret);
    width = imgInfoA(1).Width;
    height = imgInfoA(1).Height; 
    num_images = length(imgInfoA);

    if svd == 2
        file_tif_acceptor = uigetfile('*.tif','Select the acceptor movie');
        file_acceptor_shade = uigetfile('*.tif','Select the acceptor shade image');

        imgInfoB = imfinfo(file_tif_acceptor);
    end

    % Format Shade Correction Images
    shadeInfoA = imfinfo(file_donorfret_shade);
    raw_shadeA = zeros(height, width, 'uint16');
    raw_shadeA(:,:) = imread(file_donorfret_shade, 'Info', shadeInfoA);

    if svd == 2
        shadeInfoB = imfinfo(file_acceptor_shade);
        raw_shadeB = zeros(height, width, 'uint16');
        raw_shadeB(:,:) = imread(file_acceptor_shade, 'Info', shadeInfoB);
    end

    if orientation == 1
        fret_shade = raw_shadeA(:, 1:round(width/2) );
        donor_shade = raw_shadeA(:, round(width/2+1):width );

        if svd == 2
            acceptor_shade = raw_shadeB(:, 1:round(width/2) );
        end
    else
        donor_shade = raw_shadeA(:, 1:round(width/2) );
        fret_shade = raw_shadeA(:, round(width/2+1):width );

        if svd == 2
            acceptor_shade = raw_shadeB(:, round(width/2+1):width );
        end
    end

    % Format Dark Current Images
    if dark_current == 1
        file_donorfret_dark = uigetfile('*.tif','Select the dark current image');

        darkInfo = imfinfo(file_donorfret_dark);
        raw_dark = zeros(height, width, 'uint16');
        raw_dark(:,:) = imread(file_donorfret_dark, 'Info', darkInfo);

        if orientation == 1
            acceptor_dark  = raw_dark(:, 1:round(width/2) );
            donor_dark     = raw_dark(:, round(width/2+1):width );
        else
            donor_dark     = raw_dark(:, 1:round(width/2) );
            acceptor_dark  = raw_dark(:, round(width/2+1):width );
        end

        donor_shade = donor_shade - donor_dark;
        fret_shade = fret_shade - acceptor_dark;
        if svd == 2
            acceptor_shade = acceptor_shade - acceptor_dark;
        end
    end

    % Format Transformtion Matrix
    if transform == 1
    %     file_tform = uigetfile('transform.mat','Select the transformation matrix');
        trans_matrix = importdata('camera_transform.mat');
    end


    %% - Configure Shade Images

    [n,m] = size(donor_shade);

    donor_shade_avg = mean(reshape(donor_shade, n*m, 1));  % average donor intensity
    if transform == 1
        donor_shade = imtransform(donor_shade, trans_matrix,'XData',[1 m],'YData',[1 n],'FillValues',0);
    end
    donor_shade_norm = double(donor_shade) / donor_shade_avg;  % normalized donor shade image

    fret_shade_avg = mean(reshape(fret_shade, n*m, 1));  % average fret intensity
    fret_shade_norm = double(fret_shade) / fret_shade_avg;  % normalized fret shade image

    if svd == 2
        acceptor_shade_avg = mean(reshape(acceptor_shade, n*m, 1)); % average acceptor intensity
        acceptor_shade_norm = double(acceptor_shade) / acceptor_shade_avg; % normalized acceptor shade image
    end


    %% Breakup donor and FRET Excitation Images Into Managable Number of Frames
    % Matlab has limited memory and therefore a maximum possible array size
    % which is computer dependent.  Consequently, huge '.tif' files may be too
    % large to read into a single array.  Therefore, this code reads in the
    % '.tif' files in chunks with a 'for' loop to avoid 'out of memory' errors.

    % * A larger value for 'loop' will decrease the memory load on Matlab, but will increase computation time
    % * A smaller value for 'loop' could produce memory errors but will decrease computation time 

    loop = 9;       % number of subsection of frames
    view_fig = 0;   % to view figures set to 1. 

    % set number of sub-sections to process sub-total number of frames in '.tif' stack
    if num_images <= loop
        num_images_sub = num_images;
        loop = 1;
    else
        num_images_sub = round(num_images/loop);
    end

    for i = 1:loop
        fprintf('Current Loop Number: %d of %d \r',i,loop)  % display loop number in console

        if i == loop
            ind = (i-1)*(num_images_sub) + 1:num_images;  % indices of "remaining" subsection of frames in last loop
        else
            ind = (i-1)*(num_images_sub) + 1:num_images_sub*i;  % indices of subsection of frames for current loop
        end

        %% Donor and FRET Processing
        raw_imageA = zeros(height, width, length(ind), 'uint16');  % empty matrix for donor/fret preallocated for speed

        for j = ind
            raw_imageA(:,:,find(ind==j,1,'first')) = imread(file_tif_donorfret, 'Index', j, 'Info', imgInfoA);
        end

        % Split Excitation Images of Donor and FRET and Apply Dark Current Correction
        if orientation == 1
            FRET = raw_imageA(:, 1:round(width/2), :);
            donor = raw_imageA(:, round(width/2)+1:width, :);
        else
            donor = raw_imageA(:, 1:round(width/2), :);
            FRET = raw_imageA(:, round(width/2)+1:width, :);
        end

        if dark_current == 1
            donor = bsxfun(@minus, donor, donor_dark);
            FRET = bsxfun(@minus, FRET, acceptor_dark);
        end

        clear('raw_imageA')

        % Apply the Transformation to the Donor Image
        [n,m,~] = size(donor);
        if transform == 1
            donor_transformed = imtransform(donor,trans_matrix,'XData',[1 m],'YData',[1 n],'FillValues',0);
        end

        % Write Donor and FRET to '.tif' files
        for j = 1:length(ind);
            imwrite(donor(:,:,j), 'donor.tif', 'Compression', 'none', 'WriteMode', 'append')  % the raw donor images (donor excitation & emission)
            if transform == 1
                imwrite(donor_transformed(:,:,j),  'donor_transformed.tif',  'Compression', 'none', 'WriteMode', 'append')  % the transformed donor images (donor excitation & emission)
            else
                donor_transformed = donor;
            end
            imwrite(FRET(:,:,j), 'fret.tif', 'Compression', 'none', 'WriteMode', 'append')  % the FRET images (donor excitation, acceptor emission)
        end

        % Apply the Normalized Shade Correction to Donor and FRET
        donor_sc  = uint16(bsxfun(@rdivide, double(donor_transformed), donor_shade_norm));
        FRET_sc = uint16(bsxfun(@rdivide, double(FRET), fret_shade_norm));

        % Clear Unnecessary Variables
        if i == 1 && view_fig == 1  
            donor(:,:,2:end) = [];
            FRET(:,:,2:end) = [];
            if transform == 1
                donor_transformed (:,:,2:end) = [];
            end
        else
            clear('donor', 'FRET')
            if transform == 1
                clear('donor_transformed')
            end
        end

        % Write the Shade Corrected Donor and FRET to '.tif' files
        for j = 1:length(ind);
            imwrite(donor_sc(:,:,j),  'donor_sc.tif',  'Compression', 'none', 'WriteMode', 'append');
            imwrite(FRET_sc(:,:,j), 'fret_sc.tif', 'Compression', 'none', 'WriteMode', 'append');
        end

        % Clear Unnecessary Variables
        if i == 1 && view_fig == 1
           donor_sc(:,:,2:end) = [];
           FRET_sc(:,:,2:end) = [];
        else
           clear('donor_sc', 'FRET_sc')
        end


        %% Acceptor Processing

        if svd == 2
            raw_imageB = zeros(height, width, length(ind), 'uint16');  % empty matrix for acceptor preallocated for speed

            for j = ind
                raw_imageB(:,:,find(ind==j,1,'first')) = imread(file_tif_acceptor, 'Index', j, 'Info', imgInfoB);
            end

            % Split Excitation Images of Acceptor and Apply Dark Current Correction
            if orientation == 1
                acceptor = raw_imageB(:, 1:round(width/2), :);
            else
                acceptor = raw_imageB(:, round(width/2)+1:width, :);
            end

            acceptor = bsxfun(@minus, acceptor, acceptor_dark);
            clear('raw_imageB')

            % Write Acceptor to '.tif' file
            for j = 1:length(ind);
                imwrite(acceptor(:,:,j),  'acceptor.tif',  'Compression', 'none', 'WriteMode', 'append') % the acceptor images (acceptor excitation, acceptor emission)
            end

            % Apply the Normalized Shade Correction to Acceptor Image
            acceptor_sc = uint16(bsxfun(@rdivide, double(acceptor), acceptor_shade_norm));

            % Clear Unecessary Variables
            acceptor(:,:,2:end) = [];
            clear('acceptor')

            % Write the Shade Corrected Acceptor '.tif' file
            for j = 1:length(ind);
                imwrite(acceptor_sc(:,:,j), 'acceptor_sc.tif', 'Compression', 'none', 'WriteMode', 'append');
            end

            % Clear Unecessary Variables
            acceptor_sc(:,:,2:end) = [];
            clear('acceptor_sc')
        end


        %% Figures
        % Only viewed on first loop and if the variable 'view_fig' is equal to 1.
        if i == 1 && view_fig == 1

    %         f1 = figure('Name', 'Raw Data');
    %         subplot(3,1,1); imagesc(CFPr(:,:,1)); axis image; title('CFPr'); colorbar
    %         subplot(3,1,2); imagesc(FRET(:,:,1)); axis image; title('FRET'); colorbar
    %         if svd == 2
    %             subplot(3,1,3); imagesc(YFP(:,:,1)); axis image; title('YFP'); colorbar
    %         end
    %         
    %         f2 = figure('Name', 'CFP Transform');
    %         subplot(2,1,1); imagesc(CFPr(:,:,1)); axis image; title('CFPr'); colorbar
    %         subplot(2,1,2); imagesc(CFP(:,:,1)); axis image; title('Transformed CFP'); colorbar
    %         
    %         f3 = figure('Name', 'Normalized Shade Images');
    %         subplot(3,2,1); imagesc(CFPshade); axis image; title('CFP raw'); colorbar;
    %         subplot(3,2,2); imagesc(CFPshade_N); axis image; title('CFP norm'); colorbar;
    %         subplot(3,2,3); imagesc(FRETshade); axis image; title('FRET raw'); colorbar;
    %         subplot(3,2,4); imagesc(FRETshade_N); axis image; title('FRET norm'); colorbar;
    %         if svd == 2
    %             subplot(3,2,5); imagesc(YFPshade); axis image; title('YFP raw'); colorbar;
    %             subplot(3,2,6); imagesc(YFPshade_N); axis image; title('YFP norm'); colorbar;
    %         end

            f4 = figure('Name', 'Shade Corrected');
            subplot(3,2,1); imagesc(donor_transformed(:,:,1)); axis image; colorbar; title('CFP');
            subplot(3,2,2); imagesc(donor_sc(:,:,1)); axis image; colorbar; title('CFPsc');
            subplot(3,2,3); imagesc(FRET(:,:,1)); axis image; colorbar; title('FRET');
            subplot(3,2,4); imagesc(FRET_sc(:,:,1)); axis image; colorbar; title('FRETsc');
            if svd == 2
                subplot(3,2,5); imagesc(acceptor(:,:,1)); axis image; colorbar; title('YFP');
                subplot(3,2,6); imagesc(acceptor_sc(:,:,1)); axis image; colorbar; title('YFPsc');
            end

    %         saveas(f1, 'Raw_data.eps');
    %         saveas(f2, 'CFP_xForm.eps');
    %         saveas(f3, 'Shade_normalized.eps')      
        end   

    end
    
else
    %% --- No Split Initialization
    %% - Select Data to Import

    file_tif_donor = uigetfile('*.tif','Select the donor movie');
    file_tif_fret = uigetfile('*.tif','Select the FRET movie');
    file_donor_shade = uigetfile('*.tif','Select the donor shade image');
    file_fret_shade = uigetfile('*.tif','Select the FRET shade image');

    imgInfoA = imfinfo(file_tif_donor);
    width = imgInfoA(1).Width;
    height = imgInfoA(1).Height; 
    num_images = length(imgInfoA);

    if svd == 2
        file_tif_acceptor = uigetfile('*.tif','Select the acceptor movie');
        file_acceptor_shade = uigetfile('*.tif','Select the acceptor shade image');

        imgInfoB = imfinfo(file_tif_acceptor);
    end

    % Format Shade Correction Images
    donor_shade = imread(file_donor_shade);
    fret_shade = imread(file_fret_shade);

    if svd == 2
        acceptor_shade = imread(file_acceptor_shade);
    end

    % Format Dark Current Images
    if dark_current == 1
        file_donor_dark = uigetfile('*.tif','Select the dark current image for the donor channel');
        file_acceptor_dark = uigetfile('*.tif','Select the dark current image for the acceptor channel');

        acceptor_dark  = imread(file_acceptor_dark);
        donor_dark     = imread(file_donor_dark);

        donor_shade = donor_shade - donor_dark;
        fret_shade = fret_shade - acceptor_dark;
        if svd == 2
            acceptor_shade = acceptor_shade - acceptor_dark;
        end
    end

    % Format Transformtion Matrix
    if transform == 1
    %     file_tform = uigetfile('*.mat','Select the transformation matrix');
        trans_matrix = importdata('camera_transform.mat');
    end


    %% - Configure Shade Images

    [n,m] = size(donor_shade);

    donor_shade_avg = mean(reshape(donor_shade, n*m, 1));  % average donor intensity
    if transform == 1
        donor_shade = imtransform(donor_shade, trans_matrix,'XData',[1 m],'YData',[1 n],'FillValues',0);
    end
    donor_shade_norm = double(donor_shade) / donor_shade_avg;  % normalized donor shade image

    fret_shade_avg = mean(reshape(fret_shade, n*m, 1));  % average fret intensity
    fret_shade_norm = double(fret_shade) / fret_shade_avg;  % normalized fret shade image

    if svd == 2
        acceptor_shade_avg = mean(reshape(acceptor_shade, n*m, 1)); % average acceptor intensity
        acceptor_shade_norm = double(acceptor_shade) / acceptor_shade_avg; % normalized acceptor shade image
    end


    %% Breakup donor, FRET, and acceptor Excitation Images Into Managable Number of Frames
    % Matlab has limited memory and therefore a maximum possible array size
    % which is computer dependent.  Consequently, huge '.tif' files may be too
    % large to read into a single array.  Therefore, this code reads in the
    % '.tif' files in chunks with a 'for' loop to avoid 'out of memory' errors.

    % * A larger value for 'loop' will decrease the memory load on Matlab, but will increase computation time
    % * A smaller value for 'loop' could produce memory errors but will decrease computation time 

    loop = 9;       % number of subsection of frames
    view_fig = 0;   % to view figures set to 1. 

    % set number of sub-sections to process sub-total number of frames in '.tif' stack
    if num_images <= loop
        num_images_sub = num_images;
        loop = 1;
    else
        num_images_sub = round(num_images/loop);
    end

    for i = 1:loop
        fprintf('Current Loop Number: %d of %d \r',i,loop)  % display loop number in console

        if i == loop
            ind = (i-1)*(num_images_sub) + 1:num_images;  % indices of "remaining" subsection of frames in last loop
        else
            ind = (i-1)*(num_images_sub) + 1:num_images_sub*i;  % indices of subsection of frames for current loop
        end

        %% Donor and FRET Processing
        donor = zeros(height, width, length(ind), 'uint16');  % empty matrix for donor/fret preallocated for speed
        FRET = zeros(height, width, length(ind), 'uint16');  % empty matrix for donor/fret preallocated for speed

        for j = ind
            donor(:,:,find(ind==j,1,'first')) = imread(file_tif_donor, 'Index', j, 'Info', imgInfoA);
            FRET(:,:,find(ind==j,1,'first')) = imread(file_tif_fret, 'Index', j, 'Info', imgInfoA);
        end

        % Apply Dark Current Correction to Donor and FRET
        donor = bsxfun(@minus, donor, donor_dark);
        FRET = bsxfun(@minus, FRET, acceptor_dark);

        % Apply the Transformation to the Donor Image
        [n,m,~] = size(donor);
        if transform == 1
            donor_transformed = imtransform(donor,trans_matrix,'XData',[1 m],'YData',[1 n],'FillValues',0);
        end

        % Write Donor and FRET to '.tif' files
        for j = 1:length(ind);
            imwrite(donor(:,:,j), 'donor.tif', 'Compression', 'none', 'WriteMode', 'append')  % the raw donor images (donor excitation & emission)
            if transform == 1
                imwrite(donor_transformed(:,:,j),  'donor_transformed.tif',  'Compression', 'none', 'WriteMode', 'append')  % the transformed donor images (donor excitation & emission)
            else
                donor_transformed = donor;
            end
            imwrite(FRET(:,:,j), 'fret.tif', 'Compression', 'none', 'WriteMode', 'append')  % the FRET images (donor excitation, acceptor emission)
        end

        % Apply the Normalized Shade Correction to Donor and FRET
        donor_sc = uint16(bsxfun(@rdivide, double(donor_transformed), donor_shade_norm));
        FRET_sc = uint16(bsxfun(@rdivide, double(FRET), fret_shade_norm));

        % Clear Unnecessary Variables
        if i == 1 && view_fig == 1  
            donor(:,:,2:end) = []; 
            FRET(:,:,2:end) = [];
            if transform == 1
                donor_transformed(:,:,2:end) = [];
            end
        else
            clear('donor', 'FRET')
            if transform == 1
                clear('donor_transformed');
            end
        end 

        % Write the Shade Corrected Donor and FRET to '.tif' files
        for j = 1:length(ind);
            imwrite(donor_sc(:,:,j),  'donor_sc.tif',  'Compression', 'none', 'WriteMode', 'append');
            imwrite(FRET_sc(:,:,j), 'fret_sc.tif', 'Compression', 'none', 'WriteMode', 'append');
        end

        % Clear Unnecessary Variables
        if i == 1 && view_fig == 1
           donor_sc(:,:,2:end) = [];
           FRET_sc(:,:,2:end) = [];
        else
           clear('donor_sc', 'FRET_sc')
        end


        %% Acceptor Processing

        if svd == 2
            acceptor = zeros(height, width, length(ind), 'uint16');  % empty matrix for acceptor preallocated for speed

            for j = ind
                acceptor(:,:,find(ind==j,1,'first')) = imread(file_tif_acceptor, 'Index', j, 'Info', imgInfoB);
            end

            % Apply Dark Current Correction
            acceptor = bsxfun(@minus, acceptor, acceptor_dark);

            % Write Acceptor to '.tif' file
            for j = 1:length(ind);
                imwrite(acceptor(:,:,j),  'acceptor.tif',  'Compression', 'none', 'WriteMode', 'append') % the acceptor images (acceptor excitation, acceptor emission)
            end

            % Apply the Normalized Shade Correction to Acceptor Image
            acceptor_sc = uint16(bsxfun(@rdivide, double(acceptor), acceptor_shade_norm));

            % Clear Unecessary Variables
            acceptor(:,:,2:end) = [];
            clear('acceptor')

            % Write the Shade Corrected Acceptor '.tif' file
            for j = 1:length(ind);
                imwrite(acceptor_sc(:,:,j), 'acceptor_sc.tif', 'Compression', 'none', 'WriteMode', 'append');
            end

            % Clear Unecessary Variables
            acceptor_sc(:,:,2:end) = [];
            clear('acceptor_sc')
        end


        %% Figures
        % Only viewed on first loop and if the variable 'view_fig' is equal to 1.
%         if i == 1 && view_fig == 1

    %         f1 = figure('Name', 'Raw Data');
    %         subplot(3,1,1); imagesc(CFPr(:,:,1)); axis image; title('CFPr'); colorbar
    %         subplot(3,1,2); imagesc(FRET(:,:,1)); axis image; title('FRET'); colorbar
    %         if svd == 2
    %             subplot(3,1,3); imagesc(YFP(:,:,1)); axis image; title('YFP'); colorbar
    %         end
    %         
    %         f2 = figure('Name', 'CFP Transform');
    %         subplot(2,1,1); imagesc(CFPr(:,:,1)); axis image; title('CFPr'); colorbar
    %         subplot(2,1,2); imagesc(CFP(:,:,1)); axis image; title('Transformed CFP'); colorbar
    %         
    %         f3 = figure('Name', 'Normalized Shade Images');
    %         subplot(3,2,1); imagesc(CFPshade); axis image; title('CFP raw'); colorbar;
    %         subplot(3,2,2); imagesc(CFPshade_N); axis image; title('CFP norm'); colorbar;
    %         subplot(3,2,3); imagesc(FRETshade); axis image; title('FRET raw'); colorbar;
    %         subplot(3,2,4); imagesc(FRETshade_N); axis image; title('FRET norm'); colorbar;
    %         if svd == 2
    %             subplot(3,2,5); imagesc(YFPshade); axis image; title('YFP raw'); colorbar;
    %             subplot(3,2,6); imagesc(YFPshade_N); axis image; title('YFP norm'); colorbar;
    %         end
% 
%             f4 = figure('Name', 'Shade Corrected');
%             subplot(3,2,1); imagesc(donor_transformed(:,:,1)); axis image; colorbar; title('CFP');
%             subplot(3,2,2); imagesc(donor_sc(:,:,1)); axis image; colorbar; title('CFPsc');
%             subplot(3,2,3); imagesc(FRET(:,:,1)); axis image; colorbar; title('FRET');
%             subplot(3,2,4); imagesc(FRET_sc(:,:,1)); axis image; colorbar; title('FRETsc');
%             if svd == 2
%                 subplot(3,2,5); imagesc(acceptor(:,:,1)); axis image; colorbar; title('YFP');
%                 subplot(3,2,6); imagesc(acceptor_sc(:,:,1)); axis image; colorbar; title('YFPsc');
%             end

    %         saveas(f1, 'Raw_data.eps');
    %         saveas(f2, 'CFP_xForm.eps');
    %         saveas(f3, 'Shade_normalized.eps')      
%         end   

    end    
        
end