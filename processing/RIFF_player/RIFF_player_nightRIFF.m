% The toolkit RIFF_player_nightRIFF.m replays a single experiments of the RIFF.
%
% Creating date: 21/02/2019     by AlexKaz

%   ============   Opening function    ==========================

function varargout = RIFF_player_nightRIFF(varargin)
% RIFF_PLAYER_NIGHTRIFF MATLAB code for RIFF_player_nightRIFF.fig
%      RIFF_PLAYER_NIGHTRIFF, by itself, creates a new RIFF_PLAYER_NIGHTRIFF or raises the existing
%      singleton*.
%
%      H = RIFF_PLAYER_NIGHTRIFF returns the handle to a new RIFF_PLAYER_NIGHTRIFF or the handle to
%      the existing singleton*.
%
%      RIFF_PLAYER_NIGHTRIFF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RIFF_PLAYER_NIGHTRIFF.M with the given input arguments.
%
%      RIFF_PLAYER_NIGHTRIFF('Property','Value',...) creates a new RIFF_PLAYER_NIGHTRIFF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RIFF_player_nightRIFF_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RIFF_player_nightRIFF_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RIFF_player_nightRIFF

% Last Modified by GUIDE v2.5 25-Dec-2022 23:51:39

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @RIFF_player_nightRIFF_OpeningFcn, ...
                       'gui_OutputFcn',  @RIFF_player_nightRIFF_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
% End initialization code - DO NOT EDIT
end

function RIFF_player_nightRIFF_OpeningFcn(hObject, ~, handles, varargin)
    global db_h timer_loc
    timer_loc = 0;
    handles.output = hObject;
    handles.state = struct('db_name', '', 'db_path', '', 'frame_ind', 1, 'traceOn', true,...
                           'heatmapOn', 0, 'hm_data', [], 'speed_max', 1, 'ImageOn', 1,...
                           'sound_UI_on', 0, 'fw_UI_on', 0, 'np_UI_on', 0, 'ap_UI_on', 0, ...
                           'im_bright_fact', 2);

    handles.h_plots = struct('h_rat_im', 0, 'h_rat_tail_scatter', 0,...
                             'h_rat_tail_solid', 0, 'h_rat_dot', 0);
                    
    db_h = DB_container();  % create an object of the data handler class
    
    db_h.data.arena_geometrical_db = 'RIFF_int_area_locations_181020.mat';
    handles.h_plots.slider = addlistener(handles.slider, 'Value', 'PostSet' , @slider_Callback);
    guidata(hObject, handles);
    
    handles.figure1.PaperPositionMode = 'auto';
end

function varargout = RIFF_player_nightRIFF_OutputFcn(~, ~, handles)
    varargout{1} = handles.output;
end

% ======================  Timers ==================================

function slider_Callback(~, event)
    handles = guidata(event.AffectedObject);
    handles.state.frame_ind = floor(get(handles.slider, 'Value'));
    handles = replot(handles);  % replot the image
    guidata(handles.picture_area, handles); % handles.picture_area is picked arbitrary as one of the GUI objects needed for GUIDATA(obj, handles)
end  % Called by slider Value change (mouse or programmatic)

function handles = replot(handles)
    global db_h
%     disp('%%% -> start of replot callback %%%');
    h_plots = handles.h_plots;
%     db_h = handles.db_h;
    curr_fr_ind = handles.state.frame_ind;
    tail_start = max(1, curr_fr_ind - handles.state.tail_len);
    
    % === DEBUG: Real-time display of allocentric stats - used to finetune the stat extraction ===
    if isfield(db_h.data, 'tr_direc')  % The stats are computed in the debug function. Run the function manually
        tr_dir = wrapTo360(rad2deg(db_h.data.tr_direc(curr_fr_ind)));
        body_dir = db_h.data.rat_body_direcs(curr_fr_ind);
        ddir = round(wrapTo180(body_dir - tr_dir), 1);
        handles.message_text.String = "tr-ang:" + round(tr_dir) + ...
                                          "|r:" + round(db_h.data.tr_rho(curr_fr_ind), 1) + ...
                                          "|dx:" + db_h.data.dx(curr_fr_ind) + ...
                                          "|dy:" + db_h.data.dy(curr_fr_ind) + ...
                                          "|ddir:" + ddir;
        if (abs(ddir) > 140) && (round(db_h.data.tr_rho(curr_fr_ind), 1) > 1.5)
            handles.message_text.BackgroundColor = [1, 0.9, 0.85];
        else
            handles.message_text.BackgroundColor = [0.9, 1, 0.75];
        end
    end
    % =============================================================
    
    curr_im = db_h.data.image_arr(:, :, curr_fr_ind);
    if size(curr_im, 1) == 50  % Case of nightRIFF 50x50 images, LED area is small
        curr_im(1:5, 1:5) = mean(curr_im(6:10, 1:5), 'all');  % Erase the LED from the live replay
    else   % Case of nightRIFF 100x100 images, LED area is bigger
        curr_im(1:10, 1:10) = mean(curr_im(11:20, 1:10), 'all');  % Erase the LED from the live replay
    end
    curr_loc_cam = db_h.data.loc_arr(curr_fr_ind, :);
%     curr_cam_t = db_h.data.SNR_IND_cell_arr(curr_fr_ind).cam_interp_t;
    
    x = curr_loc_cam(1);
    y = curr_loc_cam(2);
    
    c_tail = db_h.data.curr_traj_c(tail_start:curr_fr_ind);
    x_tail = db_h.data.loc_arr(tail_start:curr_fr_ind, 1);
    y_tail = db_h.data.loc_arr(tail_start:curr_fr_ind, 2);
    scatter_size = 30;
    mfalpha = 0.8;
%     scatter_size = (c_tail+1)*1;
    
    % Replot the tail using 'scatter' only on first call or when changing in size
    if (h_plots.h_rat_tail_scatter == 0) || (length(h_plots.h_rat_tail_scatter.XData) ~= length(x_tail))
        if(h_plots.h_rat_tail_scatter ~= 0)  % Don't try to delete the first value 0
            delete(h_plots.h_rat_tail_scatter);
            delete(h_plots.h_rat_tail_solid);
        end
        h_plots.h_rat_tail_solid = plot(handles.picture_area, x_tail, y_tail, 'color', [1 1 1]*0.3);
%         h_plots.h_rat_tail_scatter = scatter(handles.picture_area, x_tail, y_tail,...
%                                       zeros(length(x_tail), 1)+scatter_size, c_tail, 'filled');
        h_plots.h_rat_tail_scatter = scatter(handles.picture_area, x_tail, y_tail,...
                                      scatter_size, c_tail, 'filled', ...
                                      'MarkerFaceAlpha', mfalpha);
        set(handles.picture_area, 'CLim', [0 max(db_h.data.curr_traj_c)*3/4]);
    else
%         set(h_plots.h_rat_tail_scatter, 'XData', x_tail, 'YData', y_tail, 'CData', c_tail);
        set(h_plots.h_rat_tail_scatter, 'XData', x_tail, 'YData', y_tail, 'CData', c_tail,...
            'SizeData', scatter_size);
        set(h_plots.h_rat_tail_solid, 'XData', x_tail, 'YData', y_tail);
    end
    
    if(~handles.state.ImageOn)      % Represent rat location using *
        h_plots.h_rat_im.Visible = 'off';
        h_plots.h_rat_dot.Visible = 'on';
        h_plots.h_rat_dot.XData = x;  % plot the heads
        h_plots.h_rat_dot.YData = y;  % plot the heads
    else         % Represent rat location using the images
        h_plots.h_rat_im.Visible = 'on';
        h_plots.h_rat_dot.Visible = 'off';
        h_plots.h_rat_im.CData = imresize(cat(3, curr_im, curr_im, curr_im), [100, 100])*handles.state.im_bright_fact;
%             h_plots.h1h(i) = imshow(rect, 'Parent', handles.picture_area);
        h_plots.h_rat_im.XData = - 100/2 + double(x);   % Shift image in X axis
        h_plots.h_rat_im.YData = - 100/2 + double(y);   % Shift image in Y axis
    end
    
    if isfield(db_h.data, 'rat_body_direcs')
        move_body_quivers_and_point(handles);
    end
    
    handles = render_RIFF_interactions(handles);  % function edits the UI bits, to erase in next iter
%     if isfield(db_h.data, 'overview_fig') && isvalid(db_h.data.overview_fig(1))
    if isfield(handles, 'stat_fig') && isvalid(handles.stat_fig(1))
        time_window_button_Callback([], [], handles);
    end
