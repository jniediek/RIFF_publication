function camera_parser_module_mat_to_pdf(db, out_folder)

% JN 2019-01-28 added saving in `out_folder`, made figures invisible
% Function camera_parser_module_mat_to_pdf generates graphical evaluation of the analysed data from
% the camera. The script produces two figures in .png format.
% Runtime: 4 sec

% Input:
%     db - struct - DB struct as created by the camera_parser_module_tif_to_mat.m

% Output:
%     [no output] - prints images to the screen and to the file.

% Example:
%     >> parsed_db = load('RIFF_s3_R1_1_camera_analyzed_data.mat');
%     >> camera_parser_module_mat_to_pdf(parsed_db);

plot_loc_heatmap(db, out_folder);
plot_traj(db, out_folder);
plot_integrity_statists_of_image_stream(db, out_folder)
end

function plot_loc_heatmap(db, out_folder)

% Function plot_loc_heatmap plots a heat map of the rat location along the whole experiment.
%
% Input:
%     db - struct - DB struct as created by the camera_parser_module_tif_to_mat.m
%
% Output:
%     [no output] - prints images to the screen and to the file.

[data] = bin_traj2d(db.loc_arr(:, 1), db.loc_arr(:, 2), 50, db.bg_image);

h_f = figure('Position', [100, 400, 1443, 550], 'visible', 'off');
h_ax1 = subplot(1, 2, 1);
h_im = imshow(cat(3, db.bg_image, db.bg_image, db.bg_image), 'parent', h_ax1, 'InitialMagnification', 'fit');
hold(h_ax1, 'on');
h_l = scatter(h_ax1, data(:, 1), data(:, 2), 70, data(:, 3), 's', 'filled');
title(h_ax1, 'Heatmap of the location');
h_ax1.Visible = 'off';
h_ax1.Position = [0.05 h_ax1.Position(2) 0.4 h_ax1.Position(4)];

h_ax2 = subplot(1, 2, 2);
h_im = imshow(cat(3, db.bg_image, db.bg_image, db.bg_image), 'parent', h_ax2, 'InitialMagnification', 'fit');
hold(h_ax2, 'on');
h_l = scatter(h_ax2, data(:, 1), data(:, 2), 70, log(data(:, 3)), 's', 'filled');
title(h_ax2, 'Heatmap of the location - log');
prev_size = h_ax2.Position;
colorbar(h_ax2);
h_ax2.Visible = 'off';
h_ax2.Position = prev_size;
h_ax2.Position = [0.55 h_ax2.Position(2) 0.4 h_ax2.Position(4)];

fname = fullfile(out_folder, 'camera_heatmap.png');
print(h_f, fname, '-dpng', '-r300');
close(h_f);

end

function plot_traj(db, out_folder)

% Function plot_traj plots a heat map of the rat location along the whole experiment.
%
% Input:
%     db - struct - DB struct as created by the camera_parser_module_tif_to_mat.m
%
% Output:
%     [no output] - prints images to the screen and to the file.
% dataidx = {1:1e5; 7e5:1e6; 1.1e6:length(db.loc_arr(:, 1)); 1:length(db.loc_arr(:, 1))};
% for ii = 1:4
h_f = figure('Position', [100, 100, 1090, 820], 'Visible', 'on');
h_ax = axes(h_f);
im_n = size(db.loc_arr, 1);
h_im = imshow(cat(3, db.bg_image, db.bg_image, db.bg_image), 'parent', h_ax, 'InitialMagnification', 'fit');
hold(h_ax, 'on');
h_ax.Visible = 'off';
h_line = scatter(db.loc_arr(:, 1), db.loc_arr(:, 2), 30, 1:length(db.loc_arr(:, 1)), 'filled');

locs = [[1 640-99 1 640-99]; [1 1 480-99 480-99]]';
im_inds = [1 floor(im_n/4) floor(2*im_n/4) floor(3*im_n/4)];
if db.image_arr
    for i = 1:4
        im_ind = im_inds(i);
        h_dot = scatter(db.loc_arr(im_ind, 1), db.loc_arr(im_ind, 2), 30, 'MarkerFaceColor', 'r',...
            'MarkerEdgeColor', 'r', 'MarkerFaceAlpha', 0.1 + 0.2*i);
        text(db.loc_arr(im_ind, 1)+10, db.loc_arr(im_ind, 2), num2str(i), 'Color', 'red', ...
            'FontSize', 12, 'FontWeight', 'bold');
        im = db.image_arr(1:2:end, 1:2:end, im_ind);
        im_start = locs(i, :);
        im_end = im_start+99;
        h_im.CData(im_start(2):im_end(2), im_start(1):im_end(1), :) = cat(3, im, im, im);
        text(im_start(1) + 50, im_start(2), num2str(i), 'Color', 'red', 'FontSize', 12, ...
            'FontWeight', 'bold');
    end
