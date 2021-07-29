function log_msg(folder, type, argument)
% JN 2019-03-06
% type can be 'start-part' 'finish-part' 'save-file' etc.
% argument should explain what file we are logging about


log_fname = 'logfile.txt';

fid = fopen(fullfile(folder, log_fname), 'a');

t = now();
date = datestr(t, 'yyyy-mm-dd');
time = datestr(t, 'HH:MM:SS');
log_message = sprintf('%s,%s,%s,%s\n', date, time, type, argument);
fprintf(fid, strrep(log_message, '\', '/'));  % Replacing the escape chars. '\g...\' trigger warning on Windows
fclose(fid);

% fprintf('Logging to folder %s, message %s', folder, log_message);