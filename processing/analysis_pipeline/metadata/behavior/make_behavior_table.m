function behavior_table = make_behavior_table(behavior_folder, ...
    experiment, behavior_file_no, snr_times, out_folder)
% JN 2019-07-04

behavior_filenames = find_behavior_filenames(behavior_folder, ...
    experiment, behavior_file_no);


for i = 1:length(behavior_filenames)
    if any(behavior_filenames{i})
        log_msg(out_folder, 'found-behavior-filename', behavior_filenames{i});
    else
        log_msg(out_folder, 'empty-behavior-filename', sprintf('%s file %d', behavior_folder, behavior_file_no));
    end
end

log_msg(out_folder, 'start-behav-align', ...
    'Starting alignment and parsing of behavioral events');

[behavior_table, beh_struct_for_RIFF_player] = behavior_parser(behavior_filenames, snr_times);
full_f_path = fullfile(out_folder, 'beh_struct_for_RIFF_player.mat');

% JN 2020-04-06: What is the purpose of the '-nocompression'?
save(full_f_path, '-struct', 'beh_struct_for_RIFF_player', '-nocompression', '-v7.3');

log_msg(out_folder, 'start-behav-align', ...
    'Finished alignment and parsing of behavioral events');

fname = fullfile(out_folder, 'behavior_table.mat');
save(fname, 'behavior_table');
log_msg(out_folder, 'save-mat', fname);

end


function behavior_filenames = find_behavior_filenames(folder, ...
    experiment, first_num)


behavior_filenames = cell(3, 1);

switch experiment
    case 'Maciej'
        inset = 'INSC';
    case 'Ana'
        inset = 'MDP';
    case 'nightRIFF'
        inset = 'nightRIFF';
end


for i = 0:2
    
    pattern = sprintf('ANASTROPHE*%s*_%d.csv', inset, first_num + i);
    candidates = dir(fullfile(folder, pattern));
    if length(candidates) == 1
        behavior_filenames{i + 1} = fullfile(folder, candidates(1).name);
    end
end

end