end
prev_size = h_ax.Position;
colorbar(h_ax);
h_ax.Position = prev_size;
h_ax.Visible = 'off';
FPS = 30;
exp_len_hours = round(size(db.loc_arr, 1) / FPS / 60 / 60, 2);
title(['Rat trajectory - Experiment length: ' num2str(exp_len_hours)]);
h_ax.Position = [0.05 0.05 0.88 0.9];

fname = fullfile(out_folder, 'camera_trajectory.png');
print(h_f, fname, '-dpng', '-r300');
close(h_f);
end
% end

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
% Turned all negative values of x and y to zeros to be able to plot them as indexes (Ana, 240119)
x(x < 0) = 0;
y(y < 0) = 0;
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

function [h_f] = plot_extracted_traj(loc_arr, bg_image)
% Function plot_extracted_traj plots the trajectories of the whole experiment and plots them with
% chronological coloring
%
% Inputs:
%     loc_arr - (Nx2 matrix) - [X, Y] locations of the rat
%     bg_image - (640 x 480, uint8) - background image of the RIFF
%
% Outputs:
%     h_fig - Handles to the figure
%
% Example:
%     >> h_fog = plot_extracted_traj(loc_arr)


h_f = figure();
h_ax = axes(h_f);
h_im = imshow(cat(3, bg_image, bg_image, bg_image), 'parent', h_ax);
hold(h_ax, 'on');
h_line = plot(h_ax, loc_arr(:, 1), loc_arr(:, 2), 'w');
tightfig(h_f);
h_line.Color(4) = 0.2;
h_scatter = scatter(h_ax, loc_arr(:, 1), loc_arr(:, 2), 10, 1:length(loc_arr(:, 2)), 'filled');
colorbar(h_ax);
end

function plot_integrity_statists_of_image_stream(camera_db, out_folder)
                                     
