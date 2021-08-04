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

% Last Modified by GUIDE v2.5 30-Dec-2019 11:15:24

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

    db_h.data.source_dir = 'C:\Users\Owner\Desktop\test\outputs\RIFF_results';
    
    db_h.data.arena_geometrical_db = 'RIFF_int_area_locations_181020.mat';
    handles.h_plots.slider = addlistener(handles.slider, 'Value', 'PostSet' , @slider_Callback);
    handles.data_origin_text.String = db_h.data.source_dir;
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
    
	if handles.video_tick.Value == 1
        file_name = 'sim_video.tif';
        frame = getframe(handles.picture_area);
        imwrite(frame2im(frame), file_name, 'WriteMode', 'append');
    end
    
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
        
        if isfield(handles, 'NA_fig') && isvalid(handles.NA_fig(1))
            xlim(handles.NA_fig(1), [cam_t - WIN_SZ_SHOW, cam_t + WIN_SZ_SHOW]);
            set(handles.NA_fig(1), 'XTick', (cam_t-WIN_SZ_SHOW):2:(cam_t+WIN_SZ_SHOW), 'XTickLabel', -WIN_SZ_SHOW:2:WIN_SZ_SHOW);
            set(handles.NA_fig(2), 'XData', [cam_t cam_t]);
        end
        if isfield(handles, 'NA_fig') && (length(handles.NA_fig) == 3) && isvalid(handles.NA_fig(3))
            xlim(handles.NA_fig(3), [cam_t - WIN_SZ_SHOW, cam_t + WIN_SZ_SHOW]);
            set(handles.NA_fig(3), 'XTick', (cam_t-WIN_SZ_SHOW):2:(cam_t+WIN_SZ_SHOW), 'XTickLabel', -WIN_SZ_SHOW:2:WIN_SZ_SHOW);
        end
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
    h_f = figure('Position', [300, 600, 1500, 200]);
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
    title(h_ax, ['NA around t= ' sprintf('%.2f', cam_t) ' , frame ind: ' num2str(frame_ind)]);
    xlabel(h_ax, 'Rel. time (sec)');
    ylabel(h_ax, 'Event type');
    tightfig(h_f);
%     db_h.data.overview_fig = [h_ax h_curr_point];
    handles.stat_fig = [h_ax h_curr_point];

    % Open NA figure
    if ~isempty(db_h.data.NA_db)
        
        % === Plot the FR dynamic figure ===
        
        h_f2 = figure();
        h_ax2 = axes(h_f2);
        hold(h_ax2, 'on');
        imagesc(h_ax2, [min(rel_cam_t) max(rel_cam_t)], [1 size(db_h.data.NA_FR_arr, 1)], db_h.data.NA_FR_arr(:, start_cam_ind:end_cam_ind));
        colormap(h_f2, parula);
        xlabel(h_ax2, 'time');
        ylabel(h_ax2, 'Clusters');
        set(h_ax2, 'TickDir', 'out', 'YMinorTick', 'off', 'XMinorTick', 'on', ...
            'XMinorGrid', 'on','XGrid', 'on',...
            'XTick', (cam_t-WIN_SZ_SHOW):2:(cam_t+WIN_SZ_SHOW), 'XTickLabel', -WIN_SZ_SHOW:2:WIN_SZ_SHOW, 'FontSize', 11, ...
            'TitleFontSizeMultiplier', 1.3);
        xlim(h_ax2, [cam_t - WIN_SZ_SHOW, cam_t + WIN_SZ_SHOW]);
        ylim(h_ax2, [0.5 size(db_h.data.NA_FR_arr, 1)+0.5]);
        fig_pos = get(h_f, 'Position');
        fig_pos(2) = fig_pos(2) - 250;
        set(h_f2, 'position', fig_pos);
        set(h_ax2, 'position', h_ax.Position);
        
        h_curr_point = plot([cam_t cam_t], [0.5 size(db_h.data.NA_FR_arr, 1)+0.5], 'linewidth', 2, 'color', 'w',...
                        'parent', h_ax2);
        h_curr_point.Color(4) = 0.8;
        handles.NA_fig = [h_ax2 h_curr_point];
        
        % === Plot the single cluster trace ===
        NA_WIN_SZ = 0.5;
                
        h_f3 = figure();
        h_ax3 = axes(h_f3);
        hold(h_ax3, 'on');
        [curr_NA, t_lims, ind_lims] = read_NA_raw_data(cam_t, NA_WIN_SZ);
        elec_num = db_h.data.NA_db(handles.NA_list.Value).elec_num;
        EXPANSION_FACT = 500;
        n_samples = diff(ind_lims) + 1;
        ts = interp1([1 n_samples] , t_lims, 1:n_samples, 'linear', 'extrap');
        plot(h_ax3, ts, curr_NA + int16(1:32)*EXPANSION_FACT, 'k', 'linewidth', 0.5);
        hold(h_ax3, 'on');
        
        % Add the spike detections
        sp_SNR_ts = db_h.data.NA_db(handles.NA_list.Value).sp_SNR_ts;
        sp_SNR_ts = sp_SNR_ts((sp_SNR_ts > (cam_t-NA_WIN_SZ)) & (sp_SNR_ts < (cam_t+NA_WIN_SZ)));
        
        hl = plot(h_ax3, sp_SNR_ts, (sp_SNR_ts*0 + elec_num)*EXPANSION_FACT, 'ro', ...
                                            'MarkerSize', 40, 'LineWidth', 2);
        if ~isempty(hl)
            hl.Color(4) = 0.3;
        end
        xlabel(h_ax3, 'Time (ms)');
        ylabel(h_ax3, 'Voltage');
        set(h_ax3, 'TickDir', 'out', 'YMinorTick', 'off', 'XMinorTick', 'on', ...
            'XMinorGrid', 'on','XGrid', 'on',...
            'XTick', (cam_t-NA_WIN_SZ):0.01:(cam_t+NA_WIN_SZ), ...
            'XTickLabel', (-NA_WIN_SZ:0.01:NA_WIN_SZ)*1000, 'FontSize', 11, ...
            'TitleFontSizeMultiplier', 1.3);
        xlim(h_ax3, [cam_t - NA_WIN_SZ, cam_t + NA_WIN_SZ]);
        ylim(h_ax3, [0 33*EXPANSION_FACT]);
        set(h_f3, 'position', [900, 83, 889, 1033]);
        
        handles.NA_fig = [handles.NA_fig h_ax3];
    end
    
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