%     pause(0.007);
%     set(handles.message_text, 'String', 'Movie Updated!!!');
    set(handles.percents_text, 'String', [num2str(round(100*curr_fr_ind/db_h.data.frame_n))...
        '%  |  Frame: ' num2str(curr_fr_ind) '  |  Tail:' num2str(handles.state.tail_len)...
        '  |  Time: ' datestr(datenum(0, 0, 0, 0, 0, curr_fr_ind/10),'HH:MM:SS.FFF')]);
    handles.h_plots = h_plots;
    
    if isfield(db_h.data, 'db_BRat')
        handles.ra_accel_text.String = num2str(db_h.data.db_BRat.accel_vec(curr_fr_ind));
        handles.ra_speed_text.String = num2str(db_h.data.db_BRat.speed_vec(curr_fr_ind));
        handles.ra_direc_text.String = num2str(db_h.data.db_BRat.direc_inds(curr_fr_ind));
        handles.ra_turn_text.String = num2str(db_h.data.db_BRat.turn_vec(curr_fr_ind));
        handles.ra_x_text.String = num2str(db_h.data.db_BRat.x_vec(curr_fr_ind));
        handles.ra_y_text.String = num2str(db_h.data.db_BRat.y_vec(curr_fr_ind));
    end
    
%     disp('%%% <- end of replot callback %%%');
end  % Called by slider_Callback

function timer_callback(~, ~, hObject)
    global counter db_h timer_loc
    if timer_loc == 1
        disp('violation!!!');
        return;
    end
    timer_loc = 1;
    tic
    handles = guidata(hObject); 
    new_val = round(handles.slider.Value + 1);
    if new_val > db_h.data.frame_n  % The slider is at the end, 
        stop(handles.tim);
        handles.message_text.String = 'Simulation ended!';
        play_button_Callback(handles.play_button, -77, handles);
        return;
    end
    handles.state.frame_ind = new_val;
    guidata(hObject, handles);
    handles.slider.Value = new_val; % replot() is called inside
%     clear handles new_val hObject;
%     counter = [counter toc];
    timer_loc = 0;
%     toc
end  % Called by the autoplay button

function handles = render_RIFF_interactions(handles)
    global db_h
    persistent beam_is_on sound_timer
    if isempty(beam_is_on)
        beam_is_on = false;
        sound_timer = 0;
    end
    curr_frame_ind = handles.state.frame_ind;
    if(curr_frame_ind == 1)
        return;
    end
    % Extract the global SNR time of the frame
    curr_frame_t = db_h.data.SNR_IND_cell_arr(curr_frame_ind).cam_interp_t;
    if(curr_frame_t > 1)
        prev_frame_t = db_h.data.SNR_IND_cell_arr(curr_frame_ind - 1).cam_interp_t;
    else
        prev_frame_t = curr_frame_t - 0.1;
    end
    
    % Check beam events
    if db_h.data.speed_arr(curr_frame_ind) > 6  % 04.04.21 hacky way to reset the nose poke: If rat runs, no NP
        for beam_ind = 1:12
            handles.(['np' num2str(beam_ind)]).Value = 0;
            handles.(['np' num2str(beam_ind) '_text']).String = '---';
        end
        handles.state.np_UI_on = 0;
        set(handles.h_rew_sound_circles.nosepokes, 'Visible', 'off');
        beam_is_on = false;
    else
        for beam_ind = 1:12
            curr_port_beam_ts = db_h.data.behave_struct.beam_timings{beam_ind};
            num_of_events = sum((curr_port_beam_ts > prev_frame_t) & (curr_port_beam_ts < curr_frame_t));
            if num_of_events > 0
                if mod(num_of_events, 2) == 1
                    beam_is_on = ~beam_is_on;
                    if beam_is_on
                        handles.(['np' num2str(beam_ind)]).Value = 1;
                        handles.(['np' num2str(beam_ind) '_text']).String = num2str(num_of_events);
                        handles.state.np_UI_on = 1;
                        handles.h_rew_sound_circles.nosepokes(beam_ind).Visible = 'on';
                    else
                        set(handles.h_rew_sound_circles.nosepokes, 'Visible', 'off');
                    end
                end

                break;
            end
        end
    end
    
    % Check airpuff events
    if(handles.state.ap_UI_on == 1)
        for ap_ind = 1:12
            handles.(['ap' num2str(ap_ind)]).Value = 0;
            handles.(['ap' num2str(ap_ind) '_text']).String = '---';
        end
        handles.state.ap_UI_on = 0;
    end
    for ap_ind = 1:12
        curr_port_ap_ts = db_h.data.behave_struct.airpuff_timings{ap_ind};
        num_of_events = sum((curr_port_ap_ts > prev_frame_t) & (curr_port_ap_ts < curr_frame_t));
        if num_of_events > 0
            handles.(['ap' num2str(ap_ind)]).Value = 1;
            handles.(['ap' num2str(ap_ind) '_text']).String = num2str(num_of_events);
            handles.state.ap_UI_on = 1;
        end
    end
    
    % Check food/water events
	if(handles.state.fw_UI_on == 1)
        for fw_ind = 1:6
            handles.(['f' num2str(fw_ind)]).Value = 0;
            handles.(['f' num2str(fw_ind) '_text']).String = '---';
            handles.(['w' num2str(fw_ind)]).Value = 0;
            handles.(['w' num2str(fw_ind) '_text']).String = '---';
        end
        set(handles.h_rew_sound_circles.rewards, 'Visible', 'off');
        handles.state.fw_UI_on = 0;
	end
    for food_ind = 1:6
        curr_port_f_ts = db_h.data.behave_struct.food_timings{food_ind*2 - 1};
        num_of_events = sum((curr_port_f_ts > prev_frame_t) & (curr_port_f_ts < curr_frame_t));
        if num_of_events > 0
            handles.(['f' num2str(food_ind)]).Value = 1;
            handles.(['f' num2str(food_ind) '_text']).String = num2str(num_of_events);
            handles.state.fw_UI_on = 1;
            handles.h_rew_sound_circles.rewards(2*(food_ind - 1) + 1).Visible = 'on'; % Show the colored circle near the port
        end
    end
    for water_ind = 1:6
        curr_port_w_ts = db_h.data.behave_struct.food_timings{water_ind*2};
        num_of_events = sum((curr_port_w_ts > prev_frame_t) & (curr_port_w_ts < curr_frame_t));
        if num_of_events > 0
            handles.(['w' num2str(water_ind)]).Value = 1;
            handles.(['w' num2str(water_ind) '_text']).String = num2str(num_of_events);
            handles.state.fw_UI_on = 1;
            handles.h_rew_sound_circles.rewards(2*food_ind).Visible = 'on';  % Show the colored circle near the port
        end
    end
    
    %check sounds
    sounds_inds = db_h.data.SNR_IND_cell_arr(curr_frame_ind).sounds_inds; % length is {0, 1}
    if ~isempty(sounds_inds)
        speakers = db_h.data.sound_table.speaker(sounds_inds);
        speakers = speakers{1};
        for sp_ind = 1:length(speakers)  % Mark the working speaker
            handles.(['sp' num2str(speakers(sp_ind))]).Value = 1;
        end
        
        sample_rate = 192000;             % in samples
        trial_dur = num2str(db_h.data.sound_table.trial_dur(sounds_inds)/sample_rate, 4);   % in secs
        etime = num2str(db_h.data.sound_table.etime(sounds_inds)/sample_rate, 4);           % in secs
        atten = num2str(db_h.data.sound_table.att(sounds_inds), 4);
        noabort = num2str(db_h.data.sound_table.noabort(sounds_inds)/sample_rate, 4);       % in secs
        soundtype = char(db_h.data.sound_table.soundname(sounds_inds));
        sound_area = num2str(db_h.data.sound_table.area(sounds_inds));
        handles.trial_dur_text.String = trial_dur;
        handles.etime_text.String = etime;
        handles.atten_text.String = atten;
        handles.noabort_text.String = noabort;
        handles.soundtype_text.String = soundtype;
        handles.sound_area_text.String = sound_area;
        
        set(handles.h_rew_sound_circles.sounds(speakers), 'Visible', 'on');
        handles.h_sound_text_box(3).String = beutify_sound_name(soundtype);
        set(handles.h_sound_text_box(1:3), 'Visible', 'on');
        sound_timer = floor(db_h.data.sound_table.noabort(sounds_inds)/sample_rate*10);
        
        handles.state.sound_UI_on = db_h.data.sound_table.noabort(sounds_inds)/sample_rate;  % Sounds stays for |noabort|
    elseif sound_timer > 0
        sound_timer = sound_timer - 1;
    else
        for sp_ind = 1:12
            handles.(['sp' num2str(sp_ind)]).Value = 0;
        end
        set(handles.h_rew_sound_circles.sounds, 'Visible', 'off');
        set(handles.h_sound_text_box(1:3), 'Visible', 'off');
        default_value = '---';
        if handles.state.sound_UI_on <= 0  % After |noabort| delete the sound
            set([handles.trial_dur_text, handles.etime_text, handles.atten_text,...
                handles.noabort_text, handles.soundtype_text, handles.sound_area_text],...
                'String', default_value);
        else
            handles.state.sound_UI_on = handles.state.sound_UI_on - 0.1;
        end
    end
    
    %check MDP/rat state
    state_inds = db_h.data.SNR_IND_cell_arr(curr_frame_ind).states_inds; % length is {0, 1, 2, ...}
    handles.state_change_text.String = num2str(length(state_inds));
    if ~isempty(state_inds)
        
        % Set the MDP values
        soundIsPlaying = num2str(db_h.data.maestro_states.soundIsPlaying(state_inds(end)));
        behavior = char(db_h.data.maestro_states.behavior(state_inds(end)));
        if strcmp(db_h.data.mdata.exp_name, 'Maciej')
            type = char(db_h.data.maestro_states.areatype(state_inds(end)));
        elseif strcmp(db_h.data.mdata.exp_name, 'nightRIFF')
            type = string(db_h.data.maestro_states.type(state_inds(end)));
        end
        
        area = num2str(db_h.data.maestro_states.s_area(state_inds(end)));
        rewsize = num2str(db_h.data.maestro_states.behavior(state_inds(end)) == 'reward');
        handles.sip_text.String = soundIsPlaying;
        handles.behavior_text.String = behavior;
        handles.type_text.String = type;
        handles.area_text.String = area;
        handles.rew_size_text.String = rewsize;
        update_location_box(db_h.data.maestro_states, handles.h_sound_text_box(5), ...
                                handles.exper_list.String{handles.exper_list.Value}, ...
                                state_inds(1));
        
        % Set the rat values
        action = num2str(db_h.data.maestro_states.action(state_inds(end)));
        loc_x = db_h.data.maestro_states.loc_x(state_inds(end));
        loc_y = db_h.data.maestro_states.loc_y(state_inds(end));
        maestro_loc = num2str([loc_x loc_y]);
        cam_loc_text = num2str(db_h.data.loc_arr(curr_frame_ind, :));        
        if strcmp(db_h.data.mdata.exp_name, 'Maciej')
            area2 = [num2str(db_h.data.maestro_states.r_area(state_inds(end)))...
                 ' ' char(db_h.data.maestro_states.r_areatype(state_inds(end)))];
        elseif strcmp(db_h.data.mdata.exp_name, 'nightRIFF')
            area2 = num2str(db_h.data.maestro_states.area(state_inds(end)));
        end
        
        handles.action_text.String = action;
        handles.maestro_loc_text.String = maestro_loc;
        handles.cam_loc_text.String = cam_loc_text;
        handles.area2_text.String = area2;
        if ismember('prevArea', db_h.data.maestro_states.Properties.VariableNames)
            prevArea = num2str(db_h.data.maestro_states.prevPoke(state_inds(end)));
            handles.prevArea_text.String = prevArea;
        end
        
    else
        % None!
    end
    
