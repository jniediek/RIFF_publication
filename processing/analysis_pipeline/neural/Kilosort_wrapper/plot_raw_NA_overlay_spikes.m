function plot_raw_NA_overlay_spikes(final_db, mdata)
% === Load the first raw_data_file ====
f_name = mdata.first_raw_f_name;
raw_NA = load(f_name);
n_channels = size(raw_NA.data, 2);


h_f = figure();
h_ax = axes(h_f);
n_samples = 4*1e5;

% == Plot the raw NA - turned to double, mean-reduced ===
if strcmp(mdata.neural_mode,'deuteron')
    SAMPLING_RATE = 32000;
    NA_data = raw_NA.data(1:n_samples, :);
    sound_channel = identify_sound_channel(NA_data);
    if sound_channel > 0
        NA_data(:, sound_channel) = 2^15;
    end
    to_uV_fact = raw_NA.BitResolution;
elseif strcmp(mdata.neural_mode,'tbsi')
    SAMPLING_RATE = 22000;
    NA_data(:,[1:4,6:32]) = raw_NA.data(1:n_samples,:);
    sound_channel = -1;
    n_channels = 32;
    NA_data(:, 5) = 2^15;
    to_uV_fact = raw_NA.BitResolution/raw_NA.Gain;
else
    error('Neural mode not supported!!!');
end
NA_data = mean_reduce_16x2_raw_data(double(NA_data) - 2^15, mdata.is_new_layout);
[NA_data, ~] = flatten_noise_areas(NA_data, false, mdata.neural_mode, to_uV_fact);
if strcmp(mdata.neural_mode,'deuteron')
    rel_times = ((1:(2^18))/SAMPLING_RATE)';
    rel_times_rep = repmat(rel_times, [1, length(raw_NA.starttimes_snr)]);
    rel_times_rep_shifted = rel_times_rep + raw_NA.starttimes_snr';
    t_arr = rel_times_rep_shifted(:);
elseif strcmp(mdata.neural_mode,'tbsi')
    t_arr = raw_NA.timestamps_snr;
else
    error('Neural mode not supported!!!');
end

plot(h_ax, t_arr(1:n_samples), NA_data + (1:n_channels)*800, 'k');
ylim(h_ax, [-1000 33*800]);
xlim(h_ax, [t_arr(n_samples/2+3000*SAMPLING_RATE/1000)  t_arr(n_samples/2+3600*SAMPLING_RATE/1000)]);
hold(h_ax, 'on');
xlabel(h_ax, 'Time (sample)');
ylabel(h_ax, 'Electrodes');
title(h_ax, 'Superposition of the found clusters on raw NA');
set(h_f, 'position', [195 171 1649 927]);
tightfig(h_f);
set(h_f, 'position', [195 171 1649 927]);

% === Add the located spikes ====

for i = 1:length(final_db)
    curr_SNR_ts = final_db(i).sp_SNR_ts(final_db(i).sp_SNR_ts < t_arr(end));
    curr_amps = final_db(i).spike_amps(final_db(i).sp_SNR_ts < t_arr(end));
    elec_num = final_db(i).elec_num + randn()*0.1;
   
    h = plot(h_ax, curr_SNR_ts, (curr_amps + ones(size(curr_amps))*elec_num*800)', 'o', ...
        'linewidth', 3, 'MarkerSize', 35);
    if numel(h)
        h.Color(4) = 0.5;
    end
end

% === print image ===

f_name = fullfile(mdata.ks_output_dir, 'raw_NA_with_spikes');
print_plot_to_file(h_f, f_name, mdata);
end
