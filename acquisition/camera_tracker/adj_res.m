function adj_res()
    close all
   
    
    cam = videoinput('tisimaq_r2013', 2, 'Y800 (1280x960)');
    src = getselectedsource(cam);
    cam.FramesPerTrigger = 1;
    cam.triggerrepeat = 100;
    src.Exposure = 0.01;
    start(cam);
    pause((cam.triggerrepeat+10)*src.Exposure);
    data = getdata(cam, 100);
    
    f1 = data(1:2:end ,1:2:end , 1, :) - repmat(data(1:2:end ,1:2:end , 1, 1), 1, 1, 1, 100);
    f2 = data(2:2:end ,1:2:end , 1, :) - repmat(data(2:2:end ,1:2:end , 1, 1), 1, 1, 1, 100);
    f3 = data(1:2:end ,2:2:end , 1, :) - repmat(data(1:2:end ,2:2:end , 1, 1), 1, 1, 1, 100);
    f4 = data(2:2:end ,2:2:end , 1, :) - repmat(data(2:2:end ,2:2:end , 1, 1), 1, 1, 1, 100);
    
    f1_noise = zeros(1, 100);
    f2_noise = zeros(1, 100);
    f3_noise = zeros(1, 100);
    f4_noise = zeros(1, 100);
    
    thr = 2^7;
    
    for i = 1:100
        f1_noise(i) = sum(sum(f1(:, :, 1, i)>thr));
        f2_noise(i) = sum(sum(f2(:, :, 1, i)>thr));
        f3_noise(i) = sum(sum(f3(:, :, 1, i)>thr));
        f4_noise(i) = sum(sum(f4(:, :, 1, i)>thr));
    end
    
    plot(repmat([1:100]', 1, 4), [f1_noise' f2_noise' f3_noise' f4_noise']);
    legend({'1,1', '2,1', '1,2', '2,2'});
  if (1)  
    figure;imshow(data(:,:,1,100));title('Pure data');
    
    
    figure;
    subplot(2,4,1);
    imshow(f1(:, :, 1, 100)>thr);
    title('1,1');
    subplot(2,4,2);
    pure = data(1:2:end, 1:2:end, 1, 100);
    imshow(pure);
    title(['1,1  ' num2str(mean(mean(pure(300:330, 435:465))))]);
    
    subplot(2,4,3);
    imshow(f3(:, :, 1, 100)>thr);
    title('1,2');
    subplot(2,4,4);
    pure = data(1:2:end, 2:2:end, 1, 100);
    imshow(pure);
    title(['1,2  ' num2str(mean(mean(pure(300:330, 435:465))))]);
    
    subplot(2,4,5);
    imshow(f2(:, :, 1, 100)>thr);
    title('2,1');
    subplot(2,4,6);
    pure = data(2:2:end, 1:2:end, 1, 100);
    imshow(pure);
    title(['2,1  ' num2str(mean(mean(pure(300:330, 435:465))))]);
    
    subplot(2,4,7);
    imshow(f4(:, :, 1, 100)>thr);
    title('2,2');
    subplot(2,4,8);
    pure = data(2:2:end, 2:2:end, 1, 100);
    imshow(pure);
    title(['2,2  ' num2str(mean(mean(pure(300:330, 435:465))))]);
end
    pure11 = data(1:2:end, 1:2:end, 1, 100);
    pure21 = data(2:2:end, 1:2:end, 1, 100);
    pure12 = data(1:2:end, 2:2:end, 1, 100);
    pure22 = data(2:2:end, 2:2:end, 1, 100);
    
    save('data', 'pure11', 'pure12', 'pure21', 'pure22', 'f1','f2','f3','f4');
end