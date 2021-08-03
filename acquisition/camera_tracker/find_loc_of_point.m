function [slice_id] = find_loc_of_point(p, c_p, r, slices)

% FIND_LOC_OF_POINT finds the RIFF slice that the point belongs to, according
% to the geometry of the RIFF and the internal wall locations.
% 
% Usage:
%     >> [x, y] = getpts;   RIFF_geo = load('RIFF_geometry.mat');  slices = load('RIFF_slices', 'slices');
%     >> [slice_id] = FIND_LOC_OF_POINT([x, y], RIFF_geo.c_p, RIFF_geo.r, slices)
% 
% Input:
%     p - a single point [x y]
%     c_p - center of the RIFF as recieved by RIFF_geo.c_point.
%     r - Radius of the RIFF as saved in RIFF_geo.r.
%     slices - The points and relations to the center of the riff as created
%               in 'update_RIFF_walls.m'
% 
% Output:
%     slice_id - index of the right slice

    for i = 1:3
        loc = slices{i};
        s = calc_sign(p, loc.pts(:, 1), loc.pts(:, 2));
        if(isequal(~s, loc.signs) && (pdist2(p, c_p) < r))
            slice_id = i;
            break;
        end
        slice_id = -1;
%         if(isequal(~s, loc.signs) && (pdist2([x, y], c_p) < r))
%             disp(['Point is in slice ' num2str(i)]);
%         else
%             disp(['Point is NOT in slice ' num2str(i)]);
%         end
    end
end

function [bools] = calc_sign(p, x_arr, y_arr)
%%% CALC_SIGN helper function that calculates relative locations of a point
%   P from the two lines defined by the 3 points.
    bools = [0 0];
    bools(1) = ((p(2)-y_arr(1)) < (y_arr(2)-y_arr(1))/(x_arr(2)-x_arr(1))*(p(1)-x_arr(1)));
    bools(2) = ((p(2)-y_arr(2)) < (y_arr(3)-y_arr(2))/(x_arr(3)-x_arr(2))*(p(1)-x_arr(2)));
end