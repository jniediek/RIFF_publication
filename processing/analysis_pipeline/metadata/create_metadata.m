function metadata = create_metadata(expdata, behavior_file_no, ...
    table_no, snr_times)

out_folder = expdata.folders.out_folder_session;
AO_plot_SNR_trigs(snr_times, out_folder);

if behavior_file_no > 0
    metadata.behavior_table = ...
        make_behavior_table(expdata.folders.behavior, ...
        expdata.experimenter, behavior_file_no, snr_times, out_folder);
end

fname = sprintf('Tables_%d.mat', table_no);
full_fname = fullfile(expdata.folders.maestro, fname);
maestro_file = load(full_fname);
log_msg(out_folder, 'load-mat', full_fname);

if isfield(maestro_file, 'MDPData')
    idx_snr_state = snr_times.EventType == 'state';
    ts_snr_state = snr_times(idx_snr_state, :);
    last_idx_before_skip = find_skipped_mpx_file(ts_snr_state);
    
    metadata.mdp_table = make_mdp_table(expdata.experimenter, ...
        ts_snr_state.Time, last_idx_before_skip, maestro_file, out_folder);
    
end

sound_metadata = make_sounds_table(snr_times, maestro_file, expdata);

% copy the sound fields
fn = fieldnames(sound_metadata);
for i = 1:length(fn)
    metadata.(fn{i}) = sound_metadata.(fn{i});
end