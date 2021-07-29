function mdp_table = make_mdp_table(experimenter, ts_snr_state, ...
    last_idx_before_skip, maestro_file, out_folder)

log_msg(out_folder, 'start-state-align', ...
    'Starting alignment of state events');

[mdp_table, ts_stats] = align_state_times(ts_snr_state, last_idx_before_skip, ...
    maestro_file.MDPData.MDPStates, out_folder);

mdp_table = process_mdp_table(mdp_table, ...
    maestro_file.MDPData.ratStates, experimenter);

log_msg(out_folder, 'end-state-align', ...
    'Finished alignment of state events');

if size(mdp_table, 1) == 0
    mdp_table = table();
else
    fname = fullfile(out_folder, 'mdp_table.mat');
    save(fname, 'mdp_table');
    log_msg(out_folder, 'save-mat', fname)
    fname = fullfile(out_folder, 'ts_fix_mdp_table.mat');
    save(fname, 'ts_stats');
    log_msg(out_folder, 'save-mat', fname)
end