function global_stats_Callback(~, ~, handles)
    global db_h
    h_wb = waitbar(0.3, 'Please wait...');
    
    if strcmp(db_h.data.mdata.exp_name, 'nightRIFF')
        event_name_arr = arrayfun(@num2str, 1:6, 'uni',0);
        soundstype_arr = db_h.data.sound_table.soundtype(1:end-1);
    elseif strcmp(db_h.data.mdata.exp_name, 'Maciej')
        event_name_arr = {'att', 'warning', 'safe', 'reward', 'negative', 'punish', 'target'};
        soundstype_arr = db_h.data.sound_table.area(1:end-1);
    else
        error('Event names are not yet defined for Anas experiments');
    end
    noabort_arr = db_h.data.sound_table.noabort(1:end-1);
    t_cam = db_h.data.t_cam_times_inter(2:end);
    t_sound = db_h.data.t_sound;
    speed_arr = db_h.data.speed_arr;
    
    t_lims = 3;  % time window around each event
    for curr_name_ind = 1:length(event_name_arr)  % For each sound type, plot NP-vs-t and V-vs-t
        events_inds = soundstype_arr == event_name_arr{curr_name_ind};
        event_ts = t_sound(events_inds);  % Get all SNR times when the current sound happened
        no_abort_t = noabort_arr(find(events_inds, 1))/192000;
        
        % Create the V-vs-t figure for the current sound statistics
        h_f_speed = figure('Position', [50,750,600,150]);
        h_ax_speed = axes(h_f_speed);
        hold(h_ax_speed, 'on');
        
        % Create the NosePoke-vs-t figure for the current sound statistics
        h_f_nps = figure('Position', [700,750,600,150]);
        h_ax_nps = axes(h_f_nps);
        hold(h_ax_nps, 'on');
        
        means = zeros(length(event_ts), 2*10*t_lims);
        means_counter = 1;
        for i = 1:length(event_ts)  % For each instance of the current sound replay, extract events in its time window
            curr_sound_t = event_ts(i);
            % Plot speed around each event
            curr_vals = speed_arr((t_cam > (curr_sound_t-t_lims)) & (t_cam < (curr_sound_t+t_lims)));
            if isempty(curr_vals)
                continue;
            end
            x = 1:length(curr_vals);
            h_l = plot((x - mean(x))/10 ,curr_vals, 'k', 'Parent', h_ax_speed);
            h_l.Color(4) = 0.2;
            if(length(curr_vals) == 2*10*t_lims)
                means(means_counter, :) = curr_vals';
                means_counter = means_counter + 1;
            end
            
            % Plot NP around each event
            for port_no = 1:12  % NP times of each port are saved in a separate array, in 'db_h.data.behave_struct.beam_timings'
                all_nps = db_h.data.behave_struct.beam_timings{port_no};
                % 'all_np' stores both NP onset and offset, interchangeably
                all_np_on = all_nps(1:2:end);  % Extract only onsets
                all_np_off = all_nps(2:2:end); % Extract only offsets
                if ~isempty(all_nps)  % If this port was totally inactive, skip on
                    curr_nps_on = all_np_on((all_np_on > (curr_sound_t-t_lims)) &...
                                            (all_np_on < (curr_sound_t+t_lims)));  % Extract event for the current time window
                    if ~isempty(curr_nps_on) % If no NPs happened in this time window at this port, skip on
                        curr_nps_off = all_np_off((all_np_on > (curr_sound_t-t_lims)) &...
                                                (all_np_on < (curr_sound_t+t_lims)));
                        curr_nps = zeros(1, length(curr_nps_on)*3); % Create array for NP duration.
                        curr_nps(1:3:end) = curr_nps_on-curr_sound_t;
                        curr_nps(2:3:end) = curr_nps_off-curr_sound_t;
                        curr_nps(3:3:end) = curr_nps_off-curr_sound_t;
                        curr_nps_x = curr_nps; % Create corresponding x array, NaNs create gaps in the solid line
                        curr_nps_x(1:3:end) = i;
                        curr_nps_x(2:3:end) = i;
                        curr_nps_x(3:3:end) = NaN;
                        h_np = plot(curr_nps, curr_nps_x, 'r', 'Parent', h_ax_nps);
                        h_np = plot(curr_nps_on - curr_sound_t,...
                                   (1:length(curr_nps_on))*0+i, 'r.',...
                                    'MarkerSize', 10, 'Parent', h_ax_nps);
                    end
                end
                
                all_foods = db_h.data.behave_struct.food_timings{port_no};
                if ~isempty(all_foods)
                    curr_foods = all_foods((all_foods > (curr_sound_t-t_lims)) &...
                                           (all_foods < (curr_sound_t+t_lims)));
                    if ~isempty(curr_foods)
                        h_np = plot(curr_foods - curr_sound_t, (1:length(curr_foods))*0+i,...
                                    'g.', 'MarkerSize', 10, 'Parent', h_ax_nps);
                    end
                end
            end
        end
        means = means(1:(means_counter-1), :);
        med = median(means, 1);
        mean_data = mean(means, 1);
        MAGNIF_FACT = 3;  % The statistics are too low -> they are magnified by a factor
        plot((-(10*t_lims-1):(10*t_lims))/10 ,med*MAGNIF_FACT, 'r', 'LineWidth', 2,...
             'parent', h_ax_speed);
        plot((-(10*t_lims-1):(10*t_lims))/10 ,mean_data*MAGNIF_FACT, 'g', 'LineWidth', 2,...
            'parent', h_ax_speed);
        add_info_to_plot(h_ax_speed, h_f_speed);  % Replots 
        add_info_to_plot(h_ax_nps, h_f_nps, i);
    end
    
    function add_info_to_plot(h_ax, h_f, counter)
        if nargin > 2
%             h_bar = plot([0 no_abort_t], [0 counter], 'k', 'linewidth', 4, 'parent', h_ax);
            p1 = patch(h_ax, [0 0 no_abort_t no_abort_t], [0 counter counter 0], 'k', 'parent', h_ax);
            p1.FaceAlpha = 0.2;
            ylim(h_ax, [0 counter]);
            ylabel(h_ax, 'Sound ind.');
        else
%             h_bar = plot([0 no_abort_t], [0 40], 'k', 'linewidth', 4, 'parent', h_ax);
            p1 = patch([0 0 no_abort_t no_abort_t], [0 40 40 0], 'k', 'parent', h_ax);
            p1.FaceAlpha = 0.2; 
            ylim(h_ax, [0 40]);
            ylabel(h_ax, 'Speed (pixels)');
        end
        xlim(h_ax, [-3, 3]);
        h_bar.Color(4) = 0.3;
        xlabel(h_ax, 'Rel. time (sec)');
        
        title(h_ax, [num2str(event_name_arr{curr_name_ind}) '. Event #: ' num2str(length(event_ts))]);
%         tightfig(h_f);
    end

    try
         close(h_wb)
    catch
         
    end
end

