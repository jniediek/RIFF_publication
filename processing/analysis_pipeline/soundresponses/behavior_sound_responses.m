function behavior_sound_responses(sounds_table, data_folder, out_folder)
 
spiketime_files = dir(fullfile(data_folder, 'ch_*_spiketimes_snr.mat'));

channels_to_run = [];

for i = 1:length(spiketime_files)
    num = str2double(spiketime_files(i).name(4:5));
    channels_to_run = [channels_to_run num];
end

pre_trigger_ms = 2; %000;
post_trigger_ms = 3; %000;

bin_ms = .010;
bins = -pre_trigger_ms:bin_ms:post_trigger_ms;
n_bins = length(bins);

%n_sounds = height(sounds_table);

snd_categories = unique(sounds_table.soundname);
n_snd_categories = numel(snd_categories);

n_row = 6;
n_cols = 5;

for ch = channels_to_run
    
    fname = fullfile(data_folder, sprintf('ch_%02d_spiketimes_snr.mat', ch));
    S = load(fname);
    spiketimes = S.spiketimes_snr;
    
    fig = figure('Position', [0 0 1400 1000], 'Visible', 'off');
    annotation(fig,  'textbox', [.45 .9 .1 .1], 'string', ...
        sprintf('channel %d', ch), 'LineStyle', 'none')
    
    for i = 1:n_snd_categories
        counts = zeros(n_bins - 1, 1);

        c_snd = snd_categories(i);
        idx = sounds_table.soundname == c_snd;
        onsets = sounds_table.start_t(idx);
        pidx = i + n_cols*floor((i-1)/n_cols);
        subplot(n_row, n_cols, pidx)
        hold on
        for j = 1:length(onsets)
            onset = onsets(j);
            time_idx = (spiketimes >= onset - pre_trigger_ms) & ...
                (spiketimes <= onset + post_trigger_ms);
            stimes = spiketimes(time_idx) - onset;
            [N, ~] = histcounts(stimes, bins);
            counts = counts + N';
            plot(stimes, j * ones(1, sum(time_idx)), 'k.')
        end
        %bar(bins, counts, 1, 'EdgeColor', 'none')
        %plot([stim_onset_bbn stim_onset_bbn], [0 60]);
        %plot([stim_offset_bbn stim_offset_bbn], [0 60]);
        xlim([-pre_trigger_ms post_trigger_ms])
        ylim([0 length(onsets) + 1])
        % ylim([1 length(onsets)])
        title(sprintf('Sound: %s', c_snd), 'interpreter', 'none')
%         if i == length(bbn_levels)
%             xlabel('ms')
%         end
        subplot(n_row, n_cols, pidx + n_cols);
        bar(bins(1:end-1), counts, 1, 'EdgeColor', 'none');
    end
    fname = fullfile(out_folder, ...
        sprintf('ch_%02d_sounds_behavior.png', ch));
    
    print(fig, '-dpng', '-r300', fname);
    close(fig);
end