param.font_name = "Nimbus Sans";
param.fontsize_ax = 9;
param.fontsize_label = 10;
param.fontsize_letters = 12;


param.color_options.time_colors = [[0 0 0]; ...
    [0.466 0.674 0.188]; ...
    [0.494 0.184 0.556]];

param.color_options.cluster_colors = [[.5 .5 .5]; ...
    [0 0.4470 0.7410]; ...
    [0.8500 0.3250  0.0980]];


S = load(fullfile('..', 'data', 'running_trajectories.mat'));

fig = figure();
fig.Units = 'centimeters';
fig.Position(3) = 8.9*2;
fig.Position(4) = 15;
fig.Color = 'w';

ax = subplot(5, 1, 1:2);
ax.FontSize = param.fontsize_ax;
ax.Position(2) = ax.Position(2) + .08;
ax.Position(4) = ax.Position(4) - .1;
ax.Position(1) = ax.Position(1) + .03;
ax.Position(3) = ax.Position(3) - .03;

plot_supp_1(ax, S, param);

my_axes = cell(10, 1);

c = 1;
d = 9;
for rat = 1:5
    for day = 1:2
        my_axes{c} = subplot(5, 4, d);
        my_axes{c}.FontSize = param.fontsize_ax;

        my_axes{c}.Position(2) = my_axes{c}.Position(2);
        my_axes{c}.Position(4) = my_axes{c}.Position(4) - .02;
        
        if ismember(c, [1 2 5 6])
            my_axes{c}.Position(1) = my_axes{c}.Position(1) - 0.04;
        elseif ismember(c, [3 4 7 8])
            my_axes{c}.Position(1) = my_axes{c}.Position(1) + 0.04;
        end
        c = c + 1;
        if c < 9
            d = c + 8;
        else
            d = c + 9;
        end
    end
end

axlabel_flag.x = [0 0 0 0 0 0 0 0 1 1];
axlabel_flag.y = [1 0 0 0 1 0 0 0 1 0];

plot_supp_2(my_axes, S, param, axlabel_flag);

xs = [.002 .002];
ys = [.95 .6];

letters = 'ab';
for i = 1:length(letters)
    annotation(fig, 'textbox', [xs(i) ys(i) .1 .1], ...
        'String', letters(i), 'FontWeight', 'bold', ...
        'FontSize', param.fontsize_letters, ...
        'EdgeColor', 'none', 'VerticalAlignment', 'bottom', "FontName", ...
        param.font_name);
end

set(fig.Children, 'FontName', 'Nimbus Sans');
print('-r300', '-dpng', 'supp_fig_04.png');
fig.Renderer = 'Painters';
print('-dsvg', 'supp_fig_04.svg');

