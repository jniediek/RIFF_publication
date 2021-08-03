function frame = imRemoveSpots(frame)
    h1 = figure;
    h2 = imshow(frame, 'Border', 'tight');
    set(h1, 'units','normalized','outerposition',[0.05 0.05 0.9 0.9]);
    while true
        h_temp = text(20, 20, 'Drag an elipse around the rat', 'FontSize', 20, 'FontWeight', 'bold', 'color', 'red');
        area = imfreehand('Closed', 'true');    % Mark the rat
        if(isempty(area))   % area selection aborted
            break;
        end
        delete(h_temp);
        BW = area.createMask;
        delete(area);
        h_temp = text(20, 20, 'Double click on an empty RIFF floor', 'FontSize', 20, 'FontWeight', 'bold', 'color', 'red');
        [bg_x, bg_y] = getpts;  % Get background area
        if(isempty(bg_x))   % bg selection aborted
            break;
        end
        delete(h_temp);        
        BW_color = uint8(BW)*(10 + mean(mean(frame((round(bg_y)-2):(round(bg_y)+2), (round(bg_x)-2):(round(bg_x)+2)))));    % paint mask in mean value of the bg
        frame = frame.*uint8(1-BW) + BW_color; % remove the rat from bg and paint same area with the bg values
        set(h2, 'CData', frame);
    end
    try % User can end removing spots from frame by closing the image, so close may fail.
        close(h1);
    catch
    end
end