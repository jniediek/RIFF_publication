function final_db = create_db_Kilosorted_files(mdata)

    % Function create_db_Kilosorted_files is the automated wrapper for the clustering results of
    % the KiloSort2 pipeline.
    % 
    % Created by AlexKaz 02.2020

    % === Load file from .npy files ====
    
    if nargin == 0
        mdata.do_plot = false;
    end
    ks_db = load_data_from_npy_files(mdata);
    spike_inds_db = ks_db.spike_inds_db;
    amplitudes_db = ks_db.amplitudes_db;
    spike_clusters_db = ks_db.spike_clusters_db;
    templates_unw_db = ks_db.templates_unw_db;
    n_ch = size(templates_unw_db, 1);
    
    % JN 2021-02-15
    % if the loading worked, delete all output files
    delete_db_Kilosorted_files(mdata.ks_output_dir)
    
    % === Sort channels by spike size ===
    
    [counts, ~] = histc(spike_clusters_db + 1, 1:n_ch); % spike_clusters_db are 0-indexed
    [counts_sorted, new_ch_order] = sort(counts, 'descend');
    new_ch_order = new_ch_order - 1; % Fix to 0-indexed array
    
    % === Remove noise clusters ===
    
    if strcmp(mdata.elec_type, 'tungsten')
        [out] = remove_noise_clusters_independent_contacts(templates_unw_db, new_ch_order);
    elseif strcmp(mdata.elec_type, 'shank')
        [out] = remove_noise_clusters_shanks(templates_unw_db, new_ch_order, counts);
    else
        error(['!!! Post-processing KiloSorted data: Can`t recognize electrode type: ' mdata.elec_type '. Supported: {tungsten, shank} !!!']);
    end
    
    true_spike_arr = out.true_spike_arr;
    true_elec_inds = out.true_elec_inds;
    true_spike_forms = out.true_spike_forms;
    true_ch_ID = out.true_ch_ID;
        
    % === Agregate data into a single DB ====
    
    final_db = cell(1, length(true_ch_ID));
    
    % === Load SNR time-stamps of all the spikes ===
    
    times_f_name = 'ts_large.mat';
    if strcmp(mdata.neural_mode,'deuteron')
        SAMPLE_RATE = 32000;
        SAMPLES_DT2 = 2^18;
        dt_t_starts = load(fullfile(mdata.ks_output_dir, times_f_name));
        dt_t_starts = dt_t_starts.SNR_timestamps_start_dt2; % Array of DT2 starts according to SNR times
        dt_t_ends = dt_t_starts + SAMPLES_DT2/SAMPLE_RATE;             % Computing the TD2 end times
        dt_t_strt_end = sort([dt_t_starts; dt_t_ends]);      % Creates single array of timestamps for start+stop
        
        n_dt2_files = length(dt_t_starts);
        dt_strt_inds = (0:(n_dt2_files-1))*SAMPLES_DT2 + 1;   % Indices of DT2 file starts
        dt_end_inds = (1:n_dt2_files)*SAMPLES_DT2;    % Marking the indeces of DT2 file ends
        dt_srtr_end_inds = sort([dt_strt_inds dt_end_inds]);
    elseif strcmp(mdata.neural_mode,'tbsi')
        SAMPLE_RATE = 22000;
        SAMPLES_DT2 = -1;
        tbsi_ts = load(fullfile(mdata.ks_output_dir, times_f_name));
        tbsi_ts = tbsi_ts.SNR_timestamps_start_dt2;
    else
        error('Neural mode not supported!!!');
    end
    for i = 1:length(true_ch_ID)
        curr_ch = true_ch_ID(i);
        curr_el = true_elec_inds(i);
        curr_spike_inds = (spike_clusters_db == curr_ch);
        curr_inds = spike_inds_db(curr_spike_inds);
        if strcmp(mdata.neural_mode,'deuteron')
            curr_SNR_ts = interp1(dt_srtr_end_inds, dt_t_strt_end, double(curr_inds), 'linear', 'extrap');
        elseif strcmp(mdata.neural_mode,'tbsi')
            curr_SNR_ts = tbsi_ts(curr_inds);
        else
            error('Neural mode not supported!!!');
        end
        curr_amps = amplitudes_db(curr_spike_inds);

        curr_db = struct('elec_num', curr_el, 'ch_num', curr_ch, 'template', squeeze(true_spike_forms(:, curr_el, i)), ...
                         'temps_ks', squeeze(true_spike_forms(:, :, i)), ...
                         'spike_amps', curr_amps, 'sp_inds', curr_inds, 'sp_SNR_ts', curr_SNR_ts);
        final_db{i} = curr_db;
    end
    
    final_db = cell2mat(final_db);
    
    if strcmp(mdata.elec_type, 'tungsten')
        final_db_reduced = merge_similar_spikeforms(final_db);
    elseif strcmp(mdata.elec_type, 'shank')
        final_db_reduced = final_db;
        disp('=== Shank clustring doesn`t support unit post-merging or cleaned ===')
    else
        error(['!!! Post-processing KiloSorted data: Can`t recognize electrode type: ' mdata.elec_type '. Supported: {tungsten, shank} !!!']);
    end
    
    [key_f_names, first_DT2_ind] = get_raw_NA_multiDT2_file_list(mdata);
    final_db_reduced = crop_raw_examples(key_f_names, first_DT2_ind, final_db_reduced, mdata, SAMPLE_RATE, SAMPLES_DT2);
    final_db_reduced = count_no_spikes_per_cluster(final_db_reduced);
    [final_db_reduced] = calc_heat_maps(final_db_reduced, SAMPLE_RATE);
    save_results(final_db_reduced, mdata);
    
    % ==== Plot the results ====
    
    if mdata.do_plot
        
        %%% plot_all_channels_on_electrodes(templates_unw_db);  % BROKEN - LEGACY. Don't uncomment
        
        plot_unit_quality_analysis(final_db_reduced, mdata);
        
        plot_number_of_spikes_per_cluster(final_db_reduced, mdata);
        
        plot_all_unit_quality_analysis(final_db_reduced, mdata);
        
        plot_noise_rejection(templates_unw_db, new_ch_order, counts_sorted, true_spike_arr, true_elec_inds, mdata);
        
        plot_true_templates_per_elec(final_db_reduced, mdata);
        
        plot_raw_NA_overlay_spikes(final_db_reduced, mdata);
        
        plot_true_clusters_along_time(final_db_reduced, mdata);
        
        %%% Extract the sub-folder names of the experiment - {01_passive, 02_behavior, 03_passive}
        a = dir(fullfile(mdata.ks_output_dir, '..'));
        f_names = {a.name};
        f_names_short = f_names([a.isdir]);
        exp_parts = setdiff(f_names_short, {'.', '..', 'ks_output'});    % remove irrelevant folders
        for exp_part = string(exp_parts)
            plot_PSTH_sounds(final_db_reduced, mdata, exp_part);
        end
    end
