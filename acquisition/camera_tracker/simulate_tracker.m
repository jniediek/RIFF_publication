function seq = simulate_tracker()

%%% Function that opens an raw .tif file and performs tracking of an
%%% object.
    close all;
    [file_name,~] = uigetfile('*.tif','Select Movie');
    info = imfinfo(file_name);
    len = length(info);
    h1 = imshow(imread(file_name, 1));
    hold on;
    bg = create_bg(imread(file_name, 1));
    bg = uint8(filter2(fspecial('average', 3), bg));

    
    rat_loc = plot(100/2, 100/2, '*r', 'MarkerSize', 15);
    min_size_thr = 30;
    max_size_thr = 1000;
    rat_center = [0, 0];
    blob_ar= 0;
    bin = 2;
    count = 0;
    seq = [];
    for i = 1:len
        frame = imread(file_name, i, 'Info', info);
        set(h1, 'CData', frame);
        
        dI = frame - bg;
        dI_thr = dI > 2^7;
        track = regionprops(dI_thr, 'Centroid', 'Area');
        rat_center = [-1 -1];
        if(size(track, 1) ~=0 ) % Only if No. of blobs > 0
            [blob_ar, ind] = max([track.Area]);
            if(blob_ar > (min_size_thr/4))   % Only if the biggest blob is above reasonable THR, binned to 2X2
                rat_center = (track(ind).Centroid)*2; % mult. by 2 to recreate non-binned indeces
            else
                count = count + 1;
                seq = [seq i];
            end
        end
        
        delete(rat_loc);
        if(rat_center(1) == -1)
            rat_loc = plot(1, 1, 'g*', 'MarkerSize', 30);
        else
            rat_loc = plot(rat_center(1)/bin, rat_center(2)/bin, 'g*', 'MarkerSize', 10, 'LineWidth', 2);
        end
        drawnow;
%         pause(0.2);
    end
    disp(count);
end

function [bg] = create_bg(bg)
    area = imfreehand('Closed', 'true');    % Mark the rat
    BW = area.createMask;
    [bg_x, bg_y] = getpts;  % Get background area
    BW_color = uint8(BW)*(10 + mean(mean(bg((round(bg_y)-2):(round(bg_y)+2), (round(bg_x)-2):(round(bg_x)+2)))));    % paint mask in mean value of the bg
    bg = bg.*uint8(1-BW) + BW_color;
    delete(area);
end