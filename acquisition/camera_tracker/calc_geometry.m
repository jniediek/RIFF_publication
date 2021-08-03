function [x, y, center_x, center_y, radius] = calc_geometry(doShow, handles)
%%% Function that calculates the radius and the center of the RIFF given
%   port location, stored in offline file 'six_mid_points_binned.mat'
    if(nargin > 1)  % When calc_geometry.m is called from the RatTracker, supplied by the 'handles' argument
        x = handles.last_session_h.ports(:, 1);
        y = handles.last_session_h.ports(:, 2);
    else % When 'handles' is not provided
        load('six_mid_points_binned.mat');
    end
    
    
    if(doShow)
        frame = rot90(imread('C:\logging_data\20-03-2017T\single_frame.tif',1), 2);
        h1 = figure;
        imshow(frame); hold on;
        h1 = plot(x, y, 'r.', 'MarkerSize', 25);
        c = {'r.', 'g.', 'y.'};
    end
    center_x = 0;
    center_y = 0;
    for i = 1:3
        mean_x = (x(i)+x(i+3))/2;
        mean_y = (y(i)+y(i+3))/2;
        if(doShow)
            plot(mean_x, mean_y, c{i}, 'MarkerSize', 10);
        end
        center_x = center_x + mean_x;
        center_y = center_y + mean_y;
    end
    center_x = center_x / 3;
    center_y = center_y / 3;
    
    radii = pdist2([center_x center_y], [x y]);
    radius = mean(radii);
    if(doShow)
        plot(center_x, center_y, '*', 'MarkerSize', 25);
        h1 = viscircles([center_x center_y], radius);
    end
end