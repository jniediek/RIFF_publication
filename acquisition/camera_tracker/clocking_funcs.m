%% Clocking the denoising
frame = imread('background_dark.tiff');

disp('uint8(filter2(fspecial("average", 3), frame))');
tic;
for i = 1:100   % One operation takes 12.7 mSec
     a = uint8(filter2(fspecial('average', 3), frame));
end
toc

disp('wiener2(frame, [3 3]);');
tic;
for i = 1:100       % Oneoperation takes 61.5 mSec
     a = wiener2(frame, [3 3]);
end
toc

%% Clocking getdata()
imaqreset
drawnow
cam = videoinput('tisimaq_r2013',2,'Y800 (1280x960)');
src = getselectedsource(cam);

triggerconfig(cam, 'manual');
cam.FramesPerTrigger = 210;
src.Trigger = 'Disable';
src.Strobe = 'Disable';
src.Exposure = 0.033;
src.ExposureAuto = 'Off';
src.GainAuto = 'on';
src.FrameRate = '30.00';
cam.triggerrepeat = 0;

start(cam);
trigger(cam);
pause(0.033*220);


disp('[frames, t, meta] = getdata(cam, 2, "uint8", "numeric");');
stop(cam);
tic;
for i = 1:100       % One operation takes 7.57 mSec
     [frames, t, meta] = getdata(cam, 2, 'uint8', 'numeric');
end
toc

%%
frameu = imread('background_dark.tiff');
frame = double(frameu);
disp('Manual mean');
tic;
for i = 1:100       % One operation takes 36.1 mSec
     av_frame = uint8(frame(2:end-1, 2:end-1) + frame(1:end-2, 2:end-1) + ...
                 frame(2:end-1, 1:end-2) + frame(3:end, 2:end-1) + ...
                 frame(2:end-1, 3:end))/5;
end
toc


%%
bg = imread('bg.tiff');
rat = imread('rat3.tiff');
dI = (rat - bg) > 2^7;

disp('Regionprops:');
tic;
for i = 1:100       % One operation takes 4.7 mSec
     track = regionprops(dI, 'Centroid', 'Area');
end
toc

% disp('GPU regionprops:');
% tic;
% for i = 1:100       % One operation takes 26 mSec
%     dI_gpu = gpuArray(dI);
%     track = regionprops(dI_gpu, 'Centroid', 'Area');
% end
% toc

%% Clocking writing tiffs:
len = 1000;
frame = imread('bg.tiff');

tiff_h = Tiff('test_file.tif', 'w');
tagstruct = struct();
tagstruct.ImageLength = size(frame, 1);
tagstruct.ImageWidth = size(frame, 2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 8;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;


imwrite(frame,'test_file','hdf', 'Quality', 100);
tic;
for i = 1:len  % 21.5 secs
    imwrite(frame,'test_file','hdf','WriteMode','append', 'Quality', 100);
end
disp('time for h4:  ');
toc

imwrite(frame,'test_file2.tif');
tic;
for i = 1:len   % 46.3 secs
    imwrite(frame,'test_file2.tif','WriteMode','append', 'Compression', 'packbits');
end
disp('time for imwrite():  ');
toc

tic;
for i = 1:len   % 16.1 secs
    if i ~= 1
        tiff_h.writeDirectory();
    end
    tiff_h.setTag(tagstruct);
    tiff_h.write(frame);
end
disp('time for TIFF lib:  ');
toc
tiff_h.close();


% h5create('test.h5','/film',[960 1280 len]);
% h5write('test.h5','/film',frame,[1 1 1],[960 1280 1]);
% tic;
% for i = 2:len
% 	h5write('test.h5','/film',frame,[1 1 i],[960 1280 1]);  
% end
% disp('time for .h5 lib:  ');
% toc

%% Clocking tiff saving VS collage of small frames
full = imread('bg.tiff');
small = full(1:100, 1:100);

mult = 9;
tiff_len = 1000;

t_full = Tiff('test_created11.tif','w');
tagstruct = struct();
tagstruct.ImageLength = size(small,1);
tagstruct.ImageWidth = size(small,2);
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 8;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

collage = uint8(zeros(mult*100, mult*100));
t_small = Tiff('test_created22.tif','w');
tagstruct2 = struct();
tagstruct2.ImageLength = size(collage,1);
tagstruct2.ImageWidth = size(collage,2);
tagstruct2.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct2.BitsPerSample = 8;
tagstruct2.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
% tiffobj.setTag('Compression', Tiff.Compression.JPEG);


tic;
for i = 1:tiff_len
    if(i ~= 1)
        t_full.writeDirectory();
    end

    t_full.setTag(tagstruct);
    t_full.write(small);
end
toc
t_full.close;


total = mult.^2;

tic;
i = 1;
for j = 1:tiff_len

    [x,y]=ind2sub([mult mult], i);
    collage((1+(x-1)*100):(x*100), (1+(y-1)*100):(y*100)) = small;
    if (~mod(i, total))
        if(i == total)
            t_small.writeDirectory();
        end
        t_small.setTag(tagstruct2);
        t_small.write(collage);
        collage = uint8(zeros(mult*100, mult*100));
        i = 0;
    end
    i = i + 1;
end
if(mod(i-1, total))
    t_small.writeDirectory();
    t_small.setTag(tagstruct2);
    t_small.write(collage);
end
toc
t_small.close;
