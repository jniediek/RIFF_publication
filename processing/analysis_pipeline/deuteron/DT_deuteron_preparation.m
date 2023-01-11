function [table_events, table_filestarts, TTL] = ...
    DT_deuteron_preparation(folders)
% JN 2020-04-22

% this function runs all the steps required for a recording session with
% the logger

% Parse the autolog (coming from the transceiver)
fname_ttl = fullfile(folders.results, 'deuteron_autolog_parsed.mat');

if isfile(fname_ttl)
    S = load(fname_ttl);
    TTL = S.TTL;
    CD = S.CD;
    log_msg(folders.results, 'load-mat', ...
        sprintf('Loaded parsed deuteron autolog %s', fname_ttl));
    
else
    [TTL, CD] = DT_parse_deutoron_autologs(folders.deuteron_autologs);
    save(fname_ttl, 'TTL', 'CD');
    log_msg(folders.results, 'save-mat', ...
        sprintf('Saved parsed deuteron autolog %s', fname_ttl));
end

% convert or copy the NLE/CSV file (here we'll have to do case selection
% once the "flat" format is introduced)
csv_fname = fullfile(folders.results, 'EVENTLOG.CSV');
DT_produce_csv_file(csv_fname, folders);

% deal with relevant data from the neurologger log file
table_events = DT_eventlog_to_table(csv_fname);
table_events = sortrows(table_events, 'Time_ms');

% save table_events already here to ease debugging
table_fname = fullfile(folders.results, 'table_events');
save(table_fname, 'table_events');
log_msg(folders.results, 'save-matfile', table_fname);

table_ttls = DT_get_ttls_from_logger_table(table_events, folders.results);
table_ttls = table_ttls(logical(bitand(table_ttls.TTL, 1)), :);

table_ttls.TTL(:) = 1; %49 %new SnR version AP 311219

% save already here to ease debugging
table_fname = fullfile(folders.results, 'table_ttls');
save(table_fname, 'table_ttls');
log_msg(folders.results, 'save-matfile', table_fname);

table_filestarts = DT_get_file_open_times(table_events, ...
    folders.logging, folders.results);

% correct filestarts by CD values
table_filestarts = DT_fix_file_open_times(table_filestarts, CD);

% save already here to ease debugging
table_fname = fullfile(folders.results, 'table_filestarts');
save(table_fname, 'table_filestarts');
log_msg(folders.results, 'save-matfile', table_fname);
