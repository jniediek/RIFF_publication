function [behavior_struct_arr, NA_FR_arr] = create_aligned_times(t_sim_times, t_sound, NA_db, t_state)
% Function create_aligned_times creates a cell array of structs, each corresponding to one window of the
% simulation. The window length are defined based on the predefined FPS.
% 
% Inputs:
%     t_sim_times - ((FPSxN+1) x 1 float) -  The interpolated times of the simulation pivot times
%     t_behavior  - (M x 1 floats) - Behavior times, interpolated to fit the SNR behavior triggers
%     NA_db     - ...
%     t_state     - (J x 1 floats) - State times as registered by the SNR
% 
% Outputs:
%     db - ((FPSxN) x 1 cell array of structs) - Each struct corresponds to a single simulation cycle,
%          which is coupled to one or more consecutive frames.
% 
% Examples:
%     >> t_cell_aligned = create_aligned_times(t_cam_times_inter, t_behavior, t_sound, t_state);

%     state_sound_cell_arr = cell(1, length(t_cam)-1);
    behavior_struct_arr = cell(1, length(t_sim_times)-1);
    NA_FR_arr = zeros(length(NA_db), length(t_sim_times)-1);
    
    curr_ind_state = 1;
    curr_ind_sound = 1;
    
    for i = 1:(length(t_sim_times)-1)  % affiliate triggers to the forecomming frame
        curr_t_0 = t_sim_times(i);
        curr_t_1 = t_sim_times(i+1);
        curr_states_inds = [];
        while (curr_ind_state <= length(t_state)) && (t_state(curr_ind_state) <= curr_t_1)
            if t_state(curr_ind_state) >= curr_t_0
                curr_states_inds = [curr_states_inds curr_ind_state];
            end
            curr_ind_state = curr_ind_state + 1;
        end
        
        curr_sounds_inds = [];
        while (curr_ind_sound <= length(t_sound)) && (t_sound(curr_ind_sound) <= curr_t_1)
            if t_sound(curr_ind_sound) >= curr_t_0
                curr_sounds_inds = [curr_sounds_inds curr_ind_sound];
            end
            curr_ind_sound = curr_ind_sound + 1;
        end
        
        curr_db = struct('states_inds', curr_states_inds, ...
                  'sounds_inds', curr_sounds_inds, ...
                  'cam_interp_t', curr_t_0, ...
                  'cam_interp_ind', i+1);
        behavior_struct_arr{i} = curr_db;
        
        % Calc. spikes per each bin, for each electrode
        for j = 1:length(NA_db)  % TODO: Speed up from O(N^2)  -> O(N), with chronological pointer, as in sound and states
            NA_FR_arr(j, i) = sum((NA_db(j).sp_SNR_ts > curr_t_0) & (NA_db(j).sp_SNR_ts < curr_t_1));
        end
    end
    behavior_struct_arr = [behavior_struct_arr{:}];
end