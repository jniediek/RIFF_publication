function plot_error_data(ax, param)
% Last modification: JN 2021-01-28

S = load(fullfile('..', 'data', 'error_data.mat'));
data_table = S.data_table;

axes(ax);
ax.NextPlot = "add";
grid on;

cols = {'N_correct', 'N_at_prev_port', 'N_other_err', 'N_not_at_port'};
%colors = {[0 .5 0], [.7 .4 0], 'b', 'k'};
colors = {[0.4660 0.6740 0.1880], [0.9290 0.6940 0.1250], [0.3010 0.7450 0.9330], param.symbol_color};
by_rat = zeros(5, 4);


for icol = 1:4
    d = zeros(1, 4);
    c = 1;
    for day = 22:23
        for half = 1:2
            idx = (data_table.Day == day) & (data_table.Half == half);
            temp = data_table.(cols{icol})(idx)./data_table.N(idx);
            temp = temp * 100;
            d(c) = mean(temp);
            by_rat(:, c) = temp;
            c = c + 1;
        end
    end
    
    plot(fliplr(d), 1:4, 'color', colors{icol}, 'linewidth', param.linewidth_error)
    
    for j = 1:5
        if icol == 1
            linestyle = '-';
        else
            linestyle = 'none';
        end
        l = plot(fliplr(by_rat(j, :)), 1:4, 'marker', ...
            param.rat_symbols{j}, 'color', colors{icol}, 'linestyle', linestyle, ...
            'markerfacecolor', colors{icol}, 'linewidth', .8, ...
            'markersize', param.rat_symbol_size);
        
        l.Annotation.LegendInformation.IconDisplayStyle = 'off';
        
    end
end

lgd = legend('Correct port', ['Port of' newline 'last reward'], ...
    'Other port', 'Not at port');
lgd.FontSize = param.fontsize_label;
lgd.EdgeColor = param.legend_edge_color;
lgd.Position = [.86 ax.Position(2)+.01 .01 .16];
lgd.NumColumns = 1;
lgd.Title.String = ['Location at' newline 'feedback sound'];


ax.YLim = [.5 4.5];
ax.XLim = [0 90];
ax.XTick = [0 25 50 75];
ax.FontSize = param.fontsize_ax;
ax.XLabel.String = {'Loc. at feedback sound [%]'};
ax.XLabel.FontSize = param.fontsize_label;

ax.YTick = 1:4;
ax.YTickLabel = fliplr({'1:1', '1:2', '2:1', '2:2'});
%ax.YLabel.String = 'Observation Period';
ax.YLabel.FontSize = param.fontsize_label;