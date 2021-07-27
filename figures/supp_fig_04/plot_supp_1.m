function plot_supp_1(ax, S, param)
% JN 2021-03-17 turn this into a panel of a bigger figure

% JN 2020-12-17 plot example running


ns_pre = S.ns_pre;
thr = .25;
dset = S.dset;

time_const = 29.997;

rats = 4:5;
days = 22:23;
%
start_time = .5; % sec after prev_fdb
stop_time = 9; % sec after prev_fdb

start_samp = round(start_time * time_const) + ns_pre;
stop_samp = round(stop_time * time_const) + ns_pre;


time_vars = {'t_att', 't_tgt', 't_fdb'};
time_colors = param.color_options.time_colors;

irat = 1;
iday = 1;
rat = rats(irat);


day = days(iday);
tstr = sprintf('Rat %d Day %d', rat, day - 21);
speed = dset(irat, iday).speed;
time = dset(irat, iday).time;
n_trials = size(speed, 1);
trials = dset(irat, iday).trials;

r_speed = speed(:, start_samp:stop_samp);

max_speed = max(abs(r_speed), [], 2);
idx_slow = max_speed < thr;

[ma, ima] = max(r_speed, [], 2);
[mi, imi] = max(-r_speed, [], 2);
idx_pos = (ma >= mi) & ~idx_slow;
idx_neg = ~idx_pos & ~idx_slow;

idxs = {idx_slow, idx_pos, idx_neg};

ax.Title.String = tstr;
ax.Title.FontWeight = "normal";
ax.Title.FontSize = param.fontsize_label;
ax.NextPlot = "add";

lgd_objects = [];

for itype = 1:3
    for i = 1:n_trials
        t_times = trials.(time_vars{itype})(i) - trials.t_fdb_prev(i);
        l = plot([1 1] * t_times, [-2 2], 'Color', time_colors(itype, :), 'LineWidth', 1);
    end
    lgd_objects = [lgd_objects l];
end

plot([0 0], [-2 2], 'Color', time_colors(3, :), 'LineWidth', 1)
for islow = [3 2 1]
    l = plot(time(idxs{islow}, :)', speed(idxs{islow}, :)', ...
        'Color', param.color_options.cluster_colors(islow, :), 'LineWidth', 1.2);
    %lgd_objects = [lgd_objects l(1)];
end
% 
% temp = lgd_objects(end);
% lgd_objects(end) = lgd_objects(end-2);
% lgd_objects(end-2) = temp;

plot([1 1] * start_time, [-2 2], 'k--', 'LineWidth', 1.5)
plot([1 1] * stop_time, [-2 2], 'k--', 'LineWidth', 1.5)

ax.XLim = [-3 12];
ax.YLim = [-1.5 1.5];

ytick = [-pi 0 pi] / 4;
ax.YTick = ytick;
ax.YTickLabel = ytick / pi * 180;
%ax.YLim = [-1 1] * 1.4 * max(abs(smoothed));


ax.XLabel.String = 'Time [sec]';
ax.YLabel.String = ["Angular speed", "[deg/sec]"];

ax.XLabel.FontSize = param.fontsize_label;
ax.YLabel.FontSize = param.fontsize_label;

% the legend
strings = {"Attention", "Target", "Feedback"}; %, "Sit", "Run clockwise", ['Run counter-' newline 'clockwise']};
lgd = legend(ax, lgd_objects, strings, "Position", [.4 .95 .2 .05]); %[.65 .45 .2 .2]);
lgd.NumColumns = 3;
%lgd.EdgeColor =  param.legend_edge_color;
lgd.EdgeColor = "none";
lgd.FontSize = param.fontsize_label;
%lgd.EdgeColor = 
%lgd.Title.String = 'Behavioral cluster';
