function p = add_lines(ax, trials, start_time, zones, do_port_positions, time_colors)
% JN 2020-07-02
lw = 2;

if do_port_positions
    for i = 1:6
        plot(ax, [-1 trials.t_fdb(end) + 2 - start_time], ...
            [1 1] * zones.AngleCenter(zones.AreaNum == i), 'color', ...
            [.8 .8 .8 .5]);
        %text(trials.t_fdb(end) - start_time, angle_table.Angle(i) - .12, ...
        %    num2str(angle_table.PortNo(i)), 'color', 'w', 'fontsize', 16)
    end
end

fieldnames = {'t_att', 't_tgt', 't_fdb'};
%colors = {'k-', 'g-', 'm-'};


p = [0 0 0];
for i = 1:height(trials)
    pos = [trials.t_att(i) - start_time, - pi, ...
        trials.t_fdb(i) - trials.t_att(i),  2*pi];
    rectangle(ax, 'Position', pos, 'facecolor', [.7, .7, .7, .5], ...
        'edgecolor', 'none')
    
    for j = 1:3
        times = trials.(fieldnames{j})(i) - start_time;
        p(j) = plot(ax, [1 1] * times, [-1 1] * pi, 'Color', time_colors(j, :), ...
            'linewidth', lw);
    end
    
end