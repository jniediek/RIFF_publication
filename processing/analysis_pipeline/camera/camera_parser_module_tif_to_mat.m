function camera_db = camera_parser_module_tif_to_mat(p_name, ...
    f_name, snr_times, out_dir, experimenter, do_images) %[image_arr, LED_arr, loc_arr, bg_image]
% Function integrator_script creates linear set of rects out of the raw .tif images as produced by
% the RatTracker, RIFF.

% Modified by Ana 240119 to work with general input files and the snr_times table
% Modified by JN 2019-01-28 again, with snr_times in a different folder
% than output of this script

% The script assumes that all the consecutive .tifs of the experiment are placed in the same folder,
% and named by the original script.
% The script runs automatic integrity tests
%
% Inputs:
%     p-name - folder where the camera files are
%     f-name - first .tiff file name
%     outdir - directory of previous outputs, most important of which is the snr_times file
%
% Output:
%     db-file_name - the file name of the file containing the following matrices
%     image_arr - (200 x 200 x N, uint8) - A set of rects as extracted from the whole experiment
%     LED_arr - (N x 1, float) - Mean LED values corresponding to each of the extracted frames
%     loc_arr - (N x 2, int) - [X, Y] locations corresponding to the extracted images
%     bg_image - (640 x 480 uint8) - the background of the experiment
%
% Example:
%     >> [image_arr, LED_arr, loc_arr, bg_image] = integrator_script();

NUM_RECTS_HORZ = 5;
RECT_WIDTH_PIX = 200;
if experimenter == 'nightRIFF'  % For nightRIFF, compress images to [50x50]
    IM_REDUCE_FACT = 4;  %AK|21/05/19: Reduce final image size from [200x200] to [200x200]/fact
else
    IM_REDUCE_FACT = 1; %AK|21/05/19: Consider changing to '2'
end

tic;
exp_variables = textscan(f_name, 'RIFF_s%d_R%d_%d.tif');
exp_no = exp_variables{1};

bg_name = fullfile(p_name, ['bg_s' num2str(exp_no) '.tif']);
log_name = fullfile(p_name, ['RIFF_s' num2str(exp_no) '.txt']);
tiff_name = fullfile(p_name, f_name);

% Check that the files can be accessed in FS
if (~exist(bg_name, 'file')) ||(~exist(log_name, 'file')) || (~exist(tiff_name, 'file'))
    assert(false, ['No camera files > ' tiff_name ' was found! Check path definition...']);
end

% JN 2019-01-28 we now get the SNR timestamps as an argument
SNR_camera_trigs_unfixed = snr_times.Time(snr_times.EventType == 'cam');

% Fix gaps in SNR_cam_t by interpolating missing trigs. Fixes the missing trig at 03:00
SNR_camera_trigs = interpolate_missing_SNR_trigs(SNR_camera_trigs_unfixed);

%     disp(['==> Time (1): ' num2str(round(toc, 3))]); tic; % 47 sec

[loc_arr, stack_size, driver_clock] = read_txt(log_name);
%     disp(['==> Time (2): ' num2str(round(toc, 3))]); tic; % 0.9 sec

bg_image = get_bg_image(bg_name);
%     disp(['==> Time (3): ' num2str(round(toc, 3))]); tic; % 0.01 sec
%[SNR_camera_trigs, SNR_f_name] = get_trigs_from_SNR(out_dir);
%     disp(['==> Time (4): ' num2str(round(toc, 3))]); tic; % 0.01 sec


%     disp(['==> Time (5): ' num2str(round(toc, 3))]); tic; % 0.01 sec
%     [head_dir_deg, body_dir_deg] = extract_body_head_directions(image_arr(1:2:end, 1:2:end, :));
%     disp(['==> Time (6): ' num2str(round(toc, 3))]); tic; % 101.1 sec
                                     
