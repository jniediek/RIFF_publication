function process_NA_from_single_experiment_kilosort2(origin_dir, do_plot, do_print, do_close_all, is_new_layout, neural_mode)

	if nargin == 1
        do_plot = true;
        do_print = true;
        do_close_all = false;
    end
    
    path_parts = split(origin_dir, '\');
    if isunix()
        path_parts = split(origin_dir, '/');
    end
    ks_output_dir = fullfile(origin_dir, 'ks_output');
    mdata = struct('raw_base', origin_dir, ...
        'exp_name', path_parts{end-2}, ...
        'exp_date', path_parts{end-1}, ...
        'rat_dir', path_parts{end}, ...
        'rat_no', str2double(path_parts{end}(5:end)), ...
        'ks_output_dir', ks_output_dir, ...
        'do_plot', do_plot, ...
        'do_print', do_print, ...
        'do_close_all', do_close_all, ...
        'is_new_layout', is_new_layout, ...
        'neural_mode', neural_mode, ...
        'elec_type', 'shank');    % Set to 'tungsten' for auto-denoising the post-clustering results

    % ==== Process the data =====
    backup_old_KS_outputs(origin_dir);  % Move old KS files (if exist) to a backup dir.
    
    [mdata.first_raw_f_name, ~] = multiple_raw_NA_to_bin(origin_dir, is_new_layout, neural_mode);

    my_prog_master(ks_output_dir, is_new_layout);

    % If the binary file is not re-created, add one of those lines. Used for debugging
    % It is used to check which DT2 index started the current rat session (0 or ~1050)
%     mdata.first_raw_f_name = fullfile(origin_dir, 'raw_0_49.mat');
    % mdata.first_raw_f_name = fullfile(origin_dir, 'raw_50_99.mat');
    % mdata.first_raw_f_name = fullfile(origin_dir, 'raw_1048_1097.mat');
    % mdata.first_raw_f_name = fullfile(origin_dir, 'raw_1055_1104.mat');
%     mdata.first_raw_f_name = fullfile(origin_dir, 'raw_1053_1102.mat');

    % ==== Save the data =====
%     mdata.first_raw_f_name = fullfile(origin_dir, 'raw_0_49.mat');
    create_db_Kilosorted_files(mdata);
end
