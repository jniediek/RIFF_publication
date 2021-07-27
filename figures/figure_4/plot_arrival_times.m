function plot_arrival_times(all_axes, param, mode)

S = load(fullfile('..', 'data', 'arrival_times_summary.mat'));
summary = S.summary;
all_raw = S.all_raw;
rats = 4:8;
%param = generate_colors;

if mode == "separated"

    irats = 1:5;
    
elseif mode == "merged"
    irats = 0;
end

names = {'1:1', '1:2', '2:1', '2:2'};

for irat = irats
    if irat == 0
        ts = summary(summary.Rat == -1, :);
        title_string = '';
        ax = all_axes{1};
    else
        rat = rats(irat);
        ts = summary(summary.Rat == rat, :);
        title_string = sprintf('Rat %d', rat);
        
        ax = all_axes{irat};
    end
    axes(ax)
    ax.FontSize = param.fontsize_ax;

    lcolors = param.obs_colors;
    ax.NextPlot = 'add';
    for i = 1:4
        barh(i, ts.frac(5 - i) * 100, param.barheight, 'edgecolor', 'none', ...
            'FaceColor', param.obs_colors(5 - i, :));
    end
    
    ax.XLim = [0 90];
    ax.Title.String = title_string;
    ax.Title.FontSize = param.fontsize_label;
    ax.YTick = 1:4;
    ax.YLim = [.5 4.5];
    ax.YTickLabel = flip(names);
    if irat == 0
        ax.XLabel.String = 'Rewarded trials [%]';
        ax.XLabel.FontSize = param.fontsize_label;
    end
    grid on
    
    if irat == 0
        % dots for each rat
        for jrat = 1:5
            srat = rats(jrat);
            y = summary.frac(summary.Rat == srat) * 100;
            plot(y, 4:-1:1, 'LineStyle', '-', 'Color', param.symbol_color, ... 
                'LineWidth', .2, 'Marker',...
                param.rat_symbols{jrat}, ...
                'markersize', param.rat_symbol_size, ...
                'MarkerEdgeColor', param.symbol_color, ...
                'MarkerFaceColor', param.symbol_color)
        end
        ax.YLabel.String = {'Observation', 'period'};
        ax.YLabel.FontSize = param.fontsize_label;
    end
    
    for i = 1:4
        text(2, 5-i, ...
            sprintf('%d/%d', ts.Ncorr(i), ts.Ncorr(i) + ts.Nwrong(i)), ...
            'rotation', 0, 'color', 'k', 'fontsize', param.fontsize_ax, ...
            "FontName", param.font_name)
    end
    
    if irat ==  0
        ax = all_axes{2};
    else
        ax = all_axes{i};
    end
    axes(ax);
    ax.FontSize = param.fontsize_ax;
    ax.NextPlot = 'add';
    
    plot(ax, [0 0], [0 5], 'linewidth', 2, 'color', param.time_colors(1, :))
    
    tgt_mean = 3.7262;
    tgt_std = 0.0945;
    
    boxdata = all_raw(ts.Counter);
    g = cell(4, 1);
    for i = 1:4
        g{i} = repmat(names{i}, length(boxdata{i}), 1);
    end
    
    rectangle('Position', [tgt_mean - tgt_std 0 2*tgt_std 5], 'edgecolor', 'none', ...
        'facecolor', param.time_colors(2, :))
    
    boxplot(flip(vertcat(boxdata{:})), flip(vertcat(g{:})), 'Width', .5, ...
        'orientation', 'horizontal', 'notch', 'off', 'Boxstyle', ...
        'filled', 'Symbol', '.', 'Colors', lcolors(4:-1:1, :), 'FactorGap', ...
        .1, 'OutlierSize', 6);
    
    ax.XLim = [-5; 10];
    
    ax.Box = 'off';
    ax.ActivePositionProperty = 'position';
    
    if irat < 2
        ax.XLabel.String = {'Target arrival time [sec]'};
        ax.XLabel.FontSize = param.fontsize_label;
    end
    grid on
    ax.XTick = [-5 -2.5 0 2.5 5 7.5 10];
end