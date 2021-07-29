function table = get_session_table(experimenter, year, month)
% JN 2019-04-03

[riff_folder, ~, ~] = fileparts(which('main'));
log_folder = fullfile(riff_folder, '..', 'session_logs');

if ~isfolder(log_folder)
    error('Folder %s not found, needed for database mode', log_folder)
end

% Read session database
fname = fullfile(log_folder, char(experimenter), ...
    num2str(year), sprintf('%04d-%02d.csv', year, month));

opts = detectImportOptions(fname);
opts = setvartype(opts, 'Experimenter', 'categorical');

table = readtable(fname, opts);
