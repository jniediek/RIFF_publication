function plot_cluster_stats(all_axes, stat_data, param)
% JN 2020-12-14
% JN 2021-01-29

rel_cols = {'N_slow', 'N_pos', 'N_neg'};
for irat = 1:2
    ax = all_axes{irat};
    grid on
    rel_data = stat_data(stat_data.Rat == irat + 3, rel_cols);
    plotdata = flip(table2array(rel_data), 1);
    plotdata = plotdata./sum(plotdata, 2) * 100;
    ba = barh(ax, 1:4, plotdata, param.barheight, 'stacked', ...
        'edgecolor', 'none');
    
    for ib = 1:3
        ba(ib).FaceColor = param.cluster_colors(ib, :);
    end
    
    if irat < 3
        ax.YTick = [1 2 3 4];
        ax.YTickLabel = flip({'1:1', '1:2', '2:1', '2:2'});
        ax.YLabel.String = sprintf('Rat %d', stat_data.Rat(irat + 3)); %{'Observation',  'period'};
        ax.YLabel.FontSize = param.fontsize_label;
        ax.YLabel.FontWeight = "bold";
    else
        ax.YTick = [];
    end
    ax.Box = 'off';
    ax.YLabel.FontSize = param.fontsize_label;
    
    
    ax.YLim = [.6 4.4];
    
    
    %ax.Title.String = sprintf('Rat %d', stat_data.Rat(irat + 3));
    ax.XTick = [0 25 50 75 100];
    
    if irat == 1
        ax.XLabel.String = 'Behav. cluster [%]';
        ax.XLabel.FontSize = param.fontsize_label;
    else
        ax.XTickLabel = [];
    end
end

lgd = legend({'Sit', ['Run' newline 'clockwise'], ['Run counter-' newline 'clockwise']});
lgd.Position = [.38 all_axes{1}.Position(2)+.01 .05 .16];
lgd.NumColumns = 1;
lgd.EdgeColor =  param.legend_edge_color;
lgd.FontSize = param.fontsize_label;
lgd.Title.String = 'Behavioral cluster';