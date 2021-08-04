function [t_sim_times, cam_inds] = make_ind_ars_for_triggers(t_behavior, t_sound, t_camera, t_state)

% Function make_ind_ars_for_triggers sub-samples the 30FPS frame stream to 10FPS sequence, that is 
% found to be empirically optimal for both replay and compactness of data representation and storage.
% The function first trims the unneeded frames (that come before or after the other trig rec window)
% and then down-samples to 10FPS. The input t_camera might be not exact 30FPS due to dropped frames.
% This issue is taken to consediration when picking frames for the 10FPS grid.
% 
% Inputs:
%     t_camera    - (L x 1 floats) - Camera frame times, already interpolated to 30FPS based on SNR times
%     t_behavior  - (M x 1 floats) - Behavior times, interpolated to fit the SNR behavior triggers
%     t_sound     - (K x 1 floats) - Sound triggers as registered by the SNR
%     t_state     - (J x 1 floats) - State times as registered by the SNR
% 
% Outputs:
%     t_cam_times_inter - (~L/3 x 1 floats) - Sub-sampled time-series, ~30FPS -> rigid precise 10FPS
%     t_sim_times  -  (L x 1 indices) - Indices of frames that are chosen for the sub-sampled representation.
% 
% Example:
%     >> t_cam_times_inter = make_ind_ars_for_triggers(t_behavior, t_sound, t_camera, t_state);

    % Find the start and the end time of the experiment data of all types = all systems are on
%     t_0 = max([t_behavior(1), t_sound(1), t_camera(1), t_state(1)]);
    if size(t_camera, 2) == 1
        t_camera = t_camera';
    end
    t_0 = t_camera(1);
    % JN 2020-01-08, agreed with AP and AK that it's enough to take the
    % camera end here
    t_end = t_camera(end);
    %t_end = min([t_behavior(end), t_sound(end), t_camera(end), t_state(end)]); 
    
    % Find the first index of the camera triggers that has all other corresponding triggers.
    [~, cam_ind_start] = find(t_camera <= t_0, 1, 'last');
    [~, cam_ind_end] = find(t_camera <= t_end, 1, 'last');
    t_cam_inds = cam_ind_start:cam_ind_end;
    t_cam_times = t_camera(t_cam_inds);
    SIM_FPS = 10;  % The FPS of the RIFF_player visualizer.
    t_sim_times = t_cam_times(1):(1/SIM_FPS):t_cam_times(end);  % The rigid grid of 10FPS for the simulation
%     [t_cam_times_inter, cam_inds] = interpolate_frame_times(t_cam_times, FPS_simulation);
    [~, cam_inds] = custom_round(t_cam_times, t_sim_times);  % Find closest frame t to each grid pivot - get frames index
    
%     plot(t_cam_times_inter,ones(size(t_cam_times_inter)) + 2,'r*');
    
    % ============ Local helper functions ==============
    
    function [t_cam_times_interp, cam_inds] = interpolate_frame_times(t_cam_times, FPS_simulation)
    % Function interpolate_frame_times interpolates the array of camera triggers (1 Hrz) to the required
    % FPS. This process is required to assess the approximate times of the other 29 frames in the 30Hrz
    % rec.
    % 
    % Inputs:
    %     t_cam_times - (N x 1 float array) - The times of trigs as registered by the SNR
    %     FPS_simulation - (int) - Number of frames per second the simulation would like to produce
    % 
    % Outputs:
    %     t_cam_times_interp - ((FPS*N + 1) x 1 float) - the interpolated array of times
    % 
    % Example:
    %     >> t_cam_times_interp = interpolate_frame_times(t_cam_times, FPS_simulation);
    %
    % ==> Externalized from RIFF_player_nightRIFF on 23.08.20 by alexkaz
    %
    % *    *    Created by AlexKaz 23.08.20
    
        %%% Old version: Takes every third frame - but frames might get lost or shifted
        % x = 1:length(t_cam_times);
        % x_interp = 1:(1/FPS_simulation):length(t_cam_times);
        % t_cam_times_interp = interp1(x, t_cam_times, x_interp, 'spline');
        
        %%% New version: Created solid 1/FPS grid
        c_t1 = t_cam_times(1);
        c_t2 = t_cam_times(end);
        arr_t = c_t1:(1/FPS_simulation):c_t2;
        [~, inds] = custom_round(arr_t, t_cam_times);
        cam_inds = [true diff(inds) > 0];
        t_cam_times_interp = t_cam_times(cam_inds);
    end
end
