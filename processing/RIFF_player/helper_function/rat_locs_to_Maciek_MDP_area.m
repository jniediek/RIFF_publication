function [area_num, area_type, rat_angs, rat_rs] = rat_locs_to_Maciek_MDP_area(rat_locs, ar_ports)

    % Function rat_locs_to_Maciek_MDP_area calculates the MDP spatial state of the rat out of its
    % cartesian location.
    % 
    % ASSUMPTION:
    %     # All input value are given in pixels as produced by the camera, binned to [480x640]
    % 
    % Inputs:
    %     rat_locs - (Nx2 matrix) - locations of rats on the RIFF image, in pixels (binned, [1, 640])
    %     ar_ports - (6x2 matrix) - location of the interactive areas, in binned pixels
    % 
    % Outputs:
    %     area_num - (Nx1) - numbers of the sixtyles, {1..6}
    %     area_type - (Nx1) - area types {A,B,C,D}
    %     rat_angs - (Nx1) - angles in radius, wrapped to 360 of all points
    %     rat_rs - (Nx1) - distance of all points from the origin in pixels
    %
    %   * * AlexKaz 20/03/19 * *

    [im_rot, ar_center, ar_r, ar_ports] = calc_rot_and_shift(ar_ports);
    rat_locs = rat_locs - ar_center;
    
    % Convert rat locs to deg+rads
    [rat_angs, rat_rs] = get_ang_and_rad(rat_locs(:, 1), rat_locs(:, 2));
    rat_angs = rat_angs - im_rot;
    
    [area_num, area_type] = get_areas_from_degs(rat_angs, rat_rs, ar_r);
end

function [area_num, area_type] = get_areas_from_degs(rat_angs, rat_rs, ar_r)

    % Function get_areas_from_degs calculates the area {A, B, C, D} and the sixtyle {1...6}
    % out of the polar coordinates of the points.
    % The function assumes the logic of Maciek MDP
    % 
    % Inputs:
    %     rat_angs - (Nx1) - angles in radius, wrapped to 360 of all points
    %     rat_rs - (Nx1) - distance of all points from the origin in pixels
    %     ar_r - (scalar) - arena radius in pixels
    % 
    % Outputs:
    %     area_num - (Nx1) - numbers of the sixtyles, {1..6}
    %     area_type - (Nx1) - area types {A,B,C,D}

    OUTER_R = ar_r;
    
    D_WIDTH = 38; % in CM, according to '4th_[hase_Scheme_RIFF_appetitive_aversive_6tastes.pdf'
    B_WIDTH = 25;
    A_WIDTH = 17;
    TOTAL_R_CM = D_WIDTH + B_WIDTH + A_WIDTH;
    LARGE_R = ar_r * (D_WIDTH+B_WIDTH)/TOTAL_R_CM;
    SMALL_R = ar_r * (D_WIDTH)/TOTAL_R_CM;
    
    ANG_C = 27; % Width of each pizza slice, in deg
    ANG_AB = 33;
    
    ANG_START_A1 = 360 - (ANG_AB/2 + ANG_AB + ANG_C);   % Angular point where area 1 starts,
                                                        % clocwise from mid area 2, in degs
    
    area_type = zeros(1, length(rat_angs));
    
    % Define area types: A, B, C, D
    rel_rat_angs = wrapTo360(rat_angs - ANG_START_A1);  % Shift angles to start from A1
    in_c_inds = mod(rel_rat_angs, 60) > ANG_AB;         % Find all C slices
    area_type(in_c_inds) = 3;                           % Mark 'C' areas by 3
    area_type(~in_c_inds & (rat_rs > LARGE_R)) = 1;     % Mark 'A' areas by 1
    area_type(~in_c_inds & (rat_rs < LARGE_R)) = 2;     % Mark 'B' areas by 2
    area_type(rat_rs < SMALL_R) = 4;                    % Mark all central as D
    
    % Define numbers of areas, 1-6
    rel_rat_angs = wrapTo360(rat_angs - 270);           % Shift angles to mid upper C
    area_num = ceil(rel_rat_angs/60);                   % Count 60deg pizza slices
end

function [im_rot, ar_center, ar_r, ar_ports_shifted] = calc_rot_and_shift(ar_ports)

    % Function calc_rot_and_shift calculates the center of the arena, the rorarion of the camera
    % relative to the scheme and centralizes the ports around the origin.
    % 
    % Inputs:
    %     ar_ports - (6x2 matrix, raw pixel values) - pixel values of the active areas
    % 
    % Outputs:
    %     im_rot - (scalar) - rotation of the camera around the origin, degs
    %     ar_center - (2x1) - location of the arena center relative to the 480x640 image
    %     ar_r - (scalar) - radius of the arena
    %     ar_ports_shifted - (6x2 matrix) - locations of the active areas after recentering aroung the origin

    ar_center = mean(ar_ports, 1);                      % Find middle of the arena
    ar_ports_shifted = ar_ports - ar_center;            % Shift all port locations to span around the origin
    [port_degs, ar_r] = get_ang_and_rad(ar_ports_shifted(:, 1), ar_ports_shifted(:, 2));
    
    % Sort port angles and find the first one
    [~, inds] = sort(port_degs + 60, 'ascend');         % Sort port locs clock-wise from area 1
    port_degs = port_degs(inds); 
    im_rot = port_degs(1) - 360*(port_degs(1) < 0);     % Calc the camera rotation
    ar_r = mean(ar_r);
end

function [angs, rs] = get_ang_and_rad(loc_x, loc_y)

    % Function get_ang_and_rad converts the provided X and Y locations to polar coordinates
    % 
    % Inputs:
    %     loc_x - (Nx1 matrix) - pixel X locations
    %     loc_y - (Nx1 matrix) - pixel Y locations
    % 
    % Outputs:
    %     angs - (Nx1 matrix) - angle of the point in degrees, wrapped to 360
    %     rs - (Nx1 matrix) - Radius of each point, in pixels
    % 
    % Example:
    %     >> [angs, rs] = get_ang_and_rad(loc_x, loc_y);

    [theta, rs] = cart2pol(loc_x, loc_y);
    angs = wrapTo360(rad2deg(theta));
end