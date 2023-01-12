function flatten_single_experiment(full_exp_path, rat_no)
    
    % JN 2021-02-12
    sampling_rate = 32000;
    half_window_silence_sec = 0.005; % 5 ms, this is hard-coded in `flatten_noise_areas.m`
   
    % Function flatten_single_experiment() creates a flattened DB for a single RIFF processed experiment.
    % The function operates on the outputs of the pipeline, including full image processing.
    % 
    % Inputs:
    %     full_exp_path - (str) - Full path to the pipeline output.
    %     rat_no - (scalar) - Rat No. as imprinted into the file-system
    % 
    % Outputs:
    %     None - The flat DB file is stored in the experiment folder
    % 
    % Examples:
    %     >> exp_path = '';
    %     >> rat_no = 6;
    %     >> flatten_single_experiment(exp_path, rat_no)
    % 
    % *  *  Written by AlexKaz 08.20

    if ~exist(full_exp_path, 'dir')  % Validate existance of folder 
        disp("Can't find experiment: " + full_exp_path + ". Skipping...");
        return;
    end
    
    temp = dir(fullfile(full_exp_path, ['rat_' num2str(rat_no)]));  % Get the directories
    names = {temp.name};
    rat_dir = fullfile(full_exp_path, ['rat_' num2str(rat_no)], names{endsWith(names, '_Behavior')});
    
    
    % ===== Load all data types =====
    
    sound_table = load_sound_table(rat_dir);
    t_sound = sound_table.start_t';
    [behave_struct, t_behavior] = load_behavior(rat_dir);
    [output_db] = parse_camera(rat_dir);
    t_camera = output_db.t_frames;
    [maestro_states, t_state] = parse_maestro(rat_dir);
    [t_sim_times, cam_inds] = make_ind_ars_for_triggers(t_behavior, t_sound, t_camera, t_state);
    cam_inds = cam_inds(1:end-1); % Hamsa law - N pivots, N-1 values
    
    
    do_load_NA_big = false;  % For the flattened data skip the large_NA.bin loading
    [data.NA_db, data.NA_mdata, data.NA_raw_db, ~, data.NA_ch_num] = load_NA(rat_dir, do_load_NA_big);
    
    
    data.image_arr = output_db.image_arr(:, :, cam_inds);
    data.LED_arr = output_db.LED_arr(cam_inds);
    data.loc_arr = output_db.loc_arr(cam_inds, :);
    data.bg_image = output_db.bg_image;
    data.area_num = output_db.area_num(cam_inds);
    data.area_type = output_db.area_type(cam_inds);
    data.rat_angs = output_db.rat_angs(cam_inds);
    data.rat_rs = output_db.rat_rs(cam_inds);
    data.subsampling_inds = cam_inds;
    data.first_subsample_ind = output_db.first_led_onset_ind;
    data.t_camera_full = output_db.t_frames;
    data.t_camera = t_camera;
    
    % == Load rat directions, if exist ===
    if exist(fullfile(rat_dir, 'predicted_rat_body_points.mat'), 'file')
        [out_db] = load_body_direcs(rat_dir, data.first_subsample_ind, data.subsampling_inds);
        data.rat_head_direcs = out_db.rat_head_direcs;
        data.rat_body_direcs = out_db.rat_body_direcs;
        data.base_locs = out_db.base_locs;
        data.neck_locs = out_db.neck_locs;
        data.nose_locs = out_db.nose_locs;
    end
    
    [data.SNR_IND_cell_arr, data.NA_FR_arr] = create_aligned_times(t_sim_times, t_sound, data.NA_db, t_state);
    % JN 2021-02-12
    % load the relevant information for the silenced times
    % CONT HERE WITH RAT NUMBER PATH
    rat_folder = fullfile(full_exp_path, sprintf('rat_%d', rat_no));
    silenced_times = load_silenced_times(rat_folder, sampling_rate);
    silence_starts = silenced_times - half_window_silence_sec;
    silence_stops = silenced_times + half_window_silence_sec;
    
    silenced_times_binned = zeros(length(t_sim_times) - 1, 1);
    silenced_percent_binned = silenced_times_binned;
    kk = [];
    for i = 1:(length(t_sim_times) - 1)
        t0 = t_sim_times(i);
        t1 = t_sim_times(i + 1);
        
        % if any start or stop falls into the bin, mark it as silenced
        % this could be optimized using growing indices.
        if any((silence_starts >= t0) & (silence_starts <= t1))
            silenced_times_binned(i) = 1;
        elseif any((silence_stops >= t0) & (silence_stops <= t1))
            silenced_times_binned(i) = 1;
        end
        
        %added by AP, 210421
        % calculate the percent of time each bin was silenced
        start_idx = find((silence_starts >= t0) & (silence_starts <= t1));
        stop_idx = find((silence_stops >= t0) & (silence_stops <= t1));

        if isempty(start_idx) && isempty(stop_idx)
            silenced_percent_binned(i) = 0;
            continue;
        end
        times = [silence_starts(start_idx); silence_stops(stop_idx)];
        tags = [ones(size(start_idx)); zeros(size(stop_idx))];
        T = table(times,tags);
        T = sortrows(T,'times');        
        l_start = find((T.tags == 0 & T.times-t0 < half_window_silence_sec*2),1,'last');        
        check_extreme = find(~diff(T.tags),1,'first');        
        if isempty(l_start)
            l_start = 1;        
        elseif ~T.tags(check_extreme)
            silenced_percent_binned(i) = T.times(check_extreme+1) - t0;
            l_start = check_extreme + 2;             
        else
            silenced_percent_binned(i) = T.times(l_start) - t0;
            if l_start == height(T)
                continue;
            else
                l_start = l_start + 1;
            end
        end
        l_stop = find((T.tags == 1 & t1-T.times < half_window_silence_sec*2),1,'first'); 
        if isempty(l_stop)
            l_stop = height(T);       
        else
            silenced_percent_binned(i) = silenced_percent_binned(i) + t1 - T.times(l_stop);
            if l_stop == 1
                continue;
            else
                l_stop = l_stop - 1;
            end
        end
        sti = l_start;
        while sti < l_stop
            if ~T.tags(sti)
                silenced_percent_binned(i) = silenced_percent_binned(i) + T.times(sti)-T.times(sti-1);
                sti = sti + 1;
