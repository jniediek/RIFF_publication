
function varargout = RatTracker_fast(varargin)
    % RatTracker_fast MATLAB code for RatTracker_fast.fig
    %      RatTracker_fast, by itself, creates a new RatTracker_fast or raises the existing
    %      singleton*.
    %
    %      H = RatTracker_fast returns the handle to a new RatTracker_fast or the handle to
    %      the existing singleton*.
    %
    %      RatTracker_fast('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in RatTracker_fast.M with the given input arguments.
    %
    %      RatTracker_fast('Property','Value',...) creates a new RatTracker_fast or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before RatTracker_fast_OpeningFcn gets called.  An
    %      unrecognised property name or invalid value makes property application
    %      stop.  All inputs are passed to RatTracker_fast_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help RatTracker_fast

    % Last Modified by GUIDE v2.5 13-Jun-2019 12:27:43

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @RatTracker_fast_OpeningFcn, ...
                       'gui_OutputFcn',  @RatTracker_fast_OutputFcn, ...
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

%=============      GUI main functions      =============

function RatTracker_fast_OpeningFcn(hObject, ~, handles, varargin)
    
	% Camera configuration
    imaqreset;
    cam = videoinput('tisimaq_r2013_64', 1, 'Y800 (1280x960)');
    src = getselectedsource(cam);
    cam.triggerrepeat = 0;
    src.Strobe = 'Disable';
    src.StrobeMode = 'exposure';
    src.Trigger = 'Disable';
    if(src.Exposure > 0.025)
        src.Exposure = 0.005;
    end
    src.FrameRate = '30.00'; 
    src.GainAuto = 'off';
    cam.FramesPerTrigger = 1;

    % Load previos session preferences
    last_session_h = matfile('C:\RIFF_code\session_db.mat'); % data is stored in binned indeces
    last_session_h.Properties.Writable = true; % Make the file be rewritable.
    handles.last_session_h = last_session_h;
    frame_binned = last_session_h.bg_frame;
    
    handles.filming = struct('is_live', false, 'is_recording', false, 'h_maestro', 0, 'is_linked', false, ...
                             'binning', 2, 'min_size_thr', 50, 'max_size_thr', 1500, 'cam', cam, ...
                             'src', src, 'mult', 1, 'show_max', false, 'clear_bin', [1, 1],...
                             'is_clipping', false, 'cam_res', size(frame_binned).*2, 'helper', 'start', ...
                             'slice_colors', ['g', 'r', 'y', 'cyan']);
                         
    axis(handles.picture_area);
    handles.plot = imshow(frame_binned, 'Parent', handles.picture_area);  
    
    hold on;
    % Draw walls and ports
    h_geo = zeros(1, 4);
    if(last_session_h.num_of_rats > 1) % If previous session utilized few rats, draw dividers
        [h_geo] = draw_walls_ports(h_geo, last_session_h, handles.picture_area);
        set(handles.rats_num_button, 'String', '<html>Change to<br>single rat');
    end
    handles.filming.h_geo = h_geo;
    handles.data_creation.led_loc = [-1 -1];
    handles.output = hObject;
    disp('=====     GUI loaded    =====');
    guidata(hObject, handles);
end

function varargout = RatTracker_fast_OutputFcn(~, ~, handles)

    varargout{1} = handles.output;
end

function handles = init_DB(hObject, handles)
   
%%% Singleton call function. Initilizes the session id to a unique value,
%   and a new dir is created (only not existing yet)

    if(exist('handles.data_creation.t'))   % If database already initialized, to none.
        return;
    end
    
    % create new folder in C:\Logging_data
    t = clock;
    dir_name = [num2str(t(3), '%02d') '-' num2str(t(2), '%02d') '-' num2str(t(1)) 'T']; % The filder name is padded with leading 0
    [~, ~, ~] =  mkdir('D:\logging_data', dir_name);    % Function call does nothing if folder exists
    handles.data_creation.dir_name = ['D:\logging_data\' dir_name '\'];
    session_serial = 1;
    while true
        if(~exist([handles.data_creation.dir_name 'RIFF_s' num2str(session_serial) '.txt'], 'file'))
            break;
        end
        session_serial = session_serial + 1;
    end
    handles.data_creation.session_serial = session_serial;
    handles.data_creation.file_name      = ['RIFF_s' num2str(session_serial)];
    handles.data_creation.file_name_stat = 'RIFF';
    handles.data_creation.txt_handle     = 0;
    
    guidata(hObject, handles);
end

function [name] = get_unique_name(curr_name, extension)
% Function GET_UNIQUE_NAME recieves desired name of a file and the extension, and checks if the name is
% unique in the directory. If not, it appends a serial number to the end of the name.
% Parameters:
%     curr_name - The name of the file
%     extension - file type
%     
% Usage example:
%     [name] = get_unique_name('my_file', '.tif')
%     [name] = get_unique_name([dir 'my_file'], '.tif') % where dir = 'C:\logging_files\'
    if(isempty(extension) || ~strcmp(extension(1), '.') || isempty(curr_name))
        name = '';
        disp(' ==== Wrong usage of the 	`get_unique_name()` function. Extension must be of `.tif` form and the name non-empty =======');
        return;
    end
    if(~exist([curr_name extension], 'file'))
        name = [curr_name extension];
        return;
    end
    id = 2;
    while true
        if(~exist([curr_name '_' num2str(id) extension], 'file'))
            break;
        end
        id = id + 1;
    end
    name = [curr_name '_' num2str(id) extension];
end

function [h_geo] = draw_walls_ports(h_geo, last_s_h, pic_h)

% DRAW_WALLS_PORTS helper function that draws the geometry of the RIFF.
%
% Usage:
%     >> handles.filming.h_geo = DRAW_WALLS_PORTS (handles.filming.h_geo, handles.last_s_h);
%     >> guidata(hObject, handles); % update the handles
% 
% Inputs:
%     h_geo - array of the 4 handles: 3 for the 3 walls and one for all ports and center.
%     last_s_h - handler to file with fields {bg_frame, c_point, num_of_rats, ports, r, slices}
%     
% Output:
%     h_geo - same array of the 4 handles.

    if(any(h_geo))
        for i = 1:length(h_geo)
            delete(h_geo(i));
        end
    end
    h_geo(1) = plot([last_s_h.ports(:, 1); last_s_h.c_point(1, 1)],...
                    [last_s_h.ports(:, 2); last_s_h.c_point(1, 2)],...
                    'r*', 'LineWidth', 3, 'Parent', pic_h);
    colors = ['g', 'r', 'y'];
    slices = last_s_h.slices;
    for i = 1:length(slices)
        h_geo(1 + i) = plot(slices{i}.pts(:, 1), slices{i}.pts(:, 2),...
                            'LineWidth', 3, 'Color', colors(i), 'Parent', pic_h);
    end
end

%=============      Live picture and Record operations       =============

function live_button_Callback(hObject, ~, handles)

    if(handles.filming.is_live)  % If already in live mode - escape it!
        handles.filming.is_live = false;
        guidata(hObject, handles); % pushing 'is_live'
        return;
    end
    
    bin = handles.filming.binning;
    handles.filming.is_live = true;
    guidata(hObject, handles);
    enable_buttons(handles, 'Live', 'on');
    
    triggerconfig(handles.filming.cam, 'manual'); % In this mode 'getsnapshot()' is faster
    
    set(hObject, 'String', '<html>Stop<br>Live');
    set(hObject, 'BackGroundColor', [0.757 0.867 0.776]);
    set(handles.update_text, 'String', '--- Real time(not rec.) ---');
    set(handles.exp_val, 'String', num2str(handles.filming.src.Exposure));
    set(handles.mult_val, 'String', num2str(handles.filming.mult));
    rat_pixels = plot(handles.picture_area, 1, 1, 'g.', 'MarkerSize', 5);
    
    guidata(hObject, handles);  % pushing 'is_live'
    while(handles.filming.is_live)
        frame = getsnapshot(handles.filming.cam);   % This function flushes the EDT (Event Dispatch Thread)
        frame = frame(handles.filming.clear_bin(1):2:end, handles.filming.clear_bin(2):2:end);
        handles = guidata(hObject);
        if(handles.filming.is_live == 0)
            break;
        end
%         guidata(hObject, handles);
        set(handles.plot, 'CData', frame*handles.filming.mult);
        %  ======== show max ========
        if(handles.filming.show_max)
            burnt = (frame == (2.^8-1));
            ind = find(burnt);
            [x, y] = ind2sub(size(frame), ind);
            for i = 1:5 % Blinknig red
                h_burnt = plot(handles.picture_area, y, x, '.r', 'MarkerSize', 7);
                pause(0.1);
                delete(h_burnt);
                pause(0.2);
            end
            handles.filming.show_max = false;
            guidata(hObject, handles);
        end
        %  =========================
    end
    
    enable_buttons(handles, 'Live', 'off');
    set(hObject, 'String', '<html>Start<br>Live');
    set(hObject, 'BackGroundColor',[0.94, 0.94, 0.94]);
    set(handles.update_text, 'String', '--- Ready to record ---');
    delete(rat_pixels);
    set(handles.plot, 'CData', handles.last_session_h.bg_frame*handles.filming.mult);
    %%% imwrite(frame, 'auto_bg.tif');
    triggerconfig(handles.filming.cam, 'immediate');
end

function startRec_Callback(hObject, ~, handles)    
    if(handles.filming.is_recording)  % If already in live mode and not locked - escape it!
        
        handles.filming.is_recording = false;
        guidata(hObject, handles);
        return;
    end
        
    handles = init_DB(hObject, handles); % GuiData is inside this call
    
%     handles = helper('rec', handles); % change button color to black
    set(hObject, 'String', '<html>Stop<br>Rec');
    set(hObject, 'BackGroundColor', [0.902 0.553 0.208]);
    set(handles.update_text, 'String','--- Recording ---');
    enable_buttons(handles, 'Rec', 'on');
    
    handles.filming.is_recording = true;   % Locked state
    guidata(hObject, handles); % push 'is_recording' and 'helper'
    
    cam             = handles.filming.cam;
    colors          = handles.filming.slice_colors;
    min_size_thr    = handles.filming.min_size_thr;
    max_size_thr    = handles.filming.max_size_thr;
    file_name       = handles.data_creation.file_name;
    led_loc         = handles.data_creation.led_loc;
    bg              = handles.last_session_h.bg_frame;
    mask            = handles.last_session_h.mask;
    c_point         = handles.last_session_h.c_point;
    radius          = handles.last_session_h.r;
    slices          = handles.last_session_h.slices;
    num_of_rats     = handles.last_session_h.num_of_rats;
    
    imwrite(bg, [handles.data_creation.dir_name 'bg_s' num2str(handles.data_creation.session_serial) '.tif']); % Create a new bg image in the logging dir, as a reference image
    dropped_frames   = 0;
    prev_driver_time = 0;
    rat_handlers = cell(1, num_of_rats);
    for i = 1:num_of_rats
        rat_handlers{i} = RatDataHandler(file_name, i, handles.data_creation.dir_name,...
                                         handles.picture_area, colors(i), led_loc);
    end
    
    full_txt_name = [file_name '.txt'];
    txt_handle = fopen([handles.data_creation.dir_name file_name '.txt'], 'w');
    set(handles.tiff_loc_txt, 'String', ['TIFF in:  ' handles.data_creation.dir_name file_name]); %txt_loc_txt : TXT in: ----
    set(handles.txt_loc_txt,  'String', ['TXT in:   ' handles.data_creation.dir_name full_txt_name]);
    handles.data_creation.txt_handle = txt_handle;
    guidata(hObject, handles);
    str = [];
    for i =1:num_of_rats
        str = [str 'rat' num2str(i) 'X,rat' num2str(i) 'Y,'];
    end
    fprintf(txt_handle, '%s,%s,%s,%s,%s     Logged on:  %s\r\n', 'Frame_ID', 'Driver_clock',...
            '# in stack', '|Stack|', str(1:end-1), datestr(clock));
    
    flushdata(cam);
    cam.FramesPerTrigger = 1;
    cam.triggerrepeat = Inf;
    if(0)    % DEBUG remove of Exp. run
        cam.triggerrepeat = 25*5;
    end
    
    tic;
	start_exp_time = toc;  % Used for the first 5 min of live-image rendering
    realtime_image_state = 0;
    start(cam);
    pause(0.2); % first 3-5 frames will have no LED && SNR will see no strobe -> it is the start of the sync.
    set_strobe('on', handles);
    warning('off', 'imaq:peekdata:tooManyFramesRequested'); % suppress peekdata warning printing
    
	while handles.filming.is_recording
        
        [frames, t, ~] = getdata(cam, cam.FramesAvailable, 'uint8', 'numeric');
        if(isempty(t) && handles.filming.is_recording)  % No new data is acquired
            set(handles.latency_text, 'String', 'Idle');
            drawnow;
            handles = guidata(hObject);
            continue;
        end
        if(length(t) > 100)
            disp('==== Frame stack overflow!!! Recording is stopped ==== ');
            handles.filming.is_recording = false;
            guidata(hObject, handles);
            %%% TODO: Write better handling of the stack overflow
        end
        
        % check dropped frames
        cur_dropped = sum(round(diff([prev_driver_time t'])/0.033)-1);
        dropped_frames = dropped_frames + max(cur_dropped, 0);
        prev_driver_time = t(end);
        set(handles.latency_text, 'String', ['# of images to proccess:  ' num2str(length(t))]);
        
        for j = 1:length(t)   % For each frame that are acquired in this bulk (most likely 1)

            frame = frames(:, :, : , j);
            frame_binned = frame(handles.filming.clear_bin(1):2:end, handles.filming.clear_bin(2):2:end);
            
            %   ========== Image processing  =============
            
            foundRatArr = zeros(1, num_of_rats);
            m = mean(mean(frame));
            if((m < 5) || (m > 200)) % The frame is too bright (main light was set on) or too dark. Skip data analysis
                areas_sorted = -1; % TODO rewrite in more generic and robust way
            else
                dI           = frame_binned - bg;
                dI           = dI .* mask;
                dI_thr_noise = dI > 2^5;
                dI_thr       = filter2(fspecial('average', 3), dI_thr_noise) > 0.75;
                track        = regionprops(dI_thr, 'Centroid', 'Area');
                if(num_of_rats == 1)    % Single rat mode - find a biggest blob
                    rat_handlers{1}.loc = [-1 -1];
                    if(size(track, 1) ~=0 ) % Only if No. of blobs > 0
                        [blob_ar, ind] = max([track.Area]);
                        if((blob_ar > (min_size_thr)) && (blob_ar < (max_size_thr)))   % Only if the biggest blob is above reasonable THR, binned to 2X2
                            rat_handlers{1}.loc = ceil(track(ind).Centroid);
                        end
                        areas_sorted = track.Area;  % 'Area sorted' is later shown in GUI
                    else  % if there are no blobs to show
                        areas_sorted = -1;  % Show arbitrary value
                    end
                    
                else % Multi rat mode - find few biggest blobs
                    [areas_sorted, t_id] = sort([track.Area], 'descend');
                    for i = 1:length(t_id)
                        blob_ar = areas_sorted(i);
                        curr_point = track(t_id(i)).Centroid;
                        isRightSize = (blob_ar > (min_size_thr)) && (blob_ar < (max_size_thr));
                        if((sum(foundRatArr == 0) == 0) || ~isRightSize)     % If a blob was found in each area don't look at the rest
                            break;
                        end
                        [slice_id] = find_loc_of_point(curr_point, c_point, radius, slices);
                         if((slice_id > 0) && ~foundRatArr(slice_id)) % If point is associated to a slice (not outside of all), and if the slice is not yet populated, put in the found blob
                             rat_handlers{slice_id}.loc = ceil(curr_point);
                             foundRatArr(slice_id)      = 1;
                         end
                    end
                end
            end
            
            %   ========== Save rat locations in the .txt file ===================
            
            data_str = [];  % Location that will be stored as string to be printed in a file
            locs_arr = zeros(1, num_of_rats*2);% Location as array that will be sent to Maestro
            for i =1:num_of_rats
                data_str = [data_str num2str(rat_handlers{i}.loc(1)) ',' num2str(rat_handlers{i}.loc(2)) ','];
                locs_arr(i*2-1) = rat_handlers{i}.loc(1);    % By convention, X should be sent with negative sign.
                locs_arr(i*2)   = rat_handlers{i}.loc(2);
            end
            fprintf(txt_handle, '%i,%1.4f,%i,%i,%s\r\n', rat_handlers{1}.frame_ind, t(j), j, length(t), data_str(1:end-1)); % (end-1) removes last comma
            
             %   ========== Send information to maestro ===================
            
            if(handles.filming.is_linked) % Try to send over TCP/IP only if handshake was peformed
                fwrite(handles.filming.h_maestro, typecast(int16(locs_arr), 'int32'), 'long');
            end
            %   ========== Save frame to .tiff ===================

            for i = 1:num_of_rats
                rat_handlers{i}.append_image(frame);
            end
            
            %   ===========================================
            
            drawnow;
            handles = guidata(hObject);
            
        end  % End from frame stack loop
        
        % === Plot updated image to the screen ===
        %Fix - 160619 - AlexKaz - The drawnow took ~30ms due to graphic reploting
        if toc() - start_exp_time < 60*5  % First 5 minutes the realtime image is updated.
            set(handles.plot, 'CData', frame_binned*handles.filming.mult);
        elseif realtime_image_state == 0
            realtime_image_state = 1;  % Set to value that does nothing
%             h_text = text(200, 200, '--- Recording in process... --- ', 'FontSize', 30, ...
%                           'Color', 'g', 'Parent', handles.picture_area);
        end
%         loc = rat_handlers{1}.loc;
%         set(handles.rat_rect_h, 'CData', handles.rat_rect(1:10:end, 1:10:end), 'XData', loc(1) + [-49 50], ...
%                                 'YData', loc(2) + [-49 50]);  % Didn't work - CData update makes drawnow() block for 30ms
        % === Update GUI text windows ===
        set(handles.time_text, 'String', ['Time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS')...
            '  |   Frames: ' num2str(rat_handlers{1}.frame_ind)]);
        set(handles.tifs_text, 'String', ['collages: '...
            num2str(floor(rat_handlers{1}.frame_ind/rat_handlers{1}.collage_total))...
            '  |  .tiff files: ' num2str(rat_handlers{1}.movie_serial)]);
        if(rat_handlers{1}.loc(1) ~= -2)
            set(handles.blob_text, 'String', num2str(areas_sorted(1)));
        else
            set(handles.blob_text, 'String', '-1');
        end
        
        if realtime_image_state == 0
            for i = 1:num_of_rats
                rat_handlers{i}.replot_rat(handles.picture_area);
            end
        end
        guidata(hObject, handles);  % flush changes to 'handles'
        drawnow;                    % Perform other callbacks that may change 'handles'
        handles = guidata(hObject); % Get updated 'handles'
	end
    
    % =================  Closing operations =========================
    
    % Stop camera and close files
    set_strobe('off', handles);
    stop(handles.filming.cam);
    flushdata(handles.filming.cam);
    for i = 1:num_of_rats
        rat_handlers{i}.close_tiff(); % Deletes rat location, close .tif file and erases the object
    end
    fclose(txt_handle);
       
    % Update GUI panel
    set(hObject, 'String', '<html>Start<br>Rec');
    set(hObject, 'BackGroundColor', [0.94, 0.94, 0.94]);
    set(handles.update_text, 'String', '--- Ready to record ---');
    enable_buttons(handles, 'Rec', 'off');
    
    % Update session name + ID
    session = handles.data_creation.session_serial;
    session = session + 1;
    handles.data_creation.file_name = [handles.data_creation.file_name_stat '_s' num2str(session)];
    handles.data_creation.session_serial = session;
    
    guidata(hObject, handles);
end

%=============      Update graphics       =============

function handles = helper(func_name, handles)

    % Function that guides the user through a right button sequence for his
    % first movie acquisition. Will now work if recording was stopped and
    % resumed (session > 1).
    % The sequence:   LIVE -> BG UPDATE -> MARK RAT -> MARK LED  ->  RECORD
    if(handles.filming.helper == false)  
        return;
    end
    if(strcmp(func_name, 'live'))
        set(handles.live_button, 'ForegroundColor', 'black');
        set(handles.rat_mark_button, 'ForegroundColor', 'red');
%     elseif(strcmp(func_name, 'bg'))
%         set(handles.bg_button, 'ForegroundColor', 'black');
%         set(handles.rat_mark_button, 'ForegroundColor', 'red'); % maybe no rat in bg
    elseif(strcmp(func_name, 'rat'))
        set(handles.rat_mark_button, 'ForegroundColor', 'black');
        set(handles.led_button, 'ForegroundColor', 'red');
	elseif(strcmp(func_name, 'led'))
        set(handles.led_button, 'ForegroundColor', 'black');% maybe no rat in bg
        set(handles.startRec_button, 'ForegroundColor', 'red');
    else
        set(handles.startRec_button, 'ForegroundColor', 'black');
        handles.filming.helper = false;
    end
end

function enable_buttons(handles, button, state)
    % Function that enables (disables) groups of buttons as a function of
    % the state if the GUI.
    %
    % Parameters:
    %   button - {'Live', 'Rec', 'Clip'}
    %   state - {'on', 'off'}
    
    if(strcmp(state, 'on')) % Some function went active, disable unrelevant buttons
        tmp = get(handles.panel_1, 'Children');
        set(tmp, 'Enable', 'Off');
        tmp = get(handles.panel_2, 'Children');
        set(tmp, 'Enable', 'Off');
        tmp = get(handles.panel_5, 'Children');
        set(tmp, 'Enable', 'Off');
        switch button
            case 'Live'
                tmp = get(handles.panel_3, 'Children');
                set(tmp, 'Enable', 'On');
                tmp = get(handles.panel_4, 'Children');
                set(tmp, 'Enable', 'On');
                set(handles.live_button, 'Enable', 'on');
            case 'Rec'
                tmp = get(handles.panel_3, 'Children');
                set(tmp, 'Enable', 'Off');
                tmp = get(handles.panel_4, 'Children');
                set(tmp, 'Enable', 'Off');
                set(handles.startRec_button, 'Enable', 'on');
            case 'Clip'
                tmp = get(handles.panel_3, 'Children');
                set(tmp, 'Enable', 'Off');
                tmp = get(handles.panel_4, 'Children');
                set(tmp, 'Enable', 'Off');
                set(handles.clip_button, 'Enable', 'on');
        end

    else % Return general functionality to the GUI, reactive all buttons
        tmp = get(handles.panel_1, 'Children');
        set(tmp, 'Enable', 'On');
        tmp = get(handles.panel_2, 'Children');
        set(tmp, 'Enable', 'On');
        tmp = get(handles.panel_3, 'Children');
        set(tmp, 'Enable', 'Off');
        tmp = get(handles.panel_4, 'Children');
        set(tmp, 'Enable', 'Off');
        tmp = get(handles.panel_5, 'Children');
        set(tmp, 'Enable', 'On');
    end
    
    set(handles.open_bg_button, 'Enable', 'on');
end

function exp_Callback(hObject, ~, handles)
    % Units are in seconds. The function is fail-safe such that Exposure is
    % strongly bounded to (0, 0.025). Exposure higher than 0.025 may create
    % frame drops.
    small = 0.0001;
    big = 0.001;

    tag = get(hObject,'Tag');
    val = handles.filming.src.Exposure;
    if(strcmp(tag,'exp_up'))
        if(val + small < (0.025))   % Allow only 
            val = val + small;
        end
        
    elseif  (strcmp(tag,'exp_up_up'))
        if(val + big < (0.025))
            val = val + big;
        end
    elseif  (strcmp(tag,'exp_down_down'))
        if(val - big > 0)
            val = val - big;
        end
    else % exp_down
        if(val - small > 0)
            val = val - small;
        end
    end
    handles.filming.src.Exposure = val;
    set(handles.exp_val, 'String', num2str(val));
end

function mult_Callback(hObject, ~, handles)

    tag = get(hObject,'Tag');
    val = handles.filming.mult;
    if(strcmp(tag,'mult_up'))
    	val = val + 0.2;
    else % exp_down
        if(val - 0.2 > 0)
            val = val - 0.2;
        end
    end
    
    set(handles.mult_val, 'String', num2str(val));
    handles.filming.mult = val;
    guidata(hObject, handles);
end

function max_button_Callback(hObject, ~, handles)

    handles.filming.show_max = true;
    guidata(hObject, handles);
end

function snap_button_Callback(hObject, ~, handles)

    handles = init_DB(hObject, handles); % Singelton call, creates the directory and inits counters
    name = get(handles.snap_name_text, 'String');
    [full_tiff_name] = get_unique_name([handles.data_creation.dir_name name], '.tif');
    frame = getsnapshot(handles.filming.cam);
    imwrite(frame, full_tiff_name);
    set(handles.update_text, 'String', 'Snapshot taken');
    set(handles.tiff_loc_txt, 'String', full_tiff_name);
    disp(['Snapshot saved as: ' full_tiff_name]);
end

function clip_button_Callback(hObject, ~, handles)

    if(handles.filming.is_clipping)  % If already in clipping mode - escape it!
        
        handles.filming.is_clipping = false;
        set_strobe('off', handles);
        guidata(hObject, handles);
        return;
    end
    handles = init_DB(hObject, handles); % GuiData is inside this call. Singelton call
    handles.filming.is_clipping = true; % 
    guidata(hObject, handles); % push 'is_clipping'
    
    set(hObject, 'String', '<html>Stop<br>clip!');
    set(hObject, 'BackGroundColor', [0.902 0.553 0.208]);
    set(handles.update_text, 'String','--- Clipping ---');
    enable_buttons(handles, 'Clip', 'on');
    set_strobe('on', handles);
        
    % ==== Binned saving option =========
    bin = 2;
    % ===================================
    
    cam = handles.filming.cam;
    tagstruct = struct();
    tagstruct.ImageLength = handles.filming.cam_res(1)/bin;
    tagstruct.ImageWidth = handles.filming.cam_res(2)/bin;
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 8;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    file_name = get(handles.clip_name_text, 'String');

    movie_serial = 1;
    frame_ind   = 1;
    tiff_ind    = 1;
    max_tiff_len = 1500;
    [full_tiff_name] = get_unique_name([handles.data_creation.dir_name file_name], '.tif');
    tiff_handle = Tiff(full_tiff_name, 'w');
    disp(['=====     Creating new clip: ' full_tiff_name '     =====']);
    set(handles.tiff_loc_txt, 'String', full_tiff_name);
    guidata(hObject, handles);
    
    flushdata(cam);
    cam.FramesPerTrigger = 1;
    set(cam.Source, 'FrameRate', ' 3.75');
    
%     cam.triggerrepeat = 100; % DEBUG
    cam.triggerrepeat = Inf;
    tic;
    start(cam);
    warning('off', 'imaq:peekdata:tooManyFramesRequested'); % suppress peekdata warning printing
    while handles.filming.is_clipping
        
        [frames, t, ~] = getdata(cam, cam.FramesAvailable, 'uint8', 'numeric');
        handles = guidata(hObject);
        if(handles.filming.is_clipping == 0)
            stop(cam);
            break;
        end
        if(isempty(t) && handles.filming.is_clipping)  % No new data is acquired
            set(handles.latency_text, 'String', 'Idle');
            drawnow;
            handles = guidata(hObject);
            continue;
        end
        set(handles.latency_text, 'String', ['# of images to proccess:  ' num2str(length(t))]);
        for j = 1:length(t)   % For each frame that are acquired in this bulk (most likely 1)

            frame = frames(:, :, : , j);
            if(tiff_ind ~= 1)   % Add new DIR to tiff, only for frames > 1
                tiff_handle.writeDirectory();
            end
            tiff_handle.setTag(tagstruct);
            if(bin == 1)
                 tiff_handle.write(frame);
            else
                 tiff_handle.write(frame(handles.filming.clear_bin(1):2:end, handles.filming.clear_bin(2):2:end));
            end
            tiff_ind = tiff_ind + 1;

            if(tiff_ind == (max_tiff_len + 1))    % Create new tiff, only when the old is large enough
                tiff_handle.close();
                movie_serial    = movie_serial + 1;
                full_tiff_name  = [file_name '_' num2str(movie_serial) '.tif'];
                tiff_handle     = Tiff([handles.data_creation.dir_name full_tiff_name], 'w');
                set(handles.tiff_loc_txt, 'String', ['TIFF in:  ' handles.data_creation.dir_name full_tiff_name]); %txt_loc_txt : TXT in: ----
                disp('=====     New Clip file created!     =====')
                tiff_ind = 1;
            end
            frame_ind = frame_ind + 1;
            drawnow;
            handles = guidata(hObject);
        end
        set(handles.plot, 'CData', frame(handles.filming.clear_bin(1):2:end, handles.filming.clear_bin(2):2:end)*handles.filming.mult);
        set(handles.time_text, 'String', ['Time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS') '  |   Frames: ' num2str(frame_ind)]);
        set(handles.tifs_text, 'String', ['collages: ' num2str(tiff_ind) '  |  .tiff files: ' num2str(movie_serial)]);
        drawnow;                    % Perform other callbacks that may change 'handles'
        handles = guidata(hObject); % Get updated 'handles'
    end
    
    % =================  Closing operations =========================
    
    % Stop camera and close files
    stop(cam);
    flushdata(cam);
    set(cam.Source, 'FrameRate', '30.00');
    tiff_handle.close();
    
    % Update GUI panel
    set(hObject, 'String', '<html>Start<br>Rec');
    set(hObject, 'BackGroundColor', [0.94, 0.94, 0.94]);
    set(handles.update_text, 'String', '--- Ready to record ---');
    enable_buttons(handles, 'Clip', 'off');    
    
    guidata(hObject, handles);
end

function strobe_button_Callback(hObject, ~, handles)

        txt = handles.filming.src.Strobe;
        if(strcmp(txt, 'Enable'))
            set_strobe('off', handles);
        else
            set_strobe('on', handles);
        end
end

function set_strobe(state, handles)

    if(strcmp(state, 'off'))
        handles.filming.src.Strobe = 'Disable';
        set(handles.strobe_button, 'String', 'Strobe: OFF!');
        set(handles.strobe_button, 'BackGroundColor', [0.94, 0.94, 0.94]);
        set(handles.update_text, 'String','--- Strobe turned OFF! ---');
    else
        handles.filming.src.Strobe = 'Enable';
        set(handles.strobe_button, 'String', 'Strobe: ON!');
        set(handles.strobe_button, 'BackGroundColor', [0.902 0.553 0.208]);
        set(handles.update_text, 'String','--- Strobe turned ON! ---');
    end
end

function open_bg_button_Callback(hObject, ~, handles)
    % funciton OPEN_BG_BUTTON_CALLBACK opens a background image in windows
    % defaul program, doesn't interfere with the GUI.
    try
        winopen([handles.data_creation.dir_name 'bg_s' num2str(handles.data_creation.session_serial) '.tif']);
    catch e
        disp('No bg.tiff in "Logging" folder. Showing bg in RAM');
%         winopen('C:\Users\owner\Documents\MATLAB\GIGE_cam_rec\Alex_code\bg.tif');
        figure;
        imshow(handles.last_session_h.bg_frame, 'Border', 'tight');
        title('Reference image - stored in RAM', 'FontSize', 20);
    end
end

function bg_button_Callback(hObject, ~, handles)
    % BG_BUTTON_CALLBACK function that takes image and updates the internal 'bg' variable it as new
    % background image. The image contains activated LED.
    cam = handles.filming.cam;
    src = handles.filming.src;
    triggerconfig(cam, 'manual');
    cam.FramesPerTrigger = 1;
    src.Strobe = 'Enable';  % Start the strobe
    start(cam);
    pause(0.08);   % Delay the image onset to allow LED on
    trigger(cam);  % Start the image acquisition - should be quick enough to catch the 160 ms of the strobe
    pause(0.1);
    src.Strobe = 'Disable';
    stop(cam);
    triggerconfig(cam, 'immediate');
    cam.FramesPerTrigger = Inf;
    bg = getdata(cam, cam.FramesAvailable);
    bg = bg(handles.filming.clear_bin(1):2:end, handles.filming.clear_bin(2):2:end);
    handles.last_session_h.bg_frame = bg;
    set(handles.update_text, 'String', 'Ref. frame was updated');
    % === Flash GUI with red ====
    s = size(bg);
    [x, y] = ind2sub(s, 1:(s(1)*s(2)));
    h1_temp = plot(handles.picture_area, y, x, 'r.', 'MarkerSize', 5);
    pause(0.1);
    delete(h1_temp);
    set(handles.plot, 'CData', bg * handles.filming.mult);
    % =======================
    guidata(hObject, handles);
end

function rat_mark_button_Callback(hObject, ~, handles)
    
    bg = imRemoveSpots(handles.last_session_h.bg_frame);
    handles.last_session_h.bg_frame = bg;
    set(handles.plot, 'CData', bg * handles.filming.mult);
    set(handles.rat_check, 'Value', 1);
    guidata(hObject, handles);
end

function led_button_Callback(hObject, ~, handles)
    h_temp = text(20, 20, 'Double click on the LED', 'FontSize', 20, 'FontWeight', 'bold', 'color', 'red');
    [x, y] = getpts;
    x = round(x);
    y = round(y);
    delete(h_temp);
    if(isfield(handles.data_creation, 'led_marks'))
        delete(handles.data_creation.led_marks);
    end
    size = 10;
    rect = handles.last_session_h.bg_frame(y-size:y+size, x-size:x+size);
    D = regionprops(rect == max(max(rect)), 'Centroid');
    p = round(D(1).Centroid);
    xx = x+p(1)-size-1;
    yy = y+p(2)-size-1;
    handles.data_creation.led_loc = round([xx yy]);
    % Show red star on top of led for a short time
    h1 = scatter(handles.picture_area, xx, yy, 200, 's', 'MarkerEdgeColor', 'black', 'LineWidth', 4);
    h2 = scatter(handles.picture_area, xx, yy, 400, 's', 'MarkerEdgeColor', 'red', 'LineWidth', 2);
    handles.data_creation.led_marks = [h1 h2];
    guidata(hObject, handles); % update 'handles' with the changes of 'led_loc'
    
    set(handles.update_text, 'String', 'LED loc. was updated');
%     set(handles.startRec_button, 'Enable', 'on');
    set(handles.led_check, 'Value', 1);
    
end

function open_dir_button_Callback(hObject, ~, handles)
    try
        winopen(handles.data_creation.dir_name);
    catch
        try
%             winopen('C:\logging_data');   % Changed on 100719, store to 4TB drive
            winopen('D:\logging_data');
        catch
            disp('Couldn`t open dir');
        end
    end
end

function update_geo_button_Callback(hObject, ~, handles)

% UPDATE_GEO_BUTTON_CALLBACK callback function that updates the port locations, and calculates
% the center of the RIFF and the radius. The function restores the updated info and re-draws the new
% dots.

    RIFF_geo = update_RIFF_geometry();
    if(isempty(RIFF_geo))
        disp('=== RIFF geometry upadate was canceled by the user ===');
        return;
    end
    rep = questdlg('Overwrite the data??');
    if(strcmp(rep, 'Yes')) % overwrite some field the file 'session_db.mat'
        handles.last_session_h.ports     = RIFF_geo.ports;
        handles.last_session_h.r         = RIFF_geo.r;
        handles.last_session_h.mask      = RIFF_geo.mask;
        handles.last_session_h.c_point   = RIFF_geo.c_point;
        handles.last_session_h.bg_frame  = RIFF_geo.bg_frame;
    end
    % replot new areas
    [handles.filming.h_geo] = draw_walls_ports(handles.filming.h_geo, handles.last_session_h, handles.picture_area);
    guidata(hObject, handles); % Update new geometry in 
end

function update_slices_button_Callback(hObject, ~, handles)

% UPDATE_GEO_BUTTON_CALLBACK callback function that updates the slice partitions.
% The function restores the updated info and redrawes the new lines.

    slices  = update_RIFF_walls(handles.last_session_h);
    rep = questdlg('Overwrite the data??');
    if(strcmp(rep, 'Yes'))
         handles.last_session_h.slices = slices;
    end
    handles.filming.h_geo = draw_walls_ports(handles.filming.h_geo, handles.last_session_h, handles.picture_area);
    guidata(hObject, handles);
end

function load_bg_button_Callback(hObject, ~, handles)
    [file_name, d] = uigetfile('*.tif', 'Pick BackGround image', 'D:\logging_data');
    bg = imread([d '\' file_name]);
    handles.last_session_h.bg_frame = bg;
    set(handles.update_text, 'String', 'Ref. frame was updated');
    % === Flash GUI with red ====
    s = size(bg);
    [x, y] = ind2sub(s, 1:(s(1)*s(2)));
    h1_temp = plot(handles.picture_area, y, x, 'r.', 'MarkerSize', 5);
    pause(0.1);
    delete(h1_temp);
    set(handles.plot, 'CData', bg * handles.filming.mult);
    % =======================
    guidata(hObject, handles);
end

function rats_num_button_Callback(hObject, ~, handles)
    if(handles.last_session_h.num_of_rats == 1) % flip to 3 rat configuration
        handles.last_session_h.num_of_rats = 3;
        set(hObject, 'String', '<html>Change to<br>single rat');
        [h_geo] = draw_walls_ports(zeros(1, 4), handles.last_session_h, handles.picture_area);
        handles.filming.h_geo = h_geo;
    else
        handles.last_session_h.num_of_rats = 1;
        set(hObject, 'String', '<html>Change to<br>multi rat');
        delete(handles.filming.h_geo);
    end
    guidata(hObject, handles);
end

function connect_button_Callback(hObject, ~, handles)
    % The callback opens a connection to Maestro and provides the initial definitions of the ROIs in
    % the arena. The ROI can be the location of the interactive areas or manually inserted locations.
    [x, y, center_x, center_y, radius] = calc_geometry(false, handles); % Calculate the radius and center given port locations from previous session 'session_db.mat'
    % Construct a questdlg with three options
    choice = questdlg('Geometry to be sent to Maestro:', ...
                    'Geometry menu', ...
                    'Previous session', 'Manual input', 'Load from file', 'Previous session');
    % Handle response
    switch choice
        case 'Previous session'
            disp('=== Sending ROIs of the previous session ===')
            send_num = 12 + 3;
            data = round([x' y' center_x center_y radius]);  % Send points in chunks: first all x, then all y
        case 'Manual input'
            h1 = figure;
            imshow(handles.last_session_h.bg_frame, 'Border', 'tight');
            set(h1, 'units', 'normalized', 'outerposition', [0.05 0.05 0.9 0.9]);
            [new_x, new_y] = getpts; % session_db
            close(h1);
            if(isempty(new_y))  % If user chose to pikc new points but aborted the manual picking.
                disp('=== No points entered, Connection aborted ===');
                return;
            end
            send_num = length(new_y)*2 + 3;
            data = round([new_x' new_y' center_x center_y radius]);
        case 'Load from file'
            [file_name, pathname] = uigetfile('*.mat', 'Select file with points');
            if isequal(file_name,0) || isequal(pathname,0)
                 disp('=== User aborted the operation ===');
                 return;
            end
            file_data = load(fullfile(pathname, file_name)); % Read point data from file. Assume field 'points'
            send_num = length(file_data.points(:)) + 3;
            data = [file_data.points(:)' center_x center_y radius];
        otherwise
            disp('=== Connection aborted by the user ===');
            return;
    end
    % Connection to Maestro
    is_linked = true;
%     h_maestro = tcpip('132.64.105.163', 80, 'NetworkRole', 'client'); %old tydeus
    h_maestro = tcpip('132.64.107.5', 80, 'NetworkRole', 'client'); %new tydeus
    try
        fopen(h_maestro);
        pause(0.2);
        fwrite(h_maestro, round([send_num data]), 'short');
        set(handles.update_text, 'String', 'Link to Maestro is up!');
%         save([handles.data_creation.dir_name 'geometry_s' num2str(handles.data_creation.session_serial)], 'data');
        set(handles.connect_button, 'String', 'Reconnect');
    catch
        is_linked = false;
        set(handles.update_text, 'String', 'Link to Maestro has failed!');
        disp('=====    Handshake with Maestro failed!    =====');
    end
    handles.filming.h_maestro = h_maestro;
    handles.filming.is_linked = is_linked;
    guidata(hObject, handles); % update 'handles' with the changes of 'led_loc'
    if(strcmp(choice, 'Manual input'))
        answer = inputdlg('Save the points in a ".mat" file? If yes, enter file name (without .mat)', 'Save points', 1, {'No'});
        if(isempty(answer) || strcmp(answer{1}, 'No'))
             disp('=== Points were NOT saved into additional file ===');
        else
             try
                points = [new_x new_y];
                save(['C:\RIFF_code\' answer{1} '.mat'], 'points');
             catch
                 disp('=== Failed to save the points into an additional file ===');
                 return;
             end
             disp(['=== Points were saved to "' answer{1} '.mat" file ===']);
        end
    end
end

%=============      CreateFnc (and other junk)       =============

function figure1_ResizeFcn(hObject, ~, handles)

end

function clip_name_text_CreateFcn(hObject, ~, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function snap_name_text_CreateFcn(hObject, ~, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function figure1_CloseRequestFcn(hObject, ~, handles)

    stop(handles.filming.cam);
    handles.filming.src.Strobe = 'Disable';
    delete(hObject);
    disp('=====     GUI closed, camera unmounted, strobe stopped     =====');
end

%=============      Custon Function (debug only)       =============

function custom_button_Callback(hObject, ~, handles)
    
    disp('==============    Custom Func:     =================')
    
    if(0)
        stop(handles.filming.cam);
        disp('cam stopped!!');
    end
    if(0)
        a = get(handles.picture_area, 'Children');
        rat_rect = get(a, 'CData');
        rat_rect = rat_rect(1:100, 1:100);
        handles.rat_rect_h = imshow(rat_rect, 'XData', [100 200], 'YData', [100 200], ...
                                  'parent', handles.picture_area);
        handles.rat_rect = rat_rect;
        guidata(hObject, handles);
    end
    if(0)
        handles.filming.is_recording = false;
        guidata(hObject, handles);
        disp('is_recording = false');
    end
    if(0)
        txt = handles.filming.src.Strobe;
        if(strcmp(txt, 'Enable'))
            handles.filming.src.Strobe = 'Disable';
        else
            handles.filming.src.Strobe = 'Enable';
        end
        
    end
    if(0)
        disp(['Session:  ' num2str(handles.data_creation.session_serial)]);
    end
    disp('==================================================')
end
