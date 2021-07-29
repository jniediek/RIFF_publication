function check_mdp_timing(mdp_table, stats, fig)
% JN 2020-04-28
figure(fig)
if ismember('strig', mdp_table.Properties.VariableNames)
    mode = 'strig';
else
    mode = 'ttrig';
end

switch mode
    case 'ttrig'
        
        % specific to this method: find points where the ttrig column increased
        ts_idx = find(diff(mdp_table.ttrig) > 1e-5);
        %ts_idx_rep = ts_idx(ts_idx > 1);
        
        % unique(mdp_table.(rel_col)(ts_idx_rep - 1))
        
        % these are the increased ttrig times
        ts_mdp = mdp_table.ttrig(ts_idx + 1);
        ts_snr = mdp_table.start_t(ts_idx);
    case 'strig'
        ts_mdp = mdp_table.strig;
        ts_snr = mdp_table.start_t;
end

stat = diff(ts_mdp) - diff(ts_snr);
outliers = sum(abs(stat) > .01);
ts_snr_hours = (ts_snr - ts_snr(1))/3600;

subplot(5, 3, 4)
plot(ts_snr_hours, ts_mdp - ts_snr - ts_mdp(1) + ts_snr(1), 'k.');
ylabel('SnR vs Maestro drift [s]')
xlabel('Session time [h]')
xlim([ts_snr_hours(1) ts_snr_hours(end)]);

subplot(5, 3, 5)
plot(ts_snr_hours(1:end-1), stat * 1000, 'k.')
ylim([-1 1] * 10)
ylabel('Diff of diff [ms]')
xlabel('Session time [h]')
xlim([ts_snr_hours(1) ts_snr_hours(end)]);

subplot(5, 3, 6)
histogram(stat*1000, -10:.5:10, 'edgecolor', 'none')
xlabel('Diff of diff [ms]')
ylabel('Count')
title(sprintf('Outliers (>10 ms): %d', outliers));

line_1 = sprintf("State alignment. Column used: %s", mode);

annotation('textbox', [.05 .9 .4 .05], 'String', line_1, ...
    'interpreter', 'none', 'edgecolor', 'none');

if isfield(stats, 'onset')
    add_str = "Onset time alignment statistics:";
    s = stats.onset;
    a = find(s.chosen);
    for i = -1:1
        if a + i < 1
            continue
        end
        row = s(a + i, :);
        tr = sprintf("start_snr: %d start_mdp: %d std: %.5f normr: %.5f outliers: %.0f", ...
            row.start_t1, row.start_t2, row.std, row.normr, row.outliers);
        add_str = [add_str tr];
        
    end
    annotation('textbox', [.05, .85, .4, .05], 'String', add_str, ...
        'interpreter', 'none', 'edgecolor', 'none')
end

if isfield(stats, 'fill')
    add_str = "Gap at 3 a.m. time fill statistics:";
    s = stats.fill;
    a = find(s.chosen);
    for i = -1:1
        if a + i <= 0
            continue
        end
        row = s(a + i, :);
        tr = sprintf('n_insert: %d std: %.5f normr: %.5f outliers: %.0f', ...
            row.n_insert, row.ddiff_std, row.normr, row.outliers);
        add_str = [add_str tr];
        
    end
    annotation('textbox', [.5, .85, .4, .05], 'String', add_str, ...
        'interpreter', 'none', 'edgecolor', 'none')
end

