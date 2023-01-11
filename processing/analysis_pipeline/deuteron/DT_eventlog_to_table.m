function table_events = DT_eventlog_to_table(fname)

% JN 2018-12-17
% Reads the eventlog and saves it to a matlab table for later use
% this is faster than running 'read_mixed_csv' and the other previous
% scripts

% you can then do for example:
% idx_filestart = table_events.EventType == 'File started';

% if speed ever becomes an issue here, something along 

% fid = fopen(fname, 'r');
% text = fread(fid, '*char');
% lines = splitlines(text');
% fclose(fid);
% idx_trigger = strfind(lines, 'Digital input port status');
% idx_newfile = strfind(lines, 'File started');

% is yet faster.

opts = detectImportOptions(fname);
opts.VariableNames{3}=  'Time_ms';

% JN 2019-03-14: rename 'details' to 'Details' as it used to be in
% previous parsers
opts.VariableNames{6} = 'Details';
opts = setvartype(opts, 'Time_ms', 'double');
opts = setvartype(opts, 'TimeStamp', 'datetime');
opts = setvaropts(opts, 'TimeStamp', 'DatetimeFormat', 'HH:mm:ss');
opts = setvartype(opts, 'EventNumber', 'uint32');
opts = setvartype(opts, 'EventType', 'categorical');
opts = setvartype(opts, 'TimeSource', 'categorical');
table_events = readtable(fname, opts);
% table_events.details = table_events.Details;  % AlexKaz: Commented-out the line since it forces the fix in prepare_analysis::27. Why? 