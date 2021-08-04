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
    %
    % ==> Externalized from RIFF_player_nightRIFF on 23.08.20 by alexkaz
    %
    % *    *    Created by AlexKaz 23.08.20

    [theta, rs] = cart2pol(loc_x, loc_y);
    angs = wrapTo360(rad2deg(theta));
end