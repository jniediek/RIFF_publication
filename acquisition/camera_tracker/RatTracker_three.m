
function varargout = RatTracker_three(varargin)
    % RatTracker_three MATLAB code for RatTracker_three.fig
    %      RatTracker_three, by itself, creates a new RatTracker_three or raises the existing
    %      singleton*.
    %
    %      H = RatTracker_three returns the handle to a new RatTracker_three or the handle to
    %      the existing singleton*.
    %
    %      RatTracker_three('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in RatTracker_three.M with the given input arguments.
    %
    %      RatTracker_three('Property','Value',...) creates a new RatTracker_three or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before RatTracker_three_OpeningFcn gets called.  An
    %      unrecognised property name or invalid value makes property application
    %      stop.  All inputs are passed to RatTracker_three_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help RatTracker_three

    % Last Modified by GUIDE v2.5 14-Jun-2017 19:08:31

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @RatTracker_three_OpeningFcn, ...
                       'gui_OutputFcn',  @RatTracker_three_OutputFcn, ...
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

function RatTracker_three_OpeningFcn(hObject, eventdata, handles, varargin)
    
	% Camera configuration
    imaqreset;
    cam = videoinput('tisimaq_r2013', 1, 'Y800 (1280x960)');
    src = getselectedsource(cam);
    cam.triggerrepeat = 0;
    src.Strobe = 'Disable';
    src.StrobeMode = 'exposure';
    src.Trigger = 'Disable';
    if(src.Exposure > 0.025)
        src.Exposure = 0.005;
    end
    src.GainAuto = 'on';
    cam.FramesPerTrigger = 1;
%     frame = rot90(getsnapshot(cam), 2);   % Don't want to take automatic frame
    frame_binned = imread('C:\Users\owner\Documents\MATLAB\GIGE_cam_rec\Alex_code\bg.tif');
    RIFF_geometry = load('RIFF_geometry.mat');
    RIFF_slices = load('RIFF_slices.mat');
    RIFF_slices = RIFF_slices.slices;
    
    %%% imwrite(frame, [handles.hdata_creation.dir_name 'auto_bg.tif']);
    handles.filming = struct('is_live', false, 'is_recording', false, 'h_maestro', 0, 'is_linked', false, ...
                             'binning', 2, 'min_size_thr', 50, 'max_size_thr', 1500, 'cam', cam, ...
                             'src', src, 'mult', 1, 'show_max', false, 'clear_bin', [1, 1],...
                             'RIFF_geometry', RIFF_geometry, 'RIFF_slices', {RIFF_slices}, ...
                             'is_clipping', false, 'cam_res', size(frame_binned).*2, 'helper', 'start', ...
                             'slice_colors', ['g', 'r', 'y']);
    handles.filming.control_buttons = [handles.max_button handles.exp_up handles.mult_up handles.exp_up_up...
                                handles.exp_down handles.mult_down handles.exp_down_down];
    handles.filming.mid_buttons = [handles.rat_mark_button handles.snap_button handles.rat_mark_button...
                                   handles.snap_name_text handles.bg_button handles.led_button...
                                   handles.clip_button handles.clip_name_text handles.led_button]; 
    axis(handles.picture_area);
    handles.plot = imshow(frame_binned, 'Parent', handles.picture_area);
    hold on;
    % Draw walls and ports
    h_geo = zeros(1, 4);
    [h_geo] = draw_walls_ports(h_geo, RIFF_geometry, RIFF_slices);
    handles.filming.h_geo = h_geo;
    handles.data_creation.led_loc = [-1 -1];
    handles.output = hObject;
    handles.data_creation.bg = frame_binned;
    disp('=====     GUI loaded    =====');
    guidata(hObject, handles);
end

function varargout = RatTracker_three_OutputFcn(hObject, eventdata, handles)

    varargout{1} = handles.output;
end

function handles = init_DB(hObject, handles)
    
    if(exist('handles.data_creation.t'))   % If database already initialized, to none.
        return;
    end
    
    % create new folder in C:\Logging_data
    t = clock;
    dir_name = [num2str(t(3), '%02d') '-' num2str(t(2), '%02d') '-' num2str(t(1)) 'T']; % The filder name is padded with leading 0
    [~, ~, ~] =  mkdir('C:\logging_data', dir_name);    % Function call does nothing if folder exists
    handles.data_creation.dir_name = ['C:\logging_data\' dir_name '\'];
    session_serial = 1;
    while true
        if(~exist([handles.data_creation.dir_name 'RIFF_s' num2str(session_serial) '.txt'], 'file'))
            break;
        end
        session_serial = session_serial + 1;
    end
    handles.data_creation.session_serial = session_serial;
    handles.data_creation.file_name = ['RIFF_s' num2str(session_serial)];
    handles.data_creation.file_name_stat = 'RIFF';
    handles.data_creation.txt_handle = 0;
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

function [h_geo] = draw_walls_ports(h_geo, RIFF_geometry, RIFF_slices)

% DRAW_WALLS_PORTS helper function that draws the geometry of the RIFF.
%
% Usage:
%     >> handles.filming.h_geo = DRAW_WALLS_PORTS (handles.filming.h_geo, handles.filming.RIFF_geometry,...
%                                                  handles.filming.RIFF_slices);
%     >> guidata(hObject, handles); % update the handles
% 
% Inputs:
%     h_geo - array of the 4 handles: 3 for the 3 walls and one for all ports and center.
%     RIFF_geometry - data of the ports, radius and the center.
%     RIFF_slices - data regarding the wall location.
%     
% Output:
%     h_geo - same array of the 4 handles.

    if(any(h_geo))
        for i = 1:length(h_geo)
            delete(h_geo(i));
        end
    end
    h_geo(1) = plot([RIFF_geometry.ports(:, 1); RIFF_geometry.c_point(1)],...
                    [RIFF_geometry.ports(:, 2); RIFF_geometry.c_point(2)],...
                    'r*', 'LineWidth', 3);
    colors = ['g', 'r', 'y'];
    for i = 1:3
        h_geo(1 + i) = plot(RIFF_slices{i}.pts(:, 1), RIFF_slices{i}.pts(:, 2),...
                            'LineWidth', 3, 'Color', colors(i));
    end
    
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
        frame = rot90(getsnapshot(handles.filming.cam), 2);   % This function flushes the EDT (Event Dispatch Thread)
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
    set(handles.startRec_button, 'Enable', 'on');
    set(hObject, 'String', '<html>Start<br>Live');
    set(hObject, 'BackGroundColor',[0.94, 0.94, 0.94]);
    helper('live', handles); % Change button font to black, highlight next
    set(handles.update_text, 'String', '--- Ready to record ---');
    delete(rat_pixels);
    
    %%% imwrite(frame, 'auto_bg.tif');
    triggerconfig(handles.filming.cam, 'immediate');
end

function startRec_Callback(hObject, eventdata, handles)
    
    if(handles.filming.is_recording)  % If already in live mode and not locked - escape it!
        
        handles.filming.is_recording = false;
        guidata(hObject, handles);
        return;
    end
        
    handles = init_DB(hObject, handles); % GuiData is inside this call
%     bg = uint8(filter2(fspecial('average', 3), handles.data_creation.bg));
    bg = handles.data_creation.bg;
    imwrite(bg, [handles.data_creation.dir_name 'bg_s' num2str(handles.data_creation.session_serial) '.tif']);
    handles = helper('rec', handles); % change button color to black
    set(hObject, 'String', '<html>Stop<br>Rec');
    set(hObject, 'BackGroundColor', [0.902 0.553 0.208]);
    set(handles.update_text, 'String','--- Recording ---');
    enable_buttons('off', handles.filming.mid_buttons);
    set(handles.live_button, 'Enable', 'off');
    
    handles.filming.is_recording = true;   % Locked state
    guidata(hObject, handles); % push 'is_recording' and 'helper'
    
    cam = handles.filming.cam;
    colors = handles.filming.slice_colors;
    bin = handles.filming.binning;
    min_size_thr = handles.filming.min_size_thr;
    max_size_thr = handles.filming.max_size_thr;
    max_tiff_len = handles.data_creation.max_tiff_len;
    collage_size = handles.data_creation.collage_size;
    tagstruct = handles.data_creation.tagstruct;
    file_name = handles.data_creation.file_name;
    rat_ROI_width = handles.data_creation.rat_ROI_width;
    led_loc = handles.data_creation.led_loc;
    led_size = handles.data_creation.led_size;
    
    dropped_frames = 0;
    prev_driver_time = 0;
    clean_collage = uint8(zeros(collage_size*100, collage_size*100));
    rat_data = struct('loc', [-1 -1], 'rat_rect', zeros(rat_ROI_width), 'foundInFrame', 0, 'collage', clean_collage,...
                      'movie_serial', 1, 'collage_ind', 1, 'tiff_ind', 1);
    rats_data = [rat_data rat_data rat_data];
    total = (collage_size)^2;
    frame_ind = 1;
    
    for i = 1:3
        rats_data(i).full_tiff_name = [file_name '_R' num2str(i) '_1.tif'];
        rats_data(i).tiff_handle = Tiff([handles.data_creation.dir_name rats_data(i).full_tiff_name], 'w');
        rats_data(i).rat_loc_h = plot(handles.picture_area, 50, 50, '*', 'MarkerSize', 15, 'color', colors(i));
    end
    
    full_txt_name = [file_name '.txt'];
    txt_handle = fopen([handles.data_creation.dir_name file_name '.txt'], 'w');
    set(handles.tiff_loc_txt, 'String', ['TIFF in:  ' handles.data_creation.dir_name file_name]); %txt_loc_txt : TXT in: ----
    set(handles.txt_loc_txt, 'String', ['TXT in:   ' handles.data_creation.dir_name full_txt_name]);
    handles.data_creation.txt_handle = txt_handle;
    guidata(hObject, handles);
    fprintf(txt_handle, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s     Logged on:  %s\r\n', 'Frame_ID', 'Driver_clock',...
            '# in stack', '|Stack|', 'rat1 X', 'rat1 Y','rat2 X', 'rat2 Y', 'rat3 X', 'rat3 Y', datestr(clock));
    
    flushdata(cam);
    cam.FramesPerTrigger = 1;
    cam.triggerrepeat = Inf;
%     if(1)    % DEBUG remove of Exp. run
%         cam.triggerrepeat = 52;
%     end
    
    tic;
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
        % check dropped frames
        cur_dropped = sum(round(diff([prev_driver_time t'])/0.033)-1);
        dropped_frames = dropped_frames + max(cur_dropped, 0);
        prev_driver_time = t(end);
        
        set(handles.latency_text, 'String', ['# of images to proccess:  ' num2str(length(t))]);
        for j = 1:length(t)   % For each frame that are acquired in this bulk (most likely 1)

            frame = rot90(frames(:, :, : , j), 2);
            
            %   ========== Image processing  =============
            
            temp = {[-1 -1], [-1 -1], [-1 -1]}; [rats_data.loc] = temp{:};
            frame_binned = frame(handles.filming.clear_bin(1):2:end, handles.filming.clear_bin(2):2:end);
            m = mean(mean(frame));
            if((m < 20) || (m > 100))
                areas_sorted = -1;
            else
                dI = frame_binned - bg;
                dI = dI .* handles.filming.RIFF_geometry.mask;
                dI_thr_noise = dI > 2^5;
                dI_thr = filter2(fspecial('average',3), dI_thr_noise) > 0.75;
                track = regionprops(dI_thr, 'Centroid', 'Area');
                [areas_sorted, t_id] = sort([track.Area], 'descend');
                for i = 1:length(t_id)
                    blob_ar = areas_sorted(i);
                    curr_point = track(t_id(i)).Centroid;
                    isRightSize = (blob_ar > (min_size_thr)) && (blob_ar < (max_size_thr));
                    if((sum([rats_data.foundInFrame]) == 3) || ~isRightSize)     % If a blob was found in each area don't look at the rest
                        break;
                    end
                    [slice_id] = find_loc_of_point(curr_point, handles.filming.RIFF_geometry.c_point, ...
                                                   handles.filming.RIFF_geometry.r, handles.filming.RIFF_slices);
                     if((slice_id > 0) && ~rats_data(slice_id).foundInFrame) % If point is associated to a slice (not outside of all), and if the slice is not yet populated, put in the found blob
                         rats_data(slice_id).loc = ceil(curr_point);
                         rats_data(slice_id).foundInFrame = 1;
                     end
                end
            end
            
            temp = num2cell(zeros(1,3)); [rats_data.foundInFrame] = temp{:};    % Reset the 'foundInFrame' flag
            %   ========== Save rat locations in the .txt file ===================
            
            fprintf(txt_handle, '%i,%1.4f,%i,%i,%i,%i,%i,%i,%i,%i\r\n', frame_ind, t(j), j, length(t),...
                    rats_data(1).loc(1), rats_data(1).loc(2), rats_data(2).loc(1), rats_data(2).loc(2), ...
                    rats_data(3).loc(1), rats_data(3).loc(2));

            %   ========== Save only relevant part ===================
%             buffered_image = zeros(960+rat_ROI_width+3, 1280+rat_ROI_width+3); % craete black canvas
%             buffered_image((rat_ROI_width/2+1):(960+rat_ROI_width/2), (rat_ROI_width/2+1):(1280+rat_ROI_width/2)) = frame; % fill center with the raw frame
            
            % send to maestro
            if(handles.filming.is_linked) % Try to send over TCP/IP only if handshake was peformed
                fwrite(handles.filming.h_maestro, [rats_data(1).loc rats_data(2).loc rats_data(3).loc],...
                       'short'); % location is always a positive value
            end
                        
            for i = 1:3
                [x,y]=ind2sub([collage_size collage_size], rats_data(i).collage_ind);
                loc = ceil(rats_data(i).loc).*2; % Shift to full frame coordinates
                collage = rats_data(i).collage;
                tiff_handle = rats_data(i).tiff_handle;
                if(loc(1)~=-2)    % update rat_rect only if rat is tracked in current image - else leave previous image
                    temp = frame(max((loc(2)-rat_ROI_width/2), 1):min((loc(2)+rat_ROI_width/2-1), 960),...
                                 (loc(1)-rat_ROI_width/2):(loc(1)+rat_ROI_width/2-1));
                    if((loc(2)-rat_ROI_width/2) < 1)
                        temp = [zeros(200 - size(temp, 1), 200); temp];
                    elseif ((loc(2)+rat_ROI_width/2-1) > 960)
                        temp = [temp; zeros(200 - size(temp, 1), 200)];
                    end
                    rats_data(i).rat_rect = temp;
                end
                rat_rect = rats_data(i).rat_rect;   % If rat found an updated rect will be loaded, else previous one.
                y_start = 1 + (y-1)*rat_ROI_width;
                y_end = y*rat_ROI_width;
                x_start = 1 + (x-1)*rat_ROI_width;
                x_end = x*rat_ROI_width;
                % add the led pixels - only if LED location was specified (led_loc ~= [-1, -1])
                if(led_loc(1) ~= -1)
                    rat_rect(1:(2*led_size+5), 1:(2*led_size+5)) = 255;
                    rat_rect(3:(2*led_size+3), 3:(2*led_size+3)) =  frame_binned((led_loc(2) - led_size):(led_loc(2)+ led_size),...
                                                                        (led_loc(1) - led_size):(led_loc(1) + led_size));
                end
                collage(y_start:y_end, x_start:x_end) = rat_rect;
                rats_data(i).collage = collage;
                rats_data(i).rat_rect = rat_rect;
                % Print frame to tiff only if the collage is fulled
                if (rats_data(i).collage_ind == total)
                    if(rats_data(i).tiff_ind ~= 1)   % Add new DIR to tiff, only for frames > 1
                        tiff_handle.writeDirectory();
                    end
                    tiff_handle.setTag(tagstruct);
                    tiff_handle.write(collage);
                    rats_data(i).collage = clean_collage;
                    rats_data(i).tiff_ind = rats_data(i).tiff_ind + 1;
                    rats_data(i).collage_ind = 0;
                end
                if(rats_data(i).tiff_ind == (max_tiff_len+i*10))
                    tiff_handle.close();
                    rats_data(i).full_tiff_name = [file_name '_R' num2str(i) '_' num2str(rats_data(i).movie_serial) '.tif'];
                    tiff_handle = Tiff([handles.data_creation.dir_name rats_data(i).full_tiff_name], 'w');
                    rats_data(i).tiff_handle = tiff_handle;
                    rats_data(i).movie_serial = rats_data(i).movie_serial + 1;
                    disp('--------- New File created! -----------')
                    rats_data(i).tiff_ind = 1;
                end
                rats_data(i).collage_ind = rats_data(i).collage_ind + 1;
            end
            frame_ind = frame_ind + 1;
            drawnow;
            handles = guidata(hObject);
        end
        set(handles.plot, 'CData', frame_binned*handles.filming.mult);
        delete([rats_data.rat_loc_h]);
        set(handles.time_text, 'String', ...
            ['Time: ' datestr(datenum(0,0,0,0,0,toc),'HH:MM:SS') '  |   Frames: ' num2str(frame_ind)]);
        set(handles.tifs_text, 'String',...
            ['collages: ' num2str(floor(frame_ind/total)) '  |  .tiff files: ' num2str(rats_data(1).movie_serial)]);
        if(loc(1) ~= -2)
            set(handles.blob_text, 'String', num2str(areas_sorted(1)));
        else
            set(handles.blob_text, 'String', '-1');
        end
        for i = 1:3
            loc = rats_data(i).loc;
            if(loc(1) == -2)
                rats_data(i).rat_loc_h = plot(handles.picture_area, 1, 1, 'g*', 'MarkerSize', 30);
            else
                rats_data(i).rat_loc_h = plot(handles.picture_area,...
                    loc(1), loc(2), 'g*', 'MarkerSize', 30, 'LineWidth', 4);
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
    for i = 1:3
        close(rats_data(i).tiff_handle);
    end
    fclose(txt_handle);
    delete([rats_data.rat_loc_h]);
    
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
    frame = rot90(getsnapshot(handles.filming.cam), 2);
    imwrite(frame, [handles.data_creation.dir_name name '.tif']);
    set(handles.update_text, 'String', 'Snapshot taken');
    disp(['Snapshot saved as: ' [name '.tif']]);
end

function clip_button_Callback(hObject, eventdata, handles)

    if(handles.filming.is_clipping)  % If already in clipping mode - escape it!
        
        handles.filming.is_clipping = false;
        set_strobe('off', handles);
        guidata(hObject, handles);
        return;
    end
    handles = init_DB(hObject, handles); % GuiData is inside this call
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
    set_strobe('on', handles);
        
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
%     set(cam.Source, 'FrameRate', ' 3.75');
    
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

            frame = rot90(frames(:, :, : , j), 2);
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

            if(tiff_ind == (max_tiff_len + 500 + 1))    % Create new tiff, only when the old is large enough
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
        disp('No bg.tiff in "Logging" folder. Showing bg in RAM');
%         winopen('C:\Users\owner\Documents\MATLAB\GIGE_cam_rec\Alex_code\bg.tif');
        figure;
        imshow(handles.data_creation.bg, 'Border', 'tight');
        title('Reference image - stored in RAM', 'FontSize', 20);
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
    bg = rot90(getdata(cam, cam.FramesAvailable), 2);
    bg = bg(handles.filming.clear_bin(1):2:end, handles.filming.clear_bin(2):2:end);
    handles.data_creation.bg = bg;
    
    set(handles.update_text, 'String', 'Ref. frame was updated');
    % === Flash GUI with red ====
    s = size(bg);
    [x, y] = ind2sub(s, 1:(s(1)*s(2)));
    h1_temp = plot(handles.picture_area, y, x, 'r.', 'MarkerSize', 5);
    pause(0.1);
    delete(h1_temp);
    set(handles.plot, 'CData', bg*handles.filming.mult);
    % =======================
    guidata(hObject, handles);
end

function rat_mark_button_Callback(hObject, eventdata, handles)
    
    bg = imRemoveSpots(handles.data_creation.bg);
    handles.data_creation.bg =bg;
    helper('rat', handles);
    set(handles.plot, 'CData', bg*handles.filming.mult);
    set(handles.rat_check, 'Value', 1);
    guidata(hObject, handles);
end

function led_button_Callback(hObject, eventdata, handles)
    h_temp = text(20, 20, 'Double click on the LED', 'FontSize', 20, 'FontWeight', 'bold', 'color', 'red');
    [x, y] = getpts;
    x = round(x);
    y = round(y);
    delete(h_temp);
    size = 10;
    rect = handles.data_creation.bg(y-size:y+size, x-size:x+size);
    D = regionprops(rect == max(max(rect)), 'Centroid');
    p = round(D.Centroid);
    xx = x+p(1)-size-1;
    yy = y+p(2)-size-1;
    handles.data_creation.led_loc = round([xx yy]);
    guidata(hObject, handles); % update 'handles' with the changes of 'led_loc'
    
    set(handles.update_text, 'String', 'LED loc. was updated');
%     set(handles.startRec_button, 'Enable', 'on');
    set(handles.led_check, 'Value', 1);
    % Show red star on top of led for a short time
    scatter(handles.picture_area, xx, yy, 200, 's', 'MarkerEdgeColor', 'black', 'LineWidth', 4);
    scatter(handles.picture_area, xx, yy, 400, 's', 'MarkerEdgeColor', 'red', 'LineWidth', 2);
    helper('led', handles);
end

function open_dir_button_Callback(hObject, eventdata, handles)
    try
        winopen(handles.data_creation.dir_name);
    catch
        try
            winopen('C:\logging_data');
        catch
            
        end
    end
end

function update_geo_button_Callback(hObject, eventdata, handles)

% UPDATE_GEO_BUTTON_CALLBACK callback function that updates the port locations, and calculates
% the senter of the RIFF and the radius. The function restores the updated info and redrawes the new
% dots.

    update_RIFF_geometry();
    RIFF_geometry = load('RIFF_geometry.mat');
    handles.filming.RIFF_geometry = RIFF_geometry;
    [handles.filming.h_geo] = draw_walls_ports(handles.filming.h_geo, RIFF_geometry,...
                                                handles.filming.RIFF_slices);
    guidata(hObject, handles); % Update new geometry in 
end

function update_slices_button_Callback(hObject, eventdata, handles)

% UPDATE_GEO_BUTTON_CALLBACK callback function that updates the slice partitions.
% The function restores the updated info and redrawes the new lines.

    slices = update_RIFF_walls(handles.filming.RIFF_geometry, handles.data_creation.bg);
%     RIFF_slices = load('RIFF_slices.mat');
%     RIFF_slices = RIFF_slices.slices;
    [handles.filming.h_geo] = draw_walls_ports(handles.filming.h_geo, handles.filming.RIFF_geometry,...
                                               slices);
    guidata(hObject, handles);
end

function load_bg_button_Callback(hObject, eventdata, handles)
    [file_name, d] = uigetfile('*.tif', 'Pick BackGround image', 'C:\logging_data');
    bg = imread([d '\' file_name]);
    handles.data_creation.bg = bg;
    
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

function figure1_CloseRequestFcn(hObject, eventdata, handles)

    stop(handles.filming.cam);
    handles.filming.src.Strobe = 'Disable';
    delete(hObject);
    disp('=====     GUI closed, camera unmounted, strobe stopped     =====');
end

function connect_button_Callback(hObject, eventdata, handles)
    

    [x, y, center_x, center_y, radius] = calc_geometry(false);
    figure;
    imshow(handles.data_creation.bg);
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

%=============      Custon Function (debug only)       =============

function custom_button_Callback(hObject, eventdata, handles)
    
    disp('==============    Custom Func:     =================')
    if(0)
        figure; imshow(handles.data_creation.bg);
        title('bg');
    end
    
    if(1)
        stop(handles.filming.cam);
        disp('cam stopped!!');
    end
    if(0)
        disp(handles.filming.src.Strobe);
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
