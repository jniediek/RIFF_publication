function calc_geometry(doShow) %[x, y, center_x, center_y, radius] =
load('cam_data.mat');
centData = cam_data.centData;
center_x = centData(1);
center_y = centData(2);
radius = centData(3);
areaTable = cam_data.areaTable;
len_table = areaTable.area(end);
x = radius*cos(areaTable.theta1)+center_x;
y = radius*sin(areaTable.theta1)+center_y;
if(doShow)
    frame = imread('single_frame.tif',1);
    h1 = figure;
    imshow(frame); hold on;
    for i = 1:len_table
        h1 = plot(x(i), y(i), 'r.', 'MarkerSize', 25);
    end
    %         c = {'r.', 'g.', 'y.'};
end
%     center_x = 0;
%     center_y = 0;
%     for i = 1:3
%         mean_x = (x(i)+x(i+3))/2;
%         mean_y = (y(i)+y(i+3))/2;
%         if(doShow)
%             plot(mean_x, mean_y, c{i}, 'MarkerSize', 10);
%         end
%         center_x = center_x + mean_x;
%         center_y = center_y + mean_y;
%     end
%     center_x = center_x / 3;
%     center_y = center_y / 3;

%radii = pdist2([center_x center_y], [x y]);
%     radius = mean(radii);
if(doShow)
    plot(center_x, center_y, '*', 'MarkerSize', 25);
    h1 = viscircles([center_x center_y], radius);
end
end