% [test_results, integrity_test_ok] = run_integrity_test(image_arr, LED_arr, loc_arr, bg_image,...
%     SNR_camera_trigs, t_frames, LED_on_inds, LED_on);
%     disp(['==> Time (7): ' num2str(round(toc, 3))]); tic; % 0.008 sec
if do_images
    [image_arr, LED_arr] = ...
    get_images_from_tifs(tiff_name, NUM_RECTS_HORZ, RECT_WIDTH_PIX, IM_REDUCE_FACT);
    [image_arr, loc_arr, rat_found_arr] = fill_in_data_for_black_frames(image_arr, loc_arr);  % Fix holes in data when the rat was not located
    [t_frames, LED_on_inds, LED_on] = ...
    interpolate_frames_to_SNR_times(SNR_camera_trigs, LED_arr);
    [data_f_name, ~, camera_db] = ...
        save_data_to_mat(bg_name, log_name, tiff_name, image_arr, ...
        LED_arr, loc_arr, bg_image, t_frames, LED_on_inds, ...
        [0], [0], out_dir, stack_size, driver_clock, SNR_camera_trigs, rat_found_arr);
else
    [~, loc_arr, rat_found_arr] = fill_in_data_for_black_frames([], loc_arr);
    [data_f_name, ~, camera_db] = ...
        save_data_to_mat(bg_name, log_name, tiff_name, [0], ...
        [0], loc_arr, bg_image, [0], [0], ...
        [0], [0], out_dir, stack_size, driver_clock, SNR_camera_trigs, rat_found_arr);
end

%head_dir_deg, body_dir_deg,
%     disp(['==> Time (8): ' num2str(round(toc, 3))]); tic; % 44.2 sec

% log_info(data_f_name, p_name, f_name, bg_name, log_name, SNR_f_name, test_results, integrity_test_ok);
%     disp(['==> Time (9): ' num2str(round(toc, 3))]); tic; % 0.011 sec
end

function [image_arr, loc_arr, rat_found_arr] = fill_in_data_for_black_frames(image_arr, loc_arr)

    % The function fill_in_data_for_black_frames fills in the image and location data at times
    % when the rat was not recognized, and the data filled with default values.
    % The default values are [-1, -1] for position and black frames as images.
    % The filling methods are interpolation of the position using the two known position around the 
    % unknown area, and copying last known image.
    % 
    % Inputs:
    %     image_arr - (KxKxN uint8) - Image stream, with black images that stand for untracked frames.
    %     loc_arr - (Nx2 scalars) - Position of the rat, with [-1, -1] values for untracked times.
    % 
    % Output:
    %     image_arr - (KxKxN uint8) - Image stream, with filled images
    %     loc_arr - (Nx2 scalars) - -- //-- filled positions
    %     rat_found_arr - (Nx1 binary) - 1 for original data, 0 for filled by this method

    do_fill_images = ~isempty(image_arr);
    len_arr = max(size(loc_arr));
    rat_found_arr = ones(len_arr, 1);
    i = 2; % Assume here that the first frame is tracked correctly (might backfire one day :\) 
    while i <= len_arr
        if loc_arr(i, 1) == -1  % Loc is [-1, -1] for all untracked frames
            first_pivot_ind = i-1;  
            rat_found_arr(i) = 0;
            for j = (i+1):len_arr  % Find the next filled image
                if loc_arr(j, 1) ~= -1
                    second_pivot_ind = j;
                    loc_arr = interp_locs(loc_arr, first_pivot_ind, second_pivot_ind);
                    if do_fill_images
                        n_frames = length(i:(second_pivot_ind-1)); % The correct image has to be multiplied
                        inflated_images = repmat(image_arr(:, :, first_pivot_ind), [1, 1, n_frames]);
                        image_arr(:, :, i:(second_pivot_ind-1)) = inflated_images; 
                    end
                    i = j + 1;
                    break;  % Current fill-in is finished
                else
                    rat_found_arr(j) = 0;
                end
            end
            
            % Corner case - rat not found in last N frames, so last frame is loc_arr=[-1, -1] and second_pivot never found
            if rat_found_arr(end) == 0
                for ci = 1:2
                    loc_arr(first_pivot_ind:end, ci) = loc_arr(first_pivot_ind, ci);  % Copy last known loc to the rest of the locations 
                end
                n_frames = length(i:len_arr);  
                inflated_images = repmat(image_arr(:, :, first_pivot_ind), [1, 1, n_frames]);
                image_arr(:, :, i:len_arr) = inflated_images;  % Copy last rat image to all the following locs
                i = len_arr + 1;  % Exits the main while loop
            end
        else
            i = i + 1;
        end
    end