end

% ====== Helper function ==============

function [ks_db] = load_data_from_npy_files(mdata)

    output_dir = mdata.ks_output_dir;
    
    output_matlab_name = 'rez2.mat';
    templates = 'templates.npy';
    spike_times = 'spike_times.npy';
    spike_templates = 'spike_templates.npy';
    spike_clusters = 'spike_clusters.npy';
    amplitudes = 'amplitudes.npy';

    templates_db = readNPY(fullfile(output_dir, templates));   % Download it from: https://github.com/kwikteam/npy-matlab
    spike_inds_db = readNPY(fullfile(output_dir, spike_times));
    spike_templates_db = readNPY(fullfile(output_dir, spike_templates));
    amplitudes_db = readNPY(fullfile(output_dir, amplitudes));
    spike_clusters_db = readNPY(fullfile(output_dir, spike_clusters));

    whitening_mat_inv = 'whitening_mat_inv.npy';
    whitening_mat_inv_db = readNPY(fullfile(output_dir, whitening_mat_inv));

    rez = load(fullfile(output_dir, output_matlab_name));
    rez = rez.rez;
    U = gather(rez.U);
    W = gather(rez.W);

    temp_n = size(templates_db, 1);
    templates_unw_db = zeros(temp_n, size(W, 1), size(U, 1));

    for i = 1:temp_n
        curr_temp2 = whitening_mat_inv_db' * squeeze(squeeze(U(:,i,:)) * squeeze(W(:,i,:))');
        templates_unw_db(i, :, :) = curr_temp2';
    end
    
    if ~isequal(spike_templates_db, spike_clusters_db)
        error('ERROR in assumptions regarding KS output!!');
    end
    ks_db = struct('spike_inds_db', spike_inds_db, ...
                    'spike_clusters_db', spike_clusters_db, ...
                    'amplitudes_db', amplitudes_db, ...
                    'templates_unw_db', templates_unw_db);
end

function [output_struct] = remove_noise_clusters_shanks(templates_unw_db, new_ch_order, spike_counts)

% Function that checks all spike templates and reject clusters that are not looking like a spike.

    [n_temp, ~, ~] = size(templates_unw_db);
    true_spike_forms = [];
    true_elec_inds = [];
    true_ch_ID = [];
    true_spike_arr = zeros(1, n_temp);
    
    HEAD_TAIL_NO_FLUC_REGION = 3;  % Number of samples of the head or tail to look at
    SPIKE_COUNT_THR = 5; %changed to 500 from 2000 because of the TBSI data 
    %AP 160821 changed threshold to 5, for small files
        
    for i = 1:n_temp
        curr_ch_num = new_ch_order(i);
        
        if spike_counts(curr_ch_num + 1) < SPIKE_COUNT_THR  % Omit clusters with low spike counts
            continue;
        end
        
        % Get current template
        curr_template = squeeze(templates_unw_db(curr_ch_num + 1, :, :)); %Fix for 1-indexing

        % Identify the true spike form + discard noise
        abs_data = abs(curr_template);
        maxs = max(abs_data, [], 1);
        [~, true_elec_ind] = max(maxs);
        [sorted_max, ~] = sort(maxs, 'descend');
                        
        [~, peak_inds] = findpeaks(abs_data(:, true_elec_ind), 'MinPeakHeight', sorted_max(1)/5, ...
                                   'MinPeakDistance',7);   % 5 is hyper-parameter :) %AP 061020, changed to 7 to see if it helps with detecting more spikes
        if length(peak_inds) > 2  % We expect two big maxima, since the data is absoluted. Third peak is an anomaly
            continue;
        end
        
        % Reject by high variance at the begginings / end of template, high chance of periodic noise / noise artifact
        first_sect = abs_data(1:HEAD_TAIL_NO_FLUC_REGION, true_elec_ind);
        last_sect = abs_data((end-HEAD_TAIL_NO_FLUC_REGION):end, true_elec_ind);
        max_abs_start_end = max(max(first_sect), max(last_sect));
        if max_abs_start_end > sorted_max(1)/3   % 3 is hyper-parameter :)
%             h_fig = figure;
%             plot(curr_template);
%             close(h_fig);
            continue;
        end
        
        % Add current template to true templates
        true_spike_arr(curr_ch_num+1) = 1; %Fix for 1-indexing
        true_elec_inds = [true_elec_inds true_elec_ind];
        true_spike_forms = cat(3, true_spike_forms, curr_template);
        true_ch_ID = [true_ch_ID curr_ch_num];
    end
    
    output_struct = struct('true_spike_arr', true_spike_arr, ...
                           'true_elec_inds', true_elec_inds, ...
                           'true_spike_forms', true_spike_forms, ...
                           'true_ch_ID', true_ch_ID);
end

function [output_struct] = remove_noise_clusters_independent_contacts(templates_unw_db, new_ch_order)

