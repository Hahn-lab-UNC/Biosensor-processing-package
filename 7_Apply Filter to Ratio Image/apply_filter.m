function apply_filter(filter)

%% --- Filter Application --- %%

if filter == 1
    R = 'final_hmf_ratio.tif';

    for k = 1:dura;
        t = hmf(adjratio(:,:,k),3);
        filtered_ratio(:,:,k) = t; %#ok<*AGROW>
    end
    try %#ok<*TRYNC>
        delete('final_hmf_ratio.tif');
    end
    for k = 1:dura;
            imwrite(filtered_ratio(:,:,k), R, 'Compression', 'none', 'WriteMode', 'append')
    end


    if alt == 1  
        altR = 'final_hmf_altratio.tif';

        for k = 1:dura;
            t = hmf(altadjratio(:,:,k),3);
            altfiltered_ratio(:,:,k) = t;
        end
        try
            delete('final_hmf_altratio.tif');
        end
        for k = 1:dura;
                imwrite(altfiltered_ratio(:,:,k), altR, 'Compression', 'none', 'WriteMode', 'append')
        end
    end
else
    if alt == 1
        disp('No Filter Selected - final images saved as "adjratioed_.tif" and "altadjratioed_.tif"');
    else
        disp('No Filter Selected - final image saved as "adjratioed_.tif"');
    end
end