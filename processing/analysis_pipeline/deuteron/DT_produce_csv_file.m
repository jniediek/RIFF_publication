function DT_produce_csv_file(csv_fname, folders)

if isfile(csv_fname)
    log_msg(folders.results, 'found-csv', ...
        sprintf('File %s exists, not overwriting', csv_fname));
else
    for i = 1:length(folders.logger_csv)
        % JN 2020-05-11 iterate over the candidate folders for the file
        csv_fname = fullfile(folders.logger_csv{i}, 'EVENTLOG.CSV');
        
        if ~isfile(csv_fname)
            log_msg(folders.results, 'csv-not-found', ...
                sprintf('Deuteron eventlog file not found in %s', ...
                csv_fname))
            continue
        else
            [status, msg] = copyfile(csv_fname, folders.results);
            if status == 0
                error(msg)
            else
                log_msg(folders.results, 'copied-csv', ...
                    sprintf('Copied %s to %s', ...
                    csv_fname, folders.results));
            end
        end
    end
end