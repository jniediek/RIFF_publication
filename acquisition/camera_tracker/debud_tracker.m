function debud_tracker(frame, bg)

    dI = frame - bg;
    dI_thr = dI > 2^7;
    track = regionprops(dI_thr, 'Centroid', 'Area','PixelIdxList');
    [a, ind] = max([track.Area]);
    center = track(ind).Centroid;
    disp(['Max area: ' num2str(a)]);
    [x,y] = ind2sub([960 1280], track(ind).PixelIdxList);
    
    dI_thr2 = dI > 2^6;
    track2 = regionprops(dI_thr2, 'Centroid', 'Area','PixelIdxList');
    [a2, ind2] = max([track2.Area]);
    center2 = track2(ind2).Centroid;
    disp(['Max area 2: ' num2str(a)]);
    [x2,y2] = ind2sub([960 1280], track2(ind2).PixelIdxList);
    
    
    figure;
    subplot(2,2,1);
    imshow(dI);
    
    hold on;
    h6 = plot(center(1), center(2), 'r.', 'MarkerSize', 10);
    
    subplot(2,2,2);
    imshow(dI_thr);
    hold on;
    h1 = plot(center(1), center(2), 'r.', 'MarkerSize', 10);
    h2 = plot(y, x, 'r.', 'MarkerSize', 10);
    
    subplot(2,2,3);
    imshow(dI);
    hold on;
    h3 = plot(center2(1), center2(2), 'r.', 'MarkerSize', 10);
    
    subplot(2,2,4);
    imshow(dI_thr2);
    hold on;
    h4 = plot(center2(1), center2(2), 'r.', 'MarkerSize', 10);
    h5 = plot(y2, x2, 'r.', 'MarkerSize', 10);
end