end

%========================   Callbacks   ===========================

function load_data_button_Callback(hObject, ~, handles)
    global db_h
    tic;
    h_wb = waitbar(0, 'Please wait...');
    
    % ====== Get the base dir name ====
    db_h.data.source_dir = read_and_validate_data_dir(handles);
    if db_h.data.source_dir == -1
        msgbox("Please paste a valid directory with pipeline outputs!");
        delete(h_wb);
        return;
    end
    handles.data_origin_text.String = db_h.data.source_dir;
    exp_name = handles.exper_list.String{handles.exper_list.Value};
    rat_no = str2double(handles.rat_no_list.String{handles.rat_no_list.Value});
    exp_date = [handles.day_input_text.String handles.month_input_text.String handles.year_input_text.String];
    base_dir = fullfile(db_h.data.source_dir, exp_name, exp_date);
    if strcmp(exp_name, 'nightRIFF')
        % Dynamically find the current directory index
        temp = dir(fullfile(base_dir, ['rat_' num2str(rat_no)]));  % Get the directories
        names = {temp.name};
        rat_dir = fullfile(base_dir, ['rat_' num2str(rat_no)], names{endsWith(names, '_Behavior')});
    else
        folder_contents = dir(fullfile(base_dir, ['rat_' num2str(rat_no)]));
        folder_name = folder_contents(contains({folder_contents.name}, 'Behavior')).name;     % Dynamically find the ??_Beahvior folder name
        rat_dir = fullfile(base_dir, ['rat_' num2str(rat_no)], folder_name);  %TODO: Remove the hardcoding of the prefix index
    end
    
    % Get the SNR boundary times of the behavioral session.

    % ======   Load the files and generate the data structures =================
    
    waitbar(0.1, h_wb, 'Loading sound table...');
    db_h.data.sound_table = load_sound_table(rat_dir);
    t_sound = db_h.data.sound_table.start_t';  % Changed 15/08/19 - Sound timestamps disagree berween sound_table and snr_sound
    waitbar(0.2, h_wb, 'Loading behavior...');
    [db_h.data.behave_struct, t_behavior] = load_behavior(rat_dir);
    waitbar(0.3, h_wb, 'Loading image DB...');
    [output_db] = parse_camera(rat_dir);
    t_camera = output_db.t_frames;      % Already interpolated by the pipeline up to 30FPS
    waitbar(0.4, h_wb, 'Loading maestro data...');
    [db_h.data.maestro_states, t_state] = parse_maestro(rat_dir);
    
    waitbar(0.5, h_wb, 'Sub-sampling the time series for visualization...');
    [t_sim_times, cam_inds] = make_ind_ars_for_triggers(t_behavior, t_sound, t_camera, t_state);
    cam_inds = cam_inds(1:end-1); % Hamsa law - N pivots, N-1 values
    db_h.data.image_arr = output_db.image_arr(:, :, cam_inds);
    db_h.data.LED_arr = output_db.LED_arr(cam_inds);
    db_h.data.loc_arr = output_db.loc_arr(cam_inds, :);
    db_h.data.bg_image = output_db.bg_image;
    db_h.data.area_num = output_db.area_num(cam_inds);
    db_h.data.area_type = output_db.area_type(cam_inds);
    db_h.data.rat_angs = output_db.rat_angs(cam_inds);
    db_h.data.rat_rs = output_db.rat_rs(cam_inds);
    db_h.data.subsampling_inds = cam_inds;
    db_h.data.first_subsample_ind = output_db.first_led_onset_ind;
    db_h.data.t_camera_full = output_db.t_frames;
    db_h.data.t_camera = t_camera;
    
    waitbar(0.55, h_wb, 'Loading neural activity...');
	[db_h.data.NA_db, db_h.data.NA_mdata, db_h.data.NA_raw_db, db_h.data.NA_big, ...
                        db_h.data.NA_ch_num] = load_NA(rat_dir);
    
    waitbar(0.6, h_wb, 'Aligning all events on one t-axis...');
    [db_h.data.SNR_IND_cell_arr, db_h.data.NA_FR_arr] = create_aligned_times(t_sim_times,...
                                                              t_sound, db_h.data.NA_db, t_state);
    
    waitbar(0.9, h_wb, 'Plotting...');
    db_h.data.t_sound = t_sound;
    db_h.data.t_cam_times_inter = t_sim_times;
    db_h.data.t_state = t_state;
    db_h.data.t_behavior = t_behavior;
    db_h.data.mdata = struct('exp_name', exp_name, ...
        'rat_no', rat_no, ...
        'exp_date', exp_date, ...
        'base_dir', base_dir, ...
        'rat_dir', rat_dir);
    
    % === Load the predicted rat head/body direction, if exist ===
    
    if exist(fullfile(rat_dir, 'predicted_rat_body_points.mat'), 'file')
        [out_db] = load_body_direcs(rat_dir, db_h.data.first_subsample_ind, db_h.data.subsampling_inds);
        db_h.data.rat_head_direcs = out_db.rat_head_direcs;
        db_h.data.rat_body_direcs = out_db.rat_body_direcs;
        db_h.data.base_locs = out_db.base_locs;
        db_h.data.neck_locs = out_db.neck_locs;
        db_h.data.nose_locs = out_db.nose_locs;
    end
    
    % ===========================================
    
    try
        close(h_wb)
    catch
        error('some str');
    end
    toc
    init_GUI(handles); % guidata() is called inside and the graphics are replotted to last frame
