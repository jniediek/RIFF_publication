function expdata = run_from_database(expdata)
% JN 2019-04-02
% JN 2020-04-23

% run pipeline from a CSV file of session information
session_table = get_session_table(expdata.experimenter, expdata.year, ...
    expdata.month);

idx = (session_table.Experimenter == expdata.experimenter) & ...
    (session_table.Year == expdata.year) & ...
    (session_table.Month == expdata.month) & ...
    (session_table.Day == expdata.day);

session_table = session_table(idx, :);

if ~any(session_table.DoProcess)
    expdata.errorstate = true;
    return
else
    expdata.errorstate = false;
end

folders = create_folder_names(expdata);
expdata.folders = folders;

% create output folder
if ~isfolder(folders.results)
    mkdir(folders.results)
        log_msg(folders.results, 'create-folder', ...
        sprintf('creating folder %s\n', folders.results));
    init_logfile(folders.results);
else
    log_msg(folders.results, 'start-analysis', 'starting analysis');
end

save(fullfile(folders.results, 'expdata.mat'), 'expdata');

session_table.SessionID = (1:height(session_table))';

% save the session table to the folder
fname = fullfile(folders.results, 'rat_sessions.csv');
writetable(session_table, fname);
log_msg(folders.results, 'save-csv', ...
    sprintf('Saved session table %s', fname));

% always create or load the snr times. At this point, no fixing is done
AO_get_snr_times(folders);

% if appropriate, do the deuteron preparation
if expdata.has_neural_data && strcmp(expdata.neural_mode, 'deuteron')
        DT_deuteron_preparation(expdata.folders); 
        
end

