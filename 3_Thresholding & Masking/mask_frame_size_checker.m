function  gen_new_masks = mask_frame_size_checker(condition_opt)

imInfo = imfinfo('fret_scbg_roi.tif');
W = imInfo(1).Width;
H = imInfo(1).Height; 
N = length(imInfo);

gen_new_masks = 0;

% single mask
if condition_opt == 1
    maskInfo = imfinfo('maskfor_.tif');
    width = maskInfo(1).Width;
    height = maskInfo(1).Height; 
    num_im = length(maskInfo);
    
    % check that dimensions match
    if W ~= width || H ~= height || N ~= num_im
        choice = questdlg('Masks of the required name are of different size than images to process. Generate new masks?', ...
            'WARNING', ...
            'Generate New Masks','Exit Processing','Generate New Masks');
        % Handle response
        switch choice
            case 'Generate New Masks'
                gen_new_masks = 1;
                return
            case 'Exit Processing'
                disp('Exiting Processing.')
                return
        end
    end
    
% masks for each single chain channel
elseif condition_opt == 2
    donor_maskInfo = imfinfo('maskfor_donor.tif');
    width1 = donor_maskInfo(1).Width;
    height1 = donor_maskInfo(1).Height;
    num_im1 = length(donor_maskInfo);
    
    fret_maskInfo = imfinfo('maskfor_fret.tif');
    width2 = fret_maskInfo(1).Width;
    height2 = fret_maskInfo(1).Height;
    num_im2 = length(fret_maskInfo);
    
    % check that dimensions match
    if W ~= width1 || H ~= height1 || W ~= width2 || H ~= height2 || N ~= num_im1 || N ~= num_im2
        choice = questdlg('Masks of the required name are of different size than images to process. Generate new masks?', ...
            'WARNING', ...
            'Generate New Masks','Exit Processing','Generate New Masks');
        % Handle response
        switch choice
            case 'Generate New Masks'
                gen_new_masks = 1;
                return
            case 'Exit Processing'
                disp('Exiting Processing.')
                return
        end
    end
    
% masks for each dual chain channel    
elseif condition_opt == 3
    donor_maskInfo = imfinfo('maskfor_donor.tif');
    width1 = donor_maskInfo(1).Width;
    height1 = donor_maskInfo(1).Height;
    num_im1 = length(donor_maskInfo);
    
    fret_maskInfo = imfinfo('maskfor_fret.tif');
    width2 = fret_maskInfo(1).Width;
    height2 = fret_maskInfo(1).Height;
    num_im2 = length(fret_maskInfo);
    
    accptr_maskInfo = imfinfo('maskfor_acceptor.tif');
    width3 = accptr_maskInfo(1).Width;
    height3 = accptr_maskInfo(1).Height;
    num_im3 = length(accptr_maskInfo);
    
    % check that dimensions match
    if W ~= width1 || H ~= height1 || W ~= width2 || H ~= height2 || W ~= width3 || H ~= height3 || N ~= num_im1 || N ~= num_im2 || N ~= num_im3
        choice = questdlg('Masks of the required name are of different size than images to process. Generate new masks?', ...
            'WARNING', ...
            'Generate New Masks','Exit Processing','Generate New Masks');
        % Handle response
        switch choice
            case 'Generate New Masks'
                gen_new_masks = 1;
                return
            case 'Exit Processing'
                disp('Exiting Processing.')
                return
        end
    end
end