% Function that checks all spike templates and reject clusters that are not looking like a spike.

    [n_temp, n_samp, n_elec] = size(templates_unw_db);
    true_spike_forms = [];
    true_elec_inds = [];
    true_ch_ID = [];
    true_spike_arr = zeros(1, n_temp);
    
    for i = 1:n_temp
        % Get current template
        curr_ch_num = new_ch_order(i);
        curr_template = squeeze(templates_unw_db(curr_ch_num + 1, :, :)); %Fix for 1-indexing

        % Identify the true spike form + discard noise
        abs_data = abs(curr_template);
        maxs = max(abs_data, [], 1);
        max_mean = mean(maxs);
        MAX_EXTENT = 5;
        [~, true_elec_ind] = max(maxs);
        [sorted_max, ~] = sort(maxs, 'descend');
        if sorted_max(1) > MAX_EXTENT*sorted_max(2)  % If biggest spike is MAX_EXTENT bigger than the mean maxs
                        
            % reject false-spikes that has early\late fluctuations
            HEAD_TAIL_NO_FLUC_REGION = 3;  % Number of samples of the head or tail to look at
            first_sect = abs_data(1:HEAD_TAIL_NO_FLUC_REGION, true_elec_ind);
            last_sect = abs_data((end-HEAD_TAIL_NO_FLUC_REGION):end, true_elec_ind);
            max_abs_start_end = max(max(first_sect), max(last_sect));
            [~, peak_inds] = findpeaks(abs_data(:, true_elec_ind), 'MinPeakHeight', sorted_max(1)/5, ...
                                       'MinPeakDistance', 5);
%             if(max_abs_start_end > 0.2*max(maxs))  %AK2020: Disabling early/late fluctuations
            if length(peak_inds) > 2                %... Instead looking for multiple peaks
                continue;
            end
            
            % Add current template to true templates
            true_spike_arr(curr_ch_num+1) = 1; %Fix for 1-indexing
            true_elec_inds = [true_elec_inds true_elec_ind];
            true_spike_forms = cat(3, true_spike_forms, curr_template);
            true_ch_ID = [true_ch_ID curr_ch_num];
        end
    end
    
    output_struct = struct('true_spike_arr', true_spike_arr, ...
                           'true_elec_inds', true_elec_inds, ...
                           'true_spike_forms', true_spike_forms, ...
                           'true_ch_ID', true_ch_ID);
end

function save_results(NA_db, metadata)

    f_name  = fullfile(metadata.ks_output_dir, 'final_NA_results.mat');
    save(f_name, 'NA_db', 'metadata', '-v7.3', '-nocompression'); %AP 210920 changed from nocompression to v7.3
    disp(['The final DB saved in: ' f_name]);
end