end

function init_GUI(handles)
    global db_h
    
    frame_n = length(db_h.data.SNR_IND_cell_arr);
    speed_arr = pdist1(double(db_h.data.loc_arr));
    speed_arr(speed_arr > 100) = 0;
    set(handles.picture_area, 'CLim', [0 max(speed_arr)*0.8]);
    
    handles = render_background_image(handles);
    
    handles.slider.Max = frame_n;
    handles.slider.Visible = 'on';
    handles.slider.SliderStep = [min(1/frame_n, 0.001) min(600/frame_n, 0.01)];
    handles.state.tail_len = 41;
    
% 	% Bin the images and convert to double
%     images = db_h.data.image_arr;
%     images_binned = images(1:2:end, 1:2:end, :)/4 + images(2:2:end, 1:2:end, :)/4 + ...
%                     images(1:2:end, 2:2:end, :)/4 + images(2:2:end, 2:2:end, :)/4;
%     db_h.data.image_arr = images_binned;
    
    handles.tim = timer('ExecutionMode', 'fixedRate', 'BusyMode', 'drop', 'Period', 0.1,...
                    'TimerFcn', {@timer_callback, handles.load_data_button});
                
    db_h.data.frame_n = frame_n;
    db_h.data.speed_arr = speed_arr;
    db_h.data.curr_traj_c = speed_arr;
    
%     handles.load_data_button.Enable = "off";
%     handles.load_data_button.String = '<html>Launch new GUI for<br>another experiment!';     
        
    % === init. NA related graphical objects and DBs ====
    
    if isempty(db_h.data.NA_db)
%         handles.NA_panel.Visible = false;
    else
        ch_nums = [db_h.data.NA_db.ch_num];
        elec_nums = [db_h.data.NA_db.elec_num];
        clust_names = cell(1, length(ch_nums)+1); % Last is sum of all
        for i = 1:length(elec_nums)
            clust_names{i} = ['E=' num2str(elec_nums(i)) '  |  ch=' num2str(ch_nums(i))];
        end
        clust_names{end} = 'Sum of all';
        handles.NA_list.String = clust_names;
    end
    
    % === Create both the rat image and the yellow body-center point ===
    curr_im = db_h.data.image_arr(:, :, 1);
    handles.h_plots.h_rat_dot = plot(handles.picture_area, 100, 100, 'y*', 'LineWidth', 10);
    handles.h_plots.h_rat_im = imshow(cat(3, curr_im, curr_im, curr_im), 'Parent', handles.picture_area);
    % The Plotting order is important, since rat directions should be above the image.
    
    % === init. rat body/head direction, if is loaded ===
    
    if isfield(db_h.data, 'base_locs')
        h_p1 = scatter(handles.picture_area, [0, 0,], [0, 0], 5, 'r', 'filled');
        h_p2 = scatter(handles.picture_area, [0, 0,], [0, 0], 5, 'r', 'filled');
        h_p3 = scatter(handles.picture_area, [0, 0,], [0, 0], 5, 'r', 'filled');
        h_p4 = quiver(handles.picture_area, 0, 0, 1, 1,...
                     'color', 'w',...
                     'AutoScale', 'off',...
                     'MaxHeadSize', 3, ...
                     'LineWidth', 2);
        h_p5 = quiver(handles.picture_area, 0, 0, 1, 1,...
                     'color', 'w',...
                     'AutoScale', 'off',...
                     'MaxHeadSize', 3, ...
                     'LineWidth', 2);
        handles.h_rat_direc = [h_p1, h_p2, h_p3, h_p4, h_p5];
    end
    
    % --- Add the sound/reward circles ---
    handles.h_rew_sound_circles = init_sound_rew_circles(handles.picture_area, db_h.data.arena_geometrical_db);
    handles.h_sound_text_box = init_sound_text_box(handles.picture_area);
    
    % === Store the dbs in handles and replot the arena by invoking the slider callback ===
    guidata(handles.slider, handles);  % Push the changed handles struct     
	handles.slider.Value = 51;  % The lister will be triggered and call the 'replot' function
end

function handles = render_background_image(handles)
    global db_h

    frame_bg = db_h.data.bg_image;
