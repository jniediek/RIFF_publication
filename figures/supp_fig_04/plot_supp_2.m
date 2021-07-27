function plot_supp_2(my_axes, S, param, axlabel_flag)

ns_pre = S.ns_pre;
% ns_post = S.ns_post;
thr = .25;
dset = S.dset;
clear('S');


time_const = 29.997;

rats = 4:8;
days = 22:23;

start_time = .5; % sec after prev_fdb
stop_time = 9; % sec after prev_fdb

start_samp = round(start_time * time_const) + ns_pre;
stop_samp = round(stop_time * time_const) + ns_pre;

c = 0;

text_pos = [[0.18 1]; [.9 .2]; [.7 .2]];
text_horz_align = {'center', 'left', 'right'};

for irat = 1:5
    rat = rats(irat);
    for iday = 1:2
        day = days(iday);
        tstr = sprintf('Rat %d Day %d', rat, day - 21);
        speed = dset(irat, iday).speed;
        %time = dset(irat, iday).time;
        n_trials = size(speed, 1);
        
        
        r_speed = speed(:, start_samp:stop_samp);
        
        max_speed = max(abs(r_speed), [], 2);
        idx_slow = max_speed < thr;
        
        [ma, ima] = max(r_speed, [], 2);
        [mi, imi] = max(-r_speed, [], 2);
        idx_pos = (ma >= mi) & ~idx_slow;
        idx_neg = ~idx_pos & ~idx_slow;
        
        idxs = {idx_slow, idx_pos, idx_neg};
        
        c = c + 1;
        %ax = subplot(5, 2, c);
        ax = my_axes{c};
        axes(ax);
        %pbaspect(ax, [1 1 1])
        ax.NextPlot = "add";
        ax.Title.String = tstr;
        ax.Title.FontWeight = "normal";
        ax.Title.FontSize = param.fontsize_label;
        
        ax.XLim = [-.1 1];
        ax.YLim = [-1 .1];
        col = zeros(1, n_trials, 3);
        for i = 1:3
            idx = idxs{i};
            plot(ma(idx), -mi(idx), '.', 'Color', param.color_options.cluster_colors(i, :))
            col(1, idx, :) = repmat(param.color_options.cluster_colors(i, :), sum(idx), 1);
            
        end
        % write counts
        for i = 1:3
            text(text_pos(i, 1), text_pos(i, 2), sprintf('%d', sum(idxs{i})), ...
                'FontSize', 7, 'Color', ...
                param.color_options.cluster_colors(i, :), 'Units', ...
                'Normalized', 'HorizontalAlignment', text_horz_align{i}, "FontName", ...
                param.font_name)
        end
        
        % separation lines
        sepcol = [.7 .7 .7];
        plot(ax, [0 thr], -thr * [1 1], 'color', sepcol)
        plot(ax, [thr thr], [-thr 0], 'color', sepcol)
        plot(ax, [thr 1], [-thr -1], 'color', sepcol)
        
        tick = [-pi 0 pi] / 4;
        ax.YTick = tick;
        ax.YTickLabel = tick / pi * 180;
        ax.XTick = tick;
        ax.XTickLabel = tick / pi * 180;
        
        if ~axlabel_flag.x(c)
            ax.XTickLabel = [];
        end
        
        if ~axlabel_flag.y(c)
            ax.YTickLabel = [];
        end
        
        
    end
end
ax = my_axes{9}; %subplot(5, 2, 9);
axes(ax);
ax.XLabel.String = {"Max. speed" "[deg/sec]"};
ax.XLabel.FontSize = param.fontsize_label;
ax.YLabel.String = {"Min. speed", "[deg/sec]"};
ax.YLabel.FontSize = param.fontsize_label;
text(text_pos(3, 1) - .15, text_pos(3, 2), 'N = ', 'Units', 'normalized', 'HorizontalAlignment', text_horz_align{3}, 'FontSize', 7)
%
% set(fig.Children, 'FontName', 'Calibri'); %, 'FontSize', 10);
% print('-r300', '-dpng', 'fig_behav_supp_2.png');
% fig.Renderer = 'Painters';
% print('-dsvg', 'fig_behav_supp_2.svg');
