function [slices] = update_RIFF_walls(last_session_db)

% UPDATE_RIFF_WALLS updates the locations dividing walls inside the RIFF
% 
% Usage:
%     >> last_session_db = load('session_db.mat');
%     >> slices = update_RIFF_walls(last_session_db);
% 
% Inputs:
%	 RIFF_geo - Struct that stores geometry of the RIFF, as outputed by
%               'update_RIFF_geometry.m'
% 
% Outputs:
%     slices - The walls defined by the points, and the signs that represent
%     location relative to center.

    c_p          = last_session_db.c_point;
    mask         = last_session_db.mask;
    ports        = last_session_db.ports;
    frame        = last_session_db.bg_frame;
    frame_masked = mask .* frame;
    
    h1 = figure; imshow(frame_masked, 'border', 'tight');
    set(h1, 'units','normalized','outerposition',[0.05 0.05 0.9 0.9]);
    hold on;
    slices = cell(1, 3);
    colors = ['g', 'r', 'y'];
    h_temp = text(20, 20, 'Pick area No. - ORDER MATTERS',...
                  'FontSize', 20, 'FontWeight', 'bold', 'color', 'red');
    for i = 1:3
        text((ports(2*i - 1, 1) + ports(2*i, 1)) / 2, (ports(2*i - 1, 2) + ports(2*i, 2)) / 2, num2str(i)',...
             'FontSize', 20, 'FontWeight', 'bold', 'color', colors(i));
    end
    % Get separation from the user and calculate relations to the center&ports
    for i = 1:3
        [x_arr,y_arr] = ginput(3);
        plot(x_arr, y_arr, colors(i), 'LineWIdth', 4);
        % check location of center relative to the two lines
        [bools] = calc_sign(c_p, x_arr, y_arr);
        slices{i} = struct('pts', [x_arr y_arr], 'signs', bools);
    end
    delete(h_temp);
    text(20, 20, 'Close figure to continue', 'FontSize', 20,...
                        'FontWeight', 'bold', 'color', 'red');
    uiwait(h1);
%     while true
%         [x ,y] = getpts;
%         if(isempty(x))
%             break;
%         end
%         [slice_id] = find_loc_of_point(x, y, c_p, radius, slices);
%         disp(['==== location ' num2str(slice_id) ' ======']);
%     end
   
end


function [bools] = calc_sign(p, x_arr, y_arr)
%%% CALC_SIGN helper function that calculates relative locations of a point
%   P from the two lines defined by the 3 points.
    bools = [0 0];
    bools(1) = ((p(2)-y_arr(1)) < (y_arr(2)-y_arr(1))/(x_arr(2)-x_arr(1))*(p(1)-x_arr(1)));
    bools(2) = ((p(2)-y_arr(2)) < (y_arr(3)-y_arr(2))/(x_arr(3)-x_arr(2))*(p(1)-x_arr(2)));
end

%%  Automatic identification of the walls - not completed code
% %% Find lines
% BW = edge(frame_masked > 240,'log');
% [H,theta,rho] = hough(BW);
% P = houghpeaks(H, 20, 'threshold', ceil(0.001 * max(H(:))));
% lines = houghlines(BW, theta, rho ,P ,'FillGap',10 ,'MinLength', 50);
% 
% %% show ROUGH analysis
% figure;
% imshow(H,[],'XData',theta,'YData',rho,'InitialMagnification','fit');
% axis on, axis normal, hold on;
% plot(theta(P(:,2)),rho(P(:,1)),'s','color','white');
% xlabel('\theta'), ylabel('\rho');
% 
% 
% %% print lines
% figure, imshow(BW), hold on
% max_len = 0;
% for k = 1:length(lines)
%    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'yellow');
%    plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'red');
% 
%    % Determine the endpoints of the longest line segment
%    len = norm(lines(k).point1 - lines(k).point2);
%    if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%    end
% end