%     frame_bg = abs(sin((1:500)'/100)*sin((1:500)/100));
    frame_bg = cat(3, frame_bg, frame_bg, frame_bg);% Create pseudo RGB image, to overlay later with colored plots
    handles.plot = imshow(frame_bg*handles.state.im_bright_fact, 'Parent', handles.picture_area);
    hold(handles.picture_area, 'on');
    set(handles.message_text, 'String', '=== New background loaded! ===');
end

function trace_Callback(hObject, ~, handles)
    global db_h
    state = handles.state;
    tag = get(hObject,'Tag');
    if(strcmp(tag, 'trace_up'))
        handles.state.tail_len = min(state.tail_len + 20, state.frame_ind);
        handles = replot(handles);
        guidata(hObject, handles);
        return;
    elseif(strcmp(tag, 'trace_down'))
        handles.state.tail_len = max(state.tail_len - 20, 1);
        handles = replot(handles);
        guidata(hObject, handles);
        return;
    end
    
    if(state.traceOn)   % remove trace, show full track
        set(handles.message_text, 'String', 'Showing trace');
        set(hObject,'String','<html>Show<br>trace');
        state.tail_len = db_h.data.frame_n - 1;
    else % Create trace
        set(handles.message_text, 'String', 'Showing full');
        set(hObject,'String','<html>Show<br>full traj.');
        state.tail_len = 41;
    end
    state.traceOn = ~state.traceOn;
    handles.state = state;
    handles = replot(handles);
    guidata(hObject, handles);
end

function play_button_Callback(hObject, ~, handles)
    str = hObject.String;
    if(strcmp(str, 'Play'))
        if ~handles.state.traceOn  % Don't allow to run the simulation with the full trace
            trace_Callback(handles.trace_button, -77, handles);
            handles = guidata(hObject);  % handles were resaved inside the trace_Callback function
        end
        
        play_mult = str2double(handles.play_text.String);
        if((play_mult < 0.1) || (play_mult > 9))
            disp('the speed should be in [0.1, 9]');
            return;
        end
        delay = round(1/10/play_mult, 3);
        handles.tim.Period = delay;
        hObject.String = 'Stop';
        guidata(hObject, handles);
        start(handles.tim);
        
    else
        stop(handles.tim);
        hObject.String = 'Play';
    end
end

function show_image_button_Callback(hObject, ~, handles)
%     if(handles.state.frame_ind < 25*1030)
%         disp('Please move to frame num above 26000');
%         return;
%     end
    state = handles.state;
    if(state.ImageOn)   % remove headImage, show marker
        set(handles.message_text, 'String', 'Rat image turned off');
        set(hObject, 'String', '<html>Show<br>image');        
    else % show image of the rat at the current location, remove the marker
        set(handles.message_text, 'String', 'Rat image turned off');
        set(hObject, 'String', '<html>Show<br>dot');
    end
    state.ImageOn = ~state.ImageOn;
    handles.state = state;
    handles = replot(handles);  % replot the image
    guidata(hObject, handles);    
end

function manual_advance_sim_Callback(hObject, ~, handles)
    global db_h
    jump_const = 5;
    [jump_size, status] = str2num(handles.manual_advance_input.String);
    if (status == 1) &&  (jump_size > 0) && (floor(jump_size) == jump_size)
        curr_ind = handles.state.frame_ind;
    else
        handles.message_text.String = 'Frame step should be positive integer!';
        handles.manual_advance_input.String = '1';
        return;
    end
    if strcmp(hObject.String, '<')
        handles.state.frame_ind = max(1, curr_ind - 1);
    elseif strcmp(hObject.String, '>')
        handles.state.frame_ind = min(db_h.data.frame_n, curr_ind + 1);
    elseif strcmp(hObject.String, '<<')
        handles.state.frame_ind = max(1, curr_ind - jump_const);
    elseif strcmp(hObject.String, '>>')
        handles.state.frame_ind = min(db_h.data.frame_n, curr_ind + jump_const);
	elseif strcmp(hObject.String, 'Jump to ind.')
        handles.state.frame_ind = min(db_h.data.frame_n, jump_size);
    end
    handles.manual_advance_input.String = '1';
    guidata(hObject, handles);
    handles.slider.Value = handles.state.frame_ind;
end

function figure1_KeyPressFcn(hObject, eventdata, handles)
% determine the key that was pressed 
    keyPressed = eventdata.Key;
    if strcmpi(keyPressed,'rightarrow')
        manual_advance_sim_Callback(handles.one_to_right_button,[],handles);
    elseif strcmpi(keyPressed,'leftarrow')
        manual_advance_sim_Callback(handles.one_to_left_button,[],handles);
    elseif strcmpi(keyPressed,'numpad6')
        manual_advance_sim_Callback(handles.to_right_button,[],handles);
    elseif strcmpi(keyPressed,'numpad4')
        manual_advance_sim_Callback(handles.to_left_button,[],handles);
    end
end

function figure1_CloseRequestFcn(hObject, ~, handles)
    delete(timerfindall);
    clear global db_h;
    delete(hObject);
end

function handles = time_window_button_Callback(hObject, ~, handles)
    global db_h
    frame_ind = handles.state.frame_ind;
%     if isfield(db_h.data, 'overview_fig') && isvalid(db_h.data.overview_fig(1))
    WIN_SZ = 30;
    WIN_SZ_SHOW = 10;
    if isfield(handles, 'stat_fig') && isvalid(handles.stat_fig(1))
%         h_ax = db_h.data.overview_fig(1);
%         h_curr_ind = db_h.data.overview_fig(2);
        h_ax = handles.stat_fig(1);
        h_curr_ind = handles.stat_fig(2);
        cam_t = db_h.data.SNR_IND_cell_arr(frame_ind).cam_interp_t;
        set(h_ax, 'XTick', (cam_t-WIN_SZ_SHOW):2:(cam_t+10), 'XTickLabel', -WIN_SZ_SHOW:2:WIN_SZ_SHOW);
        set(h_curr_ind, 'XData', [cam_t cam_t]);
        xlim(h_ax, [cam_t - WIN_SZ_SHOW, cam_t + WIN_SZ_SHOW]);
        title(h_ax, ['Events around t= ' sprintf('%.2f', cam_t) ' , frame ind: ' num2str(frame_ind)]);

        return;
    end
    frame_n = db_h.data.frame_n;
%     time_frame = 10*10; % The frame is extended
    sim_FPS = 10;   % FPS of the simulation, currently = 10 FPS
    start_cam_ind = max(1, frame_ind - WIN_SZ*sim_FPS);
    end_cam_ind = min(frame_n, frame_ind + WIN_SZ*sim_FPS);
    cam_t = db_h.data.SNR_IND_cell_arr(frame_ind).cam_interp_t;
    all_cam_t = db_h.data.t_cam_times_inter;
    start_cam_t = db_h.data.SNR_IND_cell_arr(start_cam_ind).cam_interp_t;
    end_cam_t = db_h.data.SNR_IND_cell_arr(end_cam_ind).cam_interp_t;
    
    % init new figure
    h_f = figure('Position', [65, 110, 1500, 200]);
    h_ax = axes(h_f);
    s = 20;
    hold(h_ax, 'on');
    colors = get(h_ax, 'colororder');
    h_curr_point = plot([cam_t cam_t], [0 7], 'linewidth', 3, 'color', 'k',...
                        'parent', h_ax);                                % Plot a thick line at (0,0)
    h_curr_point.Color(4) = 0.5;
    rel_cam_t = all_cam_t((all_cam_t <= end_cam_t) & (all_cam_t >= start_cam_t));
    h_cam = scatter(rel_cam_t, (1:length(rel_cam_t))*0 + 4, s, 'k',...
                                  'filled', 'marker', 's', 'parent', h_ax);
    
    % Extract behavior
    food_t_arr = [];
    np_t_arr_on = [];
    np_t_arr_off = [];
    ap_t_arr = [];
    for port_ind = 1:12
        % Add the food events
        all_foods = db_h.data.behave_struct.food_timings{port_ind};
        relev_foods = all_foods((all_foods >= start_cam_t) & (all_foods <= end_cam_t));
        food_t_arr = [food_t_arr relev_foods'];
        
        % Add the airpuff events
        all_aps = db_h.data.behave_struct.airpuff_timings{port_ind};
        relev_aps = all_aps((all_aps >= start_cam_t) & (all_aps <= end_cam_t));
        ap_t_arr = [ap_t_arr relev_aps'];
        
        % Add the nosepoke events - they are coupled so must capture both On and Off
        all_nps = db_h.data.behave_struct.beam_timings{port_ind};
        all_nps_on = all_nps(1:2:end);
        all_nps_off = all_nps(2:2:end);
        relev_nps_on = all_nps_on((all_nps_on >= start_cam_t) & (all_nps_on <= end_cam_t));
        relev_nps_off = all_nps_off((all_nps_off >= start_cam_t) & (all_nps_off <= end_cam_t));
        if isempty(relev_nps_on) || isempty(relev_nps_off)
            continue;
        end
        if relev_nps_on(1) > relev_nps_off(1)  % In current time frame ON and OFF can be uneven
            relev_nps_off = relev_nps_off(2:end);  % Remove first END, if it is before first start
        end
        if relev_nps_on(end) > relev_nps_off(end)
            relev_nps_on = relev_nps_on(1:end-1);
        end
        
        np_t_arr_on = [np_t_arr_on relev_nps_on'];
        np_t_arr_off = [np_t_arr_off relev_nps_off'];
    end
    food_t_arr = sort(food_t_arr);
    np_t_arr_on = sort(np_t_arr_on);
    np_t_arr_off = sort(np_t_arr_off);
    ap_t_arr = sort(ap_t_arr);
    
    % Plot the behavioral data
    h_food = scatter(food_t_arr, (1:length(food_t_arr))*0 + 1, s, colors(1, :),...
                                  'filled', 'parent', h_ax);
    h_np = scatter(np_t_arr_on, (1:length(np_t_arr_on))*0 + 2, s, colors(2, :),...
                                  'filled', 'parent', h_ax);
    x_np = zeros(1, length(np_t_arr_on)*3);
    y_np = zeros(1, length(np_t_arr_on)*3);
    x_np(1:3:end) = np_t_arr_on;
    y_np(1:3:end) = 2;
    x_np(2:3:end) = np_t_arr_off;
    y_np(2:3:end) = 2;
    x_np(3:3:end) = np_t_arr_off;
    y_np(3:3:end) = NaN;
    h_np = plot(x_np, y_np, 'Color', colors(2, :), 'parent', h_ax);
    h_ap = scatter(ap_t_arr, (1:length(ap_t_arr))*0 + 3, s, colors(3, :),...
                                  'filled', 'parent', h_ax);
    
    % Extract the sounds
    all_sound_t = db_h.data.t_sound;
    sound_inds = (all_sound_t >= start_cam_t) & (all_sound_t <= end_cam_t);
    sound_t_arr = all_sound_t(sound_inds);
    sound_t_arr = sound_t_arr;
    all_state_t = db_h.data.t_state;
    state_t_arr = all_state_t((all_state_t >= start_cam_t) & (all_state_t <= end_cam_t));
    state_t_arr = state_t_arr;
    no_abort_arr = db_h.data.sound_table.noabort(sound_inds)'/192000 + sound_t_arr;
    no_abort_x = zeros(1, length(no_abort_arr)*3);
    no_abort_y = zeros(1, length(no_abort_arr)*3);
    no_abort_x(1:3:end) = sound_t_arr+0.01;
    no_abort_y(1:3:end) = 5;
    no_abort_x(2:3:end) = no_abort_arr;
    no_abort_y(2:3:end) = 5;
    no_abort_x(3:3:end) = no_abort_arr;
    no_abort_y(3:3:end) = NaN;
    
    % Plot the sound and state data
    h_sound = scatter(sound_t_arr, (1:length(sound_t_arr))*0 + 5, s, colors(4, :),...
                                  'filled', 'parent', h_ax);
    h_noabort = plot(no_abort_x, no_abort_y, 'color', colors(4, :), 'parent', h_ax);
    h_state = scatter(state_t_arr, (1:length(state_t_arr))*0 + 6, s, colors(5, :),...
                                  'filled', 'parent', h_ax);
                
    % Format the figure
    xlim(h_ax, [cam_t - WIN_SZ_SHOW, cam_t + WIN_SZ_SHOW]);
    ylim(h_ax, [0 7]);
    set(h_ax, 'TickDir', 'out', 'YMinorTick', 'off', 'XMinorTick', 'on', ...
        'XMinorGrid', 'on','XGrid', 'on',...
        'YTick', [1 2 3 4 5 6], 'YTickLabel', {'food', 'np', 'ap', 'cam', 'sound', 'state'}, ...
        'XTick', (cam_t-WIN_SZ_SHOW):2:(cam_t+WIN_SZ_SHOW), 'XTickLabel', -WIN_SZ_SHOW:2:WIN_SZ_SHOW, 'FontSize', 11, ...
        'TitleFontSizeMultiplier', 1.3);
    title(h_ax, ['Time: ' sprintf('%.2f', cam_t) ' seconds    |    frame ind: ' num2str(frame_ind)]);
    xlabel(h_ax, 'Rel. time (sec)');
    ylabel(h_ax, 'Event type');
    tightfig(h_f);
%     db_h.data.overview_fig = [h_ax h_curr_point];
    handles.stat_fig = [h_ax h_curr_point];
    
	if ~isempty(hObject)
        guidata(hObject, handles);
    end
end

function jump_buttons_Callback(hObject, ~, handles)
    global db_h
    curr_ind = handles.state.frame_ind;
    h_wb = waitbar(0.2, 'Please wait...');
    curr_t = db_h.data.t_cam_times_inter(curr_ind + 1); % First value is not plotted
    if strcmp(hObject.String, 'Sound')
        while true
            curr_ind = curr_ind + 1;
            sounds = db_h.data.SNR_IND_cell_arr(curr_ind).sounds_inds;
            if (curr_ind > db_h.data.frame_n) || ~isempty(sounds)
                break;
            end
        end
        
        [~, ind] = find(db_h.data.t_sound > curr_t, 1, 'first');
        next_sound_t = db_h.data.t_sound(ind);
        [~, curr_ind] = find(next_sound_t < db_h.data.t_cam_times_inter(2:end), 1, 'first');
    elseif strcmp(hObject.String, 'Food')
        food_ts = [];
        for curr_food = 1:12
            food_ts = [food_ts db_h.data.behave_struct.food_timings{curr_food}'];
        end
        food_ts = sort(food_ts);
        [~, ind] = find(food_ts > curr_t, 1, 'first');
        next_food_t = food_ts(ind);
        [~, curr_ind] = find(next_food_t < db_h.data.t_cam_times_inter(2:end), 1, 'first');
    elseif strcmp(hObject.String, 'Airpuff')
        ap_ts = [];
        for curr_ap = 1:12
            ap_ts = [ap_ts db_h.data.behave_struct.airpuff_timings{curr_ap}'];
        end
        ap_ts = sort(ap_ts);
        [~, ind] = find(ap_ts > curr_t, 1, 'first');
        next_ap_t = ap_ts(ind);
        if isempty(next_ap_t)
            disp('No event find downstream to current moment!');
            try
                close(h_wb)
            catch
                error('some str');
            end
            return;
        end
        [~, curr_ind] = find(next_ap_t < db_h.data.t_cam_times_inter(2:end), 1, 'first');
    elseif strcmp(hObject.String, 'Episode')
        state_type_arr = string(db_h.data.maestro_states.MDPStates.behavior);
        att_state_arr = (state_type_arr == "att");
        relev_state_t_arr = db_h.data.t_state(att_state_arr);
        [~, ind] = find(relev_state_t_arr > curr_t, 1, 'first');
        next_epis_t = relev_state_t_arr(ind);
        [~, curr_ind] = find(next_epis_t < db_h.data.t_cam_times_inter(2:end), 1, 'first');
    elseif strcmp(hObject.String, 'Warning') %todo
        sound_type_arr = string(db_h.data.sound_table.soundtype);
        warning_sound_arr = (sound_type_arr == "warning");
        relev_sound_t_arr = db_h.data.t_sound(warning_sound_arr);
        [~, ind] = find(relev_sound_t_arr > curr_t, 1, 'first');
        next_warn_t = relev_sound_t_arr(ind);
        [~, curr_ind] = find(next_warn_t < db_h.data.t_cam_times_inter(2:end), 1, 'first');
    elseif strcmp(hObject.String, 'Negative') %todo
        sound_type_arr = string(db_h.data.sound_table.soundtype);
        warning_sound_arr = (sound_type_arr == "negative");
        relev_sound_t_arr = db_h.data.t_sound(warning_sound_arr(1:end-1)); % last value annulated
        % ... since |maestro_sounds| > |t_sounds|, but last maestro_s is Negative
        [~, ind] = find(relev_sound_t_arr > curr_t, 1, 'first');
        next_warn_t = relev_sound_t_arr(ind);
        [~, curr_ind] = find(next_warn_t < db_h.data.t_cam_times_inter(2:end), 1, 'first');
    else
        disp('Who the hell called me??');
        return;
    end
    handles.slider.Value = curr_ind;  % replot and guidata() is called by the listener
	try
        close(h_wb)
    catch
        error('some str');
    end
end

function open_dir_button_Callback(hObject, ~, handles)
    global db_h
    winopen(db_h.data.mdata.rat_dir);
end

% ============= Helper functions ==========================

function d = pdist1(arr)
% PDIST1 calculates distances passed between every two consecutive time points in the given vector.
% Input:
%     arr - array of [n x 2] points.
% 
% Output:
%     d - array of length as input 'arr', dimension as input. First value is 0.
% 
% Usage:
%     >> d = pdist1([x y])

    % ======================  INPUT CHECK  =========================
    
    if(nargin < 1)  % Return if no input was provided
        disp('Please feed in an 2xN array of points.');
        disp('        >> help pdist1');
        return;
    end
    
    s = size(arr);
    if(~(s(1) == 2 || s(2) == 2))  % Return if wrong input was provided
        disp('Please feed in an 2xN array of points.');
        disp('        >> help pdist1');
        return;
    end
    
    % ===============================================================
    
    if(s(1) == 2)   % The array is horizontal
    	arr = arr';
    end
    
    arr2 = arr(2:end, :);
    arr = arr(1:end-1, :);
    d = ((arr(:, 1) - arr2(:, 1)).^2 + (arr(:, 2) - arr2(:, 2)).^2).^0.5;
    d = [0; d];
    if(s(1) == 2) % The array is horizontal
        d = d';
    end
    
end

%========================   CreateFunc (Junk)   ===========================

function slider_CreateFcn(hObject, ~, ~)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

% ====================== Helper functions - data manipulation =================

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
    t_end = min([t_behavior(end), t_sound(end), t_camera(end), t_state(end)]); 
    
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

function hfig = tightfig(hfig)
% tightfig: Alters a figure so that it has the minimum size necessary to
% enclose all axes in the figure without excess space around them.
% 
% Note that tightfig will expand the figure to completely encompass all
% axes if necessary. If any 3D axes are present which have been zoomed,
% tightfig will produce an error, as these cannot easily be dealt with.
% 
% Input
%
% hfig - handle to figure, if not supplied, the current figure will be used
%   instead.
%
%
    if nargin == 0
        hfig = gcf;
    end
    % There can be an issue with tightfig when the user has been modifying
    % the contnts manually, the code below is an attempt to resolve this,
    % but it has not yet been satisfactorily fixed
%     origwindowstyle = get(hfig, 'WindowStyle');
    set(hfig, 'WindowStyle', 'normal');
    
    % 1 point is 0.3528 mm for future use
    % get all the axes handles note this will also fetch legends and
    % colorbars as well
    hax = findall(hfig, 'type', 'axes');
    % TODO: fix for modern matlab, colorbars and legends are no longer axes
    hcbar = findall(hfig, 'type', 'colorbar');
    hleg = findall(hfig, 'type', 'legend');
    
    % get the original axes units, so we can change and reset these again
    % later
    origaxunits = get(hax, 'Units');
    
    % change the axes units to cm
    set(hax, 'Units', 'centimeters');
    
    pos = [];
    ti = [];
    
    % get various position parameters of the axes
    if numel(hax) > 1
%         fsize = cell2mat(get(hax, 'FontSize'));
        ti = cell2mat(get(hax,'TightInset'));
        pos = [pos; cell2mat(get(hax, 'Position')) ];
    else
%         fsize = get(hax, 'FontSize');
        ti = get(hax,'TightInset');
        pos = [pos; get(hax, 'Position') ];
    end
    
    if ~isempty (hcbar)
        
        set(hcbar, 'Units', 'centimeters');
        
        % colorbars do not have tightinset property
        for cbind = 1:numel(hcbar)
            %         fsize = cell2mat(get(hax, 'FontSize'));
            [cbarpos, cbarti] = colorbarpos (hcbar);
            pos = [pos; cbarpos];
            ti = [ti; cbarti];
        end
    end
    
    if ~isempty (hleg)
        
        set(hleg, 'Units', 'centimeters');
        
        % legends do not have tightinset property
        if numel(hleg) > 1
            %         fsize = cell2mat(get(hax, 'FontSize'));
            pos = [pos; cell2mat(get(hleg, 'Position')) ];
        else
            %         fsize = get(hax, 'FontSize');
            pos = [pos; get(hleg, 'Position') ];
        end
        ti = [ti; repmat([0,0,0,0], numel(hleg), 1); ];
    end
    
    % ensure very tiny border so outer box always appears
    ti(ti < 0.1) = 0.15;
    
    % we will check if any 3d axes are zoomed, to do this we will check if
    % they are not being viewed in any of the 2d directions
    views2d = [0,90; 0,0; 90,0];
    
    for i = 1:numel(hax)
        
        set(hax(i), 'LooseInset', ti(i,:));
%         set(hax(i), 'LooseInset', [0,0,0,0]);
        
        % get the current viewing angle of the axes
        [az,el] = view(hax(i));
        
        % determine if the axes are zoomed
        iszoomed = strcmp(get(hax(i), 'CameraViewAngleMode'), 'manual');
        
        % test if we are viewing in 2d mode or a 3d view
        is2d = all(bsxfun(@eq, [az,el], views2d), 2);
               
        if iszoomed && ~any(is2d)
           error('TIGHTFIG:haszoomed3d', 'Cannot make figures containing zoomed 3D axes tight.') 
        end
        
    end
    
    % we will move all the axes down and to the left by the amount
    % necessary to just show the bottom and leftmost axes and labels etc.
    moveleft = min(pos(:,1) - ti(:,1));
    
    movedown = min(pos(:,2) - ti(:,2));
    
    % we will also alter the height and width of the figure to just
    % encompass the topmost and rightmost axes and lables
    figwidth = max(pos(:,1) + pos(:,3) + ti(:,3) - moveleft);
    
    figheight = max(pos(:,2) + pos(:,4) + ti(:,4) - movedown);
    
    % move all the axes
    for i = 1:numel(hax)
        
        set(hax(i), 'Position', [pos(i,1:2) - [moveleft,movedown], pos(i,3:4)]);
        
    end
    
    for i = 1:numel(hcbar)
        
        set(hcbar(i), 'Position', [pos(i+numel(hax),1:2) - [moveleft,movedown], pos(i+numel(hax),3:4)]);
        
    end
    
    for i = 1:numel(hleg)
        
        set(hleg(i), 'Position', [pos(i+numel(hax)+numel(hcbar),1:2) - [moveleft,movedown], pos(i+numel(hax)+numel(hcbar),3:4)]);
        
    end
    
    origfigunits = get(hfig, 'Units');
    
    set(hfig, 'Units', 'centimeters');
    
    % change the size of the figure
    figpos = get(hfig, 'Position');
    
    set(hfig, 'Position', [figpos(1), figpos(2), figwidth, figheight]);
    
    % change the size of the paper
    set(hfig, 'PaperUnits','centimeters');
    set(hfig, 'PaperSize', [figwidth, figheight]);
    set(hfig, 'PaperPositionMode', 'manual');
    set(hfig, 'PaperPosition',[0 0 figwidth figheight]);    
    
    % reset to original units for axes and figure 
    if ~iscell(origaxunits)
        origaxunits = {origaxunits};
    end
    for i = 1:numel(hax)
        set(hax(i), 'Units', origaxunits{i});
    end
    set(hfig, 'Units', origfigunits);
    
%      set(hfig, 'WindowStyle', origwindowstyle);
     
end

function [pivot_vals, pivot_inds] = custom_round(pivots, arr, is_round)

% Function custom_round floors (or rounds) one array to the custom values of the other.
% Assumption: The arrays are sorted. Default: floor to lower pivot
% 
% Inputs:
%     pivots  - (1xN array) - Array of pivot values that define the rounding grid
%     arr     - (1xM array) - Array of values to be projected on the grids
%     is_round- (flag) - When true, apply ROUND (|1 --  2.2 ->- 3|). Default: FLOOR (|1 -<-  2.2 -- 3|)
%  
% Outputs:
% 	pivot_vals - (1xM array) - Pivot values that correspond to each value from arr
%     pivot_inds - (1xM array) - Pivot indices that correspond to each value from arr
% 
% Example:
%     >> [vals, inds] = custom_round([3 4 5], [0 3.5 4 6]); % Vals=[3,3,4,5],inds=[1,1,2,3]

    if nargin == 2
        is_round = false;
    end
    [arr, orig_inds] = sort(arr, 'ascend');
    pivot_inds = arr*0 + length(pivots);
    
    if ~is_round  % The O(n) version of the floor - single pass through the array
        arr_1_len = length(pivots);
        arr_2_len = length(arr);
        curr_arr1_ind = 1;
        curr_arr2_ind = 1;

        while (curr_arr2_ind <= arr_2_len) && (curr_arr1_ind <= arr_1_len)
            if (arr(curr_arr2_ind) < pivots(curr_arr1_ind))
                pivot_inds(curr_arr2_ind) = max(1, curr_arr1_ind-1);
                curr_arr2_ind = curr_arr2_ind + 1;
            else
                curr_arr1_ind = curr_arr1_ind + 1;
            end
        end
    else
        pivot_inds = pivot_inds*0 + 1;
        watershed_bins = [pivots(1) diff(pivots)/2 + pivots(1:end-1) pivots(end)];
        for i = 2:length(watershed_bins)
            % For each watershed bin, find arr values that fit in
            curr_inds = (arr > watershed_bins(i-1)) & (arr <= watershed_bins(i));
            pivot_inds(curr_inds) = i-1;
        end
        % Deal with arr vals that are outside the bins
        pivot_inds(arr >= pivots(end)) = length(pivots);
        pivot_inds(arr <= pivots(1)) = 1;
    end
    
    pivot_vals = pivots(pivot_inds);
    
    % === Restore the original values order, for unsorted arrays ===
    pivot_vals(orig_inds) = pivot_vals;
    pivot_inds(orig_inds) = pivot_inds;
end

function move_body_quivers_and_point(handles)
    global db_h

    curr_fr_ind = handles.state.frame_ind;
    curr_loc_cam = db_h.data.loc_arr(curr_fr_ind, :);
    x = curr_loc_cam(1);
    y = curr_loc_cam(2);
    
    
    curr_base = (db_h.data.base_locs(curr_fr_ind, :) - 50/2)*2;  % [15, 30] -> [-10, +5]   Make rel to center...
    curr_neck = (db_h.data.neck_locs(curr_fr_ind, :) - 50/2)*2;  % ... Then scale res 50p -> 100p as presented in player
    curr_nose = (db_h.data.nose_locs(curr_fr_ind, :) - 50/2)*2;
    
    VISUAL_ZOOM_FACT = 1.5;  % Used to increase the arrows in the plotting
    curr_base = curr_base*VISUAL_ZOOM_FACT;
    curr_neck = curr_neck*VISUAL_ZOOM_FACT;
    curr_nose = curr_nose*VISUAL_ZOOM_FACT;
    
    % Move the body dots
    hs = handles.h_rat_direc;
    set(hs(1), 'XData', curr_base(1) + curr_loc_cam(1), 'YData', curr_base(2) + curr_loc_cam(2));
    set(hs(2), 'XData', curr_neck(1) + curr_loc_cam(1), 'YData', curr_neck(2) + curr_loc_cam(2));
    set(hs(3), 'XData', curr_nose(1) + curr_loc_cam(1), 'YData', curr_nose(2) + curr_loc_cam(2));
    
    % Move the quivers
    set(hs(4), 'XData', curr_base(1) + curr_loc_cam(1), 'YData', curr_base(2) + curr_loc_cam(2), ...
               'UData', curr_neck(1) - curr_base(1), 'VData', curr_neck(2) - curr_base(2));
    set(hs(5), 'XData', curr_neck(1) + curr_loc_cam(1), 'YData', curr_neck(2) + curr_loc_cam(2), ...
               'UData', curr_nose(1) - curr_neck(1), 'VData', curr_nose(2) - curr_neck(2));
end

function h_circles = init_sound_rew_circles(h_ax, arena_db_file)

    % Adds colored circles to the RIFF in hidden mode, will be shown only once a sound is played
    % or food is delivered.
    % Additionally adds a legend.
    % 
    % The locations of the reward/sound circles were manually picked and stored in
    % 'RIFF_int_area_locations_181020.mat'
    %
    % Inputs:
    %	  h_ax - handle - Handle to the main figure
    %     arena_db_file - string - the file name
    %
    % Outputs:
    %     h_circles - struct - Struct with two fields, 'sounds', 'nosepokes', and 'rewards', each 12x1 graphical handles
    %
    % *  *  Added on 29.03.21
    
    
    try
        db = load(arena_db_file);
    catch
        error('Can`t find a helper .mat file. Please mount the `helper_function` folder');
    end
    
    % --- Hyper parameters ----
        
    sz = 100;
    lw = 1.5;
    ang_shift = 6;
    sound_extent = 20;
    nose_poke_extent = 14;
    reward_extent = 8;
    
    % --- Calc the location of all the future scatters ---
    [theta, rho] = cart2pol(db.ports(:, 1) - db.c_point(1), db.ports(:, 2) - db.c_point(2));
    sound_locs = zeros(12, 2);
    [p1, p2] = pol2cart(deg2rad(rad2deg(theta) - ang_shift), rho + sound_extent);
    sound_locs(1:2:end, :) = [p1 p2] +  db.c_point;
    [p1, p2] = pol2cart(deg2rad(rad2deg(theta) + ang_shift), rho + sound_extent);
    sound_locs(2:2:end, :) = [p1 p2] +  db.c_point;
    
    rew_locs = zeros(12, 2);
    [p1, p2] = pol2cart(deg2rad(rad2deg(theta) - ang_shift), rho + reward_extent);
    rew_locs(1:2:end, :) = [p1 p2] +  db.c_point;
    [p1, p2] = pol2cart(deg2rad(rad2deg(theta) + ang_shift), rho + reward_extent);
    rew_locs(2:2:end, :) = [p1 p2] +  db.c_point;
    
    nosepoke_locs = zeros(12, 2);
    [p1, p2] = pol2cart(deg2rad(rad2deg(theta) - ang_shift), rho + nose_poke_extent);
    nosepoke_locs(1:2:end, :) = [p1 p2] +  db.c_point;
    [p1, p2] = pol2cart(deg2rad(rad2deg(theta) + ang_shift), rho + nose_poke_extent);
    nosepoke_locs(2:2:end, :) = [p1 p2] +  db.c_point;
    
    cs = get(h_ax, 'colororder');
    rews = gobjects(1, 12);
    sounds = gobjects(1, 12);
    nosepokes = gobjects(1, 12);
    for i = 1:12
        curr_p = sound_locs(i, :);
        sounds(i) = scatter(h_ax, curr_p(1), curr_p(2), sz, ...
                        'filled', ...
                        'MarkerEdgeColor', 'w', ...
                        'MarkerFaceColor', cs(2, :), 'LineWidth', lw);
        sounds(i).Visible = 'off';
        
        curr_p = rew_locs(i, :);
        rews(i) = scatter(h_ax, curr_p(1), curr_p(2), sz, ...
                        'filled', ...
                        'MarkerEdgeColor', 'w', ...
                        'MarkerFaceColor', cs(5, :), 'LineWidth', lw);
        rews(i).Visible = 'off';
        
        curr_p = nosepoke_locs(i, :);
        nosepokes(i) = scatter(h_ax, curr_p(1), curr_p(2), sz, ...
                        'filled', ...
                        'MarkerEdgeColor', 'w', ...
                        'MarkerFaceColor', cs(3, :), 'LineWidth', lw);
        nosepokes(i).Visible = 'off';
    end
    
    h_circles = struct('sounds', sounds, ...
                       'rewards', rews, ...
                       'nosepokes', nosepokes);
                   
    % ------- Plot the circles and save the handles ---- 
    x = 480;
    y = 25;
    h_rect = rectangle(h_ax, 'Position', [x, y, 100, 52], ...
                             'FaceColor', [1 1 1]*0.94, ...
                             'EdgeColor', 'w', ...
                              'Curvature', 0.1);
    y1 = y+10;
    scatter(h_ax, x+10, y1, sz, ...
                        'filled', ...
                        'MarkerEdgeColor', 'w', ...
                        'MarkerFaceColor', cs(2, :), 'LineWidth', lw);
    text(h_ax, x+20, y1, "Sound", 'FontSize', 12);
    
    y2 = y+25;
    scatter(h_ax, x+10, y2, sz, ...
                        'filled', ...
                        'MarkerEdgeColor', 'w', ...
                        'MarkerFaceColor', cs(3, :), 'LineWidth', lw);
    text(h_ax, x+20, y2, "Nose poke", 'FontSize', 12);
    
    y2 = y+40;
    scatter(h_ax, x+10, y2, sz, ...
                        'filled', ...
                        'MarkerEdgeColor', 'w', ...
                        'MarkerFaceColor', cs(5, :), 'LineWidth', lw);
    text(h_ax, x+20, y2, "Food/Water", 'FontSize', 12);
    
    
    
end

function h_arr = init_sound_text_box(h_ax)
    x = 480;
    y = 85;
    h_rect_loc = rectangle(h_ax, 'Position', [x, y, 100, 16], ...
                             'FaceColor', [1 1 1]*0.94, ...
                             'EdgeColor', 'w', ...
                              'Curvature', 0.23);
    h_text3 = text(h_ax, x+7, y+8, "Area: ", ...
                                'FontSize', 12, 'FontWeight', 'bold');
                            
    sound_shift_down = 25;
    h_rect_sound = rectangle(h_ax, 'Position', [x, y+sound_shift_down, 100, 32], ...
                             'FaceColor', [1 1 1]*0.94, ...
                             'EdgeColor', 'w', ...
                              'Curvature', 0.12);
                          
    h_text1 = text(h_ax, x+7, y+10+sound_shift_down, "Sound type:", ...
                                'FontSize', 12, 'FontWeight', 'bold');
    h_text2 = text(h_ax, x+7, y+23+sound_shift_down, "Placeholder", ...
                                'FontSize', 12, 'Interpreter', 'none');  
    
    h_arr = [h_rect_sound, h_text1, h_text2, h_rect_loc, h_text3];
    set(h_arr(1:3), 'Visible', 'off');
end

function name = beutify_sound_name(sound_str)
    % Converts the technical sound string into a human-readable string, to be printed on top of the
    % GUI
    
	% ---- List of Maciek sounds ----
    switch sound_str
        case "att_sound"
            name = "Attention";
        case "reward_sound"
            name = "Reward";
        case "negative_sound"
            name = "Negative";
        case "warning_sound"
            name = "Warning";
        case "safe_sound"
            name = "Safe";
        case "punish_sound"
            name = "Punish";
        case "silence_sound"
            name = "Silence";
        case "deu_katrin_da"
            name = "Area No. 1";
        case "ita_marta_qui"
            name = "Area No. 2";
        case "eng-uk_judith_here"
            name = "Area No. 3";
        case "fra_vion_la"
            name = "Area No. 4";
        case "pol_yolande_tam"
            name = "Area No. 5";
        case "rus_gulnara_tut"
            name = "Area No. 6";
        otherwise
            name = sound_str;
    end
    
    if startsWith(sound_str, 'target_')
            name = "Target area " + sound_str(end);
    end
end

function update_location_box(maestro_states, h_box, mdp_type, frame_ind)
    if strcmp(mdp_type, "nightRIFF")
        area_num = maestro_states.area(frame_ind);
        area_str = string(area_num);
        if (area_num == 0)
            area_str = "Center";
        end
    else
        area_type = maestro_states.r_areatype(frame_ind);
        area_num = maestro_states.r_area(frame_ind);
        if(area_num == 0)
            area_num = "";
        end
        area_str = string(area_type) + area_num;
    end
    
    h_box.String = "Area: " + area_str;
end

function data_dir = read_and_validate_data_dir(handles)
    data_dir = handles.dir_intext.String;
    
    if ~isfolder(data_dir)
        data_dir = -1;
    end
end
