function snr_times = AO_get_snr_times(folders)
% JN 2019-02-11
% JN 2020-05-07

fname = fullfile(folders.results, 'snr_times.mat');

if isfile(fname)
    S = load(fname);
    log_msg(folders.results, 'load-mat', fname);
    snr_times = S.snr_times;
else
    snr_times = AO_process_ttls(folders.logging, folders.results);
    [snr_times, time_to_add] = AO_monotonize_timestamps(snr_times);
    save(fname, 'snr_times', 'time_to_add');
    log_msg(folders.results, 'save-mat', fname);
end