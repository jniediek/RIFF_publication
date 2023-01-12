function silenced_times = load_silenced_times(folder, sampling_rate)
% JN 2021-02-12
% Probably this works only for Deuteron at the moment, not for TBSI

DT2_SAMPLES = 2^18;

fname_times = fullfile(folder, 'ks_output', 'ts_large.mat');
tvar = load(fname_times);

n_DT2_per_raw = ceil(max(vertcat(tvar.noise_loc_arr{:}))/DT2_SAMPLES);
fprintf('Guessing that %d input files contributed to each "raw" file\n', ...
    n_DT2_per_raw);
if n_DT2_per_raw ~= 50
    error('Strange number of %d input files per raw file detected, comment out this error to continue', ...
        n_DT2_per_raw)
end

n_noise = length(tvar.noise_loc_arr);
noise_snr_times = cell(n_noise, 1);

times_one_file = (0:(DT2_SAMPLES - 1))/sampling_rate;


for i = 1:n_noise
    t_noise = tvar.noise_loc_arr{i};
    if ~any(t_noise)
        continue
    end
    % convert to index inside one file
    rel_idx = mod(t_noise - 1, DT2_SAMPLES) + 1;
    
    % which files are we in?
    files_i = fix((t_noise - 1)/DT2_SAMPLES) + 1;
    
    % another consistency check
    if files_i(end) > n_DT2_per_raw
        error('Requesting times from file %d of a raw file, which should not exist', files_i(end))
    end
    
    % shift to correct position
    files_i = (i - 1) * n_DT2_per_raw + files_i;
    
    these_starts = tvar.SNR_timestamps_start_dt2(files_i);
    
    noise_snr_times{i} = zeros(length(rel_idx), 1);
    
    for j = 1:length(rel_idx)
        noise_snr_times{i}(j) =  these_starts(j) + times_one_file(rel_idx(j));
    end
   
end


silenced_times = vertcat(noise_snr_times{:});

% another consistency check
if any(diff(silenced_times) < 0)
    error('Time inconsistency in silenced time detection');
end
