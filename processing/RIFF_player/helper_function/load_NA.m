function [NA_db, NA_mdata, NA_raw_db, NA_big, NA_ch_num]  = load_NA(exp_beh_part_dir, do_load_NA_big)

    % Function load_NA() reads the neural activity (NA) that is produced by the Kilosort2 wrapper,
    % in the ks_output folder, inside the experiment folder.
    % 
    % Inputs:
    %     exp_beh_part_dir - (str) - Location of the ks_output folder
    % 
    % Outputs:
    %     NA_db - (struct) - Clustered results of the Kilosort2
    %     NA_mdata - (struct) - Metadata of the processed NA
    %     NA_raw_db - (struct) - Metadata of the raw_??_??.mat files
    %     NA_big - (TxC matrix) - Raw activity along time and electrodes
    %     NA_ch_num - (scalar) - Num of electrodes
    % 
    % ==> Externalized from RIFF_player_nightRIFF on 23.08.20 by alexkaz
    % 
    % *    *    Created by AlexKaz 23.08.20
    
    if nargin == 1
        do_load_NA_big = 1;
    end
    NA_ch_num = 32;

    NA_db = [];
    NA_mdata = [];
    NA_raw_db = [];
    NA_big = [];
    rat_dir = fullfile(exp_beh_part_dir, '..', filesep);
    if ~isfolder(fullfile(rat_dir, 'ks_output'))
        
        return;
    end
    try
        % === Load the sorted data ====
        
        full_dir = fullfile(rat_dir, 'ks_output');
        NA_db = load(fullfile(full_dir, 'final_NA_results.mat'));
        NA_mdata = NA_db.metadata;
        NA_db = NA_db.NA_db;
        
        % Exclude the noise clusters. The manually-added label might be found under 'manual_tag', if provided
        if isfield(NA_db(1), 'manual_tag')
            NA_db = NA_db(~strcmp({NA_db.manual_tag}, 'Noise'));
        end
        
        % === Read data regarding the raw files ====
                
        % Get the SNR start times of each dt2 files - there are 8-50 in each raw
        fs_table = load(fullfile(rat_dir, 'table_filestarts.mat'));
        
        NA_raw_db = struct('fs_arr', fs_table.table_filestarts.snr_times, ...
                           'file_nums', fs_table.table_filestarts.File_num);
        
        if do_load_NA_big
            fidOut = fopen(fullfile(rat_dir, 'ks_output\NA_large.bin'));
            NA_big = fread(fidOut, 'int16=>int16');

            disp(['Assuming the data has ' num2str(NA_ch_num) ' channels']);
            NA_big = reshape(NA_big, NA_ch_num, []);
        else
            NA_big = [];
        end
    catch err
        disp('Failed to load NA!');
        disp(err);
    end
end
