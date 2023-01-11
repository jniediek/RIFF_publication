function backup_old_KS_outputs(curr_exp_dir)

    % Looks for existing Kilosort outputs from previous runs and moves them
    % to a backup location. This prevents the mixture of outdated clusters with
    % the new results.
    % Only 3 files are omitted, since they are sometimes reused by Kilosort
    % between different runs.
    % The backup folder is named 'OLD_??_ks_output' where ?? is a unique identifier in case of 
    % multiple KS runs on the same experiment.
    % 
    % Inputs:
    %     curr_exp_dir - str - Path to the experiment folder, where 'ks_output' folder is placed
    % 
    % Output:
    %     None - Creates a 
    % 
    % *   *   Writen by AlexKaz 23.02.22  *   *

    old_dir_name = 'ks_output';
    backup_dir_name = 'OLD_ks_output';  % Initial name, might be augmented with unique ID
    
    exclude_files = [".", "..", "ts_large.mat", "NA_large.bin", "temp_wh.dat"];  % Don't copy these
    
    old_dir_fullname = fullfile(curr_exp_dir, old_dir_name);
    
    if exist(old_dir_fullname, "dir")
        % === Create a backup folder for old kilosort files ===
        backup_dir_fullname = fullfile(curr_exp_dir, backup_dir_name);
        unique_ID = 1;
        while exist(backup_dir_fullname, 'dir')
            backup_dir_fullname = fullfile(curr_exp_dir, ...
                                    strrep(backup_dir_name, "OLD", "OLD" + unique_ID));
            unique_ID = unique_ID + 1;
        end
        [~, ~] = mkdir(backup_dir_fullname);
        
        % === Move most contents from the old KS folder to backup ===
        files = dir(old_dir_fullname);
        n_found_files = length(files);
        for i = 1:n_found_files
            c_f_name = files(i).name;
            if ~contains(exclude_files, c_f_name)
                full_origin_fname = fullfile(old_dir_fullname, c_f_name);
                movefile(full_origin_fname, backup_dir_fullname);
            end
        end
        
        disp("");
        disp("Copied old Kilosort files into backup folder:");
        disp("   " + backup_dir_fullname);
        disp("");
        log_msg(curr_exp_dir, 'kilosort-backup', ...
            sprintf('created backup: %s -> %s', old_dir_fullname, backup_dir_fullname));
    end
end