function onset_times = DT_get_file_open_times(table_events, data_folder, ...
    result_folder)

% JN 2018-12-20
% simple function that returns opening times for all files in table_events

% JN 2019-01-09
% it seems that the opening times aren't always logged. In this case, check
% neighbors and continue from there.

% JN 2019-02-03
% sometimes the string 'File started' appears spuriously in log file lines
% that have nothing to do with File starting. To skip such lines here,
% I added `idx_fix_spurious`

% JN 2020-04-22
% added more complete guessing algorithm

idx = table_events.EventType == 'File started';
% table_events.Details = table_events.details;
idx_fix_spurious = contains(table_events.Details, 'File index');
idx = idx & idx_fix_spurious;
tfun = @(line) (str2double(line(12:end)));
fnums = cellfun(tfun, table_events.Details(idx));
times = table_events.Time_ms(idx);

files_in_folder = dir(fullfile(data_folder, '*DT2'));

for i = 1:length(files_in_folder)
    t_num = str2double(files_in_folder(i).name(end-7:end-4));
    
    if ~ismember(t_num, fnums)
        
        log_msg(result_folder, 'logger-timing', ...
            sprintf('Start time for %s not logged, guessing!', ...
            files_in_folder(i).name))
        
        tgt = t_num - 1;
        pre = find(fnums == tgt);
        
        if numel(pre) > 1
            log_msg(result_folder, 'logger-timing', ...
                sprintf('Duplicate start time for DT2 file with index %d', tgt))
            pre = pre(1);
        elseif ~any(pre)
            log_msg(result_folder, 'logger-timing', ...
                sprintf('No start time for DT2 file with index %d', tgt));
        end
        
        tgt = t_num + 1;
        post = find(fnums == tgt);
        
        if numel(post) > 1
            log_msg(result_folder, 'logger-timing', ...
                sprintf('Duplicate start time for DT2 file with index %d', tgt))
            post = post(1);
        elseif ~any(post)
            log_msg(result_folder, 'logger-timing', ...
                sprintf('No start time for DT2 file with index %d', tgt));
        end
        
        if (numel(pre) == 1) && (numel(post) == 1)
            if times(post) - times(pre) == 16384
                fnums(end + 1) = t_num;
                times(end + 1) = times(pre) + 8192;
                log_msg(result_folder, 'logger-timing', ...
                    sprintf('Recovered start time for DT2 file with index %d by surrounding files', t_num));
            end
            
        elseif numel(pre) == 1
            fnums(end + 1) = t_num;
            times(end + 1) = times(pre) + 8192;
            log_msg(result_folder, 'logger-timing', ...
                sprintf('Guessed start time for DT2 file with index %d based on previous file', t_num));
            
        elseif numel(post) == 1
            fnums(end + 1) = t_num;
            times(end + 1) = times(post) - 8192;
            log_msg(result_folder, 'logger-timing', ...
                sprintf('Guessed start time for DT2 file with index %d based on next file', t_num));
        else
            log_msg(result_folder, 'logger-timing', ...
                sprintf('Cannot recover start time for DT2 file with index %d: no surrounding files exist', t_num));
            
        end
    end
end

onset_times = array2table([fnums times], 'VariableNames', ...
    {'File_num', 'Time_ms_Logger'});

onset_times = sortrows(onset_times, 'File_num');