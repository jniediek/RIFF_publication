function [] = analyze_collage()
    len = 5; % num of frames in a row of the collage
    area = 3;
    single_len = 200;
    led_loc = [6,6];
    [file_name,~] = uigetfile('*.tif','Select a Movie');
    info = imfinfo(file_name);
    collage_num = length(info);
    frame_num = collage_num*(len.^2);
    values = zeros(1, frame_num);
    k = 1;
    disp('=====     Start data analysis     ======');
    for i = 1:collage_num
        collage = imread(file_name, i, 'Info', info);
        for ii = 1:(len^2)
            [y x] = ind2sub([len, len], ii);
            x = x-1; y = y-1;
            values(k) = max(max(collage((x*single_len+led_loc(1)-area):(x*single_len+led_loc(1)+area), ...
                                          (y*single_len+led_loc(2)-area):(y*single_len+led_loc(2)+area))));
            k = k + 1;
        end
        if(~mod(i, 100))
            disp(['=====   ' num2str(i/collage_num*100) ' %  |   frames done: '  num2str(i)   '      ======']);
        end
    end
    values = (diff(values > 200) > 0.5);
    values = diff(find(values));
    plot(values);
    disp('=====     END data analysis     ======');
end