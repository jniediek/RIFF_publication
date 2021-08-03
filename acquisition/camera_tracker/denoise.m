%%
a = imread('bg.tiff', 1);
b = imread('rat.tiff', 1);

%%
a2 = wiener2(a, [7 7]);
b2 = wiener2(b, [7 7]);
dI = b2-a2;
dI_thr = dI > 2^5;

%%
a2 = uint8(filter2(fspecial('average', 3), a));
b2 = uint8(filter2(fspecial('average', 3), b));
dI = b2-a2;
dI_thr = dI > 2^5;
%%
a = 
b2 = frame_smoothed;
a2 = bg_filt;

%%
subplot(2,3,1);
imshow(bg);
title('bg');
subplot(2,3,2);
imshow(frame);
title('frame');

subplot(2,3,3);
imshow(bg_filt);
title('bg_filt');
subplot(2,3,4);
imshow(frame_smoothed);
title('frame_smoothed');

subplot(2,3,5);
imshow(dI);
title(['dI. Max: ' num2str(max(max(dI))) '. Min: ' num2str(min(min(dI)))]);
subplot(2,3,6);
imshow(dI_thr);
title(['dI_thr. Max: ' num2str(max(max(dI_thr))) '. Min: ' num2str(min(min(dI_thr))) '. No: ' num2str(sum(sum(dI_thr)))]);

%%
a2 = filter2(fspecial('average', 3), a);
subplot(1,2,1);
imshow(a);
subplot(1,2,2);
imshow(uint8(a2));

