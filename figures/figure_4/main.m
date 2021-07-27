S = load(fullfile('..', 'data', 'zone_angles.mat'));
zones = S.zones;

clustering_data = load(fullfile('..', 'data', 'running_trajectories.mat'));

do_sub = ones(1, 6);

data = [[2019 10 22 4 4.5]; [2019 10 23 4 20]];
pinfo = array2table(data, 'VariableNames', ...
    {'Year', 'Month', 'Day', 'Rat', 'StartMinute'});


fig = figure();
fig.Units = "centimeters";
fig.Position(3) = 18.3;
fig.Position(4) = 23;
fig.Color = 'w';

n_obs = 4;
t1 = linspace(0, 1, n_obs)';
obs_colors = [t1 .5 * ones(n_obs, 1) zeros(n_obs, 1)];

param.font_name = "Nimbus Sans";
param.fontsize_ax = 9;
param.fontsize_label = 10;

param.fontsize_letters = 12;
param.duration = 60;
param.obs_colors = obs_colors;
param.time_colors = [[0 0 0]; ...
    [0.466 0.674 0.188]; ...
    [0.494 0.184 0.556]];

param.cluster_colors = [[.5 .5 .5]; ...
    [0 0.4470 0.7410]; ...
    [0.8500 0.3250  0.0980]];

param.scatter_size = 2;
param.dot_size = 10;
param.poke_marker_size = 6;
param.barheight = .7;
param.symbol_color = [.6 .6 .6];
param.rat_symbols = {'s', 'v', 'o', 'd', '^'};
param.rat_symbol_size = 4;
param.rats = 4:8;
param.year = 2019;
param.month = 10;
param.days = 22:23;
param.cluster_start_samp = 135;
param.cluster_stop_samp = 390;
param.cluster_thr = .25;
param.legend_edge_color =  [1 1 1] * .8;
param.linewidth_error = 2;


left = [.12 .58];
a_bottom = .73;
a_height = .27;
b_bottom_1 = .57;
b_bottom_2 = .45;
b_width = .35;
b_height = .1;
a_left_shift = (b_width-a_height)/2;

c_bottom = .28;
c_height = .1;
e_bottom = .05;
e_height = .16;

param.bottom_legend_pos_y = e_height;

xs = [.002 .002 .002 .52 .002 .52];
ys = [.97 .74 .38 .38 .21 .21];

letters = 'abcdef';

for i = 1:length(letters)
    annotation(fig, 'textbox', [xs(i) ys(i) .1 .1], ...
        'String', letters(i), 'FontWeight', 'bold', ...
        'FontSize', param.fontsize_letters, ...
        'EdgeColor', 'none', 'VerticalAlignment', 'bottom', "FontName", ...
        param.font_name);
end


objects = cell(2, 1);
if do_sub(1)
    for row = 1:2
        
        t_axes.ax_arena = axes('Position', [left(row) + a_left_shift a_bottom ...
            a_height a_height]);
        t_axes.ax_arena.ActivePositionProperty = 'position';
        
        t_axes.ax_pos = axes('Position', [left(row) b_bottom_1 ...
            b_width b_height]);
        
        t_axes.ax_vel = axes('Position', [left(row) b_bottom_2 ...
            b_width b_height]);
        
        t_pinfo = pinfo(row, :);
        
        if row == 2
            param.do_colorbar = true;
            param.annotate = false;
        else
            param.do_colorbar = false;
            param.annotate = true;
        end
        
        objects{row} = plot_short_time_wrapper(t_axes, t_pinfo, param, zones);
    end
    
    
    lgd = legend(objects{1}, {'Attention', 'Target', 'Feedback', 'Nosepoke', ...
        'Food/Water', 'Missed Target'}, 'Position', [.05 b_bottom_1 + ...
        b_height + .04 .45 .02]);
    lgd.NumColumns = 2;
    lgd.TextColor = 'k';
    lgd.FontSize = param.fontsize_label;
    
    lgd.EdgeColor = 'none';
    uistack(t_axes.ax_pos, 'bottom');
    
end

if do_sub(4)
    
    pos = [left(1) c_bottom b_width c_height];
    all_axes{1} = axes('Position', pos);
    
    pos(1) = left(2);
    all_axes{2} = axes('Position', pos);
    
    for i = 1:2
        all_axes{i}.ActivePositionProperty = 'position';
    end
    plot_arrival_times(all_axes, param, "merged")
    
end

if do_sub(5)
    sub_height = e_height*.47;
    pos = [left(1) e_bottom b_width*.5 sub_height];
    all_axes{1} = axes('Position', pos);
    pos(2) = pos(2) + e_height - sub_height;
    all_axes{2} = axes('Position', pos);
    
    stat_data = cluster_stats(clustering_data, param);
    
    plot_cluster_stats(all_axes, stat_data, param);
    
    help_ax = axes('Position', [.045 e_bottom .05 e_height], 'Visible', 'off');
    text(help_ax, 0, .5, "Observation period", 'Rotation', 90, ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', ...
        'FontSize', param.fontsize_label, "FontName", param.font_name);
end

if do_sub(6)
    
    ax = axes('Position', [left(2) e_bottom b_width*.5 e_height]);
    plot_error_data(ax, param)
    
end


set(fig.Children, 'FontName', 'Nimbus Sans');
print('-r300', '-dpng', 'fig_behavior.png');
fig.Renderer = 'Painters';
print('-dsvg', 'fig_behavior.svg');