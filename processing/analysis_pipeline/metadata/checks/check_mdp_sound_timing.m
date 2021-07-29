function check_mdp_sound_timing(mdp_table, sounds_table, stats, ...
    experimenter, fig)
% JN 2020-04-30
% refactor the code

% JN 2020-05-24
% The strig column is not really suited for the mdp sound
% timing checks because time passes between strig is taken and the
% actual playing of sounds. start_t versus start_t is more relevant, as
% well as ttrig.

figure(fig);

outlier_max = .005; % seconds

switch experimenter
    case "nightRIFF"
        rel_col = 'type';
        ymax = .1; % seconds expected maximal jitter to look at
        rel_lines = {"center", "repeat"};
        ttrig_shift = -1;
    case "Maciej"
        rel_col = 's_areatype';
        ymax = .01; % seconds expected maximal jitter to look at
        rel_lines = {"A", "B", "C", "D", "NPWait", "Feedback", ...
            "AttenSound", "AttenSoundWait", "Warning"};
        ttrig_shift = 0;
    otherwise
        error('Experimenter not found')
end

% the first sound that corresponds to the MDP (not an init sound)
rel_bline_start = find(sounds_table.bline, 1, 'first');

% the line in mdp_table where sline increased
mdp_idx = find([0; diff(mdp_table.sline)] & ...
    (mdp_table.sline >= rel_bline_start));

% the entries in sounds_table that aren't init sounds
rel_bline = sounds_table.bline(sounds_table.bline > 0);

% assert that sounds_table.bline and mdp_table.sline essentially correspond
assert(all(rel_bline == mdp_idx));

% the lines in mdp_table where the sound-related trigger increased
idx_ttrig = find([0; (diff(mdp_table.ttrig) > 1e-5)]) + ttrig_shift;

assert(all(rel_bline == idx_ttrig))

ts_snr = sounds_table.start_t(sounds_table.bline ~=0);

ts_snr_mdp = mdp_table.start_t(rel_bline);

ts_mdp = mdp_table.ttrig(sounds_table.bline(sounds_table.bline > 0) + 1);

stat = diff(ts_mdp) - diff(ts_snr_mdp);
outliers = sum(abs(stat) > outlier_max);

ts_snr_hours = (ts_snr - ts_snr(1))/3600;

subplot(5, 3, 9)
plot(ts_snr_hours, ts_mdp - ts_snr - ts_mdp(1) + ts_snr(1), 'k.');
ylabel('SnR vs Maestro drift [s]')
xlabel('Session time [h]')
xlim([ts_snr_hours(1) ts_snr_hours(end)]);

subplot(5, 3, 10)
hold on
sndtypes = unique(sounds_table.soundtype);
n_sndtypes = length(sndtypes);
for_legend = cell(n_sndtypes, 1);
for i = 1:n_sndtypes
    for_legend{i} = string(sndtypes(i));
    idx = find(sounds_table.soundtype == sndtypes(i));
    idx = idx(idx < length(ts_snr_hours));
    plot(ts_snr_hours(idx), stat(idx) * 1000, '.')
end
legend(for_legend)
ylim([-1 1] * ymax * 3* 1000)
ylabel('Diff of diff [ms]')
xlabel('Session time [h]')
xlim([ts_snr_hours(1) ts_snr_hours(end)]);

subplot(5, 3, 11)
bins = linspace(-ymax*1000, ymax*1000, 200);
histogram(stat*1000, bins, 'edgecolor', 'none')
xlabel('Diff of diff [ms]')
ylabel('Count')
tt = title(sprintf('Outliers (diff(ttrig) - diff(snd_snr) > %.0f ms): %d', ...
    outliers, outlier_max*1000));
tt.Interpreter = 'none';

subplot(5, 3, 12)
hold on
title('MDP state to sound onset')
ylabel('ms')

subplot(5, 3, 13)
xlabel('ms')
hold on

idx_sline_pre_change = find(diff(mdp_table.sline));
pre_sline_states = unique(mdp_table.(rel_col)(idx_sline_pre_change));

for i_t = 1:length(pre_sline_states)
    
    l_idx = find(mdp_table.(rel_col) == pre_sline_states(i_t));
    
    l_idx = intersect(l_idx, idx_sline_pre_change);
    
    local_stat = (sounds_table.start_t(mdp_table.sline(l_idx + 1)) - ...
        mdp_table.start_t(l_idx + 1)) * 1000;
    
    subplot(5, 3, 12)
    plot((mdp_table.start_t(l_idx + 1) - mdp_table.start_t(1))/3600, ...
        local_stat, '.');
    
    subplot(5, 3, 13)
    histogram(local_stat, -50:4:600, 'edgecolor', 'none', ...
        'facealpha', .6)
end

subplot(5, 3, 12)
legend(rel_lines)
ylim([-50 600])
xlabel('Session time [h]');

subplot(5, 3, 14)
hold on

subplot(5, 3, 15)
hold on

bins = linspace(-50, 500, 200);
for i = 1:n_sndtypes
    idx = find((sounds_table.soundtype == sndtypes(i)) & ...
        (sounds_table.bline > 0));
    idx = idx(idx < length(ts_snr_hours));
    l_data = sounds_table.start_t(idx) - ...
        mdp_table.start_t(sounds_table.bline(idx));
    subplot(5, 3, 14)
    plot(ts_snr_hours(idx), l_data, '.')
    
    subplot(5, 3, 15)
    histogram(l_data*1000, bins, 'edgecolor', 'none', 'facealpha', .6);
end

xlabel('ms')

subplot(5, 3, 14)
legend(for_legend);
xlim([ts_snr_hours(1) ts_snr_hours(end)])
title('bline to sound onset')
ylabel('sec')
xlabel('Session time [h]')

line_1 = "Sound timestamp alignment by mdp_table";

annotation('textbox', [.05 .53 .4 .05], 'String', line_1, ...
    'interpreter', 'none', 'edgecolor', 'none');

if isfield(stats, 'stats_sum')
    add_str = "Sounds time alignment statistics:";
    s = stats.stats_sum;
    a = find(s.chosen);
    for i = -1:1
        if a + i <= 0
            continue
        end
        row = s(a + i, :);
        tr = sprintf("start_snr: %d start_mdp: %d percent outliers: %.0f", ...
            row.start_t1, row.start_t2, row.outlier*100);
        add_str = [add_str tr];
        
    end
    annotation('textbox', [.05, .48, .4, .05], 'String', add_str, ...
        'interpreter', 'none', 'edgecolor', 'none')
end

end