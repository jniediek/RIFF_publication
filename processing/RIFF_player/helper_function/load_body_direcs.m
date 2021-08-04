function [out_db] = load_body_direcs(rat_dir, first_subsample_ind, subsampling_inds)

    % Function predicted_rat_body_points.mat() reads the sounds_table.mat that is produced by the pipeline.
    % 
    % Inputs:
    %     rat_dir - (str) - Location of the sounds_table.mat, inside the experiment folder
    % 
    % Outputs:
    %     sound_table - (struct) - Table of sounds
    % 
    % ==> Externalized from RIFF_player_nightRIFF on 23.08.20 by alexkaz
    % 
    % *    *    Created by AlexKaz 23.08.20
    
    
    out_db = struct();
    % Load the data from .mat on the disk
    path_for_direcs = rat_dir;
    file_name = 'predicted_rat_body_points.mat';
    full_file_name = fullfile(path_for_direcs, file_name);
    if ~exist(full_file_name, 'file')
        msgbox('The expected file `predicted_rat_body_points.mat` can not be found. Run CNN on images!')
        return;
    end
    db = load(full_file_name);
    
    base = db.base_points(first_subsample_ind + subsampling_inds, :);
    neck = db.neck_points(first_subsample_ind + subsampling_inds, :);
    nose = db.nose_points(first_subsample_ind + subsampling_inds, :);
    
    out_db.base_locs = base;
    out_db.neck_locs = neck;
    out_db.nose_locs = nose;

    % Compute directions
    [out_db.rat_head_direcs, ~] = get_ang_and_rad(nose(:, 1) - neck(:, 1), nose(:, 2) - neck(:, 2));
    [out_db.rat_body_direcs, ~] = get_ang_and_rad(neck(:, 1) - base(:, 1), neck(:, 2) - base(:, 2));

end