% Function plot_integrity_statists_of_image_stream checks the integrity of the image stream.
% it saves the results into output folder
% 
% Inputs:
%     out_folder - Folder where the images are to be stored.
%     camera_db - struct as produced by the 'camera_parser_module_tif_to_mat'
%        -----  The used fields of the struct: --------------
%     LED_arr - (1xN array) - array of averages of the LED pixels (upper-left rectangle of each image)
%     SNR_camera_trigs - (1xM array) - times of the strobe triggers as recorded by the SNR, in its time units
%     image_arr - (200x200xN matrix) - Image array
%     loc_arr - (2xN matrix) - Location of the rat on the binned image, as saved in the .txt file
%     stack_size - (1xN matrix) - Stack sizes during the image acquisition, as saved in the .txt file
%     driver_clock - (1xN matrix) - Driver clock during the acquisition, as saved in the .txt file
    
    LED_arr          = camera_db.LED_arr;
    SNR_camera_trigs = camera_db.SNR_camera_trigs;
    image_arr        = camera_db.image_arr;
    loc_arr          = camera_db.loc_arr;
    stack_size       = camera_db.stack_size;
    driver_clock     = camera_db.driver_clock;
    rat_found_arr    = camera_db.rat_found_arr;
    
    % ======= Re-create the holes in data when the rat was not tracked, for analytics purpose only ====
    loc_arr(rat_found_arr == 0, :) = -1;
    image_arr(:, :, rat_found_arr == 0) = 0;
    
    % ======= plot the inter-LED times ========
    LED_bin = LED_arr > (median(LED_arr)*2); % Adaptive treshold for LED identification
    LED_on = [0 diff(LED_bin) > 0.5];
    LED_on_inds = find(LED_on);
    diff_LEDS = diff(LED_on_inds);
    h_f = figure();
    h_ax = subplot(3, 3, 1);
    plot(h_ax, diff_LEDS, '.');
    xlabel(h_ax, 'LED on event index');
    ylabel(h_ax, 'Inter-LED-on distance (frames)'); 
    xlim(h_ax, [-1e2 length(diff_LEDS) + 1e2]);
    ylim(h_ax, [-2 40]);
    
    bad_events = diff_LEDS < 30;
    hold(h_ax, 'on');
    plot(find(bad_events), diff_LEDS(bad_events), 'ro', 'MarkerSize', 10);
    if sum(bad_events) > 0
        legend(h_ax, {'LED-on event', '<30FPS events'});
    end
    
    title(h_ax, ['inter-LED times. Bad events: ' num2str(sum(bad_events))...
                 '. |triggers| = ' num2str(length(LED_on_inds))]);
    
    % ====== Plot the sorted and unsorted inter-LED times  =========
    
    thr = 2*median(LED_arr);
    
    h_ax1 = subplot(3, 3, 2);
    plot(h_ax1, sort(LED_arr), '.', 'MarkerSize', 10);
    xlabel(h_ax1, 'Frames - sorted by LED');
    ylabel(h_ax1, 'Luminance'); 
    title(h_ax1, 'LED luminance - sorted');
    grid(h_ax1, 'on');
    xlim(h_ax1, [-1e4 length(LED_arr) + 1e4]);
    ylim(h_ax1, [min(LED_arr)-10 max(LED_arr)+10]);
    hold(h_ax1, 'on');
    plot(h_ax1, [0 length(LED_arr)], [thr thr], '--', 'Color', [0.3 0.3 0.3]);
    
    h_ax2 = subplot(3, 3, 3);
    plot(h_ax2, LED_arr, '.', 'MarkerSize', 10);
    xlabel(h_ax2, 'Frame index');
    ylabel(h_ax2, 'Luminance'); 
    title(h_ax2, 'LED luminance');
    grid(h_ax2, 'on');
    xlim(h_ax2, [-1e4 length(LED_arr) + 1e4]);
    ylim(h_ax2, [min(LED_arr)-10 max(LED_arr)+10]);
    
    % ====== Plot histogram of the LED values  ==========
    h_ax = subplot(3, 3, 4);
    histogram(h_ax, LED_arr, 100);
    grid(h_ax, 'minor');
    set(h_f, 'Position', [h_f.Position(1:2) 500 300]);
    xlabel(h_ax, 'LED luminance');
    ylabel(h_ax, 'Counts'); 
    title(h_ax, 'Histogram of the LED luminance');
    LED_counts_txt = sprintf('On:     %1$6d\nOff:     %2$6d\nBlank:    %3$6d\nTotal LEDS: %4$6d', ...
                     sum(LED_arr > 50), ...
                     sum(LED_arr < 50 & LED_arr > 3), ...
                     sum(LED_arr < 3), ...
                     length(LED_arr));
    h_text = text(h_ax, 50, 4e4, LED_counts_txt);
    hold(h_ax, 'on');
    plot(h_ax, [thr thr], [0 length(LED_arr)/2], '--', 'Color', [0.3 0.3 0.3]);
    
    set(h_f, 'Position', [2020 70 1650 1021]);
    
    % ==== Plot the mean frame luminance ===========
    
    h_ax = subplot(3, 3, 5);
    temp = mean(image_arr(20:end, 20:end, :), 1);
    im_means = squeeze(mean(temp, 2));
    plot(im_means, '.', 'MarkerSize', 10);
    xlabel(h_ax, 'Frame index');
    ylabel(h_ax, 'Luminance'); 
    title(h_ax, ['Lumincance of the whole frame. Black frames: ' num2str(sum(im_means < 5))]);
    xlim(h_ax, [-1e4 length(im_means) + 1e4]);
    ylim(h_ax, [-5 max(im_means)+5]);
    
    % ==== Plot the trajectcory ===============

    h_ax = subplot(3, 3, 6);
    plot(h_ax, loc_arr(:, 1), loc_arr(:, 2));
    daspect([1 1 1]);
    title(h_ax, 'Trajectory of the rat');
    
    % ==== Driver clock ===============
    
    h_ax = subplot(3, 3, 7);
    d_clock = diff(driver_clock);
    plot(d_clock, '.', 'MarkerSize', 10);
    xlabel(h_ax, 'Frame index');
    ylabel(h_ax, 'Inter-frame driver time (sec)'); 
    title(h_ax, ['Inter-frame driver time']);
    xlim(h_ax, [-1e4 length(d_clock) + 1e4]);
%     ylim(h_ax, [-5 max(d_clock)+5]);

    % ==== Image stack ===============
    
    h_ax = subplot(3, 3, 8);
    plot(stack_size, '.', 'MarkerSize', 10);
    xlabel(h_ax, 'Frame index');
    ylabel(h_ax, 'Stack size'); 
    title(h_ax, ['Stack sizes']);
    xlim(h_ax, [-1e4 length(stack_size) + 1e4]);
    ylim(h_ax, [-1 max(stack_size)+3]);
    hold(h_ax, 'on');
    bad_events = stack_size > 6;
    plot(h_ax, find(bad_events), stack_size(bad_events), 'ro', 'MarkerSize', 10);
    legend({'Stack size', '|stack| > 6'});
    
    % ==== SNR triggers =======
    
    h_ax = subplot(3, 3, 9);
    d_trigs = diff(SNR_camera_trigs);
    plot(d_trigs, '.', 'MarkerSize', 10);
    xlabel(h_ax, 'Trig index');
    ylabel(h_ax, 'inter-trig SNR time (sec)'); 
    title(h_ax, ['inter-SNR triggers. Number of triggers: ' num2str(length(SNR_camera_trigs))]);
    xlim(h_ax, [-100 length(d_trigs) + 100]);
%     ylim(h_ax, [-1 max(stack_size)+3]);
    
    % ===== Save the file to the output folder ===========
    fname = fullfile(out_folder, 'camera_integrity_statists.png');
    print(h_f, fname, '-dpng', '-r450');
    close(h_f);
end