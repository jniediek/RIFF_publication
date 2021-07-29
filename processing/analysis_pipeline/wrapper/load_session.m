function expdata = load_session(expdata, i)
% JN 2020-04-25

expdata.row = expdata.rat_table(i, :);
out_folder_session = expdata.folders.session_folders{i};
expdata.folders.out_folder_session = out_folder_session;


% load snr times
fname = fullfile(out_folder_session, 'snr_times.mat');
S = load(fname);
expdata.snr_times = S.snr_times;
log_msg(out_folder_session, 'load-mat', fname);