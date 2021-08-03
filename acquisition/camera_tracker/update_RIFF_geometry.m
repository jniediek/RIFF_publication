function [RIFF_geo] = update_RIFF_geometry()

% UPDATE_RIFF_GEOMETRY uses user inputs to recalc center of the riff, the
% mask of the circle and the port locations. The results are stored in
% 'RIFF_geometry.mat' file.
% 
% Usage:
%     >> [RIFF_geo] = update_RIFF_geometry()
%  
% Inputs:
%     
% Output:
%     RIFF_geo - struct that stores {port_x, port_y, r, mask, c_point}


    [file_name, d] = uigetfile('*.tif','Pick latest image of the RIFF', 'C:\logging_data');
    if isequal(file_name,0) || isequal(d,0) % User cancels 
    	disp('==== RIFF geometry update canceled by user ====');
        RIFF_geo = []; % Usefull for future check of 'isempty(RIFF_geo)'
        return;
    end
    frame = imread([d '/' file_name]);
    if(size(frame, 1) ~= 480) 
        frame = frame(1:2:end, 1:2:end);
    end
    [port_x, port_y] = get_six_points(frame);
    [c_x, c_y, r] = calc_center_points(port_x, port_y);
    c_point = [c_x, c_y];
    mask = get_mask(frame, c_x, c_y, r);
    
    h1 = figure;
    imshow(frame.*mask, 'Border', 'tight');
    set(h1, 'units', 'normalized', 'outerposition', [0.05 0.05 0.9 0.9]);
    hold on;
    plot(port_x, port_y, 'r*');
    plot(c_x, c_y, 'g.', 'LineWidth', 3);
    ports = [port_x port_y];
    text(20, 20, 'Close figure to continue', 'FontSize', 20,...
                        'FontWeight', 'bold', 'color', 'red');
    uiwait(h1);     % Let the user observe the result and wait for his response
    RIFF_geo = struct('ports', ports, 'r', r, 'mask', mask,...
                      'c_point', c_point, 'bg_frame', frame);
%     if(exist('isDiv') && isDiv)
%         update_RIFF_walls(RIFF_geo, RIFF_geo.frame);
%     end
end

function [x_arr, y_arr] = get_six_points(frame)
% GET_SIX_POINTS prompts user to define six points that define th port
% location. Each point is a center between the two ports (food&water)
    h1 = figure;
    imshow(frame, 'Border', 'tight');
    set(h1, 'units', 'normalized', 'outerposition', [0.05 0.05 0.9 0.9]);
    hold on;
    text(20, 20, 'Click mid points between each pair of ports',...
                  'FontSize', 20, 'FontWeight', 'bold', 'color', 'red');
    text(390, 90, 'Start here!',...
                  'FontSize', 20, 'FontWeight', 'bold', 'color', 'red');
    [x_arr ,y_arr] = getpts;
    close(h1);
end

function [c_x, c_y, r] = calc_center_points(arr_x, arr_y)
%CALC_CENTER_POINT calculates the center of the RIFF based on the port
%locations.
    c_x = 0;
    c_y = 0;
    for i = 1:3
        mean_x = (arr_x(i)+arr_x(i+3))/2;
        mean_y = (arr_y(i)+arr_y(i+3))/2;
        c_x = c_x + mean_x;
        c_y = c_y + mean_y;
    end
    c_x = c_x / 3;
    c_y = c_y / 3;
    
    radii = pdist2([c_x c_y], [arr_x arr_y]);
    r = mean(radii) + 10;   % provide 10 spare pixels
end

function mask = get_mask(frame, c_x, c_y, r)
% GET_MASK creates black circular mask around the RIFF of size 640x480,
% such that each [frame.*mask] will produce only the ROI of the RIFF.
    imageSize = size(frame);
    [xx,yy] = ndgrid((1:imageSize(1))-c_y,(1:imageSize(2))-c_x);
    mask = uint8((xx.^2 + yy.^2)<r^2);
end