%                 error('something is wrong!');
            else
                if ~T.tags(sti+1)
                    silenced_percent_binned(i) = silenced_percent_binned(i) + half_window_silence_sec*2;
                    sti = sti + 2;
                else
                    eni = find(diff(T.tags(sti+1:end)) == 0,1,'first') + sti + 1;
                    if ~isempty(eni)
                        silenced_percent_binned(i) = silenced_percent_binned(i) + T.times(eni) - T.times(sti);
                        sti = eni+1;
                    else
                        silenced_percent_binned(i) = silenced_percent_binned(i) + T.times(l_stop+1) - T.times(sti);
                        sti = l_stop + 1;
                    end
                end
            end
        end
        silenced_percent_binned(i) = silenced_percent_binned(i)/(t1-t0);
        if silenced_percent_binned(i) > 1
            silenced_percent_binned(i) = 1;
            kk = [kk; i];
        end
    end
    
    data.silence_arr = silenced_times_binned;
    data.silence_percent = silenced_percent_binned;
    
    speed_arr = pdist1(double(data.loc_arr));
    speed_arr(speed_arr > 100) = 0;
    
    data.speed_arr = speed_arr;
    data.rat_dir = rat_dir;
    data.maestro_states = maestro_states;
    data.behave_struct = behave_struct;
    data.t_cam_times_inter = t_sim_times;
    data.t_sound = t_sound;
    data.t_state = t_state;
    data.t_camera = t_camera;
    data.t_behavior = t_behavior;
    data.sound_table = sound_table;
        
    % ===== Flatten the data =====
    
    [corr_db, mdata] = gather_correlation_statists(data);
    field_names = fields(corr_db);
    
    % Correct flipped vectors
    for i = 1:length(field_names)
        if size(corr_db.(field_names{i}), 2) > size(corr_db.(field_names{i}), 1)
            corr_db.(field_names{i}) = corr_db.(field_names{i})';
        end
    end
    
        % Add images
    if size(data.image_arr, 1) == 50
        corr_db.images = data.image_arr;
    elseif size(data.image_arr, 1) == 100
        corr_db.images = data.image_arr(1:2:end, 1:2:end, :);
    elseif size(data.image_arr, 1) == 200
        corr_db.images = data.image_arr(1:4:end, 1:4:end, :);
    else
        1; % Skip the image addition, no idea what is the image size...
    end
    
    % Add the mdata
    corr_db.mdata = mdata;
    
    % Remove behaviorally-unrelevant field + categorical arrays
    corr_db = rmfield(corr_db, {'LED_arr', 'area_num'});
    
    % Saving the data
%     save(fullfile(db_h.data.mdata.rat_dir, '..\flat_behav_DB.mat'), '-struct', 'corr_db', '-v7');  % Good for python 'loadmat'
	if ispc()
        save(fullfile(rat_dir, 'flat_behav_DB.mat'), '-struct', 'corr_db', '-nocompression');  % Good for python 'h5py'
    else
        save(fullfile(rat_dir, 'flat_behav_DB.mat'), '-struct', 'corr_db', '-v7.3'); 
    end
%	save(fullfile(rat_dir, 'flat_behav_DB.mat'), '-struct', 'corr_db', '-nocompression');  % Good for python 'h5py'
% 	save(fullfile(rat_dir, 'flat_behav_DB.mat'), '-struct', 'corr_db');  % Good for python 'h5py'

    disp("=== Flat DB file is created in " + rat_dir + " ===");
    
end