end

function loc_arr = interp_locs(loc_arr, piv1_ind, piv2_ind)

    % Function interp_locs fills-in the default [-1 -1] locations that stand for untracked frames of the rat.
    % The method fills in a single hole in the data, and is intended to be called once per each hole.
    % The filling method is linear interpolation of rat position using two known positions, the 'pivots'
    % Those positions are picked by finding the last known position before the untracked frame and first known
    % position after the untracked frame.  The frames (+ for tracked) [+ + + - - - + + + ]
    %                                        The chosen pivots             ^       ^
    % 
    % Inputs:
    %     loc_arr - (Nx1 scalars) - The position vector of the rat as read from the .txt. [-1, -1] stand for untracked frame
    %     piv1_ind - (scalar) - The index of the first pivot
    %     piv2_ind - (scalar) - -- // --   Second pivot
    % 
    % Output:
    %     loc_arr - (Nx1 scalars) - Position array with interpolated data at the designated indexes


    loc1 = loc_arr(piv1_ind, :);  % Get last known loc before the gap
    loc2 = loc_arr(piv2_ind, :);  % Get first known loc after the gap
    new_x_locs = round(interp1([piv1_ind, piv2_ind], [loc1(1), loc2(1)], piv1_ind:piv2_ind));   % Interp x values between the two known locs
    new_y_locs = round(interp1([piv1_ind, piv2_ind], [loc1(2), loc2(2)], piv1_ind:piv2_ind));
    loc_arr(piv1_ind:piv2_ind, :) = [new_x_locs' new_y_locs'];  % Paste the interped values into the array
end

function log_info(data_f_name, path_name, tif_name, bg_name, log_name, test_results, integrity_test_ok)

% JN 2019-01-28 SNR_f_name argument removed
%    'SNR_f_name', SNR_f_name, ...
% Function that logs the details of the parsing to a log file, on the disk.

db = struct('bg_name', bg_name, ...
    'log_name', log_name, ...
    'path_name', path_name, ...
    'tif_name', tif_name, ...
    'integrity_test_ok', num2str(integrity_test_ok), ...
    'data_f_name', data_f_name, ...
    'creation_time', string(datetime));

fields = fieldnames(db);
log_f_name = [data_f_name(1:end-25) '_analysis_log.txt'];
txt_handle = fopen(log_f_name, 'w');
for i = 1:length(fields)
    curr_field_name = fields{i};
    curr_field_val = db.(curr_field_name);
    fprintf(txt_handle, '%s\t\t%s\r\n', curr_field_name, curr_field_val);
end
fields_test = fieldnames(test_results);
for i = 1:length(fields_test)
    curr_field_name = fields_test{i};
    curr_field_val = num2str(test_results.(curr_field_name));
    fprintf(txt_handle, '%s\t\t%s\r\n', curr_field_name, curr_field_val);
end
fclose(txt_handle);
disp(['=== Saved logfile ' log_f_name '. Analysis ran in ' num2str(round(toc, 2))...
    ' seconds. Integrity test: ' num2str(integrity_test_ok)]);
end

function [data_f_name, db_file_name, db_struct] = save_data_to_mat(bg_name, log_name, tiff_name, image_arr, LED_arr, loc_arr, bg_image, ...
    t_frames, LED_on_inds, test_results, integrity_test_ok, out_dir, ...
    stack_size, driver_clock, SNR_camera_trigs, rat_found_arr) % head_dir_deg, body_dir_deg,

% Function that saves the data in an uncompressed .mat format

db_struct = struct('bg_name',     bg_name, ...
    'SNR_camera_trigs', SNR_camera_trigs, ...
    'log_name',     log_name, ...
    'tiff_name',    tiff_name, ...
    'image_arr',    image_arr, ...
    'LED_arr',      LED_arr, ...
    'loc_arr',      loc_arr, ...
    'bg_image',     bg_image, ...
    't_frames',     t_frames, ...
    'LED_on_inds',  LED_on_inds, ...
    'test_results', test_results, ...
    'creation_date', string(datetime), ...
    'integrity_test_ok', integrity_test_ok, ...
    'stack_size', stack_size, ...
    'driver_clock', driver_clock, ...
    'rat_found_arr', rat_found_arr);
