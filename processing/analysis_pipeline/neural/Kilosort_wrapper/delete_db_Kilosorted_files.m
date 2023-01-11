function delete_db_Kilosorted_files(folder)
% JN 2021-02-15
% This function deletes the output of the script
% create_db_Kilosorted_files.m
% The purpose is to make sure that repeated runs of kilosort do not result
% in a nonsense combination of clustering results (especially plots 
% related to the clustering) from different iterations.

files_to_delete = {'raw_NA_with_spikes.png', 'clusts_vs_time.png', ...
    'PSTH_e*.png', 'unit_stats.png', 'noise_rejection_step.png', ...
    'num_spikes_per_cluster.png', 'found_templates.png', ...
    'final_NA_results.mat'};

for i = 1:length(files_to_delete)
    names = dir(fullfile(folder, files_to_delete{i}));
    for j = 1:length(names)
        fullfile(folder, names(j).name)
    end
end

names = dir(fullfile(folder, 'single_unit_stats', 'stats_e*.png'));
for i = 1:length(names)
    fullfile(folder, names(i).name)
end
