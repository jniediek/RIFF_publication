function expdata = prepare_session_folders(data_folder, rat_num)
% JN 2020-04-24

fname = fullfile(data_folder,  'rat_sessions.csv');
table_rat_sessions = readtable(fname);

idx = (table_rat_sessions.DoProcess == 1) & ...
    (table_rat_sessions.Rat == rat_num);


rat_table = table_rat_sessions(idx, :);

if ~any(idx)
    logstr = sprintf("Skipping requested analysis of rat %d", rat_num);
    log_msg(data_folder, 'skip-analysis', logstr);
    expdata.rat_table = table();
    return
end

fnames = {'expdata', 'snr_times'};
S = struct();

for i = 1:length(fnames)
    tfname = fullfile(data_folder, strcat(fnames{i}, '.mat'));
    if isfile(tfname)
        temp = load(tfname, fnames{i});
        S.(fnames{i}) = temp.(fnames{i});
        log_msg(data_folder, 'load-mat', tfname);
    else
        % actually this is a complete error case
        logstr = sprintf('Could not load file %s!', tfname);
        log_msg(data_folder, 'file-not-found', logstr);
    end
end

expdata = S.expdata;
if strcmp(expdata.neural_mode, 'deuteron') && expdata.has_neural_data %AP 080520, AP 120520
    fname = fullfile(data_folder, 'table_filestarts.mat');
    if isfile(fname)
        expdata.do_deuteron = true;
        temp = load(fname, 'table_filestarts');
        S.table_filestarts = temp.table_filestarts;
        log_msg(data_folder, 'load-mat', fname);
    else
        expdata.do_deuteron = false;
        log_msg(data_folder, 'file-not-found', fname);
    end
    
    fname = fullfile(data_folder, 'deuteron_autolog_parsed.mat');
    if isfile(fname)
        temp = load(fname, 'TTL');
        S.TTL_autolog = temp.TTL;
        log_msg(data_folder, 'load-mat', fname);
        expdata.has_autolog = true;
    else
        log_msg(data_folder, 'file-not-found', fname)
        expdata.has_autolog = false;
    end
    
    fname = fullfile(data_folder, 'table_ttls.mat');
    if isfile(fname)
        temp = load(fname, 'table_ttls');
        S.TTL_logger = temp.table_ttls;
        log_msg(data_folder, 'load-mat', fname);        
        expdata.has_table_ttls = true;        
    else
        log_msg(data_folder, 'file-not-found', fname);
        expdata.has_table_ttls = false;
    end
    
    log_msg(data_folder, 'do-deuteron', ...
        sprintf('Do deuteron is %d', expdata.do_deuteron));
else % AP 080520
    expdata.do_deuteron = false;
end
% create a folder for this rat
out_folder_rat = fullfile(data_folder, sprintf('rat_%d', rat_num));
expdata.rat_table = rat_table;

if ~isfolder(out_folder_rat)
    mkdir(out_folder_rat);
    log_msg(data_folder, 'create-folder', out_folder_rat);
end
init_logfile(out_folder_rat);


expdata.folders.out_folder_rat = out_folder_rat;


% create a subfolder for each session and collect all relevant tables
n_sessions = height(rat_table);

all_snr_times = cell(n_sessions, 1);
all_filestarts = cell(n_sessions, 1);
all_table_ttls = cell(n_sessions, 1);
all_table_ttls_autolog = cell(n_sessions, 1);

for i = 1:n_sessions
    [snr_times, deuteron_tables, expdata] = ...
        prepare_one_session_folder(expdata, i, S);
    
    all_snr_times{i} = snr_times;
    if expdata.do_deuteron %AP 080520
        all_filestarts{i} = deuteron_tables.table_filestarts;
        if expdata.has_table_ttls
            all_table_ttls{i} = deuteron_tables.table_ttls;
        end
        if expdata.has_autolog
            all_table_ttls_autolog{i} = deuteron_tables.table_ttls_autolog;
        end
    end
end

snr_times = vertcat(all_snr_times{:});
fname = fullfile(out_folder_rat, 'snr_times');
save(fname, 'snr_times');
log_msg(out_folder_rat, 'save-mat', fname);

table_filestarts = vertcat(all_filestarts{:});
table_ttls = vertcat(all_table_ttls{:});
table_ttls_autolog = vertcat(all_table_ttls_autolog{:});

names = {'table_filestarts', 'table_ttls', 'table_ttls_autolog'};

for i = 1:3
    fname = fullfile(out_folder_rat, names{i});
    save(fname, names{i});
    log_msg(out_folder_rat, 'save-mat', fname)
end

expdata.table_filestarts = table_filestarts;
expdata.table_ttls = table_ttls;
expdata.table_ttls_autolog = table_ttls_autolog;