%                 'head_dir_deg', head_dir_deg, ...
%                 'body_dir_deg', body_dir_deg, ...
[~,file_name, ~] = fileparts(tiff_name);
data_f_name = [file_name '_camera_analyzed_data.mat'];  % Name pattern: 'RIFF_s1_R2_10.tif'   -> 's1_R2_10_camera_analyzed_data.mat'
db_file_name = fullfile(out_dir, data_f_name);
if ispc
    save(db_file_name, '-struct', 'db_struct', '-v7.3', '-nocompression'); % raw = 30sec = 4.7GB, compressed = 120sec = 4GB
else
    save(db_file_name, '-struct', 'db_struct', '-v7.3'); % -nocompression broken on unix MATLAB 2018b (?)
end
disp(['=== Saved file ' data_f_name '. Analysis ran in ' num2str(round(toc, 2))...
    ' seconds. Integrity test: ' num2str(integrity_test_ok)]);
end

function [degs_head, degs_body] = extract_body_head_directions(image_arr)

% Function that predicts the direction of the head and body of each of the images.

net_head = load('CNN_head.mat', '-mat');
net_head = net_head.net_head;
net_body = load('CNN_body.mat', '-mat');
net_body = net_body.net_ass;

pred_vals_head = net_head.predict(reshape(image_arr, [100, 100, 1, size(image_arr, 3)]));
pred_vals_body = net_body.predict(reshape(image_arr, [100, 100, 1, size(image_arr, 3)]));
dir_vec_head = convert_softmax_to_weights(pred_vals_head);
dir_vec_body = convert_softmax_to_weights(pred_vals_body);
degs_head = convert_weights_to_degs(dir_vec_head);
degs_body = convert_weights_to_degs(dir_vec_body);
%     h_f = figure();
%     h_ax = axes(h_f);
%     h1 = plot(h_ax, degs_head, '.');
%     hold(h_ax, 'on');
%     h2 = plot(h_ax, degs_head, 'k');
%     h2.Color(4) = 0.3;
%     h3 = plot(h_ax, degs_body, '.');
%     h4 = plot(h_ax, degs_body, 'k');
%     h4.Color(4) = 0.3;
%     legend(h_ax, [h1, h3], {'head','body'});
%     ylim(h_ax, [-5, 365]);
%     xlabel(h_ax, 'Time');
%     ylabel(h_ax, 'Direction (deg)');
%     title(h_ax, 'Head and body directions during the experiment');

% figure;
% histogram(wrapTo180(degs_head - degs_body), 100)
% err_percents = length(error_inds)/length(degs_body)*100;
% figure;
% montage(image_arr(1:2:end, 1:2:end, error_inds(1:25)))
% figure;
% histogram(degs_body, 100)
% hold on;
% histogram(degs_head, 100)

end

function degs = convert_weights_to_degs(weights)

% Helper function to reconstruct a continuous angle from the 1x8 directivity softmax output

