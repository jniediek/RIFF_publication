%   ============   Opening function    ==========================

function varargout = tracks_GUI(varargin)
% TRACKS_GUI MATLAB code for tracks_GUI.fig
%      TRACKS_GUI, by itself, creates a new TRACKS_GUI or raises the existing
%      singleton*.
%
%      H = TRACKS_GUI returns the handle to a new TRACKS_GUI or the handle to
%      the existing singleton*.
%
%      TRACKS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKS_GUI.M with the given input arguments.
%
%      TRACKS_GUI('Property','Value',...) creates a new TRACKS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tracks_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to tracks_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tracks_GUI

% Last Modified by GUIDE v2.5 15-Jun-2017 10:06:13

% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @tracks_GUI_OpeningFcn, ...
                       'gui_OutputFcn',  @tracks_GUI_OutputFcn, ...
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

function tracks_GUI_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;
    handles.state = struct('db_name', '', 'db_path', '', 'end', 10, 'frame', 0, 'traceOn', false,...
                           'heatmapOn', 0, 'hm_data', [], 'speed_max', 1, 'ImageOn', 0, ...
                           'num_of_rats', 3);
    handles.buttons.db = [handles.load_bg handles.loadMovie_button];
    handles.buttons.trace = [handles.trace_button handles.trace_up handles.trace_down handles.show_image_button];
    handles.buttons.heatmap = [handles.heatmap_button handles.thr_up_button handles.thr_up2_button ...
                               handles.thr_down_button handles.thr_down2_button handles.set_thr_button...
                               handles.thr_text handles.log_button];
    handles.buttons.play = [handles.play_button handles.play_text];
    handles.h_plots = struct('h1', 0);
    handles.h_plots.slider = addlistener(handles.slider, 'Value', 'PostSet' , @slider_Callback);
    guidata(hObject, handles);
end

function varargout = tracks_GUI_OutputFcn(~, ~, handles)
    varargout{1} = handles.output;
end

%========================   Callbacks   ===========================

function slider_Callback(~, event)
    
    handles = guidata(event.AffectedObject);
    handles.state.end = floor(get(handles.slider, 'Value'));
    handles = replot(handles);  % replot the image
    guidata(handles.picture_area, handles); % handles.picture_area is picked arbitrary as one of the GUI objects needed fot GUIDATA(obj, handles)
end

