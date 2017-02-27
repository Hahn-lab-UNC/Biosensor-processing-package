function auto_registration
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

donor_path = cd;
donor_file = 'donor_masked.tif';
donor_info = imfinfo(fullfile(donor_path, donor_file));
frames = numel(donor_info);

FRET_path = cd;
FRET_file = 'fret_masked.tif';
FRET_info = imfinfo(fullfile(FRET_path ,FRET_file));

% cache the images in a cell array for speed
donor_cell = cell(1,frames);
FRET_cell = cell(1,frames);

%% Find and Delete Previous Versions of '.tif' Images
%  In order to write mulitple pages (frames) to a '.tif' requires appending
%  them during the writing process.  Therefore, it is imperative to delete
%  previous versions of the '.tif' in order to write a newly processed
%  '.tif' file.

% * Tries to find the specific '.tif' files and delete them.
try  %#ok<*TRYNC>
    delete('donor_reg.tif');   % registered donor image
end

for x=1:frames

    aa_r = imread(fullfile(donor_path,donor_file),'tif',x,'Info',donor_info);
    size(aa_r);
    donor_cell{x} = aa_r;
    aa_b = imread(fullfile(FRET_path,FRET_file),'tif',x, 'Info',FRET_info);
    FRET_cell{x} = aa_b;

    if size(aa_r)~=size(aa_b)
        error('FRET image does not match size of donor image.')
    end
    
    aa_r = double(aa_r);
    aa_b = double(aa_b);
    
    SS = size(aa_r);
    picc_r = reshape(aa_r,1,(SS(1)*SS(2)));
    picc_b = reshape(aa_b,1,(SS(1)*SS(2)));

    picc_r = reshape(picc_r, SS(1),SS(2));
    picc_b = reshape(picc_b, SS(1),SS(2));        

    %% Registration by Cross Correlation
    % FRET in relation to donor

    clear pic1 pic2 post*;
    correlation = normxcorr2(picc_r, picc_b); % offset by correlation

    [xoffsetsub,yoffsetsub] = subpixShift(correlation);

    offsetval(x,1)= xoffsetsub; %#ok<*AGROW>
    offsetval(x,2)= yoffsetsub;
end

savefile = sprintf('offsets_donor_fret.csv');
csvwrite(savefile, offsetval);

xOffsets = offsetval(:,1);
yOffsets = offsetval(:,2);

xOffsetval = median(xOffsets);
yOffsetval = median(yOffsets);

if (exist('donor_reg.tif','file'))
    delete('donor_reg.tif');
end

for x=1:frames

    aa_r = FRET_cell{x};

    xoffset = floor(xOffsetval);
    yoffset = floor(yOffsetval);

    % whole pixel shift first:
    se = translate(strel(1),[yoffset xoffset]);
    aa_r = imdilate(uint16(aa_r),se);

    % then subpixel shift:
    aa_r = subalign(aa_r,xOffsetval-xoffset,yOffsetval-yoffset);
    aa_r = uint16(aa_r);

    imwrite(aa_r,'donor_reg.tif','tif','Compression','none','WriteMode','append');        
end