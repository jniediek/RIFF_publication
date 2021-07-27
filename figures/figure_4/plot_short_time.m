function objects = plot_short_time(ax1, ax2, param, trials, loc, tab_bhv, zones, ...
    start_time, annotate)

ax = ax1;
ax.FontSize = param.fontsize_ax;
axes(ax)
hold on
ax.YLim = pi * [-1 1];
ax.Color = 'w';

if annotate
    ax.YLabel.String = {'Angular position', '[degrees]'};
    ax.YLabel.FontSize = param.fontsize_label;
end

ax.YTick = (-1:.5:1) * pi;
ax.YTickLabel = (-2:2) * 90;
ax.XTickLabel = '';

p = add_lines(ax, trials, start_time, zones, true, param.time_colors);

scatter(loc.Time - start_time, loc.Angle, param.dot_size, loc.Time, ...
    'filled')

% add the nosepokes
idx = tab_bhv.event_type == 'nosepoke';
tab_poke = tab_bhv(idx, :);
t_angle = zeros(height(tab_poke), 1);
t_angle_t = zeros(height(trials), 1);

for i = 1:6
    idx = ismember(tab_poke.port, [2*i-1 2*i]);
    t_angle(idx) = zones.AngleCenter(zones.AreaNum == i);
    
    idx = trials.area == i;
    t_angle_t(idx) = zones.AngleCenter(zones.AreaNum == i);
end

tab_poke.angle = t_angle;

pz = plot(ax, tab_poke.start_t - start_time, tab_poke.angle, 'wv', ...
    'MarkerFaceColor', 'k', 'MarkerSize', param.poke_marker_size);
p = [p pz];

% add the rewards/failures
trials.area_angle = t_angle_t;
types = ["reward", "negative"];
styles = {'g', 'r'};
q = [0 0];
for i = 1:2
    idx = trials.type == types{i};
    if any(idx)
        q(i) = plot(ax, trials.t_fdb(idx) - start_time, ...
            trials.area_angle(idx), 'k^', ...
            'MarkerFaceColor', styles{i}, 'MarkerSize', ...
            param.poke_marker_size);
    end
end
objects = [p q];

ax.XLim = [-1, trials.t_fdb(end) + 2 - start_time];


time_delta = median(diff(loc.Time));

dd = diff(double(loc.Angle));
dd(abs(dd) > 1) = 0;

dd = dd/time_delta ;

smoothed = conv(dd, ones(50, 1)/50, 'same');

ax = ax2;
axes(ax)
hold on

add_lines(ax, trials, start_time, zones, false, param.time_colors)
scatter(loc.Time(1:end-1) - start_time, smoothed, param.dot_size, ...
    loc.Time(1:end-1), 'filled');

ax.FontSize = param.fontsize_ax;

ax.XLim = [-1, trials.t_fdb(end) + 2 - start_time];

ytick = [-pi 0 pi] / 4;
ax.YTick = ytick;
ax.YTickLabel = ytick / pi * 180;
ax.YLim = [-1 1] * 1.4 * max(abs(smoothed));

ax.XLabel.String = 'Time [sec]';
ax.XLabel.FontSize = param.fontsize_label;

if annotate
    ax.YLabel.String = {'Angular speed', '[degrees/sec]'};
    ax.YLabel.FontSize = param.fontsize_label;
end
