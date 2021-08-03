
function varargout = calibrate_RIFF(varargin)
    % calibrate_RIFF MATLAB code for calibrate_RIFF.fig
    %      calibrate_RIFF, by itself, creates a new calibrate_RIFF or raises the existing
    %      singleton*.
    %
    %      H = calibrate_RIFF returns the handle to a new calibrate_RIFF or the handle to
    %      the existing singleton*.
    %
    %      calibrate_RIFF('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in calibrate_RIFF.M with the given input arguments.
    %
    %      calibrate_RIFF('Property','Value',...) creates a new calibrate_RIFF or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before calibrate_RIFF_OpeningFcn gets called.  An
    %      unrecognised property name or invalid value makes property application
    %      stop.  All inputs are passed to calibrate_RIFF_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help calibrate_RIFF

    % Last Modified by GUIDE v2.5 30-Mar-2017 17:53:15

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @calibrate_RIFF_OpeningFcn, ...
                       'gui_OutputFcn',  @calibrate_RIFF_OutputFcn, ...
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

function calibrate_RIFF_OpeningFcn(hObject, eventdata, handles, varargin)
    global vars
	% Camera configuration
    imaqreset;
    delete(timerfindall);
    cam = videoinput('tisimaq_r2013', 1, 'Y800 (1280x960)');
    src = getselectedsource(cam);
    cam.triggerrepeat = 0;
    src.Strobe = 'Disable';
    src.StrobeMode = 'Exposure';
    src.Trigger = 'Disable';
    if(src.Exposure > 0.025)
        src.Exposure = 0.005;
    end
    src.GainAuto = 'on';
    cam.FramesPerTrigger = 1;
    set_strobe('on', handles);
    frame = getsnapshot(cam);
    set_strobe('off', handles);
    [~, ~, center_x, center_y, radius] = calc_geometry(false);
    load('RIFF_circle_mask.mat');
    % create new folder in C:\Logging_data
    t = clock;
    dir_name = [num2str(t(3), '%02d') '-' num2str(t(2), '%02d') '-' num2str(t(1)) 'T']; % The filder name is padded with leading 0
    [~, ~, ~] =  mkdir('C:\logging_data', dir_name);    % Function call does nothing if folder exists
    handles.data_creation.dir_name = ['C:\logging_data\' dir_name '\'];
    
    timer_h = timer('ExecutionMode','singleShot',...
                        'StartDelay', 0.2);

    %%% imwrite(frame, [handles.hdata_creation.dir_name 'auto_bg.tif']);
    handles.filming = struct('is_live', false, 'is_recording', false, 'h_maestro', 0, 'is_linked', false, ...
                             'binning', 2, 'min_size_thr', 3, 'max_size_thr', 1500, 'cam', cam, ...
                             'src', src, 'mult', 1, 'show_max', false, 'clear_bin', [1,1], 'robot_loc', [0 0], ...
                             'riff_center', [center_x center_y], 'radius', radius, 'RIFF_mask', mask, ...
                             'is_clipping', false, 'cam_res', size(frame), 'helper', 'start', 'robot_crop_size', 50,...
                             'is_linked_local', false, 'robot_h', 0, 'timer', timer_h);
    vars.robot_elivating = false;
    vars.is_calibrating = false;
    handles.filming.control_buttons = [handles.max_button handles.exp_up handles.mult_up handles.exp_up_up...
                                handles.exp_down handles.mult_down handles.exp_down_down];
    handles.filming.mid_buttons = [handles.robot_mark_button handles.snap_button ...
                                   handles.snap_name_text handles.bg_button...
                                   handles.clip_button handles.clip_name_text handles.led_button];
    handles.filming.robot_buttons = [handles.W_button handles.A_button handles.R_button handles.F_button...
                                   handles.S_button handles.D_button handles.stop_robot_button ...
                                   handles.transmit_button handles.calib_button handles.robot_text];
    frame_binned = frame(handles.filming.clear_bin(1):2:end, handles.filming.clear_bin(2):2:end);
    axis(handles.picture_area);
    handles.plot = imshow(frame_binned, 'Parent', handles.picture_area);
    hold on
    
    handles.output = hObject;
    init_DB(hObject, handles, frame, frame_binned); % GuiData is inside this call
    disp('=====     GUI loaded    =====');
end

function varargout = calibrate_RIFF_OutputFcn(hObject, eventdata, handles)

    varargout{1} = handles.output;
end

function init_DB(hObject, handles, frame, frame_binned)

    handles.data_creation.frame_ind = 1;
    
    handles.data_creation.file_name = 'RIFF_s1';
    handles.data_creation.session_serial = 1;
    handles.data_creation.file_name_stat = 'RIFF';
    handles.data_creation.tiff_handle = 0;
    handles.data_creation.txt_handle = 0;
    handles.data_creation.bg = frame_binned;
    handles.data_creation.bg_full = frame;
    handles.data_creation.led_loc = [-1 -1];
    handles.data_creation.led_size = 3;
    
    collage_size = 5;
    rat_ROI_width = 200;
    handles.data_creation.max_tiff_len = 1000;
    handles.data_creation.collage_size = collage_size;
    handles.data_creation.rat_ROI_width = rat_ROI_width;
    
    tagstruct = struct();
    tagstruct.ImageLength = rat_ROI_width*collage_size;
    tagstruct.ImageWidth = rat_ROI_width*collage_size;
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 8;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    handles.data_creation.tagstruct = tagstruct;
    
    guidata(hObject, handles);
end


%=============      Live picture and Record operations       =============

function live_button_Callback(hObject, eventdata, handles)

    if(handles.filming.is_live)  % If already in live mode - escape it!
        handles.filming.is_live = false;
        guidata(hObject, handles); % pushing 'is_live'
        return;
    end
    
    bin = handles.filming.binning;
    handles.filming.is_live = true;
    guidata(hObject, handles);
    enable_buttons('on', handles.filming.control_buttons);
    enable_buttons('off', handles.filming.mid_buttons);
    set(handles.startRec_button, 'Enable', 'off');
    
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
%         handles.data_creation.bg = frame(handles.filming.clear_bin(1):2:end, handles.filming.clear_bin(2):2:end);
%         guidata(hObject, handles);
        set(handles.plot, 'CData', frame*handles.filming.mult);
        %  ======== show max ========
        if(handles.filming.show_max)
            burnt = (frame == (2.^handles.data_creation.tagstruct.BitsPerSample-1));
            ind = find(burnt);
            [x, y] = ind2sub(size(frame), ind);
            for i = 1:3
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
    
    enable_buttons('on', handles.filming.mid_buttons);
    enable_buttons('off', handles.filming.control_buttons);
    
    set(hObject, 'String', '<html>Start<br>Live');
    set(hObject, 'BackGroundColor',[0.94, 0.94, 0.94]);
    helper('live', handles); % Change button font to black, highlight next
    set(handles.update_text, 'String', '--- Ready to record ---');
    delete(rat_pixels);
    
    %%% imwrite(frame, 'auto_bg.tif');
    triggerconfig(handles.filming.cam, 'immediate');
    helper('live', handles);
end

function startRec_Callback(hObject, eventdata, handles)
    
    if(handles.filming.is_recording)  % If already in live mode and not locked - escape it!
        
        handles.filming.is_recording = false;
        guidata(hObject, handles);
        return;
    end
        
    handles = helper('rec', handles); % change button color to black
    set(hObject, 'String', '<html>Stop<br>Rec');
    set(hObject, 'BackGroundColor', [0.902 0.553 0.208]);
    set(handles.update_text, 'String','--- Recording ---');
    enable_buttons('off', handles.filming.mid_buttons);
    set(handles.live_button, 'Enable', 'off');
    
    handles.filming.is_recording = true;   % Locked state
    guidata(hObject, handles); % push 'is_recording' and 'helper'
    
    cam = handles.filming.cam;
    robot_loc_h = plot(handles.picture_area, 50, 50, 'r*', 'MarkerSize', 15);
%     bin = handles.filming.binning;
%     min_size_thr = handles.filming.min_size_thr;
%     max_size_thr = handles.filming.max_size_thr;
%     max_tiff_len = handles.data_creation.max_tiff_len;
%     collage_size = handles.data_creation.collage_size;
%     tagstruct = handles.data_creation.tagstruct;
    file_name = handles.data_creation.file_name;
%     rat_ROI_width = handles.data_creation.rat_ROI_width;
%     led_loc = handles.data_creation.led_loc;
%     led_size = handles.data_creation.led_size;
    robot_crop_size = handles.filming.robot_crop_size;
    robot_loc = round(handles.filming.robot_loc);
    
    dropped_frames = 0;
    prev_driver_time = 0;
%     rat_rect = [];
%     movie_serial = 1;
%     total = (collage_size).^2;
%     collage_ind = 1;
    frame_ind = 1;
%     tiff_ind = 1;
%     clean_collage = uint8(zeros(collage_size*100, collage_size*100));
%     collage = clean_collage;
%     full_tiff_name = [file_name '_1.tif'];
%     tiff_handle = Tiff([handles.data_creation.dir_name full_tiff_name], 'w');
    full_txt_name = [file_name '.txt'];
    txt_handle = fopen([handles.data_creation.dir_name file_name '.txt'], 'w');
%     set(handles.tiff_loc_txt, 'String', ['TIFF in:  ' handles.data_creation.dir_name full_tiff_name]); %txt_loc_txt : TXT in: ----
    set(handles.txt_loc_txt, 'String', ['TXT in:   ' handles.data_creation.dir_name full_txt_name]);
%     handles.data_creation.tiff_handle = tiff_handle;
    handles.data_creation.txt_handle = txt_handle;
    guidata(hObject, handles);
    fprintf(txt_handle, '%s,%s,%s,%s,%s,%s     Logged on:  %s\r\n', 'Frame_ID','Driver_clock','# in stack','|Stack|', 'rat X', 'rat Y', datestr(clock));
    
    flushdata(cam);
    cam.FramesPerTrigger = 1;
    cam.triggerrepeat = Inf;
%     if(1)    %debug
%         cam.triggerrepeat = 200;
%     end
    
    bg = uint8(filter2(fspecial('average', 3), handles.data_creation.bg));
    black_rim = zeros(robot_crop_size, size(bg,2));
    bg = [black_rim; bg; black_rim];
    robot_center = [0, 0];
    blob_ar= 0;
    tic;
    start(cam);
    pause(0.5); % first 10-15 frames will have no LED && SNR will see no strobe -> it is the start of the sync.
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
        % check dropped frames
        cur_dropped = sum(round(diff([prev_driver_time t'])/0.033)-1);
        dropped_frames = dropped_frames + max(cur_dropped, 0);
        prev_driver_time = t(end);
        
        set(handles.latency_text, 'String', ['# of images to proccess:  ' num2str(length(t))]);
        for j = 1:length(t)   % For each frame that are acquired in this bulk (most likely 1)

            frame = frames(:, :, : , j);
            %   ===== Image processing  ==========
            frame_binned = [black_rim; frame(handles.filming.clear_bin(1):2:end, handles.filming.clear_bin(2):2:end); black_rim];
            frame_binned_cropped = frame_binned(robot_loc(2):robot_loc(2) + 2*robot_crop_size,  robot_loc(1)-robot_crop_size:robot_loc(1) + robot_crop_size);
            
            bg_cropped = bg(robot_loc(2):robot_loc(2) + 2*robot_crop_size,  robot_loc(1)-robot_crop_size:robot_loc(1) + robot_crop_size);
            dI = frame_binned_cropped - bg_cropped;
            %%%
            dI_thr = dI > 2^7;
            track = regionprops(dI_thr, 'Centroid', 'Area');
%             robot_center = [-1 -1];
            [blob_ar, ind] = max([track.Area]);
%             if((blob_ar > (min_size_thr)) && (blob_ar < (max_size_thr)))   % Only if the biggest blob is above reasonable THR, binned to 2X2
            robot_center = round((track(ind).Centroid));
            robot_loc = robot_loc + robot_center - 51; % recreate real indeces
            fprintf(txt_handle, '%i,%1.4f,%i,%i,%i,%i\r\n', frame_ind, t(j), j, length(t), 2*round(robot_loc(1)), 2*round(robot_loc(2))); % saving real indices

            %   ========== Save only relevant part ===================
%             buffered_image = zeros(960+rat_ROI_width, 1280+rat_ROI_width);
%             buffered_image((rat_ROI_width/2+1):(960+rat_ROI_width/2), (rat_ROI_width/2+1):(1280+rat_ROI_width/2)) = frame;
            x_start = max(round(2*robot_loc(1)), 1);
            y_start = max(round(2*robot_loc(2)), 1);

            % send to maestro
            if(handles.filming.is_linked) % Try to send over TCP/IP only if handshake was peformed
                fwrite(handles.filming.h_maestro, [x_start y_start], 'short'); % location is always a positive value
%                 disp([x_start y_start]);
            end
%             [x,y]=ind2sub([collage_size collage_size], collage_ind);
%             if((robot_center(1)~=-1) || isempty(rat_rect))    % update rat_rect only if rat is tracked in current image - else leave previous image
%                 rat_rect = buffered_image(y_start:(y_start+rat_ROI_width-1), x_start:(x_start+rat_ROI_width-1));
%             end
%             y_start = 1 + (y-1)*rat_ROI_width;
%             y_end = y*rat_ROI_width;
%             x_start = 1 + (x-1)*rat_ROI_width;
%             x_end = x*rat_ROI_width;
%             % add the led pixels - only if LED location was specified (led_loc ~= [-1, -1])
%             if(led_loc(1) ~= -1)
%                 rat_rect(1:(2*led_size+5), 1:(2*led_size+5)) = 255;
%                 rat_rect(3:(2*led_size+3), 3:(2*led_size+3)) =  frame_binned((led_loc(2) - led_size):(led_loc(2)+ led_size),...
%                     (led_loc(1) - led_size):(led_loc(1) + led_size));
%             end
%             collage(y_start:(y_end), x_start:x_end) = rat_rect;
            
            % Print frame to tiff only if the collage is fulled
%             if (collage_ind == total)
%                 if(tiff_ind ~= 1)   % Add new DIR to tiff, only for frames > 1
%                     tiff_handle.writeDirectory();
%                 end
%                 tiff_handle.setTag(tagstruct);
%                 tiff_handle.write(collage);
%                 tiff_ind = tiff_ind + 1;
%                 collage = clean_collage;
%                 collage_ind = 0;
%             end
%             collage_ind = collage_ind + 1;
            %   ===================================================================
% 
%             if(tiff_ind == (max_tiff_len+1))    % Create new tiff, only when the old is large enough
%                 tiff_handle.close();
%                 movie_serial = movie_serial + 1;
%                 full_tiff_name = [file_name '_' num2str(movie_serial) '.tif'];
%                 tiff_handle = Tiff([handles.data_creation.dir_name full_tiff_name], 'w');
%                 set(handles.tiff_loc_txt, 'String', ['TIFF in:  ' handles.data_creation.dir_name full_tiff_name]); %txt_loc_txt : TXT in: ----
%                 handles.data_creation.tiff_handle = tiff_handle;
%                 disp('--------- New File created! -----------')
%                 tiff_ind = 1;
%             end
%             frame_ind = frame_ind + 1;
            drawnow;
            handles = guidata(hObject);
        end
        set(handles.plot, 'CData', frame_binned(51:end-50, :)*handles.filming.mult);
        delete(robot_loc_h);
        set(handles.time_text, 'String', ...
            ['Time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS') '  |   Frames: ----']);
%         set(handles.tifs_text, 'String',...
%             ['collages: ' num2str(floor(frame_ind/total)) '  |  .tiff files: ' num2str(movie_serial)']);
        set(handles.blob_text, 'String', num2str(blob_ar));
%         if(robot_center(1) == -1)
%             robot_loc_h = plot(handles.picture_area, 1, 1, 'g*', 'MarkerSize', 30);
%         else
            robot_loc_h = plot(handles.picture_area,...
                robot_loc(1), robot_loc(2), 'g*', 'MarkerSize', 30, 'LineWidth', 4);
%         end
        guidata(hObject, handles);  % flush changes to 'handles'
        drawnow;                    % Perform other callbacks that may change 'handles'
        handles = guidata(hObject); % Get updated 'handles'
    end
    
    % =================  Closing operations =========================
    
    % Stop camera and close files
    set_strobe('off', handles);
    stop(handles.filming.cam);
    flushdata(handles.filming.cam);
%     close(handles.data_creation.tiff_handle);
    fclose(handles.data_creation.txt_handle);
    delete(robot_loc_h);
    
    % Update GUI panel
    set(handles.live_button, 'Enable', 'on');
    set(hObject, 'String', '<html>Start<br>Rec');
    set(hObject, 'BackGroundColor', [0.94, 0.94, 0.94]);
    set(handles.update_text, 'String', '--- Ready to record ---');
    enable_buttons('on', handles.filming.mid_buttons);
    
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
        set(handles.bg_button, 'ForegroundColor', 'red');
    elseif(strcmp(func_name, 'led'))
        set(handles.led_button, 'ForegroundColor', 'black');% maybe no rat in bg
        set(handles.startRec_button, 'ForegroundColor', 'red');
    elseif(strcmp(func_name, 'bg'))
        set(handles.bg_button, 'ForegroundColor', 'black');
        set(handles.robot_mark_button, 'ForegroundColor', 'red'); % maybe no rat in bg
    elseif(strcmp(func_name, 'rat'))
        set(handles.robot_mark_button, 'ForegroundColor', 'black');
        set(handles.led_button, 'ForegroundColor', 'red');
    else
        set(handles.startRec_button, 'ForegroundColor', 'black');
        handles.filming.helper = false;
    end
end

function enable_buttons(setOn, button_arr)
%   parameter setOn = {'on','off'}

    for i = 1:length(button_arr)
    	curr = button_arr(i);
    	set(curr, 'Enable', setOn);
    end    
end

function exp_Callback(hObject, eventdata, handles)
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

function mult_Callback(hObject, eventdata, handles)

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

function max_button_Callback(hObject, eventdata, handles)

    handles.filming.show_max = true;
    guidata(hObject, handles);
end

function snap_button_Callback(hObject, eventdata, handles)

    name = get(handles.snap_name_text, 'String');
    frame = getsnapshot(handles.filming.cam);
    imwrite(frame, [handles.data_creation.dir_name name '.tif']);
    set(handles.update_text, 'String', 'Snapshot taken');
    disp(['Snapshot saved as: ' [name '.tif']]);
end

function clip_button_Callback(hObject, eventdata, handles)

    if(handles.filming.is_clipping)  % If already in clipping mode - escape it!
        
        handles.filming.is_clipping = false;
        guidata(hObject, handles);
        return;
    end
    
    handles.filming.is_clipping = true; % 
    guidata(hObject, handles); % push 'is_clipping'
    
    set(hObject, 'String', '<html>Stop<br>clip!');
    set(hObject, 'BackGroundColor', [0.902 0.553 0.208]);
    set(handles.update_text, 'String','--- Clipping ---');
    enable_buttons('off', handles.filming.mid_buttons);
    set(hObject, 'Enable', 'on');   % re-enable the button that was disabled (in mid_buttons)
    set(handles.live_button, 'Enable', 'off');
    start_rec_state = get(handles.startRec_button, 'Enable');   % startRec_button state depends on process time
    set(handles.startRec_button, 'Enable', 'off');
    
        
    % ==== Binned saving option =========
    bin = 2;
    % ===================================
    
    cam = handles.filming.cam;
    max_tiff_len = handles.data_creation.max_tiff_len;
    tagstruct = struct();
    tagstruct.ImageLength = handles.filming.cam_res(1)/bin;
    tagstruct.ImageWidth = handles.filming.cam_res(2)/bin;
    tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    tagstruct.BitsPerSample = 8;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    file_name = get(handles.clip_name_text, 'String');

    movie_serial = 1;
    frame_ind = 1;
    tiff_ind = 1;
    full_tiff_name = [handles.data_creation.dir_name get(handles.clip_name_text, 'String') '.tif'];
    tiff_handle = Tiff(full_tiff_name, 'w');
    disp(['=====     Creating new clip: ' full_tiff_name '     ====='])
    set(handles.tiff_loc_txt, 'String', ['TIFF in:  ' handles.data_creation.dir_name full_tiff_name]); %txt_loc_txt : TXT in: ----
    guidata(hObject, handles);
    
    flushdata(cam);
    cam.FramesPerTrigger = 1;
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

            if(tiff_ind == (max_tiff_len+1))    % Create new tiff, only when the old is large enough
                tiff_handle.close();
                movie_serial = movie_serial + 1;
                full_tiff_name = [file_name '_' num2str(movie_serial) '.tif'];
                tiff_handle = Tiff([handles.data_creation.dir_name full_tiff_name], 'w');
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
        set(handles.tifs_text, 'String', ['collages: ' num2str(tiff_ind) '  |  .tiff files: ' num2str(movie_serial)']);
        drawnow;                    % Perform other callbacks that may change 'handles'
        handles = guidata(hObject); % Get updated 'handles'
    end
    
    % =================  Closing operations =========================
    
    % Stop camera and close files
    stop(cam);
    flushdata(cam);
    tiff_handle.close();
    
    % Update GUI panel
    set(handles.live_button, 'Enable', 'on');
    set(handles.startRec_button, 'Enable', start_rec_state);
    set(hObject, 'String', '<html>Start<br>Rec');
    set(hObject, 'BackGroundColor', [0.94, 0.94, 0.94]);
    set(handles.update_text, 'String', '--- Ready to record ---');
    enable_buttons('on', handles.filming.mid_buttons);
    
    guidata(hObject, handles);
end

function strobe_button_Callback(hObject, eventdata, handles)

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

function open_bg_button_Callback(hObject, eventdata, handles)
    % funciton OPEN_BG_BUTTON_CALLBACK opens a background image in windows
    % defaul program, doesn't interfere with the GUI.
    try
        winopen([handles.data_creation.dir_name 'bg_s' num2str(handles.data_creation.session_serial) '.tif']);
    catch e
        disp(e.message);
        set(handles.update_text, 'String', e.message);
    end
end

function bg_button_Callback(hObject, eventdata, handles)

    cam = handles.filming.cam;
    src = handles.filming.src;
    triggerconfig(cam, 'manual');
    cam.FramesPerTrigger = 1;
    start(cam);
    src.Strobe = 'Enable';
    trigger(cam);
    pause(0.1);
    src.Strobe = 'Disable';
    stop(cam);
    triggerconfig(cam, 'immediate');
    cam.FramesPerTrigger = Inf;
    bg = getdata(cam, cam.FramesAvailable);
    bg = bg(handles.filming.clear_bin(1):2:end, handles.filming.clear_bin(2):2:end);
    handles.data_creation.bg = bg;
    
    set(handles.update_text, 'String', 'Ref. frame was updated');
    imwrite(bg, [handles.data_creation.dir_name 'bg_s' num2str(handles.data_creation.session_serial) '.tif']);
    % === Flash GUI with red ====
    s = size(bg);
    [x, y] = ind2sub(s, 1:(s(1)*s(2)));
    h1_temp = plot(handles.picture_area, y, x, 'r.', 'MarkerSize', 5);
    pause(0.1);
    delete(h1_temp);
    set(handles.plot, 'CData', bg*handles.filming.mult);
    % =======================
    helper('bg', handles);
    set(handles.led_button, 'Enable', 'on');
    set(handles.robot_mark_button, 'Enable', 'on');
    guidata(hObject, handles);
end

function robot_mark_button_Callback(hObject, eventdata, handles)

    h_temp = text(20, 20, 'Drag an elipse around the rat', 'FontSize', 20, 'FontWeight', 'bold', 'color', 'red');
    bg = handles.data_creation.bg;
    set(handles.plot, 'CData', bg*handles.filming.mult);
    area = imfreehand('Closed', 'true');    % Mark the rat
    delete(h_temp);
    if(isempty(area))   % area selection aborted
        set(handles.update_text, 'String', 'Ref. update canceled');
        return;
    end
    BW = area.createMask;
    delete(area);
    s = regionprops(BW, 'Centroid');
    handles.filming.robot_loc = round(s.Centroid);
    h_temp = text(20, 20, 'Double click on an empty RIFF floor', 'FontSize', 20, 'FontWeight', 'bold', 'color', 'red');
    [bg_x, bg_y] = getpts;  % Get background area
    if(isempty(bg_x))   % bg selection aborted
        set(handles.update_text, 'String', 'Ref. update canceled');
        return;
    end
    delete(h_temp);        
    BW_color = uint8(BW)*(10 + mean(mean(bg((round(bg_y)-2):(round(bg_y)+2), (round(bg_x)-2):(round(bg_x)+2)))));    % paint mask in mean value of the bg
    bg = bg.*uint8(1-BW) + BW_color; % remove the rat from bg and paint same area with the bg values
    set(handles.plot, 'CData', bg*handles.filming.mult);
%     imwrite(bg, [handles.data_creation.dir_name 'bg_s' num2str(handles.data_creation.session_serial) '.tif']);
    helper('rat', handles);
    set(handles.rat_check, 'Value', 1);
    handles.data_creation.bg = bg;
    guidata(hObject, handles);
end

function led_button_Callback(hObject, eventdata, handles)
    h_temp = text(20, 20, 'Double click on the LED', 'FontSize', 20, 'FontWeight', 'bold', 'color', 'red');
    [x, y] = getpts;
    delete(h_temp);
    handles.data_creation.led_loc = round([x y]);
    guidata(hObject, handles); % update 'handles' with the changes of 'led_loc'
    
    set(handles.update_text, 'String', 'LED loc. was updated');
    set(handles.startRec_button, 'Enable', 'on');
    set(handles.led_check, 'Value', 1);
    % Show red star on top of led for a short time
    h1_temp = plot(handles.picture_area, x, y, 'r*', 'MarkerSize', 10);
    pause(0.1);
    delete(h1_temp);
    helper('led', handles);
end

function open_dir_button_Callback(hObject, eventdata, handles)
    try
        winopen(handles.data_creation.dir_name);
    catch
    end
end

%=============      CreateFnc (and other junk)       =============

function figure1_ResizeFcn(hObject, eventdata, handles)

end

function clip_name_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function snap_name_text_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function robot_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)

    stop(handles.filming.cam);
    handles.filming.src.Strobe = 'Disable';
    delete(hObject);
    delete(timerfindall);
    disp('=====     GUI closed, camera unmounted, strobe stopped     =====');
end

function connect_button_Callback(hObject, eventdata, handles)
    

    [x, y, center_x, center_y, radius] = calc_geometry(false);
    figure;
    imshow(handles.data_creation.bg_full);
    [new_x, new_y] = getpts;
    close;
    send_num = 12 + 3;
    data = round([x' y' center_x center_y radius]);  % Send points in chunks: first all x, then all y
    if(~isempty(new_y))
        send_num = length(new_y)*2 + 3;
        data = round([new_x' new_y' center_x center_y radius]);
    end
    % Connection to Maestro
    is_linked = 'true';
    h_maestro = tcpip('132.64.61.88', 80, 'NetworkRole', 'client');
    try
        fopen(h_maestro);
        pause(0.2);
        fwrite(h_maestro, round([send_num data]), 'short');
        set(handles.update_text, 'String', 'Link to Maestro is up!');
        save([handles.data_creation.dir_name 'geometry_s' num2str(handles.data_creation.session_serial)], 'data');
        set(handles.connect_button, 'String', 'Reconnect');
    catch
        is_linked = 'false';
        set(handles.update_text, 'String', 'Link to Maestro has failed!');
        disp('=====    Handshake with Maestro failed!    =====');
    end
    handles.filming.h_maestro = h_maestro;
    handles.filming.is_linked = is_linked;
    guidata(hObject, handles); % update 'handles' with the changes of 'led_loc'
end

%=============      Robot control       =============

function pair_button_Callback(hObject, eventdata, handles)
    if(handles.filming.is_linked_local)  % If already in live mode - escape it!
        handles.filming.is_linked_local = false;
        set(hObject, 'BackGroundColor',[0.94, 0.94, 0.94]);
        set(hObject, 'String', '<html>Handshake<br>Robot');
        fwrite(handles.filming.robot_h, 'x', 'char'); % stop
        fclose(handles.filming.robot_h);
        set(handles.update_text, 'String', '--- Robot released! ---');
        enable_buttons('off', handles.filming.robot_buttons);
        guidata(hObject, handles); % pushing 'is_live'
        disp('=== robot stopped and unmounted ====');
        return;
    end
    try
        delete(instrfind);
        try
            s = serial('COM3', 'BaudRate', 19200);
            s.InputBufferSize = 1000000;
            fopen(s);
        catch
            s = serial('COM4', 'BaudRate', 19200);
            s.InputBufferSize = 1000000;
            fopen(s);
        end
        handles.filming.robot_h = s;
    catch
        set(handles.update_text, 'String', '--- COM FAILURE ---');
        return;
    end
    pause(1); %% pause for arduino boot time + hope for ~1 sec delay by user GUI...
    set(handles.filming.timer, 'TimerFcn', {@stop_robot_button_Callback, handles});
    
    handles.filming.is_linked_local = true;
    enable_buttons('on', handles.filming.robot_buttons);
    
    set(hObject, 'String', '<html>Release<br>Robot');
    set(hObject, 'BackGroundColor', [0.757 0.867 0.776]);
    set(handles.update_text, 'String', '--- Robot handshaked! ---');
    guidata(hObject, handles);
end

function W_button_Callback(hObject, eventdata, handles)
    fwrite(handles.filming.robot_h, 'w', 'char');
    activate_timer(handles);
end

function A_button_Callback(hObject, eventdata, handles)
    fwrite(handles.filming.robot_h, 'a', 'char');
    activate_timer(handles);
end

function D_button_Callback(hObject, eventdata, handles)
    fwrite(handles.filming.robot_h, 'd', 'char');
    activate_timer(handles);
end

function S_button_Callback(hObject, eventdata, handles)
    fwrite(handles.filming.robot_h, 's', 'char');
    activate_timer(handles);
end

function stop_robot_button_Callback(hObject, eventdata, handles)
global vars
    fwrite(handles.filming.robot_h, 'x', 'char');
    if(vars.robot_elivating)
        vars.robot_elivating = false;
        fwrite(handles.filming.robot_h, 'e', 'char');   % stop data transmition from robot
        pause(0.1); % verify that all data was transmitted
        try
            data = fread(handles.filming.robot_h, handles.filming.robot_h.BytesAvailable);
        catch
            data = [];
        end
        turns = sum(diff(data(1:2:end)) > 0.5);
        set(handles.update_text, 'String', ['turns: ' num2str(turns) ':' num2str(turns/180, 3)]);
        disp(['turns: ' num2str(turns) ':' num2str(turns/180, 3)]);
        if(0)
            figure;
            plot(data(1:2:end)+0.5, 'LineWidth', 3);
            ylim([-0.5 1.5]);
            hold on; plot(data(2:2:end), 'r--', 'linewidth', 1);
            ylim([-0.5 1.5]);
            title(['Elevation motor encoder data - No. of turns: ' num2str(turns)]);
       end
    end
    if(vars.is_calibrating)
        
        if(vars.doPlaySound)
            if(vars.doRunCheck)
                set(vars.timer_h1, 'StartDelay', 0.5);
            else
                set(vars.timer_h1, 'StartDelay', 14.5);
            end
             % Debug feature, if the sound is not played
            vars.doPlaySound = false;
            fwrite(vars.tcp, [vars.elivation_tick vars.circ_tick vars.line_tick], 'short');
            disp([num2str(vars.elivation_tick) ':' num2str(vars.circ_tick) ':' num2str(vars.line_tick)]);
        else
            set(vars.timer_h1, 'StartDelay', 1);
        end
        disp('start vars.timer_h1');
        start(vars.timer_h1);
    else
        disp('stopped');
    end
end

function transmit_button_Callback(hObject, eventdata, handles)
    fwrite(handles.filming.robot_h, 'e', 'char');
end

function R_button_Callback(hObject, eventdata, handles)
global vars
    flushinput(handles.filming.robot_h);
    fwrite(handles.filming.robot_h, 'e', 'char');   % start data transmition from robot
    fwrite(handles.filming.robot_h, 'r', 'char');
    vars.robot_elivating = true;
    activate_timer(handles);
end

function F_button_Callback(hObject, eventdata, handles)
global vars
    flushinput(handles.filming.robot_h);
    fwrite(handles.filming.robot_h, 'e', 'char');   % start data transmition from robot
    fwrite(handles.filming.robot_h, 'f', 'char');
    vars.robot_elivating = true;
    activate_timer(handles);
end

function activate_timer(handles)
    num = str2double(get(handles.robot_text, 'String'));
    set(handles.filming.timer, 'StartDelay', num);
    disp('start filming.timer');
    start(handles.filming.timer);
    drawnow;
end

function calib_button_Callback(hObject, eventdata, handles)
%%% calib_button
    global vars
    
    vars.doRunCheck = false;
    
    if(vars.is_calibrating)  % If calibrating, stop
        vars.is_calibrating = false;
        set(hObject, 'BackGroundColor', [0.94, 0.94, 0.94]);
        try
            stop(vars.timer_h1);
            delete(vars.timer_h1);
        catch
            disp('timers are deleted');
        end
        set(hObject, 'String', 'Start calibration');
        set(handles.update_text, 'String', '--- Calibration stopped! ---');
        guidata(hObject, handles); % pushing 'is_live'
        disp('=== calibration cycle stopped ====');
        return;
    end
    
    vars.tcp = tcpip('132.64.61.88', 80, 'NetworkRole', 'client');
    try
        fopen(vars.tcp);
        set(handles.update_text, 'String', 'Link to Maestro is up!');
    catch
        set(handles.update_text, 'String', 'Link to Maestro has failed!');
        disp('=====    Handshake with Maestro failed!    =====');
        return;
    end
    
    set(handles.filming.timer, 'TimerFcn', {@stop_robot_button_Callback, handles}); % update the handle variable that is passed
    vars.is_calibrating = true;
    set(hObject, 'String', 'Stop Calib.');
    set(hObject, 'BackGroundColor', [0.902 0.553 0.208]);
    set(handles.update_text, 'String', '--- Calibration started ---');
    guidata(hObject, handles); % upload the handles with the 'is_calibrating' change
    
    vars.elivation_tick = 0;
    vars.circ_tick = 0;
    vars.line_tick = 0;
    vars.goesUp = true;
    vars.fine_res = 1;
    vars.coarse_res = 5;
    vars.res = vars.fine_res;
    vars.doTurn = true;
    vars.performTurnEnd = false;
    vars.performTurnStart = true;
    vars.doPlaySound = true;
    vars.suspend_z_seq = false;
    vars.timer_h1 = timer('ExecutionMode', 'singleShot', 'StartDelay', 3, 'TimerFcn', {@main_loop, handles});
    pause(3);%%% DEBUG remove 
%     main_loop(-77, -77, handles);
    stop_robot_button_Callback(1, 1, handles);
end

%=============      Custon Function (debug only)       =============

function custom_button_Callback(hObject, eventdata, handles)
    
    disp('==============    Custom Func:     =================')
    if(1)
        delete(instrfindall);
        s = serial('COM3');
        fopen(s);
        fwrite(handles.filming.robot_h, 'x', 'char');
        fclose(s);
        disp('robot stopped');
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
    if(1)
        disp(['Session:  ' num2str(handles.data_creation.session_serial)]);
    end
    disp('==================================================')
end


%=============      Calibration sequence functions      =============

function move_z(handles)
    global vars
    up_move = 13;
    down_move = 12.7;
    if(vars.doRunCheck)
        up_move = 0.2;
        down_move = 0.2;
    end
    if(vars.goesUp)
        set(handles.robot_text, 'String', up_move*vars.res);
        R_button_Callback(1, 1, handles);
    else
        set(handles.robot_text, 'String', down_move*vars.res);
        F_button_Callback(1, 1, handles);
    end
end

function move_line(handles)
    %%% moves up or down
    global vars
    if(vars.res == vars.coarse_res)
%         set(handles.robot_text, 'String', 0.5);  % good fot 1.5cm XY_resolution
        set(handles.robot_text, 'String', 0.6);  % good fot 1cm XY_resolution
    else
%         set(handles.robot_text, 'String', 0.2);  % good fot 1.5cm XY_resolution
        set(handles.robot_text, 'String', 0.15);  % good fot 1cm XY_resolution
    end
    
    S_button_Callback(1, 1, handles);
end

function move_circ(op, handles)
    %%% moves up or down
    switch op
        case 'start'
%             set(handles.robot_text, 'String', 0.22);  % good fot 1.5cm XY_resolution
            set(handles.robot_text, 'String', 0.15);% good fot 1 cm XY_resolution
            D_button_Callback(1, 1, handles);
        case 'step'
%             set(handles.robot_text, 'String', 0.15);  % good fot 1.5cm XY_resolution
            set(handles.robot_text, 'String', 0.1);% good fot 1 cm XY_resolution
            A_button_Callback(1, 1, handles);
        case 'end'
%             set(handles.robot_text, 'String', 0.22);  % good fot 1.5cm XY_resolution
            set(handles.robot_text, 'String', 0.15);% good fot 1 cm XY_resolution
            D_button_Callback(1, 1, handles);
    end
end

function main_loop(~, ~, handles)
    global vars
    %%% next_z
    if(vars.doRunCheck)
        vars.suspend_z_seq = true; %%% DEBUG - remove for real run
    end
%     if(vars.performTurnEnd)
%         vars.doPlaySound = false;
%         vars.performTurnEnd = false;
%         move_circ('end', handles); % send command to robot (stop_callback ->| main_loop)
%         return;
%     end
%     if(vars.performTurnStart)
%         vars.doPlaySound = true;
%         vars.performTurnStart = false;
%         move_circ('start', handles); % send command to robot (stop_callback ->| main_loop)
%         return;
%     end
    if(~vars.suspend_z_seq)
        if((vars.elivation_tick < 10))   % sample 11 locations, 10 elivations
            vars.doPlaySound = true;
            move_z(handles); % send command to robot (stop_callback ->| main_loop)
            vars.elivation_tick = vars.elivation_tick + vars.res;
            return;
        end
        vars.elivation_tick = 0;
        vars.goesUp = ~vars.goesUp;
    else
        vars.suspend_z_seq = false;
    end
    %%% next_rot
%     if(vars.doTurn)
%         vars.circ_tick = vars.circ_tick + vars.res;
%         if(vars.circ_tick < 5)
%             vars.doPlaySound = true;
%             move_circ('step', handles); % send command to robot (stop_callback ->| main_loop -> play ->| z seq)
%         else
%             vars.circ_tick = 0;
%             vars.doTurn = false;
%             vars.doPlaySound = false;
%             vars.suspend_z_seq = true; % skip z seq, go straight to forward step
%             move_circ('end', handles); % send command to robot (stop_callback ->| main_loop -> step forward)
%         end
%         return;
%     end
    %%% next_advance
    vars.line_tick = vars.line_tick + vars.res;
    if(vars.line_tick <= 0)
%     if(vars.line_tick <= 84)  
        if(true)
%         if((vars.line_tick < 5) || ((vars.line_tick >= 40) && (vars.line_tick < 45)) || (vars.line_tick >= 80))
            vars.res = vars.fine_res;
            vars.doPlaySound = false;
            vars.performTurnStart = true; % next main_loop will start from 90 deg right turn + play_sound
            vars.doTurn = true;% next main_loop will continue with small left turns
            move_line(handles); % before the turns a forward step is performed (stop_callback ->| main_loop -> move_circ('start') ->| Z seq ->| turn)
        else
            vars.res = vars.coarse_res;
            vars.doPlaySound = true;
            move_line(handles); % perform forward step (stop_callback ->| main_loop -> Z seq ->| step forward)
        end
    else %%% finish
        fwrite(vars.tcp, [-7 -7 -7], 'short');
        fclose(vars.tcp);
        calib_button_Callback(handles.calib_button, 1, handles);
        disp('=============== Calibration sequence has ended! ===============');
    end
end