function reward_area_analysis_Callback(~, ~, handles)
global db_h

    MDP_state_arr = string(db_h.data.maestro_states.behavior);
    MDP_area_arr = string(db_h.data.maestro_states.s_area);
    t_states = db_h.data.t_state;
    t_cam_interp = db_h.data.t_cam_times_inter;
    reward_indic = (MDP_state_arr == 'reward');
    area_arr = str2double(MDP_area_arr(reward_indic));  % Get area No. {1...6} of each 'reward' state 
    figure; histogram(area_arr, 'binmethod', 'integers'); title('Rewards per area');
    change_of_area = diff(area_arr);    % Eval changed of areas (0 == no change)
    disp(['Number of repeating rewards: ' num2str(sum(change_of_area == 0))]);
    reward_inds = find(reward_indic);   % Get state indices of the rewarded states
    rep_ind_list = reward_inds([change_of_area' 1] == 0); % Filter out indices of repeating rewards in same state.
    cam_t_arr = rep_ind_list*0;         % Init time array of same size as repeating reward events
    for i = 1:length(rep_ind_list)      % For each faulty repeating reward event, find when it happens in simulation frame units
        t_event = t_states(rep_ind_list(i));  % Extract the SNR time of the first reward event
        cam_t_arr(i) = find(t_cam_interp > t_event, 1, 'first'); % find the SNR time of following frame
    end
    disp('Indices with repeating reward:');
    disp(cam_t_arr);
    
    % Plot traj evolution along time
    
    [x, y] = pol2cart(deg2rad(60*area_arr), 1); % Map numbers {1 ... 6} to corners of an hexagon
    figure;
    plot3(x, y, (1:length(x))/50, 'linewidth', 1, 'color', 'k');
    daspect([1 1 1]); hold on;
    scatter3(x, y, (1:length(x))/50, 40, 1:length(x), 'filled');  % Z units are the reward number
    zlabel('Time');
    title('Evolution of the trajectory along the experiment');
    
    %Plot the warning events on top
    if strcmp(db_h.data.mdata.exp_name, 'Maciej')
        warning_indic = string(db_h.data.maestro_states.s_areatype) == 'Warning';
        warning_indic = [0 (diff(warning_indic) == 1)'];      % Find the first state events of the consecutive series of warnings
        warning_ts = t_states([warning_indic 0] == 1);        % Get their SNR times
        reward_ts = t_states(reward_indic);                   % Get reward SNR times
        warning_ts = warning_ts(warning_ts < reward_ts(end)); % Remove all warnings from the end of the experiment
        warning_inds_aligned_to_rew = warning_ts*0;           % init array of the correct size
        for i = 1:length(warning_ts) 
            warning_inds_aligned_to_rew(i) = find(warning_ts(i) < reward_ts, 1, 'first');
        end
    end
    %%% Over-print the red points over the helix
%     h_warn = scatter3(x(warning_inds_aligned_to_rew)*1.1, y(warning_inds_aligned_to_rew)*1.1,...
%                       (warning_inds_aligned_to_rew)/50, 80, 'r', 'filled');
end

function NA_corr_button_Callback(hObject, ~, handles)
    global db_h
    curr_NA_ind = handles.NA_list.Value;
    if (curr_NA_ind == length(handles.NA_list.String))  % Last list item is sum of all NA
        db_h.data.curr_traj_c = mean(db_h.data.NA_FR_arr, 1);
    else
        db_h.data.curr_traj_c = db_h.data.NA_FR_arr(curr_NA_ind, :);
    end
    
    handles = replot(handles);
    set(handles.picture_area, 'CLim', [0 max(db_h.data.curr_traj_c)*3/4]); % Rescale the colors to the global activity of the neurons
    guidata(hObject, handles);
end

function plot_raw_NA_button_Callback(hObject, ~, handles)
    global db_h
    frame_ind = handles.state.frame_ind;
    cam_t = db_h.data.SNR_IND_cell_arr(frame_ind).cam_interp_t;
    [curr_NA, curr_ts, full_NA, full_ts] = read_NA_raw_data(cam_t, 10);
    
    % === Fig1: Plot the raw NA traces ====
    
    h_f = figure();
    h_ax = axes(h_f);
    plot(h_ax, (curr_ts - cam_t)*1000, curr_NA + int16((1:db_h.data.NA_ch_num)*400), 'k', 'LineWidth', 0.5);
    ylim(h_ax, [0 17*400]);
    xlim(h_ax, [-10 10]*1000);
    h_ax.XAxis.Exponent = 0;
    xlabel(h_ax, 'Time (msec)');
    ylabel(h_ax, 'Channels');
    title(h_ax, 'NA - mean+moise-reduced, high-passed 15Hz');
    hold(h_ax, 'on');
    
    % Add the detected spikes, per channel
    
    NA_db = db_h.data.NA_db;
    sel_clust_num = [];
    sel_sp_ts = [];
    sel_elec_num = 0;
    for i = 1:length(NA_db)
        curr_SNR_ts = NA_db(i).sp_SNR_ts;
        curr_SNR_ts = curr_SNR_ts((curr_SNR_ts > (cam_t-10)) & (curr_SNR_ts < (cam_t+10)));
        elec_num = NA_db(i).elec_num + randn()*0.1;
        
        plot_color = 'r.';
        if i == handles.NA_list.Value
%             sel_sp_inds = NA_db(i).sp_inds((curr_SNR_ts > (cam_t-10)) & (curr_SNR_ts < (cam_t+10)));
            sel_clust_num = i;
            sel_elec_num = NA_db(i).elec_num;
%             sel_sp_ts = curr_SNR_ts;
            plot_color = 'g.';
        end
        plot(h_ax, (curr_SNR_ts - cam_t)*1000, ones(size(curr_SNR_ts))*elec_num*400, plot_color, 'MarkerSize', 15);
    end
    
    h_f.Position = [1161 180 738 746];
    tightfig(h_f);
      
    % === Fig2: Align the extracted spikes ===
    
    h_f2 = figure();
    spike_ts_in_raw = NA_db(sel_clust_num).sp_SNR_ts;
    rel_times_inds = (spike_ts_in_raw > full_ts(1)) & (spike_ts_in_raw < full_ts(end));
    spike_ts_in_raw = spike_ts_in_raw(rel_times_inds);
    [~, rel_inds] = custom_round(full_ts, spike_ts_in_raw);
    [spike_mat, rel_inds] = extract_spikes_to_mat_and_realign(double(full_NA(:, sel_elec_num)), rel_inds);   
    h_ax22 = subplot(1,4,1);
    x = [(-32-10):(32+10)];
    plot(h_ax22, x, std(spike_mat, 0, 2));
    title(h_ax22, 'STD of the spikes');
    xlabel(h_ax22, 'Time (ms)');
    ylabel(h_ax22, 'STD');
    xlim(h_ax22, [min(x) max(x)]);
    
    h_ax23 = subplot(1,4,2);
    cs = get(h_ax23, 'colororder');
    h_l = plot(h_ax23, x, spike_mat, 'k', 'LineWidth', 0.5);
    set(h_l, 'Color', [h_l(1).Color 0.05]);
    hold(h_ax23, 'on');
    emp_mean = mean(spike_mat, 2);
    h_m1 = plot(h_ax23, x, emp_mean, 'Color', cs(1, :), 'LineWidth', 2);
    [temp_scaled] = normalize_data(NA_db(sel_clust_num).template, [min(emp_mean), max(emp_mean)]);
    temp_longer = [zeros(24, 1); temp_scaled];
    h_m2 = plot(h_ax23, x, temp_longer, '--', 'Color', cs(2, :), 'LineWidth', 2);
    title(h_ax23, 'Found spikes, mean and KS template');
    xlabel(h_ax23, 'Time (ms)');
    ylabel(h_ax23, 'Relative amplitude');
    xlim(h_ax23, [min(x) max(x)]);
    ylim(h_ax23, [min(emp_mean) max(emp_mean)]*2);
    
    amps = NA_db(sel_clust_num).spike_amps(rel_times_inds);   
    h_ax24 = subplot(1,4,3);
    histogram(h_ax24, amps, 100);
    title(h_ax24, 'Histogram of amplitudes');
    xlabel(h_ax24, '| Amp |');
    ylabel(h_ax24, 'Counts');
    
%     cr = [];
%     cr(rel_inds) = 1;
%     r = xcorr(cr, 32*30);
%     r(ceil(end/2)) = 0;
    d = diff(rel_inds)/32;
    h_ax25 = subplot(1,4,4);
%     bar(h_ax25, r);
    histogram(h_ax25, d(d < 100), 100)
    title(h_ax25, 'Histogram ISI');
    xlabel(h_ax25, 'Time (ms)');
    ylabel(h_ax25, 'Counts');
    set(h_f2, 'Position', [73 831 1688 223]);
    tightfig(h_f2);
    set(h_f2, 'Position', [73 831 1688 223]);
    
    legend([h_l(1) h_m1 h_m2], {'Spikes', 'Empirical mean', 'KS template'}, 'Location', 'southeast');
end

function export_NA_button_Callback(hObject, ~, handles)
    global db_h
    file_name = ['NA_FR_' db_h.data.mdata.exp_date '_rat' num2str(db_h.data.mdata.rat_no) '.mat'];
    full_name = fullfile(db_h.data.mdata.rat_dir, 'ks_output', file_name);
    FR_NA = db_h.data.NA_FR_arr;
    save(full_name, 'FR_NA');
    winopen(fullfile(db_h.data.mdata.rat_dir, 'ks_output'));
    disp(['File saved as: ' full_name]);
end

function cluster_stats_button_Callback(hObject, ~, handles)
    global db_h
    curr_clust = handles.NA_list.String{handles.NA_list.Value};
    if curr_clust == "Sum of all"
        disp('Don`t have stats for mean of all values');
        return;
    end
    % === Open the cluster quality ===
    el_num = regexp(curr_clust ,'E=(\d*)', 'tokens');
    ch_num = regexp(curr_clust ,'h=(\d*)', 'tokens');
    f_name = ['stats_e' el_num{1}{1} '_ch_' ch_num{1}{1} '.png'];
    winopen(fullfile(db_h.data.NA_mdata.ks_output_dir, 'single_unit_stats', f_name));
end

function plot_xcorrs_button_Callback(hObject, ~, handles)
    global db_h
    
    h_f = figure('Position', [400, 150, 1050, 940]);
    h_ax = axes(h_f);
    
    % === Agregate behavioral variables (BV) =============
    
    BV_names = handles.emb_colorby_list.String;
    BV_names = BV_names(~strcmp(BV_names, 'prev_area')); % Remove the empty data
    BV_mat = zeros(length(db_h.data.action_speed), length(BV_names));
    
    for i = 1:length(BV_names)
        curr_name = BV_names{i};
        [data, ~, ~] = get_data_arr_by_name(curr_name);
        BV_mat(:, i) = data;
    end
    n_statists = length(BV_names);
    
    % === Compute the corr-coeff + cluster the data ========
    BV_mat = normalize(BV_mat);
    corr_mat = corrcoef(BV_mat);
    c = clusterdata(BV_mat', 'Maxclust', 10);
    [~, inds] = sort(c);
    corr_mat = corr_mat(inds, inds);
    BV_names = BV_names(inds);
    corr_mat = corr_mat - eye(size(corr_mat));
    
    % ======= Plot the corrcoeff mat ==============
    
    imagesc(h_ax, corr_mat);
    
    colorbar(h_ax);
    colormap(redbluecmap(11));
%     caxis(h_ax, [-0.6 0.6]);
    h_ax.TickDir = 'out';
    h_ax.Box = 'off';
    axis(h_ax, 'image');
    
    set(h_ax, 'XTickLabel', BV_names, 'YTickLabel', BV_names);
    set(h_ax, 'XTick', 1:length(BV_names), 'YTick', 1:length(BV_names));
    h_ax.XTickLabelRotation = 270;
    h_ax.TickLabelInterpreter = 'None';
    title(h_ax, 'Absolute correlations, clipped to 0.6');
    tightfig(h_f);
    
    % === Compute the agglomertive clustering =================
        
%     [~, inds] = sort(a, 'descend');
%     xcorrs_sorted = abs(xcorrs(inds, inds));
%     figure; imagesc(xcorrs_sorted);
%     
%     NA = db_h.data.NAs.l4_active_neurs;
%     xcorrs = xcorr(NA, 'maxlag', 1000);  % maxlag limits the correlation shift to the range [-1000, 1000]
%     
%     CGobj = clustergram(BV_mat');   % Requires Bio-inf toolbox

    Z = linkage(BV_mat', 'complete');
	cutoff = median([Z(end-2,3) Z(end-1,3)]);
    groups = cluster(Z, 'cutoff', cutoff, 'criterion', 'distance');
    
    h_f = figure();
    h_ax = axes(h_f);
    dendrogram(Z, 0, 'ColorThreshold', cutoff, 'Labels', BV_names);
    h_ax.XTickLabelRotation = 270;
    h_ax.TickLabelInterpreter = 'None';
end

function [data, cmap_is_cyclic, interp_per_class] = get_data_arr_by_name(colorby_str)

% Helper function that extract a statist data based on the data name string, as written in the
% list of colorings in the GUI.
%
% Inputs:
%   colorby_str - str - Name of the variable, as in the GUI list
%
% Outputs:
%   data - [N x 1] matrix - Numeric data holding one of the statist values.
%   cmap_is_cyclic - flag - Indicator if the values are cyclic and thus has to be plotted with CMYK
%   interp_per_class - flag - Indicator if the statist is descrete - map unique values to colors

    global db_h
    
    cmap_is_cyclic = 0;  % Use a cyclic colormap to represent angles
    interp_per_class = 0; % For DBs with non-uniform + descrete + small number of items, paint each in a new color
    if startsWith(colorby_str, 'MDP') % Example: colorby_str == "MDP | targ_1_wait"
        string_key = colorby_str(7:end);
        data = double(strcmp(db_h.data.MDP_state, string_key));
        interp_per_class = 1;
    elseif startsWith(colorby_str, 'zone') % zone -> EDGE, CENTER 
        string_key = colorby_str(8:end);
        data = double(strcmpi(db_h.data.zone, string_key));
        interp_per_class = 1;
    elseif startsWith(colorby_str, 'neuron_')
        data = db_h.data.NAs.l4_active_neurs(:, str2double(colorby_str(8:end)));
    else
        switch colorby_str
            case 'port'
                data = db_h.data.port;
                cmap_is_cyclic = 1;
                interp_per_class = 1;
            case 'max_q'
                data = db_h.data.max_q;
            case 'action_turn'
                data = db_h.data.action_turn;
                interp_per_class = 1;
            case 'action_speed'
                data = db_h.data.action_speed;
                interp_per_class = 1;
            case 'loc_x'
                data = db_h.data.loc_x;
            case 'loc_y'
                data = db_h.data.loc_y;
            case 'speed'
                data = db_h.data.speed;
                interp_per_class = 1;
            case 'direc'
                data = cart2pol(db_h.data.direc(:, 1), db_h.data.direc(:, 2));
                cmap_is_cyclic = 1;
                interp_per_class = 1;
            case 'sound'
                data = db_h.data.sound;
                interp_per_class = 1;
            case 'prev_area'
                data = db_h.data.prev_area;
            case 'speed_arr'
                data = db_h.data.speed_arr;
                interp_per_class = 1;
            case 'radius'
                [~, r] = cart2pol(db_h.data.loc_x, db_h.data.loc_y);
                data = r;
            case 'arena_angle'
                [theta, ~] = cart2pol(db_h.data.loc_x, db_h.data.loc_y);
                data = theta;
                cmap_is_cyclic = 1;
            case 'uMDP | targs'
                data = db_h.data.MDP_targ_arr;
                interp_per_class = 1;
            case 'uMDP | targ_waits'
                data = db_h.data.MDP_targ_wait_arr;
                interp_per_class = 1;
            case 'uMDP | combined'
                data = db_h.data.MDP_all;
                interp_per_class = 1;
            case 'uzone | combined'
                data = db_h.data.zone_all;
                interp_per_class = 1;
            case 'rew'
                data = db_h.data.rew;
                interp_per_class = 1;
            otherwise
                data = db_h.data.index;
        end
    end
end

function export_behav_DB_Callback(hObject, ~, handles)
    global db_h
    
    h_wb = waitbar(0.3, 'flattening experiment data...');
    flatten_single_experiment(db_h.data.mdata.base_dir, db_h.data.mdata.rat_no);
    delete(h_wb);
    return;
    [corr_db, mdata] = gather_correlation_statists(db_h.data);
    field_names = fields(corr_db);
    
    % Correct flipped vectors
    for i = 1:length(field_names)
        if size(corr_db.(field_names{i}), 2) > size(corr_db.(field_names{i}), 1)
            corr_db.(field_names{i}) = corr_db.(field_names{i})';
        end
    end
    
    % Add images
    if size(db_h.data.image_arr, 1) == 50
        corr_db.images = db_h.data.image_arr;
    elseif size(db_h.data.image_arr, 1) == 100
        corr_db.images = db_h.data.image_arr(1:2:end, 1:2:end, :);
    elseif size(db_h.data.image_arr, 1) == 200
        corr_db.images = db_h.data.image_arr(1:4:end, 1:4:end, :);
    else
        1; % Skip the image addition, no idea what is the image size...
    end
    
    % Add the mdata
    corr_db.mdata = mdata;
    
    % Remove behaviorally-unrelevant field + categorical arrays
    corr_db = rmfield(corr_db, {'LED_arr', 'area_num'});
    
    % Saving the data
%     save(fullfile(db_h.data.mdata.rat_dir, '..\flat_behav_DB.mat'), '-struct', 'corr_db', '-v7');  % Good for python 'loadmat'
	save(fullfile(db_h.data.mdata.rat_dir, 'flat_behav_DB.mat'), '-struct', 'corr_db', '-nocompression');  % Good for python 'h5py'
    disp('=== FS : The flat DB file `flat_behav_DB.mat` is created in the experiment folder ===');
    
end

function open_dir_button_Callback(hObject, ~, handles)
    global db_h
    winopen(db_h.data.mdata.rat_dir);
end

function prepare_stats_button_Callback(hObject, ~, handles)
    global db_h
    [corr_db, mdata] = gather_correlation_statists(handles);
    NA_FR = db_h.data.NA_FR_arr;
    corr_db.NA_FR = NA_FR;
    
    % === Agregate behavioral variables (BV) =============
    field_names = fields(corr_db);
    flat_db = [];
    field_names_big = {};
    for i = 1:length(field_names)
        curr_data = corr_db.(field_names{i});
        curr_shape = size(curr_data);
        if(curr_shape(1) < curr_shape(2))
            curr_data = curr_data';
        end
        n_rows = min(curr_shape);
        for j = 1:n_rows
            field_names_big{end+1} = field_names{i};
            if n_rows > 1
                field_names_big{end} = [field_names_big{end} num2str(j)];
            end
            flat_db = [flat_db curr_data(:, j)];
        end
    end
    % Change the sound types to the real names
%     sound_types_num = length(mdata.sounds_type_keys);  %AK 190520
    sound_types_num = length(mdata.sounds_names);
    for i = 1:sound_types_num
%         field_names_big{end - sound_types_num + i} = mdata.sounds_type_keys{i};    %AK 190520
        field_names_big{end - sound_types_num + i} = mdata.sounds_names{i};
    end
    
    % === add control random binary arrays. K=N/100 bits are on, (k-10) are correlated
    arr_len = max(size(flat_db));
    y = randsample(arr_len, floor(arr_len/100));
    y2 = y + 32*10*5;  % Shift the correlation by 5 seconds. Single bin is 0.1sec
    y2(y2 > arr_len) = arr_len;
    arr1 = zeros(arr_len, 1);
    arr1(y) = 1;
    arr2 = zeros(arr_len, 1);
    arr2(y2) = 1;
    flat_db = [flat_db arr1 arr2];
    field_names_big{end+1} = 'control1';
    field_names_big{end+1} = 'control2';
    db_h.data.flat_db = flat_db;
    db_h.data.field_names_big = field_names_big;
    
    % === Save the data in a file ====
%     db_h.data.mdata.sound_names = mdata.sounds_type_keys;  % Save the sound names   %AK 190520
    db_h.data.mdata.sound_names = mdata.sounds_names;  % Save the sound names
    f_name = fullfile(db_h.data.mdata.rat_dir, 'processed_NA_FR_DB.mat');
    NA_FR_DB = struct('var_names', {field_names_big},...
                      'flat_db', flat_db, ...
                      'mdata', db_h.data.mdata, ...
                      'bg_image', db_h.data.bg_image);
    save(f_name, '-struct', 'NA_FR_DB');
    
    % === Compute the corr-coeff + cluster the data ========
    flat_db = normalize(flat_db);
    corr_mat = corrcoef(flat_db);
    c = clusterdata(flat_db', 'Maxclust', 10);
    [~, inds] = sort(c);
    corr_mat = corr_mat(inds, inds);
    field_names_big = field_names_big(inds);
    corr_mat = corr_mat - eye(size(corr_mat));
    
    
    % ======= Plot the corrcoeff mat ==============
    h_f = figure();
    h_ax = axes(h_f);
    imagesc(h_ax, corr_mat);
    
    colormap(redbluecmap(11));
%     caxis(h_ax, [-0.6 0.6]);
    h_ax.TickDir = 'out';
    h_ax.Box = 'off';
    axis(h_ax, 'image');
    
    set(h_ax, 'XTickLabel', field_names_big, 'YTickLabel', field_names_big);
    set(h_ax, 'XTick', 1:length(field_names_big), 'YTick', 1:length(field_names_big));
    h_ax.XTickLabelRotation = 270;
    h_ax.TickLabelInterpreter = 'None';
    title(h_ax, 'Absolute correlations, clipped to 0.6');
    set(h_f, 'position', [1 41 1920 1083]);
    tightfig(h_f);
    colorbar(h_ax);
    set(h_f, 'position', [1 41 1920 1083]);
    grid(h_ax, 'on');
end

function NA_heatmap_button_Callback(hObject, ~, handles)
    % Function that creates custom 2D histogram maps
    global db_h
    get_statist_arr = 0;
    NA_ind = handles.NA_list.Value;
    curr_NA_name = ['NA_FR' num2str(NA_ind)];
    curr_statist = db_h.data.flat_db(:, strcmp(db_h.data.field_names_big, curr_NA_name));
    locs = db_h.data.loc_arr;
    bg_image = db_h.data.bg_image;
    
    x = locs(:, 1);
    y = locs(:, 2);
    x(x < 0) = 1;  % Remove the -1 values for lost frames
    y(y < 0) = 1;
    BINS = 128;
    [data] = hist2D_custom_w(x, y, curr_statist, size(bg_image), BINS);
    h_f = plot_loc_heatmap();
    h_f.Position = [100   400   705   550];
    
	curr_statist = curr_statist(randperm(length(curr_statist)));  % Test the result against random
    curr_NA_name = [curr_NA_name '_perm'];
    [data] = hist2D_custom_w(x, y, curr_statist, size(bg_image), BINS);
    h_f = plot_loc_heatmap();
    h_f.Position = [810   400   705   550];
    
    function h_f = plot_loc_heatmap()

    % Function plot_loc_heatmap plots a heat map of the rat location along the whole experiment.

        h_f = figure('Position', [100, 400, 800, 550]);
        h_ax = axes();
        h_im = imshow(cat(3, bg_image, bg_image, bg_image), 'parent', h_ax, 'InitialMagnification', 'fit');
        hold(h_ax, 'on');
        h_l = scatter(h_ax, data(:, 1), data(:, 2), 24, data(:, 3), 's', 'filled');
        title(h_ax, ['Heatmap statist: ' curr_NA_name], 'FontSize', 16, 'Interpreter', 'none');
        prev_size = h_ax.Position;
    %     colorbar(h_ax);
        h_ax.Visible = 'off';
        h_ax.Position = [0.05 0.05 0.9 0.9];
        xlim(h_ax, [100 640-100]);
        ylim(h_ax, [50 480-50]);
        colorbar(h_ax);
        h_ax.CLim = ([0 h_ax.CLim(2)/2]);
%         fname = fullfile(out_folder, 'camera_heatmap.png');
    %     print(h_f, 'R2_heatmap_new.png', '-dpng', '-r600');
    %     savefig(h_f, 'R2_heatmap_new.fig');


        % === Adjustments for PDF export (vetorized graphics) ===
    %     h_ax.Units = 'centimeters';
    %     set(h_f, 'PaperUnits', 'centimeters', 'PaperSize', [h_ax.OuterPosition(3) h_ax.OuterPosition(4)] - 1)
    %     print('test.pdf', '-dpdf', '-painters');
    end
end

function invPSTH_button_Callback(hObject, ~, handles)

%{

Function that calculates the inverse-PSTH.
1. Find times when NA of cluster C_i is above THR.
2. For high NA event get its time: NA_t_i
3. For arbitrary variable, crop events around NA_t_i
4. Align all cropped events for the NA_t_i -> look for "event aggregation" around the NA_t_i


%}

    global db_h
    NA = db_h.data.NA_FR_arr;
    flat_db = db_h.data.flat_db;
    db_names = db_h.data.field_names_big;
    [sim_tick_n, var_n] = size(flat_db);
    WINDOW_SIZE = 10;           % The full window, including both directions.
    FPS = 10;  % The latency of the simulations - 10 FPS - every bin is 100 ms
    x_samp = -(WINDOW_SIZE/2*FPS):(WINDOW_SIZE/2*FPS);
    t_samp = x_samp / FPS;
    
    n_clusters = size(NA, 1);
    FR_spike_ind_arr = get_active_FR_areas(NA);
    
    h_wb = waitbar(0, 'Please wait...');
    for clust_i = 1:n_clusters  % For each NA cluster, plot all events inverse-PSTHs
        curr_high_NA_ts = FR_spike_ind_arr{clust_i};
        h_f = figure();
        subp_height = 10;
        subp_width = ceil(var_n/subp_height);
        for event_i = 1:var_n
            curr_var = flat_db(:, event_i);
            
            % === Open new plot for each cluster_group & variable ====
            
            
            h_ax = subplot(subp_height, subp_width, event_i);
            
            if length(unique(curr_var)) == 2  % For binary statist arrays plot black dots PSTHs
                curr_mat = zeros(length(curr_high_NA_ts), length(x_samp));
                curr_xs = zeros(length(curr_high_NA_ts), length(x_samp));
                for curr_NA_t = 1:length(curr_high_NA_ts)
                    curr_t = curr_high_NA_ts(curr_NA_t);
                    if (curr_t < ceil(length(x_samp)/2)) || (curr_t > sim_tick_n - ceil(length(x_samp)/2))
                        continue;  % If the first activity is too early
                    end
                    xx = t_samp;
                    xx(curr_var(curr_t + x_samp) == 0) = NaN;
                    curr_xs(curr_NA_t, :) = xx;
                    curr_mat(curr_NA_t, :) = t_samp*0 + curr_NA_t;
%                     cropped_arr(cropped_arr == 0) = NaN;
%                     plot(h_ax, t_samp, cropped_arr + curr_NA_t, 'k.', 'MarkerSize', 0.5);
%                     hold(h_ax, 'on');
                end
                curr_mat(curr_mat == 0) = NaN;
                scatter(h_ax, curr_xs(:), curr_mat(:), 5, 'k.');
                xlim(h_ax, [-5 5]);
                ylim([0 length(curr_high_NA_ts)])
            else
                curr_mat = zeros(length(curr_high_NA_ts), length(x_samp));
                for curr_NA_t = 1:length(curr_high_NA_ts)
                    curr_t = curr_high_NA_ts(curr_NA_t);
                    if (curr_t < ceil(length(x_samp)/2)) || (curr_t > sim_tick_n - ceil(length(x_samp)/2))
                        continue;
                    end
                    curr_mat(curr_NA_t, :) = curr_var(curr_t + x_samp);
                end
                imagesc(h_ax, t_samp, 1:length(curr_high_NA_ts), curr_mat);
            end
            
            title(db_names{event_i}, 'interpreter', 'non');
        end
        
%         sgtitle(['Clust: ' clust_name ' - inverse-PSTH']);
        set(h_f, 'position', [1921 41 1920 1083]);
        tightfig(h_f);
        set(h_f, 'position', [1921 41 1920 1083]);
        
        % === Print to file ===
        tokens = regexp(handles.NA_list.String{clust_i}, 'E=(\d+)  |  ch=(\d+)', 'tokens');
        e_num = tokens{1}{1};
        ch_num = tokens{2}{1};
        f_name = ['invPSTH_e' e_num '_ch' ch_num];
        p_name = fullfile(db_h.data.mdata.rat_dir, 'ks_output');
        print(h_f, fullfile(p_name, f_name), '-dpng', '-r450');
        drawnow();
        close(h_f);
        
        waitbar(clust_i/n_clusters, h_wb, 'Please wait...');
    end
    delete(h_wb);
end

function close_figs_button_Callback(hObject, ~, handles)
    % Function that closes all
    set(handles.figure1, 'HandleVisibility', 'off');
    close all;
    set(handles.figure1, 'HandleVisibility', 'on');
end

function load_RNN_output_button_Callback(hObject, ~, handles)

    % Function load_RNN_output_button_Callback loads the prediction from LSTMs, plots
    % them in a figure and saves to db_h.
    % The function assumes that the LSTM outputs are saved in 'LSTM_tagged_traces_and_indices_[DDMMYY].mat' in
    % one of the run folders in '.\dropbox\...\RIFF_model\Data integration\GuessNet\RNN\runs\full_trial_LSTM_pred_output'.
    % 
    % The expected contents of the .mat file:
    %     start_inds - (trials x 1 vector) - Indeces of the frames when the trials start
    %     lstm_traces - (trials x timepoints) - The output of the LSTM, each value in [0, 1]

    global db_h
    p_name = 'C:\Users\Owner\Dropbox\Lab - Eli\Project VRat\RIFF_model\Data integration\GuessNet\RNN\runs\full_trial_LSTM_pred_output';
    [filename, pathname] = uigetfile({'*.mat'}, 'Select output file from RNN', fullfile(p_name, 'LSTM_tagged_traces_and_indices.mat'));
    if isequal(filename,0) || isequal(pathname,0)
        disp('User pressed cancel')
    else
        disp(['=== (FS) Loading LSTM data from: ', fullfile(pathname, filename), ' ===']);
        db = load(fullfile(pathname, filename));
    end
    start_inds = double(db.start_inds');
    trial_lengths = double(db.trial_lengths');
    lstm_traces = db.lstm_traces;
    X_eval = db.X_eval;
    Y_eval = double(db.Y_eval');
    feature_means = db.feature_means;
    feature_maxs = db.feature_maxs;
    trained_net_names = db.trained_net_names;
    eval_targets = double(db.eval_targets');
    train_seg_len = double(db.train_seg_len);
    ens_lstm_traces = squeeze(mean(lstm_traces, 1));
    n_frames = db_h.data.frame_n;
    
    % === Fill a linear array of predictions ===
    
    preds_linear = nan(1, n_frames);
    for i = 1:length(start_inds)
        preds_linear(start_inds(i):(start_inds(i)+trial_lengths(i) - 1)) = ens_lstm_traces(i, 1:trial_lengths(i));
    end
    
    % === Plot all preds on a time line ===
    h_fig = figure('position', [41, 298, 1807, 756]);
    h_ax = subplot(2, 3, 1, 'parent', h_fig);
    plot(h_ax, [0 n_frames], [0 0], '--', 'color', [1 1 1]*0.5); hold(h_ax, 'on');
    plot(h_ax, [0 n_frames], [1 1], '--', 'color', [1 1 1]*0.5);
    plot(h_ax, [0 n_frames], [1 1]*0.5, '--', 'color', 'r');
    plot(h_ax, preds_linear, 'k.'); ylim(h_ax, [-0.1, 1.1]);
    ylabel(h_ax, 'RNN output [0, 1]'); xlabel(h_ax, 'Simulation steps');
    
    % === Plot predictions on RIFF spatial outline ===
    locs_partial = db_h.data.loc_arr;
    locs_partial(isnan(preds_linear)) = NaN;
    h_ax = subplot(2, 3, 2, 'parent', h_fig);
    scatter(h_ax, locs_partial(:, 1), locs_partial(:, 2), 20, preds_linear, 'filled')
    colormap(h_ax, jet); colorbar(h_ax); ylim(h_ax, [30, 430]); xlim(h_ax, [130, 520]);
    daspect(h_ax, [1 1 1]);
    
    locs_partial = db_h.data.loc_arr;
    temp_binary = preds_linear;
    temp_binary(temp_binary <= 0.5) = NaN;
    locs_partial(isnan(temp_binary)) = NaN;
    h_ax = subplot(2, 3, 3, 'parent', h_fig);
    h = plot(locs_partial(:, 1), locs_partial(:, 2), 'k'); 
    set(h, 'Color', [0 0 0 0.1]); hold(h_ax, 'on');
    scatter(h_ax, locs_partial(:, 1), locs_partial(:, 2), 20, temp_binary, 'filled');
    colormap(h_ax, jet); colorbar(h_ax); ylim(h_ax, [30, 430]); xlim(h_ax, [130, 520]);
    daspect(h_ax, [1 1 1]);
    
    % === Plot distribution of last frames ===
    h_ax = subplot(2, 3, 4, 'parent', h_fig);
    histogram(h_ax, ens_lstm_traces(:, end));
    xlabel(h_ax, 'Simulation steps {-time_points, -1}', 'interpreter', 'none');
    ylabel(h_ax, 'RNN output [0, 1]');
    
    % === Plot all LSTM predictions one over the other ===
    h_ax = subplot(2, 3, 5, 'parent', h_fig);
    h = plot(h_ax, ens_lstm_traces');
    xlabel(h_ax, 'Simulation steps {-time_points, -1}', 'interpreter', 'none');
    ylabel(h_ax, 'RNN output [0, 1]');
    
    % === Wrap and add to db_h ===
    
    db_h.data.LSTM_data = struct('start_inds', start_inds, ...
                                 'lstm_traces', lstm_traces, ...
                                 'ens_lstm_traces', ens_lstm_traces, ...
                                 'full_path', fullfile(pathname, filename), ...
                                 'X_eval', X_eval, ...
                                 'Y_eval', Y_eval, ...
                                 'feature_means', feature_means, ...
                                 'feature_maxs', feature_maxs, ...
                                 'eval_targets', eval_targets, ...
                                 'trial_lengths', trial_lengths, ...
                                 'preds_linear', preds_linear);
                             
    disp('=== (GUI DB) New fields created: db_h.data.LSTM_data ===');
end

function load_VRat_format_button_Callback(hObject, ~, handles)
    global db_h
    f_name = fullfile(db_h.data.mdata.rat_dir, 'VRat_compare', 'BRat_traj.mat');
    if exist(f_name, 'file')
        db_BRat = load(f_name);
        db_h.data.db_BRat = db_BRat;
    end
    
    handles.load_VRat_format_checkbox.Value = 1;
    
%     BRat_durics = db_h.data.db_BRat.direc_inds;
%     BRat_turns = db_h.data.db_BRat.turn_vec;
%     BRat_speeds = db_h.data.db_BRat.speed_vec;
%     BRat_accel = db_h.data.db_BRat.accel_vec;
%     rat_direcs = db_h.data.rat_angs;
%     h.XAxis.Exponent = 0;
%     ylim([-150 400]);
%     figure; plot(preds, 'r.', 'markersize', 8)
%     figure; plot(preds, '.'); hold on;
%     for i = 1:8
%     plot([0 45000], [1 1]*(i-1)*45, 'k--');
%     end
end

function trail_stats_button_Callback(hObject, ~, handles)
    global db_h
    
    if strcmp(db_h.data.mdata.exp_name, 'Maciej')
        msgbox('This analysis is relevant only for nightRIFF (checks sound latency upon center crossing)! Exising...');
        return;
    end
    
    rat_dir = db_h.data.mdata.rat_dir;
    exp_date = db_h.data.mdata.exp_date;
    analyze_rewarded_trials(rat_dir, exp_date, false)
end

function recolor_trace_Callback(hObject, ~, handles)
    persistent flag
    global db_h
    if isempty(flag) % Init. the flag on first press of the button
        flag = 1;
    end
    
    if flag == 1
        db_h.data.curr_traj_c = db_h.data.rat_body_turns;
    else
        db_h.data.curr_traj_c = db_h.data.speed_arr;
    end
    
    flag = 1 - flag;
    disp('The path changed to speed/direction');
    
    % Press the button twice to re-render the colors
    trace_Callback(handles.trace_button, 777, handles);
    trace_Callback(handles.trace_button, 777, handles);
end

% ============= Helper functions ==========================

function [data] = bin_traj2d(x, y, bins, bg)
% BIN_TRAJ2D a function that receives a Nx2 vector of locations and creates heat-map.
% The space is binned to squares, color of which indicates the relative abundance.
% 
% Input:
%     x - Nx1 array of X locations
%     y - Nx1 array of Y locations
%     bins - How many bins to create
%     bg - Image of the RIFF, to be used as the background
%     
% Output:
%     data - Nx3 array of [X , Y, C] locations
% 
% Usage:
%     >> [data] = bin_traj2d(handles.state.rat1(:, 1), handles.state.rat1(:, 2), 50, handles.bg);

    if(nargin < 3 || bins<4 || isempty(x) || isempty(y))
        disp('=== Recieved wrong args. Exiting');
    end
    if(x ~= isa(x, 'double'))
        x = double(x);
        y = double(y);
    end
    bin = max(max(x), max(y)) / bins;  % Find max value 
    x_binned = round(floor(x / bin) * bin + bin/2);
    y_binned = round(floor(y / bin) * bin + bin/2);
    linearInd = sub2ind(fliplr(size(bg)), x_binned, y_binned);
    linearInd_u = unique(linearInd);
    counts = histc(linearInd, linearInd_u);
    c_norm = counts / sum(counts);
    [xx, yy]=ind2sub(fliplr(size(bg)), linearInd_u);
    data = [xx yy c_norm];
end

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

function [NA_data, t_lims, ind_lims] = read_NA_raw_data(cam_t, t_bound_sec)
    % Function read_NA_raw_data read the relevant raw_??_??.mat that holds NA around the input 
    % cam_t time points, and preprocesses it similarly to the input to the KS.
    % The data is being read from the RAM, so it is fast.
    % 
    % Inputs:
    %     cam_t - (scalar) - SNR time of a current point (data is to be extracted around it)
    %     t_bound_sec - (scalar) - positive number representing seconds, defining time window
    %     [cam_t - ??, cam_t + ?]
    % 
    % Outputs:
    %     NA_data - (Nx16) - Raw data with removed noise
    %     t_lims - limit times of the segment
    %     ind_lims - index limits of the segmet,starting from sample 1 of the experiment
    
    global db_h
    NA_data = db_h.data.NA_big;
    start_t = cam_t - t_bound_sec;
    end_t = cam_t + t_bound_sec;
    t_lims = [start_t end_t];
    
    [ind_lims] = convert_SNR_t_2_ind_NA_filestarts(t_lims, []);
    NA_data = NA_data(:, ind_lims(1):ind_lims(2))';
end

%========================   CreateFunc (Junk)   ===========================

function slider_CreateFcn(hObject, ~, ~)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
end

function thr_text_CreateFcn(hObject, ~, ~)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
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

function [pos, ti] = colorbarpos(hcbar)
    % 1 point is 0.3528 mm
    
    pos = hcbar.Position;
    ti = [0,0,0,0];
    
    if ~isempty (strfind (hcbar.Location, 'outside'))
        if strcmp (hcbar.AxisLocation, 'out')
            
            tlabels = hcbar.TickLabels;
            
            fsize = hcbar.FontSize;
            
            switch hcbar.Location
                
                case 'northoutside'
                    
                    % make exta space a little more than the font size/height
                    ticklablespace_cm = 1.1 * (0.3528/10) * fsize;
                    
                    ti(4) = ti(4) + ticklablespace_cm;
                    
                case 'eastoutside'
                    
                    maxlabellen = max ( cellfun (@numel, tlabels, 'UniformOutput', true) );
            
                    % 0.62 factor is arbitrary and added because we don't
                    % know the width of every character in the label, the
                    % fsize refers to the height of the font
                    ticklablespace_cm = (0.3528/10) * fsize * maxlabellen * 0.62;
                    ti(3) = ti(3) + ticklablespace_cm;
                    
                case 'southoutside'
                    
                    % make exta space a little more than the font size/height
                    ticklablespace_cm = 1.1 * (0.3528/10) * fsize;
                    ti(2) = ti(2) + ticklablespace_cm;
                    
                case 'westoutside'
                    
                    maxlabellen = max ( cellfun (@numel, tlabels, 'UniformOutput', true) );
            
                    % 0.62 factor is arbitrary and added because we don't
                    % know the width of every character in the label, the
                    % fsize refers to the height of the font
                    ticklablespace_cm = (0.3528/10) * fsize * maxlabellen * 0.62;
                    ti(1) = ti(1) + ticklablespace_cm;
                    
            end
            
        end
        
    end
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

function plot_beh_arrs(env1, env2, env3, ts)
    figure();
    plot(env1, env1*0, '.');
    hold on;
    plot(env2, env2*0+1, '.');
    plot(env3, env3*0+2, '.');
    ylim([-5 8]);
    legend({'env1', 'env2', 'env3'});
    if nargin == 4
        plot(ts, ts*0+1.5, 'k.');
        legend({'env1', 'env2', 'env3', 'SNR'});
    end
    
end

function analyze_LSTM_results(~, ~, ~)
    global db_h
    
    start_inds 		= db_h.data.LSTM_data.start_inds;
    lstm_traces 	= db_h.data.LSTM_data.lstm_traces;
    X_test 			= db_h.data.LSTM_data.X_test;
    Y_test 			= db_h.data.LSTM_data.Y_test;
    test_acc 		= db_h.data.LSTM_data.test_acc;
    feature_means 	= db_h.data.LSTM_data.feature_means;
    feature_maxs 	= db_h.data.LSTM_data.feature_maxs;
    
    Y_hat = lstm_traces(:, end) > 0.5;
    correct_arr = (Y_hat == Y_test);
    lstm_last = lstm_traces(:, end);
    
    % === Plot the accuracy for each LSTM output along the trial ===
    
    acc_all_ind_lstm = mean((lstm_traces > 0.5) == Y_test);
    h_fig = figure();
    h_ax = axes(h_fig);
    plot(h_ax, acc_all_ind_lstm, '.');
    xlabel(h_ax, 'Training trial length (0.1 sec / sample)'); 
    ylabel(h_ax, 'Accuracy');
    title(h_ax, 'Accuracy at different LSTM indices (last used as predictor)');
    
    % === Compare histograms of LSTM values for correct and incorrect guesses
    
    h_fig = figure();
    h_ax = axes(h_fig);
    histogram(h_ax, lstm_last(correct_arr), 20, 'Normalization', ...
              'probability', 'BinLimits', [0 1]);
    hold(h_ax, 'on');
    histogram(h_ax, lstm_last(~correct_arr), 20, 'Normalization', ...
              'probability', 'BinLimits', [0 1]);
    legend(h_ax, {'Correct predictions', 'Wrong predictions'})
    title(h_ax, 'Last LSTM values divided into correct guesses and failures');
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

function [out_arr] = convert_SNR_t_2_ind_NA_filestarts(snr_ts, inds_arr)
    % Function convert_SNR_t_2_ind_NA_filestarts interplolates one type of data into the other,
    % given the known boundary times and indices of the NA_??_??.mat files.
    % 
    % The challenge is that the monolythic .bin file with the NA is not linear in time, there are gaps 
    % between the passive and active sessions.
    % 
    % Inputs:
    %     snr_ts - (Nx1 matrix, or []) - Array of events in SNR times, that should be converted to inds.
    %     inds_arr - (Nx1 matrix, or []) - Array of events in inds, that should be converted to SNR_t
    % 
    % Outputs:
    %     output_arr - (Nx1 matrix) - An array in the corresponding format.
    
    global db_h
    dt_t_starts = db_h.data.NA_raw_db.fs_arr;  % Array of SNR_t starts of the raw_??_??.mat files
    dt_ind_starts = db_h.data.NA_raw_db.file_nums;
    
    SAMPLE_RATE = 32000;
    SAMPLES_DT2 = 2^18;
    
    out_arr = [];
    if isempty(snr_ts) && isempty(inds_arr)  % Abort if no input data is provided
        return;
    end

    dt_t_ends = dt_t_starts + SAMPLES_DT2/SAMPLE_RATE;             % Computing the TD2 end times
    dt_t_strt_end = sort([dt_t_starts; dt_t_ends]);      % Creates single array of timestamps for start+stop
    
    n_dt2_files = length(dt_ind_starts);
    dt_strt_inds = (0:(n_dt2_files-1))*SAMPLES_DT2 + 1;   % Indices of DT2 file starts
    dt_end_inds = dt_strt_inds + SAMPLES_DT2 - 1;    % Marking the indeces of DT2 file ends
    dt_srtr_end_inds = sort([dt_strt_inds dt_end_inds]);
    
    if ~isempty(snr_ts)  % Convert ts to inds
        out_arr = interp1(dt_t_strt_end, dt_srtr_end_inds, double(snr_ts), 'linear', 'extrap');
    elseif ~isempty(inds_arr)  % Convert inds to ts
        out_arr = interp1(dt_srtr_end_inds, dt_t_strt_end, double(inds_arr), 'linear', 'extrap');
    end
    out_arr = round(out_arr);
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
    h_rect = rectangle(h_ax, 'Position', [x, y, 80, 52], ...
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
    h_rect_loc = rectangle(h_ax, 'Position', [x, y, 80, 16], ...
                             'FaceColor', [1 1 1]*0.94, ...
                             'EdgeColor', 'w', ...
                              'Curvature', 0.23);
    h_text3 = text(h_ax, x+7, y+8, "Area: ", ...
                                'FontSize', 12, 'FontWeight', 'bold');
                            
    sound_shift_down = 25;
    h_rect_sound = rectangle(h_ax, 'Position', [x, y+sound_shift_down, 80, 32], ...
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

%========================   custom (debug) function   ===========================

function Custom_button_Callback(hObject, ~, handles)
    global db_h
    if 0
        msg = inputdlg('enter_name');
        f_name = "R6_" + db_h.data.mdata.exp_date + "_" + msg;
        print(f_name + ".eps", '-depsc', '-painters');
        print(f_name + ".png", '-dpng', '-r300');
        disp("image files saved as: " + f_name);
    end
    if 0
        dx = [0; diff(db_h.data.loc_arr(:, 1))];
        dy = [0; diff(db_h.data.loc_arr(:, 2))];
        
%         dx = [0; db_h.data.loc_arr(3:end, 1) - db_h.data.loc_arr(1:end-2, 1); 0];
%         dy = [0; db_h.data.loc_arr(3:end, 2) - db_h.data.loc_arr(1:end-2, 2); 0];
        
        [tr_direc, tr_rho] = cart2pol(dx, dy);
        tr_rho = smooth(tr_rho, 3);
        
        db_h.data.dx = dx;
        db_h.data.dy = dy;
        db_h.data.tr_direc = tr_direc;
        db_h.data.tr_rho = tr_rho;
        
        handles.message_text.Visible = 'on';
        msgbox('The allocentric stats were added to db_h.data');
    end
    
    if(0)
        handles.data.image_arr = (handles.data.image_arr(1:2:end, 1:2:end, :) + ...
                             handles.data.image_arr(2:2:end, 1:2:end, :) + ...
                             handles.data.image_arr(1:2:end, 2:2:end, :) + ...
                             handles.data.image_arr(2:2:end, 2:2:end, :))/4;
         guidata(hObject, handles);
    end
    if(0)
        init_GUI(handles);
    end
    if (0)
        disp('done!');
        stats_button_Callback([], [], handles);
    end
    if(0)
        timer_loc = 0;
    end
    if 0
        1;
        t_init = db_h.data.maestro_states.start_t(db_h.data.maestro_states.type == 'center');
        types = db_h.data.maestro_states.type;
        times = db_h.data.maestro_states.start_t;
        t_ends = t_init*0;
        counter = 1;
        for i = 1:(length(types)-1)
            if (types(i) == 'NPWait') && (types(i+1) == 'wait')
                t_ends(counter) = times(i+1);
                counter = counter + 1;
            end
        end
    end
    
    if 0
        analyze_LSTM_results();
    end
    
    if 0
        db_h.data.curr_traj_c = db_h.data.rat_body_turns;
    end
end
