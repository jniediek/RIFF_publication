function [first_raw_f_name, f_names] = multiple_raw_NA_to_bin(origin_dir, is_new_layout, neural_mode)

    % Function multiple_raw_NA_to_bin prepares the binary files for the Kilosort2 run.
    % It reads sub-set of raw_??_??.mat files as produced by the integration pipeline,
    % and writes the contents to a single .bin file.
    %
    % Changes:
    %    13/02/2020 - Times are stored in a compressed form - not a single linear array. AK2020
    %    23/11/2020 - Added options for analysis of TBSI data. AP 231120
    % 
    %  Created by AlexKaz 2019

    tic;
    
    ks_dir_name = fullfile(origin_dir, '\ks_output');
    if isunix()
        ks_dir_name = fullfile(origin_dir, '/ks_output');
    end
    output_NA_name = 'NA_large.bin';
    output_ts_name = 'ts_large.mat';

    % === Get SNR times ====
    [f_names, f_inds] = get_raw_file_names_and_inds(origin_dir);
    
    % ==== Extract the data into the DB ====
    
    n_rel_files = length(f_names);
    NA_db = cell(1, n_rel_files);
    ts_db = cell(1, n_rel_files);
    ind_db = zeros(1, n_rel_files);
    noise_loc_arr = cell(1, n_rel_files);
    
    % === Find the sound channel - used by workers to annulate it
    if strcmp(neural_mode, 'deuteron')
        curr_db = load(fullfile(origin_dir, f_names{1}));
        sound_channel = identify_sound_channel(curr_db.data); % This requires extra loading of 1GB, will run only once -> can print the verdict
    else
        sound_channel = -1;
    end
    d_queue = parallel.pool.DataQueue;
%     h_wb = waitbar(0, 'Loading and processing raw_??_??.mat files: File No. 0');
%     afterEach(d_queue, @udpate_waitbar_parfor); 
%     wb_val = 1;

	for cur_f_ind = 1:n_rel_files
% 	parfor cur_f_ind = 1:n_rel_files
        
        % =========  Find raw NA files from behav. session and preproccess it ============
        
        curr_db = load(fullfile(origin_dir, f_names{cur_f_ind}));
        clear NA_data
        if strcmp(neural_mode, 'deuteron')
            NA_data = curr_db.data;
            ts_data = curr_db.starttimes_snr;
        elseif strcmp(neural_mode, 'tbsi')
            NA_data(:,[1:4,6:32]) = curr_db.data;
            ts_data = curr_db.timestamps_snr';
        else
            error('Neural mode not supported, please check you data!')
        end
        
%         [NA_data] = convert_NA_to_double_and_rescale(NA_data, false); % Don't rescale, do remain the maximal dynamic range
        if sound_channel > 0
            NA_data(:, sound_channel) = 2^15;
        elseif sound_channel == -1 && strcmp(neural_mode, 'tbsi') % should probably also check that there are only 31 channels
            NA_data(:, 5) = 2^15;
        end
        
        % === Reduce the mean of the other shank ===
        NA_data = double(NA_data) - 2^15;
        NA_data = mean_reduce_16x2_raw_data(NA_data, is_new_layout);
        
        % === Remove noisy parts ===
        if strcmp(neural_mode,'deuteron')
            [NA_data, noise_loc_arr{cur_f_ind}] = flatten_noise_areas(NA_data, false, neural_mode, curr_db.BitResolution);
        elseif strcmp(neural_mode,'tbsi')
            [NA_data, noise_loc_arr{cur_f_ind}] = flatten_noise_areas(NA_data, false, neural_mode, curr_db.BitResolution/curr_db.Gain);
        else
            error('Neural mode not supported, please check you data!')
        end
        NA_data = int16(NA_data);
        
		NA_db{cur_f_ind} = NA_data;
        ts_db{cur_f_ind} = ts_data;
        ind_db(cur_f_ind) = f_inds(cur_f_ind);
        send(d_queue, 777);
	end
    
%     delete(h_wb);
    
    % Make sure that the chronological order is not ruined by the parfor()
    [~, inds] = sort(ind_db, 'ascend');
    NA_db = NA_db(inds);
    ts_db = ts_db(inds);
        
    write_data_to_bin_file(NA_db, ks_dir_name, output_NA_name);
    write_ts_to_mat_file(ts_db, noise_loc_arr, ks_dir_name, output_ts_name);
    first_raw_f_name = fullfile(origin_dir, f_names{1});
    
    t_runtime = toc();
    disp(['=== raw NA files concatentated, denoised, mean-reduced and stored into .bin as int16in ' num2str(round(t_runtime, 1)) ' sec ===']);
    
%     function udpate_waitbar_parfor(~)
%         waitbar(wb_val/n_rel_files, h_wb, ['Loading and processing raw_??_??.mat files. ' num2str(wb_val) ' of ' num2str(n_rel_files)]);
%         wb_val = wb_val + 1;
%     end
end

function write_data_to_bin_file(NA_db, output_dir, output_name)

    % Function write_data_to_bin_file flushes the array of processed NA files into .bin file
    
    mkdir(output_dir);
    fidOut = fopen(fullfile(output_dir, output_name), 'w');
    h_wb = waitbar(0, 'Writing NA data on disk. File No.0');
    
    % == Save the NA data to bin file ===
    
    for i = 1:length(NA_db)
        fwrite(fidOut, NA_db{i}', 'int16');
        waitbar(i/length(NA_db), h_wb, ['Writing NA data on disk. File No.' num2str(i)]);
    end
    fclose(fidOut);
    delete(h_wb);
end

function write_ts_to_mat_file(ts_db, noise_loc_arr, output_dir, output_ts_name)
    
    % Function write_ts_to_mat_file flushes the timestamps and the relative locationg of the noise rmoval indices
    % of all the NA files to a single .mat file. 
    % The timestamps represent the starting time of DT2 files, in SNR time units.
    % No other timestamps are required since DT2 files have identical structure of 262144 samples
    % gathered at 32KHz.
    
    SNR_timestamps_start_dt2 = cell2mat(ts_db');
    save(fullfile(output_dir, output_ts_name), 'SNR_timestamps_start_dt2', 'noise_loc_arr','-v7.3');
end

function [f_names, f_inds] = get_raw_file_names_and_inds(target_path)
    dir_conts = dir(target_path);
    f_names = {dir_conts.name};
    f_names = f_names(contains(f_names, 'raw_'));
    out = regexp(f_names,'raw_(\d*)', 'tokens', 'once');
    f_inds = str2double(string(out));
    [f_inds, inds] = sort(f_inds, 'ascend');
    f_names = f_names(inds);
end