function crop_riff_circle()
    frame = imread('C:\logging_data\20-03-2017T\single_frame.tif',1);
    [~, ~, center_x, center_y, radius] = calc_geometry(false);
    imageSize = size(frame);
    [xx,yy] = ndgrid((1:imageSize(1))-center_y,(1:imageSize(2))-center_x);
    mask = uint8((xx.^2 + yy.^2)<radius^2);
    temp = frame.*mask;
    figure;imshow(temp)
end