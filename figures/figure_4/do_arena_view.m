function do_arena_view(ax, loc, metadata, params, start)

start_time = loc.Time(1);

axes(ax);
hold on

temp_image = metadata.bg_image;

% increase brightness
temp_image = min(temp_image * 1.4, 255);

bg = cat(3, temp_image, temp_image, temp_image);
imshow(bg)

ax.Title.String = {sprintf('%.1f minutes into day %d', ...
    start, metadata.day - 21)};

scatter(loc.x, loc.y, params.scatter_size, loc.Time - start_time, 'filled')
ax.XLim = [70 550];
ax.FontSize = params.fontsize_ax;
ax.ActivePositionProperty = 'position';
size = ax.Position;

if params.do_colorbar
    axc = colorbar();
    axc.FontSize = params.fontsize_ax;
    axc.YLabel.String = 'Time [sec]';
    axc.YLabel.FontSize = params.fontsize_label;
end

ax.Position = size;