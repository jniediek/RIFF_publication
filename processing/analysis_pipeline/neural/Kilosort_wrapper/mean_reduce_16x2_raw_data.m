function NA_data = mean_reduce_16x2_raw_data(NA_data, is_new_layout)

    % Function mean_reduce_16x2_raw_data() removes correlated noise from 16x2 recording, as done by
    % the dual shank Campbridge Neurotech array.
    % 
    % Inputs:
    %     NA_data -(Nx32 matrix, double) - The NA data, after conversion to double
    %     is_new_layout - boolean - a flag that controls the type of
    %     electrode layout (0-old, 1-new)
    %
    % Output:
    %     NA_data -(Nx32 matrix, double) - Denoised by reducing mean of the other shank
    % 
    % *  *  AlexKaz & Ana 10.2020

    % === Load the channel map - used by workers to denoise by shank_mean_reduce    
%     if ispc()
%         if strcmp(getenv('COMPUTERNAME'), 'DANCE')
% %             layout_dir = 'C:\Users\Owner\Desktop\global_integrator_github_sync\analysis_pipeline\neural\Kilosort2\prog_run';
%             layout_dir = 'C:\merging_pipeline\temp_ana\analysis_pipeline\neural\Kilosort2\prog_run';
%         elseif strcmp(getenv('COMPUTERNAME'), 'HISTORY')
%             layout_dir = 'D:\Ana\RIFF\analysis_pipeline\neural\Kilosort2\prog_run';
%         else
%             error('Unknown computer!');
%         end
%     end
%     
%     if isunix()
%         layout_dir = '/GoodmanHome/ana/matlab/RIFF/analysis_pipeline/neural/Kilosort2/prog_run';
%     end
    if is_new_layout
        layout_fname = which('Cambridge_Neurotech_32x2_new_layout.mat');
        disp('=== Denoising NA by mean-reduce, NEW layout ===');
    else
        layout_fname = which('Cambridge_Neurotech_32x2_old_layout.mat');
        disp('=== Denoising NA by mean-reduce, OLD layout ===');
    end
    if isempty(layout_fname)
        error('Cannot find layout file, please mount all pipeline folders!');
    end
    layout_table = load(layout_fname);
    shank1_inds = find(layout_table.kcoords == 1);
    shank2_inds = find(layout_table.kcoords == 2);
    
    % Reduce from one channel the mean of the whole other shank - assuming that no spike bleedtrough is accepted between shanks
    mean_shank1 = mean(NA_data(:, shank1_inds), 2);
    mean_shank2 = mean(NA_data(:, shank2_inds), 2);
    NA_data(:, shank1_inds) = NA_data(:, shank1_inds) - mean_shank2;
    NA_data(:, shank2_inds) = NA_data(:, shank2_inds) - mean_shank1;
end