rad_vec = deg2rad((0:7)*45);
x_vals = weights*cos(rad_vec');
y_vals = weights*sin(rad_vec');
degs = wrapTo360(rad2deg(atan2(y_vals, x_vals)));
end

function weights = convert_softmax_to_weights(pred_vals)
% Heuristic to boost the softmax output to a weights s.t. med-low probs won't be squached to 0
temp = pred_vals .^ (1/4);
weights = temp ./ sum(temp, 2);
end

function [t_frames, LED_on_inds, LED_on] = interpolate_frames_to_SNR_times(SNR_camera_trigs, LED_arr)

% Calculate the SNR times of the frames, based on the LED values that are stored in the image
% and the corresponding LED triggers of the SNR. The triggers are expected to happen at 1fps,
% thus the frame times are extrapulated based on the SNR triggers.

LED_bin = LED_arr > (median(LED_arr)*2); % Adaptive treshold for LED identification
LED_bin = fix_swapped_frames(LED_bin);  % Locate swapped LED patterns - [... 0 0 1 1 1 1 0 1 0 0 ...]
LED_on = [0 diff(LED_bin) > 0.5];
LED_on_inds = find(LED_on);

if (length(SNR_camera_trigs) - 1 == length(LED_on_inds))        % SNR might have excessive last trigger. See explanation line below.
    % Last strobe was shot after 'stop recording' pressed, discarding the last batch of images. No frames but SNR trigger added :\
    SNR_camera_trigs = SNR_camera_trigs(1:end-1);
    disp('===   Image processing: SNR had one excessive trigger - last trigger removed   ===');
end

if length(LED_on_inds) > length(SNR_camera_trigs)  % Might happen in case of RX8 shutdown before RatTracker (due to early Maestro switch-off)
    disp('>>>>>   Image processing: Unfixable inconsistenty between SNR and LED triggers. Clipping LEDs to avoid crushing...  <<<<');
    LED_on_inds = LED_on_inds(1:length(SNR_camera_trigs));
    LED_on((LED_on_inds(end)+6):end) = false;
end

if (length(SNR_camera_trigs) > length(LED_on_inds) + 1)        % Case when Rat_tracker stack overflow but the session goes on
    SNR_camera_trigs = SNR_camera_trigs(1:length(LED_on_inds));
    disp(['===   Image processing: SNR had ' num2str(length(LED_on_inds) - length(SNR_camera_trigs)) ...
    ' excessive trigger - last triggers removed   ===']);
end

% Interpolate LED times to actually recieved images - it preserves <30FPS sections
% for those times where frames were lost in transmition. Those don't appear in .tifs nor in .txt,
% but the gaps can be checked by inter_LED counts, that sometimes drop below 30.
x_interp = 1:length(LED_bin);
t_frames = interp1(LED_on_inds, SNR_camera_trigs, x_interp, 'linear', 'extrap');  % Removed 'spline' interpolcation since it creates filter ringing

%     h_f = figure();    % Plot the
%     h_ax = axes(h_f);
%     plot(h_ax, t_frames, t_frames * 0 + 1, 'r.');
%     hold(h_ax, 'on');
%     plot(h_ax, SNR_camera_trigs, SNR_camera_trigs * 0 + 1, 'go')
%     legend({'t_cam_frames', 't_cam_trigs'}, 'Interpreter', 'none')
end

function LED_bin_fixed = fix_swapped_frames(LED_bin)

% Function fix_swapped_frames looks for swapped frames, where one LED frame was swapped with preceding
% or trailing off-LED frame, producing LED patterns [... 0 0 1 0 1 1 1 1 0 0 ...] or [... 0 0 1 1 1 1 0 1 0 0 ...]
% instead of the healthy [... 0 0 1 1 1 1 1 0 0 ...]. This artifacts is potentially happens due to
% frame buffer errors of the ImageSource camera (low level driver instability).
% 
% Inputs:
%     LED_bin - (1xN) vector - Binary LED-on indications. N = number of frames
% 
% Output:
%     LED_bin_fixed - (1xN) vector - Indexes of the LED-on frames, with fixed artifact

    LED_bin_bp = double(LED_bin);
    LED_bin_bp(LED_bin_bp == 0) = -1;
        
    bad_pat1 = [1 1 1 1 -1 1];
    bad_pat2 = [1 -1 1 1 1 1];
    
    bad_part1_fix = [1 1 1 1 1 0];
    bad_part2_fix = [0 1 1 1 1 1];
   
    resp1 = conv(LED_bin_bp, flip(bad_pat1));
    resp1_bin = resp1(length(bad_pat1):end) == length(bad_pat1);
    resp1_inds = find(resp1_bin);
    n_bads1 = length(resp1_inds);
    
    resp2 = conv(LED_bin_bp, flip(bad_pat2));
    resp2_bin = resp2(length(bad_pat2):end) == length(bad_pat2);
    resp2_inds = find(resp2_bin);
    n_bads2 = length(resp2_inds);

    LED_bin_fixed = LED_bin;
    
    for i = 1:n_bads1
        LED_bin_fixed(resp1_inds(i):(resp1_inds(i) + length(bad_part1_fix) - 1)) = bad_part1_fix;
    end
    
    for i = 1:n_bads2
        LED_bin_fixed(resp2_inds(i):(resp2_inds(i) + length(bad_part2_fix) - 1)) = bad_part2_fix;
    end
    
    if n_bads1 > 0 || n_bads2 > 0
        disp(['===  Image processing: swapped images detected and fixed. Counts: `LEDS-101111` -> ' ...
             num2str(n_bads1) ' , `LEDS-111101` -> ' num2str(n_bads2)]);
    end
end

function [test_results, integrity_test_ok] = run_integrity_test(image_arr, LED_arr, loc_arr, bg_image, SNR_camera_trigs,...
    t_frames, LED_on_inds, LED_on)

% Function that runs sanity checks along the produced data, and creates a test summary + one
% global test boolean (pass/fail)

% Check dimentions of background image
[h, w] = size(bg_image);
bg_size_test_ok = (h == 480) && (w == 640);
test_results.bg_size_test_ok = bg_size_test_ok;

% Check dimentions of rects
[h, w, n] = size(image_arr);
rect_size_test_ok = (h == 200) && (w == 200);
test_results.rect_size_test_ok = rect_size_test_ok;

% Compare number of triggers of SNR_camera and LEDs
trigs_num_after_fix_test_ok = length(SNR_camera_trigs) == length(LED_on_inds);
test_results.trigs_num_after_fix_test_ok = trigs_num_after_fix_test_ok;


% Check if swapped frames were found and corrected during the analysis
LED_bin = LED_arr > 2*(median(LED_arr));
LED_on_unfixed = [0 diff(LED_bin) > 0.5];
LED_on_inds_unfixed = find(LED_on_unfixed);
swapped_frames_found = length(LED_on_inds_unfixed) > length(LED_on_inds);
test_results.swapped_frames_found = swapped_frames_found;

% Check that the LED was lit for exactly 5 consecutive frames = 150 ms
LED_bin = LED_arr > 2*(median(LED_arr));
LED_off = [0 diff(LED_bin) < -0.5];
LED_off_inds = find(LED_off);
LED_on = [0 diff(LED_bin) > 0.5];
LED_on_inds = find(LED_on);
consec_led_counts = unique(LED_off_inds - LED_on_inds);
five_LEDs_test_ok = (length(consec_led_counts) == 1) && (consec_led_counts == 5);
test_results.five_LEDs_test_ok = five_LEDs_test_ok;

% Check 30 frames per sec
frame_per_sec = unique(diff(LED_on_inds));
thirty_FPS_test_ok = (length(frame_per_sec) == 1) && (frame_per_sec == 30);
test_results.thirty_FPS_test_ok = thirty_FPS_test_ok;

% Generated frame timings corresponds to frame number
frame_times_n_is_frames_n_test_ok = (length(t_frames) == n);
test_results.frame_times_n_is_frames_n_test_ok = frame_times_n_is_frames_n_test_ok;

integrity_test_ok = bg_size_test_ok && rect_size_test_ok && trigs_num_after_fix_test_ok && ...
    five_LEDs_test_ok && thirty_FPS_test_ok && frame_times_n_is_frames_n_test_ok && ...
    swapped_frames_found;
test_results.integrity_test_ok = integrity_test_ok;
end

function [image_arr, LED_arr] = get_images_from_tifs(full_name, NUM_RECTS_HORZ, RECT_WIDTH_PIX, ...
                                                     IM_REDUCE_FACT)

% Function get_images_from_tifs extract a set of rects from all the .tifs of a single experiment,
% based on the 'LED_WIDTH' that defines the number of omitted rects between. Empty (black) frames at the end of the last .tif are not taken
% into account (i.e. half full last collage).
% The function automatically locates all .tifs of the current experiment, assuming they are in the
% same dir.
%
% Inputs:
%     full_name - (OPTIONAL, full path, str) - Full path of the first .tif
%     NUM_RECTS_HORZ - (scalar) - Number of images in the collage. Normally the collages are 5x5
%     RECT_WIDTH_PIX - (scalar) - Number of pixels in a single rect image. Normally 200
%     IM_REDUCE_FACT - (scalar) - Binning factor, take each M pixel out of the rect.
%
% Outputs:
%     image_arr - (200 x 200 x N) - Set of all rects from the all .tifs of the experiment.
%     LED_arr   - (N x 1, float) - The corresponding mean LED values (without the white border)

if nargin == 0
    [file_name, file_dir] = uigetfile('*.tif', 'Select a Movie');
    full_name = [file_dir file_name];
end

file_names = get_all_file_names(full_name);
files_n = length(file_names);

% if startsWith(full_name, '\\argos')
%     temp_p_name = 'F:\[temp]\ARGOS_tifs';
%     disp(['=== Copying .tif files from: '  '===']);
%     wb = waitbar(0, 'Copying files before analysis...');
%     for i = 1:files_n
%         copyfile(file_names{i}, temp_p_name, 'f');
%         waitbar(i/files_n, wb);
%     end
%     delete(wb);
%     % Re-read the tif file names, from the local folder
%     file_parts = split(full_name, '\');
%     full_name = fullfile(temp_p_name, file_parts{end});
%     file_names = get_all_file_names(full_name);
% end

image_cell_arr = cell(1, files_n);
LED_cell_arr = cell(1, files_n);

parfor i = 1:files_n
    % create new file name and check it exists
    
    curr_file_name = file_names{i};
    
    % Extract all frames from the single tif
    [image_arr, LEDs_arr] = get_images_from_single_tiff(curr_file_name, NUM_RECTS_HORZ, ...
                                                        RECT_WIDTH_PIX, IM_REDUCE_FACT);
    image_cell_arr{i} = image_arr;
    LED_cell_arr{i} = LEDs_arr;
end

[image_cell_arr{end},LED_cell_arr{end}] = ...
    remove_last_black_frames_with_no_LED(image_cell_arr{end}, LED_cell_arr{end});

image_arr = cat(3, image_cell_arr{:});
LED_arr = [LED_cell_arr{:}];
end

function [p_name, f_name] = get_file_name()
[f_name, p_name] = uigetfile({'*.tif'}, 'Select the first .tif file | Argos');
if isequal(f_name,0) || isequal(p_name, 0)
    disp('Action canceled...');
    return;
else
    if(~exist(fullfile(p_name, f_name), 'file')) % Check that the files can be accessed in FS
        assert(false, ['No .tif file > ' f_name ' was found! Check path definition...']);
    end
end
end

function file_names = get_all_file_names(full_name)
file_n = 1;
file_names = {};
while true
    
    % create new file name and check it exists
    name_cropped = full_name(1:end-5);
    curr_file_name = [name_cropped num2str(file_n) '.tif'];
    if (~exist(curr_file_name, 'file'))
        break
    end
    file_names{end+1} = curr_file_name;
    file_n = file_n + 1;
end
end

function [image_arr, LEDs_arr] = get_images_from_single_tiff(file_name, NUM_RECTS_HORZ, RECT_WIDTH_PIX, ...
                                                             IM_REDUCE_FACT)
% Function get_images_from_single_tiff creates a linear array of rect images together with the LED value.
% All frames of the .tif files are present in the image_arr, including the preceeding frames before
% the first LED and with the last black frames that fill the last collage.
% The rect resolution might be reducing by the IM_REDUCE_FACT, to limit the over-night data volumes
%
% Inputs:
%     file_name    - (full path, str)  - Path to a single .tif file, used by imread()
%     NUM_RECTS_HORZ - (scalar) - Number of images in the collage. Normally the collages are 5x5
%     RECT_WIDTH_PIX - (scalar) - Number of pixels in a single rect image. Normally 200
%     IM_REDUCE_FACT - (scalar) - Binning factor, take each M pixel out of the rect.
%
% Outputs:
%     image_arr    - (200 x 200 x N matrix) - Matrix of all rects from the current .tif
%     LEDs_arr     - (1 x N float)  - Mean values of the LED areas, corresponding to the image_arr

num_of_rects = 0;

file_info = imfinfo(file_name);
collage_num = length(file_info);
tot_rect_num = ceil(collage_num*(NUM_RECTS_HORZ.^2));

% Create temporally long arrays
image_arr = zeros(RECT_WIDTH_PIX/IM_REDUCE_FACT, RECT_WIDTH_PIX/IM_REDUCE_FACT, tot_rect_num, 'uint8');
LEDs_arr = zeros(1, tot_rect_num);

for i = 1:collage_num
    curr_collage = imread(file_name, i, 'Info', file_info);
    [rects, LEDs] = get_subset_of_rects(curr_collage, NUM_RECTS_HORZ, RECT_WIDTH_PIX);  % Returns matrix (K,K,N),(1, N)
    curr_num_rects = length(LEDs);
    
    % Update the DBs
    if curr_num_rects > 0  % It might happen that there are no rects in that collage -
        start_ind = num_of_rects + 1;
        end_ind = num_of_rects + curr_num_rects;
        image_arr(:, :, start_ind:end_ind) = rects(1:IM_REDUCE_FACT:end, 1:IM_REDUCE_FACT:end, :);  % Sub-sample the images (night-riff)
        LEDs_arr(start_ind : end_ind) = LEDs;
        num_of_rects = num_of_rects + curr_num_rects;
    else
        break
    end
end

% Shorten the array to actual number of aquired rects and LEDs
image_arr = image_arr(:, :, 1:num_of_rects);
LEDs_arr = LEDs_arr(1:num_of_rects);

end

function [rect_arr, LED_arr] = get_subset_of_rects(curr_collage, NUM_RECTS_HORZ, RECT_WIDTH_PIX)
% Function get_subset_of_rects returns set of rects, extracted from a collage by the provided
% indexes.
%
% Inputs:
%     curr_collage - (1000 x 1000 matrix) - A single collage as saved in a single page of .tif, RIFF
%     rect_inds    - (N x 1 matrix, in {1...25})
%
% Outputs:
%     rect_arr - (200 x 200 x N matrix) - set of rectangles
%     LED_arr  - (N x 1 matrix) - mean values of the LED pixels, without the white rectangle
%
% Example:
%     >> [rect_arr, LED_arr] = get_subset_of_rects(curr_collage, rect_inds);

% Half-Vectorized extractrion of the rect. Could find a better way to transorm a collage into a
% list of rectangles.
num_rects_per_collage = NUM_RECTS_HORZ^2;
rect_arr = zeros(RECT_WIDTH_PIX, RECT_WIDTH_PIX, num_rects_per_collage, 'uint8');
for i = 1:NUM_RECTS_HORZ
    rect_arr(:, :, ((i-1)*NUM_RECTS_HORZ + 1):(i*NUM_RECTS_HORZ)) = ...
        reshape(curr_collage(((i-1)*RECT_WIDTH_PIX + 1):(i*RECT_WIDTH_PIX), :),...
        [RECT_WIDTH_PIX, RECT_WIDTH_PIX, NUM_RECTS_HORZ]);
end
LED_AREA = 3;
led_arr = 3:(2*LED_AREA+3);
LEDs_ims = rect_arr(led_arr, led_arr, :);
LED_arr = zeros(1, num_rects_per_collage);
for i = 1:num_rects_per_collage
    LED_arr(i) = mean2(LEDs_ims(:, :, i));
end
end

function [loc_arr, stack_size, driver_clock] = read_txt(file_name)
% Function read_txt reads the locations .txt file and returns the total number of registered frames
% and location per each frame.
%
% Inputs:
%     file_name - (string) - full path of the file
%
% Outputs:
%     loc_arr    - (Nx2 matrix of scalars) - [X, Y] locations as written in file
%     stack_size - (Nx1 matrix of scalars) - Size of the stack along the recording
%     driver_clock - (Nx1 matrix of scalars) - Driver clock of each image
%
% Run example:
%     >>  [loc_arr, num_images] = read_txt("C:\Users\Owner\Desktop\RIFF_s4.txt")

out = readtable(file_name, 'delimiter', 'comma', 'headerlines', 1);
loc_arr = [out.Var5, out.Var6];              % Extract last two columns - [x, y]
stack_size = out.Var4;
driver_clock = out.Var2;
end

function [bg_image]= get_bg_image(tiff_name)
% Function get_bg_image reads the background image. The name of the file is auto-generated based on
% the name of one of the collage tifs, provided as 'tiff_name'
%
% Inputs:
%     tiff_name - (full path, str) - full path to the background image.
%
% Outputs:
%     bg_image - (640 x 480 uint8) - background image of the whole RIFF
%
% Example:
%     >> [bg_image]= get_bg_image("C:\Users\Owner\Desktop\RIFF_s2_R1_1.tif")

bg_image = imread(tiff_name);
end