function loadMovie_button_Callback(hObject, ~, handles)
    tic;
    state = handles.state;
    [db_name, db_path] = uigetfile('*.txt', 'Select DB file');
    if(length(db_name) < 2)
        return;
    end
    [parsed_txt] = import_text([db_path '\' db_name]);
    
%     legend({'Rat No.1', 'Rat No.2', 'Rat No.3'});
    
    state.db_name=db_name; state.db_path=db_path;
    state.rat1 = uint16([parsed_txt.rat1X parsed_txt.rat1Y]);
    state.rat2 = uint16([parsed_txt.rat2X parsed_txt.rat2Y]);
    state.rat3 = uint16([parsed_txt.rat3X parsed_txt.rat3Y]);
    state.rat1c = smooth_dists(pdist1(double(state.rat1)));
    state.rat2c = smooth_dists(pdist1(double(state.rat2)));
    state.rat3c = smooth_dists(pdist1(double(state.rat3)));
    state.speed_max = max([max(state.rat1c) max(state.rat2c) max(state.rat3c)]);
    state.db_len = length(parsed_txt.rat3X);
    handles.slider.SliderStep = [min(1/state.db_len, 0.001) min(600/state.db_len, 0.01)];
    set(handles.picture_area, 'CLim', [0 state.speed_max.*0.8]);
    set(handles.slider, 'Max', state.db_len);
    set(handles.slider, 'Min', 1);
    state.end = state.db_len;
    
    state.tail_len = state.db_len - 1;
    handles.state = state;
    set(handles.movie_path, 'String', db_name);
    set(handles.txt_name, 'String', db_path);
    guidata(hObject, handles);
    handles.slider.Value = state.end;       % Slider callback is called and performs replot()
    disp(['Time to calc the operation: ' num2str(toc)]);
    set(handles.buttons.trace, 'Enable', 'on');
    set(handles.buttons.heatmap, 'Enable', 'on');
end

function [parsed_txt] = import_text (filename)
    %IMPORTFILE Import numeric data from a text file as a matrix.
    %   RIFFS3 = IMPORTFILE(FILENAME) Reads data from text file FILENAME for
    %   the default selection.
    %
    %   RIFFS3 = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows
    %   STARTROW through ENDROW of text file FILENAME.
    %
    % Example:
    %   RIFFs3 = importfile('RIFF_s3.txt', 2, 109133);
    %
    %    See also TEXTSCAN.

    delimiter = ',';
%     if nargin<=2
    startRow = 2;
    endRow = inf;
%     end

    formatSpec = '%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
    txt_h = fopen(filename,'r');
    arr = textscan(txt_h, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter,...
                         'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(1)-1,...
                         'ReturnOnError', false, 'EndOfLine', '\r\n');
    for block = 2:length(startRow)
        frewind(txt_h);
        dataArrayBlock = textscan(txt_h, formatSpec, endRow(block)-startRow(block)+1,...
                                  'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,...
                                  'HeaderLines', startRow(block)-1, 'ReturnOnError', false,...
                                  'EndOfLine', '\r\n');
        for col = 1:length(arr)
            arr{col} = [arr{col}; dataArrayBlock{col}];
        end
    end
    fclose(txt_h);
    parsed_txt = table(arr{1:end-1}, 'VariableNames', {'Frame_ID', 'Driver_clock', 'frames_in_stack',...
                   'Stack', 'rat1X', 'rat1Y', 'rat2X', 'rat2Y', 'rat3X', 'rat3Y'});
end

function handles = replot(handles)
    state = handles.state;
    h_plots = handles.h_plots;
    curr_frame = state.end;
    start = max(1, curr_frame - state.tail_len);
    if(h_plots.h1 ~= 0)
        delete([h_plots.h1 h_plots.h1h]);
    end
    rat1 = state.rat1(start:curr_frame, :);
    rat2 = state.rat2(start:curr_frame, :);
    rat3 = state.rat3(start:curr_frame, :);
    c1 = state.rat1c(start:curr_frame);
    c2 = state.rat2c(start:curr_frame);
    c3 = state.rat3c(start:curr_frame);
    x = [rat1(:, 1); rat2(:, 1); rat3(:, 1)];
    y = [rat1(:, 2); rat2(:, 2); rat3(:, 2)];
    c = [c1; c2; c3];
    h_plots.h1 = scatter(handles.picture_area, x, y, zeros(length(x), 1)+4, c, 'filled');   % Plot the colored tail
    x = [rat1(end, 1); rat2(end, 1); rat3(end, 1)];
    y = [rat1(end, 2); rat2(end, 2); rat3(end, 2)];
    for i = 1:handles.state.num_of_rats
        if(~handles.state.ImageOn)      % Represent rat location using *
            h_plots.h1h(i) = plot(handles.picture_area, x(i), y(i), 'y*', 'LineWidth', 10);  % plot the heads
        else         % Represent rat location using the images
            [rect, ~] = handles.state.tiff_hs(i).get_rect_ra(curr_frame);
            h_plots.h1h(i) = imshow(rect(1:2:end, 1:2:end));
            try
                h_plots.h1h(i).XData = h_plots.h1h(i).XData - 200/2/2 + double(x(i));   % Shift image in X axis
                h_plots.h1h(i).YData = h_plots.h1h(i).YData - 200/2/2 + double(y(i));   % Shift image in Y axis
            catch
                disp('====== CROPPING NEEDED TO SHOW IMAGE IN THIS LOCATION ========');
                % TODO: repair the dimention mismatch when rat is near the
                % border.
            end
        end
    end
    set(handles.message_text, 'String', 'Movie Updated!!!');
    set(handles.percents_text, 'String', [num2str(round(100*curr_frame/handles.state.db_len))...
        '%  |  Frame: ' num2str(curr_frame) '  |  Tail:' num2str(handles.state.tail_len)...
        '  |  Time: ' datestr(datenum(0, 0, 0, 0, 0, state.end/30),'HH:MM:SS.FFF')]);
    handles.h_plots = h_plots;
    handles.state = state;
end

function d_s = smooth_dists(d)
    d_s = smooth(d, 20);
end

function load_bg_button_Callback(hObject, ~, handles)
    h_plots = handles.h_plots;
    state = handles.state;
    
    [file_name, d] = uigetfile('*.tif','Select BG image');
    if(file_name == 0)
        return;
    end
    frame_bg = imread([ d '\' file_name]);
    handles.bg = frame_bg;
%     frame_bg = abs(sin((1:500)'/100)*sin((1:500)/100));
    frame_bg = cat(3, frame_bg, frame_bg, frame_bg);% Create pseudo RGB image, to overlay later with colored plots
    handles.plot = imshow(frame_bg, 'Parent', handles.picture_area);
    hold on;
    set(handles.bg_name, 'String', [ d '\' file_name]);
    set(handles.message_text, 'String', '=== New background loaded! ===');
    set(handles.loadMovie_button, 'Enable', 'on');
    guidata(hObject, handles);
    
end

function trace_Callback(hObject, ~, handles)
    state = handles.state;
    tag = get(hObject,'Tag');
    if(strcmp(tag, 'trace_up'))
        handles.state.tail_len = min(state.tail_len + 50, state.end);
        handles = replot(handles);
        guidata(hObject, handles);
        return;
    elseif(strcmp(tag, 'trace_down'))
        handles.state.tail_len = max(state.tail_len - 50, 1);
        handles = replot(handles);
        guidata(hObject, handles);
        return;
    end
    
    if(state.traceOn)   % remove trace, show full track
        set(handles.message_text, 'String', 'Showing trace');
        set(hObject,'String','Trace');
        state.end = state.db_len;
        state.tail_len = state.end - 1;
        set(handles.buttons.play, 'Enable', 'off');
    else % Create trace
        set(handles.message_text, 'String', 'Showing full');
        set(hObject,'String','Full');
        state.end = min(30, state.end);
        state.tail_len = 30*60;
        set(handles.buttons.play, 'Enable', 'on');
    end
    set(handles.trace_up, 'Enable', 'on');
    set(handles.trace_down, 'Enable', 'on');
    state.traceOn = ~state.traceOn;
    handles.state = state;
    guidata(hObject, handles);
    handles.slider.Value = state.end;
end

function heatmap_button_Callback(hObject, ~, handles)

    h_plots = handles.h_plots;
    if(handles.state.heatmapOn) % Turn off the heatmap feature
        handles = replot(handles);
        set(handles.buttons.trace, 'Enable', 'on');
        set(handles.buttons.play, 'Enable', 'on');
        heatmap_toggle_buttons(handles, 0);
        set(handles.message_text, 'String', 'Heat maps turned off');
        handles.state.clim = handles.state.speed_max.*0.8;
    else % Turn on the heatmap feature
        delete([h_plots.h1]);
        set(h_plots.h1h, 'Visible', 'Off')
        if(isempty(handles.state.hm_data)) % Create for the first time the heatmaps. If created, load from memory.
            x = [handles.state.rat1(:, 1); handles.state.rat2(:, 1); handles.state.rat3(:, 1)];
            y = [handles.state.rat1(:, 2); handles.state.rat2(:, 2); handles.state.rat3(:, 2)];
            [handles.state.hm_data] = bin_traj2d(x, y, 100, handles.bg);
        end
        handles.state.clim = round(max(handles.state.hm_data(:, 3)), 5);
        set(handles.thr_text, 'String', num2str(handles.state.clim));
        hm = handles.state.hm_data;
        h_plots.h1 = scatter(hm(:, 1), hm(:, 2), 40, hm(:, 3), 'filled',...
                             'Marker', 's', 'MarkerFaceAlpha', 1);
        handles.h_plots = h_plots;
        cmap = jet(1000);
        colormap(handles.figure1, cmap(1:end, :));
        brighten(handles.figure1, 0.7);
        set(handles.message_text, 'String', 'Heat maps turned on');
        set(handles.buttons.trace, 'Enable', 'off');
        set(handles.buttons.play, 'Enable', 'off');
        set(handles.buttons.heatmap, 'Enable', 'on');
        heatmap_toggle_buttons(handles, 1);
    end
    caxis(handles.picture_area, [0 handles.state.clim]);
    handles.state.heatmapOn = ~handles.state.heatmapOn;
    guidata(hObject, handles);
end

function heatmap_toggle_buttons(handles, setTempOn)
    if(setTempOn)
        set(handles.thr_down_button,'Enable', 'on');
        set(handles.thr_up_button,  'Enable', 'on');
        set(handles.thr_down2_button,'Enable', 'on');
        set(handles.thr_up2_button,  'Enable', 'on');
        set(handles.thr_text,       'Enable', 'on');
        set(handles.set_thr_button, 'Enable', 'on');
        set(handles.log_button,     'Enable', 'on');
        
        set(handles.trace_button,   'Enable', 'off');
        set(handles.trace_up,       'Enable', 'off');
        set(handles.trace_down,     'Enable', 'off');
    else
        set(handles.thr_down_button,'Enable', 'off');
        set(handles.thr_text,       'Enable', 'off');
        set(handles.thr_down2_button,'Enable', 'off');
        set(handles.thr_up2_button,  'Enable', 'off');
        set(handles.set_thr_button, 'Enable', 'off');
        set(handles.thr_up_button,  'Enable', 'off');
        set(handles.log_button,     'Enable', 'off');
        
        set(handles.trace_button,   'Enable', 'on');
        set(handles.trace_up,       'Enable', 'on');
        set(handles.trace_down,     'Enable', 'on');
    end
end

function thr_buttons_Callback(hObject, ~, handles)

    switch hObject.Tag
        case 'thr_up_button'
           handles.state.clim = min(handles.state.clim + 0.001, 1);
           msg = 'Heatmap threshold encreased';
        case 'thr_up2_button'
            handles.state.clim = min(handles.state.clim + 0.005, 1);
           msg = 'Heatmap threshold encreased';
        case 'thr_down_button'
            handles.state.clim = max(handles.state.clim - 0.001, 0.0001);
            msg = 'Heatmap threshold decreased';
        case 'thr_down2_button'
            handles.state.clim = max(handles.state.clim - 0.005, 0.0001);
            msg = 'Heatmap threshold decreased';
        otherwise
            input_num = str2double(handles.thr_text.String);
            if(input_num < 0.00001 || input_num > 1)
                set(handles.message_text, 'String', 'Legal range: [0.02 <-> 1]');
                return;
            end
            handles.state.clim = input_num;
            msg = 'Threshold changed!';
    end
    set(handles.message_text, 'String', msg);
    caxis(handles.picture_area, [0 handles.state.clim]);
    set(handles.thr_text, 'String', num2str(handles.state.clim));
    guidata(hObject, handles);
end

function [data] = bin_traj2d(x, y, bins, bg)
% BIN_TRAJ2D a function that recieves a Nx2 vector of locations and creates heat-map.
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

function log_button_Callback(hObject, ~, handles)
    str = hObject.String;
    hm = handles.state.hm_data;
    if(strcmp(str, 'Remove log')) % Remove log
        set(hObject, 'String', 'Show log');
        set(handles.message_text, 'String', 'Color - Natural scale');
        handles.h_plots.h1.CData = handles.state.hm_data(:, 3);
        handles.state.clim = max(handles.state.hm_data(:, 3));
    else  % Set log scale
        set(hObject, 'String', 'Remove log');
        set(handles.message_text, 'String', 'Color - Log scale');
        log_data = log(handles.state.hm_data(:, 3));
        log_data = (log_data - min(log_data)) / (max(log_data) - min(log_data)) / 100;
        handles.h_plots.h1.CData = log_data;
        handles.state.clim = max(log_data);
    end
    set(handles.thr_text, 'String', num2str(handles.state.clim));
    caxis(handles.picture_area, [0 handles.state.clim]);
    guidata(hObject, handles);
end

function play_button_Callback(hObject, ~, handles)
    str = hObject.String;
    if(strcmp(str, 'Play'))
        play_mult = str2double(handles.play_text.String);
        delay = round(1/30/play_mult, 3);
        tim = timer('ExecutionMode', 'fixedRate', 'BusyMode', 'drop', 'Period', delay,...
                    'TimerFcn', {@timer_callback, hObject});
        handles.timer = tim;
        set(handles.buttons.trace, 'Enable', 'off');
        set(handles.buttons.heatmap, 'Enable', 'off');
        set(handles.buttons.db, 'Enable', 'off');
        hObject.String = 'Stop';
        guidata(hObject, handles);
        start(tim);
    else
        stop(handles.timer);
        delete(handles.timer);
        set(handles.buttons.trace, 'Enable', 'on');
        set(handles.buttons.heatmap, 'Enable', 'on');
        set(handles.buttons.db, 'Enable', 'on');
        hObject.String = 'Play';
    end
end

function timer_callback(~, ~, hObject)
    handles = guidata(hObject);
    value = handles.slider.Value;
    handles.state.end = value;
    guidata(hObject, handles);
    handles.slider.Value = value + 1; % replot() is called inside
end

function show_image_button_Callback(hObject, ~, handles)
    if(~isfield(handles.state, 'tiff_hs'))
        for i = 1:handles.state.num_of_rats
            tiff_h = Coll_tiff_handler();
            tiff_h.parse_file();
            handles.state.tiff_hs(i) = tiff_h;
        end
    end
    state = handles.state;
    if(state.ImageOn)   % remove headImage, show marker
        set(handles.message_text, 'String', 'Rat image turned off');
        set(hObject, 'String', '<html>Show<br>image');        
    else % show image of the rat at the current location, remove the marker
        set(handles.message_text, 'String', 'Rat image turned off');
        set(hObject, 'String', '<html>Stop<br>image');
    end
    state.ImageOn = ~state.ImageOn;
    handles.state = state;
    handles = replot(handles);  % replot the image
    guidata(hObject, handles);    
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

%========================   custom (debug) function   ===========================

function Custom_button_Callback(~, ~, handles)
    global call_counter
    if(0)
        [points, c] = bin_traj2d(handles.state.rat1(:, 1), handles.state.rat1(:, 2), 50, handles.bg);
    end
    if(0)
    end
end