function [key_f_names, first_ind] = get_raw_NA_multiDT2_file_list(mdata)
    dir_conts = dir(fullfile(mdata.ks_output_dir, '..'));
	file_names = {dir_conts.name};
	file_names = file_names(contains(file_names, 'raw_'));
    
	raw_f_nums = regexp(file_names', '\d*', 'match');
    % AP 091220 added handling for TBSI files too
    if strcmp(mdata.neural_mode,'deuteron')
        raw_f_nums = str2double(reshape([raw_f_nums{:}], [2, length(file_names)]));
    elseif strcmp(mdata.neural_mode,'tbsi')
        raw_f_nums = str2double([raw_f_nums{:}]);
    else
        error('Neural mode not supported!!!');
    end
    [~, inds] = sort(raw_f_nums(1, :), 'ascend');
    file_names = file_names(inds);
    first = file_names{3};  % Take middle of the passive session
    mid = file_names{round(length(file_names)/2)};
    last = file_names{end - 2}; % Take the two before last - middle of passive 2.
    key_f_names = {first, mid, last};
    first_ind = raw_f_nums(inds(1), 1); % Paste the index of the first DT of the session, used to compute relative index of spikes
end

function final_db = crop_raw_examples(key_f_names, first_DT2_ind, final_db, mdata, SAMPLE_RATE, SAMPLES_DT2)
    
    % Function crop_raw_examples crops-out the raw spike NA from the raw_??.mat and injects the spike
    % matrix into the provided database.
    % 
    % Inputs:
    %     key_f_names - (cellarr of strings) - Names of the raw files that should be extracted
    %     final_db - (1xC strcutarr) - Database that describes the C clusters.
    %                                raw_sp_mats is a [NxW] matrix of N spikes cropped with W window
    %     mdata - (struct) - Data about the whole KS processing
    %     SAMPLE_RATE - (const) - Sampling rate of the NA in the dt2 files
    %     SAMPLES_DT2 - (const) - Number of samples in dt2 file
    % 
    % Outputs:
    %     final_db - (1xC strcutarr) - Database that describes the C clusters. New variables are
    %                                added to it: raw_sp_mats, raw_sp_ints.
    
    %TO_uV_FACT = 0.195;
    
    for curr_f_ind = 1:length(key_f_names)
        f_name = fullfile(mdata.ks_output_dir, '..', key_f_names{curr_f_ind});
        raw_NA = load(f_name);
        if strcmp(mdata.neural_mode,'deuteron')
            TO_uV_FACT = raw_NA.BitResolution;
            s_raw_t = raw_NA.starttimes_snr(1);
            e_raw_t = raw_NA.starttimes_snr(end) + SAMPLES_DT2/SAMPLE_RATE;  % raw_NA.starttimes_snr(end) is start if last dt2 files, add to that the length of the last segment.
            raw_f_nums = str2double(regexp(key_f_names{curr_f_ind}, '\d*', 'match'));  % Extract 0 num from raw_0_49.mat
            % Spike indices are relative to raw_NA.bin, s.t. ind=1 is first spike of raw_?? file of session.
            % Could by raw_0_ or raw_1054_
            file_strt_global_ind = (raw_f_nums(1) - first_DT2_ind) * SAMPLES_DT2 + 1;
            NA_raw = raw_NA.data;
            sound_channel = identify_sound_channel(NA_raw);
            if sound_channel > 0
                NA_raw(:, sound_channel) = 2^15;
            end
        elseif strcmp(mdata.neural_mode,'tbsi')
            TO_uV_FACT = raw_NA.BitResolution/raw_NA.Gain;
            s_raw_t = raw_NA.timestamps_snr(1);
            e_raw_t = raw_NA.timestamps_snr(end);
            raw_f_nums = str2double(regexp(key_f_names{curr_f_ind}, '\d*', 'match'));
            file_strt_global_ind = (raw_f_nums(1) - first_DT2_ind) + 1;
            NA_raw(1:length(raw_NA.data),[1:4,6:32]) = raw_NA.data;
            sound_channel = -1;
            NA_raw(:, 5) = 2^15;
        else
            error('Neural mode not supported!!!');
        end
        
        
        NA_raw = mean_reduce_16x2_raw_data(double(NA_raw) - 2^15, mdata.is_new_layout);
        [NA_raw, ~] = flatten_noise_areas(NA_raw, false, mdata.neural_mode, TO_uV_FACT);
        NA_raw = NA_raw*TO_uV_FACT;
        
        for clust_ind = 1:length(final_db)
            curr_clust = final_db(clust_ind);
            spike_inds = curr_clust.sp_inds();
            spike_ts = curr_clust.sp_SNR_ts;
            NA_inds_cropped = spike_inds((spike_ts > s_raw_t) & (spike_ts < e_raw_t));
            NA_inds_crop_rel = NA_inds_cropped - file_strt_global_ind;  % Global index -> rel to file
%             N_SPIKES = 10;  % Take only a subset of spikes
            N_SPIKES = length(NA_inds_crop_rel);
            SPIKE_WINDOW_W = 101;
%             NA_inds_cropped = randsample(NA_inds_cropped, N_SPIKES);  % Pick random 10 spikes from the population
            single_spike_grid = 1:SPIKE_WINDOW_W;
            sp_ind_mat = repmat(uint64(single_spike_grid), [length(NA_inds_crop_rel), 1]);
            sp_ind_mat = (sp_ind_mat + NA_inds_crop_rel - floor(SPIKE_WINDOW_W/3))';
            sp_ind_mat_lin = sp_ind_mat(:);
            sp_ind_mat_lin = max(1, min(length(NA_raw), sp_ind_mat_lin));   % Deal with corner cases of first/last spike
            
            sp_lin = NA_raw(sp_ind_mat_lin, curr_clust.elec_num);
            sp_mat = reshape(sp_lin, [SPIKE_WINDOW_W, N_SPIKES]);
            
            final_db(clust_ind).raw_sp_mats{curr_f_ind} = sp_mat;  % Store the spike matrix into the final_db struct
            final_db(clust_ind).raw_sp_inds{curr_f_ind} = NA_inds_cropped;
        end
        
    end
end
% 
% function [NA_data] = preprocess_raw_NA(NA_db)
% 
%     % Function preprocess_raw_NA transforms the uint16 data into double with units of uV, and reduces
%     % the channel mean as done in pre-processing step before the KS.
%     % 
%     % Inputs:
%     %     NA_db - (struct) - As loaded from one of the raw_??_??.mat. The NA is in uint16
%     % 
%     % Outpus:
%     %     NA_db - (CxN matrix, double) - Only the NA, converted to uint16.
% 
%     NA_data = NA_db.data;
%     NA_data = (double(NA_data) - 2^15)*NA_db.BitResolution;
%     NA_data = NA_data - mean(NA_data, 2);
%     
% %     rel_times = ((1:(2^18))/32000)';
% %     rel_times_rep = repmat(rel_times, [1, length(NA_db.starttimes_snr)]);
% %     rel_times_rep_shifted = rel_times_rep + NA_db.starttimes_snr';
% %     t_snr_arr = rel_times_rep_shifted(:);
% end

function [NA_db] = calc_heat_maps(NA_db, SAMPLE_RATE)
    
    % Function calc_heat_maps calculates the heatmap of the spike matrices.
    % 
    % Inputs:
    %     NA_db - (struct) - As loaded from raw_??_??.mat and inflated with post-procesing fields.
    %     SAMPLE_RATE - (const) - The sampling rate. For DT2 it is 32000
    % 
    % Outputs:
    %     NA_db - (Struct) - The input DB with additional field: spike_heatmap.
    %                        It constists of cellarr of size 2: {N', C}.
    %                        Can be used as >> figure; h = imagesc(C{1}, C{2}, N);

    SR = SAMPLE_RATE / 1000;
    BIN_N = 20;
    CROP_WINDOW = 20:70;
    HEATMAP_RES = 80;
    AMP_LIM = 100;  % Clip noise and extreme sized spikes
    
    for curr_clust_ind = 1:length(NA_db)
        curr_clust = NA_db(curr_clust_ind);
        for curr_exp_segment = 1:length(NA_db(1).raw_sp_mats)
            spike_mat = curr_clust.raw_sp_mats{curr_exp_segment};
            if size(spike_mat, 2) < 2
                % Too few spikes were found for this cluster in the RAW section.
                % No point to calc the heatmap here, so it will be skipped.
                NA_db(curr_clust_ind).spike_heatmap{curr_exp_segment} = {1, {1, 1}}; % Placeholder for empty heatmap
                continue;
            end
            spike_mat = spike_mat(CROP_WINDOW, :);
            
            mid = floor(size(spike_mat, 1) / 2); 
            new_x = -mid:(1/BIN_N):mid;
            spike_mat_interp = interp1(-mid:mid, spike_mat, new_x, 'spline');
            x_vec = repmat((new_x/SR), 1, size(spike_mat_interp, 2));
            spikes_vec = reshape(spike_mat_interp, 1, []);
            spikes_vec(spikes_vec > AMP_LIM) = AMP_LIM;  % Clip extreme amp values
            spikes_vec(spikes_vec < -AMP_LIM) = -AMP_LIM;
            [N, C] = hist3([x_vec' spikes_vec'], [HEATMAP_RES HEATMAP_RES]);
            NA_db(curr_clust_ind).spike_heatmap{curr_exp_segment} = {N', C};
        end
    end
end

% ===== Plotting functions ========
% 
% function plot_all_channels_on_electrodes(templates_unw_db, mdata)
%     figure();
%     electrodes = [2 4 10 12];
%     for i = 1:4
%         h_ax = subplot(2, 2, i);
%         curr_elec  = electrodes(i);
%         plot(h_ax, templates_unw_db(:, :, curr_elec)');
%         title(h_ax, ['Electrode No. ' num2str(curr_elec)]);
%     end
%     
%     	% === print image ===
%     f_name = fullfile(mdata.ks_output_dir, 'all_ch_per_few_elecs');
%     print_plot_to_file(h_f, f_name, mdata);
% end

function plot_number_of_spikes_per_cluster(final_db, mdata)
    h_f = figure();
    h_ax = axes(h_f);
    names = cell(1, length(final_db));
    for i = 1:length(final_db)
        names{i} = ['e' num2str(final_db(i).elec_num) '_ch' num2str(final_db(i).ch_num)];
    end
    counts = [final_db.spike_count];
    plot(h_ax, counts, '.', 'MarkerSize', 10);
    set(h_ax, 'xticklabels', names, 'XTick', 1:length(names), 'TickLabelInterpreter', 'none', 'XTickLabelRotation', -45);
    xlabel(h_ax, 'Channel No.');
    ylabel(h_ax, 'Number of spikes');
    title(h_ax, 'No. of spikes per detected cluster');
    set(h_f, 'position', [77 791 1631 242]);
    tightfig(h_f);
        
	% === print image ===   
    f_name = fullfile(mdata.ks_output_dir, 'num_spikes_per_cluster');
    print_plot_to_file(h_f, f_name, mdata);
end

function NA_db = count_no_spikes_per_cluster(NA_db)

    % Function count_no_spikes_per_cluster counts the number of spikes in each found cluster and injects
    % the count to the final_db
    % 
    % Inputs:
    %     NA_db - (struct) - As loaded from one of the raw_??_??.mat.
    % 
    % Inputs:
    %     NA_db - (struct) - As loaded from one of the raw_??_??.mat, with new field 'spike_counts'

    spike_counts_num_cellarr = cellfun(@length, [NA_db.raw_sp_inds], 'UniformOutput', false);
    [NA_db.spike_count] = spike_counts_num_cellarr{:};
end

function plot_noise_rejection(templates_unw_db, new_ch_order, counts_sorted, true_spike_arr, true_elec_inds, mdata)
    h_f = figure;
    [n_temp, ~, ~] = size(templates_unw_db);
    true_ch_counter = 1;
    for i = 1:n_temp
        % Plot the wave-forms at each channel
        h_ax = subplot(8,ceil(n_temp / 8),i);
        curr_ch_num = new_ch_order(i) + 1; %Fix for 1-indexing
        curr_data = squeeze(templates_unw_db(curr_ch_num, :, :));
        plot(h_ax, curr_data);
        xlim(h_ax, [-5 (size(templates_unw_db, 2) + 4)]);
        ylim(h_ax, [-30, 30]);

        if true_spike_arr(curr_ch_num)
            title(h_ax, ['Spike!!! e=' num2str(true_elec_inds(true_ch_counter))...
                   ',n=' num2str(counts_sorted(i))]);
            true_ch_counter = true_ch_counter + 1;
        else
            title(h_ax, ['n=' num2str(counts_sorted(i))]);
        end
    end
    set(h_f, 'position', [1 41 1920 1083]);
    tightfig(h_f);
    set(h_f, 'position', [1 41 1920 1083]);
	% === print image ===
    
    f_name = fullfile(mdata.ks_output_dir, 'noise_rejection_step');
    print_plot_to_file(h_f, f_name, mdata);
end

function plot_true_templates_per_elec(final_db, mdata)
    h_f = figure();
    elec_nums = [final_db.elec_num];
    active_elecs = unique(elec_nums);
    for i = 1:length(active_elecs)
        templates = [];
        for curr_clust_ind = 1:length(final_db)
            curr_clust = final_db(curr_clust_ind);
            if curr_clust.elec_num ~= active_elecs(i)
                continue  % This cluster don't belong to the curr electrode
            end
            templates = [templates curr_clust.template];
        end
        h_ax = subplot(2, ceil(length(active_elecs)/2), i);
        plot(h_ax, templates, 'LineWidth', 3);
        title(h_ax, ['Elec. No. ' num2str(active_elecs(i))]);
    end
    set(h_f, 'position', [258 488 1466 420]);
    tightfig(h_f);
    set(h_f, 'position', [258 488 1466 420]);
    
	% === print image ===
   
    f_name = fullfile(mdata.ks_output_dir, 'found_templates');
    print_plot_to_file(h_f, f_name, mdata);    
end
%
%function plot_raw_NA_overlay_spikes(final_db, mdata)
%    % === Load the first raw_data_file ====
%    f_name = mdata.first_raw_f_name;
%    raw_NA = load(f_name);
%    n_channels = size(raw_NA.data, 2);
%    
%    
%    h_f = figure();
%    h_ax = axes(h_f);
%    n_samples = 4*1e5;
%
%    % == Plot the raw NA - turned to double, mean-reduced ===
%    if strcmp(mdata.neural_mode,'deuteron')
%        SAMPLING_RATE = 32000;
%        NA_data = raw_NA.data(1:n_samples, :);
%        sound_channel = identify_sound_channel(NA_data);
%        if sound_channel > 0
%            NA_data(:, sound_channel) = 2^15;
%        end
%        to_uV_fact = raw_NA.BitResolution;
%    elseif strcmp(mdata.neural_mode,'tbsi')
%        SAMPLING_RATE = 22000;
%        NA_data(:,[1:4,6:32]) = raw_NA.data(1:n_samples,:);
%        sound_channel = -1;
%        n_channels = 32;
%        NA_data(:, 5) = 2^15;
%        to_uV_fact = raw_NA.BitResolution/raw_NA.Gain;
%    else
%        error('Neural mode not supported!!!');
%    end
%    NA_data = mean_reduce_16x2_raw_data(double(NA_data) - 2^15, mdata.is_new_layout);
%    [NA_data, ~] = flatten_noise_areas(NA_data, false, mdata.neural_mode, to_uV_fact);
%    if strcmp(mdata.neural_mode,'deuteron')
%        rel_times = ((1:(2^18))/SAMPLING_RATE)';
%        rel_times_rep = repmat(rel_times, [1, length(raw_NA.starttimes_snr)]);
%        rel_times_rep_shifted = rel_times_rep + raw_NA.starttimes_snr';
%        t_arr = rel_times_rep_shifted(:);
%    elseif strcmp(mdata.neural_mode,'tbsi')
%        t_arr = raw_NA.timestamps_snr;
%    else
%        error('Neural mode not supported!!!');
%    end
%
%    plot(h_ax, t_arr(1:n_samples), NA_data + (1:n_channels)*800, 'k');
%    ylim(h_ax, [-1000 33*800]);
%    xlim(h_ax, [t_arr(n_samples/2+3000*SAMPLING_RATE/1000)  t_arr(n_samples/2+3600*SAMPLING_RATE/1000)]);
%    hold(h_ax, 'on');
%    xlabel(h_ax, 'Time (sample)');
%    ylabel(h_ax, 'Electrodes');
%    title(h_ax, 'Superposition of the found clusters on raw NA');
%    set(h_f, 'position', [195 171 1649 927]);
%    tightfig(h_f);
%    set(h_f, 'position', [195 171 1649 927]);
%    
%    % === Add the located spikes ====
%
%    for i = 1:length(final_db)
%        curr_SNR_ts = final_db(i).sp_SNR_ts(final_db(i).sp_SNR_ts < t_arr(end));
%        curr_amps = final_db(i).spike_amps(final_db(i).sp_SNR_ts < t_arr(end));
%        elec_num = final_db(i).elec_num + randn()*0.1;
%
%        h = plot(h_ax, curr_SNR_ts, (curr_amps + ones(size(curr_amps))*elec_num*800)', 'o', ...
%                'linewidth', 3, 'MarkerSize', 35);
%        h.Color(4) = 0.5;
%    end
%    
%	% === print image ===
%
%    f_name = fullfile(mdata.ks_output_dir, 'raw_NA_with_spikes');
%    print_plot_to_file(h_f, f_name, mdata);
%end

function plot_true_clusters_along_time(final_db, mdata)
    h_f = figure();
    h_ax = axes(h_f);
    g_min = Inf;
    for i = 1:length(final_db)
        g_min = min(g_min, final_db(i).sp_SNR_ts(1));
    end
    for i = 1:length(final_db)
        curr_ts = final_db(i).sp_SNR_ts;
        plot(h_ax, (curr_ts-g_min)*1000, curr_ts*0+100*(i-1), '.');
        hold(h_ax, 'on');
    end
    
    ylim(h_ax, [-100 (length(final_db)+1)*100]);
    xlim(h_ax, [4.4 4.43]*1e6);
    hold(h_ax, 'on');
    xlabel(h_ax, 'Time (sample)');
    ylabel(h_ax, 'Electrodes');
    title(h_ax, 'Eyeballing the correlation between channels');
    set(h_f, 'position', [195 171 1649 927]);
    tightfig(h_f);
    set(h_f, 'position', [195 171 1649 927]);
    
    % === print image ===
    
	f_name = fullfile(mdata.ks_output_dir, 'clusts_vs_time');
    print_plot_to_file(h_f, f_name, mdata);
end

function plot_PSTH_sounds(final_db, mdata, exp_part)

    % === Load the sound info ===
    sound_f_name = 'sounds_table.mat';
    full_sounds_fname = fullfile(mdata.raw_base, exp_part, sound_f_name);
    if ~exist(full_sounds_fname, 'file')
        return
    end
    sound_table = load(full_sounds_fname);
    sound_table = sound_table.sounds_table;

    % === Plot the PSTHs ====
    
    if ~any(contains(sound_table.Properties.VariableNames, 'soundname'))
        sound_table.Properties.VariableNames{9} = 'soundname';
    end
    sound_types = unique(sound_table.soundname);
    lim_1 = 0.5;
    lim_2 = 2;
    sbplots_w = 7; % there are 13 sounds, 3 rows
%     h_wb = waitbar(0);
    parfor clust_ind = 1:length(final_db)
        h_f = figure();
        curr_clust = final_db(clust_ind);
        curr_sp_ts = curr_clust.sp_SNR_ts;
        curr_sbplot_ind = 1;
        row_plot_counter = 1;
        for i = 1:length(sound_types)
            h_ax = subplot(6, sbplots_w, curr_sbplot_ind);
            curr_ts = sound_table.start_t(sound_table.soundname == sound_types(i));
            if length(curr_ts) < 2
                title(h_ax, ['Sound(' num2str(length(curr_ts)) '): ' char(sound_types(i))], 'interpreter', 'none');
                continue;
            end
              % spike index -> SNR time
            psth_counter = [];
            for curr_trial = 1:length(curr_ts)
                curr_t = curr_ts(curr_trial);
                t1 = curr_t - lim_1;
                t2 = curr_t + lim_2;
                spike_ts = curr_sp_ts((curr_sp_ts > t1) & (curr_sp_ts < t2));
                spike_ts = (spike_ts - t1 - lim_1)*1000; 
                plot(h_ax, spike_ts, spike_ts*0 + curr_trial, 'k.', 'MarkerSize', 3);
                hold(h_ax, 'on');
                psth_counter = [psth_counter; spike_ts];
            end
            plot(h_ax, [0 0], [0 2], 'r', 'linewidth', 2);

            ylim(h_ax, [1 length(curr_ts)]);
            xlim(h_ax, [-lim_1 lim_2]*1000);
            title(h_ax, ['Sound(' num2str(length(curr_ts)) '): ' char(sound_types(i))], 'interpreter', 'none');

            % == add the PSTH plot ====

            h_ax = subplot(6, sbplots_w, curr_sbplot_ind + sbplots_w);
            histogram(h_ax, psth_counter, -500:40:2000);
            curr_sbplot_ind = curr_sbplot_ind + 1;
            row_plot_counter = row_plot_counter + 1;
            if(row_plot_counter > sbplots_w)
                row_plot_counter = 1;
                curr_sbplot_ind = curr_sbplot_ind + sbplots_w;
            end
        end
        sgtitle(h_f, ['PSTH - Elec.: ' num2str(curr_clust.elec_num) '. ch: ' num2str(curr_clust.ch_num)]);
        set(h_f, 'position', [65 300 1772 620]);
%         waitbar(clust_ind/length(final_db), h_wb, 'Please wait...');
        
        % Print the image
        im_name = ['PSTH_e' num2str(curr_clust.elec_num) '_ch' num2str(curr_clust.ch_num) '_' exp_part{1}];
        f_name = fullfile(mdata.ks_output_dir, im_name);
        drawnow();  % Complete the graphical rendering (without the delays some images are totally black)
        pause(0.1);
        print_plot_to_file(h_f, f_name, mdata);
    end
%     delete(h_wb);
end


% JN and OB 2021-07-20. We moved this function to a file of its own to ease debugging
%function print_plot_to_file(h_f, name, mdata)
%    if ~mdata.do_print
%        return;
%    end
%    full_name = [name '.png'];
%    res = '-r450';
%    print(h_f, full_name, '-dpng', res);
%    
%    if isfield(mdata, 'do_close_all') && mdata.do_close_all
%        drawnow(); % Allow the drawing and saving to finish
%        close(h_f);
%    end
%end
%
function plot_all_unit_quality_analysis(final_db, mdata)

    h_fig = figure();
    
    for curr_clust_ind = 1:length(final_db)
        curr_clust = final_db(curr_clust_ind);
        
        % === Plot firing rate VS time ===
        h_ax = subplot(4, length(final_db), curr_clust_ind, 'Parent', h_fig);
        histogram(h_ax, curr_clust.sp_SNR_ts, 50);
        xlabel(h_ax, 'Time (seconds)');
        title(h_ax, ['Elec.: ' num2str(curr_clust.elec_num) ... 
              ' ch_num: ' num2str(curr_clust.ch_num)], 'interpreter', 'none');
          
        % === Plot amplitude VS time ===
        h_ax = subplot(4, length(final_db), curr_clust_ind + length(final_db), 'Parent', h_fig);
        plot(h_ax, curr_clust.sp_SNR_ts, smooth(curr_clust.spike_amps, 50));
        xlabel(h_ax, 'Time (seconds)');
        xlim(h_ax, [min(curr_clust.sp_SNR_ts) max(curr_clust.sp_SNR_ts)]);
        ylim(h_ax, [10 40]);
        
        % === Plot amlitude distribution ===
        h_ax = subplot(4, length(final_db), curr_clust_ind + 2*length(final_db), 'Parent', h_fig);
        amps = curr_clust.spike_amps;
        histogram(h_ax, amps(amps < 40), 'numbins', 50, 'binlimits', [0 40]);
        xlabel(h_ax, 'Amplitude (NOT uV)');
        
        % === Plot ISI ===
        h_ax = subplot(4, length(final_db), curr_clust_ind + 3*length(final_db), 'Parent', h_fig);
        diff_spike = diff(curr_clust.sp_SNR_ts)*1000;
%         histogram(h_ax, log10(diff_spike(diff_spike < 2000)), 50);
%         xlabel(h_ax, 'dTime (log10(sec) - )');
        histogram(h_ax, diff_spike(diff_spike < 30), 'numbins', 60, 'binlimits', [0 30]);
        xlabel(h_ax, 'dTime (sec)');
    end
    
    ylabel(subplot(4, length(final_db), 1), 'FR hist - Counts');
    ylabel(subplot(4, length(final_db), 1 + length(final_db)), 'Amp drift - Amplitudes');
    ylabel(subplot(4, length(final_db), 1 + 2*length(final_db)), 'Amp hist - Counts');
    ylabel(subplot(4, length(final_db), 1 + 3*length(final_db)), 'ISI - Counts');
    
    tightfig(h_fig);
    h_fig.Position = [13          47        3825        1064];
    tightfig(h_fig);
    drawnow();
    pause(1);
    f_name = fullfile(mdata.ks_output_dir, 'unit_stats');
    print_plot_to_file(h_fig, f_name, mdata);
end

function plot_unit_quality_analysis(final_db, mdata)

    [~, ~] = mkdir(fullfile(mdata.ks_output_dir, 'single_unit_stats'));
    
    
    w_plot_n = 4;
    h_plot_n = 3;
    
% 	for curr_clust_ind = 1:length(final_db)
	parfor curr_clust_ind = 1:length(final_db)
        curr_clust = final_db(curr_clust_ind);
        
        h_fig = figure();
        
        % === Plot firing rate VS time ===
        h_ax = subplot(h_plot_n, w_plot_n, w_plot_n, 'Parent', h_fig);
        histogram(h_ax, curr_clust.sp_SNR_ts/60, 50);
        xlabel(h_ax, 'Time (min)');
        ylabel(h_ax, 'Counts');
        title(h_ax, 'Firing rate VS. time');

        % === Plot amplitude VS time ===
        h_ax = subplot(h_plot_n, w_plot_n, 2, 'Parent', h_fig);
        plot(h_ax, curr_clust.sp_SNR_ts/60, smooth(curr_clust.spike_amps, 50));
        xlabel(h_ax, 'Time (min)');
        ylabel(h_ax, 'Smoothed Voltage (window 50)');
        xlim(h_ax, [min(curr_clust.sp_SNR_ts/60) max(curr_clust.sp_SNR_ts/60)]);
        ylim(h_ax, [10 40]);
        title(h_ax, 'Amplitude dist. VS. time');

        % === Plot amlitude distribution ===
        h_ax = subplot(h_plot_n, w_plot_n, 3, 'Parent', h_fig);
        amps = curr_clust.spike_amps;
        histogram(h_ax, amps(amps < 30), 50, 'binlimits', [10 30]);
        xlabel(h_ax, 'Amplitude');
        ylabel(h_ax, 'Counts');
        title(h_ax, 'Amplitude histogram');

        % === Plot ISI ===
        h_ax = subplot(h_plot_n, w_plot_n, w_plot_n + 1, 'Parent', h_fig);
        diff_spike = diff(curr_clust.sp_SNR_ts*1000);
    %         histogram(h_ax, log10(diff_spike(diff_spike < 2000)), 50);
    %         xlabel(h_ax, 'dTime (log10(sec) - )');
        histogram(h_ax, diff_spike(diff_spike < 40), 'numbins', 50, 'binlimits', [0 40]);
        xlabel(h_ax, 'dTime (ms)');
        ylabel(h_ax, 'Counts');
        title(h_ax, 'Inter-spike interval');
               
        % === Plot the template form ===
        h_ax = subplot(h_plot_n, w_plot_n, 1 + 2*w_plot_n, 'Parent', h_fig);
        plot(h_ax, reshape(curr_clust.temps_ks, 61, []));
        xlabel(h_ax, 'Time (ms)');
        ylabel(h_ax, 'Voltage (NOT uV)');
        title(h_ax, 'Cluster template');
        
        section_name = {'Passive 1', 'Behavior', 'Passive 2'};  
        N_EXAMP_SPKS = 10;
        for section_id = 1:3
            % === Plot exampler spikes: section i ===
            h_ax = subplot(h_plot_n, w_plot_n, 5 + section_id, 'Parent', h_fig);
            n_spikes = size(curr_clust.raw_sp_mats{section_id}, 2);
            title(h_ax, ['Exemplar spikes - ' section_name{section_id}]);
            if n_spikes == 0  % If no spikes were found in the current rat_??.mat, skip the plotting
                str = {'No spikes found', 'in the current raw_??.mat file!'};
                text(h_ax, 0.2, 0.5, str, 'Interpreter', 'None');
                continue;
            end
            NA_inds_cropped = randsample(n_spikes, min(n_spikes, N_EXAMP_SPKS));
            curr_spikes = curr_clust.raw_sp_mats{section_id}(:, NA_inds_cropped);
            plot(h_ax, (1:size(curr_spikes, 1))/32, ...
                        curr_spikes + 100*(1:size(curr_spikes, 2)), 'k');
            ylim(h_ax, [0, 100*(size(curr_spikes, 2) + 1)]);
            xlim(h_ax, [0-4, 3+4]);
            xlabel(h_ax, 'Time (ms)');
            if section_id == 1
                ylabel(h_ax, 'Voltage (uV)');
            end

            % === Plot heatmap spikes: section i ===
            h_ax = subplot(h_plot_n, w_plot_n, 5 + w_plot_n + section_id, 'Parent', h_fig);
            imagesc(curr_clust.spike_heatmap{section_id}{2}{1}, ...
                    curr_clust.spike_heatmap{section_id}{2}{2},...
                    log(curr_clust.spike_heatmap{section_id}{1}+1));
            h_ax.YAxis.Direction = 'normal';
            ylim(h_ax, [-100, 100]);
            xlabel(h_ax, 'Time (ms)');
            if section_id == 1
                ylabel(h_ax, 'Voltage (uV)');
            end
            title(h_ax, ['Heatmap - #spikes: ' num2str(size(curr_clust.raw_sp_mats{section_id}, 2))]);
        end
        
        h_ax = subplot(h_plot_n, w_plot_n, 1, 'Parent', h_fig);
        h_ax.YAxis.Visible = 'off';
        h_ax.XAxis.Visible = 'off';
        str = {['Elec.: ' num2str(curr_clust.elec_num) ' ch_num: ' num2str(curr_clust.ch_num)], ...
               '', ...
               ['Total #spikes: ' num2str(length(curr_clust.spike_amps))], ...
               ['#spikes in Passive1: ' num2str(size(curr_clust.raw_sp_mats{1}, 2))], ...
               ['#spikes in Active: ' num2str(size(curr_clust.raw_sp_mats{2}, 2))], ...
               ['#spikes in Passive2: ' num2str(size(curr_clust.raw_sp_mats{3}, 2))]};
        text(h_ax, 0.2, 0.5, str, 'Interpreter', 'None');
        h_fig.Position = [190         146        1488         924];
        tightfig(h_fig);
        drawnow();
        pause(0.2);
        h_ax.Color = 'None';
        
        % === Flush the graphics to a .png file ===
%         curr_elec_name = ['stats_e' num2str(curr_clust.elec_num) '_ch_' strrep(num2str(curr_clust.ch_num), ' ', '_') '.png'];
%         tstr = strrep(
        curr_elec_name = sprintf("stats_e%d_ch_%d", curr_clust.elec_num, curr_clust.ch_num);
        file_name = fullfile(mdata.ks_output_dir, 'single_unit_stats', curr_elec_name);
        print_plot_to_file(h_fig, file_name, mdata);
	end
    
    
end
% 
% function counts = hist_block(curr_block)
%     [counts, ~] = histcounts(curr_block.data, 50);
% end
