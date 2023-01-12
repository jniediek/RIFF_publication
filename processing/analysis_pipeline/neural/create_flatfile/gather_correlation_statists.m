function [corr_db, mdata] = gather_correlation_statists(db)

    % Function gather_correlation_statists() produces flat db from a db of a single experiment,
    % as produced by the pipeline.
    % 
    % Inputs:
    %     db - (struct) - The db that holds the complex datastructure, as in db_h.data of the
    %                     RIFF_player_nightRIFF, or as produced by 'flatten_single_expeirment.m'
    % 
    % Outputs:
    %     corr_db - (struct) - 
    %     mdata - (struct) -
    % 
    % Examples:
    %     >> [corr_db, mdata] = gather_correlation_statists(db_h.data);   % As in RIFF_player_nightRIFF
    % 
    % ==> Externalized from RIFF_player_nightRIFF on 23.08.20 by alexkaz
    % 
    % *    *    Created by AlexKaz 23.08.20
    
    path_parts = split(db.rat_dir, filesep);
    experiment_type = path_parts{end-3};
    rat_no = str2double(path_parts{end-1}(end));
    exp_date = path_parts{end-2};
    
    if strcmp(experiment_type, 'Ana')
        msgbox('The behavioral fields are undefined for Ana`s experiments');
        error('The behavioral fields are undefined for Ana`s experiments');
    elseif strcmp(experiment_type, 'Maciej')
        %msgbox('The stat-gathering was not yet adapted to Maciek experiments');
	fprintf('Running type Maciej, this is only partially done\n');
       % error('The stat-gathering was not yet adapted to Maciek experiments');
    end
            
    corr_arr_len = length(db.SNR_IND_cell_arr);
    speed = db.speed_arr;
    accel = [0; diff(speed)];
    
    x = db.loc_arr(:, 1);
    y = db.loc_arr(:, 2);
    LED_arr = db.LED_arr';
    area_num = db.area_num;
    area_type = db.area_type;
    rat_angs = db.rat_angs;
    rat_rs = db.rat_rs;
    t_sim_in_SNR_units = db.t_cam_times_inter(1:end-1)'; % Hamsa law
    sim_init = t_sim_in_SNR_units(1);
    sim_end = db.t_cam_times_inter(end);
    
    % === Extract MDP/sound names ===
    sounds_names = string(unique(db.sound_table.soundname));
    if strcmp(experiment_type, 'Maciej')
        MDP_type_names = string(unique(db.maestro_states.areatype));
    elseif strcmp(experiment_type, 'nightRIFF')
        MDP_type_names = string(unique(db.maestro_states.type));
    end

    MDP_beh_names = string(unique(db.maestro_states.behavior));
    
    % === Create flat arrays ===
    sounds_speakers = zeros(corr_arr_len, 12);
    MDP_type_binary = zeros(corr_arr_len, length(MDP_type_names));
    MDP_beh_binary = zeros(corr_arr_len, length(MDP_beh_names));
    sounds_type_binary = zeros(corr_arr_len, length(sounds_names));
    beh_foods = zeros(corr_arr_len, 12);
    beh_nps = zeros(corr_arr_len, 12);
    beh_aps = zeros(corr_arr_len, 12);
    
    for i = 1:corr_arr_len
        % Extract sounds:
        sound_inds = db.SNR_IND_cell_arr(i).sounds_inds;
        if ~isempty(sound_inds)
            for j = 1:length(sound_inds)
                curr_sound_ind = sound_inds(j);
                curr_sound_name = string(db.sound_table.soundname(curr_sound_ind));
                sounds_type_binary(i, strcmp(sounds_names, curr_sound_name)) = 1;
                active_speakers = db.sound_table.speaker{curr_sound_ind};
                sounds_speakers(i, active_speakers) = 1;
            end         
        end
        
        % Extract states:
        state_inds = db.SNR_IND_cell_arr(i).states_inds;
        if ~isempty(state_inds)
            for j = 1:length(state_inds)
                curr_MDP_behav_name = string(db.maestro_states.behavior(state_inds(j)));
                MDP_beh_binary(i, strcmp(MDP_beh_names, curr_MDP_behav_name)) = 1;
                
                % MDP_type_binary has gaps or multiple datum at single index - due to high and/or low freq of state transition.
                if strcmp(experiment_type, 'Maciej')
                    curr_MDP_type_name = string(db.maestro_states.areatype(state_inds(j)));
                elseif strcmp(experiment_type, 'nightRIFF')
                    curr_MDP_type_name = string(db.maestro_states.type(state_inds(j)));
                end
                MDP_type_binary(i, strcmp(MDP_type_names, curr_MDP_type_name)) = 1;
            end
        end
    end
     
    % Extract behavior:
    for i = 1:12
        t = db.behave_struct.food_timings{i};
        t = t((t < sim_end) & (t > sim_init));
        [~, rel_inds] = custom_round(t_sim_in_SNR_units, t);
        beh_foods(rel_inds, i) = 1;
        
        t = db.behave_struct.beam_timings{i};
        t_init = t(1:2:end);  % NPs are registered upon onset and ofset as distinct events
        t_end = t(2:2:end);
        t_init = t_init((t_init < sim_end) & (t_init > sim_init));
        t_end = t_end((t_end < sim_end) & (t_end > sim_init));
        if (~isempty(t_init) && ~isempty(t_end) && (t_init(1) > t_end(1)))  % Remove first NP_end if the corresponding NP_init was before sim_init
            t_end = t_end(2:end);
        end
        if (~isempty(t_init) && ~isempty(t_end) && (t_init(end) > t_end(end)))  % Remove last NP_init if the NP exceeds sim_end
            t_init = t_init(1:end-1);
        end
        [~, np_on_inds] = custom_round(t_sim_in_SNR_units, t_init);
        [~, np_off_inds] = custom_round(t_sim_in_SNR_units, t_end);
        for j = 1:length(t_init)  % Set all NP values between on_ind and off_ind to 1
            beh_nps(np_on_inds(j):np_off_inds(j), i) = 1;
        end
        
        t = db.behave_struct.airpuff_timings{i};
        t = t((t < sim_end) & (t > sim_init));
        [~, rel_inds] = custom_round(t_sim_in_SNR_units, t);
        beh_aps(rel_inds, i) = 1;
    end
    
    % Make the categorical arrays into many binary arrays
    MDP_areanum_names = unique(area_num);
    MDP_areanum_binary = zeros(length(area_num), length(MDP_areanum_names));
    for i = 1:length(MDP_areanum_names)
        MDP_areanum_binary(:, i) = area_num == MDP_areanum_names(i);
    end
    
    MDP_areatype_names = unique(area_type);
    MDP_areatype_binary = zeros(length(area_type), length(MDP_areatype_names));
    for i = 1:length(MDP_areatype_names)
        MDP_areatype_binary(:, i) = area_type == MDP_areatype_names(i);
    end
    
    % === Compute t_init and t_end of trials ===
    if strcmp(experiment_type, 'nightRIFF')
        trial_init = db.maestro_states.start_t(db.maestro_states.type == 'center');
        types = db.maestro_states.type;
        times = db.maestro_states.start_t;
        trial_ends = trial_init*0;
        counter = 1;
        for i = 1:(length(types)-1)
            if (types(i) == 'NPWait') && (types(i+1) == 'wait')
                trial_ends(counter) = times(i+1);
                counter = counter + 1;
            end
        end
        
        % Remove the trials that were logged out of the simulation window
        trial_init = trial_init((trial_init < sim_end) & (trial_init > sim_init));
        trial_ends = trial_ends((trial_ends < sim_end) & (trial_ends > sim_init));
        if (trial_init(1) > trial_ends(1)) % First trial started before sim_init but ended after
            trial_ends = trial_ends(2:length(trial_ends));
        end
        if (trial_init(end) > trial_ends(end)) % Last trail started before sim_end but ended after
            trial_init = trial_init(1:length(trial_ends));
        end
        [~, trial_init_ind] = custom_round(t_sim_in_SNR_units, trial_init);
        [~, trial_end_ind] = custom_round(t_sim_in_SNR_units, trial_ends);
    end 
    
    % === Store the data in a struct ===
    
    corr_db = struct('speed', speed , ...
                    'accel', accel , ...
                    'x', x , ...
                    'y', y , ...
                    'LED_arr', LED_arr , ...
                    'area_num', area_num , ...
                    'rat_angs', rat_angs , ...
                    'rat_rs', rat_rs , ...
                    'sounds_speakers', sounds_speakers , ...
                    'beh_foods', beh_foods , ...
                    'beh_nps', beh_nps , ...
                    'beh_aps', beh_aps , ...
                    'MDP_areanum_binary', MDP_areanum_binary , ...
                    'MDP_areatype_binary', MDP_areatype_binary , ...
                    'sounds_type_binary', sounds_type_binary, ...
                    't_sim_in_SNR_units', t_sim_in_SNR_units, ...
                    'MDP_type_binary', MDP_type_binary, ...  % Has gaps or multiple datum at single index - due to high and/or low freq of state transition.
                    'MDP_beh_binary', MDP_beh_binary);
    
        mdata = struct('sounds_names', sounds_names, ...
                    'MDP_beh_names', MDP_beh_names, ...
                    'MDP_areanum_keys', MDP_areanum_names, ...
                    'MDP_type_names', MDP_type_names, ...
                    'MDP_areatype_names', MDP_areatype_names, ...
                    'exp_name', experiment_type, ...
                    'rat_no', rat_no, ...
                    'exp_date', exp_date, ...
                    'source_path', db.rat_dir);
        
    % ====  Add the body features =====
    if isfield(db, 'rat_body_direcs')
        corr_db.rat_body_direcs = db.rat_body_direcs;
        corr_db.rat_head_direcs = db.rat_head_direcs;
        corr_db.neck_locs = db.neck_locs;
        corr_db.nose_locs = db.nose_locs;
        corr_db.base_locs = db.base_locs;
        
        MIN_VALID_BODY_LENGTH = 7;  % Minimal bio-plausable body length that is allowed. Any smaller length is a false feature extraction from rat image.
        TURN_ANGLE = 60;            % Threshold for angle to be defined as turn. If the head is turned more than that from the body, the rat is in 'turn' mode

        body_len = (db.neck_locs - db.base_locs);
        body_len = sqrt(body_len(:, 1).^2 + body_len(:, 2).^2);
        is_legit_locs = body_len > MIN_VALID_BODY_LENGTH;
        turn_vals = wrapTo180(db.rat_head_direcs - db.rat_body_direcs);
        corr_db.right_turns_inds = (turn_vals > TURN_ANGLE) & is_legit_locs;
        corr_db.left_turns_inds = (turn_vals < -TURN_ANGLE) & is_legit_locs;
        corr_db.relative_turn_angles = turn_vals;
        
        mdata.MIN_VALID_BODY_LENGTH = MIN_VALID_BODY_LENGTH;
        mdata.TURN_ANGLE = TURN_ANGLE;
    end
    
    
    % ==== Add the NA ====
    if isfield(db, 'NA_FR_arr') && ~isempty(db.NA_FR_arr)
        corr_db.NA_FR = db.NA_FR_arr;        
        if isfield(db.NA_db, 'manual_tag')
            mdata.NA_manual_tags = {db.NA_db.manual_tag};
        end
        mdata.NA_spike_counts = [db.NA_db.spike_count];
        mdata.ch_num = [db.NA_db.ch_num];
        mdata.elec_num = [db.NA_db.elec_num];
    end            
    
    if isfield(db, 'silence_arr')
        corr_db.silenced = db.silence_arr;
        corr_db.silenced_percent = db.silence_percent; %added by AP, 210421
    end
    
    if strcmp(experiment_type, 'nightRIFF')  % Add the experiment-specific fields
        corr_db.trial_init_ind = trial_init_ind;
        corr_db.trial_end_ind = trial_end_ind;
        corr_db = rmfield(corr_db, 'beh_aps'); % There are no airpuffs
    end
end
